# Role that ECS uses to pull images and write container logs on your behalf.
resource "aws_iam_role" "ecs_task_execution" {
  name = "${local.name_prefix}-ecs-execution"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  # Grants the execution role the standard ECS permissions from AWS.
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_default" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  # Role assumed by the application containers themselves.
}

resource "aws_iam_role" "ecs_task" {
  name = "${local.name_prefix}-ecs-task"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}
# Lets the application task write directly to CloudWatch Logs.

resource "aws_iam_role_policy" "ecs_task_cloudwatch" {
  name = "${local.name_prefix}-task-cloudwatch"
  role = aws_iam_role.ecs_task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

# Grants the shared execution role permissions to read environment-specific Secrets.
resource "aws_iam_policy" "ecs_secrets" {
  name        = "${local.name_prefix}-ecs-secrets"
  description = "Allows ECS execution role to fetch secrets from Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:${var.environment}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_secrets" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = aws_iam_policy.ecs_secrets.arn
}

# --- GitHub OIDC Configuration ---

# Global OIDC Provider for GitHub Actions
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1", "1c58a3a8518e8759bf075b76b750d4f2df264fcd"]
}

# 1. Infra Deploy Role (Allowed to deploy infra changes from main and stage branches)
module "infra_deploy_role" {
  source            = "./modules/github-oidc-role"
  role_name         = "infra-deploy-role"
  oidc_provider_arn = aws_iam_openid_connect_provider.github.arn
  github_org        = "sumitverma77"
  match_subjects = [
    "repo:sumitverma77/infra-pilot-iac:ref:refs/heads/main",
    "repo:sumitverma77/infra-pilot-iac:ref:refs/heads/stage"
  ]
  managed_policies = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}

# 2. App Deploy Role - Stage (Allowed to deploy to stage environment)
module "app_deploy_stage_role" {
  source            = "./modules/github-oidc-role"
  role_name         = "app-deploy-stage-role"
  oidc_provider_arn = aws_iam_openid_connect_provider.github.arn
  github_org        = "sumitverma77"
  match_subjects = [
    "repo:sumitverma77/infra-pilot-api:environment:stage",
    "repo:sumitverma77/user-service:environment:stage",
    "repo:sumitverma77/payment-service:environment:stage",
    "repo:sumitverma77/notification-service:environment:stage"
  ]
  managed_policies = [
    "arn:aws:iam::aws:policy/AmazonECS_FullAccess",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
  ]
}

# 3. App Deploy Role - Prod (Allowed to deploy to prod environment)
module "app_deploy_prod_role" {
  source            = "./modules/github-oidc-role"
  role_name         = "app-deploy-prod-role"
  oidc_provider_arn = aws_iam_openid_connect_provider.github.arn
  github_org        = "sumitverma77"
  match_subjects = [
    "repo:sumitverma77/infra-pilot-api:environment:prod",
    "repo:sumitverma77/user-service:environment:prod",
    "repo:sumitverma77/payment-service:environment:prod",
    "repo:sumitverma77/notification-service:environment:prod"
  ]
  managed_policies = [
    "arn:aws:iam::aws:policy/AmazonECS_FullAccess",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
  ]
}
