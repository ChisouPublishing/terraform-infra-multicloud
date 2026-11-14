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
  description = "OCI リージョン。"
  type        = string
  default     = "ap-tokyo-1"
}

variable "bucket_name" {
  description = "Object Storage バケット名。"
  type        = string
  default     = "expenseportal-mc-dev-2026"
}

variable "compartment_id" {
  description = "OCI のコンパートメント OCID。"
  type        = string
  default     = "ocid1.compartment.oc1..example"
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
  description = "共通タグ。"
  type        = map(string)
  default = {
    Owner = "platform-team"
  }
}
