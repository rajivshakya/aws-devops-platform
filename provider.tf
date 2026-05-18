provider "aws" {

  region = var.aws_region

  default_tags {

    tags = {

      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"

    }

  }

}

terraform {
  backend "s3" {
    bucket  = "rajiv-terraform-dev-state"
    key     = "dev/terraform.tfstate"
    region  = "ap-south-1"
    encrypt = true
  }
}