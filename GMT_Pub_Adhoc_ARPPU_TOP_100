--hiennt4 

with 
get_transaction as (

    select 
        distinct (transaction.id), user.user_id as user_id, transaction.amount_local as amount_local
    from `gamotasdk5.bidata.transactions`
    where 
       app.game_id = '180941' 
       and date >= "2024-01-01" and date <= "2024-1-31"

    ),

get_amount_per_user as (

    select 
        user_id, sum(amount_local) as rev
    from get_transaction
    group by user_id
       
    ),

get_top_100_pu as (

    select *, RANK() OVER (ORDER BY rev desc) AS rank

    from get_amount_per_user

    )
select *
from get_top_100_pu
order by rank 
limit 100

--quannm2:
--quannm2

--import
with
import_transactions as (
      select *
      from gamotasdk5.tuan_test.stg_gamota_sdk__transactions
      where
            app.game_id = "180941"   
      ),

import_transactions_in_date_range as (
      select 
            import_transactions.*,
            extract(month from date(created_date)) as month,
            extract(year from date(created_date)) as year,
      from import_transactions
      where 
            created_date >= "2023-10-01"
            and created_date <= '2023-12-31' 
      ),


top_100_oct as (
      select 
            month,
            year,
            app.game_id,
            --app.platform,
            user.user_id,
            sum(transaction.transaction_amount_vnd) as total_revenue
      from import_transactions_in_date_range
      where month = 10
      group by 1,2,3,4
      order by total_revenue desc
      limit 100
      ),

top_100_nov as (
      select 
            month,
            year,
            app.game_id,
            --app.platform,
            user.user_id,
            sum(transaction.transaction_amount_vnd) as total_revenue
      from import_transactions_in_date_range
      where month = 11
      group by 1,2,3,4
      order by total_revenue desc
      limit 100
      ),

top_100_dec as (
      select 
            month,
            year,
            app.game_id,
            --app.platform,
            user.user_id,
            sum(transaction.transaction_amount_vnd) as total_revenue
      from import_transactions_in_date_range
      where month = 12
      group by 1,2,3,4
      order by total_revenue desc
      limit 100
      ),

--aggregate
arppu_top_100_oct as (
      select 
            month,
            year,
            game_id,
            sum(total_revenue)/ count (distinct user_id) as arppu
      from top_100_oct
      group by 1,2,3
      ),

arppu_top_100_nov as (
      select 
            month,
            year,
            game_id,
            sum(total_revenue)/ count (distinct user_id) as arppu
      from top_100_nov
      group by 1,2,3
      ),

arppu_top_100_dec as (
      select 
            month,
            year,
            game_id,
            sum(total_revenue)/ count (distinct user_id) as arppu
      from top_100_dec
      group by 1,2,3
      ),

final as (
            (
                  select *
                  from arppu_top_100_oct    
            )
            union all
            (
                  select *
                  from arppu_top_100_nov  
            )
            union all
            (
                  select *
                  from arppu_top_100_dec
            )
            order by month asc
      )

select *
from final


