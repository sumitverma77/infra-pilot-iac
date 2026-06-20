output "vpc_id" {
  description = "VPC ID of the deployment"
  value       = aws_vpc.this.id
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS Name"
  value       = aws_lb.this.dns_name
}

output "ecr_repository_url" {
  description = "ECR Repository URL"
  value       = aws_ecr_repository.this.repository_url
}

output "ecs_cluster_name" {
  description = "ECS Cluster Name"
  value       = aws_ecs_cluster.this.name
}

output "ecs_service_name" {
  description = "ECS Service Name"
  value       = module.app_service.service_name
}

output "infra_deploy_role_arn" {
  description = "ARN of the Infrastructure Deployment Role"
  value       = var.environment == "stage" ? module.infra_deploy_role[0].role_arn : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/infra-deploy-role"
}

output "app_deploy_stage_role_arn" {
  description = "ARN of the Application Stage Deployment Role"
  value       = var.environment == "stage" ? module.app_deploy_stage_role[0].role_arn : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/app-deploy-stage-role"
}

output "app_deploy_prod_role_arn" {
  description = "ARN of the Application Prod Deployment Role"
  value       = var.environment == "stage" ? module.app_deploy_prod_role[0].role_arn : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/app-deploy-prod-role"
}
