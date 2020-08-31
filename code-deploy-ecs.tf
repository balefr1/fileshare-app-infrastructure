resource "aws_codedeploy_app" "ecs-codedeploy-app" {
  compute_platform = "ECS"
  name             = format("%s-deploy-fileshare",var.customer_name)
}

resource "aws_codedeploy_deployment_group" "ecs-codedeploy-dg" {
  app_name               = aws_codedeploy_app.ecs-codedeploy-app.name
  deployment_config_name = "CodeDeployDefault.ECSCanary10Percent5Minutes"
  deployment_group_name  = "fileshare-app-dg"
  service_role_arn       = aws_iam_role.codedeploy_ecs_role.arn

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.ecs.name
    service_name = aws_ecs_service.ecs_service.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_alb_listener.alb_listener_https.arn]
      }

      target_group {
        name = aws_alb_target_group.ecs-tg.name
      }

      target_group {
        name = aws_alb_target_group.ecs-tg-b.name
      }
    }
  }
}