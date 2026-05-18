#################################################
# S3 BUCKET FOR CLOUDTRAIL LOGS
#################################################

resource "aws_s3_bucket" "cloudtrail_logs" {

  bucket = "${var.project_name}-${var.environment}-cloudtrail-logs"
  force_destroy = true

}
data "aws_caller_identity" "current" {}
#################################################
# S3 BUCKET POLICY FOR CLOUDTRAIL
#################################################

resource "aws_s3_bucket_policy" "cloudtrail_policy" {

  bucket = aws_s3_bucket.cloudtrail_logs.id

  policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {

        Sid = "AWSCloudTrailAclCheck"

        Effect = "Allow"

        Principal = {

          Service = "cloudtrail.amazonaws.com"

        }

        Action = "s3:GetBucketAcl"

        Resource = aws_s3_bucket.cloudtrail_logs.arn

      },

      {

        Sid = "AWSCloudTrailWrite"

        Effect = "Allow"

        Principal = {

          Service = "cloudtrail.amazonaws.com"

        }

        Action = "s3:PutObject"

      Resource = "${aws_s3_bucket.cloudtrail_logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"

        Condition = {

          StringEquals = {

            "s3:x-amz-acl" = "bucket-owner-full-control"

          }

        }

      }

    ]

  })

}

#################################################
# CLOUDTRAIL
#################################################

resource "aws_cloudtrail" "main" {

  name = "${var.project_name}-${var.environment}-trail"

  s3_bucket_name = aws_s3_bucket.cloudtrail_logs.id

  include_global_service_events = true

  is_multi_region_trail = true

  enable_logging = true
  depends_on = [
  aws_s3_bucket_policy.cloudtrail_policy
]

}