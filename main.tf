module "vpc" {
  source = "./modules/vpc"
  vpc_cidr = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

# Set up the first public subnet
resource "aws_subnet" "prod_public_subnet_1" {
  vpc_id = aws_vpc.prod_vpc.id
  cidr_block = "10.0.1.0/24"

  availability_zone = "us-east-1a"

  tags = {
    Name = "prod_public_subnet_1"
  }
}

# Set up the second public subnet
resource "aws_subnet" "prod_public_subnet_2" {
  vpc_id            = aws_vpc.prod_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "prod_public_subnet_2"
  }
}

# Set up the first private subnet
resource "aws_subnet" "prod_private_subnet_1" {
  vpc_id = aws_vpc.prod_vpc.id
  cidr_block = "10.0.3.0/24"

  availability_zone = "us-east-1a"

  tags = {
    Name = "prod_private_subnet_1"
  }
}

# Set up the second private subnet
resource "aws_subnet" "prod_private_subnet_2" {
  vpc_id            = aws_vpc.prod_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "prod_private_subnet_2"
  }
}


# Set up the internet gateway
resource "aws_internet_gateway" "prod_igw" {
  vpc_id = aws_vpc.prod_vpc.id

  tags = {
    Name = "prod_igw"
  }
}

# Set up the route table for the public subnet
resource "aws_route_table" "prod_public_route_table" {
  vpc_id = aws_vpc.prod_vpc.id

  route {
    cidr_block = "0.0.0.0/0" # any internet request
    gateway_id = aws_internet_gateway.prod_igw.id
  }

  tags = {
    Name = "prod_public_route_table"
  }
}

# Set up the route table for the private subnet
resource "aws_route_table" "prod_private_route_table" {
  vpc_id = aws_vpc.prod_vpc.id

  tags = {
    Name = "prod_private_route_table"
  }
}

# Associate the first public subnet with the public route table
resource "aws_route_table_association" "prod_public_subnet_association" {
  subnet_id = aws_subnet.prod_public_subnet_1.id
  route_table_id = aws_route_table.prod_public_route_table.id
}

# Associate the second public subnet with the public route table
resource "aws_route_table_association" "prod_public_subnet_2_association" {
  subnet_id      = aws_subnet.prod_public_subnet_2.id
  route_table_id = aws_route_table.prod_public_route_table.id
}

# Associate the first private subnet with the private route table
resource "aws_route_table_association" "prod_private_subnet_association" {
  subnet_id = aws_subnet.prod_private_subnet_1.id
  route_table_id = aws_route_table.prod_private_route_table.id
}

# Associate the second private subnet with the private route table
resource "aws_route_table_association" "prod_private_subnet_2_association" {
  subnet_id      = aws_subnet.prod_private_subnet_2.id
  route_table_id = aws_route_table.prod_private_route_table.id
}


# Create a WAF WebACL
resource "aws_wafv2_web_acl" "prod_waf" {
  name        = "prod_waf"
  description = "WAF for the production environment"
  scope       = "CLOUDFRONT" # Use "REGIONAL" for regional resources

  default_action {
    block {}
  }

  rule {
    name = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
        none {}
    }

    statement {
        managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
        }
    }

    visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "AWSManagedRulesCommonRuleSet"
        sampled_requests_enabled   = true
    }
  }


  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "prod_waf"
    sampled_requests_enabled   = true
  }
}

# Set up the ALB
resource "aws_lb" "prod_alb" {
  name               = "prod-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.prod_alb_sg.id]
  subnets            = [aws_subnet.prod_public_subnet_1.id, aws_subnet.prod_public_subnet_2.id]

  enable_deletion_protection = true

  tags = {
    Name = "prod_alb"
  }
}

# Associate the WAF with the ALB
resource "aws_wafv2_web_acl_association" "prod_waf_association" {
  resource_arn = aws_lb.prod_alb.arn
  web_acl_arn  = aws_wafv2_web_acl.prod_waf.arn
}

# Security group for ALB
resource "aws_security_group" "prod_alb_sg" {
  name        = "prod_alb_sg"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.prod_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "prod_alb_sg"
  }
}

resource "aws_security_group" "ec2_sg_http" {
  name        = "ec2_sg_http"
  description = "Security group for EC2 instances"
  vpc_id      = aws_vpc.prod_vpc.id
  depends_on = [ aws_security_group.prod_alb_sg ]

  # HTTP (80) from ALB's security group only
  ingress {
    from_port                = 80
    to_port                  = 80
    protocol                 = "tcp"
    security_groups = [aws_security_group.prod_alb_sg.id]  # Allow HTTP from ALB only
  }

  # HTTPS (443) from ALB's security group only
  ingress {
    from_port                = 443
    to_port                  = 443
    protocol                 = "tcp"
    security_groups = [aws_security_group.prod_alb_sg.id]  # Allow HTTPS from ALB only
  }

  # Optional: Egress rule allowing all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }

  tags = {
    Name = "ec2_sg_http"
  }
}

# Set up the launch configuration for the EC2 instances
resource "aws_launch_template" "prod_lt" {
  name_prefix   = "prod-lt"
  image_id      = "ami-04b4f1a9cf54c11d0"  # Replace with latest AMI
  instance_type = "t2.micro"
  key_name      = "test_key"

  vpc_security_group_ids = [aws_security_group.ec2_sg_http.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "prod_ec2"
    }
  }
}

# Set up the autoscaling group
resource "aws_autoscaling_group" "prod_asg" {
  launch_template {
    id      = aws_launch_template.prod_lt.id
    version = "$Latest"
  }

  vpc_zone_identifier = [
    aws_subnet.prod_private_subnet_1.id,
    aws_subnet.prod_private_subnet_2.id
  ]

  min_size             = 1   # Start with 1 instance
  max_size             = 4   # Can scale up to 4 instances
  desired_capacity     = 1   # Initial instance count set to 1
  health_check_type    = "ELB"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "prod_ec2"
    propagate_at_launch = true
  }
}

# Set up the target group
resource "aws_lb_target_group" "prod_tg" {
  name     = "prod-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.prod_vpc.id
  target_type = "instance"

  health_check {
    path                = "/"
    interval           = 30
    timeout            = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Attach the target group to the autoscaling group
resource "aws_autoscaling_attachment" "prod_asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.prod_asg.id
  lb_target_group_arn    = aws_lb_target_group.prod_tg.arn
}

# Set up the listener for http
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.prod_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_tg.arn
  }
}

# Set up the RDS
resource "aws_db_instance" "prod_postgres" {
  allocated_storage    = 20           # Storage size in GB
  storage_type         = "gp2"        # General-purpose SSD storage
  engine               = "postgres"   # Specify the PostgreSQL engine
  engine_version       = "13.3"       # Version of PostgreSQL
  instance_class       = "db.t3.micro" # Choose a small instance type (adjust as needed)
  identifier           = "habit-tracker-db"  # Database identifier
  username             = "admin"      # Database admin username
  password             = "password"  # Database admin password
  db_subnet_group_name = aws_db_subnet_group.prod_db_subnet_group.name  # We will create this next
  vpc_security_group_ids = [aws_security_group.prod_db_sg.id] # Security group
  multi_az             = true         # Enable multi-AZ deployment
  backup_retention_period = 7         # Backup retention period in days
  publicly_accessible  = false        # Don't allow public access (use private subnets)
  skip_final_snapshot  = true         # Skip snapshot on deletion

  tags = {
    Name = "prod_postgres_db"
  }
}

# Subnet group for RDS
resource "aws_db_subnet_group" "prod_db_subnet_group" {
  name        = "prod-db-subnet-group"
  description = "Subnet group for RDS instances"
  subnet_ids  = [
    aws_subnet.prod_private_subnet_1.id,
    aws_subnet.prod_private_subnet_2.id
  ]
  
  tags = {
    Name = "prod-db-subnet-group"
  }
}

# Security group for RDS
resource "aws_security_group" "prod_db_sg" {
  name        = "prod_db_sg"
  description = "Security group for PostgreSQL RDS instance"
  vpc_id      = aws_vpc.prod_vpc.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [aws_security_group.ec2_sg_http.id]  # Allow EC2 instances to access RDS
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


