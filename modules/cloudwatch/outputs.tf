# Description: This file contains the output variables for the cloudwatch module.

# Output the name of the instance profile created for the CloudWatch agent
output "cloudwatch_profile_name" {
  value = aws_iam_instance_profile.cloudwatch_instance_profile.name
}