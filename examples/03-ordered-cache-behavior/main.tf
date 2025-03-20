locals {
  # Windows: $Env:GOARCH="arm64"; $Env:GOOS="linux"; go build -tags "lambda.norpc" .\cmd\bootstrap
  # Linux/Mac: GOARCH="arm64" GOOS="linux" go build -tags "lambda.norpc" .\cmd\bootstrap
  test_page    = "test-03.html"
  html_fixture = "../../tests/testdata/${local.test_page}"
  domain_name  = "terraform-03.test.kohirens.com"
  region       = "us-east-2"
}

provider "aws" {
  region = local.region
}

# upload a file to the S3 bucket.
resource "aws_s3_object" "upload_fixture_webpage" {
  depends_on   = [module.webapp]
  bucket       = local.domain_name
  content_type = "text/html"
  key          = local.test_page
  source       = local.html_fixture
  etag         = filemd5(local.html_fixture)
}

module "webapp" {
  source = "../.."

  hosted_zone_id = "Z0000000000000000000"
  aws_region     = local.region
  domain_name    = local.domain_name
  force_destroy  = true
  iac_source     = "github.com/kohirens/aws-tf-s3-website"
  lf_source_zip  = "../../app/bootstrap.zip"

  # 4135ea2d-6df8-44a3-9df3-4b5a84be39ad = Managed-CacheDisabled
  # "" = None
  cf_additional_ordered_cache_behaviors = [
    {
      allowed_methods          = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
      compress                 = true
      path_pattern             = "/*.html"
      smooth_streaming         = false
      target_origin_id         = "s3-terraform-03-test-kohirens-com"
      viewer_protocol_policy   = "redirect-to-https"
      cache_policy_id          = "658327ea-f89d-4fab-a63d-7e88639e58f6" # Managed-CachingOptimized
      origin_request_policy_id = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf" # Managed-CORS-S3Origin
      grpc_config = {
        enabled = true
      }
    }
  ]
}

output "fqdn" {
  description = "The FQDN pointing to the CloudFront distribution"
  value       = module.webapp.fqdn
}