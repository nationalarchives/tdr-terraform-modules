SELECT eventname,
       eventsource,
       requestparameters,
       useridentity.principalid,
       useridentity.sessioncontext.sessionissuer.username,
       eventtime
FROM "sampledb"."cloudtrail_logs" t
         CROSS JOIN UNNEST(t.resources) unnested (resources_entry)
WHERE useridentity.principalid LIKE '%:User.Name@nationalarchives.gov.uk'
  AND timestamp = cast(current_date AS varchar)
ORDER BY  eventtime desc
