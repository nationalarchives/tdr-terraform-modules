SELECT sourceipaddress,
       COUNT(*)
FROM tdr_cloudtrail_logs
WHERE useridentity.accesskeyid = '%<some-access-key>%'
  AND timestamp
    BETWEEN '2021/03/20'
    AND '2021/03/29'
GROUP BY  sourceipaddress;
