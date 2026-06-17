terraform {
  required_version = ">= 1.6.0"

  backend "s3" {
    bucket         = "infrapilot-terraform-state-sumit"
    region         = "us-east-1"
    dynamodb_table = "infrapilot-state-locks"
    # The key (state file path) will be overridden dynamically in the CI/CD pipeline
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = merge(var.tags, {
      Environment = var.environment
      Service     = var.project_name
    })
  }
}

data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}
