module "secrets" {
  # Will be updated once we release a version and publish to the registry
  # checkov:skip=CKV_TF_1:This module source will be updated soon, skipping this check.
  source         = "git::https://github.com/masterpointio/terraform-secrets-helper.git?ref=tags/X.X.X"
  secret_mapping = var.secret_mapping
}

variable "secret_mapping" {
  type = list(object({
    name = string
    type = string
    path = optional(string, null)
    file = string
  }))
  default     = []
  description = <<-EOT
    The list of secret mappings the application will need.
    This creates secret values for the component to consume at `local.secrets[name]`.
    EOT
}

# Reference your secrets using the module output
locals {
  # tflint-ignore: terraform_unused_declarations
  secrets = module.secrets.all
}
