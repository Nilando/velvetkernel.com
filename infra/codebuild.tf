/*
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "assume_role" {
  name = "assume_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "sync_s3" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:DeleteObject"
    ]

    resources = [
      aws_s3_bucket.vk-blog-bucket.arn,
      "${aws_s3_bucket.vk-blog-bucket.arn}/*"
    ]
  }
}

resource "aws_iam_role_policy" "sync_s3" {
  role   = aws_iam_role.assume_role.name
  policy = data.aws_iam_policy_document.sync_s3.json
}

resource "aws_codebuild_project" "sync_s3" {
  name          = "s3_sync"
  description   = "sync public folder to s3 bucket"
  build_timeout = 5
  service_role  = aws_iam_role.assume_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "velvetkernel"
      stream_name = "codebuild_s3_sync"
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/Nilando/velvetkernel.com"
  }

  source_version = "main"
}
*/

data "template_file" "buildspec" {
  template = <<EOF
version: 0.2

phases:
  build:
    commands:
      - echo "Syncing /public folder to S3 bucket..."
      - aws s3 sync public s3://${aws_s3_bucket.vk-blog-bucket.bucket} --delete
EOF
}

resource "local_file" "buildspec" {
  filename = "${path.module}/../buildspec.yml"
  content  = data.template_file.buildspec.rendered
}

/*
# GITHUB MUST BE AUTHORIZED MANUALLY FOR WEBHOOK TO WORK
resource "aws_codebuild_webhook" "main_push_hook" {
  project_name = aws_codebuild_project.sync_s3.name
  build_type   = "BUILD"

  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH"
    }
  }
}
*/
