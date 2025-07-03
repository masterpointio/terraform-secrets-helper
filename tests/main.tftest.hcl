mock_provider "sops" {
  mock_data "sops_file" {
    defaults = {
      raw = "db_password: supersecret123\napi_key: test-api-key-456"
    }
  }
}

run "test_data_resource_creation_single_file" {
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
    condition = length(data.sops_file.sops_secrets) == 1
    error_message = "Should create exactly 1 sops_file data resource for single file"
  }

  assert {
    condition = contains(keys(data.sops_file.sops_secrets), "secrets.yaml")
    error_message = "Should create data resource with key 'secrets.yaml'"
  }

  assert {
    condition = data.sops_file.sops_secrets["secrets.yaml"].source_file == "${path.root}/secrets.yaml"
    error_message = "Source file path should be correctly constructed with path.root"
  }
}

run "test_data_resource_creation_multiple_files" {
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
    condition = length(data.sops_file.sops_secrets) == 2
    error_message = "Should create exactly 2 sops_file data resources for 2 unique files"
  }

  assert {
    condition = contains(keys(data.sops_file.sops_secrets), "database.yaml")
    error_message = "Should create data resource with key 'database.yaml'"
  }

  assert {
    condition = contains(keys(data.sops_file.sops_secrets), "api.yaml")
    error_message = "Should create data resource with key 'api.yaml'"
  }

  assert {
    condition = data.sops_file.sops_secrets["database.yaml"].source_file == "${path.root}/database.yaml"
    error_message = "Database file path should be correctly constructed"
  }

  assert {
    condition = data.sops_file.sops_secrets["api.yaml"].source_file == "${path.root}/api.yaml"
    error_message = "API file path should be correctly constructed"
  }
}

run "test_data_resource_empty_files" {
  command = plan

  variables {
    secret_mapping = []
  }

  assert {
    condition = length(data.sops_file.sops_secrets) == 0
    error_message = "Should create no data resources when no files are needed"
  }
}

run "test_data_resource_for_each_behavior" {
  command = plan

  variables {
    secret_mapping = [
      {
        name = "secret1"
        type = "sops"
        file = "file1.yaml"
      },
      {
        name = "secret2"
        type = "sops"
        file = "file2.yaml"
      },
      {
        name = "secret3"
        type = "sops"
        file = "file3.yaml"
      }
    ]
  }

  assert {
    condition = length(data.sops_file.sops_secrets) == 3
    error_message = "Should create 3 data resources for 3 unique files"
  }

  assert {
    condition = length(distinct(keys(data.sops_file.sops_secrets))) == length(keys(data.sops_file.sops_secrets))
    error_message = "All data resource keys should be unique"
  }

  assert {
    condition = alltrue([
      for key, resource in data.sops_file.sops_secrets :
      resource.source_file == "${path.root}/${key}"
    ])
    error_message = "All data resources should have correctly constructed source_file paths"
  }
}
