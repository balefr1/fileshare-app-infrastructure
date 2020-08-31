resource "aws_route53_zone" "dw2020ga_zone" {
  name = var.domain_name
  tags=var.tags
}
//create base domain
resource "aws_route53_record" "dw2020ga_alb" {
  zone_id = aws_route53_zone.dw2020ga_zone.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_alb.alb.dns_name
    zone_id                = aws_alb.alb.zone_id
    evaluate_target_health = true
  }
}
// create www domain
resource "aws_route53_record" "dw2020ga_alb_www" {
  zone_id = aws_route53_zone.dw2020ga_zone.zone_id
  name    = format("www.%s",var.domain_name)
  type    = "A"

  alias {
    name                   = aws_alb.alb.dns_name
    zone_id                = aws_alb.alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "bastion" {
  zone_id = aws_route53_zone.dw2020ga_zone.zone_id
  name    = format("deploy.%s",var.domain_name)
  type    = "A"
  ttl     = "300"
  records = [aws_eip.bastion_eip.public_ip]
}