output "cloudwatch_agent" {
  value = aws_iam_role.cloudwatch_agent_role.name
}

output "rds_cloudwatch_arn" {
  value = aws_iam_role.rds_cloudwatch_role.arn
}