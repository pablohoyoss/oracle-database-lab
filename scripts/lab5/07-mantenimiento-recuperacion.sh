#!/usr/bin/env bash
# scripts/lab5/07-mantenimiento-recuperacion.sh
set -euo pipefail
source scripts/deployment/env/00-config.sh

TS=$(ts)
mkdir -p "$EVID_LAB5/script"

bash scripts/ops/sysdba.sh scripts/lab5/07-mantenimiento-recuperacion.sql "$EVID_LAB5/script/${TS}_07-mantenimiento-recuperacion.script.log"
