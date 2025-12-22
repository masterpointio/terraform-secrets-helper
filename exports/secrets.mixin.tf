# tflint-ignore-file: terraform_required_version

# Reference your secrets using the module output
locals {
  # tflint-ignore: terraform_unused_declarations
  secrets = module.secrets.all
}

module "secrets" {
  # checkov:skip=CKV_TF_1: For now we use Terraform registry source, not git. If switching to git, we should use a commit hash.
  source         = "masterpointio/helper/secrets"
  version        = "1.1.0"
  secret_mapping = var.secret_mapping
}

variable "secret_mapping" {
  type = list(object({
    name = string
    type = string
    path = optional(string, null)
    file = optional(string, null)
  }))
  default     = []
  description = <<-EOT
    The list of secret mappings the application will need.
    This creates secret values for the component to consume at `local.secrets[name]`.
    For SOPS secrets: use type="sops", file="path/to/sops/file.yaml", and name matching a key in the SOPS file.
    For SSM secrets: use type="ssm" and path="/path/to/ssm/parameter".
    EOT

  validation {
    condition = alltrue([
      for mapping in var.secret_mapping :
      contains(["sops", "ssm"], mapping.type)
    ])
    error_message = "Secret type must be either 'sops' or 'ssm'."
  }

  validation {
    condition = alltrue([
      for mapping in var.secret_mapping :
      mapping.type == "sops" ? mapping.file != null : true
    ])
    error_message = "SOPS secrets require 'file' attribute."
  }

  validation {
    condition = alltrue([
      for mapping in var.secret_mapping :
      mapping.type == "ssm" ? mapping.path != null : true
    ])
    error_message = "SSM secrets require 'path' attribute."
  }
}
