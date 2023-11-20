provider "aws" {
  region = "us-east-1"
}

variables {
  domain_name   = "terraform.test.kohirens.com"
  iac_source   = "terratest.fakehub.com"
}

run "execute" {
  variables {
    aws_region    = "us-east-1"
    force_destroy = true
    iac_source    = "github.com/kohirens/aws-tf-s3-website"
    lf_source_zip = "./tests/testdata/bootstrap.zip"
  }
}

run "verify_function_url_with_arm64_al2_go_runtime" {
  module {
    source = "./tests/make-a-website"
  }

  variables {
    cf_distribution_domain_name = run.execute.distribution_domain_name
  }

  assert {
    condition     = data.http.test_function_url_response.response_body == "Hello from Lambda!"
    error_message = "lambda function ${var.name} cannot be invoked via HTTPS"
  }

  # asserts that:
  # 1. A bucket was made.
  # 2. Files cab be uploaded to the bucket.
  # 3. IAM permissions allow the Lambda function GetObject on the S3 bucket.
  # 4. A valid ACM certificate was issued for the domain and HTTPS is working.
  assert {
    condition     = "hi world!" == data.http.test_page_response.response_body
    error_message = "could not get test page response"
  }

  # We want to verify that we get unauthorized when trying to use the
  # distribution domain URL to ensure it is locked down.
  assert {
    condition     = data.http.test_page_response_cf_domain.code == 401
    error_message = "did not get the expected unauthorized response from distribution domain"
  }
}