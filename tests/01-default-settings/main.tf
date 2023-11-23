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

variable "cf_distribution_domain_name" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "lambda_function_url" {
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

data "http" "domain_response" {
  depends_on = [null_resource.debugging_time]

  url = "https://${var.domain_name}/test.html"
}

data "http" "cf_domain_response" {
  depends_on = [null_resource.debugging_time]

  url = "https://${var.cf_distribution_domain_name}/test.html"
}

data "http" "function_url_response" {
  depends_on = [null_resource.debugging_time]

  url = "${var.lambda_function_url}test.html"
}

resource "null_resource" "debugging_time" {
  triggers = {
    distribution_domain_name = var.cf_distribution_domain_name
  }

  provisioner "local-exec" {
    command = "sleep 60"
  }
}