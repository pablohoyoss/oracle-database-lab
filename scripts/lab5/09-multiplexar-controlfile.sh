#!/usr/bin/env bash
# scripts/lab5/09-multiplexar-controlfile.sh
set -euo pipefail
source scripts/deployment/env/00-config.sh

CTL1="$DATA_ROOT/FREE/control01.ctl"
CTL2="$DATA_ROOT/FREE/control02.ctl"
CTL3="$DATA_ROOT/FREE/control03.ctl"

echo "== 1. Copia física del tercer control file =="
docker exec "$CONT_NAME" cp -p "$CTL1" "$CTL3"
docker exec "$CONT_NAME" ls -la "$DATA_ROOT/FREE/" | grep control

echo "== 2. Configuración en SPFILE y arranque de la instancia =="
docker exec -i "$CONT_NAME" sqlplus -s / as sysdba << SQL
STARTUP NOMOUNT;
ALTER SYSTEM SET control_files='$CTL1', '$CTL2', '$CTL3' SCOPE=SPFILE;
SHUTDOWN IMMEDIATE;
STARTUP;
SET LINESIZE 160 PAGESIZE 100
COLUMN name FORMAT A50
SELECT name, status FROM v\$controlfile;
EXIT;
SQL

bash scripts/ops/esperar-healthy.sh
