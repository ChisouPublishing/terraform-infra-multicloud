#!/usr/bin/env bash
# 4クラウドの foundation モジュールと env を、クラウド認証なしで検証する。
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLOUDS=(aws gcp azure oci)

cd "$ROOT"

echo ">>> terraform fmt -check -recursive"
terraform fmt -check -recursive

echo ""
echo ">>> contract: common inputs/outputs"
python3 "$ROOT/scripts/check_contract.py"

for cloud in "${CLOUDS[@]}"; do
  echo ""
  echo ">>> ${cloud}: module"
  (
    cd "$ROOT/modules/${cloud}/foundation"
    terraform init -backend=false -input=false >/dev/null
    terraform fmt -check
    terraform validate
    terraform test
  )

  echo ""
  echo ">>> ${cloud}: env"
  (
    cd "$ROOT/envs/${cloud}/dev"
    terraform init -backend=false -input=false >/dev/null
    terraform fmt -check
    terraform validate
  )
done

echo ""
echo "すべての静的検証が完了しました。"
