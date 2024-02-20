WITH A AS 
(
SELECT
  user_id,
  server_id,
  first_date, 
  DATE_ADD(first_date, INTERVAL 120 DAY) AS end_date
FROM `gamotasdk5.bidata.temp_trutien_nru_server`
),
B AS (
SELECT DISTINCT (Transaction.id), user.user_id, date, user.server_id, transaction.amount_local
FROM `gamotasdk5.bidata.transactions`
WHERE app.game_id = '180419'
  AND (user.server_id LIKE '230_%' OR user.server_id LIKE '231_%')
)
-- SELECT A.user_id, B.user.user_id, A.server_id, B.user.server_id, A.first_date, A.end_date, B.transaction.amount_local, B.date --Thử xem raw của bảng này
-- FROM A
-- LEFT JOIN `gamotasdk5.bidata.transactions` AS B
-- ON A.user_id = B.user.user_id AND A.server_id = B.user.server_id
-- WHERE B.date <= A.end_date AND B.date >= A.first_date;
SELECT A.server_id, SUM(B.transaction.amount_local) AS acc_rev_120
FROM A
LEFT JOIN `gamotasdk5.bidata.transactions` AS B
ON A.user_id = B.user.user_id AND A.server_id = B.user.server_id
WHERE B.date <= A.end_date AND B.date >= A.first_date
GROUP BY A.server_id;
