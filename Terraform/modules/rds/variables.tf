variable "private_subnets_id" {
  description = "value of private_subnet_id for ec2 instance"
  type = list(string)
}

variable "db_sg" {
  description = "value of security group for RDS instance"
  type = string
}

variable "db_password" {
  description = "The password for the database admin user"
  type        = string
  sensitive   = true  # Mark as sensitive to avoid logging
}