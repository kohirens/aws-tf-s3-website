provider "aws" {
  region = "us-east-1"
}

variables {
  iac_source = "terratest.fakehub.com"
}

run "execute" {
  variables {
    aws_region    = "us-east-1"
    domain_name   = "terraform.test.kohirens.com"
    force_destroy = true
    iac_source    = "github.com/kohirens/aws-tf-s3-website"
    lf_source_zip = "./app/bootstrap.zip"
    lf_environment_vars = {
      VERBOSITY_LEVEL : 6,
    }
  }
}

run "verify_function_url_with_arm64_al2_go_runtime" {
  module {
    source = "./tests/01-default-settings"
  }

  variables {
    domain_name                 = run.execute.fqdn
    cf_distribution_domain_name = run.execute.distribution_domain_name
    lambda_function_url         = run.execute.function_url
  }

  # asserts that:
  # 1. A bucket was made.
  # 2. Files cab be uploaded to the bucket.
  # 3. IAM permissions allow the Lambda function GetObject on the S3 bucket.
  # 4. A valid ACM certificate was issued for the domain and HTTPS is working.
  assert {
    condition     = "hi world!" == terraform_data.domain_response.output.response_body
    error_message = "not the expected test page response"
  }

  # We want to verify that we get unauthorized when trying to use the
  # distribution domain URL to ensure it is locked down.
  assert {
    condition     = terraform_data.cf_domain_response.output.status_code == "401"
    error_message = "a request to the distribution domain url returned a response code other than 401"
  }

  # Verify the function URL cannot be hit from the public internet.
  assert {
    condition     = terraform_data.function_url_response.output.status_code == "403"
    error_message = "a request to the lambda function url returned a response code other than 403"
  }

  assert {
    condition     = terraform_data.domain_asset_ok_response.output.status_code == "200"
    error_message = "a request for a valid asset in the S3 bucket returned a response code other than 200"
  }
}