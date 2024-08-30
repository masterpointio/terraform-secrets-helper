[![Masterpoint Logo](https://i.imgur.com/RDLnuQO.png)](https://masterpoint.io)

# terraform-secrets-helper [![Latest Release](https://img.shields.io/github/release/masterpointio/terraform-secrets-helper.svg)](https://github.com/masterpointio/terraform-secrets-helper/releases/latest)

This Terraform module provides a standard and extensible way of managing secrets from different sources, making them accessible through `local.secrets["<SECRET_NAME>"]`. It's designed to create an abstract interface for dealing with secrets in Terraform, regardless of the source of these secrets.

Our initial version is built to handle [SOPS secrets](https://github.com/getsops/sops), but it is designed in a way that it can be easily extended to support other secret providers like AWS SSM Parameter Store, Vault, and more in the future.

This module can be included as a child module, where needed, to fetch secrets and provide them in an abstract manner.

It's 100% Open Source and licensed under the [APACHE2](LICENSE).

# Usage

Copy `exports/secrets.sops.tf` to your project by running the following command:

```sh
curl -sL https://raw.githubusercontent.com/masterpointio/terraform-secrets-helper/main/exports/secrets.sops.tf -o secrets.sops.tf
```

The mixin incorporates the invocation of this module, so you simply need to configure the required `secret_mapping` variable and then reference it within your code.

See the full example in [examples/complete](https://github.com/masterpointio/terraform-secrets-helper/tree/main/examples/complete)

```hcl
secret_mapping = [{
  name = "db_password"
  file = "test.yaml"
  type = "sops"
}]

output "db_password" {
  value     = jsonencode(local.secrets["db_password"])
  sensitive = true
}
```

# Future Enhancements

While the current version is specific to SOPS, future mixins will support other secret providers like SSM Parameter Store, Vault, and more. The future mixins will include all necessary provider configuration for themselves, making the process of integrating with different secret providers seamless.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

| Name      | Version |
| --------- | ------- |
| terraform | >= 1.3  |
| sops      | >= 0.7  |

## Providers

| Name | Version |
| ---- | ------- |
| sops | >= 0.7  |

## Modules

No modules.

## Resources

| Name                                                                                                          | Type        |
| ------------------------------------------------------------------------------------------------------------- | ----------- |
| [sops_file.sops_secrets](https://registry.terraform.io/providers/carlpett/sops/latest/docs/data-sources/file) | data source |

## Inputs

| Name           | Description                                                                                                                              | Type                                                                                                          | Default | Required |
| -------------- | ---------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------- | ------- | :------: |
| secret_mapping | The list of secret mappings the application will need. This creates secret values for the component to consume at `local.secrets[name]`. | `list(object({ name = string type = optional(string, "sops") path = optional(string, null) file = string }))` | `[]`    |    no    |

## Outputs

| Name | Description                                    |
| ---- | ---------------------------------------------- |
| all  | The final secrets pulled from various sources. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
