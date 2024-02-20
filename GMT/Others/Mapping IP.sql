SELECT
  a.*, b.city_name, b.country_name
FROM (
  SELECT
    loc.*,
    CAST((PARSE_IP( loc.last_login_ip )) AS INT) AS clientIpNum,
    CAST((PARSE_IP( loc.last_login_ip )/(256*256)) AS INT) AS class_b
  FROM
   `gamotasdk5.userdata.analytics_2404` AS loc) AS a
JOIN 
`gamotasdk5.geocode.geolite_city_mapping`AS b
ON
  (a.class_b = b.class_b)
WHERE
  (a.clientIpNum BETWEEN b.network_start_integer
    AND b.network_last_integer)

