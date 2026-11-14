variable "project" {
  description = "プロジェクト名。"
  type        = string
  default     = "expense-portal"
}

variable "environment" {
  description = "環境名。"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "Azure のリージョン（location）。"
  type        = string
  default     = "japaneast"
}

variable "bucket_name" {
  description = "Blob コンテナ名。ストレージアカウント名の元にもなる。"
  type        = string
  default     = "expenseportal-mc-dev-2026"
}

variable "network_cidr" {
  description = "VNet の CIDR。"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "サブネットの CIDR。"
  type        = string
  default     = "10.0.1.0/24"
}

variable "tags" {
  description = "共通タグ。"
  type        = map(string)
  default = {
    Owner = "platform-team"
  }
}
