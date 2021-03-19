resource "aws_route53_zone" "internal" {
  name    = "${local.environment}.internal"
  comment = "Private Route53 Zone for ${local.environment}"

  vpc {
    vpc_id = data.aws_vpc.vpc.id
  }

  tags = local.default_tags
}

resource "aws_route53_record" "serve_postgres" {
  name    = "postgres"
  type    = "CNAME"
  zone_id = aws_route53_zone.internal.id
  records = [local.db.endpoint]
  ttl     = 300
}