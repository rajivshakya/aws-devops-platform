data "aws_ami" "ubuntu" {

  most_recent = true

  owners = ["099720109477"]

  filter {

    name = "name"

    values = [
      "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
    ]

  }

  filter {

    name = "virtualization-type"

    values = ["hvm"]

  }

}
resource "aws_launch_template" "app_lt" {

  name_prefix = "${var.project_name}-${var.environment}-lt"

  image_id = data.aws_ami.ubuntu.id

  instance_type = "t2.micro"

  vpc_security_group_ids = [
    var.app_sg_id
  ]

  iam_instance_profile {

    name = var.instance_profile_name

  }
  metadata_options {

  http_endpoint = "enabled"

  http_tokens = "required"

}

  user_data = base64encode(<<-EOF
              #!/bin/bash

              apt update -y

              apt install -y apache2 ruby-full wget

              systemctl enable apache2

              systemctl start apache2

              echo "<h1>Welcome to AWS DevOps Platform</h1>" > /var/www/html/index.html

              #################################################
              # INSTALL CODEDEPLOY AGENT
              #################################################

              cd /tmp

              wget https://aws-codedeploy-ap-south-1.s3.ap-south-1.amazonaws.com/latest/install

              chmod +x ./install

              ./install auto

              systemctl enable codedeploy-agent

              systemctl start codedeploy-agent

              EOF
  )

  tag_specifications {

    resource_type = "instance"

    tags = {

      Name = "${var.project_name}-${var.environment}-app-server"

      Environment = var.environment

      Role = "application-server"

    }

  }

}


resource "aws_autoscaling_group" "app_asg" {

  name = "${var.project_name}-${var.environment}-asg"

  desired_capacity = 2

  min_size = 2

  max_size = 4

  vpc_zone_identifier = var.private_subnet_ids

  target_group_arns = [
    var.target_group_arn
  ]

  health_check_type = "ELB"

  launch_template {

    id = aws_launch_template.app_lt.id

    version = "$Latest"

  }

  tag {

    key = "Name"

    value = "${var.project_name}-${var.environment}-asg-instance"

    propagate_at_launch = true

  }
tag {

  key = "Environment"

  value = var.environment

  propagate_at_launch = true

}

tag {

  key = "Role"

  value = "application-server"

  propagate_at_launch = true

}
}