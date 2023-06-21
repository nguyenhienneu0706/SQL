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
