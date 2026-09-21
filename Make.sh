#!/bin/bash
# Build script for IOS-Il2CppDumper (smartpepole build)
# Usage:
#   ./Make.sh            -> clean + build .deb
#   ./Make.sh install    -> build + install on this device (rootful/rootless)
set -e

# ---- Theos path (on-device) ----
export THEOS=/var/mobile/theos
export PATH="$THEOS/bin:$PATH"

if [ ! -d "$THEOS" ]; then
  echo "[!] THEOS not found at $THEOS"
  echo "    Install Theos first or edit the THEOS path in Make.sh"
  exit 1
fi

echo "[*] THEOS = $THEOS"
echo "[*] Cleaning…"
make clean >/dev/null 2>&1 || true

echo "[*] Building package…"
make package FINALPACKAGE=1

DEB=$(ls -t packages/*.deb 2>/dev/null | head -1)
if [ -z "$DEB" ]; then
  echo "[!] Build failed - no .deb produced"
  exit 1
fi
echo "[✓] Built: $DEB"

if [ "$1" = "install" ]; then
  echo "[*] Installing…"
  if command -v dpkg >/dev/null 2>&1; then
    dpkg -i "$DEB" || sudo dpkg -i "$DEB"
  else
    echo "[!] dpkg not found - copy $DEB and install manually"
  fi
fi
