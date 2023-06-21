-- Tìm lượng DAU Alo Chủ Tướng theo server:
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
