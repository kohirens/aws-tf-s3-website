variable "evaluate_target_health" {
  description = "Evaluate the health of the alis. Required if record type is \"A\"."
  type        = bool
  default     = true
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

variable "page_error" {
  default     = "400.html"
  description = "Error page for 4xx HTTP status errors."
  type        = string
}

variable "page_index" {
  default     = "index.html"
  description = "Index page."
  type        = string
}
