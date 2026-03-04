# tflint-ignore-file: terraform_required_version

# SSM-ONLY MIXIN - Uses the SSM sub-module.
# The SOPS provider (carlpett/sops) is NOT required.
# If you also need SOPS secrets, use secrets.mixin.tf (both) or secrets.sops.mixin.tf (SOPS only).

locals {
  # tflint-ignore: terraform_unused_declarations
  secrets = module.secrets.all
}

module "secrets" {
  # checkov:skip=CKV_TF_1: For now we use Terraform registry source, not git. If switching to git, we should use a commit hash.
  source  = "masterpointio/helper/secrets//modules/ssm"
  version = "3.0.0"

  secret_mapping = [
    for mapping in var.secret_mapping :
    {
      name = mapping.name
      path = mapping.path
    }
    if mapping.type == "ssm"
  ]
}

variable "secret_mapping" {
  type = list(object({
    name = string
    type = optional(string, "ssm")
    path = optional(string, null)
    file = optional(string, null)
  }))
  default     = []
  description = <<-EOT
    The list of secret mappings the application will need.
    This creates secret values for the component to consume at `local.secrets[name]`.
    For SSM secrets: use type="ssm" (default) and path="/path/to/ssm/parameter".
    NOTE: SOPS secrets require using secrets.sops.mixin.tf or secrets.mixin.tf instead.
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
      mapping.type == "ssm" ? mapping.path != null : true
    ])
    error_message = "SSM secrets require 'path' attribute."
  }
}
