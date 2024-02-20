
-- Nạp một loại cổng:
WITH A AS 
(
SELECT
  DISTINCT (`transaction`.id) AS id,
  `transaction`.amount_local AS amount,
  `user`.user_id as user,
  `transaction`.type As type,
  CASE WHEN `transaction`.vendor IS NULL THEN "" ELSE `transaction`.vendor END AS Vendor,
  CONCAT(`transaction`.type, " ", `transaction`.vendor) AS type_vendor,
  app.game_id AS game_id
FROM
  `gamotasdk5.bidata.transactions`
WHERE
  app.game_id in ("180941", "180150", "180419", "180730", "180534", "180886", "180915", "180927", "180937", "180872")
  AND DATE >= "2023-01-01" AND DATE <= "2023-06-30"
)
, B as (
SELECT user, game_id, COUNT(DISTINCT type_vendor) as no_gate
FROM A
GROUP BY game_id, user
ORDER BY game_id, user
)
, C AS (
SELECT A.game_id AS game_id, A.type_vendor, B.no_gate AS no_gate, B.user, A.id, A.amount AS amount
FROM B LEFT JOIN A
ON A.user = B.user
WHERE A.vendor != "gamota_tester"
ORDER BY A.game_id, B.user 
)
, D AS (
SELECT game_id, C.type_vendor, c.user, sum(C.amount) As total_amount
FROM C
WHERE C.no_gate = 1
GROUP BY game_id, C.type_vendor, c.user
HAVING SUM(C.amount) >= 200000
ORDER BY C.type_vendor, c.user
)
SELECT D.type_vendor, COUNT(user) AS PU, SUM(total_amount) AS REVENUE
FROM D
GROUP BY D.type_vendor;

--

-- Nạp >= hai loại cổng:
WITH A AS 
(
SELECT
  DISTINCT (`transaction`.id) AS id,
  `transaction`.amount_local AS amount,
  `user`.user_id as user,
  `transaction`.type As type,
  CASE WHEN `transaction`.vendor IS NULL THEN "" ELSE `transaction`.vendor END AS Vendor,
  CONCAT(`transaction`.type, " ", `transaction`.vendor) AS type_vendor,
  app.game_id AS game_id
FROM
  `gamotasdk5.bidata.transactions`
WHERE
  app.game_id in ("180941", "180150", "180419", "180730", "180534", "180886", "180915", "180927", "180937", "180872")
  AND DATE >= "2023-01-01" AND DATE <= "2023-06-30"
)
, B as (
SELECT user, game_id, COUNT(DISTINCT type_vendor) as no_gate
FROM A
GROUP BY game_id, user
ORDER BY game_id, user
)
, C AS (
SELECT A.game_id AS game_id, A.type_vendor, B.no_gate AS no_gate, B.user, A.id, A.amount AS amount
FROM B LEFT JOIN A
ON A.user = B.user
WHERE A.vendor != "gamota_tester"
ORDER BY A.game_id, B.user 
)
, D AS (
SELECT game_id, C.type_vendor, c.user, sum(C.amount) As total_amount
FROM C
WHERE C.no_gate >= 2 
-- AND C.type_vendor = "ewallet zalopay"
GROUP BY game_id, C.type_vendor, c.user
HAVING SUM(C.amount) >= 200000
ORDER BY C.type_vendor, c.user
)
SELECT D.type_vendor, COUNT(user) AS PU, SUM(total_amount) AS REVENUE
FROM D
GROUP BY D.type_vendor;

--

-- Breakdown xem nạp ở các cổng khác thì như thế nào (Nạp >= hai loại cổng):
WITH A AS 
(
SELECT
  DISTINCT (`transaction`.id) AS id,
  `transaction`.amount_local AS amount,
  `user`.user_id as user,
  `transaction`.type As type,
  CASE WHEN `transaction`.vendor IS NULL THEN "" ELSE `transaction`.vendor END AS Vendor,
  CONCAT(`transaction`.type, " ", `transaction`.vendor) AS type_vendor,
  app.game_id AS game_id
FROM
  `gamotasdk5.bidata.transactions`
WHERE
  app.game_id in ("180941", "180150", "180419", "180730", "180534", "180886", "180915", "180927", "180937", "180872")
  AND DATE >= "2023-01-01" AND DATE <= "2023-06-30"
)
, B as (
SELECT user, game_id, COUNT(DISTINCT type_vendor) as no_gate
FROM A
GROUP BY game_id, user
ORDER BY game_id, user
)
, C AS (
SELECT A.game_id AS game_id, A.type_vendor, B.no_gate AS no_gate, B.user, A.id, A.amount AS amount
FROM B LEFT JOIN A
ON A.user = B.user
WHERE A.vendor != "gamota_tester"
ORDER BY A.game_id, B.user 
)
, D AS (
SELECT game_id, C.type_vendor, c.user, sum(C.amount) As total_amount
FROM C
WHERE C.no_gate >= 2 
GROUP BY game_id, C.type_vendor, c.user
HAVING SUM(C.amount) >= 200000
ORDER BY C.type_vendor, c.user
)
SELECT D.type_vendor, D.user, SUM(total_amount) AS REVENUE
FROM D
GROUP BY D.type_vendor, D.user;
