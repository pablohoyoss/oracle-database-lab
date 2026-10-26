#!/usr/bin/env bash
# scripts/lab5/11-activar-archivelog.sh
set -euo pipefail
source scripts/deployment/env/00-config.sh

FRA="$DATA_ROOT/fra"
FRA_SIZE="${FRA_SIZE:-4G}"
sql() { docker exec -i "$CONT_NAME" sqlplus -s -L / as sysdba; }

MODO=$(echo "SET HEADING OFF FEEDBACK OFF PAGESIZE 0; SELECT log_mode FROM v\$database;" | sql | xargs)
echo "Modo actual: $MODO"

echo "== 1. Crear directorio de la FRA en el volumen =="
docker exec "$CONT_NAME" mkdir -p "$FRA"

echo "== 2. Configurar tamaño y ubicación de la FRA =="
sql <<SQL
ALTER SYSTEM SET db_recovery_file_dest_size = $FRA_SIZE SCOPE=BOTH;
ALTER SYSTEM SET db_recovery_file_dest = '$FRA' SCOPE=BOTH;
SQL

if [ "$MODO" = "ARCHIVELOG" ]; then
  echo "La base de datos ya está en modo ARCHIVELOG."
else
  echo "== 3. Cambio de modo a ARCHIVELOG (requiere MOUNT) =="
  sql <<SQL
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
ALTER DATABASE ARCHIVELOG;
ALTER DATABASE OPEN;
SQL
fi

bash scripts/ops/esperar-healthy.sh

echo "== 4. Verificación y primer archivado manual =="
sql <<SQL
SET LINESIZE 160 PAGESIZE 100 FEEDBACK OFF
ARCHIVE LOG LIST;
ALTER SYSTEM SWITCH LOGFILE;
ALTER SYSTEM ARCHIVE LOG CURRENT;
COLUMN name FORMAT A55
SELECT sequence#, REGEXP_SUBSTR(name, '[^/]+$') AS name, ROUND(blocks*block_size/1048576, 1) AS mb, archived
FROM v\$archived_log WHERE name IS NOT NULL ORDER BY sequence# DESC FETCH FIRST 4 ROWS ONLY;
SELECT file_type, percent_space_used, number_of_files FROM v\$recovery_area_usage WHERE number_of_files > 0;
SELECT name, ROUND(space_limit/1048576) AS limite_mb, ROUND(space_used/1048576) AS usado_mb FROM v\$recovery_file_dest;
EXIT;
SQL
