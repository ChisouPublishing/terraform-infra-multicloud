mock_provider "aws" {}

run "contract" {
  command = plan

  variables {
    project     = "expense-portal"
    environment = "dev"
    region      = "ap-northeast-1"
    bucket_name = "expenseportal-mc-dev-2026"
    tags = {
      Owner = "platform-team"
    }
  }

  assert {
    condition     = output.cloud == "aws"
    error_message = "cloud output must be aws"
  }

  assert {
    condition     = output.bucket_name == "expenseportal-mc-dev-2026"
    error_message = "bucket_name output must match the input"
  }

  assert {
    condition     = output.storage_endpoint == "https://expenseportal-mc-dev-2026.s3.ap-northeast-1.amazonaws.com"
    error_message = "storage_endpoint must be the S3 HTTPS endpoint"
  }
}
