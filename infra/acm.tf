resource "aws_acm_certificate" "vk-blog-certificate" {
  domain_name       = "blog.velvetkernel.com"
  validation_method = "DNS"
}

resource "aws_route53_record" "vk-blog-certificate-record" {
  for_each = {
    for dvo in aws_acm_certificate.vk-blog-certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.vk-hosted-zone.zone_id
}

resource "aws_acm_certificate_validation" "vk-blog-certificate-validation" {
  certificate_arn         = aws_acm_certificate.vk-blog-certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.vk-blog-certificate-record : record.fqdn]
}
