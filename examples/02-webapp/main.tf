locals {
  region = "us-east-2"
  domain = "webapp.example.com"
}

provider "aws" {
  region = local.region
}

module "webapp" {
  source = "../.."

  // defaults to the aws account and region set with the login credential,
  // but you can also set them with aws_account and aws_region variables.
  hosted_zone_id = "Z000000000000000000O"
  domain_name    = local.domain
  iac_source     = "github.com/example/website"
  lf_source_zip  = "../../app/bootstrap.zip"
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