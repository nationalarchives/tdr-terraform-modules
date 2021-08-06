SELECT eventname,
       eventsource,
       errorcode,
       requestparameters,
       useridentity.principalid,
       useridentity.sessioncontext.sessionissuer.username,
       eventtime
FROM tdr_cloudtrail_logs t
         CROSS JOIN UNNEST(t.resources) unnested (resources_entry)
WHERE useridentity.sessioncontext.sessionissuer.username = 'AssumedRoleName'
  AND timestamp = cast(current_date AS varchar)
ORDER BY  eventtime desc
