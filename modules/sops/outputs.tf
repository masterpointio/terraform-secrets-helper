output "all" {
  value       = local.sops_secrets
  description = "The secrets pulled from SOPS-encrypted files."
  sensitive   = true
}
