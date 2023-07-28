locals {
  # Filter out our sops mappings
  sops_secret_mapping = [
    for mapping in var.secret_mapping :
    mapping if mapping.type == "sops"
  ]

  # Filter the unique set of sops files we need to pull
  sops_files = toset(distinct([
    for mapping in local.sops_secret_mapping :
    mapping.file
  ]))

  # Collect our sops file values as a map of "sops file path => map of values"
  sops_yamls = {
    for sops_file in local.sops_files :
    sops_file => yamldecode(data.sops_file.sops_secrets[sops_file].raw)
  }

  # Create our sops secret name to value map
  sops_secrets = {
    for mapping in local.sops_secret_mapping :
    mapping.name => lookup(local.sops_yamls[mapping.file], mapping.name, null)
  }

  # The final secrets for generic consumption
  secrets = local.sops_secrets
}

data "sops_file" "sops_secrets" {
  for_each    = local.sops_files
  source_file = "${path.root}/${each.value}"
}
