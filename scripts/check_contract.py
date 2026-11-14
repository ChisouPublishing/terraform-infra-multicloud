#!/usr/bin/env python3
"""4クラウドの foundation モジュールが共通契約を満たすか確認する。"""

from __future__ import annotations

import re
import sys
from pathlib import Path

COMMON_INPUTS = {
    "project",
    "environment",
    "region",
    "bucket_name",
    "network_cidr",
    "subnet_cidr",
    "tags",
}
COMMON_OUTPUTS = {
    "cloud",
    "region",
    "network_id",
    "network_name",
    "subnet_id",
    "subnet_name",
    "bucket_name",
    "bucket_id",
    "storage_endpoint",
}
CLOUDS = ("aws", "gcp", "azure", "oci")


def names(path: Path, kind: str) -> set[str]:
    text = path.read_text(encoding="utf-8")
    return set(re.findall(rf'^{kind}\s+"([^"]+)"', text, flags=re.MULTILINE))


def main() -> int:
    root = Path(__file__).resolve().parent.parent
    failed = False

    print(f"{'cloud':<8} {'inputs':<12} {'outputs':<12}")
    for cloud in CLOUDS:
        module = root / "modules" / cloud / "foundation"
        inputs = names(module / "variables.tf", "variable")
        outputs = names(module / "outputs.tf", "output")
        missing_inputs = sorted(COMMON_INPUTS - inputs)
        missing_outputs = sorted(COMMON_OUTPUTS - outputs)

        input_status = "OK" if not missing_inputs else "MISSING"
        output_status = "OK" if not missing_outputs else "MISSING"
        print(f"{cloud:<8} {input_status:<12} {output_status:<12}")

        if missing_inputs:
            failed = True
            print(f"  missing inputs: {', '.join(missing_inputs)}")
        if missing_outputs:
            failed = True
            print(f"  missing outputs: {', '.join(missing_outputs)}")

    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
