output "bucket_arn" {
  description = "The ARN of the bucket."
  value       = aws_s3_bucket.web.arn
}

output "bucket_domain_name" {
  description = "The bucket domain name."
  value       = aws_s3_bucket.web.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "The bucket region-specific domain name. The bucket domain name including the region name, please refer here for format. Note: The AWS CloudFront allows specifying S3 region-specific endpoint when creating S3 origin, it will prevent redirect issues from CloudFront to S3 Origin URL."
  value       = aws_s3_bucket.web.bucket_regional_domain_name
}

output "bucket_website_hosted_zone_id" {
  description = "The Route 53 Hosted Zone ID for this bucket's region."
  value       = aws_s3_bucket.web.hosted_zone_id
}

output "certificate_arn" {
  description = "ACM certificate ARN"
  value       = length(aws_acm_certificate.web) > 0 ? aws_acm_certificate.web[0].arn : null
}

output "distribution_domain_name" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.web.domain_name
}

output "distribution_hosted_zone_id" {
  description = "Hosted zone ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.web.hosted_zone_id
}

output "distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.web.id
}

output "distribution_status" {
  description = "Status of the CloudFront distribution"
  value       = aws_cloudfront_distribution.web.status
}

output "dvo_list" {
  description = "Domain validation list"
  value       = local.dvo_list
}

output "fqdn" {
  description = "The FQDN pointing to the CloudFront distribution"
  value       = length(aws_route53_record.web_s3_alias) > 0 ? aws_route53_record.web_s3_alias[0].fqdn : null
}

output "hosted_zone" {
  description = "Name of the Route 53 zone containing the CloudFront Alias record"
  value       = var.hosted_zone_id == null ? aws_route53_zone.web_hosted_zone[0].name : null
}

output "hosted_zone_id" {
  description = "ID of the Route 53 zone containing the CloudFront Alias record"
  value       = var.hosted_zone_id == null ? aws_route53_zone.web_hosted_zone[0].zone_id : var.hosted_zone_id
}

output "hosted_zone_ns" {
  description = "Route 53 zone"
  value       = var.hosted_zone_id == null ? aws_route53_zone.web_hosted_zone[0].name_servers : null
}
