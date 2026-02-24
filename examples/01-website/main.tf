locals {
  domain = "webapp.example.com"
}

provider "aws" {
  region = "us-east-1"
}

module "webapp" {
  source = "../.."

  domain_name    = var.domain_name
  lf_source_zip  = var.lf_source_zip
  iac_source     = "github.com/b01/aws-tf-s3-wesbite"
  force_destroy  = true
  hosted_zone_id = var.hosted_zone_id
}

# upload a file to the S3 bucket.
resource "aws_s3_object" "upload_fixture_webpage" {
  depends_on   = [module.webapp]
  bucket       = local.domain
  content_type = "text/html"
  key          = "index.html"
  source       = "../files/index.html"
}

output "fqdn" {
  description = "The FQDN pointing to the CloudFront distribution"
  value       = module.webapp.fqdn
}