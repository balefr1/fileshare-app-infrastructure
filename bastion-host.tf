resource "aws_security_group" "bastion_host_sg" {
  name        = "${var.customer_name}-bastion_host-sg"
  description = "controls access to the bastion host"
  vpc_id      = "${aws_vpc.vpc_download_2020.id}"

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow external access to bastion"
  }

  ingress {
    protocol    = "tcp"
    from_port   = 8080
    to_port     = 8080
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow external access to bastion"
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eip_association" "bastion_eip_assoc" {
  instance_id   = aws_instance.bastion_host_instance.id
  allocation_id = aws_eip.bastion_eip.id
}

# Bastion host should be in autoscaling across at least two AZ for HA
resource "aws_instance" "bastion_host_instance" {
    ami = "${var.bastion_host_ami}"
    instance_type = "t3.small"
    subnet_id = "${aws_subnet.subnet-pub-A.id}"
    #key_name = "management-ec2-instance"
    key_name = aws_key_pair.bastion_key_pair.key_name
    iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.id
    vpc_security_group_ids = ["${aws_security_group.bastion_host_sg.id}"]
    associate_public_ip_address = true

    tags = merge(
      var.tags,
      {
      Name = "download-2020"
      }
    )
}

resource "aws_key_pair" "bastion_key_pair" {
  key_name   = format("%s-bastion",var.customer_name)
  public_key = var.keypair_publickey
}