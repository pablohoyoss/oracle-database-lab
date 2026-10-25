#!/usr/bin/env bash
# scripts/lab5/12-undo-multiversion.sh
set -euo pipefail
source scripts/deployment/env/00-config.sh

TS=$(ts)
mkdir -p "$EVID_LAB5/script"

bash scripts/ops/sysdba.sh scripts/lab5/12-undo-multiversion.sql "$EVID_LAB5/script/${TS}_12-undo-multiversion.script.log"
