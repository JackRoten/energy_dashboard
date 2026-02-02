provider "aws" {
  region = var.region
}

data "aws_vpc" "default" {
  default = true
}

data "aws_caller_identity" "current" {}

module "rds" {
  # TODO: modularize iam roles
  source         = "./modules/rds"
  db_secret_name = var.db_secret_name
  db_instance    = var.db_instance
  cidr_blocks    = var.cidr_blocks
  egress_port    = var.egress_port
  ingress_port   = var.ingress_port

}

module "api_lambda" {
  # TODO: modularize iam roles
  source         = "./modules/lambda"
  region         = var.region
  db_secret_name = var.db_secret_name
  eia_api_key    = var.eia_api_key
}

module "apigateway" {
  # TODO: modularize iam roles
  source              = "./modules/apigateway"
  lambda_function_arn = module.api_lambda.api_gateway_lambda_invoke_arn
}

module "ecs" {
  # Define resources for ecs deployment
  source = "./modules/ecs"
  region = var.region
  ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn
}

module "iam" {
  # Define roles and policies for following modules
  source               = "./modules/iam"
  api_gateway_arn      = module.apigateway.api_gateway_arn
  ecr_repository_name  = "react-app"
}


module "github" {
  # Define github action secrets containing 
  source = "./modules/github"
  github_actions_deploy_role_arn = module.iam.github_actions_deploy_role_arn
  ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn
  ecs_task_role_arn = module.iam.ecs_task_role_arn
  api_gateway_id = module.apigateway.api_gateway_id
}