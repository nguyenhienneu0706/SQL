-- [quannm2] channel manager key metric 
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
                    then 'Campaign Branding'
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
        select 
                user_id, 
                game_id, 
                app_id, 
                min(event_time) as first_login
        from `gamotasdk5.bidata.appsflyer_login_postback`
        group by 1,2,3
        ),

login as (
        select 
                distinct
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
                    else 'Campaign Branding'
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
                            '98135605-ff41-44a1-b764-f1256dd13135'
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
                                partition by user_id, game_id, app_id 
                                order by user_id, game_id, app_id
                                ) as rn
        from login
        ),

final_sdk_first_login as (
        select * except (rn) 
        from row_num 
        where 
            rn = 1
        ),

-- gdp-staging.gamota_sdk.stg_gamota_sdk__transactions
input as (
        select * 
        from `gamotasdk5.bidata.transactions`
        ),

deduped as (
        select 
                distinct
                date as created_date,
                created as created_at,
                `transaction`.id as transaction_id,
                `transaction`.package_id as transaction_package_id,
                `transaction`.ip as transaction_ip,
                `transaction`.type as transaction_type,
                `transaction`.vendor as transaction_vendor,
                `transaction`.currency as transaction_currency_id,
                `transaction`.amount as transaction_amount,
                `transaction`.amount_local as transaction_amount_vnd,
                cast(user.user_id as string) as user_id,
                user.username,
                user.role_id,
                user.role_name,
                user.server_id,
                user.server_name,
                cast(app.app_id as string) as app_id,
                app.game_id,
                app.gma_id,
                app.app_name,
                app.platform,
                app.market
        from input
        ),

final_stg_gamota_sdk__transactions as (
        select
                created_date,
                created_at,
                struct(
                    transaction_id,
                    transaction_package_id,
                    transaction_ip,
                    transaction_type,
                    transaction_vendor,
                    transaction_currency_id,
                    transaction_amount,
                    transaction_amount_vnd
                    ) as transaction,
                struct(
                    user_id, 
                    username, 
                    role_id, 
                    role_name, 
                    server_id, 
                    server_name
                    ) as user,
                struct(
                    app_id, 
                    game_id, 
                    app_name, 
                    platform, 
                    market
                    ) as app
        from deduped
        ),

-- gdp-staging.bidata.sdk_registered_users (return final_sdk_registered_users)
register as (
        select 
                distinct 
                date, 
                user_id, 
                game_id, 
                app_id
        from `gamotasdk5.bidata.register_logs`
        ),

final_sdk_registered_users as (
        select 
                distinct
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

rev1 as (
        select
                ru.register_date as date,
                ru.game_id as game_id,
                ru.platform as platform,
                ru.media_type,	
                ru.channel,
                ru.campaign_name,
                sum(transaction.transaction_amount_vnd) as rev1
        from final_sdk_registered_users as ru
        left join
            (select *
            from final_stg_gamota_sdk__transactions
            ) as tr
            on cast(ru.user_id as string) = tr.user.user_id
            and ru.game_id = tr.app.game_id
        where created_date <= register_date + 1
        group by 1,2,3,4,5,6
        ),

rev3 as (
        select
                ru.register_date as date,
                ru.game_id as game_id,
                ru.platform as platform,
                ru.media_type,	
                ru.channel,
                ru.campaign_name,
                sum(transaction.transaction_amount_vnd) as rev3
        from final_sdk_registered_users as ru
        left join
            (select *
            from final_stg_gamota_sdk__transactions
            ) as tr
            on cast(ru.user_id as string) = tr.user.user_id
            and ru.game_id = tr.app.game_id
        where created_date <= register_date + 3
        group by 1,2,3,4,5,6
        ),

rev7 as (
        select
                ru.register_date as date,
                ru.game_id as game_id,
                ru.platform as platform,
                ru.media_type,	
                ru.channel,
                ru.campaign_name,
                sum(transaction.transaction_amount_vnd) as rev7
        from final_sdk_registered_users as ru
        left join
            (select *
            from final_stg_gamota_sdk__transactions
            ) as tr
            on cast(ru.user_id as string) = tr.user.user_id
            and ru.game_id = tr.app.game_id
        where created_date <= register_date + 7
        group by 1,2,3,4,5,6
        ),

acc_rev as (
        select
                ru.register_date as date,
                ru.game_id as game_id,
                ru.platform as platform,
                ru.media_type,	
                ru.channel,
                ru.campaign_name,
                sum(transaction.transaction_amount_vnd) as nru_acc_revenue
        from final_sdk_registered_users as ru
        left join
            (select *
            from final_stg_gamota_sdk__transactions
            ) as tr
            on cast(ru.user_id as string) = tr.user.user_id
            and ru.game_id = tr.app.game_id
        group by 1,2,3,4,5,6
        ),

installs_paid as (
        select
                date,
                game_id,
                platform,
                media_type,
                channel,
                campaign_name,
                sum(installs) as installs_paid
        from final_appsflyer_aggregate_report
        where 
            media_type = 'non_organic'
        group by 1,2,3,4,5,6
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
        group by 1,2,3,4,5,6
        ),

nru_organic as (
        select
                register_date as date,
                game_id,
                platform,
                media_type,
                channel,
                campaign_name,
                count(distinct user_id) as nru_organic
        from final_sdk_registered_users
        where 
            media_type = 'organic'
        group by 1,2,3,4,5,6
        ),

nru_non_organic as (
        select
                register_date as date,
                game_id,
                platform,
                media_type,
                channel,
                campaign_name,
                count(distinct user_id) as nru_non_organic
        from final_sdk_registered_users
        where 
            media_type = 'non_organic'
        group by 1,2,3,4,5,6
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
            and ru.platform = tr.app.platform
        group by 1,2,3,4,5,6
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
        group by 1,2,3,4,5,6
        ),

combine as (
        select
                coalesce(
                    afl.date, 
                    user.date, 
                    revenue.date, 
                    login_final_sdk_first.date,
                    nru_organic.date,
                    nru_non_organic.date,
                    installs_paid.date,
                    rev1.date,
                    rev3.date,
                    rev7.date,
                    acc_rev.date
                        ) as date,
                coalesce(
                    afl.game_id,
                    user.game_id,
                    revenue.game_id,
                    login_final_sdk_first.game_id,
                    nru_organic.game_id,
                    nru_non_organic.game_id,
                    installs_paid.game_id,
                    rev1.game_id,
                    rev3.game_id,
                    rev7.game_id,
                    acc_rev.game_id
                        ) as game_id,
                coalesce(
                    afl.platform,
                    user.platform,
                    revenue.platform,
                    login_final_sdk_first.platform,
                    nru_organic.platform,
                    nru_non_organic.platform,
                    installs_paid.platform,
                    rev1.platform,
                    rev3.platform,
                    rev7.platform,
                    acc_rev.platform
                        ) as platform,
                coalesce(
                    afl.media_type,
                    user.media_type,
                    revenue.media_type,
                    login_final_sdk_first.media_type,
                    nru_organic.media_type,
                    nru_non_organic.media_type,
                    installs_paid.media_type,
                    rev1.media_type,
                    rev3.media_type,
                    rev7.media_type,
                    acc_rev.media_type
                        ) as media_type,
                coalesce(
                    afl.channel,
                    user.channel,
                    revenue.channel,
                    login_final_sdk_first.channel,
                    nru_organic.channel,
                    nru_non_organic.channel,
                    installs_paid.channel,
                    rev1.channel,
                    rev3.channel,
                    rev7.channel,
                    acc_rev.channel
                        ) as channel,
                coalesce(
                    afl.campaign_name,
                    user.campaign_name,
                    revenue.campaign_name,
                    login_final_sdk_first.campaign_name,
                    nru_organic.campaign_name,
                    nru_non_organic.campaign_name,
                    installs_paid.campaign_name,
                    rev1.campaign_name,
                    rev3.campaign_name,
                    rev7.campaign_name,
                    acc_rev.campaign_name
                        ) as campaign_name,
                sum(cast(afl.installs as int64)) as installs,
                sum(cast(installs_paid.installs_paid as int64)) as installs_paid,
                sum(cast(afl.total_cost_local as float64)) as cost,
                sum(user.nru) as nru,
                sum(nru_organic.nru_organic) as nru_organic,
                sum(nru_non_organic.nru_non_organic) as nru_non_organic,
                sum(revenue.pu) as pu,
                sum(revenue.total_revenue) as revenue,
                sum(rev1.rev1) as rev1,
                sum(rev3.rev3) as rev3,
                sum(rev7.rev7) as rev7,
                sum(acc_rev.nru_acc_revenue) as nru_acc_revenue,
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
        full join
            nru_organic
            on afl.date = nru_organic.date
            and afl.game_id = nru_organic.game_id
            and afl.platform = nru_organic.platform
            and afl.media_type = nru_organic.media_type
            and afl.channel = nru_organic.channel
            and afl.campaign_name = nru_organic.campaign_name
        full join
            nru_non_organic
            on afl.date = nru_non_organic.date
            and afl.game_id = nru_non_organic.game_id
            and afl.platform = nru_non_organic.platform
            and afl.media_type = nru_non_organic.media_type
            and afl.channel = nru_non_organic.channel
            and afl.campaign_name = nru_non_organic.campaign_name
        full join
            installs_paid
            on afl.date = installs_paid.date
            and afl.game_id = installs_paid.game_id
            and afl.platform = installs_paid.platform
            and afl.media_type = installs_paid.media_type
            and afl.channel = installs_paid.channel
            and afl.campaign_name = installs_paid.campaign_name
        full join
            rev1
            on afl.date = rev1.date
            and afl.game_id = rev1.game_id
            and afl.platform = rev1.platform
            and afl.media_type = rev1.media_type
            and afl.channel = rev1.channel
            and afl.campaign_name = rev1.campaign_name
        full join
            rev3
            on afl.date = rev3.date
            and afl.game_id = rev3.game_id
            and afl.platform = rev3.platform
            and afl.media_type = rev3.media_type
            and afl.channel = rev3.channel
            and afl.campaign_name = rev3.campaign_name
        full join
            rev7
            on afl.date = rev7.date
            and afl.game_id = rev7.game_id
            and afl.platform = rev7.platform
            and afl.media_type = rev7.media_type
            and afl.channel = rev7.channel
            and afl.campaign_name = rev7.campaign_name
        full join
            acc_rev
            on afl.date = acc_rev.date
            and afl.game_id = acc_rev.game_id
            and afl.platform = acc_rev.platform
            and afl.media_type = acc_rev.media_type
            and afl.channel = acc_rev.channel
            and afl.campaign_name = acc_rev.campaign_name
        group by date, game_id, platform, media_type, channel, campaign_name
        ),

final as (
        select 
                distinct
                date,
                game_id,
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
                ifnull(platform,'undefined') as platform,
                ifnull(media_type,'undefined') as media_type,
                ifnull(channel,'undefined') as channel,
                ifnull(campaign_name,'undefined') as campaign_name,
                ifnull(installs,0) as installs,
                ifnull(installs_paid,0) as installs_paid,
                ifnull(cost,0) as cost_ua,
                ifnull(nru,0) as nru,
                ifnull(nru_organic,0) as nru_organic,
                ifnull(nru_non_organic,0) as nru_non_organic,
                ifnull(pu,0) as pu,
                ifnull(revenue,0) as revenue,
                ifnull(rev1,0) as rev1,
                ifnull(rev3,0) as rev3,
                ifnull(rev7,0) as rev7,
                ifnull(nru_acc_revenue,0) as nru_acc_revenue,
                d1_users,
                extract(month from date(date)) as month,
                extract(year from date(date)) as year
        from combine
        where 
            date >= '2023-01-01'
        order by date asc
        ),

get_budget_branding as (
        select 
                day,
                month,
                year,
                game,
                platform,
                branding_cost *24000 as branding_cost 
        from gamotasdk5.tuan_test.stg_google_sheets_branding_cost_detail
        order by game asc,month asc
        ),

final_with_cost_branding as ( --lấy cost branding theo dimensions
        select 
                final.date,
                final.game_id,
                final.game_name,
                final.platform,
                final.media_type,
                final.channel,
                final.campaign_name,
                final.revenue,
                final.cost_ua,
                get_budget_branding.branding_cost,
                row_number() over ( partition by 
                                        final.date,
                                        final.game_id,
                                        final.game_name,
                                        final.platform
                                    order by final.date asc
                                    ) as rn
                --get_budget_branding.days_in_month
        from (  
                select *
                from final
                where 
                    media_type = 'organic'
                ) as final
        left join 
            get_budget_branding 
            on final.game_name = get_budget_branding.game
            and final.month = get_budget_branding.month
            and final.year = get_budget_branding.year
            and final.platform = get_budget_branding.platform
            and final.date = get_budget_branding.day
        order by date asc
        ),

final_with_cost_branding_max as (
        select 
                date,
                game_id,
                game_name,
                platform,
                max(rn) as max_rn
        from final_with_cost_branding
        group by 1,2,3,4
        ),

final_true_cost_branding as (
        select 
                date,
                game_id,
                game_name,
                platform,
                media_type,
                channel,
                campaign_name,
                cost_branding
        from (
                select 
                        final_with_cost_branding.*,
                        final_with_cost_branding_max.max_rn,
                        (branding_cost / max_rn) as cost_branding
                from final_with_cost_branding
                left join 
                    final_with_cost_branding_max
                    on final_with_cost_branding.date = final_with_cost_branding_max.date
                    and final_with_cost_branding.game_id = final_with_cost_branding_max.game_id
                    and final_with_cost_branding.game_name = final_with_cost_branding_max.game_name
                    and final_with_cost_branding.platform = final_with_cost_branding_max.platform   
                order by final_with_cost_branding.date asc
                )
        ),
        
final_cohort_user_trending as (
        select 
                final.date,
                final.game_id,
                final.game_name,
                final.platform,
                final.media_type,
                final.channel,
                final.campaign_name,
                final.installs,
                final.installs_paid,
                final.nru,
                final.nru_organic,
                final.nru_non_organic,
                final.pu,
                final.d1_users,
                final.revenue as total_revenue,
                final.rev1 as rev1,
                final.rev3 as rev3,
                final.rev7 as rev7,
                final.nru_acc_revenue as nru_acc_revenue,
                final.cost_ua,
                final_true_cost_branding.cost_branding,
                (final.cost_ua +  ifnull(final_true_cost_branding.cost_branding,0)) as total_cost
        from final
        left join 
            final_true_cost_branding
            on final.date = final_true_cost_branding.date
            and final.game_id = final_true_cost_branding.game_id
            and final.game_name = final_true_cost_branding.game_name
            and final.platform = final_true_cost_branding.platform
            and final.media_type = final_true_cost_branding.media_type
            and final.channel = final_true_cost_branding.channel
            and final.campaign_name = final_true_cost_branding.campaign_name
        
        )

select *
from final_cohort_user_trending


-- select 
--         game_id,
--         --platform,
--         --channel,
--         sum(rev1) as rev1,
--         sum(rev3) as rev3,
--         sum(rev7) as rev7,
--         sum(nru_acc_revenue) as nru_acc_revenue,
--         sum(cost_ua) as cost_ua,
--         sum(cost_branding) as cost_branding,
--         sum(total_cost) as total_cost
-- from final_channel_manager_key_metric
-- where game_id = '180941'
-- and date >= '2023-11-01'
-- and date <= '2023-11-27'
-- group by 1
