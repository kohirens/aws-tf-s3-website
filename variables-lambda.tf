variable "lf_architecture" {
  default     = ["x86_64"]
  description = "Instruction set architecture for your Lambda function. Valid values are [\"x86_64\"], [\"arm64\"]. Mind the square brackets and quotes."
  type        = list(string)
}

variable "lf_description" {
  default     = null
  description = "Provide a description"
  type        = string
}

variable "lf_environment_vars" {
  default     = null
  description = "A list of alt domain names."
  type        = map(string)
}

variable "lf_handler" {
  description = "Function entrypoint in your code (name of the executable for binaries."
  type        = string
}

variable "lf_log_retention_in_days" {
  default     = 14
  description = "Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653, and 0. If you select 0 they never expire."
  type        = number
}

variable "lf_policy_path" {
  default     = "policy-lambda.json"
  description = "Path to a IAM policy for the Lambda function."
  type        = string
}
variable "lf_role_arn" {
  default     = null
  description = "ARN for the function to assume, this will be used instad of making a new role."
  type        = string
}

variable "lf_reserved_concurrent_executions" {
  default     = -1
  description = "Amount of reserved concurrent executions for this lambda function. A value of 0 disables lambda from being triggered and -1 removes any concurrency limitations. Defaults to Unreserved Concurrency Limits."
  type        = string
}

variable "lf_runtime" {
  description = "Identifier of the function's runtime. See https://docs.aws.amazon.com/lambda/latest/dg/API_CreateFunction.html#SSS-CreateFunction-request-Runtime"
  type        = string
}

variable "lf_source_file" {
  default     = null
  description = "a file to zip up for your Lambda. Works well apps that build to a single binary."
  type        = string
}

variable "lf_source_zip" {
  default     = null
  description = "Supply your own zip for he Lambda."
  type        = string
}

variable "lf_url_alias" {
  default     = null
  description = ""
  type        = string
}

variable "lf_url_allowed_headers" {
  default     = ["date", "keep-alive"]
  description = "HTTP headers allowed."
  type        = list(string)
}

variable "lf_url_allowed_methods" {
  default     = ["GET", "HEAD"]
  description = "List of HTTP verbs allowed."
  type        = list(string)
}

variable "lf_url_headers_to_expose" {
  default     = ["keep-alive", "date"]
  description = "List of HTTP headers to expose in te response."
  type        = list(string)
}

variable "lf_url_allowed_origins" {
  default     = ["*"]
  description = "List of HTTP methods allowed."
  type        = list(string)
}

variable "lf_url_authorization_type" {
  default     = "NONE"
  description = "Valid values are NONE and AWS_IAM."
  type        = string
}

variable "lf_url_max_age" {
  default     = 0
  description = "The maximum amount of time, in seconds, that web browsers can cache results of a preflight request. The maximum value is 86400."
  type        = number
}