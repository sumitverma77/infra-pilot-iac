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
  value       = aws_ecs_service.app.name
}
