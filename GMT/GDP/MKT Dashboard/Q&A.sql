with
    -- gdp-staging.bidata.appsflyer_aggregate_report (return
    -- final_appsflyer_aggregate_report )
    af as (
        select
            date,
            game_id as gma_id,
            case
                when game_id = 'GMA0131'
                then '180941'
                when game_id = 'GMA0077'
                then '180534'
                when game_id = 'GMA0130'
                then '180937'
                when game_id = 'GMA0110'
                then '180886'
                when game_id = 'GMA0124'
                then '180915'
                when game_id = 'GMA0127'
                then '180927'
                when game_id = 'GMA0072'
                then '180419'
                when game_id = 'GMA0062'
                then '180150'
                else null
            end as game_id,
            platform,
            case
                when
                    media_source in (
                        'googleadwords_int',
                        'bytedanceglobal_int',
                        'tiktokglobal_int',
                        'mintegral_int',
                        'ldplayer_int',
                        'bluestacks_int',
                        'moloco_int',
                        'instantmetric_int',
                        'bignox_int',
                        'unityads_int',
                        'gxmedia_int',
                        'redhotads4i_int',
                        'toplinemeu4_int',
                        'uuumedia_int',
                        'Facebook Ads',
                        'Apple Search Ads'
                    )
                then 'non_organic'
                else 'organic'
            end as media_type,
            case
                when media_source = 'googleadwords_int'
                then 'Google Ads'
                when
                    media_source = 'tiktokglobal_int'
                    or media_source = 'bytedanceglobal_int'
                then 'Tiktok Ads'
                when media_source = 'Facebook Ads'
                then 'Meta Ads'
                when media_source = 'Apple Search Ads'
                then 'Apple Search Ads'
                when media_source = 'mintegral_int'
                then 'Mintegral'
                when media_source = 'ldplayer_int'
                then 'ldplayer'
                when media_source = 'bluestacks_int'
                then 'Bluestacks'
                when media_source = 'moloco_int'
                then 'Moloco'
                when media_source = 'instantmetric_int'
                then 'Instantmetric'
                when media_source = 'bignox_int'
                then 'Bignox'
                when media_source = 'unityads_int'
                then 'Unityads'
                when media_source = 'gxmedia_int'
                then 'GXmedia'
                when media_source = 'redhotads4i_int'
                then 'Redhotads4i'
                when media_source = 'toplinemeu4_int'
                then 'Toplinemeu4'
                when media_source = 'uuumedia_int'
                then 'Uuumedia'
                when
                    media_source in (
                        'organic',
                        'ReviewGame',
                        'Trang Chủ_AND',
                        'Social',
                        'IAmNar',
                        'toplinemeu4_int',
                        'Momo',
                        'KOLs',
                        'Website',
                        'TruTienMomo',
                        'AHXDMomo',
                        'Landing DK',
                        'PR',
                        'Tracking MV',
                        'Nạp Gamota',
                        'TamQuocTest',
                        'Gamota fanpage',
                        'endy',
                        'WebGamota-AND',
                        'web',
                        'TranMa_Test',
                        'TQLT_Test',
                        'Tiktok Fanpage',
                        'PhongLang_Test',
                        'Tru Tiên - Test',
                        'Social_facebook',
                        'User_invite',
                        'Web Gamota - IOS',
                        'Social_Campaign',
                        'Kol',
                        'WEB GAMOTA',
                        'Cross Game',
                        'Trang Chủ_IOS',
                        'CrossTraffic',
                        'prmoi',
                        'fanpage',
                        'ReviewGame',
                        'Trang Chủ_AND'
                    )
                then 'Organic'
                else 'Others'
            end as channel,
            campaign as campaign_name,
            max(impressions) as impressions,
            max(clicks) as clicks,
            max(installs) as installs,
            max(total_revenue) as total_revenue,
            max(total_cost) as total_cost,
            max(total_cost_local) as total_cost_local
        from `gamotasdk5.bidata.appsflyer_aggregate_report`
        group by date, gma_id, game_id, platform, media_type, channel, campaign_name
    ),
    final_appsflyer_aggregate_report as (
        select
            date,
            gma_id,
            game_id,
            platform,
            media_type,
            channel,
            campaign_name,
            cast(impressions as int64) as impressions,
            cast(clicks as int64) as clicks,
            cast(installs as int64) as installs,
            cast(total_revenue as float64) as total_revenue,
            cast(total_cost as float64) as total_cost,
            cast(total_cost_local as float64) as total_cost_local
        from af
    ),
    -- gdp-staging.bidata.sdk_first_login (return final_sdk_first_login)
    first_login as (
        select user_id, game_id, app_id, min(event_time) as first_login
        from `gamotasdk5.bidata.appsflyer_login_postback`
        group by user_id, game_id, app_id
    ),
    login as (
        select distinct
            fl.first_login,
            fl.user_id,
            fl.game_id,
            fl.app_id,
            af.platform,
            af.media_source,
            case
                when
                    media_source in (
                        'googleadwords_int',
                        'bytedanceglobal_int',
                        'tiktokglobal_int',
                        'mintegral_int',
                        'ldplayer_int',
                        'bluestacks_int',
                        'moloco_int',
                        'instantmetric_int',
                        'bignox_int',
                        'unityads_int',
                        'gxmedia_int',
                        'redhotads4i_int',
                        'toplinemeu4_int',
                        'uuumedia_int',
                        'Facebook Ads',
                        'Apple Search Ads'
                    )
                then 'non_organic'
                else 'organic'
            end as media_type,
            case
                when media_source = 'googleadwords_int'
                then 'Google Ads'
                when
                    media_source = 'tiktokglobal_int'
                    or media_source = 'bytedanceglobal_int'
                then 'Tiktok Ads'
                when media_source = 'Facebook Ads'
                then 'Meta Ads'
                when media_source = 'Apple Search Ads'
                then 'Apple Search Ads'
                when media_source = 'mintegral_int'
                then 'Mintegral'
                when media_source = 'ldplayer_int'
                then 'ldplayer'
                when media_source = 'bluestacks_int'
                then 'Bluestacks'
                when media_source = 'moloco_int'
                then 'Moloco'
                when media_source = 'instantmetric_int'
                then 'Instantmetric'
                when media_source = 'bignox_int'
                then 'Bignox'
                when media_source = 'unityads_int'
                then 'Unityads'
                when media_source = 'gxmedia_int'
                then 'GXmedia'
                when media_source = 'redhotads4i_int'
                then 'Redhotads4i'
                when media_source = 'toplinemeu4_int'
                then 'Toplinemeu4'
                when media_source = 'uuumedia_int'
                then 'Uuumedia'
                else 'Organic'
            end as channel,
            af.device_id,
            case
                when
                    device_id in (
                        '98135605-ff41-44a1-b764-f1256dd13135',  -- gmo-646acc62cfc1af2bbc466b04
                        '76d1434c-9905-4736-bcce-3cbac0878692',  -- gmo-643f74e29d5e0515c1605631
                        'b3e6b703-d32a-487c-b859-9b16b4891ef5',  -- gmo-6459fa4acf75462ba9bfaf58
                        'ebc6653e-db85-48a6-bba7-819922a17af2',  -- gmo-645f0d2c86f3e914f82c97e3
                        'eb5d1d80-1d51-4a53-b784-8175a935c711',  -- gmo-646f0cfd65be27231eba4d95
                        'f4d2858d-87ae-4e6a-8e4a-6c6f370f48f5',  -- gmo-646b1dcc67287128be1bdb3f
                        '4721fa11-c2dc-41cd-97b3-0d046bf7049b',  -- gmo-64e45e9b60e9bd0fb5e3e826
                        '33dda61b-9eb2-47f2-b71f-ea1280c73cda',  -- gmo-646b1e4453e465278c9f982c
                        '11680c00-9955-4b1d-bcd0-b558b1c60da3',  -- gmo-646c9add17a3971b3f3c1b2d
                        '9dbd877c-29c5-40e0-8f89-19a45bdecb15',
                        '98135605-ff41-44a1-b764-f1256dd13135',
                        '23e20a86-ff7a-4cc3-95f7-aec465a22883'

                    )
                then 'clone'
                -- when device_id is null or device_id = '' or device_id = 'null' then
                -- 'undefined'
                else 'real'
            end as nru_type,
            af.ip,
            af.city,
            af.country_code,
            af.campaign_type,
            af.campaign as campaign_name
        from first_login as fl
        left join
            `gamotasdk5.bidata.appsflyer_login_postback` as af
            on fl.user_id = af.user_id
            and fl.game_id = af.game_id
            and fl.app_id = af.app_id
            and fl.first_login = af.event_time
    ),
    row_num as (
        select
            *,
            row_number() over (
                partition by user_id, game_id, app_id order by user_id, game_id, app_id
            ) as rn
        from login
    ),
    final_sdk_first_login as (select * except (rn) from row_num where rn = 1),
    -- gdp-staging.bidata.sdk_registered_users (return final_sdk_registered_users)
    register as (
        select distinct date, user_id, game_id, app_id
        from `gamotasdk5.bidata.register_logs`
    ),
    act_register as (
        select distinct date, user_id, game_id, app_id
        from `gamotasdk5.bidata.register_logs`
        where game_id = '180941' 
        order by date asc 
    ),
    act_af as (
        select *
        from 
        (
            select date, user_id, game_id, app_id,
            row_number() over (
                partition by user_id, game_id, app_id Order by event_time asc) as rn
            from `gamotasdk5.bidata.appsflyer_login_postback`
        ) as c
        where rn =1
        and date >= "2023-11-01" and date <= "2023-11-27"
        and game_id = '180941' 
        order by date asc 
    ),
    act_join as (
        select a.*, b.date as d2, b.user_id as u2, b.game_id as g2, b.app_id as a2, b.rn
        from act_af as b
        left join act_register as a
        on a.user_id = b.user_id and a.game_id = b.game_id and a.app_id = b.app_id
    ),
    user_register_before_1_4 as (
        select user_id, game_id, app_id
        from register
        where date < "2023-04-01"
    ),
    user_af_login_after_1_4 as (
        select *
        from (
        select *, 
            row_number() over (
                partition by user_id, game_id, app_id Order by event_time asc) as rn
        from `gamotasdk5.bidata.appsflyer_login_postback`
        ) as c
        where rn =1
    ),
    user_nham_lan as (
        select distinct a.*
        from user_register_before_1_4 as a
        inner join user_af_login_after_1_4 as b 
          on a.game_id = b.game_id  
          and a.app_id = b.app_id
          and a.user_id = b.user_id
    ),
    nru_af_full_info as (
        select *
        from `gamotasdk5.bidata.appsflyer_login_postback`
        where user_id not in (select user_id from user_nham_lan)
    ),
    final_sdk_registered_users as (
        select distinct
            register.date as register_date,
            login.first_login as first_login,
            coalesce(register.user_id, login.user_id) as user_id,
            coalesce(register.game_id, login.game_id) as game_id,
            coalesce(register.app_id, login.app_id) as app_id,
            -- login.game,
            login.platform,
            login.media_type,
            login.channel,
            login.device_id,
            login.nru_type,
            login.ip,
            login.city,
            login.country_code,
            login.campaign_type,
            login.campaign_name
        from register
        left join
            final_sdk_first_login login
            on register.date = date(login.first_login)
            and register.user_id = login.user_id
            and register.game_id = login.game_id
            and register.app_id = login.app_id
    ),
    -- return final_appsflyer_aggregate_report, final_sdk_first_login,
    -- final_sdk_registered_users
    afl as (
        select
            date,
            game_id,
            platform,
            media_type,
            channel,
            campaign_name,
            installs,
            total_cost,
            total_cost_local
        from final_appsflyer_aggregate_report
    ),
    user as (
        select
            register_date as date,
            game_id,
            platform,
            media_type,
            channel,
            campaign_name,
            count(distinct user_id) as nru
        from final_sdk_registered_users
        group by date, game_id, platform, media_type, channel, campaign_name
    ),
    revenue as (
        select
            tr.date,
            tr.app.game_id,
            tr.app.platform,
            ru.media_type,
            ru.channel,
            ru.campaign_name,
            -- ru.nru_type,
            count(distinct tr.user.user_id) as pu,
            -- sum(transaction.amount) as total_revenue,		
            sum(transaction.amount_local) as total_revenue
        from `gamotasdk5.bidata.transactions` as tr
        left join
            final_sdk_registered_users as ru
            on ru.user_id = tr.user.user_id
            and ru.game_id = tr.app.game_id
            and ru.register_date = tr.date
            and ru.platform = tr.app.platform
        group by date, game_id, platform, media_type, channel, campaign_name
    -- ,nru_type
    ),
    login_final_sdk_first as (
        select
            date(first_login) as date,
            game_id,
            platform,
            media_type,
            channel,
            campaign_name,
            count(distinct user_id) as d1_users
        from final_sdk_first_login
        group by date, game_id, platform, media_type, channel, campaign_name
    ),
    combine as (
        select
            coalesce(
                afl.date, user.date, revenue.date, login_final_sdk_first.date
            ) as date,
            coalesce(
                afl.game_id,
                user.game_id,
                revenue.game_id,
                login_final_sdk_first.game_id
            ) as game_id,
            coalesce(
                afl.platform,
                user.platform,
                revenue.platform,
                login_final_sdk_first.platform
            ) as platform,
            coalesce(
                afl.media_type,
                user.media_type,
                revenue.media_type,
                login_final_sdk_first.media_type
            ) as media_type,
            coalesce(
                afl.channel,
                user.channel,
                revenue.channel,
                login_final_sdk_first.channel
            ) as channel,
            coalesce(
                afl.campaign_name,
                user.campaign_name,
                revenue.campaign_name,
                login_final_sdk_first.campaign_name
            ) as campaign_name,
            sum(cast(afl.installs as int64)) as installs,
            sum(cast(afl.total_cost_local as float64)) as cost,
            sum(user.nru) as nru,
            sum(revenue.pu) as pu,
            sum(revenue.total_revenue) as revenue,
            sum(login_final_sdk_first.d1_users) as d1_users
        from afl
        full join
            user
            on afl.date = user.date
            and afl.game_id = user.game_id
            and afl.platform = user.platform
            and afl.media_type = user.media_type
            and afl.channel = user.channel
            and afl.campaign_name = user.campaign_name
        full join
            revenue
            on afl.date = revenue.date
            and afl.game_id = revenue.game_id
            and afl.platform = revenue.platform
            and afl.media_type = revenue.media_type
            and afl.channel = revenue.channel
            and afl.campaign_name = revenue.campaign_name
        full join
            login_final_sdk_first
            on afl.date = login_final_sdk_first.date
            and afl.game_id = login_final_sdk_first.game_id
            and afl.platform = login_final_sdk_first.platform
            and afl.media_type = login_final_sdk_first.media_type
            and afl.channel = login_final_sdk_first.channel
            and afl.campaign_name = login_final_sdk_first.campaign_name
        group by date, game_id, platform, media_type, channel, campaign_name
    ),
    final as (
        select distinct
            date,
            case
                when game_id = '180941'
                then 'Alo Chủ Tướng'
                when game_id = '180534'
                then 'Anh Hùng Xạ Điêu'
                when game_id = '180937'
                then 'Liên Minh Nhẫn Giả '
                when game_id = '180886'
                then 'Phong Lăng Thiên Hạ'
                when game_id = '180915'
                then 'Thiên Long Kiếm 2'
                when game_id = '180927'
                then 'Thiếu Niên Anh Hùng'
                when game_id = '180419'
                then 'Tru Tiên'
                when game_id = '180150'
                then 'Ỷ Thiên'
                else 'undefined'
            end as game_name,
            platform,
            media_type,
            channel,
            campaign_name,
            installs,
            cost,
            nru,
            pu,
            revenue,
            d1_users
        from combine
        where date >= '2023-01-01'
    )
-- select *
-- from act_join
-- where date is null

select *
from act_join
where user_id = 51992293 and game_id = '180941' and date is null

--and date >= "2023-11-01" and date <= "2023-11-27"
-- where user_id not in (select user_id from act_register)
