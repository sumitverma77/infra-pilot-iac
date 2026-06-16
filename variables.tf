variable "aws_region" {
  description = "AWS region for InfraPilot"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name used across AWS resources"
  type        = string
  default     = "infrapilot"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "prod"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.50.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.50.0.0/24", "10.50.1.0/24"]
}

variable "availability_zones" {
  description = "AZs used by the stack"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "container_port" {
  description = "Application container port"
  type        = number
  default     = 8080
}

variable "desired_count" {
  description = "Desired ECS task count"
  type        = number
  default     = 1
}

variable "task_cpu" {
  description = "Fargate task CPU units"
  type        = number
  default     = 1024
}

variable "task_memory" {
  description = "Fargate task memory in MiB"
  type        = number
  default     = 2048
}

variable "app_name" {
  description = "Application name exposed to the container"
  type        = string
  default     = "InfraPilot"
}

variable "app_version" {
  description = "Application version tag/tag used to pull from ECR"
  type        = string
  default     = "latest"
}

variable "git_commit_sha" {
  description = "Git commit SHA exposed to the container"
  type        = string
  default     = "unknown"
}

variable "build_timestamp" {
  description = "Build timestamp exposed to the container"
  type        = string
  default     = "unknown"
}

variable "hostname" {
  description = "Hostname value exposed to the container"
  type        = string
  default     = "infrapilot-aws"
}

variable "acm_certificate_arn" {
  description = "Optional ACM certificate ARN for HTTPS"
  type        = string
  default     = null
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default = {
    Project   = "InfraPilot"
    ManagedBy = "Terraform"
  }
}
