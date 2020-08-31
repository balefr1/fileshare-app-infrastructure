resource "aws_efs_file_system" "app_efs" {

  tags = var.tags
}

locals {
   private_subnets = [aws_subnet.subnet-priv-A.id,aws_subnet.subnet-priv-B.id,aws_subnet.subnet-priv-C.id]
}

resource "aws_efs_mount_target" "drupal_mnt" {
  count = length(local.private_subnets)

  file_system_id  = aws_efs_file_system.app_efs.id
  subnet_id       = element(local.private_subnets, count.index)
  security_groups = [aws_security_group.efs_mount_drupal.id]
}

resource "aws_security_group" "efs_mount_drupal" {
  name        = format("%s-efs-sg",var.customer_name)
  description = "Allow EFS mounting from Drupal instances"

  vpc_id = aws_vpc.vpc_download_2020.id

  ingress {
    from_port = 2049
    to_port   = 2049
    protocol  = "tcp"
    security_groups = [aws_security_group.ecs_sg.id,aws_security_group.bastion_host_sg.id]
    self            = false
  }

  tags = var.tags
}