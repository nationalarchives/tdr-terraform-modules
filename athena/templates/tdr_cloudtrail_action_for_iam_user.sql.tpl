SELECT eventname,
       eventsource,
       requestparameters,
       useridentity.username
FROM "sampledb"."cloudtrail_logs" t
         CROSS JOIN UNNEST(t.resources) unnested (resources_entry)
WHERE useridentity.username = 'an iam user'
  AND timestamp = cast(current_date AS varchar)
ORDER BY  eventtime desc
