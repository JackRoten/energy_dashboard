variable "region" {}
variable "db_secret_name" {}

variable "eia_api_key" {
  description = "EIA API key for accessing electricity data"
  type        = string
  sensitive   = true
}

variable "eia_secret_name" {
  default = "eia_api_secret_v2"
}

variable "lambda_role_name" {
  default = "lambda_role"
}

variable "lambda_layer_name" {
  default = "python-dependencies-layer"
}

variable "lambda_function_name" {
  default = "api_to_postgres_lambda"
}

variable "lambda_handler" {
  default = "lambda_function.lambda_handler"
}

variable "lambda_timeout" {
  default = 60
}

variable "event_rule_name" {
  default = "daily_api_lambda_trigger"
}

variable "schedule_expression" {
  default = "cron(0 6 * * ? *)"
}
