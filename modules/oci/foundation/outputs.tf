output "cloud" {
  description = "クラウド識別子。共通契約の確認に使う。"
  value       = "oci"
}

output "region" {
  description = "作成先リージョン。"
  value       = var.region
}

output "network_id" {
  description = "VCN の OCID。"
  value       = oci_core_vcn.this.id
}

output "network_name" {
  description = "VCN の表示名。"
  value       = oci_core_vcn.this.display_name
}

output "subnet_id" {
  description = "サブネットの OCID。"
  value       = oci_core_subnet.this.id
}

output "subnet_name" {
  description = "サブネットの表示名。"
  value       = oci_core_subnet.this.display_name
}

output "bucket_name" {
  description = "Object Storage バケット名。"
  value       = oci_objectstorage_bucket.this.name
}

output "bucket_id" {
  description = "Object Storage バケット名（OCI では名前が識別子）。"
  value       = oci_objectstorage_bucket.this.name
}

output "storage_endpoint" {
  description = "アプリから使う Object Storage の HTTPS エンドポイント。"
  value       = "https://objectstorage.${var.region}.oraclecloud.com/n/${data.oci_objectstorage_namespace.this.namespace}/b/${oci_objectstorage_bucket.this.name}/o"
}

output "compartment_id" {
  description = "OCI のコンパートメント OCID（OCI 固有）。"
  value       = var.compartment_id
}
