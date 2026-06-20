# Shared ECS Fargate Cluster
resource "aws_ecs_cluster" "this" {
  name = local.name_prefix

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# Environment-specific compute sizing configurations
locals {
  service_sizing = {
    stage = {
      cpu           = 256
      memory        = 512
      desired_count = 1
    }
    prod = {
      cpu           = 512
      memory        = 1024
      desired_count = 2
    }
  }

  current_sizing = local.service_sizing[var.environment]
}

# Onboard the main API application service using the reusable ecs-service module
module "app_service" {
  source = "./modules/ecs-service"

  service_name              = var.project_name
  environment               = var.environment
  vpc_id                    = aws_vpc.this.id
  ecs_cluster_arn           = aws_ecs_cluster.this.arn
  subnets                   = aws_subnet.public[*].id
  alb_security_group_id     = aws_security_group.alb.id
  shared_execution_role_arn = aws_iam_role.ecs_task_execution.arn
  custom_task_role_arn      = aws_iam_role.ecs_task.arn

  # Route HTTPS if SSL certificate is present, otherwise fallback to HTTP listener
  alb_listener_arn = var.acm_certificate_arn == null ? aws_lb_listener.http.arn : aws_lb_listener.https[0].arn

  container_port    = var.container_port
  health_check_path = "/actuator/health/readiness"

  # Sizing configured dynamically per environment
  cpu           = local.current_sizing.cpu
  memory        = local.current_sizing.memory
  desired_count = local.current_sizing.desired_count

  # Priority and path routing
  alb_routing_priority = 100
  alb_path_patterns    = ["/*"]

  # Application Secrets from AWS Secrets Manager
  secrets_map = {
    "SPRING_DATASOURCE_PASSWORD" = "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:${var.environment}/db-password"
  }
}
