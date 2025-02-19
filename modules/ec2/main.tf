# This module creates an EC2 instance, with a launch configuration and an autoscaling group.

## Set up the launch configuration for the EC2 instances
resource "aws_launch_template" "prod_lt" {
  name_prefix   = "prod-lt"
  image_id      = "ami-04b4f1a9cf54c11d0" 
  instance_type = "t2.micro"
  key_name      = "test_key"

  vpc_security_group_ids = [ var.ec2_sg_id ]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "prod_ec2"
    }
  }
}

## Set up the autoscaling group for the EC2 instances
resource "aws_autoscaling_group" "prod_asg" {
  count = length(var.private_subnets_id)
  launch_template {
    id      = aws_launch_template.prod_lt.id
    version = "$Latest"
  }

  vpc_zone_identifier = [ var.private_subnets_id[count.index] ]

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

# Attach the target group to the autoscaling group
resource "aws_autoscaling_attachment" "prod_asg_attachment" {
  count = length(var.private_subnets_id)
  autoscaling_group_name = aws_autoscaling_group.prod_asg[count.index].id
  lb_target_group_arn    = var.target_group_arn
}