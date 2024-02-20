-- TASK TRUNG ORDER NOTION: Tìm mốc nạp trung vị (nếu có kĩ từng percentile thì càng tốt) của NEW USER Alo Chủ Tướng trong giai đoạn OB-OB+30 và 02/06-09/06:

-- Giai đoạn OB-OB+30:
SELECT
  DISTINCT (transaction.id) AS Transaction_ID,
  user.user_id AS User_ID,
  Date AS Date_pay,
  transaction.amount_local AS Amount_local
FROM `gamotasdk5.bidata.transactions`
WHERE app.game_id = 180941 
  AND (Date <= "2023-05-27" AND Date >= "2023-04-27")
  AND transaction.vendor != "gamota_tester"
ORDER BY Amount_local;
--
WITH TRANS_ALO AS
(
  SELECT
  DISTINCT (transaction.id) AS Transaction_ID,
  user.user_id AS User_ID,
  date AS Date_pay,
  transaction.amount_local AS Amount_local
FROM `gamotasdk5.bidata.transactions`
WHERE app.game_id = 180941 AND (Date <= "2023-05-27" AND Date >= "2023-04-27")
AND NOT transaction.vendor = "gamota_tester"
ORDER BY Amount_local
)
SELECT
  APPROX_QUANTILES(Amount_local, 100)[OFFSET(9)] AS percentile_10,
  APPROX_QUANTILES(Amount_local, 100)[OFFSET(24)] AS percentile_25,
  APPROX_QUANTILES(Amount_local, 100)[OFFSET(39)] AS percentile_40,
  APPROX_QUANTILES(Amount_local, 100)[OFFSET(49)] AS percentile_50,
  APPROX_QUANTILES(Amount_local, 100)[OFFSET(59)] AS percentile_60,
  APPROX_QUANTILES(Amount_local, 100)[OFFSET(74)] AS percentile_75,
  APPROX_QUANTILES(Amount_local, 100)[OFFSET(89)] AS percentile_90,
FROM TRANS_ALO;

-- Giai đoạn 02-09/06 New Users:
--- Lấy giao dịch:
WITH TRANS_ALO AS
(
  SELECT
  DISTINCT (transaction.id) AS Transaction_ID,
  user.user_id AS T_User_ID,
  date AS Date_pay,
  transaction.amount_local AS Amount_local
FROM `gamotasdk5.bidata.transactions`
WHERE app.game_id = 180941 AND (DATE(Date) <= "2023-06-09" AND DATE(Date) >= "2023-06-02")
AND transaction.vendor != "gamota_tester"
),
REGISTER AS
(
  SELECT
  user_id AS R_User_ID,
  Date AS Date_register_roles,
  MIN(date) AS First_date_register_roles
FROM `gamotasdk5.bidata.register_logs`
WHERE game_id = 180941
GROUP BY user_id, Date
)
SELECT *
FROM TRANS_ALO AS T
LEFT JOIN REGISTER AS R ON T.T_User_ID = R.R_User_ID
WHERE R.First_date_register_roles <= "2023-06-09" AND R.First_date_register_roles >= "2023-06-02"
    AND R.R_User_ID IS NOT NULL; -- LOẠI ĐI NHỮNG NGƯỜI NẠP TRONG THGIAN NÀY NHƯNG LÀ OLD USER RỒI

--- Lấy trung vị:
WITH TRANS_ALO AS
(
  SELECT
  DISTINCT (transaction.id) AS Transaction_ID,
  user.user_id AS T_User_ID,
  date AS Date_pay,
  transaction.amount_local AS Amount_local
FROM `gamotasdk5.bidata.transactions`
WHERE app.game_id = 180941 AND (DATE(Date) <= "2023-06-09" AND DATE(Date) >= "2023-06-02")
AND transaction.vendor != "gamota_tester"
),
--- LẤY RA THÔNG TIN USER ĐĂNG KÍ GAME ALO:
REGISTER AS
(
  SELECT
  user_id AS R_User_ID,
  Date AS Date_register_roles,
  MIN(date) AS First_date_register_roles
FROM `gamotasdk5.bidata.register_logs`
WHERE game_id = 180941 AND (DATE(Date) <= "2023-06-09" AND DATE(Date) >= "2023-06-02")
GROUP BY user_id, Date
)
SELECT
  APPROX_QUANTILES(Amount_local, 100)[OFFSET(9)] AS percentile_10,
  APPROX_QUANTILES(Amount_local, 100)[OFFSET(24)] AS percentile_25,
  APPROX_QUANTILES(Amount_local, 100)[OFFSET(39)] AS percentile_40,
  APPROX_QUANTILES(Amount_local, 100)[OFFSET(49)] AS percentile_50,
  APPROX_QUANTILES(Amount_local, 100)[OFFSET(59)] AS percentile_60,
  APPROX_QUANTILES(Amount_local, 100)[OFFSET(74)] AS percentile_75,
  APPROX_QUANTILES(Amount_local, 100)[OFFSET(89)] AS percentile_90,
FROM TRANS_ALO;
