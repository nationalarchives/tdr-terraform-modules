SELECT eventname,
       requestparameters,
       useridentity,
       readonly
FROM tdr_cloudtrail_logs t
         CROSS JOIN UNNEST(t.resources) unnested (resources_entry)
WHERE timestamp = '2020/10/13'
  AND unnested.resources_entry.ARN = '<some-arn>'
  AND readonly = 'false'
ORDER BY  eventtime
