resource "aws_s3_bucket" "app" {
  bucket        = var.domain_name
  force_destroy = var.force_destroy

  tags = {
    module = "kohirens/aws-tf-s3-website"
  }
}

resource "aws_s3_bucket_acl" "backend_logs_acl" {
  bucket = aws_s3_bucket.app.id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "app_policy" {
  bucket = aws_s3_bucket.app.id
  policy = templatefile(
    "${path.module}/policy.json",
    {
      bucket = var.domain_name
    }
  )
}

resource "aws_s3_bucket_public_access_block" "app_public" {
  bucket                  = aws_s3_bucket.app.id
  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false
}

resource "aws_s3_bucket_versioning" "backend_logs_versioning" {
  bucket = aws_s3_bucket.app.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_website_configuration" "app_website" {
  bucket = aws_s3_bucket.app.id

  index_document {
    suffix = var.page_index
  }

  error_document {
    key = var.page_error
  }
}

resource "aws_route53_zone" "app_domain" {
  name = var.domain_name
}

resource "aws_route53_record" "a_record" {
  allow_overwrite = false
  name            = var.domain_name
  type            = "A"
  zone_id         = aws_route53_zone.app_domain.zone_id

  alias {
    evaluate_target_health = var.evaluate_target_health
    name                   = aws_s3_bucket.app.bucket_regional_domain_name
    zone_id                = aws_s3_bucket.app.hosted_zone_id
  }
}
