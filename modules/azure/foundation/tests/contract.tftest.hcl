mock_provider "azurerm" {}

run "contract" {
  command = plan

  variables {
    project     = "expense-portal"
    environment = "dev"
    region      = "japaneast"
    bucket_name = "expenseportal-mc-dev-2026"
    tags = {
      Owner = "platform-team"
    }
  }

  assert {
    condition     = output.cloud == "azure"
    error_message = "cloud output must be azure"
  }

  assert {
    condition     = output.bucket_name == "expenseportal-mc-dev-2026"
    error_message = "bucket_name output must be the container name"
  }

  assert {
    condition     = output.storage_endpoint == "https://expenseportalmcdev2026.blob.core.windows.net/expenseportal-mc-dev-2026"
    error_message = "storage_endpoint must be the Blob container HTTPS endpoint"
  }
}
