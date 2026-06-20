variable "service_name" {
  type        = string
  description = "Name of the microservice (e.g., user-service)"
}

variable "environment" {
  type        = string
  description = "Deployment environment (stage or prod)"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the service will be deployed"
}

variable "ecs_cluster_arn" {
  type        = string
  description = "ARN of the shared ECS Cluster"
}

variable "alb_listener_arn" {
  type        = string
  description = "ARN of the shared ALB Listener"
}

variable "alb_security_group_id" {
  type        = string
  description = "Security Group ID of the shared ALB (to allow ingress)"
}

variable "subnets" {
  type        = list(string)
  description = "Subnets where the Fargate tasks will run"
}

variable "shared_execution_role_arn" {
  type        = string
  description = "ARN of the shared ECS Task Execution Role"
}

variable "custom_task_role_arn" {
  type        = string
  default     = null
  description = "Optional custom IAM Task Role ARN (defaults to None)"
}

variable "container_port" {
  type        = number
  default     = 8080
  description = "Port exposed by the application container"
}

variable "health_check_path" {
  type        = string
  default     = "/health"
  description = "Path used by the load balancer health check"
}

variable "cpu" {
  type        = number
  default     = 256
  description = "Task CPU limit"
}

variable "memory" {
  type        = number
  default     = 512
  description = "Task Memory limit"
}

variable "desired_count" {
  type        = number
  default     = 1
  description = "Desired number of running tasks"
}

variable "alb_routing_priority" {
  type        = number
  description = "Priority number for ALB listener rules (must be unique)"
}

variable "alb_path_patterns" {
  type        = list(string)
  description = "List of path patterns to route to this service"
}

variable "secrets_map" {
  type        = map(string)
  default     = {}
  description = "Map of environment variables to AWS Secrets Manager secret ARNs"
}
