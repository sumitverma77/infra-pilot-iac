# Variables configuration for InfraPilot deployment environments
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

  validation {
    condition     = contains(["prod", "stage"], var.environment)
    error_message = "The environment variable must be either 'prod' or 'stage'."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.50.0.0/16"

  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.vpc_cidr))
    error_message = "The vpc_cidr variable must be a valid CIDR block notation (e.g. 10.0.0.0/16)."
  }
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

  validation {
    condition     = contains([256, 512, 1024, 2048, 4096], var.task_cpu)
    error_message = "The task_cpu value must be a valid Fargate CPU size (256, 512, 1024, 2048, or 4096)."
  }
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
