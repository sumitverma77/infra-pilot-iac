output "target_group_arn" {
  value       = aws_lb_target_group.app.arn
  description = "ARN of the Target Group"
}

output "task_definition_arn" {
  value       = aws_ecs_task_definition.app.arn
  description = "ARN of the Task Definition"
}

output "service_name" {
  value       = aws_ecs_service.app.name
  description = "Name of the ECS Service"
}
