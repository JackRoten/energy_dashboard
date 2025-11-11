output "rds_endpoint" {
  value = aws_db_instance.postgres.address
}

output "db_secret" {
  value = aws_secretsmanager_secret.db_secret.name
}