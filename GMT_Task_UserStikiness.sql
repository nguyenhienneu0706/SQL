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
