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

resource "aws_s3_bucket_policy" "web" {
  bucket = aws_s3_bucket.web.id
  policy = templatefile(
    "${path.module}/policy.json",
    {
      bucket = var.domain_name
    }
  )
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
    status = var.versioning ? "Enabled" : "Disabled"
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

resource "aws_route53_zone" "web_hosted_zone" {
  name = var.domain_name
}

resource "aws_route53_record" "web_s3_alias" { # Map the domain to the S3 bucket
  allow_overwrite = false
  name            = var.domain_name
  type            = "A"
  zone_id         = aws_route53_zone.web_hosted_zone.zone_id

  alias {
    # This is a list kept by AWS here: https://docs.aws.amazon.com/general/latest/gr/s3.html#s3_website_region_endpoints
    evaluate_target_health = var.evaluate_target_health
#    name                   = "s3-website.${var.aws_region}.amazonaws.com"
    name                   = aws_s3_bucket_website_configuration.web.website_domain
    zone_id                = aws_s3_bucket.web.hosted_zone_id
  }
}
