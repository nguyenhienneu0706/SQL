-- [quannm2] overview cost nru 
with
dau as (
        select
                date,
                game_id,
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
            count(distinct user_id) as dau
        from `gamotasdk5.bidata.appsflyer_login_postback`
        group by date, game_id, platform, media_type
        ),

-- gdp-staging.bidata.sdk_first_login
register as (
        select 
                distinct date, 
                user_id, 
                game_id, 
                app_id
        from `gamotasdk5.bidata.register_logs`
        ),

import_login_postback as (
        select 
                distinct
                event_time,
                user_id,
                game_id,
                app_id,
                platform,
                media_source,
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
                device_id,
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
                ip,
                city,
                country_code,
                campaign_type,
                campaign as campaign_name
        from `gamotasdk5.bidata.appsflyer_login_postback`
        ),

first_login as (
        select 
                user_id, 
                game_id, 
                app_id, 
                min(event_time) as first_login
        from `gamotasdk5.bidata.appsflyer_login_postback`
        group by user_id, game_id, app_id
        ),

join_first_login_and_postback as (   --join ngược lại để lấy thêm info cho user with 1st login
        select 
                distinct
                first_login.first_login,
                first_login.user_id,
                first_login.game_id,
                first_login.app_id,
                import_login_postback.platform,
                import_login_postback.media_source,
                import_login_postback.media_type,
                import_login_postback.channel,
                import_login_postback.device_id,
                import_login_postback.nru_type,
                import_login_postback.ip,
                import_login_postback.city,
                import_login_postback.country_code,
                import_login_postback.campaign_type,
                import_login_postback.campaign_name
        from first_login
        left join 
            import_login_postback
            on first_login.user_id = import_login_postback.user_id
            and first_login.game_id = import_login_postback.game_id
            and first_login.app_id = import_login_postback.app_id
            and first_login.first_login = import_login_postback.event_time
        ),

get_rownum_first_login as (
        select
                *,
                row_number() over (partition by user_id, game_id, app_id order by first_login) as rn
        from join_first_login_and_postback
        ),
        
get_first_true_login as (
        select * except (rn) 
        from get_rownum_first_login 
        where rn = 1
        ),

final_sdk_first_login as (
        select
                register.date as register_date,
                register.user_id,
                register.game_id,
                register.app_id,
                get_first_true_login.platform,
                get_first_true_login.media_source,
                get_first_true_login.media_type,
                get_first_true_login.channel,
                get_first_true_login.device_id,
                get_first_true_login.nru_type,
                get_first_true_login.ip,
                get_first_true_login.city,
                get_first_true_login.country_code,
                get_first_true_login.campaign_type,
                get_first_true_login.campaign_name
        from register
        left join 
            get_first_true_login
            on register.user_id = get_first_true_login.user_id
            and register.game_id = get_first_true_login.game_id
            and register.app_id = get_first_true_login.app_id
            and register.date = date(get_first_true_login.first_login)
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
-- gdp-staging.bidata.appsflyer_aggregate_report
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

nru as (
        select
                ru.register_date as date,
                ru.game_id as game_id,
                ru.platform as platform,
                ru.media_type,
                -- ru.nru_type,
                count(distinct ru.user_id) as nru,
                count(distinct if(nru_type = 'clone', user_id, null)) as nru_buff,
                -- count(distinct if (nru_type = 'real', user_id, NULL)) as nru_real,
                -- count(distinct if (nru_type = 'undefined', user_id, NULL)) as
                -- nru_undefined
                -- sum(transaction.amount) as nru_revenue,		
                sum(transaction.transaction_amount_vnd) as nru_revenue
        from final_sdk_first_login as ru
        left join
            (select *
                from final_stg_gamota_sdk__transactions 
            -- where 
            --     created_date >= '2023-12-11' --parse_date ('%Y%m%d', @DS_START_DATE) 
            --     and created_date <= '2023-12-20'--parse_date('%Y%m%d', @DS_END_DATE) 
            ) as tr
            on cast(ru.user_id as string) = tr.user.user_id
            and ru.game_id = tr.app.game_id
            --and ru.register_date = tr.created_date
            --and ru.platform = tr.app.platform
        group by 1,2,3,4
        -- ,nru_type
        ),

acc_rev as (
        select
                ru.register_date as date,
                ru.game_id as game_id,
                ru.platform as platform,
                ru.media_type,	
                sum(transaction.transaction_amount_vnd) as nru_acc_revenue
        from final_sdk_first_login as ru
        left join
            (select *
            from final_stg_gamota_sdk__transactions 
            --where created_date >= parse_date ('%Y%m%d', @DS_START_DATE) 
            --and created_date <= parse_date('%Y%m%d', @DS_END_DATE) 
            ) as tr
            on cast(ru.user_id as string) = tr.user.user_id
            and ru.game_id = tr.app.game_id
            --and ru.register_date = tr.created_date
            --and ru.platform = tr.app.platform
        group by 1,2,3,4
        ),

nru_rev3 as (
        select
                ru.register_date as date,
                ru.game_id as game_id,
                ru.platform as platform,
                ru.media_type,	
                sum(transaction.transaction_amount_vnd) as nru_rev3
        from final_sdk_first_login as ru
        left join
            (select *
            from final_stg_gamota_sdk__transactions 
            -- where 
            --     created_date >= '2023-12-11'--parse_date ('%Y%m%d', @DS_START_DATE) 
            --     and created_date <= '2023-12-20' --parse_date('%Y%m%d', @DS_END_DATE) 
            ) as tr
            on cast(ru.user_id as string) = tr.user.user_id
            and ru.game_id = tr.app.game_id
            --and ru.register_date = tr.created_date
            --and ru.platform = tr.app.platform
        where 
            tr.created_date <= ru.register_date + 3
        group by 1,2,3,4
        ),

revenue as (
        select
                tr.created_date as date,
                tr.app.game_id,
                tr.app.platform,
                ru.media_type,
                -- ru.nru_type,
                -- count(distinct tr.user_id) as pu,
                -- sum(transaction.amount) as total_revenue,		
                sum(transaction.transaction_amount_vnd) as total_revenue
        from final_stg_gamota_sdk__transactions as tr
        left join 
            final_sdk_first_login as ru
            on cast(ru.user_id as string) = tr.user.user_id
            and ru.game_id = tr.app.game_id
            and ru.platform = tr.app.platform
        group by 1,2,3,4
        ),

cost as (
        select
                date,
                game_id,
                platform,
                media_type,
                -- total_revenue,
                -- total_cost,
                sum(cast(total_cost_local as float64)) as total_cost
        from final_appsflyer_aggregate_report
        group by 1,2,3,4
        ),

installs as (
        select
                date,
                game_id,
                platform,
                media_type,
                -- total_revenue,
                -- total_cost,
                sum(installs) as total_installs
        from final_appsflyer_aggregate_report
        group by 1,2,3,4
        ),

nru_organic as (   
        select 
                date,
                game_id,
                platform,
                media_type,
                sum(nru.nru) as nru_organic
        from nru
        where 
            media_type = 'organic'
        group by 1,2,3,4
        ),

nru_paid as (
        select 
                date,
                game_id,
                platform,
                media_type,
                sum(nru.nru) as nru_paid
        from nru
        where 
            media_type = 'non_organic'
        group by 1,2,3,4
        ),

installs_organic as (
        select 
                date,
                game_id,
                platform,
                media_type,
                sum(installs.total_installs) as installs_organic
        from installs
        where 
            media_type = 'organic'
        group by 1,2,3,4
        ),

installs_paid as (
        select 
                date,
                game_id,
                platform,
                media_type,
                sum(installs.total_installs) as installs_paid
        from installs
        where 
            media_type = 'non_organic'
        group by 1,2,3,4
        ),

combine as (
        select
                coalesce(
                        dau.date, 
                        nru.date, 
                        revenue.date, 
                        cost.date,
                        installs.date,
                        acc_rev.date,
                        nru_rev3.date
                        ) as date,
                coalesce(
                        dau.game_id, 
                        nru.game_id, 
                        revenue.game_id, 
                        cost.game_id,
                        installs.game_id,
                        acc_rev.game_id,
                        nru_rev3.game_id
                        ) as game_id,
                coalesce(
                        dau.platform,
                        nru.platform, 
                        revenue.platform, 
                        cost.platform,
                        installs.platform,
                        acc_rev.platform,
                        nru_rev3.platform
                        ) as platform,
                coalesce(
                        dau.media_type, 
                        nru.media_type, 
                        revenue.media_type, 
                        cost.media_type,
                        installs.media_type,
                        acc_rev.media_type,
                        nru_rev3.media_type
                        ) as media_type,
                sum(dau.dau) as dau,
                sum(nru.nru) as nru,
                sum(nru.nru_buff) as nru_buff,
                (sum(nru.nru) - sum(nru.nru_buff)) as nru_real,
                sum(nru.nru_revenue) as nru_revenue,
                sum(nru_rev3.nru_rev3) as nru_rev3,
                sum(acc_rev.nru_acc_revenue) as nru_acc_revenue,
                sum(revenue.total_revenue) as total_revenue,
                sum(cast(cost.total_cost as float64)) as total_cost,
                sum(installs.total_installs) as total_installs
        from dau
        full join
            nru
            on dau.date = nru.date
            and dau.game_id = nru.game_id
            and dau.platform = nru.platform
            and dau.media_type = nru.media_type
        full join
            revenue
            on dau.date = revenue.date
            and dau.game_id = revenue.game_id
            and dau.platform = revenue.platform
            and dau.media_type = revenue.media_type
        full join
            cost
            on dau.date = cost.date
            and dau.game_id = cost.game_id
            and dau.platform = cost.platform
            and dau.media_type = cost.media_type
        full join
            installs
            on dau.date = installs.date
            and dau.game_id = installs.game_id
            and dau.platform = installs.platform
            and dau.media_type = installs.media_type
        full join
            acc_rev
            on dau.date = acc_rev.date
            and dau.game_id = acc_rev.game_id
            and dau.platform = acc_rev.platform
            and dau.media_type = acc_rev.media_type
        full join
            nru_rev3
            on dau.date = nru_rev3.date
            and dau.game_id = nru_rev3.game_id
            and dau.platform = nru_rev3.platform
            and dau.media_type = nru_rev3.media_type
        group by date, game_id, platform, media_type
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
                case 
                    when platform = 'android' then 'android'
                    when platform = 'ios' then 'ios'
                    else 'undefined'
                    end as platform,
                case
                    when media_type = 'organic' then 'organic'
                    when media_type = 'non_organic' then 'non_organic'
                    else 'undefined'
                    end as media_type,
                dau,
                nru,
                nru_buff,
                nru_real,
                nru_revenue,
                nru_rev3,
                nru_acc_revenue,
                total_revenue,
                total_cost,
                total_installs
        from combine
        where 
            date >= '2023-09-01'
        ),

final_in_range_aggregate_report as (
        select 
                date,
                game_id,
                game_name,
                platform,
                media_type,
                extract(month from date(date)) as month,
                extract(year from date(date)) as year,
                sum(dau) as dau,
                sum(nru) as nru,
                sum(nru_buff) as nru_buff,
                sum(nru_real) as nru_real,
                sum(nru_revenue) as nru_revenue,
                sum(nru_rev3) as nru_rev3,
                sum(nru_acc_revenue) as nru_acc_revenue,
                sum(total_revenue) as total_revenue,
                sum(total_cost) as cost_ua,
                sum(total_installs) as total_installs
        from final
        -- where date >= '2023-12-11' --parse_date ('%Y%m%d', @DS_START_DATE)  --
        -- and date <= '2023-12-20' --parse_date('%Y%m%d', @DS_END_DATE)  --
        --and game_id = '180941'
        group by 1,2,3,4,5
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

final_with_cost_branding as ( --lấy cost branding theo 5 dimensions
        select 
                date,
                game_id,
                game_name,
                platform,
                media_type,
                cost_branding
        from (
                select 
                        final_in_range_aggregate_report.date,
                        final_in_range_aggregate_report.game_id,
                        final_in_range_aggregate_report.game_name,
                        final_in_range_aggregate_report.platform,
                        final_in_range_aggregate_report.media_type,
                        final_in_range_aggregate_report.total_revenue,
                        final_in_range_aggregate_report.cost_ua,
                        get_budget_branding.branding_cost as cost_branding,
                        row_number() over ( partition by 
                                                final_in_range_aggregate_report.date,
                                                final_in_range_aggregate_report.game_id,
                                                final_in_range_aggregate_report.game_name
                                            order by final_in_range_aggregate_report.date asc
                                            ) as rn
                        
                from (  select *
                        from final_in_range_aggregate_report
                        where 
                            media_type = 'organic'
                        ) as final_in_range_aggregate_report
                left join 
                    get_budget_branding 
                    on final_in_range_aggregate_report.game_name = get_budget_branding.game
                    and final_in_range_aggregate_report.month = get_budget_branding.month
                    and final_in_range_aggregate_report.year = get_budget_branding.year
                    and final_in_range_aggregate_report.platform = get_budget_branding.platform
                    and final_in_range_aggregate_report.date = get_budget_branding.day
                order by date asc
                )
        ),

final_overview_cost_nru as (
        select 
                coalesce(
                        final_in_range_aggregate_report.date,
                        final_with_cost_branding.date,
                        nru_organic.date,
                        nru_paid.date,
                        installs_organic.date,
                        installs_paid.date
                        ) as date,
                coalesce(
                        final_in_range_aggregate_report.game_id,
                        final_with_cost_branding.game_id,
                        nru_organic.game_id,
                        nru_paid.game_id,
                        installs_organic.game_id,
                        installs_paid.game_id
                        ) as game_id,
                final_in_range_aggregate_report.game_name,
                coalesce(
                        final_in_range_aggregate_report.platform,
                        final_with_cost_branding.platform,
                        nru_organic.platform,
                        nru_paid.platform,
                        installs_organic.platform,
                        installs_paid.platform
                        ) as platform,
                coalesce(
                        final_in_range_aggregate_report.media_type,
                        final_with_cost_branding.media_type,
                        nru_organic.media_type,
                        nru_paid.media_type,
                        installs_organic.media_type,
                        installs_paid.media_type
                        ) as media_type,
                final_in_range_aggregate_report.dau,
                final_in_range_aggregate_report.nru,
                final_in_range_aggregate_report.nru_buff,
                final_in_range_aggregate_report.nru_real,
                --final_in_range_aggregate_report.nru_revenue,
                final_in_range_aggregate_report.nru_rev3,
                final_in_range_aggregate_report.nru_acc_revenue,
                final_in_range_aggregate_report.total_revenue,
                final_in_range_aggregate_report.total_installs,
                nru_organic.nru_organic,
                nru_paid.nru_paid,
                installs_organic.installs_organic,
                installs_paid.installs_paid,
                ifnull(final_in_range_aggregate_report.cost_ua,0) as cost_ua,
                ifnull(final_with_cost_branding.cost_branding,0) as cost_branding,
                (ifnull(final_in_range_aggregate_report.cost_ua,0) + ifnull(final_with_cost_branding.cost_branding,0)) as total_cost
                -- round((final_in_range_aggregate_report.nru_acc_revenue / (cost_ua + final_with_cost_branding.cost_branding)),2) as roas,
                -- round(((cost_ua + final_with_cost_branding.cost_branding) / (nru_organic.nru_organic + nru_paid.nru_paid)) /24000,2)  as CPN,
                -- round((cost_ua / cast(nru_paid.nru_paid as float64)) /24000,2) as pCPN,
                -- round(((cost_ua + final_with_cost_branding.cost_branding) / (installs_organic.installs_organic + installs_paid.installs_paid)) /24000,2) as CPI,
                -- round((cost_ua / cast(installs_paid.installs_paid as float64)) /24000,2) as pCPI
        from final_in_range_aggregate_report
        full join 
            final_with_cost_branding 
            on final_in_range_aggregate_report.date = final_with_cost_branding.date
            and final_in_range_aggregate_report.game_id = final_with_cost_branding.game_id
            and final_in_range_aggregate_report.game_name = final_with_cost_branding.game_name
            and final_in_range_aggregate_report.platform = final_with_cost_branding.platform
            and final_in_range_aggregate_report.media_type = final_with_cost_branding.media_type
        full join 
            nru_organic
            on final_in_range_aggregate_report.date = nru_organic.date
            and final_in_range_aggregate_report.game_id = nru_organic.game_id
            and final_in_range_aggregate_report.platform = nru_organic.platform
            and final_in_range_aggregate_report.media_type = nru_organic.media_type
        full join 
            nru_paid
            on final_in_range_aggregate_report.date = nru_paid.date
            and final_in_range_aggregate_report.game_id = nru_paid.game_id
            and final_in_range_aggregate_report.platform = nru_paid.platform
            and final_in_range_aggregate_report.media_type = nru_paid.media_type
        full join 
            installs_organic
            on final_in_range_aggregate_report.date = installs_organic.date
            and final_in_range_aggregate_report.game_id = installs_organic.game_id
            and final_in_range_aggregate_report.platform = installs_organic.platform
            and final_in_range_aggregate_report.media_type = installs_organic.media_type
        full join 
            installs_paid
            on final_in_range_aggregate_report.date = installs_paid.date
            and final_in_range_aggregate_report.game_id = installs_paid.game_id
            and final_in_range_aggregate_report.platform = installs_paid.platform
            and final_in_range_aggregate_report.media_type = installs_paid.media_type
        order by date asc
        )

select *
from final_overview_cost_nru

-- select game_id,
--         --platform,
--         round(sum(nru_acc_revenue) / sum(total_cost),2) as roas,
--         sum(total_revenue) as total_revenue,
--         sum(nru_acc_revenue) as nru_acc_revenue,
--         sum(nru_rev3) as nru_rev3,
--         sum(cost_ua) as cost_ua,
--         sum(cost_branding) as cost_branding,
--         sum(total_cost) as total_cost,
--         round(sum(total_cost) / sum(total_installs) /24000 ,2) as CPI,
--         round(sum(cost_ua) / sum(installs_paid) /24000 ,2) as pCPI,
--         round(sum(total_cost) / sum(nru) /24000 ,2) as CPN,
--         round(sum(cost_ua) / sum(nru_paid) /24000 ,2) as pCPN,
--         round(sum(nru) / sum(total_installs) *100 ,2) as CVR
-- from final_overview_cost_nru
-- where 
--     game_id ='180941'
--     and date >= '2023-12-15'
--     and date <= '2023-12-31'
--     --and platform = 'android'
-- group by 1


--and game_name = @GAME_NAME
