resource "aws_codecommit_repository" "app_repo" {

  repository_name = "${var.project_name}-${var.environment}-repo"

  description = "Application source repository"

  tags = {

    Environment = var.environment

  }

}