resource "aws_s3_bucket" "app" {
  acl           = "private"
  bucket        = var.domain_name
  force_destroy = false

  policy = templatefile(
    "${path.module}/policy.json",
    {
      bucket = var.domain_name
    }
  )

  tags = {
    module         = "kohirens/aws-tf-s3-website"
    module_version = "0.0.1"
  }

  versioning {
    enabled = true
  }

  website {
    index_document = "index.html"
    error_document = "400.html"
  }
}

resource "aws_s3_bucket_public_access_block" "app_public" {
  bucket                  = aws_s3_bucket.app.id
  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false
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
    evaluate_target_health = false
    name                   = var.alias_regional_domain_name
    zone_id                = var.alias_zone_id
  }
}