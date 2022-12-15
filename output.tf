output "bucket_arn" {
  description = "The ARN of the bucket."
  value       = aws_s3_bucket.app.arn
}

output "bucket_bucket_domain_name" {
  description = "The bucket domain name."
  value       = aws_s3_bucket.app.bucket_domain_name
}

output "bucket_bucket_regional_domain_name" {
  description = "The bucket region-specific domain name. The bucket domain name including the region name, please refer here for format. Note: The AWS CloudFront allows specifying S3 region-specific endpoint when creating S3 origin, it will prevent redirect issues from CloudFront to S3 Origin URL."
  value       = aws_s3_bucket.app.bucket_regional_domain_name
}

output "bucket_hosted_zone_id" {
  description = "The Route 53 Hosted Zone ID for this bucket's region."
  value       = aws_s3_bucket.app.hosted_zone_id
}

output "bucket_website_endpoint" {
  description = "The website endpoint, if the bucket is configured with a website. If not, this will be an empty string."
  value       = aws_s3_bucket_website_configuration.app_website.website_endpoint
}

output "bucket_website_domain" {
  description = "The domain of the website endpoint, if the bucket is configured with a website. If not, this will be an empty string. This is used to create Route 53 alias records. "
  value       = aws_s3_bucket_website_configuration.app_website.website_domain
}
output "fqdn" {
  description = "The FQDN"
  value       = aws_route53_record.a_record.fqdn
}

output "route_53_zone" {
  description = "Route 53 zone"
  value       = aws_route53_zone.app_domain
}