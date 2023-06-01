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
