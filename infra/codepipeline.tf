resource "aws_codepipeline" "codepipeline" {
  name     = "s3_sync_pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn
  pipeline_type = "V2"

  artifact_store {
    location = aws_s3_bucket.velvetkernel_codepipeline_bucket.bucket
    type     = "S3"
  }

  trigger {
      provider_type     = "CodeStarSourceConnection"
      git_configuration {
        source_action_name = "Source"
        push {
          branches {
            includes = ["main"]
          }
        }
      }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.nilando_github.arn
        FullRepositoryId = "Nilando/velvetkernel.com"
        BranchName       = "main"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.sync_s3.name
      }
    }
  }
}

resource "aws_s3_bucket" "velvetkernel_codepipeline_bucket" {
  bucket = "velvetkernel-codepipeline-bucket"
}

resource "aws_codestarconnections_connection" "nilando_github" {
  name          = "nilando_github"
  provider_type = "GitHub"
}


resource "aws_s3_bucket_public_access_block" "velvetkernel_codepipeline_bucket_pab" {
  bucket = aws_s3_bucket.velvetkernel_codepipeline_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "codepipeline_role" {
  name               = "test-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "codepipeline_policy" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObjectAcl",
      "s3:PutObject",
    ]

    resources = [
      aws_s3_bucket.velvetkernel_codepipeline_bucket.arn,
      "${aws_s3_bucket.velvetkernel_codepipeline_bucket.arn}/*"
    ]
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

  statement {
    effect    = "Allow"
    actions   = ["codestar-connections:UseConnection"]
    resources = [aws_codestarconnections_connection.nilando_github.arn]
  }

  statement {
    effect = "Allow"

    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name   = "codepipeline_policy"
  role   = aws_iam_role.codepipeline_role.id
  policy = data.aws_iam_policy_document.codepipeline_policy.json
}
