data "sh_vars" "lambda" {
  count = var.lf_external_env_vars == null ? 0 : 1
  names = var.lf_external_env_vars
}

locals {
  alt_domain_names = length(var.alt_domain_names) > 0 ? join(",", var.alt_domain_names) : ""
  required_vars = {
    REDIRECT_TO          = var.domain_name
    REDIRECT_HOSTS       = local.alt_domain_names
    S3_BUCKET_NAME       = aws_s3_bucket.web.id
    HTTP_METHODS_ALLOWED = join(",", local.cf_http_methods)
  }
  ext_vars            = length(data.sh_vars.lambda) > 0 ? data.sh_vars.lambda[0].values : { "none" : "true" }
  lf_environment_vars = merge(local.required_vars, var.lf_environment_vars, local.ext_vars)

  policy_path = var.lf_policy_path != null ? var.lf_policy_path : "${path.module}/files/policy-lambda-iam-role.json"
  policy_doc = templatefile(local.policy_path, {
    account_no = local.account
    bucket     = aws_s3_bucket.web.id
    lambda_arn = module.lambda_origin.function_arn
    region     = local.region
  })
}

module "lambda_origin" {
  source = "github.com/kohirens/aws-tf-lambda-function//.?ref=2.1.1"

  add_url     = true
  aws_account = local.account
  aws_region  = local.region
  iac_source  = var.iac_source
  name        = local.name
  description = var.lf_description != null ? var.lf_description : "CloutFront origin for ${var.domain_name}"

  architecture                   = var.lf_architecture
  handler                        = var.lf_handler
  invoke_mode                    = var.lf_invoke_mode
  log_retention_in_days          = var.lf_log_retention_in_days
  policy_path                    = null
  role_arn                       = var.lf_role_arn
  reserved_concurrent_executions = var.lf_reserved_concurrent_executions
  runtime                        = var.lf_runtime
  source_file                    = var.lf_source_file
  source_zip                     = var.lf_source_zip
  url_alias                      = var.lf_url_alias
  url_cors_allowed_headers       = var.lf_url_cors_allowed_headers
  url_cors_allowed_methods       = var.lf_url_cors_allowed_methods
  url_cors_headers_to_expose     = var.lf_url_cors_headers_to_expose
  url_cors_allowed_origins       = var.lf_url_cors_allowed_origins
  url_cors_max_age               = var.lf_url_cors_max_age
  environment_vars               = local.lf_environment_vars
  url_authorization_type         = "AWS_IAM"
}

resource "aws_iam_role_policy" "lambda_s3_policy" {
  name   = "s3-${local.name}"
  role   = module.lambda_origin.iam_role_name
  policy = local.policy_doc
}

# Add a resource policy to the Lambda function to allow Cloudfront access to invoke it.
resource "aws_lambda_permission" "allow_cloudfront" {
  depends_on    = [module.lambda_origin]
  statement_id  = "AllowCloudFrontServicePrincipal"
  action        = "lambda:InvokeFunctionUrl"
  principal     = "cloudfront.amazonaws.com"
  function_name = local.name
  source_arn    = aws_cloudfront_distribution.web.arn
}