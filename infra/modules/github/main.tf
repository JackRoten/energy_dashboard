provider "github" {
  owner = "JackRoten"
}

resource "github_actions_secret" "deploy_role_arn" {
  repository  = "energy_dashboard"
  secret_name = "AWS_DEPLOY_ROLE_ARN"
  plaintext_value = var.github_actions_deploy_role_arn # aws_iam_role.github_actions_deploy_role.arn
}

resource "github_actions_secret" "ecs_task_execution_role_arn" {
  repository  = "energy_dashboard"
  secret_name = "ECS_TASK_EXECUTION_ROLE_ARN"
  plaintext_value = var.ecs_task_execution_role_arn # aws_iam_role.ecs_task_execution_role.arn 
}

resource "github_actions_secret" "ecs_task_role_arn" {
  repository  = "energy_dashboard"
  secret_name = "ECS_TASK_ROLE_ARN"
  plaintext_value = var.ecs_task_role_arn # aws_iam_role.ecs_task_role.arn
}

resource "github_actions_secret" "aws_region" {
  repository  = "energy_dashboard"
  secret_name = "AWS_REGION"
  plaintext_value = "us-west-2"
}

resource "github_actions_secret" "ecr_repository" {
  repository  = "energy_dashboard"
  secret_name = "ECR_REPOSITORY"
  plaintext_value = "react-app"
}

resource "github_actions_secret" "ecs_cluster" {
  repository  = "energy_dashboard"
  secret_name = "ECS_CLUSTER"
  plaintext_value = "react-app-cluster"
}

resource "github_actions_secret" "ecs_service" {
  repository  = "energy_dashboard"
  secret_name = "ECS_SERVICE"
  plaintext_value = "react-app-service"
}

resource "github_actions_secret" "task_definition_family" {
  repository  = "energy_dashboard"
  secret_name = "TASK_DEFINITION_FAMILY"
  plaintext_value = "react-app-task"
}
