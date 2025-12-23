[![Banner][banner-image]](https://masterpoint.io/)

# terraform-secrets-helper

[![Release][release-badge]][latest-release]

💡 Learn more about Masterpoint [below](#who-we-are-𐦂𖨆𐀪𖠋).

## Purpose and Functionality

This Terraform module provides a standard and extensible way of managing secrets from different sources, making them accessible through `local.secrets["<SECRET_NAME>"]`. It's designed to create an abstract interface for dealing with secrets in Terraform, regardless of the source of these secrets.

Our initial version is built to handle [SOPS secrets](https://github.com/getsops/sops), but it is designed in a way that it can be easily extended to support other secret providers like AWS SSM Parameter Store, Vault, and more in the future.

This module can be included as a child module, where needed, to fetch secrets and provide them in an abstract manner.

## Usage

Copy `exports/secrets.mixin.tf` to your project by running the following command:

```sh
curl -sL https://raw.githubusercontent.com/masterpointio/terraform-secrets-helper/main/exports/secrets.mixin.tf -o secrets.mixin.tf
```

The mixin incorporates the invocation of this module, so you simply need to configure the required `secret_mapping` variable and then reference it within your code.

See the full example in [examples/complete](https://github.com/masterpointio/terraform-secrets-helper/tree/main/examples/complete)

### SOPS Secrets

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

### AWS SSM Parameter Store Secrets

```hcl
secret_mapping = [{
  name = "api_token"
  type = "ssm"
  path = "/myapp/prod/api_token"
}]
```

### Mixed Sources

You can combine both SOPS and SSM secrets in the same configuration:

```hcl
secret_mapping = [
  {
    name = "db_password"
    type = "sops"
    file = "secrets.yaml"
  },
  {
    name = "api_token"
    type = "ssm"
    path = "/myapp/prod/api_token"
  }
]
```

# Future Enhancements

The module currently supports SOPS and AWS SSM Parameter Store. Future versions may add support for other secret providers like HashiCorp Vault, AWS Secrets Manager, and more.

<!-- prettier-ignore-start -->
<!-- markdownlint-disable MD013 -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |
| <a name="requirement_sops"></a> [sops](#requirement\_sops) | >= 0.7 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0 |
| <a name="provider_sops"></a> [sops](#provider\_sops) | >= 0.7 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ssm_parameter.ssm_secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [sops_file.sops_secrets](https://registry.terraform.io/providers/carlpett/sops/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_secret_mapping"></a> [secret\_mapping](#input\_secret\_mapping) | The list of secret mappings the application will need.<br/>This creates secret values for the component to consume at `local.secrets[name]`.<br/>For SOPS secrets: use type="sops" (default), file="path/to/sops/file.yaml", and name matching a key in the SOPS file.<br/>For SSM secrets: use type="ssm" and path="/path/to/ssm/parameter". | <pre>list(object({<br/>    name = string<br/>    type = optional(string, "sops")<br/>    path = optional(string, null)<br/>    file = optional(string, null)<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_all"></a> [all](#output\_all) | The final secrets pulled from various sources. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- markdownlint-enable MD013 -->
<!-- prettier-ignore-end -->

## Built By

Powered by the [Masterpoint team](https://masterpoint.io/who-we-are/) and driven forward by contributions from the community ❤️

[![Contributors][contributors-image]][contributors-url]

## Contribution Guidelines

Contributions are welcome and appreciated!

Found an issue or want to request a feature? [Open an issue][issues-url]

Want to fix a bug you found or add some functionality? Fork, clone, commit, push, and PR — we'll check it out.

## Who We Are 𐦂𖨆𐀪𖠋

Established in 2016, Masterpoint is a team of experienced software and platform engineers specializing in Infrastructure as Code (IaC). We provide expert guidance to organizations of all sizes, helping them leverage the latest IaC practices to accelerate their engineering teams.

### Our Mission

Our mission is to simplify cloud infrastructure so developers can innovate faster, safer, and with greater confidence. By open-sourcing tools and modules that we use internally, we aim to contribute back to the community, promoting consistency, quality, and security.

### Our Commitments

- 🌟 **Open Source**: We live and breathe open source, contributing to and maintaining hundreds of projects across multiple organizations.
- 🌎 **1% for the Planet**: Demonstrating our commitment to environmental sustainability, we are proud members of [1% for the Planet](https://www.onepercentfortheplanet.org), pledging to donate 1% of our annual sales to environmental nonprofits.
- 🇺🇦 **1% Towards Ukraine**: With team members and friends affected by the ongoing [Russo-Ukrainian war](https://en.wikipedia.org/wiki/Russo-Ukrainian_War), we donate 1% of our annual revenue to invasion relief efforts, supporting organizations providing aid to those in need. [Here's how you can help Ukraine with just a few clicks](https://masterpoint.io/updates/supporting-ukraine/).

## Connect With Us

We're active members of the community and are always publishing content, giving talks, and sharing our hard earned expertise. Here are a few ways you can see what we're up to:

[![LinkedIn][linkedin-badge]][linkedin-url] [![Newsletter][newsletter-badge]][newsletter-url] [![Blog][blog-badge]][blog-url] [![YouTube][youtube-badge]][youtube-url]

... and be sure to connect with our founder, [Matt Gowie](https://www.linkedin.com/in/gowiem/).

## License

[Apache License, Version 2.0][license-url].

[![Open Source Initiative][osi-image]][license-url]

Copyright © 2016-2025 [Masterpoint Consulting LLC](https://masterpoint.io/)

<!-- MARKDOWN LINKS & IMAGES -->

[banner-image]: https://masterpoint-public.s3.us-west-2.amazonaws.com/v2/standard-long-fullcolor.png
[license-url]: https://opensource.org/license/apache-2-0
[osi-image]: https://i0.wp.com/opensource.org/wp-content/uploads/2023/03/cropped-OSI-horizontal-large.png?fit=250%2C229&ssl=1
[linkedin-badge]: https://img.shields.io/badge/LinkedIn-Follow-0A66C2?style=for-the-badge&logoColor=white
[linkedin-url]: https://www.linkedin.com/company/masterpoint-consulting
[blog-badge]: https://img.shields.io/badge/Blog-IaC_Insights-55C1B4?style=for-the-badge&logoColor=white
[blog-url]: https://masterpoint.io/updates/
[newsletter-badge]: https://img.shields.io/badge/Newsletter-Subscribe-ECE295?style=for-the-badge&logoColor=222222
[newsletter-url]: https://newsletter.masterpoint.io/
[youtube-badge]: https://img.shields.io/badge/YouTube-Subscribe-D191BF?style=for-the-badge&logo=youtube&logoColor=white
[youtube-url]: https://www.youtube.com/channel/UCeeDaO2NREVlPy9Plqx-9JQ
[release-badge]: https://img.shields.io/github/v/release/masterpointio/terraform-secrets-helper?color=0E383A&label=Release&style=for-the-badge&logo=github&logoColor=white
[latest-release]: https://github.com/masterpointio/terraform-secrets-helper/releases/latest
[contributors-image]: https://contrib.rocks/image?repo=masterpointio/terraform-secrets-helper
[contributors-url]: https://github.com/masterpointio/terraform-secrets-helper/graphs/contributors
[issues-url]: https://github.com/masterpointio/terraform-secrets-helper/issues
