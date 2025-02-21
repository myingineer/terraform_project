# Create an instance profile for the CloudWatch agent
resource "aws_iam_instance_profile" "cloudwatch_instance_profile" {
  name = "CloudWatchInstanceProfile"
  role = var.cloudwatch_agent_role_name
}

# Create an SSM parameter for the CloudWatch agent configuration
resource "aws_ssm_parameter" "cloudwatch_agent_config" {
  name  = "AmazonCloudWatch-linux"
  type  = "String"
  value = <<EOT
{
  "agent": {
    "metrics_collection_interval": 60
  },
  "metrics": {
    "namespace": "MyApp/Metrics",
    "metrics_collected": {
      "cpu": {
        "measurement": ["cpu_usage_idle", "cpu_usage_user", "cpu_usage_system"],
        "metrics_collection_interval": 60
      },
      "disk": {
        "measurement": ["disk_used_percent"],
        "metrics_collection_interval": 60
      },
      "mem": {
        "measurement": ["mem_used_percent"],
        "metrics_collection_interval": 60
      }
    }
  }
}
EOT
}

resource "aws_cloudwatch_log_group" "rds_log_group" {
  name = "/aws/rds/instance/habit-tracker-instance"
}
