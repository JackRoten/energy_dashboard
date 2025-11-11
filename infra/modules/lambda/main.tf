# Secrets Manager resource
resource "aws_secretsmanager_secret" "eia_api_secret" {
  name        = var.eia_secret_name
  description = "Stores the EIA API key securely"
}

# The secret value itself
resource "aws_secretsmanager_secret_version" "eia_api_secret_value" {
  secret_id = aws_secretsmanager_secret.eia_api_secret.id
  secret_string = jsonencode({
    api_key = var.eia_api_key
  })
}

# Lambda IAM Role
resource "aws_iam_role" "lambda_role" {
  name = var.lambda_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Effect = "Allow"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_secrets" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

# Lambda Layer
resource "aws_lambda_layer_version" "python_dependencies" {
  filename            = "${path.module}/../../../backend/lambda_layer.zip"
  layer_name          = var.lambda_layer_name
  compatible_runtimes = ["python3.11"]
  source_code_hash    = filebase64sha256("${path.module}/../../../backend/lambda_layer.zip")
  description         = "Python dependencies for Lambda functions"
}

# Package Lambda source
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../../../backend/lambda"
  excludes    = ["venv", "_pycache_"]
  output_path = "${path.module}/../../../backend/lambda.zip"
}

# Lambda Function
resource "aws_lambda_function" "api_lambda" {
  function_name    = var.lambda_function_name
  role             = aws_iam_role.lambda_role.arn
  handler          = var.lambda_handler
  runtime          = "python3.11"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout          = var.lambda_timeout

  layers = [
    aws_lambda_layer_version.python_dependencies.arn
  ]

  environment {
    variables = {
      DB_SECRET_NAME  = var.db_secret_name
      EIA_SECRET_NAME = aws_secretsmanager_secret.eia_api_secret.name
      REGION_NAME     = var.region
    }
  }
}

# EventBridge rule (daily trigger)
resource "aws_cloudwatch_event_rule" "daily_trigger" {
  name                = var.event_rule_name
  schedule_expression = var.schedule_expression
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.daily_trigger.name
  target_id = "LambdaTrigger"
  arn       = aws_lambda_function.api_lambda.arn
}

# Allow EventBridge to invoke Lambda
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_trigger.arn
}
