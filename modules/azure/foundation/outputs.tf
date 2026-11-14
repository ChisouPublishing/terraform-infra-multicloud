output "cloud" {
  description = "クラウド識別子。共通契約の確認に使う。"
  value       = "azure"
}

output "region" {
  description = "作成先リージョン。"
  value       = var.region
}

output "network_id" {
  description = "VNet の ID。"
  value       = azurerm_virtual_network.this.id
}

output "network_name" {
  description = "VNet の名前。"
  value       = azurerm_virtual_network.this.name
}

output "subnet_id" {
  description = "サブネットの ID。"
  value       = azurerm_subnet.this.id
}

output "subnet_name" {
  description = "サブネットの名前。"
  value       = azurerm_subnet.this.name
}

output "bucket_name" {
  description = "Blob コンテナ名。"
  value       = azurerm_storage_container.this.name
}

output "bucket_id" {
  description = "Blob コンテナの ID。"
  value       = azurerm_storage_container.this.id
}

output "storage_endpoint" {
  description = "アプリから使う Blob コンテナの HTTPS エンドポイント。"
  value       = "https://${local.storage_account_name}.blob.core.windows.net/${local.container_name}"
}

output "storage_account_name" {
  description = "Azure のストレージアカウント名（Azure 固有）。"
  value       = azurerm_storage_account.this.name
}

output "resource_group_name" {
  description = "Azure のリソースグループ名（Azure 固有）。"
  value       = azurerm_resource_group.this.name
}
