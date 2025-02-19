# Outputs from the WAF module

output "waf_arn" {
  value = aws_wafv2_web_acl.prod_waf.arn
}