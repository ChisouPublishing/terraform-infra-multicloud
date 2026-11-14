mock_provider "google" {}

run "contract" {
  command = plan

  variables {
    project     = "expense-portal"
    environment = "dev"
    region      = "asia-northeast1"
    bucket_name = "expenseportal-mc-dev-2026"
    tags = {
      Owner = "platform-team"
    }
  }

  assert {
    condition     = output.cloud == "gcp"
    error_message = "cloud output must be gcp"
  }

  assert {
    condition     = output.bucket_name == "expenseportal-mc-dev-2026"
    error_message = "bucket_name output must match the input"
  }

  assert {
    condition     = output.storage_endpoint == "https://storage.googleapis.com/expenseportal-mc-dev-2026"
    error_message = "storage_endpoint must be the Cloud Storage HTTPS endpoint"
  }
}
