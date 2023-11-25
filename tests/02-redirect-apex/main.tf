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

locals {
  html_fixture = "tests/testdata/test.html"
}

resource "aws_s3_object" "upload_fixture_webpage" {
  bucket = var.domain_name
  key    = "index.html"
  source = local.html_fixture
  etag   = filemd5(local.html_fixture)
}

data "http" "redirect_apex_to_www_01" {
  depends_on = [null_resource.debugging_time]

  url = "https://${replace(var.domain_name, "www.", "")}"
}

data "http" "www_no_redirect_loop" {
  depends_on = [null_resource.debugging_time]

  url = "https://${var.domain_name}"
}

resource "null_resource" "debugging_time" {
  triggers = {
    distribution_domain_name = var.domain_name
  }

  provisioner "local-exec" {
    command = "sleep 300"
  }
}