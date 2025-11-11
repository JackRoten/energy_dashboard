provider "aws" {
  region = var.region
}

data "aws_vpc" "default" {
  default = true
}

module "rds" {
  source         = "./modules/rds"
  db_secret_name = "api_postgres_secret_v2"
}

module "api_lambda" {
  source         = "./modules/lambda"
  region         = var.region
  db_secret_name = module.rds.db_secret
  eia_api_key    = var.eia_api_key
}
