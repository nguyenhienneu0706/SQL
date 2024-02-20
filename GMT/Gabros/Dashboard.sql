-- 1. Lấy số lượt first_open TRONG MỘT KHOẢNG THỜI GIAN:

SELECT event_date, COUNT(DISTINCT user_pseudo_id) AS no_user_first_open
FROM (
  SELECT event_date, user_pseudo_id
  FROM `gab002.analytics_378566684.events_*`, UNNEST(event_params) AS params_key
  WHERE event_name = 'first_open'
  UNION ALL
  SELECT event_date, user_pseudo_id
  FROM `gab002.analytics_378566684.events_intraday_*`, UNNEST(event_params) AS params_key
  WHERE event_name = 'first_open'
) 
WHERE event_date >= "20230529" AND event_date <= "20230606" -- ĐOẠN NÀY K THÊM NGÀY VẪN ĐƯỢC
GROUP BY event_date;

-- 2. BẢNG LEVEL TRACKING:
-- 2.1: CHIA THEO DATE:
WITH A AS (
  SELECT event_date, user_pseudo_id, CAST(params_key.value.string_value AS INT64) AS Level
  FROM `gab002.analytics_378566684.events_*`, UNNEST(event_params) AS params_key
  WHERE event_name = 'a_level_start' AND params_key.key = 'level_event'
UNION ALL
  SELECT event_date, user_pseudo_id, CAST(params_key.value.string_value AS INT64) AS Level
  FROM `gab002.analytics_378566684.events_intraday_*`, UNNEST(event_params) AS params_key
  WHERE event_name = 'a_level_start' AND params_key.key = 'level_event'
)
SELECT event_date, Level, COUNT(DISTINCT user_pseudo_id) AS User, COUNT(user_pseudo_id) AS Count
FROM A
WHERE A.event_date >= "20230529" AND A.event_date <= "20230606" -- ĐOẠN NÀY K THÊM NGÀY VẪN ĐƯỢC
GROUP BY event_date, Level
ORDER BY event_date, Level;

-- 2.2: KHÔNG CHIA THEO DATE:
WITH A AS (
  SELECT event_date, user_pseudo_id, CAST(params_key.value.string_value AS INT64) AS Level
  FROM `gab002.analytics_378566684.events_*`, UNNEST(event_params) AS params_key
  WHERE event_name = 'a_level_start' AND params_key.key = 'level_event'
UNION ALL
  SELECT event_date, user_pseudo_id, CAST(params_key.value.string_value AS INT64) AS Level
  FROM `gab002.analytics_378566684.events_intraday_*`, UNNEST(event_params) AS params_key
  WHERE event_name = 'a_level_start' AND params_key.key = 'level_event'
)
SELECT Level,COUNT(DISTINCT user_pseudo_id) AS User, COUNT(user_pseudo_id) AS Count
FROM A
WHERE event_date >= "20230529" AND event_date <= "20230606" -- ĐOẠN NÀY K THÊM NGÀY VẪN ĐƯỢC
GROUP BY Level
ORDER BY Level;
--------------------------------------------------------------------------------------------------
-- CHỐT KHÔNG DÙNG BẢNG INTRADAY NỮA:

-- 1. Lấy số lượt first_open TRONG MỘT KHOẢNG THỜI GIAN = tổng các ngày:

SELECT event_date, 
  COUNT(DISTINCT user_pseudo_id) AS No_user_first_open
FROM `gab002.analytics_378566684.events_*`, UNNEST(event_params) AS params_key
WHERE event_name = 'first_open' 
  AND params_key.key = "ga_session_id"
GROUP BY event_date;
-- Check với số từng ngày trên firebase đúng rồi ạ huhu

-- 2. BẢNG LEVEL TRACKING:
-- Level Start:
-- 2.1.1: CHIA THEO DATE:
SELECT event_date, 
  CAST(params_key.value.string_value AS INT64) AS Level,
  COUNT(DISTINCT user_pseudo_id) AS User, 
  COUNTIF(event_name = 'a_level_start' AND params_key.key = 'level_event') AS Count
FROM `gab002.analytics_378566684.events_*`, UNNEST(event_params) AS params_key
WHERE event_name = 'a_level_start' AND params_key.key = 'level_event'
GROUP BY event_date, Level
ORDER BY event_date, Level;
-- 2.1.2: KHÔNG CHIA THEO DATE:
SELECT
  CAST(params_key.value.string_value AS INT64) AS Level,
  COUNT(DISTINCT user_pseudo_id) AS User, 
  COUNTIF(event_name = 'a_level_start' AND params_key.key = 'level_event') AS Count
FROM `gab002.analytics_378566684.events_*`, UNNEST(event_params) AS params_key
WHERE event_name = 'a_level_start' AND params_key.key = 'level_event'
-- AND params_key.value.string_value IS NOT NULL: CÓ THÊM HAY KHÔNG CŨNG KHÔNG QUAN TRỌNG DO VỚI CÁC ĐK TRƯỚC THÌ GIÁ TRỊ NÀY KBH NULL
GROUP BY Level
ORDER BY Level;

-- Level Complete:
-- 2.2.1: CHIA THEO DATE:
SELECT event_date, 
  CAST(params_key.value.string_value AS INT64) AS Level,
  COUNT(DISTINCT user_pseudo_id) AS User, 
  COUNTIF(event_name = 'a_level_complete' AND params_key.key = 'level_event') AS Count
FROM `gab002.analytics_378566684.events_*`, UNNEST(event_params) AS params_key
WHERE event_name = 'a_level_complete' AND params_key.key = 'level_event'
GROUP BY event_date, Level
ORDER BY event_date, Level;
-- 2.2.2: KHÔNG CHIA THEO DATE:
SELECT
  CAST(params_key.value.string_value AS INT64) AS Level,
  COUNT(DISTINCT user_pseudo_id) AS User, 
  COUNTIF(event_name = 'a_level_complete' AND params_key.key = 'level_event') AS Count
FROM `gab002.analytics_378566684.events_*`, UNNEST(event_params) AS params_key
WHERE event_name = 'a_level_complete' AND params_key.key = 'level_event'
GROUP BY Level
ORDER BY Level;

-- Level Fail:
-- 2.2.1: CHIA THEO DATE:
SELECT event_date, 
  CAST(params_key.value.string_value AS INT64) AS Level,
  COUNT(DISTINCT user_pseudo_id) AS User, 
  COUNTIF(event_name = 'a_level_fail' AND params_key.key = 'level_event') AS Count,
  (COUNTIF(event_name = 'a_level_fail' AND params_key.key = 'level_event'))/ COUNT(DISTINCT user_pseudo_id) AS TimeReplay
FROM `gab002.analytics_378566684.events_*`, UNNEST(event_params) AS params_key
WHERE event_name = 'a_level_fail' AND params_key.key = 'level_event'
GROUP BY event_date, Level
ORDER BY event_date, Level;
-- 2.2.2: KHÔNG CHIA THEO DATE:
SELECT
  CAST(params_key.value.string_value AS INT64) AS Level,
  COUNT(DISTINCT user_pseudo_id) AS User, 
  COUNTIF(event_name = 'a_level_fail' AND params_key.key = 'level_event') AS Count,
  (COUNTIF(event_name = 'a_level_fail' AND params_key.key = 'level_event'))/ COUNT(DISTINCT user_pseudo_id) AS TimeReplay
FROM `gab002.analytics_378566684.events_*`, UNNEST(event_params) AS params_key
WHERE event_name = 'a_level_fail' AND params_key.key = 'level_event'
GROUP BY Level
ORDER BY Level;

-- Fail gộp bảng:
WITH Level_counts AS (
SELECT event_date, 
  CAST(params_key.value.string_value AS INT64) AS Level,
  COUNT(DISTINCT user_pseudo_id) AS User, 
  COUNTIF(event_name = 'a_level_fail' AND params_key.key = 'level_event') AS Count
FROM `gab002.analytics_378566684.events_*`, UNNEST(event_params) AS params_key
WHERE event_name = 'a_level_fail' AND params_key.key = 'level_event'
GROUP BY event_date, Level
ORDER BY event_date, Level
)
SELECT 
CASE
  WHEN Level <= 10 THEN Level
  WHEN MOD(Level, 10) = 0 THEN 10
    ELSE MOD(Level, 10)
  END AS LevelGroup,
SUM(User) AS Total_Users,
SUM(Count) AS Total_Count
FROM Level_counts
GROUP BY LevelGroup
ORDER BY LevelGroup;
-- 
SELECT
  geo.country,
  event_date,
  COUNT(DISTINCT(user_pseudo_id)) AS users,
  COUNTIF(event_name = "first_open" AND param.key = "ga_session_id") AS first_open,
  COUNTIF(param.key = "session_engaged") AS engaged_session,
  COUNTIF(param.key = "ga_session_id" AND event_name = "session_start") AS session,
  COUNTIF(param.key = "ga_session_id" AND event_name IS NOT NULL) AS all_event_count,
  COUNTIF(param.key = "firebase_conversion" AND event_name IS NOT NULL) AS all_event_conversion,
  SUM(CASE WHEN param.key = "engagement_time_msec" THEN param.value.int_value END)/60000 AS avg_engagement_time,
FROM
  `gab002.analytics_378566684.events_*`,UNNEST(event_params) AS param
GROUP BY geo.country,
         event_date -- Thêm trường event_date vào phần GROUP BY
ORDER BY users DESC;

-- Lấy Average engagement time per session và Average engagement time per engaged session:
WITH A AS
(
  SELECT event_date, 
  COUNTIF(param.key = "session_engaged" AND event_name IS NOT NULL) AS engaged_session,
  COUNTIF(param.key = "ga_session_id" AND event_name = "session_start") AS session,
  SUM(CASE WHEN  param.key = "engagement_time_msec" THEN param.value.int_value END)/1000 AS sum_engagement_time
FROM `gab002.analytics_378566684.events_*`, UNNEST(event_params) AS param
GROUP BY event_date
)
SELECT 
  SUM(A.sum_engagement_time)/SUM(A.session) AS avg_engagement_time_per_session,
  SUM(A.sum_engagement_time)/SUM(A.engaged_session) AS avg_engagement_time_per_engaged_session
FROM A;

-- CÂU CỦA ANH ĐỨC:
WITH start_date AS(
SELECT event_date,
  CAST(params_key.value.string_value AS INT64) AS Level,
  COUNT(DISTINCT user_pseudo_id) AS User,
  COUNTIF(event_name = 'a_level_start' AND params_key.key = 'level_event') AS Count
FROM `gab002.analytics_378566684.events_*`, UNNEST(event_params) AS params_key
WHERE event_name = 'a_level_start' AND params_key.key = 'level_event'
GROUP BY event_date, Level
ORDER BY event_date, Level
)
SELECT start_date.Level, SUM(start_date.User) AS users, SUM(start_date.Count) AS counts, 
  ROUND(IFNULL((100 * SUM(start_date.User)/(LAG(SUM(start_date.User)) OVER(ORDER BY SUM(start_date.Level) ASC))),100),2) || '%' AS percent_user
FROM start_date
GROUP BY start_date.Level
ORDER BY start_date.Level ASC;

-- SỬA LẠI CÂU CÙA ẢNH ĐỨC:
--- USERS:
WITH start_date AS(
SELECT event_date,
  CAST(params_key.value.string_value AS INT64) AS Level,
  COUNT(DISTINCT user_pseudo_id) AS User,
  COUNTIF(event_name = 'a_level_start' AND params_key.key = 'level_event') AS Count
FROM `gab002.analytics_378566684.events_*`, UNNEST(event_params) AS params_key
WHERE event_name = 'a_level_start' AND params_key.key = 'level_event'
GROUP BY event_date, Level
ORDER BY event_date, Level
)
SELECT
  start_date.Level,
  SUM(start_date.User) AS Users,
  SUM(start_date.Count) AS Counts,
  ROUND(IFNULL((SUM(start_date.User) / LAG(SUM(start_date.User), 1) OVER (ORDER BY start_date.Level ASC)),1),2) AS percent_user
FROM start_date
GROUP BY start_date.Level
ORDER BY start_date.Level ASC;

--- COUNT:
WITH start_date AS(
SELECT event_date,
  CAST(params_key.value.string_value AS INT64) AS Level,
  COUNT(DISTINCT user_pseudo_id) AS User,
  COUNTIF(event_name = 'a_level_start' AND params_key.key = 'level_event') AS Count
FROM `gab002.analytics_378566684.events_*`, UNNEST(event_params) AS params_key
WHERE event_name = 'a_level_start' AND params_key.key = 'level_event'
GROUP BY event_date, Level
ORDER BY event_date, Level
)
SELECT
  start_date.Level,
  SUM(start_date.User) AS Users,
  SUM(start_date.Count) AS Counts,
  CONCAT(ROUND((100 * SUM(start_date.Count) / (SELECT start_date.Count FROM start_date WHERE start_date.Level = 1)),2), '%') AS percent_user
FROM start_date
JOIN (
  SELECT Level,
    COUNT AS LevelCount
  FROM start_date
  WHERE
Level = 1
) AS start_date2 ON start_date.Level = start_date2.Level
GROUP BY
  start_date.Level,
  start_date2.LevelCount
ORDER BY
  start_date.Level ASC;
-------------------------------------------------------------------------------------
-- WEEK:
WITH analytics_data AS (
  SELECT user_pseudo_id, event_timestamp, event_name, 
    UNIX_MICROS(TIMESTAMP("2023-05-29 00:00:00", "-7:00")) AS start_day,
    3600*1000*1000*24*7 AS one_week_micros
  FROM `gab002.analytics_378566684.events_*`
  WHERE _table_suffix BETWEEN '20230529' AND '20230627'
)

SELECT 
  IFNULL(week_0_cohort / NULLIF(week_0_cohort, 0), 0) AS week_0_pct,
  IFNULL(week_1_cohort / NULLIF(week_0_cohort, 0), 0) AS week_1_pct,
  IFNULL(week_2_cohort / NULLIF(week_0_cohort, 0), 0) AS week_2_pct,
  IFNULL(week_3_cohort / NULLIF(week_0_cohort, 0), 0) AS week_3_pct
FROM (

  WITH week_3_users AS (
    SELECT DISTINCT user_pseudo_id
    FROM analytics_data
    WHERE event_timestamp BETWEEN start_day+(3*one_week_micros) AND start_day+(4*one_week_micros)
  ),
  week_2_users AS (
    SELECT DISTINCT user_pseudo_id
    FROM analytics_data
    WHERE event_timestamp BETWEEN start_day+(2*one_week_micros) AND start_day+(3*one_week_micros)
  ),
  week_1_users AS (
    SELECT DISTINCT user_pseudo_id
    FROM analytics_data
    WHERE event_timestamp BETWEEN start_day+(1*one_week_micros) AND start_day+(2*one_week_micros)
  ), 
  week_0_users AS (
    SELECT DISTINCT user_pseudo_id
    FROM analytics_data
    WHERE event_name = 'first_open'
      AND event_timestamp BETWEEN start_day AND start_day+(1*one_week_micros)
  )

  SELECT 
    (SELECT count(*) 
     FROM week_0_users) AS week_0_cohort,
    (SELECT count(*) 
     FROM week_1_users 
     JOIN week_0_users USING (user_pseudo_id)) AS week_1_cohort,
    (SELECT count(*) 
     FROM week_2_users 
     JOIN week_0_users USING (user_pseudo_id)) AS week_2_cohort,
    (SELECT count(*) 
     FROM week_3_users 
     JOIN week_0_users USING (user_pseudo_id)) AS week_3_cohort
);

-- DAY:
WITH analytics_data AS (
  SELECT user_pseudo_id, event_timestamp, event_name,
    UNIX_MICROS(TIMESTAMP("2023-05-29 00:00:00", "-7:00")) AS start_day,
    3600*1000*1000*24*1 AS one_day_micros
  FROM `gab002.analytics_378566684.events_*`
  WHERE _table_suffix BETWEEN '20230529' AND '20230627'
)
SELECT
  IFNULL(day_0_cohort / NULLIF(day_0_cohort, 0), 0) AS day_0_pct,
  IFNULL(day_1_cohort / NULLIF(day_0_cohort, 0), 0) AS day_1_pct,
  IFNULL(day_2_cohort / NULLIF(day_0_cohort, 0), 0) AS day_2_pct,
  IFNULL(day_3_cohort / NULLIF(day_0_cohort, 0), 0) AS day_3_pct
FROM (
  WITH day_3_users AS (
    SELECT DISTINCT user_pseudo_id
    FROM analytics_data
    WHERE event_timestamp BETWEEN start_day+(3*one_day_micros) AND start_day+(4*one_day_micros)
  ),
  day_2_users AS (
    SELECT DISTINCT user_pseudo_id
    FROM analytics_data
    WHERE event_timestamp BETWEEN start_day+(2*one_day_micros) AND start_day+(3*one_day_micros)
  ),
  day_1_users AS (
    SELECT DISTINCT user_pseudo_id
    FROM analytics_data
    WHERE event_timestamp BETWEEN start_day+(1*one_day_micros) AND start_day+(2*one_day_micros)
  ),
  day_0_users AS (
    SELECT DISTINCT user_pseudo_id
    FROM analytics_data
    WHERE event_name = 'first_open'
      AND event_timestamp BETWEEN start_day AND start_day+(1*one_day_micros)
  )
  SELECT
    (SELECT count(*)
     FROM day_0_users) AS day_0_cohort,
    (SELECT count(*)
     FROM day_1_users
     JOIN day_0_users USING (user_pseudo_id)) AS day_1_cohort,
    (SELECT count(*)
     FROM day_2_users
     JOIN day_0_users USING (user_pseudo_id)) AS day_2_cohort,
    (SELECT count(*)
     FROM day_3_users
     JOIN day_0_users USING (user_pseudo_id)) AS day_3_cohort
);


-- CÁCH CHỊ MAI:
WITH first_open AS(
  SELECT DATE(TIMESTAMP_MICROS(event_timestamp)) as first_open_date,user_pseudo_id
  FROM `gab002.analytics_378566684.events_*`
  WHERE event_date BETWEEN "20230601" AND "20230620"
  AND event_name = "first_open"
),
active AS(
  SELECT DISTINCT DATE(TIMESTAMP_MICROS(event_timestamp)) AS active_date, user_pseudo_id
  FROM `gab002.analytics_378566684.events_*`
  WHERE event_date BETWEEN "20230601" AND "20230620" 
  AND event_name = "session_start"
),
cohort_size AS(
  SELECT first_open_date, COUNT(DISTINCT first_open.user_pseudo_id) AS users
  FROM first_open
  GROUP BY first_open.first_open_date
)
SELECT first_open.first_open_date AS first_open_dt, DATE_DIFF(CAST(active.active_date AS DATE), CAST(first_open.first_open_date AS DATE), DAY) AS days, cohort_size.users as cohort_users, COUNT(DISTINCT active.user_pseudo_id) AS retained, SAFE_DIVIDE (COUNT(DISTINCT active.user_pseudo_id), cohort_size.users) AS retention_rate
FROM first_open
LEFT JOIN cohort_size
ON first_open.first_open_date = cohort_size.first_open_date
LEFT JOIN active
ON first_open.user_pseudo_id = active.user_pseudo_id
GROUP BY first_open_dt, days, cohort_users
ORDER BY first_open_dt, days
