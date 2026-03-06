locals {
  sops_files = toset(distinct([
    for mapping in var.secret_mapping :
    mapping.file
  ]))

  sops_yamls = {
    for sops_file in local.sops_files :
    sops_file => yamldecode(data.sops_file.sops_secrets[sops_file].raw)
  }

  sops_secrets = {
    for mapping in var.secret_mapping :
    mapping.name => local.sops_yamls[mapping.file][mapping.name]
  }
}

data "sops_file" "sops_secrets" {
  for_each    = local.sops_files
  source_file = "${path.root}/${each.value}"
}
