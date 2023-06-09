/* 
Task sử dụng dữ liệu ở Dataset: gmogamesdk5.analytics_165902128. Table Event với event_intraday là kéo tự động từ Firebase Analytics ra BigQuery:
BI A Đức ✈, [6/7/2023 2:20 PM]
- intraday là kéo realtime trong ngày
- kéo tự động từ firebase sang
- có một số data về chậm, cụ thể là 3 ngày sau mới về
- thì nó vẫn sẽ lưu ở intraday. Sau 3 ngày nó sẽ đẩy về event 
*/

-- CHÚ Ý: TÊN BẢNG EVENTS_ SẼ LÀ ĐƯỢC CẬP NHẬT HÀNG NGÀY. VÍ DỤ ***.events_20230606 THÌ 20230606 SẼ LÀ NGÀY GẦN NHẤT CÓ DỮ LIỆU XUẤT ĐƯỢC CẬP NHẬT TRONG BẢNG:
-- Vì vậy khi sử dụng nên copy ID của bảng để đúng nhất:
SELECT * 
FROM `gab002.analytics_378566684.events_20230606`
LIMIT 3

-- 1. Lấy số lượt first_open THEO NGÀY:
SELECT event_date, COUNT(DISTINCT user_pseudo_id) AS no_user_first_open
FROM `gab002.analytics_378566684.events_*`,
  UNNEST(event_params) AS params_key
WHERE event_name = 'first_open'
GROUP BY event_date
LIMIT 5;

-- 1.1. Lấy số lượt first_open TRONG MỘT KHOẢNG THỜI GIAN:
WITH date_range AS (
  SELECT 
    MIN(event_date) AS min_event_date,
    MAX(event_date) AS max_event_date
  FROM `gab002.analytics_378566684.events_*`, UNNEST(event_params) AS params_key
  WHERE event_name = 'first_open'
)
SELECT COUNT(DISTINCT user_pseudo_id) AS no_user_first_open
FROM `gab002.analytics_378566684.events_*`, UNNEST(event_params) AS params_key, date_range
WHERE event_name = 'first_open'
  AND event_date >= date_range.min_event_date
  AND event_date <= date_range.max_event_date;

