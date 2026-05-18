#################################################
# IAM ROLE FOR CODEBUILD
#################################################

resource "aws_iam_role" "codebuild_role" {

  name = "${var.project_name}-${var.environment}-codebuild-role"

  assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {

        Effect = "Allow"

        Principal = {

          Service = "codebuild.amazonaws.com"

        }

        Action = "sts:AssumeRole"

      }

    ]

  })

}

#################################################
# IAM POLICY ATTACHMENT
#################################################

resource "aws_iam_role_policy_attachment" "codebuild_policy" {

  role = aws_iam_role.codebuild_role.name

  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildDeveloperAccess"

}

#################################################
# S3 BUCKET FOR BUILD ARTIFACTS
#################################################



#################################################
# CODEBUILD PROJECT
#################################################

resource "aws_codebuild_project" "app_build" {

  name = "${var.project_name}-${var.environment}-build"

  service_role = aws_iam_role.codebuild_role.arn

  artifacts {

      type = "CODEPIPELINE"

  }

  environment {

    compute_type = "BUILD_GENERAL1_SMALL"

    image = "aws/codebuild/standard:7.0"

    type = "LINUX_CONTAINER"

  }

  source {

  type = "CODEPIPELINE"

  buildspec = "buildspec.yml"

}

  tags = {

    Environment = var.environment

  }

}