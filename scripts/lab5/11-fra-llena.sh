#!/usr/bin/env bash
# scripts/lab5/11-fra-llena.sh
set -euo pipefail
source scripts/deployment/env/00-config.sh

TS=$(ts)
mkdir -p "$EVID_LAB5/script"

bash scripts/ops/sysdba.sh scripts/lab5/11-fra-llena.sql "$EVID_LAB5/script/${TS}_11-fra-llena.script.log"
