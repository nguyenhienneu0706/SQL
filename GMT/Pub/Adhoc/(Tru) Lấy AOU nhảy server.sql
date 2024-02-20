---LẤY NRU VÀO SERVER:

SELECT COUNT(DISTINCT Raw.user_id) AS AOU, Raw.server_id, Server_OD, Server_CD, first_date
FROM
(
-- B1: Tạo ra bảng chứa server và ngày đầu tiên có user vào server (coi như là ngày mở server), Tạo thêm một cột đánh stt
WITH S1 AS 
(
SELECT 
  CAST(server_id AS INT64) - 23000 AS RowNumber,
  server_id,
  MIN(DATE(date)) AS Server_OD
FROM `gamotasdk5.bidata.game_roles` 
WHERE game_id = '180419'
  AND (server_id LIKE '230_%' OR server_id LIKE '231_%')
GROUP BY server_id
ORDER BY server_id
),
-- B2: Tạo ra bảng tương tự như bảng 1 nhưng stt giảm đi một đơn vị, mục đích để các hàng đều di chuyển lên trên 1 dòng (nhằm đưa ngày ra mắt của 2 server liên tiếp lên cùng 1 hàng để tính khoảng thời gian giữa nó: ĐK >= ngày ra mắt và < ngày ra mắt của server sau:
S2 AS 
(
SELECT 
  CAST(server_id AS INT64) - 23001 AS RowNumber,
  server_id,
  MIN(DATE(date)) AS Server_OD
FROM `gamotasdk5.bidata.game_roles` 
WHERE game_id = '180419'
  AND (server_id LIKE '230_%' OR server_id LIKE '231_%')
GROUP BY server_id
ORDER BY server_id
)
,
--B3: Lấy ra các cột cần thiết, lấy S1 làm gốc, tạo thêm cột NRU theo server:
A AS 
(
SELECT S1.RowNumber, S1.server_id AS server_id, S1.Server_OD AS Server_OD, S2.Server_OD AS Server_CD
FROM S1
LEFT JOIN S2
ON S1.RowNumber = S2.RowNumber
ORDER BY S1.RowNumber
),
-- B4: Bảng chứa user_id, server_id và ngày mà user tạo nhân vật ở server đó
B AS
(
SELECT DISTINCT (user_id) AS user_id,
MIN(DATE(Date)) AS first_date_in_server, server_id
FROM `gamotasdk5.bidata.game_roles` 
WHERE game_id = '180419'AND server_id LIKE '230_%' OR server_id LIKE '231_%'
GROUP BY user_id, server_id
),
-- B5: Tạo ra bảng có ngày đăng kí tài khoản đầu tiên của user (để kết nối với bảng ở b4)
R AS 
(
SELECT Distinct (user_id) as user_id, date as first_date --dùng distinct vì dữ liệu có bản ghi giống nhau 100% các thông tin
FROM `gamotasdk5.bidata.register_logs`
WHERE game_id = '180419'
)
-- B6: Kết nối với bảng register_logs: user đăng kí tài khoản trong khoảng thời gian ở b4 thì ghi nhận là NRU đẩy mới vào server (không tính user cũ lên server mới):
SELECT B.user_id, R.first_date, B.server_id, A.Server_OD, A.Server_CD
FROM B
LEFT JOIN R ON B.user_id = R.user_id
LEFT JOIN A ON B.server_id = A.server_id
) 
AS Raw
WHERE first_date < Server_OD -- ĐIỀU KIỆN: ĐÃ ĐK TÀI KHOẢN TRƯỚC NGÀY MỞ SERVER ĐƯỢC TÍNH LÀ ACTIVE OLD USER NHẢY SERVER (k nhất thiết phải group by theo first_date)
GROUP BY Raw.server_id, Server_OD, Server_CD, first_date
ORDER BY Raw.server_id, first_date;




