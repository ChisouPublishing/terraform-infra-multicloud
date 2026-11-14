module "foundation" {
  source = "../../../modules/gcp/foundation"

  project      = var.project
  environment  = var.environment
  region       = var.region
  bucket_name  = var.bucket_name
  network_cidr = var.network_cidr
  subnet_cidr  = var.subnet_cidr
  tags         = var.tags
}
