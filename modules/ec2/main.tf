# This module creates an EC2 instance, with a launch configuration and an autoscaling group.

## Set up the launch configuration for the EC2 instances
resource "aws_launch_template" "prod_lt" {
  name_prefix   = "prod-lt"
  image_id      = "ami-04b4f1a9cf54c11d0"  # Amazon Ubuntu 20.04
  instance_type = "t2.micro" # Small instance type
  iam_instance_profile {
    name = var.iam_instance_profile
  } # Instance profile for the CloudWatch agent
  key_name      = "test_key" # Key pair for SSH access

  vpc_security_group_ids = [ var.ec2_sg_id ] # Security group for the EC2 instance

  user_data = base64encode(<<-EOF
              #!/bin/bash
              sudo yum install -y amazon-cloudwatch-agent
              sudo amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c ssm:AmazonCloudWatch-linux -s
              EOF
  )

  tag_specifications {
    resource_type = "instance" # Tag the instance

    tags = {
      Name = "prod_ec2"
    }
  }
}

## Set up the autoscaling group for the EC2 instances
resource "aws_autoscaling_group" "prod_asg" {
  count = length(var.private_subnets_id) # Create an autoscaling group for each private subnet
  launch_template {
    id      = aws_launch_template.prod_lt.id
    version = "$Latest"
  } # Use the launch template for the autoscaling group

  vpc_zone_identifier = [ var.private_subnets_id[count.index] ]

  min_size             = 1   # Start with 1 instance
  max_size             = 4   # Can scale up to 4 instances
  desired_capacity     = 1   # Initial instance count set to 1
  health_check_type    = "ELB" # Health check type
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "prod_ec2"
    propagate_at_launch = true
  }
}

# Attach the target group to the autoscaling group
resource "aws_autoscaling_attachment" "prod_asg_attachment" {
  count = length(var.private_subnets_id)
  autoscaling_group_name = aws_autoscaling_group.prod_asg[count.index].id
  lb_target_group_arn    = var.target_group_arn
}