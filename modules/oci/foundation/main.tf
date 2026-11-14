locals {
  name = "${var.project}-${var.environment}"

  tags = merge(var.tags, {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
    Cloud       = "oci"
  })

  # OCI の DNS ラベルは英数字のみ・15文字以内・先頭は英字。
  dns_prefix = substr(replace(lower("${var.project}${var.environment}"), "/[^a-z0-9]/", ""), 0, 10)
}

data "oci_objectstorage_namespace" "this" {
  compartment_id = var.compartment_id
}

resource "oci_core_vcn" "this" {
  compartment_id = var.compartment_id
  cidr_blocks    = [var.network_cidr]
  display_name   = "vcn-${local.name}"
  dns_label      = "vcn${local.dns_prefix}"
  freeform_tags  = local.tags
}

resource "oci_core_subnet" "this" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  cidr_block     = var.subnet_cidr
  display_name   = "snet-${local.name}"
  dns_label      = "snet${local.dns_prefix}"
  freeform_tags  = local.tags
}

resource "oci_objectstorage_bucket" "this" {
  compartment_id = var.compartment_id
  namespace      = data.oci_objectstorage_namespace.this.namespace
  name           = var.bucket_name
  access_type    = "NoPublicAccess"
  storage_tier   = "Standard"
  versioning     = "Enabled"
  freeform_tags  = local.tags
}
