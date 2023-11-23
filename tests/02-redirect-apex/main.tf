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

locals {
  test_page    = "test.html"
  html_fixture = "tests/testdata/${local.test_page}"
  zip_fixture  = "tests/fixtures/bootstrap.zip"
}

data "http" "redirect_apex_to_www_01" {
  depends_on = [ null_resource.debugging_time ]

  retry {
    attempts     = 2
    min_delay_ms = 5000
  }
  url = "https://${replace(var.domain_name, "www.", "")}/test.html"
}

data "http" "do_not_redirect_apex_to_www_02" {
  depends_on = [ null_resource.debugging_time ]

  retry {
    attempts     = 2
    min_delay_ms = 5000
  }
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