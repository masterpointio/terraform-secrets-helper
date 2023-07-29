# In this example we assume that the mixin `../../exports/secrets.sops.tf` is placed next to `outputs.tf`,
# `so local.secrets` is available.

output "db_password" {
  value     = jsonencode(local.secrets["db_password"])
  sensitive = true
}
