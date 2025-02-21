# Create an IAM role for CloudWatch
resource "aws_iam_role" "cloudwatch_agent_role" {
  name = "CloudWatchAgentRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Attach the CloudWatchAgentServerPolicy to the CloudWatchAgentRole
resource "aws_iam_policy_attachment" "cloudwatch_agent_attachment" {
  name       = "CloudWatchAgentAttachment"
  roles      = [aws_iam_role.cloudwatch_agent_role.name]
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role" "rds_cloudwatch_role" {
  name = "RDSCloudWatchRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "rds.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "rds_cloudwatch_policy" {
  name       = "RDSCloudWatchPolicyAttachment"
  roles      = [aws_iam_role.rds_cloudwatch_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
