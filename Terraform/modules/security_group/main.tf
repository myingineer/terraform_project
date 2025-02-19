# Setting up security groups


## Security group for ALB
resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "Security group for ALB. Allow HTTP and HTTPS traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ALB Security Group"
  }
}


## Security group for EC2
resource "aws_security_group" "ec2_sg" {
  name        = "ec2_sg"
  description = "Security group for EC2 instances"
  vpc_id      = var.vpc_id
  depends_on = [ aws_security_group.alb_sg ]

  # HTTP (80) from ALB's security group only
  ingress {
    from_port                = 80
    to_port                  = 80
    protocol                 = "tcp"
    security_groups = [aws_security_group.alb_sg.id]  # Allow HTTP from ALB only
  }

  # SSH (22) from ALB's security group only
  ingress {
    from_port                = 22
    to_port                  = 22
    protocol                 = "tcp"
    security_groups = [aws_security_group.alb_sg.id]  # Allow SSH from ALB only
  }

  # Optional: Egress rule allowing all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }

  tags = {
    Name = "EC2 Security Group"
  }
}

## Security group for RDS
resource "aws_security_group" "prod_db_sg" {
  name        = "prod_db_sg"
  description = "Security group for PostgreSQL RDS instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]  # Allow EC2 instances to access RDS
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [ aws_security_group.ec2_sg.id ]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "prod-db-sg"
  }
}
