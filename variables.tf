variable "secret_mapping" {
  type = list(object({
    name = string
    type = optional(string, "sops")
    path = optional(string, null)
    file = string
  }))
  default     = []
  description = <<-EOT
    The list of secret mappings the application will need.
    This creates secret values for the component to consume at `local.secrets[name]`.
    EOT
}
