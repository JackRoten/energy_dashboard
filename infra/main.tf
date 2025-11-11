provider "aws" {
  region = var.region
}

# 👇 Fetch your default VPC
data "aws_vpc" "default" {
  default = true
}

module "rds" {
  source         = "./modules/rds"
  db_secret_name = "api_postgres_secret_v2" # Changed to avoid conflict with deleted secret
}

module "api_lambda" {
  source         = "./modules/lambda"
  region         = var.region
  db_secret_name = module.rds.db_secret
  eia_api_key    = var.eia_api_key
}
