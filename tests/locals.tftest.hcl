mock_provider "sops" {
  mock_data "sops_file" {
    defaults = {
      raw = "db_password: supersecret123\napi_key: test-api-key-456"
    }
  }
}

run "test_empty_secret_mapping" {
  command = plan

  variables {
    secret_mapping = []
  }

  assert {
    condition = length(local.secrets) == 0
    error_message = "Empty input should result in empty final secrets"
  }
}

run "test_multiple_files_and_secrets" {
  command = plan

  variables {
    secret_mapping = [
      {
        name = "db_password"
        type = "sops"
        file = "database.yaml"
      },
      {
        name = "api_key"
        type = "sops"
        file = "api.yaml"
      },
      {
        name = "redis_password"
        type = "sops"
        file = "database.yaml"
      }
    ]
  }

  assert {
    condition = length(local.sops_secret_mapping) == 3
    error_message = "Should have 3 sops secret mappings"
  }

  assert {
    condition = (
      length(local.sops_files) == 2
      && contains(local.sops_files, "database.yaml")
      && contains(local.sops_files, "api.yaml")
    )
    error_message = "Should have 2 unique sops files (database.yaml and api.yaml)"
  }

  assert {
    condition = length(local.sops_yamls) == 2
    error_message = "Should have 2 YAML files loaded in sops_yamls"
  }

  assert {
    condition = length(local.sops_secrets) == 3
    error_message = "Should have 3 secrets in sops_secrets map"
  }

  assert {
    condition = alltrue([
      for mapping in local.sops_secret_mapping :
      contains(keys(local.sops_secrets), mapping.name)
    ])
    error_message = "All secret mappings should result in corresponding secret names"
  }

  assert {
    condition = length(distinct(keys(local.sops_secrets))) == length(keys(local.sops_secrets))
    error_message = "All secret keys should be unique"
  }
}
