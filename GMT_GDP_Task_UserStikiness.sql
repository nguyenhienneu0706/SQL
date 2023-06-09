/* TASK: USER STICKINESS */
-- 1. Lượng active old users qua mỗi ngày:
WITH FIRST_LOGIN AS (
SELECT user_id, MIN(Date) AS first_login_date
FROM `gamotasdk5.bidata.appsflyer_login_postback`
WHERE game_id = 180941 AND (Date <= "2023-05-26" AND Date >= "2023-04-27")
GROUP BY user_id
),
LOGIN AS (
SELECT AF_LOGIN.user_id, Date, FIRST_LOGIN.first_login_date
FROM `gamotasdk5.bidata.appsflyer_login_postback` AS AF_LOGIN
FULL JOIN FIRST_LOGIN ON FIRST_LOGIN.user_id = AF_LOGIN.user_id
WHERE game_id = 180941 AND (Date <= "2023-05-26" AND Date >= "2023-04-27")
)
SELECT LOGIN.Date, COUNT(DISTINCT LOGIN.user_id) AS AOU
FROM LOGIN 
WHERE LOGIN.Date > LOGIN.First_login_date
GROUP BY LOGIN.Date;

-- 1.1. Lượng NRU qua mỗi ngày:
WITH FIRST_LOGIN AS (
SELECT user_id, MIN(Date) AS first_login_date
FROM `gamotasdk5.bidata.appsflyer_login_postback`
WHERE game_id = 180941 AND (Date <= "2023-05-26" AND Date >= "2023-04-27")
GROUP BY user_id
),
LOGIN AS (
SELECT AF_LOGIN.user_id, Date, FIRST_LOGIN.first_login_date
FROM `gamotasdk5.bidata.appsflyer_login_postback` AS AF_LOGIN
FULL JOIN FIRST_LOGIN ON FIRST_LOGIN.user_id = AF_LOGIN.user_id
WHERE game_id = 180941 AND (Date <= "2023-05-26" AND Date >= "2023-04-27")
)
SELECT LOGIN.Date, COUNT(DISTINCT LOGIN.user_id) AS NRU
FROM LOGIN 
WHERE LOGIN.Date = LOGIN.First_login_date
GROUP BY LOGIN.Date;

-- 2. Thời gian truy cập app (KHÔNG TÍNH ĐƯỢC DO THIẾU EVENT_LOGOUT)
-- 3. Số lần truy cập của 1 user trong ngày:
-- 3.1: Bảng đánh số thứ tự mỗi lần login của user mỗi ngày
WITH A AS (
WITH user_access AS (
SELECT user_id, Date, event_time,
  ROW_NUMBER() OVER (PARTITION BY Date, user_id ORDER BY Date) AS access_rank
FROM `gamotasdk5.bidata.appsflyer_login_postback`
WHERE game_id = 180941 AND (Date <= "2023-05-26" AND Date >= "2023-04-27")
ORDER BY user_id, Date)

-- 3.2: Lấy ra số lần đăng nhập:
SELECT user_id, date, MAX(Access_rank) AS NoAccess_per_day_by_user, 
FROM user_access
GROUP BY user_id, date
ORDER BY user_id, date
)
SELECT COUNT(USER_ID) AS no_user, 
CASE WHEN NoAccess_per_day_by_user <= 3 THEN "0->3"
  WHEN NoAccess_per_day_by_user <= 10 THEN "4->10"
  WHEN NoAccess_per_day_by_user <= 30 THEN "11->30"
  ELSE ">30"
END AS PHANTO
FROM A
GROUP BY PHANTO

-- Lấy ra thông tin những user đăng nhập > 30 lần/ ngày

-- Lấy ra thông tin những user đăng nhập > 30 lần/ ngày
WITH user_access AS (
  SELECT user_id, Date, event_time,
    ROW_NUMBER() OVER (PARTITION BY Date, user_id ORDER BY Date) AS access_rank
  FROM `gamotasdk5.bidata.appsflyer_login_postback`
  WHERE game_id = 180941 AND (Date <= "2023-05-26" AND Date >= "2023-04-27")
  ORDER BY user_id, Date
),
A AS (
  SELECT UA.user_id, UA.date, MAX(UA.access_rank) AS NoAccess_per_day_by_user,
    AF.platform, AF.country_code, AF.media_source, GR.device_id
  FROM user_access AS UA
  left JOIN `gamotasdk5.bidata.appsflyer_login_postback` AS AF
    ON UA.user_id = AF.user_id
      left JOIN `gamotasdk5.bidata.game_roles` AS GR
    ON UA.user_id = GR.user_id
  GROUP BY UA.user_id, UA.date, AF.platform, AF.country_code, AF.media_source, GR.device_id
    HAVING MAX(UA.access_rank) > 50
)
SELECT *
FROM A;
---------------------------------------------------------------------------------------------------------------------

-- 1. LẤY RA ACTIVE USER:

-- Thử bảng login_logs:
WITH LOGIN AS (
  SELECT userinfo.user_id, date AS login_date
  FROM `gamotasdk5.bidata.login_logs`
  WHERE appinfo.game_id = 180941 AND (Date <= "2023-05-26" AND Date >= "2023-04-28")
  -- Mình muốn lấy Old User chỉ cần lấy những thằng đã từng có đăng nhập trước đó là được
)
SELECT LOGIN.login_date,
  COUNT(DISTINCT user_id) AS AU
FROM LOGIN 
GROUP BY LOGIN.login_date
ORDER BY login_date ASC;
-- Kết quả trả về là Active User (check với Ana chỉ số DAU không chênh lệch nhiều)

-- Sau đó tạo ra bằng chứa cả ngày login và ngày login đầu tiên bằng cách tìm ra ngày login đầu tiên của user đó, với điều kiện lần đăng nhập đầu tiên < khoảng thời gian là ok
-- Bước 1: Tạo ra bảng chứa dữ liệu
-- CÁCH 1:
WITH FIRST_LOGIN AS (
  SELECT userinfo.user_id, MIN(Date) AS first_login_date
  FROM `gamotasdk5.bidata.login_logs`
  WHERE appinfo.game_id = 180941 AND (Date <= "2023-05-26" AND Date >= "2023-04-27")
  GROUP BY userinfo.user_id
), LOGIN AS (
  SELECT userinfo.user_id, Date AS login_date
  FROM `gamotasdk5.bidata.login_logs`
  WHERE appinfo.game_id = 180941 AND (Date <= "2023-05-26" AND Date >= "2023-04-27")
)
SELECT LOGIN.user_id, LOGIN.login_date, FIRST_LOGIN.first_login_date
FROM LOGIN
FULL JOIN FIRST_LOGIN ON FIRST_LOGIN.user_id = LOGIN.user_id;

-- CÁCH 2:
WITH FIRST_LOGIN AS (
SELECT userinfo.user_id, MIN(Date) AS first_login_date
FROM `gamotasdk5.bidata.login_logs`
WHERE appinfo.game_id = 180941 AND (Date <= "2023-05-26" AND Date >= "2023-04-27")
GROUP BY userinfo.user_id
)
SELECT LOGIN.userinfo.user_id, LOGIN.date, FIRST_LOGIN.first_login_date
FROM `gamotasdk5.bidata.login_logs` AS LOGIN
FULL JOIN FIRST_LOGIN ON FIRST_LOGIN.user_id = LOGIN.userinfo.user_id
WHERE appinfo.game_id = 180941 AND (Date <= "2023-05-26" AND Date >= "2023-04-27");

-- Bước 2: Lấy ra AOU
-- Cách 1: (CHƯA TỐI ƯU TỐT)
WITH A AS (
  WITH FIRST_LOGIN AS (
  SELECT userinfo.user_id, MIN(Date) AS first_login_date
  FROM `gamotasdk5.bidata.login_logs`
  WHERE appinfo.game_id = 180941 AND (Date <= "2023-05-26" AND Date >= "2023-04-27")
  GROUP BY userinfo.user_id
), LOGIN AS (
  SELECT userinfo.user_id, Date AS login_date
  FROM `gamotasdk5.bidata.login_logs`
  WHERE appinfo.game_id = 180941 AND (Date <= "2023-05-26" AND Date >= "2023-04-27")
)
SELECT LOGIN.user_id, LOGIN.login_date, FIRST_LOGIN.first_login_date
FROM LOGIN
FULL JOIN FIRST_LOGIN ON FIRST_LOGIN.user_id = LOGIN.user_id
)
SELECT login_date, COUNT(DISTINCT user_id)
FROM A
WHERE login_date > first_login_date
GROUP BY login_date;

-- Cách 2:
SELECT A.Date, COUNT(DISTINCT A.user_id)
FROM
(
WITH FIRST_LOGIN AS (
SELECT userinfo.user_id, MIN(Date) AS first_login_date
FROM `gamotasdk5.bidata.login_logs`
WHERE appinfo.game_id = 180941 AND (Date <= "2023-05-26" AND Date >= "2023-04-27")
GROUP BY userinfo.user_id
)
SELECT LOGIN.userinfo.user_id, LOGIN.Date, FIRST_LOGIN.first_login_date
FROM `gamotasdk5.bidata.login_logs` AS LOGIN
FULL JOIN FIRST_LOGIN ON FIRST_LOGIN.user_id = LOGIN.userinfo.user_id
WHERE appinfo.game_id = 180941 AND (Date <= "2023-05-26" AND Date >= "2023-04-27")
) AS A
WHERE A.Date > A.First_login_date
GROUP BY A.Date;

-- CÁCH 3: (Tối ưu nhất)
WITH FIRST_LOGIN AS (
SELECT userinfo.user_id, MIN(Date) AS first_login_date
FROM `gamotasdk5.bidata.login_logs`
WHERE appinfo.game_id = 180941 AND (Date <= "2023-05-26" AND Date >= "2023-04-27")
GROUP BY userinfo.user_id
),
LOGIN AS (
SELECT userinfo.user_id, Date, FIRST_LOGIN.first_login_date
FROM `gamotasdk5.bidata.login_logs` 
FULL JOIN FIRST_LOGIN ON FIRST_LOGIN.user_id = userinfo.user_id
WHERE appinfo.game_id = 180941 AND (Date <= "2023-05-26" AND Date >= "2023-04-27")
)
SELECT A.Date, COUNT(DISTINCT A.user_id)
FROM LOGIN AS A
WHERE A.Date > A.First_login_date
GROUP BY A.Date;
