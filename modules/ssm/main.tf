locals {
  ssm_paths = toset(distinct([
    for mapping in var.secret_mapping :
    mapping.path
  ]))

  ssm_secrets = {
    for mapping in var.secret_mapping :
    mapping.name => data.aws_ssm_parameter.ssm_secrets[mapping.path].value
  }
}

data "aws_ssm_parameter" "ssm_secrets" {
  for_each = local.ssm_paths
  name     = each.value
}
