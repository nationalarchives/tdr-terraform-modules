SELECT eventtime,
       eventname,
       useridentity,
       resources,
       responseelements,
       requestparameters
FROM tdr_cloudtrail_logs
WHERE timestamp = '2021/03/29'
  AND eventname = 'AssumeRole'
  AND responseelements LIKE '%<some-access-key>%'
ORDER BY  eventtime