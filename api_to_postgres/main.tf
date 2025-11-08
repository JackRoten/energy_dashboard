data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda.zip"
}


provider "aws" {
  region = var.region
}

# 1️⃣ Create RDS Postgres instance
resource "aws_db_instance" "postgres" {
  identifier              = "api-postgres-db"
  engine                  = "postgres"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  username                = "admin"
  password                = "password123"  # Use a random password in real setup
  db_name                 = "apidb"
  publicly_accessible     = true
  skip_final_snapshot     = true
}

# 2️⃣ Create Secrets Manager secret
resource "aws_secretsmanager_secret" "db_secret" {
  name = "api_postgres_secret"
}

resource "aws_secretsmanager_secret_version" "db_secret_value" {
  secret_id     = aws_secretsmanager_secret.db_secret.id
  secret_string = jsonencode({
    username = aws_db_instance.postgres.username
    password = aws_db_instance.postgres.password
    host     = aws_db_instance.postgres.address
    dbname   = aws_db_instance.postgres.db_name
    port     = aws_db_instance.postgres.port
  })
}

# 3️⃣ Lambda IAM Role
resource "aws_iam_role" "lambda_role" {
  name = "api_lambda_role"
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

# 4️⃣ Lambda function
resource "aws_lambda_function" "api_lambda" {
  function_name    = "api_to_postgres_lambda"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.10"
  filename         = data.archive_file.lambda_zip.output_path
  timeout          = 60

  environment {
    variables = {
      DB_SECRET_NAME = aws_secretsmanager_secret.db_secret.name
      AWS_REGION     = var.region
    }
  }
}

# 5️⃣ EventBridge rule (daily trigger)
resource "aws_cloudwatch_event_rule" "daily_trigger" {
  name                = "daily_api_lambda_trigger"
  schedule_expression = "cron(0 6 * * ? *)" # 6 AM UTC daily
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
