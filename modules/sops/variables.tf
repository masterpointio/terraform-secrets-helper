variable "secret_mapping" {
  type = list(object({
    name = string
    file = string
  }))
  default     = []
  description = <<-EOT
    The list of SOPS secret mappings the application will need.
    This creates secret values for the component to consume at `module.secrets_sops.all["name"]`.
    Each entry requires:
      - name: The key used to reference the secret, matching a key in the SOPS YAML file
      - file: Path to the SOPS-encrypted YAML file relative to the root module
    EOT
}
