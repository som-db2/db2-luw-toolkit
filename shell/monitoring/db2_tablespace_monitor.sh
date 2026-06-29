\
#!/bin/bash

VERSION="1.0.0"

CONFIG="$(dirname "$0")/config.conf"

[[ -f "$CONFIG" ]] && source "$CONFIG"

WARNING_THRESHOLD=${WARNING_THRESHOLD:-80}
CRITICAL_THRESHOLD=${CRITICAL_THRESHOLD:-90}
REPORT_DIR=${REPORT_DIR:-reports}

usage(){
cat <<EOF
DB2 Tablespace Capacity Monitor

Usage:
  db2_tablespace_monitor.sh --all
  db2_tablespace_monitor.sh --database SAMPLE
  db2_tablespace_monitor.sh --help
  db2_tablespace_monitor.sh --version
EOF
}

[[ "$1" == "--help" ]] && usage && exit 0
[[ "$1" == "--version" ]] && echo "$VERSION" && exit 0

mkdir -p "$REPORT_DIR"

timestamp=$(date +%Y%m%d_%H%M%S)
outfile="$REPORT_DIR/tablespace_report_$timestamp.txt"

collect_db () {

DB=$1

db2 connect to "$DB" >/dev/null 2>&1 || {
    echo "Cannot connect to $DB"
    return
}

db2 -x "
SELECT
TBSP_NAME,
TBSP_TYPE,
DECIMAL((TBSP_USED_PAGES*100.0)/TBSP_TOTAL_PAGES,5,2),
TBSP_AUTO_RESIZE_ENABLED
FROM SYSIBMADM.TBSP_UTILIZATION
ORDER BY 3 DESC
" | while read NAME TYPE USED AUTO
do

STATUS="OK"

USED_INT=${USED%.*}

if [ "$USED_INT" -ge "$CRITICAL_THRESHOLD" ]; then
    STATUS="CRITICAL"
elif [ "$USED_INT" -ge "$WARNING_THRESHOLD" ]; then
    STATUS="WARNING"
fi

printf "%-35s %-8s %6s%% %-10s %s\n" \
"$NAME" "$TYPE" "$USED" "$AUTO" "$STATUS"

done

db2 connect reset >/dev/null
}

{
echo "============================================================="
echo "DB2 TABLESPACE CAPACITY REPORT"
echo "Generated : $(date)"
echo "============================================================="

if [[ "$1" == "--database" ]]; then
    collect_db "$2"
else
    db2 list db directory | awk -F= '/Database alias/ {gsub(/ /,"",$2);print $2}' | while read db
    do
        echo
        echo "Database : $db"
        collect_db "$db"
    done
fi

} | tee "$outfile"

echo
echo "Report saved to $outfile"
