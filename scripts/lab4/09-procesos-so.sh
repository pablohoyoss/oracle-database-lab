#!/usr/bin/env bash
# scripts/lab4/09-procesos-so.sh
set -euo pipefail
source scripts/deployment/env/00-config.sh

TMP=$(mktemp)

docker exec "$CONT_NAME" bash -c '
printf "%-8s %-10s %s\n" PID RSS_MB PROCESO
for d in /proc/[0-9]*; do
  pid=${d#/proc/}
  cmd=$(tr "\0" " " < "$d/cmdline" 2>/dev/null) || continue
  [ -n "$cmd" ] || continue
  rss=$(awk "/^VmRSS/ {printf \"%.0f\", \$2/1024}" "$d/status" 2>/dev/null)
  printf "%-8s %-10s %s\n" "$pid" "${rss:-0}" "$cmd"
done' > "$TMP"

echo "== 1. Procesos de background clave =="
grep -E '(pmon|lreg|smon|dbw0|lgwr|ckpt|mmon|mmnl|reco)_' "$TMP" || true

echo "== 2. Recuento por tipo =="
echo " background (db_*_FREE / ora_*_FREE): $(grep -cE '(db|ora)_[a-z0-9]+_FREE' "$TMP")"
echo " servidor dedicado (oracleFREE):       $(grep -c 'oracleFREE' "$TMP")"
echo " listener (tnslsnr):                   $(grep -c 'tnslsnr' "$TMP")"

if [ -n "${1:-}" ]; then
  echo "== 3. El proceso con SPID $1 =="
  awk -v p="$1" '$1 == p' "$TMP"
fi

rm -f "$TMP"
