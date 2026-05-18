#################################################
# IAM ROLE FOR CODEDEPLOY
#################################################

resource "aws_iam_role" "codedeploy_role" {

  name = "${var.project_name}-${var.environment}-codedeploy-role"

  assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {

        Effect = "Allow"

        Principal = {

          Service = "codedeploy.amazonaws.com"

        }

        Action = "sts:AssumeRole"

      }

    ]

  })

}

#################################################
# ATTACH POLICY
#################################################

resource "aws_iam_role_policy_attachment" "codedeploy_policy" {

  role = aws_iam_role.codedeploy_role.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"

}

#################################################
# CODEDEPLOY APPLICATION
#################################################

resource "aws_codedeploy_app" "app" {

  name = "${var.project_name}-${var.environment}-app"

  compute_platform = "Server"

}

#################################################
# DEPLOYMENT GROUP
#################################################

resource "aws_codedeploy_deployment_group" "deployment_group" {

  app_name = aws_codedeploy_app.app.name

  deployment_group_name = "${var.project_name}-${var.environment}-dg"

  service_role_arn = aws_iam_role.codedeploy_role.arn

  deployment_config_name = "CodeDeployDefault.AllAtOnce"

  ec2_tag_set {

    ec2_tag_filter {

      key = "Role"

      type = "KEY_AND_VALUE"

      value = "application-server"

    }

  }

}