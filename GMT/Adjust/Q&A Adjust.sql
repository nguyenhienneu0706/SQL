-- import
with 
get_adjust_data as (
        select 
                date,
                adid,
                app_id,
                app_name,
                app_name_dashboard,
                event_name,
                event_time,
                country,
                device_name,
                os_name,
                adgroup_name,
                network_name,
                campaign_name,
                created_at,
                installed_at,
                revenue_usd
        from `gamotasdk5.bidata.adjust_postback`
        where app_name_dashboard = 'Alo Chủ Tướng'
        ),

get_first_register_in_time_range as (
        select distinct *
        from 
                (select get_adjust_data.*,
                        row_number() over (partition by adid, app_name_dashboard order by event_time asc) as rn
                from get_adjust_data
                )
        where 
                rn=1
                and date >= '2023-12-11'  
                and date <= '2023-12-20'  
        order by date asc
        ),

get_adjust_transactions as (
        select 
                distinct
                date,
                adid,
                app_id,
                app_name_dashboard,
                os_name,
                network_name,
                sum ( cast (revenue_usd as float64) ) as revenue
        from `gamotasdk5.bidata.adjust_postback`
        where 
                app_name_dashboard = 'Alo Chủ Tướng'
                and revenue_usd != ''
        group by 1,2,3,4,5,6
        ),

get_adjust_transactions_in_time_range as (
        select *
        from get_adjust_transactions
        where 
                date >= '2023-12-11'  
                and date <= '2023-12-20'  
        ),

get_adjust_aggregate_report_in_time_range as (
        select *
        from `gamotasdk5.bidata.adjust_aggregate_report`
        where 
                app='Alo Chủ Tướng'
                and date >= '2023-12-11' 
                and date <= '2023-12-20'  
        ),

--nru
total_nru as (
        select 
                date,
                app_name_dashboard,
                count (distinct adid) as total_nru
        from get_first_register_in_time_range
        group by 1,2
        order by date asc 
        ),

nru_android as (
        select 
                date,
                app_name_dashboard,
                os_name,
                count (distinct adid) as nru_android
        from get_first_register_in_time_range
        where os_name = 'android'
        group by 1,2,3
        order by date asc 
        ),

nru_ios as (
        select 
                date,
                app_name_dashboard,
                os_name,
                count (distinct adid) as nru_ios
        from get_first_register_in_time_range
        where os_name = 'ios'
        group by 1,2,3
        order by date asc 
        ),

--revenue
revenue_android as (
        select 
                date,
                app_name_dashboard,
                os_name,
                round(sum(revenue),2) as revenue_android
        from get_adjust_transactions_in_time_range
        where os_name = 'android'  
        group by 1,2,3
        order by date asc
        ),

revenue_ios as (
        select 
                date,
                app_name_dashboard,
                os_name,
                round(sum(revenue),2) as revenue_ios
        from get_adjust_transactions_in_time_range
        where os_name = 'ios'  
        group by 1,2,3
        order by date asc
        ),

--costs
cost_android_gg_ads as (
        select 
                date,
                app,
                os_name,
                channel,
                round(sum(costs),2) as cost_android_gg_ads
        from get_adjust_aggregate_report_in_time_range
        where 
                os_name = 'android'
                and channel = 'Google Ads'
        group by 1,2,3,4
        order by date asc
        ),  

cost_android_facebook as (
        select 
                date,
                app,
                os_name,
                channel,
                round(sum(costs),2) as cost_android_facebook
        from get_adjust_aggregate_report_in_time_range
        where 
                os_name = 'android'
                and channel = 'Facebook'
        group by 1,2,3,4
        order by date asc
        ),  

cost_android_tiktok as (
        select 
                date,
                app,
                os_name,
                channel,
                round(sum(costs),2) as cost_android_tiktok
        from get_adjust_aggregate_report_in_time_range
        where 
                os_name = 'android'
                and channel = 'TikTok for Business'
        group by 1,2,3,4
        order by date asc
        ), 

cost_ios_gg_ads as (
        select 
                date,
                app,
                os_name,
                channel,
                round(sum(costs),2) as cost_ios_gg_ads
        from get_adjust_aggregate_report_in_time_range
        where 
                os_name = 'ios'
                and channel ='Google Ads'
        group by 1,2,3,4
        order by date asc
        ),     

cost_ios_facebook as (
        select 
                date,
                app,
                os_name,
                channel,
                round(sum(costs),2) as cost_ios_facebook
        from get_adjust_aggregate_report_in_time_range
        where 
                os_name = 'ios'
                and channel = 'Facebook'
        group by 1,2,3,4
        order by date asc
        ),  

cost_ios_tiktok as (
        select 
                date,
                app,
                os_name,
                channel,
                round(sum(costs),2) as cost_ios_tiktok
        from get_adjust_aggregate_report_in_time_range
        where 
                os_name = 'ios'
                and channel = 'TikTok for Business'
        group by 1,2,3,4
        order by date asc
        ), 

--installs
installs_android as (
        select 
                date,
                app,
                os_name,
                sum(installs) as installs_android
        from get_adjust_aggregate_report_in_time_range
        where os_name = 'android'
        group by 1,2,3
        order by date asc
        ),

installs_ios as (
        select 
                date,
                app,
                os_name,
                sum(installs) as installs_ios
        from get_adjust_aggregate_report_in_time_range
        where os_name = 'ios'
        group by 1,2,3
        order by date asc
        ),

installs_android_gg_ads as (
        select 
                date,
                app,
                os_name,
                channel,
                sum(installs) as installs_android_gg_ads
        from get_adjust_aggregate_report_in_time_range
        where 
                os_name = 'android'
                and channel = 'Google Ads'
        group by 1,2,3,4
        order by date asc
        ),     

installs_android_facebook as (
        select 
                date,
                app,
                os_name,
                channel,
                sum(installs) as installs_android_facebook
        from get_adjust_aggregate_report_in_time_range
        where 
                os_name = 'android'
                and channel = 'Facebook'
        group by 1,2,3,4
        order by date asc
        ),  

installs_android_tiktok as (
        select 
                date,
                app,
                os_name,
                channel,
                sum(installs) as installs_android_tiktok
        from get_adjust_aggregate_report_in_time_range
        where 
                os_name = 'android'
                and channel = 'TikTok for Business'
        group by 1,2,3,4
        order by date asc
        ), 

installs_ios_gg_ads as (
        select 
                date,
                app,
                os_name,
                channel,
                sum(installs) as installs_ios_gg_ads
        from get_adjust_aggregate_report_in_time_range
        where 
                os_name = 'ios'
                and channel = 'Google Ads'
        group by 1,2,3,4
        order by date asc
        ),     

installs_ios_facebook as (
        select 
                date,
                app,
                os_name,
                channel,
                sum(installs) as installs_ios_facebook
        from get_adjust_aggregate_report_in_time_range
        where 
                os_name = 'ios'
                and channel = 'Facebook'
        group by 1,2,3,4
        order by date asc
        ),  

installs_ios_tiktok as (
        select 
                date,
                app,
                os_name,
                channel,
                sum(installs) as installs_ios_tiktok
        from get_adjust_aggregate_report_in_time_range
        where 
                os_name = 'ios'
                and channel = 'TikTok for Business'
        group by 1,2,3,4
        order by date asc
        ),

-- revenue nru
revenue_nru_android as (
        select 
                date,
                app_name_dashboard,
                os_name,
                round(sum(revenue),2) as revenue_nru_android
        from
                (
                select 
                        get_first_register_in_time_range.date,
                        get_first_register_in_time_range.adid,
                        get_first_register_in_time_range.app_name_dashboard,
                        get_first_register_in_time_range.os_name,
                        get_adjust_transactions_in_time_range.date as transaction_date,
                        get_adjust_transactions_in_time_range.revenue
                from 
                        (select *
                        from get_first_register_in_time_range 
                        where os_name ='android'
                        ) as get_first_register_in_time_range
                left join 
                        get_adjust_transactions_in_time_range 
                        on get_first_register_in_time_range.adid = get_adjust_transactions_in_time_range.adid
                        and get_first_register_in_time_range.app_name_dashboard = get_adjust_transactions_in_time_range.app_name_dashboard
                        and get_first_register_in_time_range.os_name = get_adjust_transactions_in_time_range.os_name
                )
        group by 1,2,3
        order by date asc
        ),

revenue_nru_ios as (
        select 
                date,
                app_name_dashboard,
                os_name,
                round(sum(revenue),2) as revenue_nru_ios
        from
                (
                select 
                        get_first_register_in_time_range.date,
                        get_first_register_in_time_range.adid,
                        get_first_register_in_time_range.app_name_dashboard,
                        get_first_register_in_time_range.os_name,
                        get_adjust_transactions_in_time_range.date as transaction_date,
                        get_adjust_transactions_in_time_range.revenue
                from 
                        (select *
                        from get_first_register_in_time_range 
                        where os_name ='ios'
                        ) as get_first_register_in_time_range
                left join 
                        get_adjust_transactions_in_time_range 
                        on get_first_register_in_time_range.adid = get_adjust_transactions_in_time_range.adid
                        and get_first_register_in_time_range.app_name_dashboard = get_adjust_transactions_in_time_range.app_name_dashboard
                        and get_first_register_in_time_range.os_name = get_adjust_transactions_in_time_range.os_name
                )
        group by 1,2,3
        order by date asc
        ),

final as (
        select 
                total_nru.date,
                total_nru.app_name_dashboard,
                total_nru.total_nru,
                --nru
                nru_android.nru_android,
                nru_ios.nru_ios,
                --revenue
                revenue_android.revenue_android,
                revenue_ios.revenue_ios,
                --cost
                cost_android_gg_ads.cost_android_gg_ads,
                cost_android_facebook.cost_android_facebook,
                cost_android_tiktok.cost_android_tiktok,
                cost_ios_gg_ads.cost_ios_gg_ads,
                cost_ios_facebook.cost_ios_facebook,
                cost_ios_tiktok.cost_ios_tiktok,
                --install
                installs_android.installs_android,
                installs_ios.installs_ios,
                installs_android_gg_ads.installs_android_gg_ads,
                installs_android_facebook.installs_android_facebook,
                installs_android_tiktok.installs_android_tiktok,
                installs_ios_gg_ads.installs_ios_gg_ads,
                installs_ios_facebook.installs_ios_facebook,
                installs_ios_tiktok.installs_ios_tiktok,
                --revenue nru
                revenue_nru_android.revenue_nru_android,
                revenue_nru_ios.revenue_nru_ios
        from total_nru
        --nru
        left join 
                nru_android
                on total_nru.date = nru_android.date
                and total_nru.app_name_dashboard = nru_android.app_name_dashboard
        left join 
                nru_ios
                on total_nru.date = nru_ios.date
                and total_nru.app_name_dashboard = nru_ios.app_name_dashboard
        --revenue
        left join 
                revenue_android
                on total_nru.date = revenue_android.date
                and total_nru.app_name_dashboard = revenue_android.app_name_dashboard
        left join 
                revenue_ios
                on total_nru.date = revenue_ios.date
                and total_nru.app_name_dashboard = revenue_ios.app_name_dashboard
        --cost
        left join 
                cost_android_gg_ads
                on total_nru.date = cost_android_gg_ads.date
                and total_nru.app_name_dashboard = cost_android_gg_ads.app
        left join 
                cost_android_facebook
                on total_nru.date = cost_android_facebook.date
                and total_nru.app_name_dashboard = cost_android_facebook.app
        left join 
                cost_android_tiktok
                on total_nru.date = cost_android_tiktok.date
                and total_nru.app_name_dashboard = cost_android_tiktok.app
        left join 
                cost_ios_gg_ads
                on total_nru.date = cost_ios_gg_ads.date
                and total_nru.app_name_dashboard = cost_ios_gg_ads.app
        left join 
                cost_ios_facebook
                on total_nru.date = cost_ios_facebook.date
                and total_nru.app_name_dashboard = cost_ios_facebook.app
        left join 
                cost_ios_tiktok
                on total_nru.date = cost_ios_tiktok.date
                and total_nru.app_name_dashboard = cost_ios_tiktok.app
        --install
        left join 
                installs_android
                on total_nru.date = installs_android.date
                and total_nru.app_name_dashboard = installs_android.app
        left join 
                installs_ios
                on total_nru.date = installs_ios.date
                and total_nru.app_name_dashboard = installs_ios.app
        left join 
                installs_android_gg_ads
                on total_nru.date = installs_android_gg_ads.date
                and total_nru.app_name_dashboard = installs_android_gg_ads.app
        left join 
                installs_android_facebook
                on total_nru.date = installs_android_facebook.date
                and total_nru.app_name_dashboard = installs_android_facebook.app
        left join 
                installs_android_tiktok
                on total_nru.date = installs_android_tiktok.date
                and total_nru.app_name_dashboard = installs_android_tiktok.app
        left join 
                installs_ios_gg_ads
                on total_nru.date = installs_ios_gg_ads.date
                and total_nru.app_name_dashboard = installs_ios_gg_ads.app
        left join 
                installs_ios_facebook
                on total_nru.date = installs_ios_facebook.date
                and total_nru.app_name_dashboard = installs_ios_facebook.app
        left join 
                installs_ios_tiktok
                on total_nru.date = installs_ios_tiktok.date
                and total_nru.app_name_dashboard = installs_ios_tiktok.app
        --revenue nru
        left join 
                revenue_nru_android
                on total_nru.date = revenue_nru_android.date
                and total_nru.app_name_dashboard = revenue_nru_android.app_name_dashboard
        left join 
                revenue_nru_ios
                on total_nru.date = revenue_nru_ios.date
                and total_nru.app_name_dashboard = revenue_nru_ios.app_name_dashboard
        )



select 
        app_name_dashboard,
        sum(revenue_android) as revenue_android,
        sum(revenue_ios) as revenue_ios,
        sum(revenue_nru_android) as revenue_nru_android,
        sum(revenue_nru_ios) as revenue_nru_ios
from final
group by app_name_dashboard
