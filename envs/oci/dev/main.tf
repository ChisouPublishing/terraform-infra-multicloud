module "foundation" {
  source = "../../../modules/oci/foundation"

  project        = var.project
  environment    = var.environment
  region         = var.region
  bucket_name    = var.bucket_name
  compartment_id = var.compartment_id
  network_cidr   = var.network_cidr
  subnet_cidr    = var.subnet_cidr
  tags           = var.tags
}
