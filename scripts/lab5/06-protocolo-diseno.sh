#!/usr/bin/env bash
# scripts/lab5/06-protocolo-diseno.sh
set -euo pipefail
source scripts/deployment/env/00-config.sh

TS=$(ts)
mkdir -p "$EVID_LAB5/script" "$EVID_LAB5/spool"

# Aplicar migración V005
MIG_EVID="$EVID_LAB5/spool" MIG_PARTE=06 bash scripts/deployment/env/08-aplicar-migraciones.sh V005_indices_optimizados

# Ejecutar script de mediciones
bash scripts/ops/sysdba.sh scripts/lab5/06-protocolo-diseno.sql "$EVID_LAB5/script/${TS}_06-protocolo-diseno.script.log"
