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
            # "token.actions.githubusercontent.com:sub" : "repo:${local.github_org}/${local.github_repo}:*"
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
      # ECR auth token (must be *)
      {
        Effect   = "Allow",
        Action   = [
          "ecr:GetAuthorizationToken"
        ],
        Resource = "*"
      },
      # ECR push/pull permissions (requires repo ARN)
      {
        Effect   = "Allow",
        Action   = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ],
        Resource = var.ecr_repository_arn
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

# --------------------------
# IAM Roles
# --------------------------

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ecs-tasks.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}


resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task_role" {
  name = "ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "github_actions_passrole" {
  name = "github-actions-passrole"
  role = aws_iam_role.github_actions_deploy_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "iam:PassRole",
        Resource = [
          aws_iam_role.ecs_task_execution_role.arn,
          aws_iam_role.ecs_task_role.arn
        ]
      }
    ]
  })
}

# ---------------------------------------

# Define an IAM Policy that grants access to Secrets Manager
resource "aws_iam_policy" "ecs_secrets_manager_access_policy" {
  name        = "ecs_secrets-manager-access-policy"
  description = "Allows ECS tasks to retrieve secrets from Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
        ],
        Effect   = "Allow",
        Resource = var.api_gateway_arn #"arn:aws:secretsmanager:REGION:ACCOUNT_ID:secret:YOUR_SECRET_NAME-??????", # Replace with your secret ARN
      },
    ],
  })
}

# Attach the policy to the ECS Task Execution Role
resource "aws_iam_role_policy_attachment" "ecs_secrets_manager_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_secrets_manager_access_policy.arn
}

# CloudWatch Logs permissions for ECS (allows auto-creating log groups)
resource "aws_iam_role_policy" "ecs_cloudwatch_logs" {
  name = "ecs-cloudwatch-logs"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup"
        ],
        Resource = "*"
      }
    ]
  })
}
