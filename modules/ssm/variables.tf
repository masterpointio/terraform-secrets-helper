variable "secret_mapping" {
  type = list(object({
    name = string
    path = string
  }))
  default     = []
  description = <<-EOT
    The list of SSM secret mappings the application will need.
    This creates secret values for the component to consume at `local.secrets[name]`.
    Each entry requires:
      - name: The key used to reference the secret via `module.secrets_ssm.all["name"]`
      - path: The SSM parameter path, e.g. "/myapp/prod/api_token"
    EOT
}
