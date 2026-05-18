###########################################
##  Security Group for ALB                #
###########################################

resource "aws_security_group" "alb_sg" {

  name = "${var.project_name}-${var.environment}-alb-sg"

  description = "Security Group for ALB"

  vpc_id = var.vpc_id

  ingress {

    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {

    from_port   = 0
    to_port     = 0
    protocol    = "-1"

    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {

    Name = "${var.project_name}-${var.environment}-alb-sg"

  }

}
###########################################
##  Security Group for Allication Nodes  #
###########################################
resource "aws_security_group" "app_sg" {

  name = "${var.project_name}-${var.environment}-app-sg"

  description = "Security Group for Application Servers"

  vpc_id = var.vpc_id

  ingress {

    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    security_groups = [
      aws_security_group.alb_sg.id
    ]

  }

  egress {

    from_port   = 0
    to_port     = 0
    protocol    = "-1"

    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {

    Name = "${var.project_name}-${var.environment}-app-sg"

  }

}