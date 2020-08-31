### ECS

resource "aws_ecs_cluster" "ecs" {
  name = "${var.customer_name}-ecs"
  tags = var.tags
}

resource "aws_cloudwatch_log_group" "cloudwatch_ecs_log_group" {
  name = "/ecs/${var.customer_name}/fileshare-app"
  tags = var.tags
}

resource "aws_ecs_task_definition" "ecs_task_app" {
  family                   = "fileshare-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = <<DEFINITION
[
  {
    "cpu": 0,
    "image": "${var.fileshare-app-image}:latest",
    "name": "fileshare-app",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": 8080,
        "hostPort": 8080
      }
    ],
   "mountPoints": [
        {
            "containerPath": "/efs",
            "sourceVolume": "fileshare-app-fs"
        }
    ],
    "environment": [
      {
          "name": "GIN_MODE",
          "value": "release"
      },
      {
          "name": "AWS_REGION",
          "value": "${var.region}"
      },
      {
          "name": "S3_BUCKET",
          "value": "${aws_s3_bucket.s3_bucket.id}"
      },
      {
          "name": "USER_FILE_PATH",
          "value": "/efs/uploads"
      },
      {
          "name": "DB_HOST",
          "value": "${aws_db_instance.download_2020_mysql_instance.address}"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "${var.region}",
        "awslogs-group": "/ecs/${var.customer_name}/fileshare-app",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
DEFINITION

  volume {
    name = "fileshare-app-fs"

    efs_volume_configuration {
      file_system_id          = aws_efs_file_system.app_efs.id
      root_directory          = "/"
  }
}
}

resource "aws_ecs_service" "ecs_service" {
  name            = "fileshare-app-ecs-service"
  #use version 1.4.0 rather than 1.3.0, since the latter doesn't support EFS mount.
  platform_version = "1.4.0"
  cluster         = "${aws_ecs_cluster.ecs.id}"
  task_definition = "${aws_ecs_task_definition.ecs_task_app.arn}"
  desired_count   = 2
  launch_type     = "FARGATE"
  deployment_controller {
    type = "CODE_DEPLOY"
  }
  
  network_configuration {
    security_groups = ["${aws_security_group.ecs_sg.id}"]
    subnets         = ["${aws_subnet.subnet-priv-A.id}","${aws_subnet.subnet-priv-B.id}","${aws_subnet.subnet-priv-C.id}"]
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.ecs-tg.id}"
    container_name   = "fileshare-app"
    container_port   = "8080"
  }

  depends_on = [
    "aws_alb_listener.alb_listener_https",
  ]

    lifecycle {
    ignore_changes = [
      # Ignore changes to these settings, e.g. because CodeDeploy 
      # updates these. See code-deploy-ecs.tf
      load_balancer,
      task_definition
    ]
  }
}

resource "aws_appautoscaling_target" "ecs_autoscaling_target" {
    max_capacity = "4"
    min_capacity = "2"
    scalable_dimension = "ecs:service:DesiredCount"
    resource_id = "service/${aws_ecs_cluster.ecs.name}/${aws_ecs_service.ecs_service.name}"
    role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ecsAutoscaleRole"
    service_namespace = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_autoscaling_policy" {
    resource_id = "${aws_appautoscaling_target.ecs_autoscaling_target.resource_id}"
    policy_type = "TargetTrackingScaling"
    name = "CPUScaling"
    scalable_dimension = "${aws_appautoscaling_target.ecs_autoscaling_target.scalable_dimension}"
    service_namespace = "${aws_appautoscaling_target.ecs_autoscaling_target.service_namespace}"

    target_tracking_scaling_policy_configuration {
        target_value = 70
        scale_out_cooldown = 300
        scale_in_cooldown = 300
        predefined_metric_specification {
            predefined_metric_type = "ECSServiceAverageCPUUtilization"
        }
    }

}



# Traffic to the ECS Cluster should only come from the ALB
resource "aws_security_group" "ecs_sg" {
  name        = "${var.customer_name}-ecs-sg"
  description = "allow inbound access from the ALB only"
  vpc_id      = "${aws_vpc.vpc_download_2020.id}"

  ingress {
    protocol        = "tcp"
    from_port       = "80"
    to_port         = "80"
    security_groups = [aws_security_group.alb_sg.id,aws_security_group.bastion_host_sg.id]
  }

    ingress {
    protocol        = "tcp"
    from_port       = "8080"
    to_port         = "8080"
    security_groups = [aws_security_group.alb_sg.id,aws_security_group.bastion_host_sg.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
