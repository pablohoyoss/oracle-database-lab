#!/bin/bash
set -e

# Variable de evidencia definida en el entorno del laboratorio
EVID_DIR="${EVID_LAB5:-docs/bitacora/lab5/evidencia}"
mkdir -p "$EVID_DIR"

LOG_FILE="${EVID_DIR}/$(date +%Y%m%dT%H%M%S)_08-scn-checkpoints.spool.log"

echo "[INFO] Ejecutando Parte I: SCN y Checkpoints..."
docker exec -i oracle-23ai sqlplus -s / as sysdba @/dev/stdin < scripts/lab5/08-scn-checkpoints.sql | tee "$LOG_FILE"

echo "[OK] Evidencia generada en: $LOG_FILE"
