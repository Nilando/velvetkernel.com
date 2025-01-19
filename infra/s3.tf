resource "aws_s3_bucket" "vk-blog-bucket" {
  bucket = "vk-blog-bucket"

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_website_configuration" "vk-blog-bucket-web-config" {
  bucket = aws_s3_bucket.vk-blog-bucket.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_policy" "allow_access_from_cloudfront_oac" {
  bucket = aws_s3_bucket.vk-blog-bucket.id
  policy = data.aws_iam_policy_document.allow_access_from_cloudfront_oac.json
}

data "aws_iam_policy_document" "allow_access_from_cloudfront_oac" {
  statement {
    actions = [
      "s3:GetObject"
    ]
    
    resources = [
      "${aws_s3_bucket.vk-blog-bucket.arn}/*"
    ]
    
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [aws_cloudfront_distribution.vk-blog-distribution.arn]
    }

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
  }
}
