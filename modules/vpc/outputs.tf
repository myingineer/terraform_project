# Description: This file contains the output variables for the VPC module.

## VPC ID
output "vpc_id" {
  value = aws_vpc.prod_vpc.id
}

## Public Subnet IDs
output "public_subnet_ids" {
  value = aws_subnet.public_subnet.*.id
}

## Private Subnet IDs
output "private_subnet_ids" {
  value = aws_subnet.private_subnet.*.id
}