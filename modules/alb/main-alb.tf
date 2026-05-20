resource "aws_lb_target_group" "app_tg" {

  name = "${var.project_name}-${var.environment}-tg"

  port = 80

  protocol = "HTTP"

  vpc_id = var.vpc_id

  target_type = "instance"

  health_check {

    enabled = true

    path = "/"

    protocol = "HTTP"

    matcher = "200"

    interval = 30

    timeout = 5

    healthy_threshold = 2

    unhealthy_threshold = 2

  }

  tags = {

    Name = "${var.project_name}-${var.environment}-tg"

  }

}
#tfsec:ignore:aws-elb-alb-not-public
# Reason: Internet-facing ALB required for public application access
resource "aws_lb" "app_alb" {

  name = "${var.project_name}-${var.environment}-alb"

  internal = false

  load_balancer_type = "application"

  security_groups = [
    var.alb_sg_id
  ]

  subnets = var.public_subnet_ids

  enable_deletion_protection = false
  drop_invalid_header_fields = true
  tags = {

    Name = "${var.project_name}-${var.environment}-alb"

  }

}
#tfsec:ignore:aws-elb-http-not-used
resource "aws_lb_listener" "http_listener" {

  load_balancer_arn = aws_lb.app_alb.arn

  port = 80

  protocol = "HTTP"

  default_action {

    type = "forward"

    target_group_arn = aws_lb_target_group.app_tg.arn

  }

}
