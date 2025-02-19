# This file contains the output variables for the ALB module.

output "target_group_arn" {
  value = aws_lb_target_group.prod_tg.arn
}