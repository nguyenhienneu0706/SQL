-- Lấy NRU ngày đầu: 

WITH A AS 
(
SELECT distinct user_id, date as date, date + 7 as date7, date + 30 as date30
FROM
  `gamotasdk5.bidata.register_logs`
WHERE game_id in  ('180419', '180150', '180534', '180915')
AND date >= '2023-01-01' and date <= '2023-12-31'
), 
B AS 
(
SELECT distinct (userinfo.user_id) AS user_id, date as logindate
FROM
  `gamotasdk5.bidata.login_logs`
WHERE appinfo.game_id in  ('180419', '180150', '180534', '180915')
AND date >= '2023-01-01'
) 
SELECT 
count( distinct A.user_id), a.date
FROM A
group by a.date
order by a.date;

-- Lấy NRU ngày 7:

WITH A AS 
(
SELECT distinct user_id, date as date, date + 7 as date7, date + 30 as date30
FROM
  `gamotasdk5.bidata.register_logs`
WHERE game_id in  ('180419', '180150', '180534', '180915')
AND date >= '2023-01-01' and date <= '2023-12-31'
), 
B AS 
(
SELECT distinct (userinfo.user_id) AS user_id, date as logindate
FROM
  `gamotasdk5.bidata.login_logs`
WHERE appinfo.game_id in  ('180419', '180150', '180534', '180915')
AND date >= '2023-01-01'
) 
SELECT 
count( distinct A.user_id), a.date
FROM A
Left join B
on  A.user_id =  B.user_id
where b.logindate = a.date7 
group by a.date
order by a.date
