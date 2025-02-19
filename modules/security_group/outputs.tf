# This file contains the output variables for the security group module.

output "alb_sg_id" {
  value =  aws_security_group.alb_sg.id
}

output "ec2_sg_id" {
  value =  aws_security_group.ec2_sg.id
}