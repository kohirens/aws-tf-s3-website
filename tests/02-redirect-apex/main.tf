terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    local = {
      source = "hashicorp/local"
    }
    null = {
      source = "hashicorp/null"
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
  apex_domain  = replace(var.domain_name, "www.", "")
  html_fixture = "tests/testdata/test.html"
  filename1    = "${path.module}/${replace(local.apex_domain, ".", "-")}.json"
  filename2    = "${path.module}/${replace(var.domain_name, ".", "-")}.json"
}

resource "aws_s3_object" "upload_fixture_webpage" {
  bucket = var.domain_name
  key    = "index.html"
  source = local.html_fixture
  etag   = filemd5(local.html_fixture)
}

resource "null_resource" "time_delay" {
  triggers = {
    distribution_domain_name = var.domain_name
  }

  provisioner "local-exec" {
    command = "sleep 60"
  }
}

# check the url
resource "null_resource" "redirect_apex_to_www" {
  depends_on = [null_resource.time_delay]

  triggers = {
    apex_domain = local.apex_domain
  }

  provisioner "local-exec" {
    command = "${path.module}/../testdata/test-endpoint.sh 'https://${local.apex_domain}/' > ${local.filename1}"
  }
}

# get the response
data "local_file" "redirect_apex_to_www" {
  depends_on = [null_resource.redirect_apex_to_www]

  filename = local.filename1
}

# For help see: https://developer.hashicorp.com/terraform/language/resources/terraform-data
resource "terraform_data" "redirect_apex_to_www" {
  triggers_replace = [data.local_file.redirect_apex_to_www.id]

  input = jsondecode(data.local_file.redirect_apex_to_www.content)
}

resource "null_resource" "www_no_redirect_loop" {
  depends_on = [null_resource.time_delay]

  triggers = {
    domain_name = var.domain_name
  }

  provisioner "local-exec" {
    command = "${path.module}/../testdata/test-endpoint.sh 'https://${var.domain_name}/' > ${local.filename2}"
  }
}

data "local_file" "www_no_redirect_loop" {
  depends_on = [null_resource.www_no_redirect_loop]

  filename = local.filename2
}

resource "terraform_data" "www_no_redirect_loop" {
  triggers_replace = [data.local_file.www_no_redirect_loop.id]

  input = jsondecode(data.local_file.www_no_redirect_loop.content)
}

locals {
  test_script = "${path.module}/../testdata/test-endpoint.sh"
  get_options = "${path.module}/${replace(var.domain_name, ".", "-")}-options.json"
}

resource "null_resource" "get_options" {
  depends_on = [null_resource.time_delay]

  triggers = {
    domain_name = var.domain_name
  }

  provisioner "local-exec" {
    command = "curl -X OPTIONS 'https://${var.domain_name}/' -i > ${local.get_options}"
  }
}

data "local_file" "get_options" {
  depends_on = [null_resource.www_no_redirect_loop]

  filename = local.get_options
}
