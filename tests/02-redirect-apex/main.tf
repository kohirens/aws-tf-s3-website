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

resource "null_resource" "delay_time" {
  triggers = {
    distribution_domain_name = var.domain_name
  }

  provisioner "local-exec" {
    command = "sleep 60"
  }
}

# For help see: https://developer.hashicorp.com/terraform/language/resources/terraform-data
resource "terraform_data" "redirect_apex_to_www_01" {
  depends_on = [null_resource.delay_time]

  provisioner "local-exec" {
    command = "${path.module}/../testdata/test-endpoint.sh 'https://${replace(var.domain_name, "www.", "")}'"
  }
}

resource "terraform_data" "www_no_redirect_loop" {
  depends_on = [null_resource.delay_time]

  provisioner "local-exec" {
    command = "${path.module}/../testdata/test-endpoint.sh 'https://${var.domain_name}'"
  }
}

output "domain_response" {
  value = tomap(terraform_data.redirect_apex_to_www_01.output)
}

output "cf_domain_response" {
  value = tomap(terraform_data.www_no_redirect_loop.output)
}