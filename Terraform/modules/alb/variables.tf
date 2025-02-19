variable "alb_sg_id" {
  description = "value of alb_sg_id for security group"
  type = string
}

variable "public_subnets_id" {
  description = "value of public_subnet_id for ec2 instance"
  type = list(string)
}

variable "aws_waf_arn" {
  description = "value of aws_waf_arn for web acl"
  type = string
}

variable "vpc_id" {
  description = "value of vpc_id for alb"
  type = string
}