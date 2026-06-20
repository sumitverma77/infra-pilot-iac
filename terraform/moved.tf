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

# State migration blocks to handle the addition of the count parameter on global IAM resources
moved {
  from = aws_iam_openid_connect_provider.github
  to   = aws_iam_openid_connect_provider.github[0]
}

moved {
  from = module.infra_deploy_role
  to   = module.infra_deploy_role[0]
}

moved {
  from = module.app_deploy_stage_role
  to   = module.app_deploy_stage_role[0]
}

moved {
  from = module.app_deploy_prod_role
  to   = module.app_deploy_prod_role[0]
}
