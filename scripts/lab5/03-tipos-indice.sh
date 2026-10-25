#!/usr/bin/env bash
# scripts/lab5/03-tipos-indice.sh
set -euo pipefail
source scripts/deployment/env/00-config.sh

TS=$(ts)
mkdir -p "$EVID_LAB5/script"

bash scripts/ops/sysdba.sh scripts/lab5/03-tipos-indice.sql "$EVID_LAB5/script/${TS}_03-tipos-indice.script.log"
