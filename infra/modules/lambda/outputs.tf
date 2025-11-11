output "lambda_function_arn" {
  value = aws_lambda_function.api_lambda.arn
}

output "event_rule_name" {
  value = aws_cloudwatch_event_rule.daily_trigger.name
}

output "eia_secret_name" {
  value = aws_secretsmanager_secret.eia_api_secret.name
}
