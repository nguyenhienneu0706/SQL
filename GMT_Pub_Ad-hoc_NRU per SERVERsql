----- KIỂM CHỨNG XEM BAO NHIÊU NRU (HOẶC PU) TRONG MỘT SERVER LÀ TỐT NHẤT - GAME TRU TIÊN -----

-- LẤY RA NRU THEO SERVER:
-- B1: Tạo ra bảng chứa role_id không bị trùng lặp (số NRU):
WITH R AS (
  SELECT DISTINCT role_id AS Role,
    User_id,
    DATE(Date) AS Date,
    server_id AS Server,
    game_id AS Game
  FROM `gamotasdk5.bidata.game_roles` 
  WHERE game_id = '180419'
  AND server_id LIKE '230_%' OR server_id LIKE '231_%'
),
-- B2: Tạo ra bảng chứa server và ngày đầu tiên có user vào server (coi như là ngày mở server):
S AS (
SELECT DISTINCT server_id AS Server, 
  MIN(DATE(date)) AS ServerOpen_Day,
  DATE_ADD(MIN(DATE(date)), INTERVAL 30 DAY) AS Onemonth
FROM `gamotasdk5.bidata.game_roles` 
WHERE game_id = '180419'
  AND server_id LIKE '230_%' OR server_id LIKE '231_%'
GROUP BY Server
)
-- Join 2 bảng lấy ra số NRU trong 30 ngày kể từ ngày ra mắt:
SELECT COUNT(DISTINCT R.User_id) AS AU,
  R.Server,
  S.ServerOpen_Day,
  S.Onemonth
FROM R
LEFT JOIN S ON R.Server = S.Server
WHERE Date <= S.Onemonth AND Date >= S.ServerOpen_Day
GROUP BY R.Server, S.ServerOpen_Day, S.Onemonth
ORDER BY R.Server;

-- HOẶC:

-- LẤY RA NRU THEO SERVER:
-- B1: Tạo ra bảng chứa role_id không bị trùng lặp (số NRU):
SELECT  
  COUNT(DISTINCT user_id) AS AU,
  Server
FROM 
(
WITH R AS (
  SELECT DISTINCT role_id AS Role,
    user_id,
    DATE(Date) AS Date,
    server_id AS Server,
    game_id AS Game
  FROM `gamotasdk5.bidata.game_roles` 
  WHERE game_id = '180419'
  AND server_id LIKE '230_%' OR server_id LIKE '231_%'
),
-- B2: Tạo ra bảng chứa server và ngày đầu tiên có user vào server (coi như là ngày mở server):
S AS (
SELECT DISTINCT server_id AS Server, 
  MIN(DATE(date)) AS ServerOpen_Day,
  DATE_ADD(MIN(DATE(date)), INTERVAL 30 DAY) AS Onemonth,
  DATE_ADD(MIN(DATE(date)), INTERVAL 60 DAY) AS Twomonth
FROM `gamotasdk5.bidata.game_roles` 
WHERE game_id = '180419'
  AND server_id LIKE '230_%' OR server_id LIKE '231_%'
GROUP BY Server
)
-- Join 2 bảng lấy ra số NRU trong 30 ngày kể từ ngày ra mắt:
SELECT 
  R.Server, R.user_id, R.Date, S.ServerOpen_Day, S.Onemonth, S.Twomonth
FROM R
LEFT JOIN S ON R.Server = S.Server
) AS RAW_DATA
WHERE Date <= Onemonth AND Date >= ServerOpen_Day
GROUP BY Server
ORDER BY Server;

-- LẤY RA NRU CÒN LẠI SAU 30 DAYS KỂ TỪ NGÀY ĐẦU TIÊN TRUY CẬP
-- B1: Tạo ra bảng chứa role_id không bị trùng lặp (số NRU):
WITH R AS (
  SELECT DISTINCT role_id AS Role,
    User_id,
    DATE(Date) AS Date,
    server_id AS Server,
    game_id AS Game
  FROM `gamotasdk5.bidata.game_roles` 
  WHERE game_id = '180419'
  AND server_id LIKE '230_%' OR server_id LIKE '231_%'
),
-- B2: Tạo ra bảng chứa server và ngày đầu tiên có user vào server (coi như là ngày mở server):
S AS (
SELECT DISTINCT server_id AS Server, 
  MIN(DATE(date)) AS ServerOpen_Day,
  DATE_ADD(MIN(DATE(date)), INTERVAL 30 DAY) AS Onemonth,
  DATE_ADD(MIN(DATE(date)), INTERVAL 60 DAY) AS Twomonth
FROM `gamotasdk5.bidata.game_roles` 
WHERE game_id = '180419'
  AND server_id LIKE '230_%' OR server_id LIKE '231_%'
GROUP BY Server
)
-- Join 2 bảng lấy ra số NRU trong 30 ngày kể từ ngày ra mắt:
SELECT COUNT(DISTINCT R.User_id) AS AU,
  R.Server,
  S.ServerOpen_Day,
  S.Onemonth,
  S.Twomonth
FROM R
LEFT JOIN S ON R.Server = S.Server
WHERE Date <= S.Twomonth AND Date >= S.Onemonth
GROUP BY R.Server, S.ServerOpen_Day, S.Onemonth, S.Twomonth
ORDER BY R.Server;

-- HOẶC:

-- LẤY RA NRU THEO SERVER:
-- B1: Tạo ra bảng chứa role_id không bị trùng lặp (số NRU):
SELECT  
  COUNT(DISTINCT user_id) AS AU,
  Server
FROM 
(
WITH R AS (
  SELECT DISTINCT role_id AS Role,
    user_id,
    DATE(Date) AS Date,
    server_id AS Server,
    game_id AS Game
  FROM `gamotasdk5.bidata.game_roles` 
  WHERE game_id = '180419'
  AND server_id LIKE '230_%' OR server_id LIKE '231_%'
),
-- B2: Tạo ra bảng chứa server và ngày đầu tiên có user vào server (coi như là ngày mở server):
S AS (
SELECT DISTINCT server_id AS Server, 
  MIN(DATE(date)) AS ServerOpen_Day,
  DATE_ADD(MIN(DATE(date)), INTERVAL 30 DAY) AS Onemonth,
  DATE_ADD(MIN(DATE(date)), INTERVAL 60 DAY) AS Twomonth
FROM `gamotasdk5.bidata.game_roles` 
WHERE game_id = '180419'
  AND server_id LIKE '230_%' OR server_id LIKE '231_%'
GROUP BY Server
)
-- Join 2 bảng lấy ra số NRU trong 30 ngày kể từ ngày ra mắt:
SELECT 
  R.Server, R.user_id, R.Date, S.ServerOpen_Day, S.Onemonth, S.Twomonth
FROM R
LEFT JOIN S ON R.Server = S.Server
) AS RAW_DATA
WHERE Date <= Onemonth AND Date >= ServerOpen_Day
GROUP BY Server
ORDER BY Server;

-- LẤY RA PU/REV THEO SERVER:
-- B1: Tạo ra bảng chứa các thông tin nạp:
WITH T AS (
SELECT DISTINCT (transaction.id),
  Date,
  user_id,
  user.role_id AS Role,
  user.server_id AS Server,
  transaction.amount_local AS amount_local
FROM `gamotasdk5.bidata.transactions`
  WHERE app.game_id = '180419'
  AND user.server_id LIKE '230_%' OR user.server_id LIKE '231_%'
),
-- B2: Tạo ra bảng chứa server và ngày đầu tiên có user vào server (coi như là ngày mở server):
S AS (
SELECT DISTINCT (server_id) AS Server, 
  MIN(DATE(date)) AS ServerOpen_Day,
  DATE_ADD(MIN(DATE(date)), INTERVAL 30 DAY) AS Onemonth
FROM `gamotasdk5.bidata.game_roles` 
WHERE game_id = '180419'
  AND server_id LIKE '230_%' OR server_id LIKE '231_%'
GROUP BY Server
)
-- Join 2 bảng lấy ra số PU/ REV trong 30 ngày kể từ ngày ra mắt:
SELECT COUNT(DISTINCT T.User_id) AS PU,
  SUM(T.amount_local) AS Revenue30days,
  S.Server,
  S.ServerOpen_Day,
  S.Onemonth
FROM T
INNER JOIN S ON T.Server = S.Server
WHERE T.Date <= S.Onemonth AND T.Date >= S.ServerOpen_Day
GROUP BY S.Server, S.ServerOpen_Day, S.Onemonth
ORDER BY S.Server;
