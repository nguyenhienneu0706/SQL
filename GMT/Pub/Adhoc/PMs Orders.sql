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
-----------------------------------------------------------------------------------------------------------------------
-- 1. Task Query doanh thu Alo chủ tướng:

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

/* Cụ thể điều kiện: 
Thời gian : từ ngày 27/04 đến ngày 27/05
Tổng nạp tích lũy ( total amount local) [20tr, 50tr)
	Yêu cầu
Lấy theo chiều ngày để xem mỗi ngày user đó nạp bao nhiêu, nhiều hay ít và ngày nào không nạp */

-- Lấy ra bảng không bị dup giao dịch --
WITH trans_dedup AS(
  SELECT DISTINCT transaction.id as trans_id, date, transaction.amount_local AS amt_local, user.user_id AS user_id
  FROM
  gamotasdk5.bidata.transactions
  WHERE
    date >= "2023-04-27"
    AND date <= "2023-05-27"
    AND app.game_id = 180941
    AND transaction.vendor != "gamota_tester"
),
-- Lấy các user_id có tổng nạp tích lũy từ 20-50tr --
user_sum AS(
  SELECT trans_dedup.user_id AS user_id, SUM(trans_dedup.amt_local) as total_amt
  FROM trans_dedup
  GROUP BY user_id
  HAVING SUM(trans_dedup.amt_local) >= 20000000 AND SUM(trans_dedup.amt_local) <= 50000000
)
-- Lấy thông tin các cột cần, với điều kiện user_id thuộc bảng user tổng nạp tích lũy 20-50 --
SELECT trans_dedup.trans_id, date, trans_dedup.amt_local, trans_dedup.user_id
FROM trans_dedup
WHERE trans_dedup.user_id IN(SELECT user_sum.user_id FROM user_sum)
-----------------------------------------------------------------------------------------------------------------------------------------------------

-- 2. TASK TRUNG ORDER NOTION: Tìm mốc nạp trung vị (nếu có kĩ từng percentile thì càng tốt) của NEW USER Alo Chủ Tướng trong giai đoạn OB-OB+30 và 02/06-09/06:
-- Check: LẤY RA DOANH THU THEO NGÀY:
WITH A AS (
  SELECT
    DISTINCT (transaction.id) AS Transaction_ID,
    DATE,
    transaction.amount_local AS Amount_local
  FROM `gamotasdk5.bidata.transactions`
  WHERE app.game_id = 180941 AND (Date <= "2023-05-27" AND Date >= "2023-04-27")
  AND transaction.vendor != "gamota_tester"
)
SELECT
  A.Date,
  SUM(A.Amount_local) AS Total_Amount_local
FROM A
GROUP BY A.DATE;
-- GIAI ĐOẠN: OB - OB+30:
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
  APPROX_QUANTILES(Amount_local, 100)[OFFSET(9)] AS percentile_10,
  APPROX_QUANTILES(Amount_local, 100)[OFFSET(24)] AS percentile_25,
  APPROX_QUANTILES(Amount_local, 100)[OFFSET(39)] AS percentile_40,
  APPROX_QUANTILES(Amount_local, 100)[OFFSET(49)] AS percentile_50,
  APPROX_QUANTILES(Amount_local, 100)[OFFSET(59)] AS percentile_60,
  APPROX_QUANTILES(Amount_local, 100)[OFFSET(74)] AS percentile_75,
  APPROX_QUANTILES(Amount_local, 100)[OFFSET(89)] AS percentile_90,
FROM TRANS_ALO;

-- Giai đoạn 02-09/06 New Users:
--- LẤY RA BẢNG GIAO DỊCH GAME ALO TRONG KHOẢNG 02-09/06:
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
WHERE game_id = 180941
GROUP BY user_id, Date
)
SELECT *
FROM TRANS_ALO AS T
LEFT JOIN REGISTER AS R ON T.T_User_ID = R.R_User_ID
--- LẤY ĐIỀU KIỆN ĐĂNG KÍ TRONG KHOẢNG 02-09/06 TỨC LÀ NRU TRONG KHOẢNG THGIAN NÀY:
WHERE R.First_date_register_roles <= "2023-06-09" AND R.First_date_register_roles >= "2023-06-02"
    AND R.R_User_ID IS NOT NULL; -- LOẠI ĐI NHỮNG NGƯỜI NẠP TRONG THGIAN NÀY NHƯNG LÀ OLD USER RỒI
    
-- Lấy ra trung vị:
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
WHERE game_id = 180941
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
-----------------------------------------------------------------------------------------------------------------------------------------------------

-- 3. TRUNG ORDER NOTION: Tìm lượng DAU Alo Chủ Tướng theo server:
WITH LOGIN AS (
SELECT DISTINCT(appsflyer_id), -- CŨNG BỊ TRÙNG (635084 - BAN ĐẦU: 2075045)
  Date AS Date_login, user_id
FROM `gamotasdk5.bidata.appsflyer_login_postback`
WHERE game_id = 180941 AND (Date >= "2023-04-27")
),
SERVER AS (
SELECT DATE(Date) AS Date_server, server_id, user_id
FROM `gamotasdk5.bidata.game_roles`
WHERE game_id = 180941 AND DATE(Date) >= "2023-04-27" AND server_id != "001"
-- một user vào cùng 1 server vào những ngày khác nhau vẫn ghi nhận hết, điều đó chứng tỏ cứ vào tận trong server là nó tính chứ nó k chỉ tính mỗi cái ngày mà nó đăng kí roles
)
SELECT LOGIN.Date_login, SERVER.Date_server, SERVER.server_id, COUNT(DISTINCT LOGIN.user_id) AS DAU
FROM LOGIN 
RIGHT JOIN SERVER ON LOGIN.user_id = SERVER.user_id AND LOGIN.Date_login = SERVER.Date_server
GROUP BY LOGIN.Date_login, SERVER.server_id, SERVER.Date_server
ORDER BY LOGIN.Date_login;
--- Nhưng kết qủa trả về có rất nhiều lượt vào login mà k tracking được server_id

--- Nên đi check tiếp xem có đúng k, bằng cách xem từng lượt login ghi nhận như thế nào:
WITH LOGIN AS (
SELECT DISTINCT(appsflyer_id), -- CŨNG BỊ TRÙNG (635084 - BAN ĐẦU: 2075045)
  Date AS Date_login, user_id
FROM `gamotasdk5.bidata.appsflyer_login_postback`
WHERE game_id = 180941 AND (Date >= "2023-04-27")
),
SERVER AS (
SELECT DATE(Date) AS Date_server, server_id, user_id
FROM `gamotasdk5.bidata.game_roles`
WHERE game_id = 180941 AND DATE(Date) >= "2023-04-27" AND server_id != "001"
)
SELECT LOGIN.Date_login, SERVER.Date_server, SERVER.server_id, LOGIN.user_id AS User_ID
FROM LOGIN 
LEFT JOIN SERVER ON LOGIN.user_id = SERVER.user_id AND LOGIN.Date_login = SERVER.Date_server
WHERE LOGIN.Date_login = "2023-04-30" ; -- ví dụ check ngày 30/05

--- Ngoài ra dữ liệu từ bảng roles chỉ ghi nhận được như này (thiếu đi những người login nhưng k tracking được server_id)
WITH A AS (
SELECT DATE(Date) AS Date_server, server_id, user_id
FROM `gamotasdk5.bidata.game_roles`
WHERE game_id = 180941 AND DATE(Date) >= "2023-04-27" AND server_id != "001"
)
SELECT Date_server, server_id, COUNT(DISTINCT user_id) AS DAU
FROM A 
GROUP BY Date_server, server_id
ORDER BY Date_server;
--- Thực sự, các users này có login nhưng k có thông tin về server:
SELECT *
FROM `gamotasdk5.bidata.game_roles`
WHERE game_id = 180941 AND DATE(Date) = "2023-04-30" AND user_id IN (15812993,
66213370,
65923379,
58960807)
---> Chỉ có user_id 65923379 có thông tin thôi, các user kia k tracking ra được

