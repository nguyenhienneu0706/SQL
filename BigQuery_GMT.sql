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
