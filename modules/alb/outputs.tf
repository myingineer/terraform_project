# This file contains the output variables for the ALB module.

output "target_group_arn" {
  value = aws_lb_target_group.prod_tg.arn
}

output "alb_dns_name" {
  value = aws_lb.prod_alb.dns_name
}
