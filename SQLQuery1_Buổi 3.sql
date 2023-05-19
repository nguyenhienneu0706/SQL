-- BUỔI 3: KẾT HỢP BẢNG (JOIN - KẾT HỢP THEO CHIỀU NGANG) & (UNION - KẾT HƠP THEO CHIỀU DỌC)
-- PHẦN 1: JOIN
-- JOIN được sử dụng để kết hợp các dữ liệu từ hai hoặc nhiều bảng dựa trên mối liên quan giữa chúng
-- Các loại Join thường dùng:
--  INNER JOIN hay JOIN
--  LEFT OUTER JOIN hay LEFT JOIN: 
--  RIGHT OUTER JOIN hay RIGHT JOIN--  FULL JOIN hay FULL OUTER JOIN-- CỤ THỂ VỚI:
SELECT * FROM Returns;
SELECT * FROM Managers;
SELECT * FROM Orders;
SELECT * FROM Profiles;

-- Cách sử dụng và cấu trúc INNER JOIN:
-- KẾT QUẢ: Trả về các bản ghi có giá trị khớp trong cả hai bảng (CÁC BẢN GHI CHUNG TRONG CỘT KEY.JOIN)
-- Cấu trúc câu lệnh mẫu:
SELECT Column_name (s)
FROM Table_A AS T1
INNER JOIN Table_B AS T2
ON Table_A.Key_column_name = Table_B.Key_column_name;

-- THỰC HÀNH: VIẾT CÂU TRUY VẤN TRẢ VỀ KQ BẢNG GỒM CÁC CỘT: 
-- order_id, order_date, value, status
-- VÌ BẢNG RETURNS LÀ TẬP CON CỦA ORDERS NÊN CÁC ĐƠN KẾT QUẢ ĐỀU LÀ CÁC ĐƠN BỊ TRẢ HÀNG (RETURNS)
SELECT T1.order_id, T1.order_date, T1.value, T2.status
FROM ORDERS AS T1
INNER JOIN RETURNS AS T2
ON T1.order_id=T2.order_id; --ĐỊNH NGHĨA MỐI LIÊN HỆ GIỮA 2 BẢNG

-- THỰC HÀNH: TỪ BẢNG Managers và Profiles LẤY RA NHỮNG ĐƠN HÀNG CÓ Managers.manager_name=Profiles.manager
SELECT *
FROM Managers, Profiles
WHERE Managers.manager_name=Profiles.manager;

-- THỰC HÀNH: TỪ BẢNG Managers và Profiles LẤY RA NHỮNG ĐƠN HÀNG CÓ Managers.manager_name=Profiles.manager
SELECT *
FROM Managers as T1
INNER JOIN Profiles as T2
ON T1.manager_name=T2.manager;

-- THỰC HÀNH: TỪ BẢNG Managers và Profiles LẤY RA NHỮNG ĐƠN HÀNG CÓ Managers.manager_name=Profiles.manager
-- BAO GỒM NHỮNG THÔNG TIN SAU: manager_id, manager_name, region.
SELECT 
 T1.manager_id,
 T1.manager_name,
 T2.region
FROM Managers as T1
INNER JOIN Profiles as T2
ON T1.manager_name=T2.manager;

-- THỰC HÀNH: TỪ BẢNG Orders và Returns CHỈ LẤY RA NHỮNG ĐƠN Returned BAO GỒM NHỮNG THÔNG TIN SAU:
-- order_id, order_date, value, product_name, returned_date
-- TA THẤY: ĐƠN Returned LÀ ĐƠN CÓ Returns.status='Returned'
SELECT 
 T1.order_id,
 T1.order_date,
 T1.value,
 T1.product_name,
 T2.returned_date
FROM ORDERS AS T1
FULL JOIN RETURNS AS T2
ON T1.ORDER_ID = T2. ORDER_ID
WHERE T2.Status='Returned'; --TRUE
-- hoặc:
SELECT 
 T1.order_id,
 T1.order_date,
 T1.value,
 T1.product_name,
 T2.returned_date
FROM Orders as T1
INNER JOIN Returns as T2
ON T1.order_id=T2.order_id; --THỬ RA 872 ROWS, ĐÚNG

-- Cách sử dụng và cấu trúc LEFT JOIN - GIỐNG HOÀN TOÀN VỚI CÁCH THỨC CỦA VLOOKUP TRÊN EXCEL

-- Kết quả: Trả về tất cả các bản ghi từ bảng bên trái (A) và các bản ghi phù hợp từ bảng bên phải (B).
-- HAY: bảng trái làm gốc, bảng phải là bảng tham khảo, bảng trái k thay đổi, bảng phải tìm về thông tin thì điền, không tìm thấy thì là null
-- CHÚ Ý: Kết quả là NULL từ bên phải, nếu không có kết quả phù hợp.
-- BẢNG TRÁI LÀ BẢNG SAU FROM, BẢNG PHẢI SAU JOIN
-- CÚ PHÁP: Cấu trúc câu lệnh mẫu:
SELECT Column_name (s)
FROM Table_A
LEFT JOIN Table_B
ON Table_A.Key_column_name = Table_B.Key_column_name;-- THỰC HÀNH: VIẾT CÂU TRUY VẤN TRẢ VỀ KQ BẢNG GỒM CÁC CỘT: 
-- order_id, order_date, value, status
-- BẢNG KẾT QUẢ CHỨA TẤT CẢ CÁC ĐƠN HÀNG TRONG BẢNG ORDERS -> BẢNG ORDERS LÀ BẢNG GỐC
SELECT 
   T1.ORDER_ID, 
   T1.ORDER_DATE, 
   T1.VALUE, 
   T2.STATUS
FROM ORDERS AS T1
LEFT JOIN RETURNS AS T2
ON T1.ORDER_ID=T2.ORDER_ID; --ĐỊNH NGHĨA MỐI LIÊN HỆ GIỮA 2 BẢNG-- NẾU MUỐN BỎ NHỮNG ĐƠN HÀNG NHẬN HÀNG THÌ LÀ: (=INNER JOIN)
SELECT 
   T1.ORDER_ID, 
   T1.ORDER_DATE, 
   T1.VALUE, 
   T2.STATUS
FROM ORDERS AS T1
LEFT JOIN RETURNS AS T2
ON T1.ORDER_ID=T2.ORDER_IDWHERE T2.STATUS='RETURNED';-- HOẶC LÀ:SELECT 
   T1.ORDER_ID, 
   T1.ORDER_DATE, 
   T1.VALUE, 
   T2.STATUS
FROM ORDERS AS T1
LEFT JOIN RETURNS AS T2
ON T1.ORDER_ID=T2.ORDER_IDWHERE T2.STATUS IS NOT NULL;-- THỰC HÀNH: TỪ BẢNG Managers và Profiles LẤY RA NHỮNG ĐƠN HÀNG CÓ Managers.manager_name=Profiles.manager
-- BAO GỒM NHỮNG THÔNG TIN SAU: manager_id, manager_name, region.SELECT
 T1.manager_id,
 T1.manager_name,
 T2.region
FROM Managers as T1
LEFT JOIN Profiles as T2
ON T1.manager_name=T2.manager;

-- THỰC HÀNH: Từ bảng Orders và Returns lấy ra những đơn returns bao gồm những thông tin sau:
-- order_id, order_date, total_value, total_order_quantity, status, returned_date
-- HOẶC: ORDERS LÀ BẢNG A:
SELECT 
 T1.order_id,
 T1.order_date,
 SUM(value) AS total_value,
 SUM(order_quantity) AS total_order_quantity,
 T2.status,
 T2.returned_date
FROM Orders as T1
LEFT JOIN Returns as T2
ON T1.order_id=T2.order_id
GROUP BY T1.order_id, T1.order_date, T2.status, T2.returned_date;

-- HOẶC: ORDERS LÀ BẢNG B (PHẢI CHUYỀN LEFT THÀNH RIGHT)
SELECT 
 T2.order_id,
 T2.order_date,
 SUM(value) AS total_value,
 SUM(order_quantity) AS total_order_quantity,
 T1.status,
 T1.returned_date
FROM Returns as T1
RIGHT JOIN Orders as T2
ON T2.order_id=T1.order_id
GROUP BY T2.order_id, T2.order_date, T1.status, T1.returned_date;

-- Cách sử dụng và cấu trúc RIGHT JOIN
-- Kết quả: Trả về tất cả các bản ghi từ bảng bên phải (B) và các bản ghi phù hợp từ bảng bên trái (A).
-- Kết quả là NULL từ bên trái, nếu không có kết quả phù hợp.
-- CÚ PHÁP: Cấu trúc câu lệnh mẫu:
SELECT Column_name (s)
FROM Table_A
RIGHT JOIN Table_B
ON Table_A.Key_column_name = Table_B.Key_column_name;-- THỰC HÀNH: VIẾT CÂU TRUY VẤN TRẢ VỀ KQ BẢNG GỒM CÁC CỘT: 
-- order_id, order_date, value, status, profit, customer_name
-- BẢNG KẾT QUẢ CHỨA TẤT CẢ CÁC ĐƠN HÀNG TRONG BẢNG ORDERS -> BẢNG ORDERS LÀ BẢNG GỐC
SELECT 
   T1.STATUS,
   T2.PROFIT,
   T2.CUSTOMER_NAME,
   T2.ORDER_ID, 
   T2.ORDER_DATE, 
   T2.VALUE
FROM RETURNS AS T1
RIGHT JOIN ORDERS AS T2
ON T1.ORDER_ID=T2.ORDER_ID;-- NẾU MUỐN BỎ NHỮNG ĐƠN HÀNG NHẬN HÀNG THÌ LÀ: (=INNER JOIN)
SELECT 
   T1.STATUS,
   T2.PROFIT,
   T2.CUSTOMER_NAME,
   T2.ORDER_ID, 
   T2.ORDER_DATE, 
   T2.VALUE
FROM RETURNS AS T1
RIGHT JOIN ORDERS AS T2
ON T1.ORDER_ID=T2.ORDER_IDWHERE T2.STATUS='RETURNED';-- HOẶC LÀ:SELECT 
   T1.STATUS,
   T2.PROFIT,
   T2.CUSTOMER_NAME,
   T2.ORDER_ID, 
   T2.ORDER_DATE, 
   T2.VALUE
FROM RETURNS AS T1
RIGHT JOIN ORDERS AS T2
ON T1.ORDER_ID=T2.ORDER_IDWHERE T2.STATUS IS NOT NULL;-- THỰC HÀNH: TỪ BẢNG Managers và Profiles LẤY RA NHỮNG ĐƠN HÀNG CÓ Managers.manager_name=Profiles.manager
-- BAO GỒM NHỮNG THÔNG TIN SAU: manager_id, manager_name, region TRONG BẢNG Managers.SELECT
T1.manager_id,
T1.manager_name,
T2.region
FROM Managers as T1
RIGHT JOIN Profiles as T2
ON T1.manager_name=T2.manager;

-- THỰC HÀNH: Từ bảng Orders và Returns lấy ra những đơn returns bao gồm những thông tin sau:
-- order_id, order_date, total_value, total_order_quantity, status, returned_date
SELECT 
 T1.order_id,
 T1.order_date,
 SUM(value) AS total_value,
 SUM(order_quantity) AS total_order_quantity,
 T2.status,
 T2.returned_date
FROM Orders as T1
RIGHT JOIN Returns as T2
ON T1.order_id=T2.order_id
GROUP BY T1.order_id, T1.order_date, T2.status, T2.returned_date;

-- Cách sử dụng và cấu trúc FULL OUTER JOIN - KẾT HỢP 2 BẢNG LÀM MỘT, TRẢ VỀ TẤT CẢ GTRI KEY.JOIN Ở CẢ 2 BẢNG
-- KHÔNG QUAN TÂM BẢNG TRÁI, BẢNG PHẢI
-- Kết quả: Trả về tất cả các bản ghi khi có kết quả khớp trong bản ghi bảng trái (A) hoặc phải (B)
-- Cấu trúc câu lệnh mẫu:
SELECT Column_name (s)
FROM Table_A
FULL OUTER JOIN Table_B
ON Table_A.Key_column_name = Table_B.Key_column_name;

-- THỰC HÀNH: VIẾT CÂU TRUY VẤN TRẢ VỀ KQ BẢNG GỒM CÁC CỘT: 
-- order_id, order_date, value, status, profit, customer_name
-- BẢNG KẾT QUẢ CHỨA TẤT CẢ CÁC ĐƠN HÀNG TRONG BẢNG ORDERS -> BẢNG ORDERS LÀ BẢNG GỐC
SELECT 
   T1.STATUS,
   T2.PROFIT,
   T2.CUSTOMER_NAME,
   T2.ORDER_ID, 
   T2.ORDER_DATE, 
   T2.VALUE
FROM RETURNS AS T1
FULL JOIN ORDERS AS T2
ON T1.ORDER_ID=T2.ORDER_ID; -- DÙNG FULL JOIN ĐƯỢC VÌ BẢNG ORDERS CHỨA LUÔN BẢNG RETURNS RỒI

-- THỰC HÀNH: Từ bảng Managers và Profiles sử dụng Full Outer Join lấy ra thông tin:
-- t1.manager_id, t1.manager_level, t1.manager_name,t1.manager_phone, t2.Manager, t2.province
SELECT 
T1.manager_id, 
T1.manager_level, 
T1.manager_name,
T1.manager_phone, 
T2.Manager, 
T2.province
FROM Managers as T1
FULL OUTER JOIN Profiles as T2
ON T1.manager_name = T2.manager;

-- THỰC HÀNH: Từ bảng Orders và Returns sử dụng Full Outer Join lấy ra thông tin:
-- order_id, order_date, total_value, total_order_quantity, status, returned_date
SELECT 
T1.order_id, 
T1.order_date, 
SUM(value) AS total_value,
SUM(order_quantity) AS total_order_quantity,
T2.returned_date
FROM Orders AS T1
FULL OUTER JOIN Returns AS T2
ON T1.order_id = T2.order_id
GROUP BY T1.order_id, T1.order_date, T2.returned_date;
----- TỔNG KẾT 04 LOẠI JOIN -----INNER JOIN: CHUNG, KHÔNG QUAN TÂM BẢNG TRÁI, PHẢILEFT JOIN: BẢNG TRÁI LÀM GỐC, BẢNG PHẢI THAM CHIẾU (GIỐNG VLOOKUP TRÊN EXCEL - CHỊ LINH RECOMMENT)RIGHT JOIN: BẢNG PHẢI LÀM GỐC, BẢNG TRÁI THAM CHIẾUFULL JOIN: GỘP 02 BẢNG VỚI NHAUPHÂN BIỆT LEFT VÀ RIGHT: PHÂN BIỆT BẢNG TRÁI VÀ PHẢI-- --THỰC HÀNH: LẤY THÔNG TIN ORDER_ID, VALUE, PROFIT, CUSTOMER_NAME, ORDER_PRIORITY CỦA CÁC ĐƠN HÀNG BỊ TRẢ LẠISELECT 
 T1.ORDER_ID,
 T1.PROFIT,
 T1.CUSTOMER_NAME,
 T1.VALUE,
 T1.ORDER_PRIORITY
FROM Orders as T1
INNER JOIN Returns as T2
ON T1.order_id=T2.order_id;-- HOẶC:SELECT 
 T1.ORDER_ID,
 T1.PROFIT,
 T1.CUSTOMER_NAME,
 T1.VALUE,
 T1.ORDER_PRIORITY
FROM ORDERS AS T1
FULL JOIN RETURNS AS T2
ON T1.ORDER_ID = T2. ORDER_ID
WHERE T2.Status='Returned';-- Giới thiệu UNION Và UNION ALL: -- KHÁC NHAU Ở CHỖ: ALL KHÔNG LOẠI BỎ TRÙNG LẶP, UNION THÌ LOẠI BỎ TRÙNG LẶP LUÔN (CHỊ LINH HỎI VIETIN)-- Union và Union All là phép nối các bảng có cấu trúc giống nhau, trong đó:
--  Union All sẽ lấy tất cả bản ghi của phép nối (cả trùng lặp)
--  Union sẽ chỉ lấy các bản ghi duy nhất (không trùng lặp)

-- KHI CHẮC CHẮN KHÔNG CÓ SỰ TRÙNG LẶP TRONG DỮ LIỆU -> DÙNG UNION ALL ĐỂ ĐỠ TỐN HIỆU NĂNG;
-- UNION TƯƠNG ỨNG UNIQUE TRÊN EXCEL, CỨ UNIQUE CỦA UNION ALL = UNION
-- UNION TRONG CÂU TRUY VẤN LÀ DẤU CHẤM PHẨY
-- Cấu trúc giống nhau là gì?
--  Các bảng phải có cùng số cột, TÊN CỘT KHÁC CŨNG ĐƯỢC (1 CỘT DÙNG TA, 1 CỘT DÙNG TIẾNG VIỆT CŨNG ĐƯỢC)
--  Các cột cũng phải có các loại dữ liệu tương tự
--  Các cột trong mỗi bảng phải theo thứ tự
-- CÚ PHÁP:
SELECT column1, column2, column3 
FROM table1 
UNION
SELECT column1, column2, column3 
FROM table2;
-- HOẶC:
SELECT column1, column2, column3 
FROM table1 
UNION ALL
SELECT column1, column2, column3 
FROM table2;

--

-- THỰC HÀNH: DÙNG UNION ALL NỐI province VÀ region CỦA 02 BẢNG Profiles VÀ Orders VỚI NHAU
SELECT T1.province, T1.region 
FROM Profiles AS T1
UNION ALL
SELECT T2.province, T2.region 
FROM Orders AS T2;

-- THỰC HÀNH: Dùng Union và Union All nối Profiles với Profiles sau đó rút ra nhận xét so sánh về kết quả số lượng bản ghi từ hai phép nối
-- DÙNG UNION: KẾT QUẢ TRẢ VỀ VẪN LÀ BẢNG Profiles BAN ĐẦU
SELECT *
FROM Profiles AS T1
UNION
SELECT *
FROM Profiles AS T2;
-- DÙNG UNION ALL: KẾT QUẢ TRẢ VỀ LÀ LẶP 02 LẦN BẢNG Profiles BAN ĐẦU
SELECT *
FROM Profiles AS T1
UNION ALL
SELECT *
FROM Profiles AS T2;

-- BT1: Từ bảng Orders và Returns tính tổng order_quantity, value, profit của các đơn hàng có trạng thái 
-- status = 'Returned' (kết quả chỉ lấy ra đơn hàng có trạng thái returned)
-- THÔNG TIN BẢNG GỒM: order_id_return, order_date, returned_date
-- Lưu ý: Làm với 3 loại join ( inner join, left join, right join)

-- CÚ PHÁP:
-- TRƯỜNG HỢP 1: INNER JOIN 
SELECT 
T1.order_id,
T1.order_date,
SUM(order_quantity) AS total_order_quantity,
SUM(value) AS total_value,
SUM(profit) AS total_profit,
T2.returned_date
FROM Orders AS T1
INNER JOIN Returns AS T2
ON T1.order_id=T2.order_id
GROUP BY T1.order_id, T1.order_date, T2.returned_date;
-- CÓ THỂ SẮP XẾP THỨ TỰ TĂNG GIẢM THEO NGÀY THÁNG, TỔNG LỢI NHUẬN, ...
-- DÙNG: ORDER BY order_date desc
-- VD SẮP XẾP THEO THỨ TỰ GIẢM DẦN TỔNG LỢI NHUẬN:
SELECT 
T1.order_id,
T1.order_date,
SUM(order_quantity) AS total_order_quantity,
SUM(value) AS total_value,
SUM(profit) AS total_profit,
T2.returned_date
FROM Orders AS T1
INNER JOIN Returns AS T2
ON T1.order_id=T2.order_id
GROUP BY T1.order_id, T1.order_date, T2.returned_date
ORDER BY  total_profit DESC;

-- TRƯỜNG HỢP 2: LEFT JOIN 
-- Vì kết quả chỉ lấy ra đơn hàng có trạng thái returned nên phải loại đi những đơn có T2.returned_date = NULL
SELECT 
T1.order_id,
T1.order_date,
SUM(order_quantity) AS total_order_quantity,
SUM(value) AS total_value,
SUM(profit) AS total_profit,
T2.returned_date
FROM Orders AS T1
LEFT JOIN Returns AS T2
ON T1.order_id=T2.order_id
WHERE T2.returned_date IS NOT NULL
GROUP BY T1.order_id, T1.order_date, T2.returned_date;

-- TRƯỜNG HỢP 3: RIGHT JOIN
SELECT 
T1.order_id,
T1.order_date,
SUM(order_quantity) AS total_order_quantity,
SUM(value) AS total_value,
SUM(profit) AS total_profit,
T2.returned_date
FROM Orders AS T1
RIGHT JOIN Returns AS T2
ON T1.order_id=T2.order_id
GROUP BY T1.order_id, T1.order_date, T2.returned_date;

-- BT2: Sử dụng 2 bảng Orders và Profiles tính:
-- total_order_quantity, total_value, total_profit của từng manager
-- Gợi ý: Mối quan hệ giữa 2 bảng là cột province (VÌ MỖI TỈNH CÓ MỘT NGƯỜI QUẢN LÝ, MỘT NHÀ QUẢN LÝ CÓ THỂ QUẢN LÝ NHIỀU HƠN MỘT TỈNH)
-- CÚ PHÁP:
-- TRƯỜNG HỢP 1: INNER JOIN 
SELECT 
T2.manager,
SUM(order_quantity) AS total_order_quantity,
SUM(value) AS total_value,
SUM(profit) AS total_profit
FROM Orders AS T1
INNER JOIN Profiles AS T2
ON T2.province=T1.province
GROUP BY T2.manager; 

-- TRƯỜNG HỢP 2: LEFT JOIN 
SELECT 
T2.manager,
SUM(order_quantity) AS total_order_quantity,
SUM(value) AS total_value,
SUM(profit) AS total_profit
FROM Orders AS T1
LEFT JOIN Profiles AS T2
ON T2.province=T1.province
GROUP BY T2.manager;

-- BT3: Hiển thị bảng tính tổng lợi nhuận (total_profit) mỗi mức độ ưu tiên (order_priority) sử dụng union all
SELECT 
T1.order_priority,
SUM(Profit) AS Total_profit
FROM Orders AS T1
WHERE 
order_priority='LOW'
OR order_priority='HIGH'
OR order_priority='MEDIUM'
OR order_priority='CRITICAL'
OR order_priority='NOT SPECIFIED'
GROUP BY T1.order_priority;

-- BT4: Hiển thị bảng tính tổng lợi nhuận mỗi mức độ ưu tiên bao gồm dòng total.
SELECT 
T1.order_priority,
SUM(Profit) AS Total_profit
FROM Orders AS T1
WHERE 
order_priority='LOW'
OR order_priority='HIGH'
OR order_priority='MEDIUM'
OR order_priority='CRITICAL'
OR order_priority='NOT SPECIFIED'
GROUP BY T1.order_priority
UNION ALL
SELECT
'Total' AS order_priority, --GÁN CỘT GIẢ ĐỂ TẠO THÀNH 2 CỘT CHO GIỐNG CẤU TRÚC BẢNG Orders
SUM(profit) AS total_profit
From Orders;

-- CHỮA BÀI TẬP:
-- BÀI TẬP VỀ NHÀ (BUỔI 03) 
-- HỌC VIÊN: NGUYỄN THỊ HIỀN
-------------------------------------------- BÀI LÀM --------------------------------------------

-- BT1: Từ bảng Orders và Returns tính tổng order_quantity, value, profit của các đơn hàng có trạng thái 
-- status = 'Returned' (kết quả chỉ lấy ra đơn hàng có trạng thái returned)
-- THÔNG TIN BẢNG GỒM: order_id_return, order_date, returned_date
-- Lưu ý: Làm với 3 loại join ( inner join, left join, right join)

-- CÚ PHÁP:
-- TRƯỜNG HỢP 1: INNER JOIN 
SELECT 
T1.order_id,
T1.order_date,
SUM(order_quantity) AS total_order_quantity,
SUM(value) AS total_value,
SUM(profit) AS total_profit,
T2.returned_date
FROM Orders AS T1
INNER JOIN Returns AS T2
ON T1.order_id=T2.order_id
GROUP BY T1.order_id, T1.order_date, T2.returned_date; ---TRUE
-- CÓ THỂ SẮP XẾP THỨ TỰ TĂNG GIẢM THEO NGÀY THÁNG, TỔNG LỢI NHUẬN, ...
-- DÙNG: ORDER BY order_date desc
-- VD SẮP XẾP THEO THỨ TỰ GIẢM DẦN TỔNG LỢI NHUẬN:
-- T2.ORDER_ID AS ORDER_ID_RETURN NHƯNG ƯU TIÊN LẤY ORDER_ID Ở BẢNG RETURN, VÌ ĐIỀU KIỆN LÀ LẤY CÁC ĐƠN RETURNED
SELECT 
T1.order_date,
SUM(order_quantity) AS total_order_quantity,
SUM(value) AS total_value,
SUM(profit) AS total_profit,
T2.order_id,
T2.returned_date
FROM Orders AS T1
INNER JOIN Returns AS T2
ON T1.order_id=T2.order_id
GROUP BY T1.order_id, T1.order_date, T2.returned_date
ORDER BY  total_profit DESC; ---TRUE

-- TRƯỜNG HỢP 2: LEFT JOIN 
-- Vì kết quả chỉ lấy ra đơn hàng có trạng thái returned nên phải loại đi những đơn có T2.returned_date = NULL
SELECT 
T1.order_id,
T1.order_date,
SUM(order_quantity) AS total_order_quantity,
SUM(value) AS total_value,
SUM(profit) AS total_profit,
T2.returned_date
FROM Orders AS T1
LEFT JOIN Returns AS T2
ON T1.order_id=T2.order_id
WHERE T2.returned_date IS NOT NULL
GROUP BY T1.order_id, T1.order_date, T2.returned_date; ---TRUE

--Mình cũng có thể sử dụng LEFT JOIN xem bảng RETURNS làm gốc, như vậy sẽ không cần lọc bỏ các đơn không bị trả lại
--VD:
SELECT 
T1.order_id,
T1.order_date,
SUM(order_quantity) AS total_order_quantity,
SUM(value) AS total_value,
SUM(profit) AS total_profit,
T2.returned_date
FROM Returns AS T2
LEFT JOIN Orders AS T1
ON T1.order_id=T2.order_id
--WHERE T2.returned_date IS NOT NULL-->Vậy mình k cần where chỗ này nữa
GROUP BY T1.order_id, T1.order_date, T2.returned_date;

-- TRƯỜNG HỢP 3: RIGHT JOIN
SELECT 
T1.order_id,
T1.order_date,
SUM(order_quantity) AS total_order_quantity,
SUM(value) AS total_value,
SUM(profit) AS total_profit,
T2.returned_date
FROM Orders AS T1
RIGHT JOIN Returns AS T2
ON T1.order_id=T2.order_id
GROUP BY T1.order_id, T1.order_date, T2.returned_date; ---TRUE
--Tương tự, phép RIGHT cũng có thể xem ORDERS làm gốc, nếu vậy mình lại cần thêm WHERE (tương tự cách em làm với LEFT) nhé ^^


-- BT2: Sử dụng 2 bảng Orders và Profiles tính:
-- total_order_quantity, total_value, total_profit của từng manager
-- Gợi ý: Mối quan hệ giữa 2 bảng là cột province (VÌ MỖI TỈNH CÓ MỘT NGƯỜI QUẢN LÝ, MỘT NHÀ QUẢN LÝ CÓ THỂ QUẢN LÝ NHIỀU HƠN MỘT TỈNH)
-- CÚ PHÁP:
-- TRƯỜNG HỢP 1: INNER JOIN 
SELECT 
T2.manager,
SUM(order_quantity) AS total_order_quantity,
SUM(value) AS total_value,
SUM(profit) AS total_profit
FROM Orders AS T1
INNER JOIN Profiles AS T2
ON T2.province=T1.province
GROUP BY T2.manager; --TRUE

-- TRƯỜNG HỢP 2: LEFT JOIN 
SELECT 
T2.manager,
SUM(order_quantity) AS total_order_quantity,
SUM(value) AS total_value,
SUM(profit) AS total_profit
FROM Orders AS T1
LEFT JOIN Profiles AS T2
ON T2.province=T1.province
GROUP BY T2.manager;--TRUE

-- BT3: Hiển thị bảng tính tổng lợi nhuận (total_profit) mỗi mức độ ưu tiên (order_priority) sử dụng union all
SELECT 
T1.order_priority,
SUM(Profit) AS Total_profit
FROM Orders AS T1
WHERE 
order_priority='LOW'
OR order_priority='HIGH'
OR order_priority='MEDIUM'
OR order_priority='CRITICAL'
OR order_priority='NOT SPECIFIED'
GROUP BY T1.order_priority;--TRUE

--Chỗ này em có thể không cần luôn where vì 5 giá trị này có đủ trong order_priority nè
--C bổ sung thêm cách này
SELECT 
order_priority,
SUM(Profit) AS Total_profit
FROM Orders
GROUP BY order_priority;
--Hoặc cách trong slide ^^

SELECT ORDER_PRIORITY, SUM(PROFIT) AS TOTAL_PROFIT 
FROM ORDERS 
WHERE ORDER_PRIORITY ='LOW'
GROUP BY ORDER_PRIORITY
UNION ALL
SELECT ORDER_PRIORITY, SUM(PROFIT) AS TOTAL_PROFIT 
FROM ORDERS 
WHERE ORDER_PRIORITY !='LOW'
GROUP BY ORDER_PRIORITY

-- BT4: Hiển thị bảng tính tổng lợi nhuận mỗi mức độ ưu tiên bao gồm dòng total.
SELECT 
T1.order_priority,
SUM(Profit) AS Total_profit
FROM Orders AS T1
WHERE 
order_priority='LOW'
OR order_priority='HIGH'
OR order_priority='MEDIUM'
OR order_priority='CRITICAL'
OR order_priority='NOT SPECIFIED'
GROUP BY T1.order_priority
UNION ALL
SELECT
'Total' AS order_priority, --GÁN CỘT GIẢ ĐỂ TẠO THÀNH 2 CỘT CHO GIỐNG CẤU TRÚC BẢNG Orders
SUM(profit) AS total_profit
From Orders;--TRUE
--Tương tự câu 3, em cũng có thể bỏ hẳn where đi nhé
-- Thank you for your reviewing! --> Good job