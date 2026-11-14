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
  description = "AWS リージョン。"
  type        = string
  default     = "ap-northeast-1"
}

variable "bucket_name" {
  description = "S3 バケット名。世界で一意にする。"
  type        = string
  default     = "expenseportal-mc-dev-2026"
}

variable "network_cidr" {
  description = "VPC の CIDR。"
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
