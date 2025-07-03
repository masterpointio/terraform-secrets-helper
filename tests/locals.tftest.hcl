mock_provider "sops" {
  mock_data "sops_file" {
    defaults = {
      raw = "db_password: supersecret123\napi_key: test-api-key-456"
    }
  }
}

run "test_basic_secret_mapping_filtering" {
  command = plan

  variables {
    secret_mapping = [
      {
        name = "db_password"
        type = "sops"
        file = "secrets.yaml"
      },
      {
        name = "api_key"
        type = "sops"
        file = "secrets.yaml"
      }
    ]
  }

  assert {
    condition = length(local.sops_secret_mapping) == 2
    error_message = "Should have 2 sops secret mappings"
  }

  assert {
    condition = alltrue([
      for mapping in local.sops_secret_mapping :
      mapping.type == "sops"
    ])
    error_message = "All filtered mappings should be of type 'sops'"
  }

  assert {
    condition = length(local.sops_files) == 1
    error_message = "Should have 1 unique sops file"
  }

  assert {
    condition = contains(local.sops_files, "secrets.yaml")
    error_message = "Should contain secrets.yaml in sops_files"
  }

  assert {
    condition = length(local.sops_secrets) == 2
    error_message = "Should have 2 secrets in sops_secrets map"
  }

  assert {
    condition = local.secrets == local.sops_secrets
    error_message = "Final secrets should match sops_secrets"
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
    condition = length(local.sops_files) == 2
    error_message = "Should have 2 unique sops files (database.yaml and api.yaml)"
  }

  assert {
    condition = contains(local.sops_files, "database.yaml")
    error_message = "Should contain database.yaml in sops_files"
  }

  assert {
    condition = contains(local.sops_files, "api.yaml")
    error_message = "Should contain api.yaml in sops_files"
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
    error_message = "All secret mappings should result in corresponding secrets"
  }

  assert {
    condition = length(distinct(keys(local.sops_secrets))) == length(keys(local.sops_secrets))
    error_message = "All secret keys should be unique"
  }
}