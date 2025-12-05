mock_provider "sops" {
  mock_data "sops_file" {
    defaults = {
      raw = "db_password: supersecret123\napi_key: test-api-key-456\nredis_password: redis-secret-789"
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

run "test_output_structure_and_content" {
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
      }
    ]
  }

  assert {
    condition     = output.all["db_password"] == "supersecret123"
    error_message = "db_password should have the expected value from mocked SOPS data"
  }

  assert {
    condition     = output.all["api_key"] == "test-api-key-456"
    error_message = "api_key should have the expected value from mocked SOPS data"
  }

  assert {
    condition     = !contains(keys(output.all), "redis_password")
    error_message = "redis_password should not be in the output"
  }

  assert {
    condition     = length(output.all) == 2
    error_message = "Output should contain exactly 2 secrets"
  }
}

run "test_output_empty_secrets" {
  command = plan

  variables {
    secret_mapping = []
  }

  assert {
    condition     = length(output.all) == 0
    error_message = "Output should be empty when no secrets are configured"
  }

  assert {
    condition     = output.all == {}
    error_message = "Output should be an empty map when no secrets are configured"
  }
}
