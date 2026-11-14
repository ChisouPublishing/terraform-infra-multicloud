# マルチクラウド試作の検証記録

- 最終更新: 2026-10-23
- Terraform: v1.17.0（Homebrew `hashicorp/tap`）
- 対象: `codes/terraform-infra-multicloud`

## 実行済み

次のコマンドを実行しました。

```bash
cd codes/terraform-infra-multicloud
terraform fmt -recursive
./scripts/check.sh
```

`scripts/check.sh` は各クラウドの module と env に対して、`terraform init -backend=false`、`terraform fmt -check`、`terraform validate` を実行し、module では `terraform test` も実行します。

あわせて `scripts/check_contract.py` で、4つの `foundation` モジュールが共通の入力名・出力名を持っているかを確認します。

### 結果

| 対象 | `validate` | `terraform test` |
| --- | --- | --- |
| AWS module | 成功 | 1 passed / 0 failed |
| GCP module | 成功 | 1 passed / 0 failed |
| Azure module | 成功 | 1 passed / 0 failed |
| OCI module | 成功 | 1 passed / 0 failed |
| AWS env | 成功 | 対象外 |
| GCP env | 成功 | 対象外 |
| Azure env | 成功 | 対象外 |
| OCI env | 成功 | 対象外 |

共通契約チェックは4クラウドすべてで `inputs: OK` / `outputs: OK` でした。

`terraform test` は `mock_provider` を使い、実際のクラウド API は呼んでいません。各テストは、共通出力 `cloud`、`bucket_name`、`storage_endpoint` が期待どおりになることを確認します。

### 固定したプロバイダー

`terraform init` で取得したバージョンは次のとおりです。

| クラウド | プロバイダー | バージョン |
| --- | --- | --- |
| AWS | `hashicorp/aws` | 6.70.0 |
| GCP | `hashicorp/google` | 7.46.1 |
| Azure | `hashicorp/azurerm` | 5.10.0 |
| OCI | `oracle/oci` | 7.32.0 |

Azure プロバイダー 5.x では `azurerm_storage_container` が `storage_account_id` を要求するため、試作もその引数に合わせています。

## 未実行

次の項目は、クラウドアカウントと認証が必要なため実行していません。

- AWS / GCP / Azure / OCI への `terraform plan` と `terraform apply`
- 実際の VPC / VNet / VCN とサブネットの作成
- S3 / Cloud Storage / Blob Storage / Object Storage へのオブジェクト投入
- Azure のストレージアカウント名の世界一意性の確認
- OCI のコンパートメント OCID とネームスペースの確認
- 4クラウド間のネットワーク接続、IAM、監視、課金の確認
- アプリ実行基盤、マネージド PostgreSQL、ロードバランサー、Secrets の構築
- `terraform destroy` による後片付け

## 試作の位置づけ

この試作は、4クラウドで **共通契約が成立するか** を確かめる最小リファレンスです。アプリ全体の移植ではありません。書籍本文では、この検証済みの範囲と、未検証の範囲を分けて説明します。
