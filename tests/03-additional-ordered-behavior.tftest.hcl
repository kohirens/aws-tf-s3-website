provider "aws" {
  region = "us-east-1"
}

run "execute" {
  variables {
    aws_region    = "us-east-1"
    domain_name   = "terraform-03.test.kohirens.com"
    force_destroy = true
    iac_source    = "github.com/kohirens/aws-tf-s3-website"
    lf_source_zip = "./app/bootstrap.zip"

    cf_additional_ordered_cache_behaviors = [
      {
        allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
        compress               = true
        path_pattern           = "/*.html"
        smooth_streaming       = false
        target_origin_id       = "s3-terraform-03-test-kohirens-com"
        viewer_protocol_policy = "redirect-to-https"
        grpc_config = {
          enabled = true
        }
      }
    ]
  }
}

run "additional_ordered_cache_behavior" {
  module {
    source = "./tests/03-ordered-cache-behavior"
  }

  variables {
    domain_name = run.execute.fqdn
  }

  assert { # the response code
    condition     = terraform_data.response_1.output.status_code == "200"
    error_message = "the request resulted in a response code other than 200"
  }

  assert { # the response code
    condition     = data.http.domain_name.status_code == "200"
    error_message = "the request resulted in a response code other than 200"
  }

  assert { # the response body
    condition     = data.http.domain_name.response_body == "just what I wanted!"
    error_message = "did not get the expected response body"
  }
}