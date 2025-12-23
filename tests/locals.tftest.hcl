mock_provider "sops" {
  mock_data "sops_file" {
    defaults = {
      raw = "db_password: supersecret123\napi_key: test-api-key-456"
    }
  }
}

mock_provider "aws" {
  mock_data "aws_ssm_parameter" {
    defaults = {
      value = "mock-ssm-value"
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

run "test_ssm_secrets" {
  command = plan

  variables {
    secret_mapping = [
      {
        name = "ssm_secret"
        type = "ssm"
        path = "/app/secret"
      },
      {
        name = "another_ssm_secret"
        type = "ssm"
        path = "/app/another_secret"
      }
    ]
  }

  assert {
    condition     = length(local.ssm_secret_mapping) == 2
    error_message = "Should have 2 SSM secret mappings"
  }

  assert {
    condition = (
      length(local.ssm_paths) == 2
      && contains(local.ssm_paths, "/app/secret")
      && contains(local.ssm_paths, "/app/another_secret")
    )
    error_message = "Should have both SSM paths in ssm_paths"
  }

  assert {
    condition     = length(local.ssm_secrets) == 2
    error_message = "Should have 2 secrets in ssm_secrets map"
  }

  assert {
    condition     = length(local.sops_secret_mapping) == 0
    error_message = "Should have no SOPS secret mappings"
  }
}

run "test_mixed_sops_and_ssm" {
  command = plan

  variables {
    secret_mapping = [
      {
        name = "db_password"
        type = "sops"
        file = "database.yaml"
      },
      {
        name = "api_token"
        type = "ssm"
        path = "/app/api_token"
      },
      {
        name = "api_key"
        type = "sops"
        file = "api.yaml"
      }
    ]
  }

  assert {
    condition     = length(local.sops_secret_mapping) == 2
    error_message = "Should have 2 SOPS secret mappings"
  }

  assert {
    condition     = length(local.ssm_secret_mapping) == 1
    error_message = "Should have 1 SSM secret mapping"
  }

  assert {
    condition     = length(local.secrets) == 3
    error_message = "Should have 3 total secrets"
  }

  assert {
    condition = (
      contains(keys(local.secrets), "db_password")
      && contains(keys(local.secrets), "api_token")
      && contains(keys(local.secrets), "api_key")
    )
    error_message = "All secret names should be present in the merged secrets"
  }
}
