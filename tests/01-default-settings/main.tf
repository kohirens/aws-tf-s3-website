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
  filename1    = "${path.module}/${replace(var.domain_name, ".", "-")}.json"
  filename2    = "${path.module}/${replace(var.cf_distribution_domain_name, ".", "-")}.json"
  filename3    = replace(var.lambda_function_url, "https://", "")
  filename4    = "${replace(local.filename3, "/", "")}.json"
  filename5    = "${path.module}/${replace(local.filename4, ".", "-")}.json"
}

resource "aws_s3_object" "upload_fixture_webpage" {
  bucket = var.domain_name
  key    = local.test_page
  source = local.html_fixture
  etag   = filemd5(local.html_fixture)
}

# serves as a delay to wait for the infrastructure to be really ready.
resource "null_resource" "time_delay" {
  triggers = {
    distribution_domain_name = var.cf_distribution_domain_name
  }

  provisioner "local-exec" {
    command = "sleep 5"
  }
}

# check the url
resource "null_resource" "domain_response" {
  depends_on = [null_resource.time_delay]

  triggers = {
    domain_name = var.domain_name
  }

  provisioner "local-exec" {
    command = "${path.module}/../testdata/test-endpoint.sh 'https://${var.domain_name}/${local.test_page}' > ${local.filename1}"
  }
}

# get the response
data "local_file" "domain_response" {
  depends_on = [null_resource.domain_response]

  filename = local.filename1
}

# For help see: https://developer.hashicorp.com/terraform/language/resources/terraform-data
resource "terraform_data" "domain_response" {
  triggers_replace = [data.local_file.domain_response.id]

  input = jsondecode(data.local_file.domain_response.content)
}

resource "null_resource" "cf_domain_response" {
  depends_on = [null_resource.time_delay]

  triggers = {
    cf_distribution_domain_name = var.cf_distribution_domain_name
  }

  provisioner "local-exec" {
    command = "${path.module}/../testdata/test-endpoint.sh 'https://${var.cf_distribution_domain_name}/${local.test_page}' > ${local.filename2}"
  }
}

data "local_file" "cf_domain_response" {
  depends_on = [null_resource.cf_domain_response]

  filename = local.filename2
}

resource "terraform_data" "cf_domain_response" {
  triggers_replace = [data.local_file.cf_domain_response.id]

  input = jsondecode(data.local_file.cf_domain_response.content)
}

resource "null_resource" "function_url_response" {
  depends_on = [null_resource.time_delay]

  triggers = {
    function_url_response = var.lambda_function_url
  }

  provisioner "local-exec" {
    command = "${path.module}/../testdata/test-endpoint.sh '${var.lambda_function_url}/${local.test_page}' > ${local.filename5}"
  }
}

data "local_file" "function_url_response" {
  depends_on = [null_resource.function_url_response]

  filename = local.filename5
}

resource "terraform_data" "function_url_response" {
  triggers_replace = [data.local_file.function_url_response.id]
  input            = jsondecode(data.local_file.function_url_response.content)
}

locals {
  test_img                 = "red-corner-01.svg"
  svg_fixture              = "tests/testdata/${local.test_img}"
  test_script              = "${path.module}/../testdata/test-endpoint.sh"
  domain_asset_ok_response = "${path.module}/${replace(local.test_img, ".", "-")}.json"
}

resource "aws_s3_object" "upload_fixture_image" {
  bucket = var.domain_name
  key    = "/assets/${local.test_img}"
  source = local.svg_fixture
  etag   = filemd5(local.html_fixture)
}

# check asset url
resource "null_resource" "domain_asset_ok_response" {
  depends_on = [null_resource.time_delay]

  triggers = {
    domain_name = var.domain_name
  }

  provisioner "local-exec" {
    command = "${local.test_script} 'https://${var.domain_name}/assets/${local.test_img}' > ${local.domain_asset_ok_response}"
  }
}

# get the response
data "local_file" "domain_asset_ok_response" {
  depends_on = [null_resource.domain_asset_ok_response]

  filename = local.domain_asset_ok_response
}

resource "terraform_data" "domain_asset_ok_response" {
  triggers_replace = [data.local_file.domain_asset_ok_response.id]
  input            = jsondecode(data.local_file.domain_asset_ok_response.content)
}