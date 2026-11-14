locals {
  name = "${var.project}-${var.environment}"

  labels = merge(
    { for key, value in var.tags : lower(key) => lower(value) },
    {
      project     = lower(var.project)
      environment = lower(var.environment)
      managed_by  = "terraform"
      cloud       = "gcp"
    }
  )
}

resource "google_compute_network" "this" {
  name                    = "vpc-${local.name}"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "this" {
  name          = "snet-${local.name}"
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.this.id
}

resource "google_storage_bucket" "this" {
  name                        = var.bucket_name
  location                    = var.region
  force_destroy               = true
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  versioning {
    enabled = true
  }

  labels = local.labels
}
