resource "aws_iam_role" "ecs_task_execution_role" {
  name               = format("%s-ECS-TASK-EXECUTION", var.customer_name)
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

}

resource "aws_iam_role_policy_attachment" "ecs_policy_task_execution" {
  role = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_policy_fileshare" {
  role = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.fileshare-app-s3-access.arn
}

resource "aws_iam_policy" "fileshare-app-s3-access" {
name        = "Fileshare-app-access-policy"
description = "Allows read-only access to deploy S3 bucket"
policy      = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.s3_bucket.id}",
                "arn:aws:s3:::${aws_s3_bucket.s3_bucket.id}/*"
            ]
        }
	]
}
POLICY

}


//role for CodeDeploy

resource "aws_iam_role" "codedeploy_ecs_role" {
  name               = format("%s-CODEDEPLOY-ECS", var.customer_name)
    assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "codedeploy.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "codedeploy_ecs_policy" {
  role = aws_iam_role.codedeploy_ecs_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}

//role for Jenkins (bastion)
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = format("%s-EC2-DEPLOY-ROLE", var.customer_name)
  role = aws_iam_role.deploy_ec2_role.id
}

resource "aws_iam_role" "deploy_ec2_role" {
  name               = format("%s-EC2-Deploy", var.customer_name)
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

}

resource "aws_iam_role_policy_attachment" "deploy_ec2_ecraccess_policy" {
  role = aws_iam_role.deploy_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}