-- Rev full năm:

with a as 
(
  select distinct (user_id), 
    date as register_date, 
    date + 30 as date30, 
    game_id, 
    app_id
  from `gamotasdk5.bidata.register_logs`
  where game_id in ("180941", "180150", "180419", "180730", "180534", "180886", "180915", "180927", "180937", "180872")
    and date(date) >= '2023-01-01'
    and date(date) <= '2023-12-31'
), 
b as 
(
  SELECT distinct(transaction.id) as id, 
    transaction.amount_local as amount_local, 
    user.user_id as user_id, 
    date as pay_date, 
    app.app_id as app_id, 
    app.game_id as game_id
  FROM `gamotasdk5.bidata.transactions`
  WHERE app.game_id in ("180941", "180150", "180419", "180730", "180534", "180886", "180915", "180927", "180937", "180872")
    and date(date) >= '2022-01-01'
    and date(date) <= '2022-12-31'
)
select  sum(amount_local)
from b;

-- Rev 30:

with a as 
(
  select distinct (user_id), 
    date as register_date, 
    date + 60 as date30, 
    game_id
  from `gamotasdk5.bidata.register_logs`
  where game_id in ("180941", "180150", "180419", "180730", "180534", "180886", "180915", "180927", "180937", "180872")
    and date(date) >= '2022-01-01'
    and date(date) <= '2022-12-31'
), 
b as 
(
  SELECT distinct(transaction.id) as id, 
    transaction.amount_local as amount_local, 
    user.user_id as user_id, 
    date as pay_date, 
    app.game_id as game_id
  FROM `gamotasdk5.bidata.transactions`
  WHERE app.game_id in ("180941", "180150", "180419", "180730", "180534", "180886", "180915", "180927", "180937", "180872")
)
select sum(amount_local) as rev
from a
  left join b
  on b.user_id = a.user_id and a.game_id = b.game_id
where a.register_date <= b.pay_date and b.pay_date <= a.date30 
order by rev desc;
