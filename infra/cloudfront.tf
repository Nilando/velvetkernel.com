locals {
  s3_origin_id = "vk-blog-bucket-origin"
}

resource "aws_cloudfront_origin_access_control" "vk-blog-origin-acl" {
  name                              = "vk-blog-origin-acl"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "vk-blog-distribution" {
  origin {
    domain_name              = aws_s3_bucket.vk-blog-bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.vk-blog-origin-acl.id
    origin_id                = local.s3_origin_id
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  aliases = ["blog.velvetkernel.com"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.index_redirect.arn
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }

  tags = {
    Environment = "production"
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.vk-blog-certificate.arn
    ssl_support_method  = "sni-only"
  }
}

resource "aws_cloudfront_function" "index_redirect" {
  name    = "index_redirect"
  runtime = "cloudfront-js-2.0"
  publish = true
  code    = file("${path.module}/index_redirect.js")
}
