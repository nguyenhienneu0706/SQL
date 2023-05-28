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

SELECT COUNT(DISTINCT userinfo.user_id)
FROM 
  `gamotasdk5.bidata.login_logs`
WHERE Date = "2023-05-22";
-- Kết quả: 29013

SELECT COUNT(DISTINCT user_id)
FROM 
  `gamotasdk5.bidata.appsflyer_login_postback`
WHERE Date = "2023-05-22"; 
-- Kết quả: 27581

SELECT COUNT(DISTINCT userinfo.user_id)
FROM 
  `gamotasdk5.bidata.open_logs`
WHERE Date = "2023-05-22";
-- Kết quả: 20243

SELECT COUNT(DISTINCT user_id)
FROM 
  `gamotasdk5.bidata.game_roles`
WHERE DATE(Date) = "2023-05-22"; -- Trường Date chưa có, chỉ có Datetime
-- Kết quả: 8337

SELECT COUNT(DISTINCT user_id)
FROM 
  `gamotasdk5.bidata.register_logs`
WHERE Date = "2023-05-22";
-- Kết quả: 7560

SELECT COUNT(DISTINCT user.user_id)
FROM 
  `gamotasdk5.bidata.transactions`
WHERE Date = "2023-05-22";
-- Kết quả: 1930 

-- CHỐT LẠI: login_logs -> appsflyer_login_postback -> open_logs -> game_roles -> register_logs -> transactions

/* LẤY DOANH THU TỪNG KÊNH QUẢNG CÁO CỦA GAME ALO NGÀY 25/05/23 (TRONG TRƯỜNG HỢP K BỊ DUP DỮ LIỆU)
Doanh thu ghi nhận là doanh thu của những user mà có login vào ngày 25 và nạp luôn ngày 25, thiếu đi những user k login nhưng vẫn nạp (ví dụ nạp qua trang nạp, ...) */

SELECT
  LOGIN.media_source,
  SUM(TRANS.transaction.amount_local) AS Total_amount_local
FROM `gamotasdk5.bidata.transactions` AS TRANS
  LEFT JOIN `gamotasdk5.bidata.appsflyer_login_postback` AS LOGIN
  ON TRANS.user.user_id = LOGIN.user_id
WHERE TRANS.app.game_id = 180941
  AND TRANS.date = "2023-05-25"
GROUP BY LOGIN.media_source
ORDER BY Total_amount_local DESC; 

-- LẤY DOANH THU TỪNG KÊNH QUẢNG CÁO CỦA GAME ALO NGÀY 25/05/23 (TRONG TRƯỜNG HỢP CÓ BỊ DUP DỮ LIỆU) - CÁCH NGU NGỐC CỦA HIỀN

/* Doanh thu ghi nhận là doanh thu của những user mà có login vào ngày 25 và nạp luôn ngày 25, thiếu đi những user k login nhưng vẫn nạp (ví dụ nạp qua trang nạp, ...)

Vì ý nghĩa ngày trong bảng transactions và bảng appsflyer_login_postback là khác nhau:
- Bảng Trans: Mỗi giao dịch nạp ghi nhận một bản ghi (nhưng do bị dup dữ liệu nên mỗi giao dịch thường sẽ bị x nhiều lần nên => muốn sử dụng chính xác phải lấy distinct transaction_id)
- Bảng appsflyer_login_postback mỗi lần user nào đó login ghi nhận 1 bản ghi, nếu users đó vào nhiều lần trong ngày thì ghi nhận nhiều bản ghi nên khi join qua bảng transactions thì sẽ 1 users giao dịch (unique) sẽ tương ứng với nhiều lần vào (mỗi lần vào tính doanh thu 1 lần) nên doanh thu từng user sẽ bị nhân lên -> để sử dụng đúng chỉ tính mỗi user coi như vào 1 lần => distinct user_id */ 

WITH TRANS AS (
SELECT
  user.user_id,
  transaction.id,
  transaction.amount_local AS Amount_local,
  created
FROM
  `gamotasdk5.bidata.transactions`
WHERE Date = "2023-05-25" AND app.game_id = 180941 
GROUP BY
  user.user_id,
  transaction.id,
  Amount_local,
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
  SUM(Amount_local) AS Total_amount
FROM TRANS
  LEFT JOIN AF_LOGIN
  ON TRANS.user_id = AF_LOGIN.user_id
GROUP BY AF_LOGIN.media_source
ORDER BY Total_amount DESC; 

-- LẤY DOANH THU TỪNG KÊNH QUẢNG CÁO CỦA GAME ALO NGÀY 25/05/23 (TRONG TRƯỜNG HỢP CÓ BỊ DUP DỮ LIỆU)
/* Doanh thu ghi nhận là doanh thu của những user mà có login vào ngày 25 và nạp luôn ngày 25, thiếu đi những user k login nhưng vẫn nạp (ví dụ nạp qua trang nạp, ...)

Vì ý nghĩa ngày trong bảng transactions và bảng appsflyer_login_postback là khác nhau:
- Bảng Trans: Mỗi giao dịch nạp ghi nhận một bản ghi (nhưng do bị dup dữ liệu nên mỗi giao dịch thường sẽ bị x nhiều lần nên => muốn sử dụng chính xác phải lấy distinct transaction_id)
- Bảng appsflyer_login_postback mỗi lần user nào đó login ghi nhận 1 bản ghi, nếu users đó vào nhiều lần trong ngày thì ghi nhận nhiều bản ghi nên khi join qua bảng transactions thì sẽ 1 users giao dịch (unique) sẽ tương ứng với nhiều lần vào (mỗi lần vào tính doanh thu 1 lần) nên doanh thu từng user sẽ bị nhân lên -> để sử dụng đúng chỉ tính mỗi user coi như vào 1 lần => distinct user_id */ 

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

/* LẤY RA TẤT CẢ CÁC TRƯỜNG THÔNG TIN CẦN THIẾT TRONG BẢNG TRANSACTIONS MÀ KHÔNG BỊ DUP DỮ LIỆU
ĐÂY LÀ DỮ LIỆU GỐC ĐỂ QUERY TRỰC TIẾP TỪ BIGQUERY QUA LOOKER STUDIO */
SELECT
  DISTINCT (transaction.id),
  date, 
  user.user_id,user.role_id, user.server_id,
  transaction.type,transaction.vendor,
  transaction.amount_local AS Amount_local,
  app.app_id, app.game_id, app.platform, app.market
FROM `gamotasdk5.bidata.transactions`;
