output "cloud" {
  description = "クラウド識別子。共通契約の確認に使う。"
  value       = "gcp"
}

output "region" {
  description = "作成先リージョン。"
  value       = var.region
}

output "network_id" {
  description = "VPC ネットワークの ID。"
  value       = google_compute_network.this.id
}

output "network_name" {
  description = "VPC ネットワークの名前。"
  value       = google_compute_network.this.name
}

output "subnet_id" {
  description = "サブネットの ID。"
  value       = google_compute_subnetwork.this.id
}

output "subnet_name" {
  description = "サブネットの名前。"
  value       = google_compute_subnetwork.this.name
}

output "bucket_name" {
  description = "Cloud Storage バケット名。"
  value       = google_storage_bucket.this.name
}

output "bucket_id" {
  description = "Cloud Storage バケットの ID。"
  value       = google_storage_bucket.this.id
}

output "storage_endpoint" {
  description = "アプリから使う Cloud Storage の HTTPS エンドポイント。"
  value       = "https://storage.googleapis.com/${google_storage_bucket.this.name}"
}
