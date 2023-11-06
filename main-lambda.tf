locals {
  alt_domain_names = length(var.alt_domain_names) > 0 ? join(",", var.alt_domain_names) : ""
  required_vars = {
    REDIRECT_TO    = var.domain_name
    REDIRECT_HOSTS = local.alt_domain_names
    S3_BUCKET_NAME = aws_s3_bucket.web.id
  }
  lf_environment_vars = merge(local.required_vars, var.lf_environment_vars)

  policy_path = var.lf_policy_path != null ? var.lf_policy_path : "${path.module}/policy-lambda.json"
  policy_doc = templatefile(local.policy_path, {
    region         = var.aws_region
    account_no     = var.aws_account
    lambda_arn     = module.lambda_origin.function_arn
    cloudfront_arn = aws_cloudfront_distribution.web.arn
  })
}

module "lambda_origin" {
  source = "git@github.com:kohirens/aws-tf-lambda-function//.?ref=add-env-vars-var"

  add_url     = true
  aws_account = var.aws_account
  aws_region  = var.aws_region
  iac_source  = var.iac_source
  name        = replace(var.domain_name, ".", "_")
  description = var.lf_description != null ? var.lf_description : "CloutFront origin for a website"

  architecture                   = var.lf_architecture
  handler                        = var.lf_handler
  log_retention_in_days          = var.lf_log_retention_in_days
  policy_path                    = null #local.policy_doc
  role_arn                       = var.lf_role_arn
  reserved_concurrent_executions = var.lf_reserved_concurrent_executions
  runtime                        = var.lf_runtime
  source_file                    = var.lf_source_file
  source_zip                     = var.lf_source_zip
  url_alias                      = var.lf_url_alias
  url_allowed_headers            = var.lf_url_allowed_headers
  url_allowed_methods            = var.lf_url_allowed_methods
  url_headers_to_expose          = var.lf_url_headers_to_expose
  url_allowed_origins            = var.lf_url_allowed_origins
  url_authorization_type         = var.lf_url_authorization_type
  url_max_age                    = var.lf_url_max_age
  environment_vars               = local.lf_environment_vars
}
