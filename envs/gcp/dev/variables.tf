variable "project" {
  description = "GCP のプロジェクト ID。"
  type        = string
  default     = "your-gcp-project"
}

variable "environment" {
  description = "環境名。"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "GCP リージョン。"
  type        = string
  default     = "asia-northeast1"
}

variable "bucket_name" {
  description = "Cloud Storage バケット名。世界で一意にする。"
  type        = string
  default     = "expenseportal-mc-dev-2026"
}

variable "network_cidr" {
  description = "VPC ネットワークの CIDR。"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "サブネットの CIDR。"
  type        = string
  default     = "10.0.1.0/24"
}

variable "tags" {
  description = "共通ラベル。"
  type        = map(string)
  default = {
    Owner = "platform-team"
  }
}
