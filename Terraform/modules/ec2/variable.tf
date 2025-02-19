variable "ec2_sg_id" {
  description = "value of ec2_sg_id for security group"
  type = string
}

variable "private_subnets_id" {
  description = "value of private_subnet_id for ec2 instance"
  type = list(string)
}

variable "target_group_arn" {
  description = "value of target_group_arn for alb"
  type = string
}