-- LẤY RA NRU ORGANIC/PAID CỦA GAME ACT:

--- a) Dựa trên số Ana
-- B1: Tạo ra bảng chứa role_id không bị trùng lặp (số NRU):
WITH R AS (
  SELECT DISTINCT (role_id) AS Role,
  user_id AS User,
  FROM `gamotasdk5.bidata.game_roles` 
  WHERE game_id = '180941'
    AND date >= "2023-07-01" AND date <= "2023-07-16"
    AND server_id LIKE '300%'
  ),
  -- B2: Tạo ra bảng chứa thông tin quảng cáo:
AF AS (
  SELECT DISTINCT (user_id) AS User,
  platform AS Platform,
  media_source AS Media_sourse
  FROM `gamotasdk5.bidata.appsflyer_login_postback` 
  WHERE game_id = '180941'
    AND date >= "2023-07-01" AND date <= "2023-07-16"
    AND platform = 'ios'
    AND media_source = 'organic'
)
  -- B3: Join 2 bảng lấy ra số NRU Organic IOS từ ngày 01-16/07:
SELECT DISTINCT (R.Role) AS NRU,
  AF.Platform,
  AF.Media_sourse,
FROM R
INNER JOIN AF ON R.User = AF.User

--- b) Dựa trên số AF
-- B1: Tạo ra bảng chứa role_id không bị trùng lặp (số NRU):
WITH R AS (
  SELECT DISTINCT (role_id) AS Role,
  user_id AS User,
  FROM `gamotasdk5.bidata.game_roles` 
  WHERE game_id = '180941'
    AND date >= "2023-07-01" AND date <= "2023-07-16"
    AND server_id LIKE '300%'
  ),
  -- B2: Tạo ra bảng chứa thông tin quảng cáo:
AF AS (
  SELECT DISTINCT (user_id) AS User,
  platform AS Platform,
  media_source AS Media_sourse
  FROM `gamotasdk5.bidata.appsflyer_login_postback` 
  WHERE game_id = '180941'
    AND date >= "2023-07-01" AND date <= "2023-07-16"
    AND platform = 'ios'
    AND media_source = 'organic'
)
  -- B3: Join 2 bảng lấy ra số NRU Organic IOS từ ngày 01-16/07:
SELECT DISTINCT (AF.User) AS NRU,
  AF.Platform,
  AF.Media_sourse,
FROM R
INNER JOIN AF ON R.User = AF.User
