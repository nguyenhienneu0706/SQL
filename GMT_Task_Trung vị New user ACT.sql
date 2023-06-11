-- BẢNG DỮ LIỆU KẾT NỐI BÁO CÁO DOANH THU:

-- Lấy ra danh sách nạp (transactions) không bị dup dữ liệu:
WITH T_DISTINCT AS (
SELECT
  DISTINCT (transaction.id),
  user.user_id,
  date
FROM `gamotasdk5.bidata.transactions`
WHERE app.game_id = 180941 AND (Date <= "2023-05-26" AND Date >= "2023-04-27")
AND transaction.vendor != "gamota_tester"
)
SELECT 
  date,
  COUNT (DISTINCT user_id) AS PU
  FROM T_DISTINCT
  GROUP BY Date
  ORDER BY Date ASC;

-- Lấy ra số PU không bị dup dữ liệu:
WITH T_DISTINCT AS (
SELECT
  DISTINCT (transaction.id),
  user.user_id,
  date
FROM `gamotasdk5.bidata.transactions`
WHERE app.game_id = 180941 AND (Date <= "2023-05-26" AND Date >= "2023-04-27")
AND transaction.vendor != "gamota_tester"
)
SELECT 
  COUNT (DISTINCT user_id) AS PU
  FROM T_DISTINCT;

-- Task Query doanh thu Alo chủ tướng:
WITH TRANS AS (
SELECT
  DISTINCT (transaction.id),
   user.user_id,
  transaction.amount_local AS Amount_local
FROM
  `gamotasdk5.bidata.transactions`
WHERE Date = "2023-05-25" AND app.game_id = 180941 
)-- 634 rows trong khi nếu không distinct sẽ là 1263 rows
, 
AF_LOGIN AS (
SELECT DISTINCT(user_id), -- Chỉ ghi nhận một lần login trong ngày cho 1 user
media_source
FROM
  `gamotasdk5.bidata.appsflyer_login_postback`
WHERE Date = "2023-05-25" AND game_id = 180941 
-- 14307 rows trong khi nếu không distinct sẽ là 45024 rows
)
SELECT 
AF_LOGIN.media_source,
  SUM(Amount_local) AS Total_amount
FROM TRANS
  LEFT JOIN AF_LOGIN
  ON TRANS.user_id = AF_LOGIN.user_id
GROUP BY AF_LOGIN.media_source
ORDER BY Total_amount DESC; 

-----------------------------------------------------------------------------------------------------------------------------------------------------

-- TASK TRUNG ORDER NOTION: Tìm mốc nạp trung vị (nếu có kĩ từng percentile thì càng tốt) của NEW USER Alo Chủ Tướng trong giai đoạn OB-OB+30 và 02/06-09/06:

-- Lấy ra danh sách nạp (transactions) không bị dup dữ liệu OB-OB+30
SELECT
  DISTINCT (transaction.id) AS Transaction_ID,
  user.user_id AS User_ID,
  date AS Date_pay,
  transaction.amount_local AS Amount_local
FROM `gamotasdk5.bidata.transactions`
WHERE app.game_id = 180941 AND (Date <= "2023-05-27" AND Date >= "2023-04-27")
AND transaction.vendor != "gamota_tester"
ORDER BY Amount_local;

-- Lấy ra Trung vị:
WITH TRANS_ALO AS
(
  SELECT
  DISTINCT (transaction.id) AS Transaction_ID,
  user.user_id AS User_ID,
  date AS Date_pay,
  transaction.amount_local AS Amount_local
FROM `gamotasdk5.bidata.transactions`
WHERE app.game_id = 180941 AND (Date <= "2023-05-27" AND Date >= "2023-04-27")
AND transaction.vendor != "gamota_tester"
ORDER BY Amount_local
)
SELECT
  APPROX_QUANTILES(Amount_local, 100)[OFFSET(24)] AS percentile_25,
  APPROX_QUANTILES(Amount_local, 100)[OFFSET(49)] AS percentile_50,
  APPROX_QUANTILES(Amount_local, 100)[OFFSET(74)] AS percentile_75
FROM TRANS_ALO;
