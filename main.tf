module "ssm" {
  source = "./modules/ssm"

  secret_mapping = [
    for mapping in var.secret_mapping :
    {
      name = mapping.name
      path = mapping.path
    }
    if mapping.type == "ssm"
  ]
}

module "sops" {
  source = "./modules/sops"

  secret_mapping = [
    for mapping in var.secret_mapping :
    {
      name = mapping.name
      file = mapping.file
    }
    if mapping.type == "sops"
  ]
}

locals {
  secrets = merge(module.sops.all, module.ssm.all)
}
