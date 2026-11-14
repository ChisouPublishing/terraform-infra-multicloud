variable "project" {
  description = "GCP のプロジェクト ID。リソース名にも使う。"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,30}$", var.project))
    error_message = "project は小文字英数字とハイフンで指定してください。"
  }
}

variable "environment" {
  description = "環境名（dev / stg / prod など）。"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,15}$", var.environment))
    error_message = "environment は小文字英数字とハイフンで指定してください。"
  }
}

variable "region" {
  description = "GCP リージョン。"
  type        = string
}

variable "bucket_name" {
  description = "Cloud Storage バケット名。世界で一意にする。"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "bucket_name は3〜63文字の小文字英数字とハイフンで指定してください。"
  }
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
  description = "共通ラベル。GCP の制約に合わせて小文字化する。"
  type        = map(string)
  default     = {}
}
