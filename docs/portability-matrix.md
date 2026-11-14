# 4クラウド比較と移植の差分

対象は AWS / GCP / Azure / Oracle Cloud Infrastructure（OCI）です。Terraform は複数プロバイダーを扱えますが、**同じ HCL をそのまま4クラウドに適用することはできません**。ここでは、どの层が同じで、どこが変わるかを整理します。

## 1. 役割ごとの対応表

| 役割 | AWS | GCP | Azure | OCI |
| --- | --- | --- | --- | --- |
| Terraform プロバイダー | `hashicorp/aws` | `hashicorp/google` | `hashicorp/azurerm` | `oracle/oci` |
| 仮想ネットワーク | VPC | VPC ネットワーク | Virtual Network (VNet) | Virtual Cloud Network (VCN) |
| サブネット | Subnet | Subnet | Subnet | Subnet |
| インターネット出口 | Internet Gateway / NAT Gateway | Cloud NAT | NAT Gateway | Internet Gateway / NAT Gateway |
| ファイアウォール | Security Group / NACL | VPC ファイアウォール ルール | Network Security Group (NSG) | Security List / NSG |
| ロードバランサー | ALB / NLB | Cloud Load Balancing | Application Gateway / Load Balancer | Load Balancer / Network Load Balancer |
| コンテナ実行 | ECS Fargate / EKS | Cloud Run / GKE | Container Apps / AKS | Container Instances / OKE |
| PostgreSQL | Aurora PostgreSQL / RDS | Cloud SQL / AlloyDB | Database for PostgreSQL Flexible Server | Database with PostgreSQL / VM 上の PostgreSQL |
| オブジェクトストレージ | S3 | Cloud Storage | Blob Storage | Object Storage |
| シークレット | Secrets Manager | Secret Manager | Key Vault | Vault |
| 監視・ログ | CloudWatch | Cloud Monitoring / Cloud Logging | Azure Monitor / Log Analytics | Monitoring / Logging |
| コンテナレジストリ | ECR | Artifact Registry | Container Registry (ACR) | Container Registry (OCIR) |
| IAM | IAM ロール / ポリシー | サービスアカウント / IAM | Microsoft Entra ID + Azure RBAC | IAM ポリシー / 動的グループ |
| タグ | `tags` | `labels` | `tags` | `freeform_tags` / `defined_tags` |
| 可用性単位 | Availability Zone | zone | Availability Zone | Availability Domain / Fault Domain |

## 2. 同じに見えて違うもの

### 2.1 ネットワーク

AWS の VPC は、VPC の中にサブネット、ルートテーブル、Security Group を置きます。GCP は VPC ネットワークとサブネットがリージョン資源で、ファイアウォールルールはネットワーク単位です。Azure は VNet とサブネットをリソースグループ内に置き、NSG をサブネットまたは NIC に付けます。OCI は VCN とサブネットをコンパートメント内に置き、Security List と NSG を使います。

```hcl
# AWS
resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"
}

# GCP
resource "google_compute_network" "this" {
  name                    = "vpc-expense-portal-dev"
  auto_create_subnetworks = false
}

# Azure
resource "azurerm_virtual_network" "this" {
  name          = "vnet-expense-portal-dev"
  address_space = ["10.0.0.0/16"]
}

# OCI
resource "oci_core_vcn" "this" {
  compartment_id = var.compartment_id
  cidr_blocks    = ["10.0.0.0/16"]
  display_name   = "vcn-expense-portal-dev"
}
```

CIDR の考え方は共通ですが、リソースの親子関係、必須引数、命名制約は異なります。

### 2.2 タグとラベル

AWS と Azure は `tags`、GCP は `labels`、OCI は `freeform_tags` です。GCP のラベルはキーも値も小文字に正規化する必要があります。Azure のタグは大文字小文字を保持しますが、コスト配分の集計では大文字小文字の揺れが問題になります。

```hcl
# GCP は小文字化して渡す
labels = {
  project     = "expense-portal"
  environment = "dev"
  managed_by  = "terraform"
}
```

共通契約では「タグの意味」をそろえ、**キーの表記はクラウド別に変換する**のが現実的です。

### 2.3 オブジェクトストレージ

S3、Cloud Storage、Blob Storage、Object Storage は、どれも「バケットにオブジェクトを置く」という概念は同じです。しかし、次の点が違います。

- バケット名の一意性: S3 と GCS は世界で一意。Azure のストレージアカウント名も世界で一意。OCI はネームスペース内で一意。
- Azure のストレージアカウント名は 3〜24 文字の小文字英数字のみ。ハイフンも使えない。
- Azure は「ストレージアカウント」と「コンテナ」の2層。S3 / GCS / OCI はバケット1層に近い。
- 署名付き URL の方式が違う。AWS SDK の S3 署名をそのまま Azure Blob には使えない。
- GCS は S3 互換の XML API を一部提供するが、完全互換ではない。OCI Object Storage も S3 互換 API を持つが、IAM と署名の扱いは同じではない。

このため、アプリ側は「StorageProvider」のような薄いインターフェースを置き、クラウド別の実装を差し替えるのが安全です。

### 2.4 マネージド PostgreSQL

本書の AWS 版は Aurora PostgreSQL の Writer / Reader を使い、Reader の台数を Auto Scaling します。これは Aurora 固有の設計です。

- GCP の Cloud SQL for PostgreSQL はリードレプリカを作れますが、Aurora の Reader Auto Scaling と同じ自動台数制御ではありません。AlloyDB を使う場合は read pool の設計が別になります。
- Azure Database for PostgreSQL Flexible Server はリードレプリカを作れますが、レプリカ台数の自動スケールは Aurora と同一ではありません。
- OCI Database with PostgreSQL はマネージド PostgreSQL を提供しますが、リードレプリカや自動スケールの提供範囲は契約・バージョンで確認が必要です。

共通契約では、次の2つの出力を用意します。

```hcl
output "db_writer_endpoint" { ... }
output "db_reader_endpoint" { ... }
```

Reader を持たないクラウドでは、`db_reader_endpoint` に Writer と同じ値を入れるか、アプリ側で Writer にフォールバックします。**「Reader がある」という前提を共通契約にしない**のがポイントです。

### 2.5 コンテナ実行基盤

AWS の ECS は、クラスタ、タスク定義、サービス、ターゲットグループ、ロールを組み合わせます。GCP の Cloud Run はサービスとリビジョン、Azure Container Apps は環境とアプリ、OCI Container Instances はコンテナインスタンスです。同じ「コンテナを動かす」でも、デプロイ単位、ヘルスチェック、スケール、IAM の考え方が違います。

共通化できるのは「イメージ、ポート、環境変数、CPU / メモリ、最小 / 最大台数」といったアプリ寄りの入力です。VPC 接続、ログ出力、シークレット注入、ロールの付け方はクラウド別モジュールに残します。

### 2.6 IAM と認証

AWS は IAM ロール、GCP はサービスアカウント、Azure は Entra ID のマネージド ID と RBAC、OCI は IAM ポリシーと動的グループです。Terraform のリソース名も権限の書き方も違います。

「アプリが S3 を読める」という同じ要件でも、AWS はタスクロールのポリシー、GCP はサービスアカウントへの `roles/storage.objectViewer`、Azure はストレージアカウントの RBAC ロール割り当て、OCI は動的グループとポリシーになります。ここを1つのモジュールで抽象化すると、かえって読みにくくなります。

## 3. 共通化できるもの・できないもの

| 層 | 共通化 | 理由 |
| --- | --- | --- |
| 変数名・出力名 | できる | ルートモジュールとアプリの接続をそろえられる |
| タグの意味 | できる | 表記はクラウド別に変換する |
| 命名規則 | 一部できる | 文字種・長さ・一意性の制約が違う |
| 環境分離 | できる | `envs/<cloud>/<env>` で分ける |
| state 管理 | 分ける | クラウドごとに state を分離する |
| ネットワーク | できない | リソースの親子関係と必須引数が違う |
| IAM | できない | 権限モデルが違う |
| DB のスケール | できない | Aurora 固有の Reader Auto Scaling などがある |
| コンテナ実行 | 一部できる | アプリ入力は共通化できるが、実行資源は別 |
| 監視 | 一部できる | メトリクス名・ログの構造が違う |

## 4. 共通化の実装パターン

### 4.1 クラウド別モジュール + 共通契約

```text
envs/aws/dev   ──> modules/aws/foundation
envs/gcp/dev   ──> modules/gcp/foundation
envs/azure/dev ──> modules/azure/foundation
envs/oci/dev   ──> modules/oci/foundation
```

4つの `foundation` は、同じ変数名と同じ出力名を持ちます。ルート設定はクラウドごとに分けます。Terraform は module source を動的に切り替えられないため、1つのルートで `if cloud == ...` と書くのではなく、環境ディレクトリを分けるのが正解です。

### 4.2 共通契約の例

```hcl
# どのクラウドでも同じ形
module "foundation" {
  source = "../../../modules/<cloud>/foundation"

  project      = var.project
  environment  = var.environment
  region       = var.region
  bucket_name  = var.bucket_name
  network_cidr = var.network_cidr
  subnet_cidr  = var.subnet_cidr
  tags         = var.tags
}
```

クラウド固有の入力は、共通契約の外に置きます。

- OCI: `compartment_id`
- Azure: ストレージアカウント名の生成
- GCP: `project` がプロジェクト ID

### 4.3 避けたい設計

- 1つの巨大モジュールで、全クラウドのリソースを `count` で切り替える。
- `provider` を動的に切り替える。
- すべてのクラウドを同じネットワーク構成に無理やり合わせる。
- 共通化のために、クラウド固有のセキュリティ機能を無効にする。
- 1つの state に4クラウドを混ぜる。

## 5. 試作の範囲

`codes/terraform-infra-multicloud` では、次の範囲だけを4クラウドで実装しています。

- 仮想ネットワークとサブネット
- オブジェクトストレージ
- 共通のタグ / ラベル
- 共通の出力

アプリ実行基盤、DB、LB、Secrets、監視は、差分が大きいため試作の対象外です。まず「共通契約が成立するか」を確認し、その上でクラウド別に厚みを足す順序にします。

## 6. 無料枠で試すときの注意

4クラウドの無料枠は、マネージド LB、マネージド DB、コンテナサービスをすべてカバーするわけではありません。無料で試すなら、次の順序が現実的です。

1. この試作を `terraform validate` と `terraform test` で検証する（クラウド認証不要）。
2. 1クラウドずつ、無料枠の範囲で `apply` する。バケットとネットワークだけなら課金は小さい。
3. アプリ実行基盤と DB は、無料 VM 上の Docker / PostgreSQL など、別の構成で試す。
4. マネージドサービスを使う場合は、クラウドごとに予算アラートと削除手順を先に決める。

無料枠は改定されるため、契約前に各クラウドの最新条件を確認してください。
