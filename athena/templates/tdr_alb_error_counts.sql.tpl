SELECT client_ip,
       elb_status_code,
       count(*)
FROM consignmentapi_alb_logs
WHERE timestamp = cast(current_date AS varchar)
  AND elb_status_code IN ('403','401')
GROUP BY  1,2
ORDER BY  3 DESC limit 10;
