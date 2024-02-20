WITH A AS(
SELECT  transaction.id AS id, 
  date, user.user_id AS user, user.username, transaction.amount_local
FROM `gamotasdk5.bidata.transactions` 
WHERE app.game_id = '180419' AND (Date <= "2023-08-01" AND Date >= "2017-01-01")
AND transaction.vendor != "gamota_tester"
AND  transaction.id in (
  SELECT
  DISTINCT transaction.id, 
  FROM `gamotasdk5.bidata.transactions` 
  )
),
B AS (
  SELECT user_id AS user, appsflyer_id, city, country_code, ip
  FROM `gamotasdk5.bidata.appsflyer_login_postback` 
  WHERE game_id = '180419' AND (Date <= "2023-08-01" AND Date >= "2017-01-01")
)
SELECT distinct (a.user), b.ip
FROM A
LEFT JOIN B
ON A.user = B.user
where ip is not null

--

WITH C AS 
(  SELECT  transaction.id AS id, 
  date, user.user_id AS user, user.username, transaction.amount_local
FROM `gamotasdk5.bidata.transactions` 
WHERE app.game_id = '180419' AND (Date <= "2023-08-01" AND Date >= "2017-01-01")
AND transaction.vendor != "gamota_tester"
)
SELECT *
FROM 
(
  SELECT a.user_id, a.email, a.phone, a.total_amount, a.last_login_ip, b.country_name, b.city_name
  FROM `gamotasdk5.userdata.analytics_2404` AS a
LEFT JOIN `gamotasdk5.geocode.geolite_city_mapping` AS b
ON b.network_start_ip = a.last_login_ip 
LEFT JOIN C
ON a.user_id = c.user
)

-- cách 1:
WITH GEO AS (
SELECT
  a.*, b.city_name, b.country_name
FROM (
  SELECT
    loc.*,
    INTEGER(PARSE_IP( loc.last_login_ip )) AS clientIpNum,
    INTEGER(PARSE_IP( loc.last_login_ip )/(256*256)) AS class_b
  FROM
    [gamotasdk5:userdata.analytics_2404] AS loc) AS a
JOIN each
  [gamotasdk5:geocode.geolite_city_mapping] AS b
ON
  (a.class_b = b.class_b)
WHERE
  (a.clientIpNum BETWEEN b.network_start_integer
    AND b.network_last_integer)
), 
PU AS (
  SELECT  transaction.id AS id, 
  date, user.user_id AS user, user.username, transaction.amount_local
FROM [gamotasdk5:bidata.transactions] 
WHERE app.game_id = '180419' AND (Date <= "2023-08-01" AND Date >= "2017-01-01")
AND transaction.vendor != "gamota_tester"
)
SELECT PU.user, PU.username, GEO.city_name, GEO.country_code, pu.amount_local
FROM PU
LEFT JOIN GEO
ON GEO.user = PU.user
-- cách 2:
SELECT PU.user, PU.username, GEO.city_name, GEO.country_code, pu.amount_local
FROM 
(SELECT
  a.*, b.city_name, b.country_name
FROM (
  SELECT
    loc.*,
    INTEGER(PARSE_IP( loc.last_login_ip )) AS clientIpNum,
    INTEGER(PARSE_IP( loc.last_login_ip )/(256*256)) AS class_b
  FROM
    [gamotasdk5:userdata.analytics_2404] AS loc) AS a
JOIN each
  [gamotasdk5:geocode.geolite_city_mapping] AS b
ON
  (a.class_b = b.class_b)
WHERE
  (a.clientIpNum BETWEEN b.network_start_integer
    AND b.network_last_integer)
) AS GEO
LEFT JOIN
(
  SELECT *
FROM [gamotasdk5:bidata.transactions] 
WHERE app.game_id = '180419' AND (Date <= "2023-08-01" AND Date >= "2017-01-01")
AND transaction.vendor != "gamota_tester"
) AS PU
ON GEO.user = PU.user


--
SELECT PU.user, GEO.b_city_name, GEO.b_country_name
FROM `gamotasdk5.bidata.Geography` AS GEO
RIGHT JOIN
(
  SELECT distinct(user.user_id) AS user
FROM `gamotasdk5.bidata.transactions`
WHERE app.game_id = '180419' AND (Date <= "2023-08-01" AND Date >= "2017-01-01")
AND transaction.vendor != "gamota_tester"
) AS PU
ON GEO.a_user_id = PU.user
--
--Count thử xem mỗi nơi có bn:

select count (user), pp.b_city_name
from 
(
  SELECT PU.user, GEO.b_city_name, GEO.b_country_name
FROM `gamotasdk5.bidata.Geography` AS GEO
RIGHT JOIN
(
  SELECT distinct(user.user_id) AS user
FROM `gamotasdk5.bidata.transactions`
WHERE app.game_id = '180419' AND (Date <= "2023-08-01" AND Date >= "2017-01-01")
AND transaction.vendor != "gamota_tester"
) AS PU
ON GEO.a_user_id = PU.user
) AS pp
group by pp.b_city_name

--Lấy ra ip đầu tiên của user:
WITH RAW AS
(
  SELECT DISTINCT (PU.user) as user
  , GEO.b_city_name, GEO.b_country_name
FROM `gamotasdk5.bidata.Geography` AS GEO
RIGHT JOIN
(
  SELECT distinct(user.user_id) AS user, transaction.amount_local as amount_local
FROM `gamotasdk5.bidata.transactions`
WHERE app.game_id = '180419' AND (Date <= "2023-08-01" AND Date >= "2017-01-01")
AND transaction.vendor != "gamota_tester"
) AS PU
ON GEO.a_user_id = PU.user
),
IP AS
(
  SELECT DISTINCT(user_id) AS user, appsflyer_id, city, country_code, ip
  FROM `gamotasdk5.bidata.appsflyer_login_postback` AS AF
  WHERE game_id = '180419' AND (Date <= "2023-08-01" AND Date >= "2017-01-01")
) 
SELECT DISTINCT (raw.USER), b_city_name, b_country_name, ip.country_code, ip.ip
FROM RAW 
LEFT JOIN IP
ON IP.user = RAW.user
--
WITH RAW AS
(
  SELECT DISTINCT
    PU.user AS user,
    GEO.b_city_name,
    GEO.b_country_name
  FROM `gamotasdk5.bidata.Geography` AS GEO
  RIGHT JOIN
  (
    SELECT DISTINCT
      user.user_id AS user,
      transaction.amount_local AS amount_local
    FROM `gamotasdk5.bidata.transactions`
    WHERE app.game_id = '180941' AND (Date <= "2023-08-01" AND Date >= "2016-01-01")
      AND transaction.vendor != "gamota_tester"
  ) AS PU
  ON GEO.a_user_id = PU.user
  WHERE b_city_name IS NOT NULL
),
IP AS
(
  SELECT DISTINCT
    user_id AS user,
    appsflyer_id,
    city,
    country_code,
    ip,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY ip) AS ip_row_number
  FROM `gamotasdk5.bidata.appsflyer_login_postback` AS AF
  WHERE game_id = '180419' AND (Date <= "2023-08-01" AND Date >= "2017-01-01")
)
SELECT DISTINCT
  RAW.user,
  b_city_name,
  b_country_name,
  ip.country_code,
  ip.ip,
  ip.ip_row_number
FROM RAW
LEFT JOIN IP ON IP.user = RAW.user
WHERE IP.ip_row_number = 1;
