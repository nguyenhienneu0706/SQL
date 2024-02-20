-- vip MỚI:
with a as (
  select distinct (user_id)
  FROM `gamotasdk5.bidata.game_roles`
  WHERE game_id = '180927'
  and date(date) >= '2023-10-01'
), b as (
SELECT distinct(transaction.id) as id, transaction.amount_local as amount_local, user.user_id as user_id
FROM `gamotasdk5.bidata.transactions`
WHERE app.game_id = '180927'
and date(date) >= '2023-10-01'
)
select b.user_id, sum(amount_local) as rev
from b
inner join a
on b.user_id = a.user_id
group by b.user_id
order by rev desc;

-- check:
SELECT distinct(transaction.id), transaction.amount_local as amount_local, date, created, user.server_name, user.username, user.role_name, app.platform
FROM `gamotasdk5.bidata.transactions`
WHERE app.game_id = '180927'
and user.user_id = 7701931;

SELECT *
FROM `gamotasdk5.bidata.appsflyer_login_postback`
WHERE game_id = '180927'
and user_id = 7701931
