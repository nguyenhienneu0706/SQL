/* NGÀY 22/05/2023 */ 
--- Lấy ra số tiền nạp của mỗi user trong một khoảng thời gian:
SELECT
  SUM(transaction.amount) AS Total_amount,
  user.user_id
FROM
  `gamotasdk5.bidata.transactions`
WHERE
  app.game_id = 180927
  AND (date >= "2023-04-27" AND date <= "2023-05-15")
GROUP BY
  user.user_id
LIMIT
  1000; 
  
--- Lấy ra ngày đầu tiên tồn tại dữ liệu (tức ngày đầu tiên dữ liệu được đưa lên Big Query):
SELECT
  MIN(date)
FROM
  `gamotasdk5.bidata.transactions`; 
  
--- Lấy ra số NRU truy cập:
-- Test thử tại thời điểm ngày 22/05/2023 tất cả các con game đang có dữ liệu, để xem nên NRU được lấy như thế nào?

SELECT COUNT(DISTINCT user_id)
FROM 
  `gamotasdk5.bidata.register_logs`;  
-- Kết quả: 257121

SELECT COUNT(DISTINCT userinfo.user_id)
FROM 
  `gamotasdk5.bidata.login_logs`;  
-- Kết quả: 232313 

SELECT COUNT(DISTINCT user_id)
FROM 
  `gamotasdk5.bidata.appsflyer_login_postback`; 
-- Kết quả: 223380

SELECT COUNT(DISTINCT user_id)
FROM 
  `gamotasdk5.bidata.game_roles`;  
-- Kết quả: 187790

SELECT COUNT(DISTINCT userinfo.user_id)
FROM 
  `gamotasdk5.bidata.open_logs`;  
-- Kết quả: 134632

SELECT COUNT(DISTINCT user.user_id)
FROM 
  `gamotasdk5.bidata.transactions`;  
-- Kết quả: 34238 

-- LẤY DOANH THU TỪNG KÊNH QUẢNG CÁO CỦA GAME ALO NGÀY 25/05/23 (TRONG TRƯỜNG HỢP K BỊ DUP DỮ LIỆU)
SELECT
  DISTINCT TRANS.transaction.id AS ID,
  LOGIN.media_source,
  SUM(TRANS.transaction.amount) AS Total_amount
FROM `gamotasdk5.bidata.transactions` AS TRANS
  LEFT JOIN `gamotasdk5.bidata.appsflyer_login_postback` AS LOGIN
  ON TRANS.user.user_id = LOGIN.user_id
WHERE TRANS.app.game_id = 180941
  AND TRANS.date = "2023-05-25"
GROUP BY LOGIN.media_source
ORDER BY Total_amount DESC; 

-- LẤY DOANH THU TỪNG KÊNH QUẢNG CÁO CỦA GAME ALO NGÀY 25/05/23 (TRONG TRƯỜNG HỢP CÓ BỊ DUP DỮ LIỆU) - CÁCH NGU NGỐC CỦA HIỀN
WITH TRANS AS (
SELECT
  user.user_id,
  transaction.id,
  transaction.amount AS Amount,
  created
FROM
  `gamotasdk5.bidata.transactions`
WHERE Date = "2023-05-25" AND app.game_id = 180941 
GROUP BY
  user.user_id,
  transaction.id,
  Amount,
  created -- có thể bỏ đi (để vào cho chắc hoi)
)-- 634 rows trong khi nếu không distinct sẽ là 1263 rows
, 
AF_LOGIN AS (
SELECT event_time, user_id, media_source, game_id, app_id, platform,
device_id, -- không cần trừ đi id tạo clone nếu clone không nạp
appsflyer_id, bundle_id, ip, city, country_code
FROM
  `gamotasdk5.bidata.appsflyer_login_postback`
WHERE Date = "2023-05-25" AND game_id = 180941 
GROUP BY
event_time, user_id, media_source, game_id, app_id, platform,
device_id, -- không cần trừ đi id tạo clone nếu clone không nạp
appsflyer_id, bundle_id, ip, city, country_code
-- 42139 rows trong khi nếu không distinct sẽ là 45024 rows
)
SELECT 
AF_LOGIN.media_source,
  SUM(Amount) AS Total_amount
FROM TRANS
  LEFT JOIN AF_LOGIN
  ON TRANS.user_id = AF_LOGIN.user_id
GROUP BY AF_LOGIN.media_source
ORDER BY Total_amount DESC; 

-- LẤY DOANH THU TỪNG KÊNH QUẢNG CÁO CỦA GAME ALO NGÀY 25/05/23 (TRONG TRƯỜNG HỢP CÓ BỊ DUP DỮ LIỆU)
WITH TRANS AS (
SELECT
  DISTINCT (transaction.id),
   user.user_id,
  transaction.amount AS Amount
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
  SUM(Amount) AS Total_amount
FROM TRANS
  LEFT JOIN AF_LOGIN
  ON TRANS.user_id = AF_LOGIN.user_id
GROUP BY AF_LOGIN.media_source
ORDER BY Total_amount DESC; 
