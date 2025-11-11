output "rds_endpoint" {
  value = aws_db_instance.postgres.address
}
# output "lambda_name" {
#   value = aws_lambda_function.api_lambda.function_name
# }
