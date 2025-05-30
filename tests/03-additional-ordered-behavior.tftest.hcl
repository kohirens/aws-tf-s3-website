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
        allowed_methods          = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
        compress                 = true
        path_pattern             = "/*.html"
        smooth_streaming         = false
        target_origin_id         = "s3-terraform-03-test-kohirens-com"
        viewer_protocol_policy   = "redirect-to-https"
        cache_policy_id          = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # Managed-CachingDisabled; Managed-CachingOptimized (658327ea-f89d-4fab-a63d-7e88639e58f6
        origin_request_policy_id = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf" # Managed-CORS-S3Origin
        cached_methods           = ["GET", "HEAD", "OPTIONS", ]
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
    condition     = data.http.domain_name.status_code == 200
    error_message = "the request resulted in a response code other than 200"
  }

  assert { # the response body
    condition     = strcontains(data.http.domain_name.response_body, "just what I wanted!")
    error_message = "did not get the expected response body"
  }
}