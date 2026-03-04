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
    condition     = length(local.secrets) == 0
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
    condition     = length(local.secrets) == 3
    error_message = "Should have 3 total secrets from SOPS"
  }

  assert {
    condition = alltrue([
      contains(keys(local.secrets), "db_password"),
      contains(keys(local.secrets), "api_key"),
      contains(keys(local.secrets), "redis_password"),
    ])
    error_message = "All SOPS secret names should be present"
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
    condition     = length(local.secrets) == 2
    error_message = "Should have 2 SSM secrets"
  }

  assert {
    condition = alltrue([
      contains(keys(local.secrets), "ssm_secret"),
      contains(keys(local.secrets), "another_ssm_secret"),
    ])
    error_message = "All SSM secret names should be present"
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
    condition     = length(local.secrets) == 3
    error_message = "Should have 3 total secrets"
  }

  assert {
    condition = alltrue([
      contains(keys(local.secrets), "db_password"),
      contains(keys(local.secrets), "api_token"),
      contains(keys(local.secrets), "api_key"),
    ])
    error_message = "All secret names should be present in the merged secrets"
  }
}
