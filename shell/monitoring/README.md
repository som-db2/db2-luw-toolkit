# DB2 Tablespace Capacity Monitor

## Purpose

Reports tablespace utilization across one or more IBM DB2 LUW databases.

## Requirements

- DB2 CLP installed
- Instance environment sourced
- SYSIBMADM.TBSP_UTILIZATION view available

## Examples

```
./db2_tablespace_monitor.sh --all

./db2_tablespace_monitor.sh --database SAMPLE

./db2_tablespace_monitor.sh --version
```

## Exit Codes

|Code|Meaning|
|---:|---|
|0|Completed successfully|
|1|Warnings detected|
|2|Critical threshold exceeded|
|3|Connection failure|

## Future Roadmap

- HTML dashboard
- Email notifications
- CSV export
- Growth forecasting
- Cron integration
