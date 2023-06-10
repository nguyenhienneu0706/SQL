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

-- 1. Lấy số lượt first_open TRONG MỘT KHOẢNG THỜI GIAN = TỔNG số lượt first_open THEO NGÀY, do một user chỉ ghi nhận 1 lần first_open cho đến khi họ xóa app và tải lại => xem theo ngày rồi cộng lại là được (trên looker dùng Sum)
-- Đầu tiên phải nối hai bảng lại với nhau bằng UNION ALL:
-- Cách đơn giản: 
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

-- Cách phức tạp:
SELECT event_date_parsed, COUNT(DISTINCT user_pseudo_id) AS no_user_first_open
FROM (
  SELECT PARSE_DATE('%Y%m%d', event_date) AS event_date_parsed, user_pseudo_id
  FROM `gab002.analytics_378566684.events_*`, UNNEST(event_params) AS params_key
  WHERE event_name = 'first_open'
  UNION ALL
  SELECT PARSE_DATE('%Y%m%d', event_date) AS event_date_parsed, user_pseudo_id
  FROM `gab002.analytics_378566684.events_intraday_*`, UNNEST(event_params) AS params_key
  WHERE event_name = 'first_open'
) 
WHERE event_date_parsed >= "2023-05-29" AND event_date_parsed <= "2023-06-06" -- ĐOẠN NÀY K THÊM NGÀY VẪN ĐƯỢC
GROUP BY event_date_parsed;

-- 1.1. ĐẾM TỔNG số lượt first_open TRONG MỘT KHOẢNG THỜI GIAN:
WITH date_range AS (
  SELECT 
    MIN(event_date) AS min_event_date,
    MAX(event_date) AS max_event_date
  FROM (
    SELECT event_date FROM `gab002.analytics_378566684.events_*`, UNNEST(event_params) AS params_key WHERE event_name = 'first_open'
    UNION ALL
    SELECT event_date FROM `gab002.analytics_378566684.events_intraday_*`, UNNEST(event_params) AS params_key WHERE event_name = 'first_open'
  )
)
SELECT COUNT(DISTINCT user_pseudo_id) AS no_user_first_open
FROM `gab002.analytics_378566684.events_*`, UNNEST(event_params) AS params_key, date_range
WHERE event_name = 'first_open'
  AND event_date >= date_range.min_event_date
  AND event_date <= date_range.max_event_date;
  
 -----------------------------------------------------------------------------------------------------------------------------------------------------
 -- Tối check lại thấy chưa ra số giống firebase:
SELECT event_date_parsed, COUNT(DISTINCT user_pseudo_id) AS no_user_first_open
FROM (
  SELECT PARSE_DATE('%Y%m%d', event_date) AS event_date_parsed, user_pseudo_id
  FROM `gab002.analytics_378566684.events_*`, UNNEST(event_params) AS params_key
  WHERE event_name = 'first_open'AND key = 'previous_first_open_count' AND value.int_value = 0
UNION ALL
  SELECT PARSE_DATE('%Y%m%d', event_date) AS event_date_parsed, user_pseudo_id
  FROM `gab002.analytics_378566684.events_intraday_*`, UNNEST(event_params) AS params_key
  WHERE event_name = 'first_open'AND key = 'previous_first_open_count' AND value.int_value = 0
  -- "The number of times first_open was logged before this occurrence" trong tiếng Anh có nghĩa là "Số lần sự kiện 'first_open' được đăng nhập trước lần xuất hiện này". Nếu bằng 0 tức là chưa từng ghi nhận sự kiện first_open trước đây
) 
WHERE event_date_parsed >= "2023-05-29" AND event_date_parsed <= "2023-06-06"
GROUP BY event_date_parsed;
--
  SELECT *
  FROM `gab002.analytics_378566684.events_*`, UNNEST(event_params) AS params_key
  WHERE event_name = 'first_open'
--
  SELECT *
  FROM `gab002.analytics_378566684.events_intraday_*`, UNNEST(event_params) AS params_key
  WHERE event_name = 'first_open'
