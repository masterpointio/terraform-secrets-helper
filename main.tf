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

  # Filter out our ssm mappings
  ssm_secret_mapping = [
    for mapping in var.secret_mapping :
    mapping if mapping.type == "ssm"
  ]

  # Collect the ssm paths we need to pull
  ssm_paths = toset(distinct([
    for mapping in local.ssm_secret_mapping :
    mapping.path
  ]))

  # Create our ssm secret name to value map
  ssm_secrets = {
    for mapping in local.ssm_secret_mapping :
    mapping.name => data.aws_ssm_parameter.ssm_secrets[mapping.path].value
  }

  # Merge the final ssm secrets + sops secrets for generic consumption in the component.
  secrets = merge(local.sops_secrets, local.ssm_secrets)
}

data "sops_file" "sops_secrets" {
  for_each    = local.sops_files
  source_file = "${path.root}/${each.value}"
}

data "aws_ssm_parameter" "ssm_secrets" {
  for_each = local.ssm_paths
  name     = each.value
}