#!/bin/bash
set -euo pipefail

if sudo -n /usr/bin/find / -maxdepth 1 >/dev/null 2>&1; then
  echo "[+] Vulnerability validated: sudo find works without password"
  exit 0
else
  echo "[-] Vulnerability not present"
  exit 1
fi
