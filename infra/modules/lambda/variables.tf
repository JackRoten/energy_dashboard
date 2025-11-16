variable "region" {}

variable "db_secret_name" {
  description = "Name for the database secret in Secrets Manager"
  type        = string
}

variable "eia_api_key" {
  description = "EIA API key for accessing electricity data"
  type        = string
  sensitive   = true
}

variable "eia_secret_name" {
  default = "eia_api_secret_v3"
}

variable "lambda_role_name" {
  default = "e_dash_lambda_role"
}

variable "lambda_layer_name" {
  default = "python-dependencies-layer"
}

variable "eia_lambda_function_name" {
  default = "eia_api_to_postgres"
}

variable "lambda_handler" {
  default = "lambda_function.lambda_handler"
}

variable "lambda_timeout" {
  default = 60
}

variable "monthly_event_rule_name" {
  default = "monthly_api_lambda_trigger"
}

variable "monthly_schedule_expression" {
  default = "cron(0 0 10 * ? *)"
}

variable "api_gateway_lambda_function_name" {
  default = "api_gateway"
}

# variable "api_gateway_arn" {
#   type = string
# }

variable "daily_event_rule_name" {
  default = "daily_api_lambda_trigger"
}

variable "daily_schedule_expression" {
  default = "cron(0 0 10 * ? *)"
}
