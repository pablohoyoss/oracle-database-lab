#!/usr/bin/env bash
# scripts/lab5/10-redo.sh
set -euo pipefail
source scripts/deployment/env/00-config.sh

TS=$(ts)
mkdir -p "$EVID_LAB5/script"

bash scripts/ops/sysdba.sh scripts/lab5/10-redo.sql "$EVID_LAB5/script/${TS}_10-redo.script.log"
