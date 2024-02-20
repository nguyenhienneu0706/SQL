-- Rev 30: user & game

with a as 
(
  select distinct (user_id), 
    date as register_date, 
    date + 120 as date30, 
    game_id
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
    app.game_id as game_id
  FROM `gamotasdk5.bidata.transactions`
  WHERE app.game_id in ("180941", "180150", "180419", "180730", "180534", "180886", "180915", "180927", "180937", "180872")
), 
c as (
select pay_date, game_id, user_id, sum(amount_local) as rev
from b
group by user_id, game_id, pay_date
)
select sum(rev) as rev30
from a
  left join c
  on c.user_id = a.user_id 
where a.register_date <= c.pay_date and c.pay_date <= a.date30 
order by rev30 desc;

-- Rev 30: user
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
  on b.user_id = a.user_id
where a.register_date <= b.pay_date and b.pay_date <= a.date30 
order by rev desc;
