# Terraform マルチクラウド試作（AWS / GCP / Azure / OCI）

『育てるTerraform』第19章のための、マルチクラウド最小リファレンスです。

## これは何か

4クラウドで **同じ入力・同じ出力** を持つ最小基盤を作り、Terraform の共通化と差分を確かめます。

- 対象: ネットワーク、サブネット、オブジェクトストレージ、共通出力
- 対象外: アプリ実行基盤、ロードバランサー、マネージド PostgreSQL、Secrets、監視、CI/CD
- 実 AWS / GCP / Azure / OCI への `apply` は未実行です。検証済みの範囲は [`docs/verification.md`](docs/verification.md) を参照してください。

書籍本体の実装は `codes/terraform-infra` にあり、この試作は独立したフォルダで管理します。既存のモジュールや環境には手を加えません。

## 構成

```text
terraform-infra-multicloud/
├── modules/
│   ├── aws/foundation/
│   ├── gcp/foundation/
│   ├── azure/foundation/
│   └── oci/foundation/
├── envs/
│   ├── aws/dev/
│   ├── gcp/dev/
│   ├── azure/dev/
│   └── oci/dev/
├── shared/contract.md
├── docs/
│   ├── portability-matrix.md
│   └── verification.md
└── scripts/
    ├── check.sh
    └── check_contract.py
```

各 `foundation` モジュールは、次の共通出力を返します。

```text
cloud, region, network_id, network_name, subnet_id, subnet_name,
bucket_name, bucket_id, storage_endpoint
```

## 使う

### 1. 静的検証（クラウド認証不要）

```bash
cd codes/terraform-infra-multicloud
terraform fmt -check -recursive
./scripts/check.sh
```

`scripts/check.sh` は4モジュールと4環境に対して、`init -backend=false`、`validate`、`test` を実行します。`test` は `mock_provider` を使うため、クラウド API を呼びません。あわせて `scripts/check_contract.py` で、4モジュールが共通の入力名・出力名を持っているかを確認します。

### 2. 実際に plan / apply する場合

クラウドごとに認証を設定し、`terraform.tfvars.example` をコピーして値を変えます。

```bash
cd envs/aws/dev
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
```

GCP は `gcloud auth application-default login`、Azure は `az login`、OCI は `~/.oci/config` など、各プロバイダーの認証が必要です。OCI は `compartment_id` を実値に置き換えてください。

> **注意:** `bucket_name` は世界で一意にしてください。Azure のストレージアカウント名は `bucket_name` から自動生成されるため、他クラウドと同じ名前を使い回すと衝突する可能性があります。検証後は `terraform destroy` で削除してください。

## 4クラウドの差分

詳細は [`docs/portability-matrix.md`](docs/portability-matrix.md) にまとめています。要点は次のとおりです。

- ネットワーク: VPC / VPC / VNet / VCN
- ストレージ: S3 / Cloud Storage / Blob Storage / Object Storage
- タグ: `tags` / `labels` / `tags` / `freeform_tags`
- ゾーン: AZ / zone / Availability Zone / Availability Domain
- 認証: IAM / サービスアカウント / Entra ID + RBAC / IAM ポリシー

## 共通化の考え方

共通化するのは、入力・出力・タグ・命名・環境分離のルールです。プロバイダー、リソース型、IAM、マネージドサービスの機能差は共通化しません。

```hcl
module "foundation" {
  source = "../../../modules/gcp/foundation"

  project     = var.project
  environment = var.environment
  region      = var.region
  bucket_name = var.bucket_name
  tags        = var.tags
}
```

AWS / Azure / OCI も同じ変数名・同じ出力名です。`source` だけが変わります。Terraform は module source を動的に切り替えられないため、ルート設定はクラウドごとに分けます。

## 書籍との関係

- 第19章: 4クラウドの比較、共通化パターン、この試作の説明
- 本書本体: AWS の VPC、ALB、ECS Fargate、Aurora、S3、Secrets Manager、CloudWatch
- この試作: 上記のうち、ネットワークとオブジェクトストレージだけを4クラウドに移植

アプリ実行基盤・DB・監視まで含む完全版は、各クラウドのマネージドサービスに合わせてモジュールを追加します。試作の段階で「共通契約が成立するか」を先に確かめるのが目的です。
