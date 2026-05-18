#################################################
# S3 BUCKET FOR PIPELINE ARTIFACTS
#################################################

resource "aws_s3_bucket" "pipeline_artifacts" {

  bucket = "${var.project_name}-${var.environment}-pipeline-artifacts"
  force_destroy = true
}

#################################################
# IAM ROLE FOR CODEPIPELINE
#################################################

resource "aws_iam_role" "codepipeline_role" {

  name = "${var.project_name}-${var.environment}-codepipeline-role"

  assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {

        Effect = "Allow"

        Principal = {

          Service = "codepipeline.amazonaws.com"

        }

        Action = "sts:AssumeRole"

      }

    ]

  })

}

resource "aws_iam_role_policy" "codepipeline_policy" {

  name = "${var.project_name}-${var.environment}-codepipeline-policy"

  role = aws_iam_role.codepipeline_role.id

  policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {

        Effect = "Allow"

        Action = [

          "s3:*",
          "codebuild:*",
          "codedeploy:*",
          "codecommit:*"

        ]

        Resource = "*"

      }

    ]

  })

}

#################################################
# CODEPIPELINE
#################################################

resource "aws_codepipeline" "pipeline" {

  name = "${var.project_name}-${var.environment}-pipeline"

  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {

    location = aws_s3_bucket.pipeline_artifacts.bucket

    type = "S3"

  }

  #################################################
  # SOURCE STAGE
  #################################################

  stage {

    name = "Source"

    action {

      name = "Source"

      category = "Source"

      owner = "AWS"

      provider = "CodeCommit"

      version = "1"

      output_artifacts = ["source_output"]

      configuration = {

        RepositoryName = var.repository_name

        BranchName     = "main"

      }

    }

  }

  #################################################
  # BUILD STAGE
  #################################################

  stage {

    name = "Build"

    action {

      name = "Build"

      category = "Build"

      owner = "AWS"

      provider = "CodeBuild"

      version = "1"

      input_artifacts = ["source_output"]

      output_artifacts = ["build_output"]

      configuration = {

        ProjectName = var.codebuild_project_name

      }

    }

  }

  #################################################
  # DEPLOY STAGE
  #################################################

  stage {

    name = "Deploy"

    action {

      name = "Deploy"

      category = "Deploy"

      owner = "AWS"

      provider = "CodeDeploy"

      version = "1"

      input_artifacts = ["build_output"]

      configuration = {

        ApplicationName     = var.codedeploy_app_name

        DeploymentGroupName = var.deployment_group_name

      }

    }

  }

}