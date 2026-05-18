module "vpc" {

  source = "./modules/vpc"

  project_name = var.project_name
  environment  = var.environment

  vpc_cidr = var.vpc_cidr

  public_subnet_1_cidr = var.public_subnet_1_cidr
  public_subnet_2_cidr = var.public_subnet_2_cidr

  private_subnet_1_cidr = var.private_subnet_1_cidr
  private_subnet_2_cidr = var.private_subnet_2_cidr

}

module "security_groups" {

  source = "./modules/security_groups"

  project_name = var.project_name

  environment = var.environment

  vpc_id = module.vpc.vpc_id

}

module "iam" {

  source = "./modules/iam"

  project_name = var.project_name

  environment = var.environment

}

module "alb" {

  source = "./modules/alb"

  project_name = var.project_name

  environment = var.environment

  vpc_id = module.vpc.vpc_id

  public_subnet_ids = [
    module.vpc.public_subnet_1_id,
    module.vpc.public_subnet_2_id
  ]

  alb_sg_id = module.security_groups.alb_sg_id

}

module "ec2" {

  source = "./modules/ec2"

  project_name = var.project_name

  environment = var.environment

  private_subnet_ids = [
    module.vpc.private_subnet_1_id,
    module.vpc.private_subnet_2_id
  ]

  app_sg_id = module.security_groups.app_sg_id

  instance_profile_name = module.iam.instance_profile_name

  target_group_arn = module.alb.target_group_arn

}

module "codecommit" {

  source = "./modules/codecommit"

  project_name = var.project_name

  environment = var.environment

}
module "codebuild" {

  source = "./modules/codebuild"

  project_name = var.project_name

  environment = var.environment

  repository_name = module.codecommit.repository_name

}

module "codedeploy" {

  source = "./modules/codedeploy"

  project_name = var.project_name

  environment = var.environment

}

module "codepipeline" {

  source = "./modules/codepipeline"

  project_name = var.project_name

  environment = var.environment

  repository_name = module.codecommit.repository_name

  codebuild_project_name = module.codebuild.codebuild_project_name

  codedeploy_app_name = module.codedeploy.codedeploy_app_name

  deployment_group_name = module.codedeploy.deployment_group_name

}

module "cloudtrail" {

  source = "./modules/cloudtrail"

  project_name = var.project_name

  environment = var.environment

}

module "aws_config" {

  source = "./modules/aws_config"

  project_name = var.project_name

  environment = var.environment

}