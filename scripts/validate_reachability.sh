#!/usr/bin/env bash
set -euo pipefail

OUT="${1:-outputs.json}"

IP="$(jq -r '.target_public_ip.value' "$OUT")"

if [ -z "$IP" ] || [ "$IP" = "null" ]; then
  echo "[-] target_public_ip not found in outputs"
  exit 1
fi

echo "[*] Checking TCP/22 on $IP ..."
nc -z -w 3 "$IP" 22
echo "[+] Reachable on SSH (22)"

