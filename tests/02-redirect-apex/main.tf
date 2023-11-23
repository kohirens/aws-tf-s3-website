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
  test_page    = "test.html"
  html_fixture = "tests/testdata/${local.test_page}"
  zip_fixture  = "tests/fixtures/bootstrap.zip"
}

data "http" "redirect_apex_to_www_01" {
  depends_on = [null_resource.debugging_time]

  url = "https://${replace(var.domain_name, "www.", "")}/test.html"
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
    command = "sleep 60"
  }
}