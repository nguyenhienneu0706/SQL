
-- Buổi 2: CÁC LỆNH TRUY VẤN DỮ LIỆU (TIẾP)
-- CÚ PHÁP:
SELECT * FROM Returns;
SELECT * FROM Managers;
SELECT * FROM Orders;
SELECT * FROM Profiles;
-- SỬ DỤNG TOÁN TỬ NỐI CHUỖI:
-- THỰC HÀNH: Hiển thị bảng gồm cột Quan_ly (tương ứng cột Manager), Dia_chi (Nối cột Province và cột Region ngăn cách bởi dấu ",") từ bảng Profiles
-- CÚ PHÁP: 
SELECT 
 Manager AS Quan_ly,
 Province + ',' + Region AS Dia_chi 
FROM Profiles;

-- THỰC HÀNH: Hiển thị bảng gồm cột Ma_dat_hang (tương ứng cột order_id), Ngay_tra_hang (tương 
ứng cột returned_date) từ bảng Returns-- CÚ PHÁP: SELECT order_id AS Ma_dat_hang, returned_date AS Ngay_tra_hangFROM Returns;
-- LOẠI BỎ NHỮNG DÒNG TRÙNG LẶP: Distinct
-- CÚ PHÁP:
SELECT DISTINCT * FROM TABLE_NAME;
SELECT DISTINCT COL1, COL2, COL3 * FROM TABLE_NAME;
-- THỰC HÀNH: Hiển thị danh sách của cột Manager trong bảng Profiles (CÓ TRÙNG LẶP)
SELECT Manager 
FROM Profiles;
-- HIỂN THỊ 15 BẢN GHI LẶP LẠI GIÁ TRỊ CỦA 6 GIÁ TRỊ KHÁC NHAU
-- THỰC HÀNH: Hiển thị danh sách KHÔNG TRÙNG LẶP của cột Manager trong bảng Profiles
SELECT DISTINCT Manager 
FROM Profiles;
-- HIỂN THỊ 6 BẢN GHI KHÁC NHAU
-- THỰC HÀNH: Hãy viết câu truy vấn trả về danh sách không trùng lặp của cột Province trong bảng 
Profiles
-- CÚ PHÁP: 
SELECT DISTINCT Province 
FROM Profiles;
-- THỰC HÀNH: Hãy viết câu truy vấn trả về danh sách không trùng lặp của cột Province và Manager trong bảng 
-- CÚ PHÁP: 
SELECT DISTINCT Province, Manager 
FROM Profiles;
-- THỰC HÀNH: Hiển thị bảng kq không trùng lặp của ORDER_ID, ORDER_DATE, CUSTOMER_NAME từ bảng ORDERS:
SELECT DISTINCT ORDER_ID, ORDER_DATE, CUSTOMER_NAME 
FROM ORDERS;
-- Nhưng đơn hàng 32 vẫn có 3 dòng vì nó vẫn có sự khác biệt ở đâu đấy, check:
SELECT * FROM ORDERS;
-- Ta thấy cùng 1 khách hàng mua cùng 1 lúc nhưng các sản phẩm khác nhau, tiền khác nhau, ...

-- Trả về kết quả theo MỘT điều kiện xác định trong một cột 
-- => Sử dụng dấu "=" cho mệnh đề WHERE
SELECT column_name(s)
FROM table_name
WHERE column_name = value1;
-- HOẶC:
SELECT column_name(s)
FROM table_name
WHERE column_name IN (value1, value2, ...);
-- cụ thể:
SELECT COL1, COL2, COL3 
FROM TABLE_NAME
WHERE COL1 = 'A';
-- CHÚ Ý: KHÔNG CẦN SỬ DỤNG ' ' TRONG TRƯỜNG HỢP COL1 KIỂU SỐ, CẦN KHI LÀ CHỮ/ CHUỖI
-- THỰC HÀNH: Viết câu truy vấn trả về các bản ghi từ bảng Orders với điều kiện cột order_priority='Medium'
-- CÚ PHÁP:
SELECT * FROM Orders 
WHERE order_priority='Medium';
-- THỰC HÀNH: VIẾT CÂU TRUY VẤN TRẢ VỀ BẢNG KẾT QUẢ GỒM TẤT CẢ CÁC CỘT CỦA BẢNG ORDERS CÓ ORDER_PRIORITY LÀ LOW
SELECT * FROM Orders 
WHERE order_priority='LOW';

-- Trả về kết quả theo NHIỀU điều kiện xác định trong một cột 
-- => Sử dụng "in()" cho mệnh đề WHERE
-- THỰC HÀNH: Viết câu truy vấn trả về các bản ghi từ bảng Orders với điều kiện cột order_priority có các giá trị là:
-- 'Medium', 'Low', 'High'
-- CÚ PHÁP:
SELECT * FROM Orders 
WHERE order_priority in ('Medium', 'Low','High');
-- HOẶC:
SELECT
	 ORDER_ID,
	 ORDER_PRIORITY,
	 VALUE,
	 CUSTOMER_NAME
FROM Orders
WHERE order_priority = 'Low' 
	OR order_priority = 'High'
	OR order_priority = 'Medium';

-- Trả về giá trị khác MỘT giá trị xác định trong 1 cột
-- THỰC HÀNH: Viết câu truy vấn trả về bảng kết quả gồm các cột: ORDER_ID, ORDER_DATE, VALUE, PROFIT CỦA BẢNG ORDERS, điều kiện là SHIPPING_MODE KHÁC 'Delivery Truck'
-- CÚ PHÁP:
SELECT order_id, order_date, value, profit
FROM Orders 
WHERE shipping_mode <> 'Delivery Truck';

-- Trả về kết quả không thuộc một/ nhiều điều kiện:
-- THỰC HÀNH: VIẾT CÂU TRUY VẤN TRẢ VỀ BẢNG KQ GỒM CÁC CỘT: ORDER_ID, ORDER_DATE, VALUE, ORDER_PRIORITY CỦA BẢNG ORDERS
-- điều kiện là ORDER_PRIORITY KHÔNG THUỘC LOW, HIGH 'Delivery Truck'
SELECT 
     ORDER_ID,
	 ORDER_PRIORITY,
	 VALUE,
	 CUSTOMER_NAME
FROM Orders 
WHERE order_priority NOT in ('Low','High');
-- HOẶC:
SELECT
	 ORDER_ID,
	 ORDER_PRIORITY,
	 VALUE,
	 CUSTOMER_NAME
FROM Orders
WHERE order_priority <> 'Low' 
	OR order_priority = 'High';

-- Trả về kết quả theo điều kiện chưa xác định (điều kiện là chứa kí tự nào đó, bắt đầu với kí tự, ...) trong một cột
-- => Sử dụng "like" trong mệnh đề WHERE
-- CÚ PHÁP:
SELECT column_name(s)
FROM table_name
WHERE column_name (not) like parttern;
-- Trong đó: 'a%' => Bắt đầu với ký tự a | '%a' => Kết thúc với ký tự a |'%a%' => Chứa ký tự a
-- THỰC HÀNH: Từ bảng Orders trả về 100 dòng kết quả đầu tiên với điều kiện cột shipping_mode chứa ký tự 'Air'
-- CÚ PHÁP cụ thể:
-- Chứa A là được:
SELECT TOP 100 * FROM Orders
WHERE shipping_mode like '%A%';
-- Bắt đầu với ký tự A:
SELECT TOP 100 * FROM Orders
WHERE shipping_mode like 'A%';
-- Kết thúc với ký tự A:
SELECT TOP 100 * FROM Orders
WHERE shipping_mode like '%A';
-- THỰC HÀNH: Từ bảng Orders trả về các kết quả với điều kiện cột product_subcategory bắt đầu với ký tự "Co"
-- CÚ PHÁP:SELECT * FROM Orders WHERE product_subcategory like 'Co%';-- THỰC HÀNH: Lấy danh sách các đơn hàng trong bảng orders điều kiện product_name bắt đầu với ký tự E:SELECT * FROM Orders
WHERE product_name like 'E%';
-- Lọc các kết quả theo điều kiện null
-- CÚ PHÁP:
SELECT COL1, COL2, COL3 
FROM TABLE_NAME
WHERE COL1 IS (NOT) NULL;
-- HAY:
SELECT column_name(s)
FROM table_name
WHERE column_name is (not) null;
-- THỰC HÀNH: Từ bảng Returns, trả về các kết quả điều kiện cột status null (trống)
-- CÚ PHÁP:
SELECT * FROM Returns
WHERE status is null;
-- THỰC HÀNH: Từ bảng Returns, trả về các kết quả điều kiện cột status không null (trống)
-- CÚ PHÁP:
SELECT * FROM Returns
WHERE status is not null;
-- THỰC HÀNH: Province trống
SELECT * FROM Orders
WHERE Province is null;
 
-- Lọc kết quả trong một khoảng nào đó (CHỈ CÓ DỮ LIỆU KIỂU SỐ)
-- CÚ PHÁP:
SELECT COL1, COL2, COL3 
WHERE column_name BETWEEN value1 AND value2;
-- HAY:
FROM TABLE_NAME
SELECT column_name(s)
FROM table_name
WHERE column_name BETWEEN value1 AND value2;
-- THỰC HÀNH: Từ bảng Orders, trả về các kết quả điều kiện cột profit nằm trong khoảng (100,1000)
-- CÚ PHÁP:
SELECT * FROM Orders
WHERE profit between 100 and 1000;
-- THỰC HÀNH: LẤY ĐƠN HÀNG CÓ VALUE NẰM TRONG KHOẢNG 100-1000
SELECT * FROM Orders
WHERE VALUE between 100 and 1000;

-- Kết hợp nhiều điều kiện toán tử AND, OR:
-- THỰC HÀNH: LẤY DS CÁC ĐƠN HÀNG THỎA MÃN: ORDER_PRIORITY LÀ LOW, VALUE >100 VÀ CUSTORMER_NAME CHỨA KÍ TỰ A
-- CÚ PHÁP:
SELECT * FROM Orders
WHERE 
ORDER_PRIORITY = 'LOW'
AND VALUE > 100
AND CUSTOMER_NAME LIKE '%A%';

-- SỬ DỤNG HÀM MIN() VÀ MAX():
-- CÚ PHÁP:
SELECT MIN(column_name)
FROM table_name
WHERE condition;-- HOẶC: SELECT MAX(column_name)
FROM table_name
WHERE condition;
-- THỰC HÀNH: Lấy giá trị nhỏ nhất của cột profit từ bảng Orders
-- CÚ PHÁP:
SELECT MIN(profit)
FROM Orders;
-- THỰC HÀNH: Lấy giá trị lớn nhất của cột Order_quantity từ bảng Orders
-- CÚ PHÁP: 
SELECT MAX(Order_quantity)
FROM Orders;-- SỬ DỤNG HÀM COUNT, AVG , SUM:-- CÚ PHÁP:SELECT COUNT ( [DISTINCT] column_name)
FROM table_name
WHERE condition;-- HOẶC: SELECT AVG(column_name)
FROM table_name
WHERE condition;-- TH: TÍNH GIÁ TRỊ TB CỦA PROFIT CỦA TẤT CẢ CÁC ĐƠN HÀNG TRONG BẢNG ORDERSSELECT AVG(PROFIT) AS 'AVG_PROFIT'
FROM ORDERS;-- HOẶC:SELECT SUM(column_name)
FROM table_name
WHERE condition;-- THỰC HÀNH: Đếm số dòng cột order_priority từ bảng Orders
SELECT COUNT(Order_priority)
FROM Orders;
-- THỰC HÀNH: Tính giá trị trung bình profit từ bảng Orders
SELECT AVG(Profit)
FROM Orders;
-- THỰC HÀNH: Tính tổng profit từ bảng Orders
| SELECT SUM(Profit)
FROM Orders;-- TẠO BẢNG TỔNG HỢP VỚI GROUP BY:-- NHÓM KẾT QUẢ THEO MỘT HOẶC NHIỀU CỘT SỬ DỤNG GROUP BY: 
-- CÚ PHÁP: 
SELECT column_1, function_name(column_2) --bao gồm cột tạo mới bằng hàm tổng hợp
FROM table_name
GROUP BY column_name --nhóm các hàng đề áp dụng hàm tổng hợp
ORDER BY column_name; --sắp xếp tăng/giảm nếu có
-- CHÚ Ý: TẤT CẢ CÁC COL MÀ KHÔNG DÙNG HÀM TỔNG HỢP THÌ ĐƯA XUỐNG SAU GROUP BY
-- Câu lệnh GROUP BY nhóm các hàng có cùng giá trị thành các hàng tóm tắt, như "tìm số lượng khách hàng ở mỗi quốc gia"
-- Câu lệnh GROUP BY thường được sử dụng với các hàm tổng hợp (COUNT (), MAX (), MIN (), SUM (), AVG ()) để nhómtập hợp kết quả theo một hoặc nhiều cột.
-- THỰC HÀNH: Trả về bảng tính tổng lợi nhuận (profit) theo các tỉnh (Province)
SELECT Province AS Tinh, SUM(Profit) as Tong_loi_nhuan
FROM Orders
GROUP BY Provine
-- Theo 1 tiêu chí:
-- THỰC HÀNH: Tính tổng lợi nhuận theo từng mức độ ưu tiên (order_priority)
SELECT order_priority AS Muc_do_uu_tien, SUM(profit) as Tong_loi_nhuan
FROM Orders
GROUP BY order_priority;
-- hoặc:
SELECT order_priority, SUM(profit) AS sum_profit
FROM Orders
GROUP BY order_priority;
-- Theo nhiều tiêu chí:
-- THỰC HÀNH: Tính tổng lợi nhuận theo từng mức độ ưu tiên (order_priority) và tỉnh
SELECT order_priority AS Muc_do_uu_tien, province AS Tinh, SUM(profit) as Tong_loi_nhuan
FROM Orders
GROUP BY order_priority, province;
-- hoặc:
SELECT order_priority, province, SUM(profit) AS sum_profit
FROM Orders
GROUP BY order_priority, province;
 
-- SẮP XẾP KẾT QUẢ TĂNG DẦN/GIẢM DẦN SỬ DỤNG ORDER BY:
-- CÚ PHÁP:
SELECT column_name(s) --Các cột muốn hiển thị
FROM table_name
GROUP BY column_name(s) --Nhóm các hàng để áp dụng hàm tổng hợp (nếu có)
ORDER BY column_name(s) ASC/DESC; --Sắp xếp theo tứ thự tăng/giảm tùy chọn
-- ASC: Tăng dần, DESC: Giảm dần
-- THỰC HÀNH: Trả về bảng tính tổng lợi nhuận (profit) theo các tỉnh (Province) và sắp xếp theo thứ tự giảm dần
SELECT Province AS Tinh, SUM(Profit) as Tong_loi_nhuan
FROM Orders
GROUP BY Provine
ORDER BY SUM(Profit) DESC;
-- THỰC HÀNH: Tính tổng lợi nhuận theo từng mức độ ưu tiên (order_priority) và tỉnh
-- ĐIỀU KIỆN TRẢ VỀ TĂNG DẦN:
SELECT order_priority AS Muc_do_uu_tien, province AS Tinh, SUM(profit) as Tong_loi_nhuan
FROM Orders
GROUP BY order_priority, province
ORDER BY Tong_loi_nhuan ASC;
-- THỰC HÀNH: Tính tổng lợi nhuận theo từng mức độ ưu tiên (order_priority) và tỉnh
-- ĐIỀU KIỆN TRẢ VỀ lần lượt theo tỉnh giảm dần:
SELECT order_priority AS Muc_do_uu_tien, province AS Tinh, SUM(profit) as Tong_loi_nhuan
FROM Orders
GROUP BY order_priority, province
ORDER BY province DESC;
-- THỰC HÀNH: Sắp xếp các đơn hàng có profit giảm dần
SELECT * FROM Orders
ORDER BY PROFIT DESC;

-- LỌC KẾT QUẢ VỚI HAVING:
SELECT <column_1, function_name(column_2),…> --Trong select chứa hàm tổng hợp
FROM <table>
WHERE <condition>                            -- Điều kiện áp dụng với cột có sẵn
GROUP BY <column(s)>                         -- Nhóm các hàng để áp dụng hàm tổng hợp
HAVING <condition>                           -- Hàm tổng hợp trong điều kiện
ORDER BY <column(s)>;                        -- Xác định thứ tự tăng giảm (Tùy chọn)
-- HAY:SELECT column_name(s), function_name(column_2)
FROM table_name
WHERE condition
GROUP BY column_name(s)
HAVING condition
-- THỰC HÀNH: Trả về bảng tính tổng lợi nhuận (profit) theo các tỉnh (Province). Điều kiện là lấy các tỉnh có tổng lợi nhuận lớn hơn 10000
SELECT Province AS Tinh, SUM(Profit) as Tong_loi_nhuan
FROM Orders
GROUP BY Provine
HAVING SUM(profit) > 10000;
-- THỰC HÀNH: Lấy danh sách các SP: Product_name có sum_profit > 15000, 
-- và sắp xếp theo thứ tự tổng lợi nhuận giảm dần
SELECT product_name, sum(profit) as 'sum_profit'
FROM ORDERS
GROUP BY Product_name
HAVING sum(profit) > 15000
ORDER BY sum(profit) DESC;
-- THỰC HÀNH: Lấy top 10 danh sách các SP có tổng LN lớn nhất
SELECT TOP 10 product_name, sum(profit) as 'sum_profit'
FROM ORDERS
GROUP BY Product_name
ORDER BY sum(profit) DESC;

-- BTVN: BÀI 2 (BUỔI 2) - MỖI Ý VIẾT MỘT CÂU TRUY VẤN & BÀI 3 
-- HỌC VIÊN: NGUYỄN THỊ HIỀN
-------------------------------------------- BÀI LÀM --------------------------------------------

-- Bài 2: Từ bảng Orders. Viết các câu lệnh theo các điều kiện sau:
-- Ý 2.1 region là “West”:
SELECT * 
FROM  ORDERS
WHERE REGION = 'WEST';

-- Ý 2.2 order_priority không bao gồm “Critical”
SELECT * 
FROM  ORDERS
WHERE ORDER_PRIORITY <> 'CRITICAL';

-- Ý 2.3 order_priority là “High” hoặc order_priority là “Low” hoặc order_priority là “Medium” hoặc order_priority là “Not Specified”
-- ĐẦU TIÊN KIỂM TRA:
SELECT DISTINCT ORDER_PRIORITY
FROM ORDERS;
-- => THẤY CÓ CRITICAL, HIGH, LOW, MEDIUM &  NOT SPECIFIED
SELECT * 
FROM  ORDERS
WHERE ORDER_PRIORITY <> 'CRITICAL';
-- HOẶC LÀ:
SELECT * 
FROM ORDERS
WHERE 
     ORDER_PRIORITY = 'HIGH'
  OR ORDER_PRIORITY = 'LOW'
  OR ORDER_PRIORITY = 'MEDIUM'
  OR ORDER_PRIORITY = 'NOT SPECIFIED';

-- Ý 2.4 province chứa từ “New”
SELECT *
FROM  ORDERS
WHERE PROVINCE LIKE '%NEW%';

-- Ý 2.5 shipping_mode không chứa từ “Air” và value nhỏ hơn 500
SELECT *
FROM ORDERS
WHERE 
     SHIPPING_MODE NOT LIKE '%AIR%'
 AND VALUE < 500;

-- Ý 2.6 product_subcategory bắt đầu với từ “Co”
SELECT *
FROM  ORDERS
WHERE PRODUCT_SUBCATEGORY LIKE 'CO%';

-- Ý 2.7 customer_segment kết thúc là “e” và order_quantity lớn hơn 10
SELECT *
FROM  ORDERS
WHERE CUSTOMER_SEGMENT LIKE '%E'
  AND ORDER_QUANTITY > 10;

-- Bài 3: Từ bảng Orders: Viết lệnh trả về kết quả danh sách 10 khách hàng của tỉnh "Nunavut" đem lại tổng lợi nhuận cao nhất. Kết quả trả về như bảng bên
SELECT TOP 10 PROVINCE, CUSTOMER_NAME, sum(PROFIT) as 'SUM_PROFIT'

-- CÓ CỘT PROVINCE:
FROM ORDERS
WHERE PROVINCE = 'NUNAVUT'
GROUP BY CUSTOMER_NAME, PROVINCE
ORDER BY sum(PROFIT) DESC;

-- HOẶC LÀ KHÔNG CÓ CỘT PROVINCE:
SELECT TOP 10 CUSTOMER_NAME, sum(PROFIT) as 'SUM_PROFIT'
FROM ORDERS
WHERE PROVINCE = 'NUNAVUT'
GROUP BY CUSTOMER_NAME
ORDER BY sum(PROFIT) DESC;

-- Thank you for your reviewing!
