# So we cannot really on `terraform test` for this simple case, which means
# unfortunately that we are still stuck with TerraTest.

# The command `terraform test` would be preferred, as that would mean that
# our developers do not have to learn Terraform and Go; and would increase
# the rate of adoption for writing test for terraform.

# Terraform test does not currently produce any output when resources fail to
# deploy, instead it:
# 1. fails silently
# 2. automatically skips all test
# 3. return an exit code of 0
# So use set the terraform environment variable TF_LOG="INFO" or DEBUG|INFO|WARN|ERROR
terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }

    http = {
      source = "hashicorp/http"
    }

    aws = {
      source  = "hashicorp/aws"
      version = ">=3.40.0, <5.0.0"
    }
  }
}

locals {
  aws_region   = "us-east-1"
  domain_name  = "terraform.test.kohirens.com"
  test_page    = "test.html"
  html_fixture = "tests/fixtures/${local.test_page}"
  zip_fixture  = "tests/fixtures/bootstrap.zip"
}

provider "aws" {
  region = local.aws_region
}

module "website" {
  source         = "../.."
  aws_account    = 755285156183
  aws_region     = local.aws_region
  domain_name    = local.domain_name
  environment    = "qa"
  force_destroy    = true
  hosted_zone_id = "Z0250703J0M86T7FS9EO"
  iac_source     = "github.com/kohirens/aws-tf-s3-website"
  lf_source_zip  = local.zip_fixture
}

resource "aws_s3_object" "upload_fixture_webpage" {
  depends_on = [
    module.website
  ]

  bucket = local.domain_name
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
  url = "https://${module.website.fqdn}/test.html"
}

data "http" "test_page_response_cf_domain" {
  url = "https://${module.website.cf_distribution_domain_name}/test.html"
}

resource "test_assertions" "website_deployed" {
  component = "website_deployed"

  depends_on = [
    module.website,
    data.http.test_page_response,
  ]

  # assert a domain validation was made
#   equal "acm_validation" {
#     description = "acm validation request made"
#     got         = module.website.dvo_list
#     want = [
#       {
#         "domain_name"           = local.domain_name
#         "resource_record_name"  = "_82aeeebac447632bdaae992b14d6913c.terraform.test.kohirens.com."
#         "resource_record_type"  = "CNAME"
#         "resource_record_value" = "_80659d912e510d0f94879fa55e9e1472.fmfdpfvvyn.acm-validations.aws."
#       },
#     ]
#   }

  # asserts that:
  # a bucket with the domain name was made
  # files cab be uploaded to the bucket
  # the policy on the bucket allows access from this CloudFront distribution
  # a valid ACM certificate was issue for the domain
  # HTTPS is working via the CloudFront distribution
  equal "get_response" {
    description = "assert response from fixture test page"
    want        = "hi world!"
    got         = data.http.test_page_response.response_body
  }

  equal "get_response_cf" {
    description = "assert response from fixture test page"
    want        = "hi world!"
    got         = data.http.test_page_response_cf_domain.response_body
  }
}
