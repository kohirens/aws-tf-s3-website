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
  aws_region   = "us-west-1"
  domain_name  = "terraform.test.kohirens.com"
  html_fixture = "tests/make-a-new-public-zone/test.html"
}

provider "aws" {
  region = local.aws_region
}

module "main" {
  source         = "../.."
  aws_region     = local.aws_region
  aws_account    = 755285156183
  environment    = "qa"
  domain_name    = local.domain_name
  hosted_zone_id = "Z0250703J0M86T7FS9EO"
}

resource "aws_s3_object" "upload_fixture_webpage" {
  bucket = local.domain_name
  key    = local.html_fixture
  source = local.html_fixture
  etag   = filemd5(local.html_fixture)
}

resource "test_assertions" "certificate_made" {
  component = "certificate_made"

  equal "scheme" {
    description = "assert acm was made"
    got         = module.main.dvo_list
    want = [
      {
        "domain_name"           = local.domain_name
        "resource_record_name"  = "_82aeeebac447632bdaae992b14d6913c.terraform.test.kohirens.com."
        "resource_record_type"  = "CNAME"
        "resource_record_value" = "_80659d912e510d0f94879fa55e9e1472.fmfdpfvvyn.acm-validations.aws."
      },
    ]
  }
}
