-- BUỔI 4: CÁC HÀM XỬ LÝ DỮ LIỆU
-- CÁC HÀM XỬ LÍ CHUỖI
-- 1. CHARINDEX() : Trả về vị trí của một chuỗi con trong một chuỗi 
-- CẤU TRÚC: CHARINDEX(substring, string, start)
-- VÍ DỤ:

SELECT ORDER_ID, ORDER_PRIORITY, CHARINDEX('O', order_priority, 1) AS VITRI_O
FROM Orders;

SELECT CHARINDEX('C', 'MAGIC CODE INSTITUTE') 
AS char_index; -- TRẢ VỀ VỊ TRÍ LÀ 5 (VỊ TRÍ CỦA CHỮ C ĐẦU TIÊN TRONG CHUỖI)

SELECT CHARINDEX('C', 'MAGIC CODE INSTITUTE', 6) 
AS char_index; -- TRẢ VỀ VỊ TRÍ LÀ 7 (VỊ TRÍ CỦA CHỮ C THỨ 2 TRONG CHUỖI)

SELECT CHARINDEX(' C', 'MAGIC CODE INSTITUTE') 
AS char_index; -- TRẢ VỀ VỊ TRÍ LÀ 6 (VỊ TRÍ CỦA DẤU CÁCH, VÌ COI ' C' LÀ 1 CỤM)

SELECT CHARINDEX('O', 'MAGIC CODE INSTITUTE') 
AS char_index; -- TRẢ VỀ VỊ TRÍ LÀ 8

SELECT CHARINDEX('CO', 'MAGIC CODE INSTITUTE') 
AS char_index; -- TRẢ VỀ VỊ TRÍ LÀ 7

SELECT CHARINDEX('COD', 'MAGIC CODE INSTITUTE') 
AS char_index; -- TRẢ VỀ VỊ TRÍ LÀ 7 ('CO' VÀ 'COD' ĐỀU LÀ VỊ TRÍ 7 VÌ CỤM 'CO' VÀ 'COD' COI LÀ 1 CHUỖI)

-- 2. CONCAT() : Nối các chuỗi với nhau 
-- CẤU TRÚC: CONCAT(string1, string2,..)
-- VÍ DỤ: 

SELECT PROVINCE, REGION, CONCAT(PROVINCE,' ', REGION) AS DIACHI 
FROM ORDERS;

SELECT CONCAT('MAGIC','CODE','INSTITUTE')
AS chars_combined; -- KẾT QUẢ LÀ CHUỖI: MAGICCODEINSTITUTE

SELECT CONCAT('MAGIC ','CODE ','INSTITUTE')
AS chars_combined; -- KẾT QUẢ LÀ CHUỖI: 'MAGIC CODE INSTITUTE'

-- 3. CONCAT_WS() : Thêm hai hoặc nhiều chuỗi với một dấu phân cách (CÓ THỂ LÀ 1 KÝ TỰ BẤT KỲ)
-- CẤU TRÚC: CONCAT_WS(separator, string1, string2,..)
-- VÍ DỤ: 
SELECT PROVINCE, REGION, CONCAT_WS('-', PROVINCE, REGION) AS DIACHI 
FROM ORDERS;

SELECT CONCAT_WS(' ', 'MAGIC', 'CODE', 'INSTITUTE'); -- KẾT QUẢ LÀ CHUỖI: 'MAGIC CODE INSTITUTE'
-- Vậy thay vì thêm dấu cách vào từng chuỗi con, thì dùng hàm CONCAT_WS() 

-- 4. LEN() : Đo chiều dài chuỗi 
-- CẤU TRÚC: LEN(string)
-- VÍ DỤ:
SELECT ORDER_ID, ORDER_PRIORITY, LEN(ORDER_PRIORITY) AS LEN_PRIORITY 
FROM ORDERS;

SELECT LEN('MAGIC CODE INSTITUTE') 
AS char_length; -- CHUỖI DÀI 20 KÍ TỰ (TÍNH CẢ DẤU CÁCH)

-- 5. LEFT() : Trích xuất một số ký tự từ một chuỗi (bắt đầu từ trái sang)
-- CẤU TRÚC: LEFT(string, number_of_chars)
-- VÍ DỤ:
SELECT ORDER_ID, ORDER_PRIORITY, LEFT(ORDER_PRIORITY,2) AS CODE_PRIORITY 
FROM ORDERS;

SELECT LEFT('MAGIC CODE INSTITUTE', 5) 
AS extract_string; -- KẾT QUẢ TRẢ VỀ LÀ CHUỖI CON GỒM 5 KÝ TỰ ĐẦU 'MAGIC'

SELECT LEFT('MAGIC CODE INSTITUTE', 10) 
AS extract_string; -- KẾT QUẢ TRẢ VỀ LÀ CHUỖI CON GỒM 10 KÝ TỰ ĐẦU 'MAGIC CODE'

-- 6. RIGHT() : Trích xuất một số ký tự từ một chuỗi (bắt đầu từ phải sang)
-- CẤU TRÚC: RIGHT(string, number_of_chars
-- VÍ DỤ: 
SELECT ORDER_ID, ORDER_PRIORITY, RIGHT(ORDER_PRIORITY,2) AS CODE_PRIORITY FROM ORDERS;

SELECT RIGHT('MAGIC CODE INSTITUTE', 9) 
AS extract_string; -- KẾT QUẢ TRẢ VỀ: 'INSTITUTE'

SELECT RIGHT('MAGIC CODE INSTITUTE', 14) 
AS extract_string; -- KẾT QUẢ TRẢ VỀ: 'CODE INSTITUTE'

-- 7. LTRIM() or RTRIM() : Loại bỏ khoảng trắng đầu chuỗi hoặc cuối chuỗi
-- CẤU TRÚC: LTRIM(string); RTRIM(string)
-- VÍ DỤ:
SELECT RTRIM('LUONG MY LINH    ')); --KẾT QUẢ: 'LUONG MY LINH'
SELECT RTRIM(LTRIM('    LUONG MY LINH    ')); --KẾT QUẢ: 'LUONG MY LINH'

SELECT LTRIM(' MCI') 
AS Left_Trimmed; -- TRẢ VỀ KẾT QUẢ: 'MCI'

SELECT RTRIM('MCI ') 
AS Right_Trimmed; -- TRẢ VỀ KẾT QUẢ: 'MCI'

-- 8. PATINDEX() : Trả về vị trí của một mẫu trong một chuỗi -- ÍT DÙNG
-- CẤU TRÚC: PATINDEX(%pattern%, string)
-- VÍ DỤ:

SELECT ORDER_ID, ORDER_PRIORITY, PATINDEX('%O%',ORDER_PRIORITY) AS VITRI_O FROM ORDERS;

SELECT PATINDEX('%D%', 'MAGIC CODE INSTITUTE'); -- KẾT QUẢ TRẢ VỀ VỊ TRÍ THỨ 9
SELECT PATINDEX('%D', 'MAGIC CODE INSTITUTE'); -- KẾT QUẢ TRẢ VỀ LÀ 0 
SELECT PATINDEX('%E', 'MAGIC CODE INSTITUTE'); -- KẾT QUẢ TRẢ VỀ LÀ 20 
SELECT PATINDEX('D%', 'MAGIC CODE INSTITUTE'); -- KẾT QUẢ TRẢ VỀ LÀ 0
SELECT PATINDEX('C%', 'MAGIC CODE INSTITUTE'); -- KẾT QUẢ TRẢ VỀ LÀ 0 (VÌ DÙ CHỮ CODE CHỮ C ĐỨNG ĐẦU NHƯNG ĐÂY LÀ 1 CHUỖI, DẤU CÁCH CŨNG LÀ 1 KÝ TỰ)
SELECT PATINDEX('M%', 'MAGIC CODE INSTITUTE'); -- KẾT QUẢ TRẢ VỀ LÀ 1
SELECT PATINDEX('%OD%', 'MAGIC CODE INSTITUTE'); -- KẾT QUẢ TRẢ VỀ VỊ TRÍ THỨ 8
SELECT PATINDEX('%C%', 'MAGIC CODE INSTITUTE'); -- KẾT QUẢ TRẢ VỀ VỊ TRÍ THỨ 5

-- 9. REPLACE() : Thay thế tất cả các lần xuất hiện của một chuỗi con trong một chuỗi, với một chuỗi con mới
-- CẤU TRÚC: REPLACE(string, old_string, new_string)
--THỰC HÀNH: HIỂN BẢNG KQ GỒM CÁC CỘT: ORDER_ID, CUSTOMER_NAME, NEW_CUSTOMER_NAME
--TRONG ĐÓ: NEW_CUSTOMER_NAME: THAY THẾ KÝ TỰ 'E' THÀNH 'A'
SELECT 
ORDER_ID, 
CUSTOMER_NAME,
REPLACE(CUSTOMER_NAME, 'e', 'a') AS NEW_CUSTOMER_NAME 
FROM ORDERS;

-- VÍ DỤ:
SELECT REPLACE('MAGIC', 'MA', 'LO'); -- KẾT QUẢ TRẢ VỀ LÀ 'LOGIC'
SELECT REPLACE('MAGIC', 'GIC', 'P'); -- KẾT QUẢ TRẢ VỀ LÀ 'MAP'

-- 10. REPLICATE(): LẶP LẠI CHUỖI X LẦN
-- CẤU TRÚC: REPLICATE(string, times)
-- THỰC HÀNH: LẶP TÊN 03 LẦN ĐỂ TẠO RA TÊN MỚI
SELECT 
ORDER_ID, 
CUSTOMER_NAME, 
REPLICATE(CUSTOMER_NAME,3) AS NEW_CUSTOMER_NAME
FROM ORDERS;

-- 11. REVERSE() : Đảo ngược chuỗi
-- CẤU TRÚC: REVERSE(string) 
-- VÍ DỤ:
SELECT REVERSE('MCI'); -- KẾT QUẢ 'ICM'

SELECT 
ORDER_ID, 
CUSTOMER_NAME, 
REVERSE(CUSTOMER_NAME) AS NEW_CUSTOMER_NAME
FROM ORDERS;

-- 12. SUBSTRING() : Trích xuất một số ký tự từ một chuỗi 
-- CẤU TRÚC: SUBSTRING(string, start, length)
-- VÍ DỤ:
SELECT SUBSTRING('MAGIC CODE INSTITUTE', 1, 5) AS extract_string; --TRÍCH 5 KÝ TỰ BẮT ĐẦU TỪ VỊ TRÍ SỐ 1 TRONG CHUỐI, KẾT QUẢ: 'MAGIC'SELECT CUSTOMER_NAME,SUBSTRING(CUSTOMER_NAME, 2, 2) AS CODE_NAMEFROM ORDERS;SELECT SUBSTRING('MAGIC CODE INSTITUTE', 7, 4) AS extract_string; --TRÍCH 4 KÝ TỰ BẮT ĐẦU TỪ VỊ TRÍ SỐ 7 TRONG CHUỐI, KẾT QUẢ: 'CODE'
-- 13. STUFF() : Xóa một phần của chuỗi rồi chèn một phần khác vào chuỗi, bắt đầu từ một vị trí được chỉ định
-- CẤU TRÚC: STUFF(string, start, length, new_string)
-- VÍ DỤ:
SELECT 
CUSTOMER_NAME,
STUFF(CUSTOMER_NAME,2,2,'AB') AS NEW_CUSTOMERNAME 
FROM ORDERS;

SELECT STUFF('MAGIC CODE INSTITUTE', 1, 2, 'LO'); -- BẮT ĐẦU TỪ VT SỐ 1, XÓA 2 KÝ TỰ, SAU ĐÓ THÊM VÀO TỪ VỊ TRÍ SỐ 1 'LO'
-- KẾT QUẢ TRẢ VỀ: 'LOGIC CODE INSTITUTE'

-- 14. LOWER() : Chuyển đổi chuỗi thành chữ thường
-- CẤU TRÚC: LOWER(string)
-- VÍ DỤ:
SELECT LOWER('MAGIC CODE INSTITUTE '); -- KẾT QUẢ: 'magic code institute 'SELECT LOWER('MAGIC CODE INSTITUTE'); -- KẾT QUẢ: 'magic code institute'
-- 15. UPPER() : Chuyển đổi chuối thành chữ in 
-- CẤU TRÚC: UPPER(string)
-- VÍ DỤ:
SELECT UPPER('mci '); -- KẾT QUẢ: 'MCI 'SELECT UPPER('mci'); -- KẾT QUẢ: 'MCI'

-- 16. STRING_AGG() : Là một hàm tổng hợp nối các hàng chuỗi thành một chuỗi duy nhất, 
-- được phân tách bằng dấu phân tách được chỉ định.
-- CẤU TRÚC: STRING_AGG ( input_string, separator ) 
-- VÍ DỤ: LẤY RA Product_subcategory_list NGĂN CÁCH NHAU BỞI DẤU ; CỦA TỪNG Product_category
SELECT 
Product_category, 
STRING_AGG(Product_subcategory,';') AS Product_subcategory_list 
FROM Orders
WHERE  PROFIT > 0
AND    PROFIT < 5
GROUP BY Product_category;

-- CÁC HÀM XỬ LÍ THỜI GIAN
-- 1. CURRENT_TIMESTAMP() : Trả về thời gian hiện tại
-- CẤU TRÚC: SELECT CURRENT_TIMESTAMP
-- TƯƠNG ĐƯƠNG HÀM NOW TRÊN EXCEL: DÙNG ĐỂ XEM ĐƠN HÀNG NÀO TRỄ DEADLINE RỒI
-- VÍ DỤ: 
SELECT CURRENT_TIMESTAMP; -- KẾT QUẢ TRẢ VỀ: 2022-07-21 19:31:59.913

-- 2. DATEADD() : Cộng thêm một khoảng thời gian
-- CẤU TRÚC: DATEADD(interval, number, date)
-- VÍ DỤ:
SELECT 
ORDER_ID,
ORDER_DATE,
SHIPPING_DATE,
DATEADD(MONTH, 1, ORDER_DATE) AS DEADLINE 
FROM ORDERS;

SELECT DATEADD(YEAR, 1, '2020-03-10')
AS date_add; -- KẾT QUẢ TRẢ VỀ: 2021-03-10 00:00:00.000 -> CỘNG THÊM 1 NĂM

SELECT DATEADD(MONTH, 11, '2020-03-10') 
AS date_add; -- KẾT QUẢ TRẢ VỀ: 2021-02-10 00:00:00.000 -> CỘNG THÊM 11 THÁNG

SELECT DATEADD(DAY, 21, '2020-03-10') 
AS date_add; -- KẾT QUẢ TRẢ VỀ: 2020-03-31 00:00:00.000 -> CỘNG THÊM 21 NGÀY

-- 3. DATEDIFF() : Trả về khoảng cách giữa 2 ngày
-- CẤU TRÚC: DATEDIFF(interval, date1, date2)
-- VÍ DỤ:
SELECT 
ORDER_ID, 
DATEDIFF(HOUR, ORDER_DATE, SHIPPING_DATE) AS DELIVER_TIME
FROM ORDERS;

SELECT DATEDIFF(YEAR, '2021-03-10', '2020-03-10'); -- KẾT QUẢ TRẢ VỀ -1 (TỨC LÀ KHOẢNG CÁCH LÀ 1 NĂM)
SELECT DATEDIFF(DAY, '2021-03-10', '2022-04-09'); -- KẾT QUẢ TRẢ VỀ 395 (TỨC LÀ KHOẢNG CÁCH LÀ 395 NGÀY)
SELECT DATEDIFF(MONTH, '2021-03-10', '2022-04-22'); -- KẾT QUẢ TRẢ VỀ 13 
-- TỨC LÀ KHOẢNG CÁCH LÀ 13 THÁNG NHƯNG THỰC TẾ LÀ HƠN 13 THÁNG - LÀ 408 NGÀY
SELECT DATEDIFF(MONTH, '2021-03-10', '2022-03-14'); -- KẾT QUẢ TRẢ VỀ 13 (TỨC LÀ KHOẢNG CÁCH LÀ 13 THÁNG)
-- TỨC LÀ KHOẢNG CÁCH LÀ 13 THÁNG NHƯNG THỰC TẾ LÀ CHƯA TỚI 13 THÁNG - LÀ 369 NGÀY
SELECT DATEDIFF(MONTH, '2021-03-10', '2022-04-09'); -- KẾT QUẢ TRẢ VỀ 13 (TỨC LÀ KHOẢNG CÁCH LÀ 13 THÁNG)

-- 4. DATEFROMPARTS() : Trả về một ngày từ các phần được chỉ định (năm, tháng, ngày)
-- CẤU TRÚC: DATEFROMPARTS(year, month, day)
-- VÍ DỤ:

SELECT DATEFROMPARTS(2021, 10, 07 )
AS date_from_parts; -- KẾT QUẢ TRẢ VỀ: 2021-10-07

-- 5. DATEPART() : Trả về một phần đã xác định của một ngày (dưới dạng số nguyên)
-- CẤU TRÚC: DATEPART(interval, date)
-- VÍ DỤ:
SELECT 
DATEPART(YEAR,ORDER_DATE) AS YEAR, 
SUM(PROFIT) AS TOTAL_PROFIT
FROM ORDERS
GROUP BY DATEPART(YEAR,ORDER_DATE);

SELECT DATEPART(year, '2021/12/01') 
AS date_part_in; -- KẾT QUẢ TRẢ VỀ NĂM 2021

SELECT DATEPART(MONTH, '2021/12/01') 
AS date_part_in; -- KẾT QUẢ TRẢ VỀ THÁNG 12

SELECT DATEPART(DAY, '2021/12/01') 
AS date_part_in; -- KẾT QUẢ TRẢ VỀ NGÀY 1

-- 6. DAY() : Trả về ngày trong ngày đã cho
-- CẤU TRÚC: DAY(date)
-- BẰNG VỚI CẤU TRÚC: SELECT DATEPART(DAY, 'NĂM/THÁNG/NGÀY')
-- VÍ DỤ: 
SELECT DAY('2021/05/23') 
AS get_day; -- KẾT QUẢ TRẢ VỀ NGÀY 23

-- 7. MONTH() : Trả về tháng trong ngày đã cho
-- CẤU TRÚC: MONTH(date) 
-- BẰNG VỚI CẤU TRÚC: SELECT DATEPART(MONTH, 'NĂM/THÁNG/NGÀY')
-- VÍ DỤ:
SELECT MONTH('2021/05/23') 
AS get_month; -- KẾT QUẢ TRẢ VỀ THÁNG 5

-- 8. YEAR()  : Trả về năm trong ngày đã cho
-- CẤU TRÚC: YEAR(date) 
-- BẰNG VỚI CẤU TRÚC: SELECT DATEPART(YEAR, 'NĂM/THÁNG/NGÀY')
-- VÍ DỤ:
SELECT YEAR('2021/05/23') 
AS year; -- KẾT QUẢ TRẢ VỀ NĂM 2021

-- CÁC HÀM CHUYỂN ĐỔI:
-- 1. CAST() : Chuyển đổi một giá trị (thuộc bất kỳ loại nào) 
-- thành một kiểu dữ liệu được chỉ định
-- CẤU TRÚC: CAST(expression AS data_type[length])
-- VÍ DỤ: 
SELECT CAST('2021' AS INT) 
AS new_datatype; --KẾT QUẢ TRẢ VỀ SỐ NGUYÊN 2021

SELECT CAST('2021' AS VARCHAR) 
AS new_datatype; --KẾT QUẢ TRẢ VỀ KÝ TỰ 2021

-- 2. CONVERT() : Chuyển đổi một giá trị (thuộc bất kỳ loại nào) thành một kiểu dữ liệu được chỉ định
-- CẤU TRÚC: CONVERT(data_type[length], expression)
-- VÍ DỤ: 
SELECT CONVERT(int, '2021') 
AS new_datatype; --KẾT QUẢ TRẢ VỀ SỐ NGUYÊN 2021

-- 3. STR() : Trả về dạng chuỗi
-- CẤU TRÚC: STR()
-- VÍ DỤ: 
SELECT STR(2021); -- KẾT QUẢ LÀ CHUỖI '2021'
-- 4. ISNUMERIC() : Kiểm tra có dạng số hay không
-- CẤU TRÚC: ISNUMERIC()
-- VÍ DỤ: 
SELECT ISNUMERIC(2021); --KẾT QUẢ TRẢ VỀ LÀ 1: TỨC LÀ CÓ LÀ DẠNG SỐSELECT ISNUMERIC('HELLO'); --KẾT QUẢ TRẢ VỀ LÀ 0: TỨC LÀ KHÔNG LÀ DẠNG SỐ
-- 5. ISNULL() : Trả về giá trị đã chỉ định nếu biểu thức là NULL, nếu không trả về biểu thức
-- CẤU TRÚC: ISNULL()
-- VÍ DỤ: 
SELECT ISNULL(NULL, 'MCI');

-- MỆNH ĐỀ CASE WHEN: TƯƠNG TỰ IF CỦA EXCEL
-- Hàm CASE đi qua các điều kiện đến khi một điều kiện Đúng, hàm này sẽ dừng và trả về kết quả
-- Nếu không có điều kiện nào đúng, hàm này trả về giá trị trong mệnh đề ELSE
-- Nếu không có ELSE và không có điều kiện nào đánh giá là đúng, hàm trả về NULL
-- CÚ PHÁP:
CASE WHEN (điều kiện 1) THEN value_1
WHEN (điều kiện 2) THEN value_2
... ...
WHEN (điều kiện N) THEN value_N
ELSE value_0
END AS NEW_COL

--VD: 
SELECT 
ORDER_ID, 
VALUE, 
CASE WHEN VALUE < 100 THEN 'THAP'
WHEN VALUE < 200 THEN 'TB'
ELSE 'CAO' END AS MUC_DO_VALUE
FROM ORDERS;

-- THỰC HÀNH:
SELECT 
product_category, 
product_subcategory,
CASE WHEN shipping_mode like '%Air%' then 'Air' 
ELSE 'Other' END AS shipping_method
FROM Orders;

-- THỰC HÀNH: Từ bảng Orders: Nếu discount = 0 trả về 'No Discount' nếu không thì trả về 'Discount'
SELECT 
ORDER_ID,
DISCOUNT,
CASE WHEN DISCOUNT = 0 THEN 'No Discount'
ELSE 'Discount' END AS CO_DISCOUNT_KHONG
FROM ORDERS;

-- THỰC HÀNH: Từ bảng Orders sử dụng mệnh đề Case When theo điều kiện sau:
--- Value lớn hơn 1000 trả về High
--- Value từ 200 đến 1000 trả về Medium
--- Value nhỏ hơn 200 trả về Low. Cột mới tạo ra được đặt tên là Range_Value
------ TH1:
SELECT 
ORDER_ID,
VALUE,
CASE WHEN VALUE > 1000 THEN 'HIGH'
     WHEN VALUE >200 THEN 'MEDIUM'
ELSE 'LOW' END AS 'RANGE_VALUE'
FROM ORDERS;
------ TH2:
SELECT 
ORDER_ID,
VALUE,
CASE WHEN VALUE < 200 THEN 'LOW'
     WHEN VALUE > 1000 THEN 'HIGH'
ELSE 'MEDIUM' END AS 'RANGE_VALUE'
FROM ORDERS;

-- BÀI TẬP VỀ NHÀ (BUỔI 04) 
-- HỌC VIÊN: NGUYỄN THỊ HIỀN
-------------------------------------------- BÀI LÀM --------------------------------------------

-- BT1. Tạo ra một bảng bao gồm các cột:
-- order_id, customer_name, product_category, product_subcategory, product_name, thickness
-- Thỏa mãn các điều kiện sau:
---- Product_subcategory = 'Pens & Art Supplies'
---- Product_name chứa từ 'Newell'
-- Giả sử rằng nếu product_name là "Newell 345", nó có nghĩa là độ dày của nó là 345 mm
----- CÁCH 1.1 & 1.2: (các cách sau đều là sử dụng CONCAT_WS thay cho CONCAT)
SELECT 
ORDER_ID,
CUSTOMER_NAME,
PRODUCT_CATEGORY,
PRODUCT_SUBCATEGORY,
PRODUCT_NAME,
CONCAT(SUBSTRING(PRODUCT_NAME, LEN('Newell')+2, LEN(PRODUCT_NAME)-LEN('Newell')-1), ' ','mm') AS THICKNESS
FROM ORDERS
WHERE PRODUCT_SUBCATEGORY = 'Pens & Art Supplies'
  AND PRODUCT_NAME LIKE '%Newell%';

SELECT 
ORDER_ID,
CUSTOMER_NAME,
PRODUCT_CATEGORY,
PRODUCT_SUBCATEGORY,
PRODUCT_NAME,
CONCAT_WS(' ',SUBSTRING(PRODUCT_NAME, LEN('Newell')+2, LEN(PRODUCT_NAME)-LEN('Newell')-1),'mm') AS THICKNESS
FROM ORDERS
WHERE PRODUCT_SUBCATEGORY = 'Pens & Art Supplies'
  AND PRODUCT_NAME LIKE '%Newell%';

----- CÁCH 2.1 & 2.2:
SELECT 
ORDER_ID,
CUSTOMER_NAME,
PRODUCT_CATEGORY,
PRODUCT_SUBCATEGORY,
PRODUCT_NAME,
CONCAT(RIGHT(PRODUCT_NAME, LEN(PRODUCT_NAME)-LEN('Newell')-1), ' ', 'mm') AS THICKNESS
FROM ORDERS
WHERE PRODUCT_SUBCATEGORY = 'Pens & Art Supplies'
  AND PRODUCT_NAME LIKE '%Newell%';

SELECT 
ORDER_ID,
CUSTOMER_NAME,
PRODUCT_CATEGORY,
PRODUCT_SUBCATEGORY,
PRODUCT_NAME,
CONCAT_WS(' ',RIGHT(PRODUCT_NAME, LEN(PRODUCT_NAME)-LEN('Newell')-1), 'mm') AS THICKNESS
FROM ORDERS
WHERE PRODUCT_SUBCATEGORY = 'Pens & Art Supplies'
  AND PRODUCT_NAME LIKE '%Newell%';

----- CÁCH 3.1 & 3.2:
SELECT 
ORDER_ID,
CUSTOMER_NAME,
PRODUCT_CATEGORY,
PRODUCT_SUBCATEGORY,
PRODUCT_NAME,
CONCAT(REPLACE(PRODUCT_NAME, 'Newell ',''), ' ', 'mm') AS THICKNESS
FROM ORDERS
WHERE PRODUCT_SUBCATEGORY = 'Pens & Art Supplies'
  AND PRODUCT_NAME LIKE '%Newell%';

SELECT 
ORDER_ID,
CUSTOMER_NAME,
PRODUCT_CATEGORY,
PRODUCT_SUBCATEGORY,
PRODUCT_NAME,
CONCAT_WS(' ', REPLACE(PRODUCT_NAME, 'Newell ',''), 'mm') AS THICKNESS
FROM ORDERS
WHERE PRODUCT_SUBCATEGORY = 'Pens & Art Supplies'
  AND PRODUCT_NAME LIKE '%Newell%';

----- CÁCH 4.1 & 4.2:
SELECT 
ORDER_ID,
CUSTOMER_NAME,
PRODUCT_CATEGORY,
PRODUCT_SUBCATEGORY,
PRODUCT_NAME,
CONCAT(STUFF(PRODUCT_NAME, 1, LEN('Newell')+1, ''), ' ', 'mm') AS THICKNESS
FROM ORDERS
WHERE PRODUCT_SUBCATEGORY = 'Pens & Art Supplies'
  AND PRODUCT_NAME LIKE '%Newell%';

SELECT 
ORDER_ID,
CUSTOMER_NAME,
PRODUCT_CATEGORY,
PRODUCT_SUBCATEGORY,
PRODUCT_NAME,
CONCAT_WS(' ', STUFF(PRODUCT_NAME, 1, LEN('Newell')+1, ''), 'mm') AS THICKNESS
FROM ORDERS
WHERE PRODUCT_SUBCATEGORY = 'Pens & Art Supplies'
  AND PRODUCT_NAME LIKE '%Newell%';

----- CÁCH 5.1 & 5.2:
SELECT 
ORDER_ID,
CUSTOMER_NAME,
PRODUCT_CATEGORY,
PRODUCT_SUBCATEGORY,
PRODUCT_NAME,
LTRIM(CONCAT(STUFF(PRODUCT_NAME, 1, LEN('Newell'), ''), ' ', 'mm')) AS THICKNESS
FROM ORDERS
WHERE PRODUCT_SUBCATEGORY = 'Pens & Art Supplies'
  AND PRODUCT_NAME LIKE '%Newell%';

SELECT 
ORDER_ID,
CUSTOMER_NAME,
PRODUCT_CATEGORY,
PRODUCT_SUBCATEGORY,
PRODUCT_NAME,
LTRIM(CONCAT_WS(' ', STUFF(PRODUCT_NAME, 1, LEN('Newell'), ''), 'mm')) AS THICKNESS
FROM ORDERS
WHERE PRODUCT_SUBCATEGORY = 'Pens & Art Supplies'
  AND PRODUCT_NAME LIKE '%Newell%';

-- BT2. Tạo ra một bảng bao gồm các cột: 
-- Year, count_orders, total_value, total_profit, total_quantity và sắp xếp theo thứ tự các năm giảm dần.

---- CÁCH 1:
SELECT
DATEPART(YEAR, ORDER_DATE) AS YEAR,
COUNT(DISTINCT(ORDER_ID)) AS COUNT_ORDERS,
SUM(VALUE) AS TOTAL_VALUE,
SUM(PROFIT) AS TOTAL_PROFIT,
SUM(ORDER_QUANTITY) AS TOTAL_QUANTITY
FROM ORDERS
GROUP BY DATEPART(YEAR, ORDER_DATE)
ORDER BY DATEPART(YEAR, ORDER_DATE) DESC;

---- CÁCH 2:
SELECT
YEAR(ORDER_DATE) AS YEAR,
COUNT(DISTINCT(ORDER_ID)) AS COUNT_ORDERS,
SUM(VALUE) AS TOTAL_VALUE,
SUM(PROFIT) AS TOTAL_PROFIT,
SUM(ORDER_QUANTITY) AS TOTAL_QUANTITY
FROM ORDERS
GROUP BY DATEPART(YEAR, ORDER_DATE)
ORDER BY DATEPART(YEAR, ORDER_DATE) DESC;

-- BT3: Từ bảng Managers tạo ra một bảng gồm các cột: 
-- manager_name, manager_level, manager_phone, level
---- Cột level được tạo ra thỏa mãn điều kiện sau:
-- Nếu manager_level =1 trả về là 'Fresher'
-- Nếu manager_level = 2 và 3 trả về là 'Junior'
-- Nếu manager_level = 4 trả về là 'Senior'

-- CÁCH 1:
SELECT
MANAGER_NAME,
MANAGER_LEVEL,
MANAGER_PHONE,
CASE WHEN MANAGER_LEVEL = 1 THEN 'FRESHER'
     WHEN MANAGER_LEVEL = 4 THEN 'SENIOR'
ELSE 'JUNIOR' END AS LEVEL
FROM MANAGERS;

-- CÁCH 2:
SELECT
MANAGER_NAME,
MANAGER_LEVEL,
MANAGER_PHONE,
CASE WHEN MANAGER_LEVEL = 1 THEN 'FRESHER'
     WHEN MANAGER_LEVEL = 2 OR MANAGER_LEVEL = 3 THEN 'JUNIOR'
ELSE 'SENIOR' END AS LEVEL
FROM MANAGERS;

-- CÁCH 3:
SELECT
MANAGER_NAME,
MANAGER_LEVEL,
MANAGER_PHONE,
CASE WHEN MANAGER_LEVEL = 1 THEN 'FRESHER'
     WHEN MANAGER_LEVEL IN (2,3) THEN 'JUNIOR'
ELSE 'SENIOR' END AS LEVEL
FROM MANAGERS;

-- Thank you for your reviewing!