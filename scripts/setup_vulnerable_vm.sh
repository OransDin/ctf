#!/bin/bash
set -euo pipefail

TARGET_USER="ctfuser"
SUDO_FILE="/etc/sudoers.d/ctf_vulnerability"
FIND_BIN="/usr/bin/find"

echo "[*] Installing prerequisites..."
apt-get update -y
apt-get install -y sudo

echo "[*] Creating user if missing: ${TARGET_USER}"
if ! id "${TARGET_USER}" >/dev/null 2>&1; then
  useradd -m -s /bin/bash "${TARGET_USER}"
fi

echo "[*] Creating vulnerable sudoers rule..."
echo "${TARGET_USER} ALL=(ALL) NOPASSWD: ${FIND_BIN}" > "${SUDO_FILE}"
chmod 440 "${SUDO_FILE}"

echo "[*] Verifying sudo rule..."
sudo -u "${TARGET_USER}" sudo -n -l || true

echo "[+] Vulnerable target configured: ${TARGET_USER} can sudo ${FIND_BIN} without password"

