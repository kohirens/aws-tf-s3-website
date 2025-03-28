variable "domain_name" {
  type = string
}

locals {
  test_page    = "test-03.html"
  html_fixture = "tests/testdata/${local.test_page}"
}

resource "aws_s3_object" "upload_fixture_webpage" {
  bucket       = var.domain_name
  content_type = "text/html"
  key          = local.test_page
  source       = local.html_fixture
  etag         = filemd5(local.html_fixture)
}

data "http" "domain_name" {
  url = "https://${var.domain_name}/${local.test_page}"
}
