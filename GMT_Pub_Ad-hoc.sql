----- KIỂM CHỨNG XEM BAO NHIÊU NRU (HOẶC PU) TRONG MỘT SERVER LÀ TỐT NHẤT - GAME TRU TIÊN -----

-- LẤY RA NRU THEO SERVER:
-- B1: Tạo ra bảng chứa role_id không bị trùng lặp (số NRU):
WITH R AS (
  SELECT DISTINCT role_id AS Role,
    DATE(Date) AS Date,
    server_id AS Server,
    game_id AS Game
  FROM `gamotasdk5.bidata.game_roles` 
  WHERE game_id = '180419'
  AND server_id LIKE '230%' OR server_id LIKE '231%'
),
-- B2: Tạo ra bảng chứa server và ngày đầu tiên có user vào server (coi như là ngày mở server):
S AS (
SELECT DISTINCT server_id AS Server, 
  MIN(DATE(date)) AS ServerOpen_Day,
  DATE_ADD(MIN(DATE(date)), INTERVAL 30 DAY) AS Onemonth
FROM `gamotasdk5.bidata.game_roles` 
WHERE game_id = '180419'
  AND server_id LIKE '230%' OR server_id LIKE '231%'
GROUP BY Server
)
-- Join 2 bảng lấy ra số NRU trong 30 ngày kể từ ngày ra mắt:
SELECT COUNT(DISTINCT R.Role) AS AU,
  R.Server,
  S.ServerOpen_Day,
  S.Onemonth
FROM R
LEFT JOIN S ON R.Server = S.Server
WHERE Date <= S.Onemonth AND Date >= S.ServerOpen_Day
GROUP BY R.Server, S.ServerOpen_Day, S.Onemonth
ORDER BY R.Server;

-- LẤY RA PU/REV THEO SERVER:
-- B1: Tạo ra bảng chứa các thông tin nạp:
WITH T AS (
SELECT DISTINCT (transaction.id),
  Date,
  user.role_id AS Role,
  user.server_id AS Server,
  transaction.amount_local AS amount_local
FROM `gamotasdk5.bidata.transactions`
  WHERE app.game_id = '180419'
  AND user.server_id LIKE '230%' OR user.server_id LIKE '231%'
),
-- B2: Tạo ra bảng chứa server và ngày đầu tiên có user vào server (coi như là ngày mở server):
S AS (
SELECT DISTINCT (server_id) AS Server, 
  MIN(DATE(date)) AS ServerOpen_Day,
  DATE_ADD(MIN(DATE(date)), INTERVAL 30 DAY) AS Onemonth
FROM `gamotasdk5.bidata.game_roles` 
WHERE game_id = '180419'
  AND server_id LIKE '230%' OR server_id LIKE '231%'
GROUP BY Server
)
-- Join 2 bảng lấy ra số PU/ REV trong 30 ngày kể từ ngày ra mắt:
SELECT COUNT(DISTINCT T.Role) AS PU,
  SUM(T.amount_local) AS Revenue30days,
  S.Server,
  S.ServerOpen_Day,
  S.Onemonth
FROM T
INNER JOIN S ON T.Server = S.Server
WHERE T.Date <= S.Onemonth AND T.Date >= S.ServerOpen_Day
GROUP BY S.Server, S.ServerOpen_Day, S.Onemonth
ORDER BY S.Server;
