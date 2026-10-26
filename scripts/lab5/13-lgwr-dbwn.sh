#!/usr/bin/env bash
# scripts/lab5/13-lgwr-dbwn.sh
set -euo pipefail
source scripts/deployment/env/00-config.sh

TS=$(ts)
mkdir -p "$EVID_LAB5/script"

bash scripts/ops/sysdba.sh scripts/lab5/13-lgwr-dbwn.sql "$EVID_LAB5/script/${TS}_13-lgwr-dbwn.script.log"
