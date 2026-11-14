# マルチクラウド共通契約 v0.1

このフォルダは、AWS・GCP・Azure・OCI の4クラウドで **同じ入力・同じ出力** を持つ最小基盤を試作するためのものです。書籍本体の `codes/terraform-infra` は変更しません。

## 目的

- クラウドごとにプロバイダーとリソース型が違うことを、実際の HCL で確認する。
- 「共通契約」を決めれば、ルートモジュールとアプリの接続部分をそろえられることを確認する。
- 共通化してよい部分と、クラウド固有のまま残す部分を切り分ける。

## 共通入力

| 変数 | 型 | 意味 | 補足 |
| --- | --- | --- | --- |
| `project` | string | プロジェクト名 | GCP ではプロジェクト ID を兼ねる |
| `environment` | string | 環境名 | `dev` / `stg` / `prod` |
| `region` | string | リージョン | Azure では `location` として使う |
| `bucket_name` | string | オブジェクトストレージ名 | 世界で一意にする。Azure はコンテナ名 |
| `network_cidr` | string | ネットワーク CIDR | 既定 `10.0.0.0/16` |
| `subnet_cidr` | string | サブネット CIDR | 既定 `10.0.1.0/24` |
| `tags` | map(string) | 共通タグ | GCP では小文字ラベルに変換する |

クラウド固有の入力は、共通契約の外に置きます。

- OCI: `compartment_id`
- Azure: ストレージアカウント名は `bucket_name` から生成する（Azure の命名制約のため）
- GCP: `project` が GCP のプロジェクト ID になる

## 共通出力

| 出力 | 型 | 意味 |
| --- | --- | --- |
| `cloud` | string | `aws` / `gcp` / `azure` / `oci` |
| `region` | string | 作成先リージョン |
| `network_id` | string | VPC / VCN / VNet の ID |
| `network_name` | string | ネットワーク名 |
| `subnet_id` | string | サブネット ID |
| `subnet_name` | string | サブネット名 |
| `bucket_name` | string | バケット / コンテナ名 |
| `bucket_id` | string | ストレージの ID |
| `storage_endpoint` | string | アプリが参照する HTTPS エンドポイント |

Azure だけは `storage_account_name` と `resource_group_name` を追加で出力します。OCI は `compartment_id` を追加で出力します。共通契約にない出力は、クラウド固有の実装詳細として扱います。

## 命名とタグのルール

- AWS / GCP / OCI のバケット名は、世界またはネームスペース内で一意にする。
- Azure のストレージアカウント名は 3〜24 文字の小文字英数字のみ。`bucket_name` から記号を除いて生成する。
- GCP のラベルは小文字のみ。共通の `tags` を小文字化して渡す。
- OCI の DNS ラベルは 15 文字以内、先頭は英字。プロジェクト名から生成する。
- タグのキー名はクラウドごとに揺れる。`Project` / `Environment` / `ManagedBy` / `Cloud` を共通の意味としてそろえる。

## 状態管理

この試作はローカル state です。実際に複数クラウドへ適用する場合は、クラウドごとに state を分けます。

```text
envs/aws/dev/terraform.tfstate
envs/gcp/dev/terraform.tfstate
envs/azure/dev/terraform.tfstate
envs/oci/dev/terraform.tfstate
```

HCP Terraform を使う場合も、クラウドごとに workspace を分けます。1つの state に複数クラウドのリソースを混ぜません。

## 共通化の境界

共通化するのは、次の3つです。

1. **入力と出力の名前**
2. **アプリが参照する接続情報の形**
3. **タグ、命名、環境分離のルール**

共通化しないのは、次の3つです。

1. プロバイダーとリソース型
2. IAM と認証
3. マネージドサービスの機能差（Reader、LB、コンテナ、監視など）

「同じ HCL ファイルを4クラウドに適用する」のではなく、**同じ契約を満たすクラウド別モジュールを4つ持つ**のがこの試作の立場です。
