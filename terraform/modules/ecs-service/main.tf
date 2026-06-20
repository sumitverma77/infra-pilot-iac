# 1. Security Group for the Service (Ingress restricted only to traffic from ALB)
resource "aws_security_group" "service" {
  name        = "${var.service_name}-${var.environment}-service-sg"
  description = "ECS service security group for ${var.service_name}"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.service_name}-${var.environment}-service-sg"
  }
}

# 2. Target Group for ALB routing
resource "aws_lb_target_group" "app" {
  name                 = "${var.service_name}-${var.environment}-tg"
  port                 = var.container_port
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  target_type          = "ip"
  deregistration_delay = 30 # Speed up connection draining from 300s default

  health_check {
    enabled             = true
    path                = var.health_check_path
    protocol            = "HTTP"
    port                = "traffic-port"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

# 3. ALB Listener Rule
resource "aws_lb_listener_rule" "routing" {
  listener_arn = var.alb_listener_arn
  priority     = var.alb_routing_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }

  condition {
    path_pattern {
      values = var.alb_path_patterns
    }
  }
}

# 4. CloudWatch Log Group for container logs
resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${var.service_name}-${var.environment}"
  retention_in_days = var.environment == "prod" ? 30 : 7
}

# 5. ECS Task Definition with Placeholder image
resource "aws_ecs_task_definition" "app" {
  family                   = "${var.service_name}-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.shared_execution_role_arn
  task_role_arn            = var.custom_task_role_arn

  container_definitions = jsonencode([
    {
      name      = var.service_name
      image     = "public.ecr.aws/nginx/nginx:alpine" # Placeholder image, updated by CI/CD
      essential = true

      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]

      secrets = [
        for key, arn in var.secrets_map : {
          name      = key
          valueFrom = arn
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.app.name
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  # Ignore container image changes during updates (CI/CD handles it)
  lifecycle {
    ignore_changes = [container_definitions]
  }
}

# 6. ECS Service
resource "aws_ecs_service" "app" {
  name                               = "${var.service_name}-${var.environment}"
  cluster                            = var.ecs_cluster_arn
  task_definition                    = aws_ecs_task_definition.app.arn
  desired_count                      = var.desired_count
  launch_type                        = "FARGATE"
  platform_version                   = "LATEST"
  health_check_grace_period_seconds  = 120
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  enable_execute_command             = true

  network_configuration {
    subnets          = var.subnets
    security_groups  = [aws_security_group.service.id]
    assign_public_ip = true # Required for NAT Gateway-avoidance setup
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = var.service_name
    container_port   = var.container_port
  }

  # Prevent Terraform from reverting the active Spring Boot image back to the nginx placeholder
  lifecycle {
    ignore_changes = [task_definition]
  }

  depends_on = [
    aws_lb_listener_rule.routing
  ]
}
