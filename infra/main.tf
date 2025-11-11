provider "aws" {
  region = var.region
}

# 👇 Fetch your default VPC
data "aws_vpc" "default" {
  default = true
}

# 👇 Create a security group for PostgreSQL access
resource "aws_security_group" "rds_sg" {
  name        = "rds_public_access_sg"
  description = "Allow inbound PostgreSQL"
  vpc_id      = data.aws_vpc.default.id   # ✅ use the default VPC ID

  ingress {
    description = "PostgreSQL from your IP (for testing)"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    # For local dev only — replace with your own IP:
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 1️⃣ Create RDS Postgres instance
resource "aws_db_instance" "postgres" {
  identifier              = "api-postgres-db"
  engine                  = "postgres"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  username                = "admin_main"
  password                = "password123"  # Use a random password in real setup
  db_name                 = "apidb"
  publicly_accessible     = true
  skip_final_snapshot     = true
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]

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

# Variable to hold your secret (never hardcode the key!)
variable "eia_api_key" {
  description = "EIA API key for accessing electricity data"
  type        = string
  sensitive   = true
}

# Secrets Manager resource
resource "aws_secretsmanager_secret" "eia_api_secret" {
  name        = "eia_api_secret"
  description = "Stores the EIA API key securely"
}

# The secret value itself
resource "aws_secretsmanager_secret_version" "eia_api_secret_value" {
  secret_id     = aws_secretsmanager_secret.eia_api_secret.id
  secret_string = jsonencode({
    api_key = var.eia_api_key
  })
}

module "api_lambda" {
  source = "./modules/lambda"
  region          = var.region
  db_secret_name  = aws_secretsmanager_secret.db_secret.name
  eia_secret_name = aws_secretsmanager_secret.eia_api_secret.name
}
