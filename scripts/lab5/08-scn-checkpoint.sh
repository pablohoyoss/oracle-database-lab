#!/usr/bin/env bash
# scripts/lab5/08-scn-checkpoint.sh
set -euo pipefail
source scripts/deployment/env/00-config.sh

TS=$(ts)
mkdir -p "$EVID_LAB5/script"

bash scripts/ops/sysdba.sh scripts/lab5/08-scn-checkpoint.sql "$EVID_LAB5/script/${TS}_08-scn-checkpoint.script.log"
