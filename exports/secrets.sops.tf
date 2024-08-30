module "secrets" {
  # checkov:skip=CKV_TF_1: For now we use Terraform registry source, not git. If switching to git, we should use a commit hash.
  source         = "masterpointio/helper/secrets"
  version        = "0.3.0"
  secret_mapping = var.secret_mapping
}

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

# Reference your secrets using the module output
locals {
  # tflint-ignore: terraform_unused_declarations
  secrets = module.secrets.all
}
