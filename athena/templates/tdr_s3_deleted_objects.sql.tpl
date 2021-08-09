SELECT requestdatetime,
       remoteip,
       requester,
       key
FROM upload_files_dirty_logs
WHERE operation LIKE '%DELETE%' limit 10;
