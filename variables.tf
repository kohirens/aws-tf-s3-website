variable "alias_evaluate_target_health" {
  description = "Evaluate the health of the alis. Required if record type is \"A\"."
  type        = bool
  default     = true
}

variable "alias_regional_domain_name" {
  description = "The regional domain name for the alias. Required if record type is \"A\"."
  type        = string
  default     = null
}

variable "alias_zone_id" {
  description = "Hosted zone ID for a CloudFront distribution, S3 bucket, ELB, or Route 53 hosted zone. Required if record type is \"A\"."
  type        = string
}

variable "aws_account" {
  description = "AWS account ID."
  type        = number
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "domain_name" {
  description = "The website domain name, for example: test.example.com."
  type        = string
}

variable "environment" {
  description = "Designated environment label, for example: prod, beta, test, non-prod, etc."
  type        = string
}

variable "force_destroy" {
  description = "force bucket destruction"
  type        = bool
  default     = false
}

variable "page_400" {
  default     = "400.html"
  description = "400 page."
  type        = string
}

variable "page_index" {
  default     = "index.html"
  description = "Index page."
  type        = string
}
