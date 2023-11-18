output "function_iam_policy_arn" {
  value = module.lambda_origin.iam_policy_arn
}

output "function_iam_role_arn" {
  value = module.lambda_origin.iam_role_arn
}

output "function_iam_role_name" {
  value = module.lambda_origin.iam_role_name
}

output "function_arn" {
  value = module.lambda_origin.function_arn
}

output "function_memory_size" {
  value = module.lambda_origin.function_memory_size
}

output "function_url" {
  value = module.lambda_origin.function_url
}

output "function_log_group_arn" {
  value = module.lambda_origin.log_group_arn
}
