variable "domain_name" {
  type = string
}

locals {
  test_page    = "test-03.html"
  html_fixture = "tests/testdata/${local.test_page}"
  filename1    = "${path.module}/${replace(var.domain_name, ".", "-")}.json"
}

resource "aws_s3_object" "upload_fixture_webpage" {
  bucket       = var.domain_name
  content_type = "text/html"
  key          = local.test_page
  source       = local.html_fixture
  etag         = filemd5(local.html_fixture)
}

# check the url
resource "null_resource" "response_1" {
  triggers = {
    domain_name = var.domain_name
  }

  provisioner "local-exec" {
    command = "${path.module}/../testdata/test-endpoint.sh 'https://${var.domain_name}/${local.test_page}' > ${local.filename1}"
  }
}

# get the response
data "local_file" "response_1" {
  depends_on = [null_resource.response_1]

  filename = local.filename1
}

data "http" "domain_name" {
  url = "https://${var.domain_name}/${local.test_page}"
}
