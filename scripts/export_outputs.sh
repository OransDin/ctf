#!/usr/bin/env bash
set -euo pipefail

TF_DIR="${1:-infra}"

cd "$TF_DIR"
terraform output -json > ../outputs.json
echo "[+] Wrote outputs.json"

