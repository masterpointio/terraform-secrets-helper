# tflint-ignore-file: terraform_unused_required_providers

terraform {
  required_version = ">= 1.3"

  # Providers are used by sub-modules (modules/ssm, modules/sops) and declared
  # here so consumers of the root module know the full set of provider dependencies.
  required_providers {
    sops = {
      source  = "carlpett/sops"
      version = "1.3.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}
