variable "vpc_cidr" {
    description = "The CIDR block for the VPC"
    type = string
}

variable "public_subnet_cidrs" {
    description = "The CIDR blocks for the public subnets"
    type = list(string)
}

variable "private_subnet_cidrs" {
    description = "The CIDR blocks for the private subnets"
    type = list(string)
}

variable "public_subnet_names" {
    description = "The names for the subnets"
    type = list(string)
    default = [ "Public_Subnet_1", "Public_Subnet_2" ]
}

variable "private_subnet_names" {
    description = "The names for the subnets"
    type = list(string)
    default = [ "Private_Subnet_1", "Private_Subnet_2" ]
}