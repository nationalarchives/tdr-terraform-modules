SELECT eventname,
       requestparameters,
       useridentity,
       readonly
FROM tdr_cloudtrail_logs
WHERE timestamp = '2020/10/13'
  AND eventtime
    BETWEEN '2020-10-13T15:52:00Z'
    AND '2020-10-13T15:54:00Z'
  AND eventName = 'CreateQueue'
ORDER BY  eventtime
