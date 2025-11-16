# 👇 Fetch your default VPC

data "aws_vpc" "default" {
  default = true
}

# 👇 Create a security group for PostgreSQL access
resource "aws_security_group" "rds_sg" {
  name        = "e_dash/rds_public_access_sg"
  description = "Allow inbound PostgreSQL"
  vpc_id      = data.aws_vpc.default.id
  
  ingress {
    description = "PostgreSQL from your IP (for testing)"
    from_port   = var.ingress_port
    to_port     = var.ingress_port
    protocol    = "tcp"
    # For local dev only — replace with your own IP:
    cidr_blocks = var.cidr_blocks
  }

  egress {
    from_port   = var.egress_port
    to_port     = var.egress_port
    protocol    = "-1"
    cidr_blocks = var.cidr_blocks
  }

  lifecycle {
        create_before_destroy = true
      }

}

# 1️⃣ Create RDS Postgres instance
resource "aws_db_instance" "postgres" {
  identifier             = var.db_instance.identifier
  engine                 = var.db_instance.engine
  instance_class         = var.db_instance.instance_class
  allocated_storage      = var.db_instance.allocated_storage
  username               = var.db_instance.username
  password               = var.db_instance.passsword
  db_name                = var.db_instance.db_name
  publicly_accessible    = var.db_instance.publicly_accessible
  skip_final_snapshot    = var.db_instance.skip_final_snapshot
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  

}

# 2️⃣ Create Secrets Manager secret
resource "aws_secretsmanager_secret" "db_secret" {
  name = var.db_secret_name
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "db_secret_value" {
  secret_id = aws_secretsmanager_secret.db_secret.id
  secret_string = jsonencode({
    username = aws_db_instance.postgres.username
    password = aws_db_instance.postgres.password
    host     = aws_db_instance.postgres.address
    dbname   = aws_db_instance.postgres.db_name
    port     = aws_db_instance.postgres.port
  })
}