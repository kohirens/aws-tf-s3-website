moved {
  from = aws_s3_bucket.app
  to   = aws_s3_bucket.web
}

resource "aws_s3_bucket" "web" {
  bucket        = var.domain_name
  force_destroy = var.force_destroy

  tags = {
    module = "kohirens/aws-tf-s3-website"
  }
}

resource "aws_s3_bucket_acl" "web" {
  bucket = aws_s3_bucket.web.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "web" {
  bucket                  = aws_s3_bucket.web.id
  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false
}

resource "aws_s3_bucket_versioning" "web" {
  bucket = aws_s3_bucket.web.id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_website_configuration" "web" {
  bucket = aws_s3_bucket.web.id

  index_document {
    suffix = var.index_page
  }

  error_document {
    key = var.error_page
  }
}

resource "aws_s3_bucket_policy" "web" {
  depends_on = [
    aws_cloudfront_distribution.web
  ]

  bucket = aws_s3_bucket.web.id
  policy = templatefile(
    "${path.module}/bucket-policy.json",
    {
      account_no = var.aws_account
      bucket     = var.domain_name
      cfd_id     = aws_cloudfront_distribution.web.id
    }
  )
}

