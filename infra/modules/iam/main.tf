locals {
  github_org  = "JackRoten"
  github_repo = "energy_dashboard"
}

# -------------------------------
# GitHub OIDC Identity Provider
# -------------------------------
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]
}

# -------------------------------
# Deploy Role for GitHub Actions
# -------------------------------
resource "aws_iam_role" "github_actions_deploy_role" {
  name = "github-actions-ecs-deploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringLike = {
            # Restrict to pushes in your repo only!
            "token.actions.githubusercontent.com:sub" : "repo:${local.github_org}/${local.github_repo}:ref:refs/heads/main"
          },
          StringEquals = {
            "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

# -------------------------------
# Policies for ECS + ECR Deploy
# -------------------------------
resource "aws_iam_policy" "github_actions_ecs_deploy_policy" {
  name        = "GitHubActionsECSDeployPolicy"
  description = "Allows pushing to ECR and deploying to ECS"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # ECR push/pull permissions
      {
        Effect   = "Allow",
        Action   = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ],
        Resource = "*"
      },

      # ECS deployment permissions
      {
        Effect   = "Allow",
        Action   = [
          "ecs:DescribeServices",
          "ecs:DescribeTaskDefinition",
          "ecs:DescribeTasks",
          "ecs:ListTasks",
          "ecs:RegisterTaskDefinition",
          "ecs:UpdateService"
        ],
        Resource = "*"
      }
    ]
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "github_actions_deploy_attach" {
  role       = aws_iam_role.github_actions_deploy_role.name
  policy_arn = aws_iam_policy.github_actions_ecs_deploy_policy.arn
}

output "github_actions_deploy_role_arn" {
  value = aws_iam_role.github_actions_deploy_role.arn
}

provider "github" {
  owner = "JackRoten"
}

resource "github_actions_secret" "deploy_role_arn" {
  repository  = "energy_dashboard"
  secret_name = "AWS_DEPLOY_ROLE_ARN"
  plaintext_value = aws_iam_role.github_actions_deploy_role.arn
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