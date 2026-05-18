variable "project_name" {

  type = string

}

variable "environment" {

  type = string

}

variable "private_subnet_ids" {

  type = list(string)

}

variable "app_sg_id" {

  type = string

}

variable "instance_profile_name" {

  type = string

}

variable "target_group_arn" {

  type = string

}
