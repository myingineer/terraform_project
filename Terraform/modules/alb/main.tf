# Setting Up the Application Load Balancer

## ALB
resource "aws_lb" "prod_alb" {
  name               = "prod-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnets_id
  enable_deletion_protection = false

  tags = {
    Name = "prod_alb"
  }
}

## Associate the AWS WAF with the ALB
resource "aws_wafv2_web_acl_association" "prod_waf_association" {
  resource_arn = aws_lb.prod_alb.arn
  web_acl_arn  = var.aws_waf_arn
}

## ALB Target Group
resource "aws_lb_target_group" "prod_tg" {
  name     = "prod-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/"
    interval           = 30
    timeout            = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

## ALB Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.prod_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_tg.arn
  }
}
