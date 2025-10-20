terraform {
  required_version = ">= 1.3"

  required_providers {
    sops = {
      source  = "carlpett/sops"
      version = ">= 0.7"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}
