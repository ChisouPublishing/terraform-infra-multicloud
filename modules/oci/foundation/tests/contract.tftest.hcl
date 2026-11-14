mock_provider "oci" {
  mock_data "oci_objectstorage_namespace" {
    defaults = {
      namespace = "testnamespace"
    }
  }
}

run "contract" {
  command = plan

  variables {
    project        = "expense-portal"
    environment    = "dev"
    region         = "ap-tokyo-1"
    bucket_name    = "expenseportal-mc-dev-2026"
    compartment_id = "ocid1.compartment.oc1..example"
    tags = {
      Owner = "platform-team"
    }
  }

  assert {
    condition     = output.cloud == "oci"
    error_message = "cloud output must be oci"
  }

  assert {
    condition     = output.bucket_name == "expenseportal-mc-dev-2026"
    error_message = "bucket_name output must match the input"
  }

  assert {
    condition     = output.storage_endpoint == "https://objectstorage.ap-tokyo-1.oraclecloud.com/n/testnamespace/b/expenseportal-mc-dev-2026/o"
    error_message = "storage_endpoint must be the Object Storage HTTPS endpoint"
  }
}
