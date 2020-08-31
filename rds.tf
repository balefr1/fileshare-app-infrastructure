resource "aws_db_instance" "download_2020_mysql_instance" {
  allocated_storage    = 20
  identifier = "download2020-mysql"
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.6"
  instance_class       = "db.t3.micro"
  name                 = var.db_name
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.mysql5.6"
  db_subnet_group_name = aws_db_subnet_group.subnet_group_rds.name
  vpc_security_group_ids = [aws_security_group.download_2020_rds_sg.id]
  tags=var.tags
}

resource "aws_db_subnet_group" "subnet_group_rds" {
  name        = "${var.customer_name}-subnet-group-rds"
  description = "${var.customer_name}-subnet-group-rds"
  subnet_ids  = ["${aws_subnet.subnet-priv-A.id}","${aws_subnet.subnet-priv-B.id}","${aws_subnet.subnet-priv-C.id}"]

  tags = var.tags
}

resource "aws_security_group" "download_2020_rds_sg" {
  vpc_id      = "${aws_vpc.vpc_download_2020.id}"
  name        = "${format("%s-rds-sg", var.customer_name)}"
  description = "${format("Security Group for %s RDS", var.customer_name)}"

  # ingress {
  #   protocol    = "tcp"
  #   from_port   = 3306
  #   to_port     = 3306
  #   cidr_blocks = ["${aws_subnet.subnet-priv-A.cidr_block}","${aws_subnet.subnet-priv-B.cidr_block}","${aws_subnet.subnet-priv-C.cidr_block}"]
  # }

  ingress {
    protocol    = "tcp"
    from_port   = 3306
    to_port     = 3306
    security_groups = ["${aws_security_group.ecs_sg.id}"]
  }
  
  ingress {
    protocol    = "tcp"
    from_port   = 3306
    to_port     = 3306
    security_groups = ["${aws_security_group.bastion_host_sg.id}"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = var.tags
}




