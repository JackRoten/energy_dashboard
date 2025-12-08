resource "aws_api_gateway_rest_api" "api" {
  name        = "backend-api"
  description = "API for front-end"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "route" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "data"
}

resource "aws_api_gateway_method" "get" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.route.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_invoke" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.route.id
  http_method = aws_api_gateway_method.get.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_function_arn
}

resource "aws_api_gateway_deployment" "lambda_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  depends_on = [
    aws_api_gateway_integration.lambda_invoke,
  ]
}

resource "aws_api_gateway_stage" "dev" {
  stage_name    = "dev"
  rest_api_id   = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.lambda_api_deployment.id
}

# Secrets Manager resource
resource  "aws_secretsmanager_secret" "api_gateway_secret" {
  name        = "api_gateway_secret"
  description = "Stores the API Gateway id"
  recovery_window_in_days = 0
}

# The secret value itself
resource "aws_secretsmanager_secret_version" "api_gateway_secret_value" {
  secret_id = aws_secretsmanager_secret.api_gateway_secret.id
  secret_string = jsonencode({
    api_key = aws_api_gateway_rest_api.api.id
  })
}