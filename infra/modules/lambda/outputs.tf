output "eia_lambda_function_arn" {
  value = aws_lambda_function.eia_api_lambda.arn
}

output "eia_event_rule_name" {
  value = aws_cloudwatch_event_rule.monthly_trigger.name
}

output "eia_secret_name" {
  value = aws_secretsmanager_secret.eia_api_secret.name
}

output "api_gateway_lambda_invoke_arn" {
  value = aws_lambda_function.api_gateway_lambda.invoke_arn
}

# output "api_gateway__rule_name" {
#   value = aws_cloudwatch_event_rule.monthly_trigger.name
# }

