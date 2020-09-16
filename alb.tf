### ALB

resource "aws_alb" "alb" {
  name            = "${var.customer_name}-alb"
  subnets         = ["${aws_subnet.subnet-pub-A.id}","${aws_subnet.subnet-pub-B.id}","${aws_subnet.subnet-pub-C.id}"]
  security_groups = ["${aws_security_group.alb_sg.id}"]
  tags            = var.tags
}

resource "aws_alb_target_group" "ecs-tg" {
  name        = "${var.customer_name}-ecs-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = "${aws_vpc.vpc_download_2020.id}"
  target_type = "ip"
  health_check {
    path = "/health"
  }
}

resource "aws_alb_target_group" "ecs-tg-b" {
  name        = "${var.customer_name}-ecs-tg-b"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = "${aws_vpc.vpc_download_2020.id}"
  target_type = "ip"
  health_check {
    path = "/health"
  }
}

#resource "aws_alb_listener_rule" "redirect_http_to_https" {
#  listener_arn = "${aws_alb_listener.alb_listener_http.arn}"

#  action {
#    type = "redirect"

#    redirect {
#      port        = "443"
#      protocol    = "HTTPS"
#      status_code = "HTTP_301"
#    }
#  }
#}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "alb_listener_http" {
  load_balancer_arn = "${aws_alb.alb.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

#Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "alb_listener_https" {
  load_balancer_arn = "${aws_alb.alb.id}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.dw2020ga_cert.arn

  default_action {
    target_group_arn = "${aws_alb_target_group.ecs-tg.id}"
    type             = "forward"
  }
  lifecycle {
    ignore_changes = [
      # Ignore changes to these settings, e.g. because CodeDeploy 
      # updates these. See code-deploy-ecs.tf
      default_action,
    ]
  }
}

resource "aws_lb_listener_rule" "health_check" {
  listener_arn = aws_alb_listener.alb_listener_https.arn

  action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "BALANCER IS HEALTHY"
      status_code  = "200"
    }
  }

  condition {
    path_pattern {
      values = ["/balancer"]
    }
  }

}

resource "aws_lb_listener_rule" "redirect_base_domain_to_www" {
  listener_arn = aws_alb_listener.alb_listener_https.arn

  action {
    type = "redirect"

    redirect {
      host = format("www.%s",var.domain_name)
      status_code = "HTTP_301"
    }
  }

  condition {
    host_header {
      values = [var.domain_name]
    }
  }
}

# ALB Security group
resource "aws_security_group" "alb_sg" {
  name        = "${var.customer_name}-alb-sg"
  description = "controls access to the ALB"
  vpc_id      = "${aws_vpc.vpc_download_2020.id}"

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = var.alb_public_access
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = var.alb_public_access
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}