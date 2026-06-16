terraform {
  required_version = ">= 1.6.0"

  # Uncomment and configure this block to use an S3 bucket for remote state storage in CI/CD
  # backend "s3" {
  #   bucket         = "YOUR-AWS-S3-STATE-BUCKET-NAME"
  #   key            = "infrapilot/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "YOUR-DYNAMODB-LOCK-TABLE-NAME"
  # }

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
