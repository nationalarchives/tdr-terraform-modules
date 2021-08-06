SELECT *
FROM upload_files_dirty_logs
WHERE parse_datetime(requestdatetime,'dd/MMM/yyyy:HH:mm:ss Z') > parse_datetime('2021-05-07:00:00:00','yyyy-MM-dd:HH:mm:ss')
  AND httpstatus IN ('401','403') limit 10
