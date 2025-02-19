# AWS Web Application Firewall (WAF) module

## Set up the WAF
resource "aws_wafv2_web_acl" "prod_waf" {
  name        = "prod_waf"
  description = "WAF for the production environment"
  scope       = "REGIONAL"

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