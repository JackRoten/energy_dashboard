provider "aws" {
  region = var.region
}

data "aws_vpc" "default" {
  default = true
}

module "rds" {
  source         = "./modules/rds"
  db_secret_name = var.db_secret_name
  db_instance    = var.db_instance
  cidr_blocks    = var.cidr_blocks
  egress_port    = var.egress_port
  ingress_port   = var.ingress_port

}

module "api_lambda" {
  source         = "./modules/lambda"
  region         = var.region
  db_secret_name = var.db_secret_name
  eia_api_key    = var.eia_api_key
  # api_gateway_arn = var.api_gateway_arn
}

module "apigateway" {
  source              = "./modules/apigateway"
  lambda_function_arn = module.api_lambda.api_gateway_lambda_invoke_arn
}

module "ecs" {
  source = "./modules/ecs"
  region = var.region
}

module "iam" {
  source = "./modules/iam"
}

# module "github" {
#   source = "./modules/github"
# }