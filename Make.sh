#!/bin/bash
set -euo pipefail

if [[ -z "${THEOS:-}" || ! -d "$THEOS" ]]; then
  echo "[!] Defina THEOS para o diretório de instalação do Theos." >&2
  exit 1
fi

make clean
make package FINALPACKAGE=1

artifact=$(find packages -maxdepth 1 -type f -name '*.deb' -print -quit)
if [[ -z "$artifact" ]]; then
  echo "[!] O build terminou sem gerar um pacote .deb." >&2
  exit 1
fi
printf '[OK] Pacote gerado: %s\n' "$artifact"
