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

data "http" "test_page_response" {
  retry {
    attempts     = 3
    min_delay_ms = 60000
  }
  url = "https://${var.domain_name}/test.html"
}

data "http" "test_page_response_cf_domain" {
  retry {
    attempts     = 3
    min_delay_ms = 60000
  }
  url = "https://${var.cf_distribution_domain_name}/test.html"
}

# Wait for the domain to resolve
resource "null_resource" "domain_resolution" {
  triggers = {
    distribution_domain_name = var.cf_distribution_domain_name
  }

  provisioner "local-exec" {
    command = "chmod +x ./tests/testdata/wait-for-dna-resolve.sh; ./tests/testdata/wait-for-dna-resolve.sh '${var.domain_name}' '300' '1'"
  }
}