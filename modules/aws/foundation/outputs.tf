output "cloud" {
  description = "クラウド識別子。共通契約の確認に使う。"
  value       = "aws"
}

output "region" {
  description = "作成先リージョン。"
  value       = var.region
}

output "network_id" {
  description = "VPC の ID。"
  value       = aws_vpc.this.id
}

output "network_name" {
  description = "VPC の名前。"
  value       = "vpc-${local.name}"
}

output "subnet_id" {
  description = "サブネットの ID。"
  value       = aws_subnet.this.id
}

output "subnet_name" {
  description = "サブネットの名前。"
  value       = "snet-${local.name}"
}

output "bucket_name" {
  description = "S3 バケット名。"
  value       = aws_s3_bucket.this.bucket
}

output "bucket_id" {
  description = "S3 バケットの ID。"
  value       = aws_s3_bucket.this.id
}

output "storage_endpoint" {
  description = "アプリから使う S3 の HTTPS エンドポイント。"
  value       = "https://${aws_s3_bucket.this.bucket}.s3.${var.region}.amazonaws.com"
}
