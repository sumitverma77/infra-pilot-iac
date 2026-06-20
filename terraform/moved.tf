# State migration blocks to transition existing resources into the app_service module without recreation.

moved {
  from = aws_lb_target_group.app
  to   = module.app_service.aws_lb_target_group.app
}

moved {
  from = aws_cloudwatch_log_group.app
  to   = module.app_service.aws_cloudwatch_log_group.app
}

moved {
  from = aws_ecs_task_definition.app
  to   = module.app_service.aws_ecs_task_definition.app
}

moved {
  from = aws_ecs_service.app
  to   = module.app_service.aws_ecs_service.app
}
