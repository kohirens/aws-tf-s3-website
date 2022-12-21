# So we cannot really on `terraform test` for this simple case, which means
# unfortunately that we are still stuck with TerraTest.

# The command `terraform test` would be preferred, as that would mean that
# our developers do not have to learn Terraform and Go; and would increase
# the rate of adoption for writing test for terraform.

# Terraform test does not currently produce any helpful output on Windows when

# $Env:TF_LOG="INFO"
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

# Find a certificate that is issued
data "aws_acm_certificate" "issued" {
  domain      = module.main.fqdn
  statuses    = ["ISSUED"]
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

locals {
  test_url_parts = regex(
    "^(?:(?P<scheme>[^:/?#]+):)?(?://(?P<authority>[^/?#]*))?",
    "https://${module.main.fqdn}/test.html"
  )
}

data "http" "test_page_response" {
  depends_on = [
    local.test_url_parts
  ]

  url = "https://${module.main.fqdn}/test.html"
}

resource "test_assertions" "website_deployed" {
  component = "website_deployed"

  depends_on = [
    module.main,
    data.http.test_page_response,
  ]

  equal "acm_cert" {
    description = "acm issued cert"
    got         = data.aws_acm_certificate.issued.arn
    want        = module.main.certificate_arn
  }

  equal "scheme" {
    description = "acm made validations"
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

  check "get_response" {
    description = "assert response from fixture test page"
    # This SHOULD fail, the response body should contain "hi world!" and NOT
    # "it worked!".
    condition   = can(regex("it worked!", data.http.test_page_response.body))
  }

  check "acm_has_cert" {
    description = "acm cert exist"
    condition   = can(regex("^.+", module.main.certificate_arn))
  }
}
