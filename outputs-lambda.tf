output "function_iam_policy_arn" {
  description = "Amazon Resource Name (ARN) identifying the policy that is attached to the Lambda IAM role."
  value       = module.lambda_origin.iam_policy_arn
}

output "function_iam_role_arn" {
  description = "Amazon Resource Name (ARN) identifying the IAM assigned to the Lambda function."
  value       = module.lambda_origin.iam_role_arn
}

output "function_iam_role_name" {
  description = "Name of the IAM role used when the lambda is executed."
  value       = module.lambda_origin.iam_role_name
}

output "function_arn" {
  description = "Amazon Resource Name (ARN) identifying the Lambda function."
  value       = module.lambda_origin.function_arn
}

output "function_memory_size" {
  description = "Amount of memory in MB the Lambda function can use at runtime."
  value       = module.lambda_origin.function_memory_size
}

output "function_url" {
  description = "URL assigned to the Lambda function."
  value       = module.lambda_origin.function_url
}

output "function_log_group_arn" {
  description = "CloudWatch Log group assigned to the lambda function for receiving logs."
  value       = module.lambda_origin.log_group_arn
}
