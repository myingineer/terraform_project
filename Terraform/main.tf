# The Module for the VPC
module "vpc" {
  source = "./modules/vpc"
  vpc_cidr = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

# The Module for the AWS WAF
module "aws_waf" {
  source = "./modules/waf"
}

# The Module for the Security Group
module "security_group" {
  source = "./modules/security_group"
  vpc_id = module.vpc.vpc_id
}

# The Module for the EC2
module "ec2" {
  source = "./modules/ec2"
  ec2_sg_id = module.security_group.ec2_sg_id
  private_subnets_id = module.vpc.private_subnet_ids
  target_group_arn = module.alb.target_group_arn
}

# The Module for the ALB
module "alb" {
  source = "./modules/alb"
  alb_sg_id = module.security_group.alb_sg_id
  public_subnets_id = module.vpc.public_subnet_ids
  aws_waf_arn = module.aws_waf.waf_arn
  vpc_id = module.vpc.vpc_id
}

# The Module for the RDS
module "rds" {
  source = "./modules/rds"
  private_subnets_id = module.vpc.private_subnet_ids
  db_sg = module.security_group.db_sg_id
  db_password = var.db_password
}