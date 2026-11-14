variable "project" {
  description = "プロジェクト名。リソース名の共通接頭辞に使う。"
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
  description = "OCI リージョン。"
  type        = string
}

variable "bucket_name" {
  description = "Object Storage バケット名。"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "bucket_name は3〜63文字の小文字英数字とハイフンで指定してください。"
  }
}

variable "compartment_id" {
  description = "OCI のコンパートメント OCID。OCI だけが必須にするクラウド固有の入力。"
  type        = string
}

variable "network_cidr" {
  description = "VCN の CIDR。"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "サブネットの CIDR。"
  type        = string
  default     = "10.0.1.0/24"
}

variable "tags" {
  description = "共通タグ。OCI の freeform_tags に渡す。"
  type        = map(string)
  default     = {}
}
