#!/usr/bin/env bash
# scripts/lab5/09-controlfile.sh
set -euo pipefail
source scripts/deployment/env/00-config.sh

TS=$(ts)
mkdir -p "$EVID_LAB5/script"

bash scripts/ops/sysdba.sh scripts/lab5/09-controlfile.sql "$EVID_LAB5/script/${TS}_09-controlfile.script.log"
