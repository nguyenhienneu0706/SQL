/* 
Thông tin tài liệu được lấy tại: 
https://medium.com/firebase-developers
Ví dụ:
https://medium.com/firebase-developers/analyzing-custom-retention-cohorts-using-bigquery-and-google-analytics-for-firebase-779777595950
https://medium.com/firebase-developers/how-to-use-select-from-unnest-to-analyze-multiple-parameters-in-bigquery-for-analytics-5838f7a004c2
https://towardsdatascience.com/a-complete-guide-to-cohort-analysis-using-bigquery-and-looker-studio-1cd18c0edd79
...
*/
---------------------------------------------------------------------------------------------------------------------------------------------
/* 1. PHỤC VỤ TÍNH RETENTION RATE (RR) */

** TRƯỜNG HỢP CỤ THỂ:
  
-- THỰC HIỆN BƯỚC 01: LẤY DANH SÁCH USER THỎA MÃN:
-- CÁCH 01:
-- Lấy ra danh sách người dùng đã sử dụng ứng dụng từ ngày 8/88 đến ngày 14/8 nằm trong nhóm người chơi bắt đầu sử dụng ứng dụng vào tuần trước.
SELECT DISTINCT user_pseudo_id
FROM `firebase-public-project.analytics_153293282.events_*`
WHERE event_timestamp >= UNIX_MICROS(TIMESTAMP("2018-08-08 00:00:00", "-7:00")) 
AND  event_timestamp < UNIX_MICROS(TIMESTAMP("2018-08-15 00:00:00", "-7:00")) 
AND _TABLE_SUFFIX BETWEEN '20180807' AND '20180815'
AND user_pseudo_id IN 
( 
  -- Đầu tiên lấy ra danh sách tất cả người dùng lần đầu tiên mở ứng dụng sau nửa đêm vào ngày 1/8 và ngay trước nửa đêm ngày 8/8:
  SELECT DISTINCT user_pseudo_id
  FROM `firebase-public-project.analytics_153293282.events_*`
  WHERE event_name = 'first_open'
  AND event_timestamp >= UNIX_MICROS(TIMESTAMP("2018-08-01 00:00:00", "-7:00")) 
  AND  event_timestamp < UNIX_MICROS(TIMESTAMP("2018-08-08 00:00:00", "-7:00")) 
  AND _TABLE_SUFFIX BETWEEN '20180731' AND '20180808'
);

-- CÁCH 02:
-- Lấy ra danh sách người dùng đã sử dụng ứng dụng từ ngày 8/88 đến ngày 14/8 nằm trong nhóm người chơi bắt đầu sử dụng ứng dụng vào tuần trước.
WITH week_1_users AS (
  SELECT DISTINCT user_pseudo_id
  FROM `firebase-public-project.analytics_153293282.events_*`
  WHERE event_timestamp >= UNIX_MICROS(TIMESTAMP("2018-08-08 00:00:00", "-7:00")) 
    AND  event_timestamp < UNIX_MICROS(TIMESTAMP("2018-08-15 00:00:00", "-7:00")) 
    AND _TABLE_SUFFIX BETWEEN '20180807' AND '20180815'
), 
week_0_users AS 
(
-- Đầu tiên lấy ra danh sách tất cả người dùng lần đầu tiên mở ứng dụng sau nửa đêm vào ngày 1/8 và ngay trước nửa đêm ngày 8/8:
  SELECT DISTINCT user_pseudo_id
  FROM `firebase-public-project.analytics_153293282.events_*`
  WHERE event_name = 'first_open'
    AND event_timestamp >= UNIX_MICROS(TIMESTAMP("2018-08-01 00:00:00", "-7:00")) 
    AND  event_timestamp < UNIX_MICROS(TIMESTAMP("2018-08-08 00:00:00", "-7:00")) 
    AND _TABLE_SUFFIX BETWEEN '20180731' AND '20180808'
)
SELECT * from week_1_users JOIN week_0_users USING(user_pseudo_id);

-- THỰC HIỆN BƯỚC 02: LẤY THEO COHORT

WITH week_3_users AS (
  SELECT DISTINCT user_pseudo_id
  FROM `firebase-public-project.analytics_153293282.events_*`
  WHERE event_timestamp >= UNIX_MICROS(TIMESTAMP("2018-08-22 00:00:00", "-7:00")) 
    AND  event_timestamp < UNIX_MICROS(TIMESTAMP("2018-08-29 00:00:00", "-7:00")) 
    AND _TABLE_SUFFIX BETWEEN '20180821' AND '20180829'
),
week_2_users AS (
  SELECT DISTINCT user_pseudo_id
  FROM `firebase-public-project.analytics_153293282.events_*`
  WHERE event_timestamp >= UNIX_MICROS(TIMESTAMP("2018-08-15 00:00:00", "-7:00")) 
    AND  event_timestamp < UNIX_MICROS(TIMESTAMP("2018-08-22 00:00:00", "-7:00")) 
    AND _TABLE_SUFFIX BETWEEN '20180814' AND '20180822'
),
week_1_users AS (
  SELECT DISTINCT user_pseudo_id
  FROM `firebase-public-project.analytics_153293282.events_*`
  WHERE event_timestamp >= UNIX_MICROS(TIMESTAMP("2018-08-08 00:00:00", "-7:00")) 
    AND  event_timestamp < UNIX_MICROS(TIMESTAMP("2018-08-15 00:00:00", "-7:00")) 
    AND _TABLE_SUFFIX BETWEEN '20180807' AND '20180815'
), week_0_users AS (
  SELECT DISTINCT user_pseudo_id
  FROM `firebase-public-project.analytics_153293282.events_*`
  WHERE event_name = 'first_open'
    AND event_timestamp >= UNIX_MICROS(TIMESTAMP("2018-08-01 00:00:00", "-7:00")) 
    AND  event_timestamp < UNIX_MICROS(TIMESTAMP("2018-08-08 00:00:00", "-7:00")) 
    AND _TABLE_SUFFIX BETWEEN '20180731' AND '20180808'
)
SELECT 
  (SELECT count(*) FROM week_0_users) AS week_0_cohort,
  (SELECT count(*) 
   FROM week_1_users 
   JOIN week_0_users USING (user_pseudo_id)) AS week_1_cohort,
  (SELECT count(*) 
   FROM week_2_users 
   JOIN week_0_users USING (user_pseudo_id)) AS week_2_cohort,
  (SELECT count(*) 
   FROM week_3_users 
   JOIN week_0_users USING (user_pseudo_id)) AS week_3_cohort;

-- THỰC HIỆN BƯỚC 03: TÍNH TOÁN CHỈ SỐ % RR

SELECT 
 week_0_cohort / week_0_cohort AS week_0_pct,
 week_1_cohort / week_0_cohort AS week_1_pct,
 week_2_cohort / week_0_cohort AS week_2_pct,
 week_3_cohort / week_0_cohort AS week_3_pct
FROM (
  WITH week_3_users AS (
    SELECT DISTINCT user_pseudo_id
    FROM `firebase-public-project.analytics_153293282.events_*`
    WHERE event_timestamp >= UNIX_MICROS(TIMESTAMP("2018-08-22 00:00:00", "-7:00")) 
      AND  event_timestamp < UNIX_MICROS(TIMESTAMP("2018-08-29 00:00:00", "-7:00")) 
      AND _TABLE_SUFFIX BETWEEN '20180821' AND '20180829'
  ),
  week_2_users AS (
    SELECT DISTINCT user_pseudo_id
    FROM `firebase-public-project.analytics_153293282.events_*`
    WHERE event_timestamp >= UNIX_MICROS(TIMESTAMP("2018-08-15 00:00:00", "-7:00")) 
      AND  event_timestamp < UNIX_MICROS(TIMESTAMP("2018-08-22 00:00:00", "-7:00")) 
      AND _TABLE_SUFFIX BETWEEN '20180814' AND '20180822'
  ),
  week_1_users AS (
    SELECT DISTINCT user_pseudo_id
    FROM `firebase-public-project.analytics_153293282.events_*`
    WHERE event_timestamp >= UNIX_MICROS(TIMESTAMP("2018-08-08 00:00:00", "-7:00")) 
      AND  event_timestamp < UNIX_MICROS(TIMESTAMP("2018-08-15 00:00:00", "-7:00")) 
      AND _TABLE_SUFFIX BETWEEN '20180807' AND '20180815'
  ), 
  week_0_users AS (
    SELECT DISTINCT user_pseudo_id
    FROM `firebase-public-project.analytics_153293282.events_*`
    WHERE event_name = 'first_open'
      AND event_timestamp >= UNIX_MICROS(TIMESTAMP("2018-08-01 00:00:00", "-7:00")) 
      AND  event_timestamp < UNIX_MICROS(TIMESTAMP("2018-08-08 00:00:00", "-7:00")) 
      AND _TABLE_SUFFIX BETWEEN '20180731' AND '20180808'
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
-- Tuy nhiên, điều gì sẽ xảy ra nếu chúng ta đột nhiên muốn thay đổi ngày bắt đầu của báo cáo?
-->

** TRƯỜNG HỢP TỔNG QUÁT:
-- BƯỚC 01:
WITH analytics_data AS (
  SELECT user_pseudo_id, event_timestamp, event_name, 
    UNIX_MICROS(TIMESTAMP("2018-08-01 00:00:00", "-7:00")) AS start_day,
    3600*1000*1000*24*7 AS one_week_micros
  FROM `firebase-public-project.analytics_153293282.events_*`
  WHERE _table_suffix BETWEEN '20180731' AND '20180829'
)
SELECT DISTINCT user_pseudo_id
FROM analytics_data
WHERE event_name = 'first_open'
  AND event_timestamp BETWEEN start_day AND start_day+(1*one_week_micros)

-- BƯỚC 02:
WITH analytics_data AS (
  SELECT user_pseudo_id, event_timestamp, event_name, 
    UNIX_MICROS(TIMESTAMP("2018-08-01 00:00:00", "-7:00")) AS start_day,
    3600*1000*1000*24*7 AS one_week_micros
  FROM `firebase-public-project.analytics_153293282.events_*`
  WHERE _table_suffix BETWEEN '20180731' AND '20180829'
)
  
SELECT week_0_cohort / week_0_cohort AS week_0_pct,
 week_1_cohort / week_0_cohort AS week_1_pct,
 week_2_cohort / week_0_cohort AS week_2_pct,
 week_3_cohort / week_0_cohort AS week_3_pct
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

----------------------------------------------------------------------------------------------------------------------------------------

-- TRƯỜNG HỢP GAMOTA:
-- RR THEO TUẦN:
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

-- RR THEO NGÀY:
WITH analytics_data AS (
  SELECT user_pseudo_id, event_timestamp, event_name,
    UNIX_MICROS(TIMESTAMP("2023-05-29 00:00:00", "-7:00")) AS start_day,
    3600*1000*1000*24*1 AS one_day_micros
  FROM `gab002.analytics_378566684.events_*`
  WHERE _table_suffix BETWEEN '20230529' AND '20230627' 
  -- Có hay không có dòng này cũng được nó chỉ xác định cái phần mà câu này nó tìm đến
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

-- ĐÂY LÀ CÂU CODE LẤY RA RR1,3,7 CỦA MỘT NGÀY NÀO ĐÓ, NGÀY MÌNH PHẢI TỰ THAY ĐỔI
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
  IFNULL(day_3_cohort / NULLIF(day_0_cohort, 0), 0) AS day_3_pct,
  IFNULL(day_7_cohort / NULLIF(day_0_cohort, 0), 0) AS day_7_pct
FROM (
  WITH day_7_users AS (
    SELECT DISTINCT user_pseudo_id
    FROM analytics_data
    WHERE event_timestamp BETWEEN start_day+(7*one_day_micros) AND start_day+(8*one_day_micros)
  ),
  day_3_users AS (
    SELECT DISTINCT user_pseudo_id
    FROM analytics_data
    WHERE event_timestamp BETWEEN start_day+(3*one_day_micros) AND start_day+(4*one_day_micros)
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
     FROM day_3_users
     JOIN day_0_users USING (user_pseudo_id)) AS day_3_cohort,
    (SELECT count(*)
     FROM day_7_users
     JOIN day_0_users USING (user_pseudo_id)) AS day_7_cohort
);
