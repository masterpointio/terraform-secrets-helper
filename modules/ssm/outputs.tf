output "all" {
  value       = local.ssm_secrets
  description = "The secrets pulled from AWS SSM Parameter Store."
  sensitive   = true
}
