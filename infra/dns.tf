data "aws_route53_zone" "vk-hosted-zone" {
  name         = "velvetkernel.com"
  private_zone = false
}

resource "aws_route53_record" "cloudfront_alias" {
  zone_id = data.aws_route53_zone.vk-hosted-zone.id
  name    = "blog.velvetkernel.com"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.vk-blog-distribution.domain_name
    zone_id                = aws_cloudfront_distribution.vk-blog-distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
