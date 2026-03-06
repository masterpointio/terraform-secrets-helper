# tflint-ignore-file: terraform_required_version

# SOPS-ONLY MIXIN - Uses the SOPS sub-module.
# Requires the SOPS provider (carlpett/sops).
# If you also need SSM secrets, use secrets.mixin.tf (both) or secrets.ssm.mixin.tf (SSM only).

locals {
  # tflint-ignore: terraform_unused_declarations
  secrets = module.secrets.all
}

module "secrets" {
  # checkov:skip=CKV_TF_1: For now we use Terraform registry source, not git. If switching to git, we should use a commit hash.
  source  = "masterpointio/helper/secrets//modules/sops"
  version = "3.0.0"

  secret_mapping = [
    for mapping in var.secret_mapping :
    {
      name = mapping.name
      file = mapping.file
    }
    if mapping.type == "sops"
  ]
}

variable "secret_mapping" {
  type = list(object({
    name = string
    type = optional(string, "sops")
    path = optional(string, null)
    file = optional(string, null)
  }))
  default     = []
  description = <<-EOT
    The list of secret mappings the application will need.
    This creates secret values for the component to consume at `local.secrets[name]`.
    For SOPS secrets: use type="sops" (default), file="path/to/sops/file.yaml", and name matching a key in the SOPS file.
    NOTE: SSM secrets require using secrets.ssm.mixin.tf or secrets.mixin.tf instead.
    EOT

  validation {
    condition = alltrue([
      for mapping in var.secret_mapping :
      mapping.type == "sops"
    ])
    error_message = "This is a SOPS-only mixin. All secrets must have type=\"sops\". For SSM secrets, use secrets.ssm.mixin.tf or secrets.mixin.tf instead."
  }

  validation {
    condition = alltrue([
      for mapping in var.secret_mapping :
      mapping.type == "sops" ? mapping.file != null : true
    ])
    error_message = "SOPS secrets require 'file' attribute."
  }
}
