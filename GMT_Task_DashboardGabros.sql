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
