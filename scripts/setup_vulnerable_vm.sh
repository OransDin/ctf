#!/bin/bash
set -euo pipefail

TARGET_USER="ctfuser"
SUDO_FILE="/etc/sudoers.d/ctf_vulnerability"
FIND_BIN="/usr/bin/find"

# 1) verify user exists
id "$TARGET_USER" >/dev/null 2>&1 || { echo "[-] user $TARGET_USER not found"; exit 1; }

# 2) verify sudoers file exists + permissions
test -f "$SUDO_FILE" || { echo "[-] sudoers file missing: $SUDO_FILE"; exit 1; }
perm="$(stat -c "%a" "$SUDO_FILE")"
[ "$perm" = "440" ] || { echo "[-] sudoers perms expected 440, got $perm"; exit 1; }

# 3) verify rule exists (simple grep is enough here)
grep -qE "^${TARGET_USER} .*NOPASSWD: ${FIND_BIN}\b" "$SUDO_FILE" || {
  echo "[-] sudo rule not found or not exact"
  exit 1
}

# 4) verify target user can run sudo find without password
if sudo -u "$TARGET_USER" sudo -n "$FIND_BIN" /etc -maxdepth 0 -type d -print >/dev/null 2>&1; then
  echo "[+] Vulnerability validated: $TARGET_USER can sudo find without password"
  exit 0
else
  echo "[-] Vulnerability not present (or requires password)"
  exit 1
fi
