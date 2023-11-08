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

resource "aws_s3_bucket_public_access_block" "web" {
  bucket                  = aws_s3_bucket.web.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "web" {
  bucket = aws_s3_bucket.web.id
  versioning_configuration {
    status = var.s3_enable_versioning ? "Enabled" : "Disabled"
  }
}
