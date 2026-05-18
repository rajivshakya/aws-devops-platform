#################################################
# S3 BUCKET FOR AWS CONFIG
#################################################

resource "aws_s3_bucket" "config_bucket" {

  bucket = "${var.project_name}-${var.environment}-config-logs"
  force_destroy = true
}

#################################################
# IAM ROLE FOR AWS CONFIG
#################################################

resource "aws_iam_role" "config_role" {

  name = "${var.project_name}-${var.environment}-config-role"

  assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {

        Effect = "Allow"

        Principal = {

          Service = "config.amazonaws.com"

        }

        Action = "sts:AssumeRole"

      }

    ]

  })

}

#################################################
# ATTACH AWS MANAGED POLICY
#################################################

resource "aws_iam_role_policy_attachment" "config_policy" {

  role = aws_iam_role.config_role.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"

}

#################################################
# CONFIGURATION RECORDER
#################################################

resource "aws_config_configuration_recorder" "main" {

  name = "${var.project_name}-${var.environment}-config-recorder"

  role_arn = aws_iam_role.config_role.arn

  recording_group {

    all_supported = true

    include_global_resource_types = true

  }

}

#################################################
# DELIVERY CHANNEL
#################################################

resource "aws_config_delivery_channel" "main" {

  name = "${var.project_name}-${var.environment}-config-delivery"

  s3_bucket_name = aws_s3_bucket.config_bucket.bucket

  depends_on = [

    aws_config_configuration_recorder.main

  ]

}

#################################################
# ENABLE CONFIG RECORDER
#################################################

resource "aws_config_configuration_recorder_status" "main" {

  name = aws_config_configuration_recorder.main.name

  is_enabled = true

  depends_on = [

    aws_config_delivery_channel.main

  ]

}

#################################################
# CONFIG RULE - NO PUBLIC SSH
#################################################

resource "aws_config_config_rule" "no_public_ssh" {

  name = "restricted-ssh"

  source {

    owner = "AWS"

    source_identifier = "INCOMING_SSH_DISABLED"

  }

  depends_on = [

    aws_config_configuration_recorder_status.main

  ]

}

#################################################
# S3 BUCKET POLICY FOR AWS CONFIG
#################################################

resource "aws_s3_bucket_policy" "config_bucket_policy" {

  bucket = aws_s3_bucket.config_bucket.id

  policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {

        Sid = "AWSConfigBucketPermissionsCheck"

        Effect = "Allow"

        Principal = {

          Service = "config.amazonaws.com"

        }

        Action = "s3:GetBucketAcl"

        Resource = aws_s3_bucket.config_bucket.arn

      },

      {

        Sid = "AWSConfigBucketDelivery"

        Effect = "Allow"

        Principal = {

          Service = "config.amazonaws.com"

        }

        Action = "s3:PutObject"

        Resource = "${aws_s3_bucket.config_bucket.arn}/*"

        Condition = {

          StringEquals = {

            "s3:x-amz-acl" = "bucket-owner-full-control"

          }

        }

      }

    ]

  })

}