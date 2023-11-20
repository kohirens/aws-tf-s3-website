terraform {
  required_providers {
    http = {
      source = "hashicorp/http"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

variable "domain_name" {
  type = string
}

variable "cf_distribution_domain_name" {
  type = string
}

locals {
  aws_region   = "us-east-1"
  domain_name  = "terraform.test.kohirens.com"
  test_page    = "test.html"
  html_fixture = "tests/testdata/${local.test_page}"
  zip_fixture  = "tests/fixtures/bootstrap.zip"
}

resource "aws_s3_object" "upload_fixture_webpage" {
  bucket = var.domain_name
  key    = local.test_page
  source = local.html_fixture
  etag   = filemd5(local.html_fixture)
}

# Cannot seem to find the certificate that is issued in US-EAST-1 during `terraform test`
# data "aws_acm_certificate" "issued" {
#   depends_on = [
#     module.website
#   ]
#
#  domain      = module.website.fqdn
#  statuses    = ["ISSUED"]
#  types       = ["AMAZON_ISSUED"]
#  most_recent = true
# }

data "http" "test_page_response" {
  url = "https://${var.domain_name}/test.html"
}

data "http" "test_page_response_cf_domain" {
  url = "https://${var.cf_distribution_domain_name}/test.html"
}