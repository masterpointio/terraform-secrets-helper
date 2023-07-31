# In this example we assume that the mixin `../../exports/secrets.sops.tf` is placed next to `outputs.tf`, `so local.secrets` is available.
# The secrets file `test.yaml` is encrypted by tool `age`, see more https://github.com/getsops/sops#encrypting-using-age.
#
# To decrypt and view the secrets file, run `SOPS_AGE_KEY_FILE=key.txt sops test.yaml`.
# To run Terraform commands - pass the age key file as well, e.g.: `SOPS_AGE_KEY_FILE=key.txt terraform apply`.

output "db_password" {
  value     = jsonencode(local.secrets["db_password"])
  sensitive = true
}
