# VPC

## Set up the VPC
resource "aws_vpc" "prod_vpc" {
  cidr_block = var.vpc_cidr
  instance_tenancy = "default" 

  tags = {
    Name = "prod_vpc"
  }
}

# SUBNETS

## Set up the public subnets
resource "aws_subnet" "public_subnet" {
  count = length(var.public_subnet_cidrs)
  vpc_id = aws_vpc.prod_vpc.id
  cidr_block = var.public_subnet_cidrs[count.index]
  map_public_ip_on_launch = true

  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = var.public_subnet_names[count.index]
  }
}

## Set up the private subnets
resource "aws_subnet" "private_subnet" {
  count = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.prod_vpc.id
  cidr_block = var.private_subnet_cidrs[count.index]

  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = var.private_subnet_names[count.index]
  }
}


# INTERNET GATEWAY

## Set up the internet gateway
resource "aws_internet_gateway" "prod_igw" {
  vpc_id = aws_vpc.prod_vpc.id

  tags = {
    Name = "MyInternetGateway"
  }
}

# NAT GATEWAY

### Create an Elastic IP address
resource "aws_eip" "prod_eip" {
  domain = "vpc"
}

## Set up the NAT gateway
resource "aws_nat_gateway" "prod_nat_gateway" {
  allocation_id = aws_eip.prod_eip.id
  subnet_id = aws_subnet.public_subnet[0].id

  tags = {
    Name = "MyNatGateway"
  }

  depends_on = [ aws_internet_gateway.prod_igw ]
}

# ROUTE TABLES

## Set up the route table for the public subnet
resource "aws_route_table" "prod_public_route_table" {
  vpc_id = aws_vpc.prod_vpc.id

  route {
    cidr_block = "0.0.0.0/0" # any internet request
    gateway_id = aws_internet_gateway.prod_igw.id
  }

  tags = {
    "Name" = "MyPublicRouteTable"
  }
}

## Set up the route table for the private subnet
resource "aws_route_table" "prod_private_route_table" {
  vpc_id = aws_vpc.prod_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.prod_nat_gateway.id
  }

  tags = {
    Name = "MyPrivateRouteTable"
  }
}

# ROUTE TABLE ASSOCIATIONS

## Associate the public route table with the public subnet
resource "aws_route_table_association" "prod_public_subnet_association" {
  count = length(var.public_subnet_cidrs)
  subnet_id = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.prod_public_route_table.id
}

## Associate the private route table with the private subnet
resource "aws_route_table_association" "prod_private_subnet_association" {
  count = length(var.private_subnet_cidrs)
  subnet_id = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.prod_private_route_table.id
}