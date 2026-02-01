locals {
  github_org  = "JackRoten"
  github_repo = "energy_dashboard"
}

variable "api_gateway_arn" {
  description = "api gateway secret arn from apigateway module"
}

variable "ecr_repository_arn" {
  description = "ARN of the ECR repository for push permissions"
}