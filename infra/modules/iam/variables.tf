locals {
  github_org  = "JackRoten"
  github_repo = "energy_dashboard"
}

variable "api_gateway_arn" {
  type        = string
  description = "api gateway secret arn from apigateway module"
}

variable "ecr_repository_name" {
  type        = string
  description = "Name of the ECR repository for push permissions"
}

variable "ecr_repository_arn" {
  type        = string
  default     = ""
  description = "Optional full ARN of the ECR repository (if set, overrides ecr_repository_name)"
}