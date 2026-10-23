#!/usr/bin/env bash
# scripts/lab4/02-configurar-omf.sh activa OMF para garantizar que nuevos datafiles vayan al volumen
set -euo pipefail
source scripts/deployment/env/00-config.sh

echo "== Configurando db_create_file_dest =="
docker exec -i "$CONT_NAME" sqlplus -s -L / as sysdba <<'SQL'
ALTER SYSTEM SET db_create_file_dest = '/opt/oracle/oradata' SCOPE=BOTH;
SHOW PARAMETER db_create_file_dest;
EXIT
SQL
