SELECT client_ip,
       count(client_ip)
FROM consignmentapi_alb_logs
WHERE timestamp = cast(current_date AS varchar)
GROUP BY  1
ORDER BY  2 DESC limit 10;
