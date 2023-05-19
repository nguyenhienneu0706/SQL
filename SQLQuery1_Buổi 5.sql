-- BUỔI 5: TRUY VẤN DỮ LIỆU TRÊN BẢNG PHỤ

-- PHƯƠNG PHÁP SỬ DỤNG SUBQUERY:
---? Truy vấn con trong SQL (subquery) là gì?
---> Trong SQL Server, truy vấn con là một truy vấn nằm trong một truy vấn khác. 
---> Có thể tạo các truy vấn trong lệnh SQL. 
---> Các truy vấn con này nằm trong mệnh đề WHERE, FROM hoặc SELECT.

-- VÍ DỤ:
SELECT
ORDER_ID,
ORDER_QUANTITY,
PRODUCT_NAME
FROM ORDERS
WHERE ORDER_QUANTITY > (SELECT AVG(ORDER_QUANTITY) 
                        FROM ORDERS);

-- => VẬY: 
(SELECT AVG(ORDER_QUANTITY) 
FROM ORDERS); -- LÀ TRUY VẤN CON (HAY INNER QUERY, INNER SELECT)
-- TRUY VẤN CHÍNH MÀ CHỨA TRUY VẤN CON ĐƯỢC GỌI LÀ OUTET QUERY HAY OUTER SELECT.

-- CHÚ Ý: Có một vài quy tắc mà Subquery phải tuân theo:
-- i. Sub query phải được đặt trong dấu ngoặc đơn.
-- ii.Không thể sử dụng lệnh ORDER BY trong subquery, mặc dù truy vấn chính có thể sử dụng ORDER BY. 
-- iii.Lệnh GROUP BY được sử dụng bình thường trong 1 subquery.

-- VỊ TRÍ WHERE:
-- THỰC HÀNH: LẤY DANH SÁCH CÁC ĐƠN HÀNG CÓ LỢI NHUẬN > LỢI NHUẬN TRUNG BÌNH CÁC ĐƠN HÀNG
SELECT *
FROM ORDERS
WHERE PROFIT > (SELECT AVG(PROFIT) 
                        FROM ORDERS);

-- THỰC HÀNH: LẤY DANH SÁCH CÁC ĐƠN HÀNG CÓ GIÁ TRỊ: VALUE > VALUE TRUNG BÌNH, CỦA CÁC ĐƠN HÀNG CÓ MỨC ĐỘ ƯU TIÊN LÀ LOW:
SELECT *
FROM ORDERS
WHERE VALUE > (SELECT AVG(VALUE) FROM ORDERS)
AND ORDER_PRIORITY = 'LOW';

-- THỰC HÀNH: LẤY DANH SÁCH CÁC ĐƠN HÀNG CÓ GIÁ TRỊ: VALUE > (VALUE TRUNG BÌNH CỦA CÁC ĐƠN HÀNG CÓ MỨC ĐỘ ƯU TIÊN LÀ LOW):
SELECT *
FROM ORDERS
WHERE VALUE > (SELECT AVG(VALUE) FROM ORDERS 
                   WHERE ORDER_PRIORITY = 'LOW');

-- VỊ TRÍ SELECT:
-- THỰC HÀNH: VIẾT CÂU TRUY VẤN RA OUTPUT GỒM CÁC CỘT: 
-- ORDER_ID, ORDER_DATE, FROFIT, AVG_FROFIT_ALL_ORDERS
-- VỚI AVG_PROFIT_ALL_ORDERS --LÀ GIÁ TRỊ LỢI NHUẬN TRUNG BÌNH CỦA TẤT CÁC ĐƠN HÀNG
SELECT 
ORDER_ID, 
ORDER_DATE, 
PROFIT,
(SELECT AVG(PROFIT) FROM ORDERS AS AVG_FROFIT_ALL_ORDERS)
FROM ORDERS; -- CÁI NÀY THƯỜNG DÙNG ĐỂ VẼ BIỂU ĐỒ.

-- VỊ TRÍ FROM:
-- VÍ DỤ LÀM LẠI BÀI TẬP TẠO NET_PROFIT
----> BÀI 1:  DÙNG CTE Viết câu lệnh Select các trường từ bảng Orders: order_id, order_date, order_quantity, value, profit
--  Và tạo thêm các cột mới:
--	cột mới “revenue” được tính bởi công thức:       order_quantity* unit_price*(1- discount)
--	cột mới “total_cost” được tính bởi công thức:	 product_base_margin* unit_price+shipping_cost
--	cột mới “net_profit” được tính bởi công thức:	 revenue - total_cost
-- NGOÀI CÁCH NHƯ BUỔI 1 LÀM BTVN THÌ, CÁCH KHÁC LÀ:
SELECT *, REVENUE-TOTAL_COST AS NET_PROFIT
FROM
    (SELECT order_id, order_date, order_quantity,value, profit,
    order_quantity * unit_price * (1- discount) AS revenue,
    product_base_margin* unit_price+shipping_cost AS total_cost
    FROM ORDERS) AS A -- TRONG NGOẶC LÀ TẠO RA BẢNG CẦN TÌM NHƯNG CÒN THIẾU NET_PROFIT

-- THỰC HÀNH: TỪ BẢNG ORDERS TÍNH DOANH THU TB MỖI NĂM (AVG_REVENUE)
SELECT YEAR(ORDER_DATE) AS YEAR, 
AVG(REVANUE) AS AVG_REVANUE
FROM
(SELECT 
order_id, 
order_date, 
order_quantity, 
value, 
profit,
order_quantity * unit_price * (1- discount) AS REVANUE
FROM ORDERS) AS A
GROUP BY YEAR(ORDER_DATE);
-- HOẶC:
SELECT
	YEAR,
	AVG(revenue) AS avg_revenue
FROM
	(SELECT
		YEAR(order_date) AS year,
		order_quantity* unit_price*(1- discount) AS revenue
	FROM Orders) AS A
GROUP BY (year); --ĐÂY LÀ CÁCH CỦA ANH HUY

-- PHƯƠNG PHÁP SỬ DỤNG CTE-COMMON TABLE EXPRESSION (BIỂU THỨC BẢNG):
---? CTE trong SQL Server là gì?---> CTE có thể được xem như một bảng chứa dữ liệu tạm thời từ câu lệnh được định nghĩa trong phạm vi của nó.
---> CTE tương tự như một bảng dẫn xuất (derived table) ở chỗ nó không được lưu trữ như một đối tượng chỉ kéo dài trong suốt thời gian của câu truy vấn. 
---> Không giống như bảng dẫn xuất, CTE có thể tự tham chiếu tới bản thân của nó và có thể tham chiếu nhiều lần trong một câu truy vấn

-- Mục đích của CTE:
---> Tạo truy vấn đệ quy (recursive query).
---> Thay thế View trong một số trường hợp.
---> Sử dụng được nhiều CTE trong một truy vấn duy nhất.

-- Ưu điểm của CTE:
---> CTE có nhiều ưu điểm như khả năng đọc dữ liệu được cải thiện và dễ dàng bảo trì các truy vấn phức tạp. 
---> Các truy vấn có thể được phân thành các khối nhỏ, đơn giản. 
---> Những khối này được sử dụng để xây dựng các CTE phức tạp hơn cho đến khi tập hợp kết quả cuối cùng được tạo ra

-- CÚ PHÁP:
-- BƯỚC 1: Xác định tên biểu thức CTE và danh sách các cột.
WITH expression_name [ ( column_name1 column_name2 [...n] ) ]
AS (                                                            -- BƯỚC 2: Xác định truy vấn CTE.                               
     CTE_query_definition
)                         -- BƯỚC 3:Xác định truy vấn bên ngoài tham chiếu đến tên CTE.
SELECT 
FROM expression_name;

-- THỰC HÀNH: TỪ BẢNG ORDERS TÍNH DOANH THU TB MỖI NĂM (AVG_REVENUE)
-- CÚ PHÁP:
WITH A AS
(
SELECT
		YEAR(order_date) AS YEAR,
		order_quantity * unit_price*(1- discount) AS REVENUE
	FROM Orders
)
SELECT YEAR, AVG(REVENUE) AS AVG_REVENUE FROM A
GROUP BY YEAR;

-- THỰC HÀNH: 
-- BÀI 1: DÙNG CTE Viết câu lệnh Select các trường từ bảng Orders: order_id, order_date, order_quantity, value, profit
--  Và tạo thêm các cột mới:
--	cột mới “revenue” được tính bởi công thức:       order_quantity* unit_price*(1- discount)
--	cột mới “total_cost” được tính bởi công thức:	 product_base_margin* unit_price+shipping_cost
--	cột mới “net_profit” được tính bởi công thức:	 revenue - total_cost
-- CÁCH 1: DÙNG CÁCH THÔNG THƯỜNG NHƯ BTVN BUỔI 1
SELECT 
order_id, 
order_date, 
order_quantity, 
value, 
profit,
order_quantity * unit_price * (1- discount) AS revenue,
product_base_margin * unit_price + shipping_cost AS total_cost,
(order_quantity * unit_price * (1- discount)) - (product_base_margin * unit_price + shipping_cost) AS net_profit
FROM Orders;

-- CÁCH 2: DÙNG CTE
WITH A AS
(
SELECT 
ORDER_ID, 
ORDER_DATE,
ORDER_QUANTITY, 
VALUE, 
PROFIT,
ORDER_QUANTITY * UNIT_PRICE * (1-DISCOUNT) AS REVENUE,
PRODUCT_BASE_MARGIN * UNIT_PRICE + SHIPPING_COST AS TOTAL_COST
FROM ORDERS 
)
SELECT *,
REVENUE - TOTAL_COST AS NET_PROFIT
FROM A;

-- THỰC HÀNH: TỔNG HỢP BẢNG KQ:
-- YEAR, COUNT_ORDERS, COUNT_ORDERS_RETURNS:
-- GỢI Ý: LẬP BẢNG A: COUNT_ORDERS; BẢNG B: COUNT_ORDERS_RETURNS. SAU ĐÓ KẾT HỢP DÙNG JOIN, KEY LÀ YEAR
---> BƯỚC 1: TẠO BẢNG A
SELECT 
YEAR(ORDER_DATE) AS YEAR, 
COUNT(DISTINCT ORDER_ID) AS COUNT_ORDERS 
FROM ORDERS 
GROUP BY YEAR(ORDER_DATE);
---> BƯỚC 2: TẠO BẢNG B
SELECT YEAR(ORDER_DATE) AS YEAR, COUNT(DISTINCT ORDER_ID) AS COUNT_ORDERS_RETURNS
FROM
    (SELECT A.ORDER_ID, A.ORDER_DATE, B.STATUS 
    FROM ORDERS AS A 
    LEFT JOIN RETURNS AS B
    ON A.ORDER_ID=B.ORDER_ID
    WHERE B.STATUS IS NOT NULL) AS RETURNS
GROUP BY YEAR(ORDER_DATE);
---> BƯỚC 3: GHÉP NỐI 2 BẢNG
WITH 
A AS 
    (SELECT YEAR(ORDER_DATE) AS YEAR , COUNT(ORDER_ID) AS COUNT_ORDERS 
    FROM ORDERS 
    GROUP BY YEAR(ORDER_DATE)),
B AS 
    (SELECT YEAR(O.ORDER_DATE) AS YEAR, COUNT(O.ORDER_ID) AS COUNT_ORDERS_RETURNS 
    FROM ORDERS AS O 
    INNER JOIN RETURNS AS R 
    ON O.ORDER_ID=R.ORDER_ID
    GROUP BY YEAR(O.ORDER_DATE))
SELECT A.YEAR, A.COUNT_ORDERS, B.COUNT_ORDERS_RETURNS
FROM A 
LEFT JOIN B 
ON A.YEAR=B.YEAR

-- GIẢ SỬ MUỐN CÓ THÊM: TỶ LỆ HOÀN ĐƠN
WITH 
A AS 
    (SELECT YEAR(ORDER_DATE) AS YEAR , COUNT(ORDER_ID) AS COUNT_ORDERS 
    FROM ORDERS 
    GROUP BY YEAR(ORDER_DATE)),
B AS 
    (SELECT YEAR(O.ORDER_DATE) AS YEAR, COUNT(O.ORDER_ID) AS COUNT_ORDERS_RETURNS 
    FROM ORDERS AS O 
    INNER JOIN RETURNS AS R 
    ON O.ORDER_ID=R.ORDER_ID
    GROUP BY YEAR(O.ORDER_DATE))
SELECT A.YEAR, A.COUNT_ORDERS, B.COUNT_ORDERS_RETURNS, B.COUNT_ORDERS_RETURNS*100.0/A.COUNT_ORDERS AS PERCENT_RETURNS
FROM A LEFT JOIN B ON A.YEAR=B.YEAR

-- DÙNG SUBQUERY
SELECT 
A.YEAR, 
A.COUNT_ORDERS, 
B.COUNT_ORDERS_RETURNS, 
B.COUNT_ORDERS_RETURNS*100.0/A.COUNT_ORDERS AS PERCENT_RETURNS
FROM 
( 
SELECT
YEAR(ORDER_DATE) AS YEAR,
COUNT(DISTINCT ORDER_ID) AS COUNT_ORDERS
FROM ORDERS
GROUP BY YEAR(ORDER_DATE)
) AS A
LEFT JOIN
(
SELECT
YEAR(A.ORDER_DATE) AS YEAR,  -- RETURNED_DATE THAY BẰNG O. ORDER_DATE CŨNG ĐƯỢC
COUNT(A.ORDER_ID) AS COUNT_ORDERS_RETURNS
FROM ORDERS AS A
INNER JOIN RETURNS AS B
ON A.ORDER_ID=B.ORDER_ID
GROUP BY YEAR(A.ORDER_DATE)
) AS B
ON A.YEAR=B.YEAR;

-- THỰC HÀNH: 
-- Xác định tên biểu thức CTE và danh sách các cột.
WITH PivotOrders_CTE (Order_id, Total_quantity, Total_value)
AS (                      -- Xác định truy vấn CTE.           
SELECT Order_id, 
sum(Order_quantity) AS Total_quantity, 
sum(value) AS Total_value
FROM Orders
GROUP BY Order_id
)
-- Xác định truy vấn bên ngoài tham chiếu đến tên CTE.
SELECT 
Order_id, 
Total_quantity, 
Total_value
FROM PivotOrders_CTE
WHERE Total_quantity > 100
ORDER BY Total_quantity Desc;
-- HAY THÔNG THƯỜNG HAY VIẾT LÀ:
SELECT 
Order_id, 
sum(Order_quantity) AS Total_quantity, 
sum(value) AS Total_value
FROM Orders
GROUP BY Order_id
HAVING sum(Order_quantity) > 100
ORDER BY Order_id DESC;

-- THỰC HÀNH:
WITH PivotOrders_CTE (Order_id, Order_date, Total_quantity, Total_value)
AS (
SELECT 
Order_id, 
Order_date,
sum(Order_quantity) AS Total_quantity, 
sum(value) AS Total_value
FROM Orders
GROUP BY Order_id, Order_date
)
SELECT 
Order_id, 
Order_date, 
Total_quantity, 
Total_value
FROM PivotOrders_CTE
WHERE YEAR(Order_date)=2012
ORDER BY Order_id DESC;
-- HAY THÔNG THƯỜNG VIẾT:
SELECT 
Order_id, 
Order_date,
sum(Order_quantity) AS Total_quantity, 
sum(value) AS Total_value
FROM Orders
WHERE YEAR(Order_date)=2012
GROUP BY Order_id, Order_date
ORDER BY Order_id DESC;

WITH PivotOrders_CTE (Order_id, Order_date, Total_quantity, Total_value)
AS (
SELECT 
Order_id, 
Order_date,
sum(Order_quantity) AS Total_quantity, 
sum(value) AS Total_value
FROM Orders
GROUP BY Order_id, Order_date
)
SELECT 
Order_id, 
Order_date, 
Total_quantity, 
Total_value
FROM PivotOrders_CTE
WHERE Total_quantity > 150
ORDER BY Order_id DESC;
-- HAY THÔNG THƯỜNG VIẾT:
SELECT 
Order_id, 
Order_date,
sum(Order_quantity) AS Total_quantity, 
sum(value) AS Total_value
FROM Orders
GROUP BY Order_id, Order_date
HAVING sum(Order_quantity) > 150
ORDER BY Order_id DESC;

-- PHƯƠNG PHÁP SỬ DỤNG BẢNG TẠM - TEMP TABLE:
-- Sẽ rất có lợi khi lưu trữ dữ liệu trong các bảng tạm thời của SQL Server thay vì thao tác hoặc làm việc với các bảng cố định.
---> Khi bạn muốn có đầy đủ quyền truy cập vào các bảng trong Database, nhưng bạn lại không có. 
---> Bạn có thể sử dụng quyền truy cập đọc hiện có của mình để kéo dữ liệu vào bảng tạm thời của SQL-Server và thực hiện các điều chỉnh từ đó.
---> Hoặc bạn không có quyền để tạo bảng trong cơ sở dữ liệu hiện có, bạn có thể tạo bảng tạm thời SQL Server mà bạn có thể thao tác.
---> Cuối cùng, bạn có thể rơi vào tình huống chỉ cần hiển thị dữ liệu trong phiên hiện tại, và muốn update insert data trước khi hiển thị.

---? Bảng tạm trong SQL server là gì ?
---> Bảng tạm là các có cấu trúc và chức năng như một bảng cố định bình thường trong SQL Server. 
---> Nhưng thay vì tạo ra một bảng trong Database, bảng tạm được tạo ra và lưu trữ trong tempdb. 
---> Chúng ta thường tạo bảng tạm trong một câu truy vấn, trong xử lý của một procedure hoặc trong một function (chỉ sử dụng được biến kiểu bảng).

-- Đối với SQL Server có 2 dạng bảng tạm đó là:
---> Local temporary table (#Table1): Sử dụng để tạo ra bảng tạm và tồn tại trong kết nối của người dùng tạo ra bảng đó và sẽ bị huỷ khi ngắt kết nối.
---> Global temporary table (##Table2): Sử dụng để tạo ra bảng tạm và tồn tại đến khi nào tất cả các kết nối đến cơ sở dữ liệu làm việc đóng hết.
---> Global temporary table (##Table2): Có thể sử dụng ở kết nối của người dùng khác.

-- CÚ PHÁP TẠO BẢNG TẠM:
-- 1. LOCAL TEMPORARY TABLE:
CREATE TABLE #TempTable1 
(
ID INT IDENTITY PRIMARY KEY NOT NULL, 
Name VARCHAR(10) NOT NULL, 
DOB DATETIME null
)
GO

-- 2. GLOBAL TEMPORARY TABLE:
CREATE TABLE ##TempTable2
(
ID INT IDENTITY PRIMARY KEY NOT NULL,
Name VARCHAR(10) NOT NULL,
DOB DATETIME null
)
GO
INSERT INTO ##TempTable2
( Name, DOB )
VALUES (
'TONA', -- Name - varchar(10)
GETDATE() -- DOB - datetime
)
GO
SELECT * FROM ##TempTable2

-- BÀI TẬP VỀ NHÀ:
-- BT1: Từ bảng dữ liệu Orders và Returns hãy tạo ra kết quả:
-- gồm 4 cột: Năm, Tháng, Tổng đơn hàng, Tổng đơn hàng bị trả lại
-- =>> Sử dụng cả phương pháp Sub query và CTE
SELECT * FROM ORDERS;
SELECT * FROM MANAGERS;
SELECT * FROM PROFILES;
SELECT * FROM RETURNS;

-- CÁCH 1: Sử dụng phương pháp CTE:
WITH 
T1 AS 
   (SELECT
   YEAR(ORDER_DATE) AS YEAR,
   MONTH(ORDER_DATE) AS MONTH,
   COUNT(DISTINCT ORDER_ID) AS TOTAL_ORDERS
   FROM ORDERS
   GROUP BY YEAR(ORDER_DATE), MONTH(ORDER_DATE)),
T2 AS 
   (SELECT
   YEAR(RETURNED_DATE) AS YEAR,
   MONTH(RETURNED_DATE) AS MONTH,
   COUNT(DISTINCT ORDER_ID) AS TOTAL_RETURNS
   FROM RETURNS
   GROUP BY YEAR(RETURNED_DATE), MONTH(RETURNED_DATE))
SELECT
T1.YEAR,      -- T2.YEAR CŨNG ĐƯỢC
T2.MONTH,    -- T1.MONTH CŨNG ĐƯỢC
T1.TOTAL_ORDERS,
T2.TOTAL_RETURNS
FROM T1 AS T1
LEFT JOIN T2 AS T2
ON T1.YEAR=T2.YEAR AND T1.MONTH=T2.MONTH;

-- CÁCH 2: Sử dụng phương pháp Subquery:
SELECT
YEAR(T1.ORDER_DATE) AS YEAR,
MONTH(T1.ORDER_DATE) AS MONTH,
COUNT(DISTINCT T1.ORDER_ID) AS TOTAL_ORDERS,
COUNT(DISTINCT T2.ORDER_ID) AS TOTAL_RETURNS
FROM ORDERS AS T1
LEFT JOIN RETURNS AS T2
ON  YEAR(T1.ORDER_DATE)=(SELECT YEAR(T2.RETURNED_DATE)) 
AND MONTH(T1.ORDER_DATE)=(SELECT MONTH(T2.RETURNED_DATE))
GROUP BY YEAR(T1.ORDER_DATE), MONTH(T1.ORDER_DATE)
ORDER BY YEAR, MONTH ASC;

-- BT2: Từ bảng Orders và Returns hãy tạo ra kết quả gồm các cột:
-- Năm, Tháng, Loại sản phẩm, Tổng giá trị (Total_value), Tổng giá trị hoàn hàng (Total_value_of_returned)
-- =>> Sử dụng cả phương pháp Sub query và CTE

-- CÁCH 1: Sử dụng phương pháp CTE:
WITH 
T1 AS 
   (SELECT
   YEAR(ORDER_DATE) AS YEAR,
   MONTH(ORDER_DATE) AS MONTH,
   PRODUCT_CATEGORY,
   SUM(VALUE) AS TOTAL_VALUE
   FROM ORDERS
   GROUP BY YEAR(ORDER_DATE), MONTH(ORDER_DATE), PRODUCT_CATEGORY),
T2 AS 
   (SELECT
   YEAR(RETURNED_DATE) AS YEAR,
   MONTH(RETURNED_DATE) AS MONTH,
   T1.PRODUCT_CATEGORY,
   SUM (VALUE) AS TOTAL_VALUE_OF_RETURNED
   FROM ORDERS AS T1
   RIGHT JOIN RETURNS AS T2
   ON T1.ORDER_ID=T2.ORDER_ID
   GROUP BY YEAR(RETURNED_DATE), MONTH(RETURNED_DATE), T1.PRODUCT_CATEGORY)
SELECT
T1.YEAR,      -- T2.YEAR CŨNG ĐƯỢC
T2.MONTH,    -- T1.MONTH CŨNG ĐƯỢC
T1.PRODUCT_CATEGORY,
TOTAL_VALUE,
TOTAL_VALUE_OF_RETURNED
FROM T1 
LEFT JOIN T2 
ON T1.YEAR=T2.YEAR AND T1.MONTH=T2.MONTH AND T1.PRODUCT_CATEGORY=T2.PRODUCT_CATEGORY;

-- CÁCH 2: Sử dụng phương pháp Subquery:
SELECT 
T1.YEAR,      -- T2.YEAR CŨNG ĐƯỢC
T2.MONTH,    -- T1.MONTH CŨNG ĐƯỢC
T1.PRODUCT_CATEGORY,
TOTAL_VALUE,
TOTAL_VALUE_OF_RETURNED
FROM
   (SELECT
   YEAR(ORDER_DATE) AS YEAR,
   MONTH(ORDER_DATE) AS MONTH,
   PRODUCT_CATEGORY,
   SUM(VALUE) AS TOTAL_VALUE
   FROM ORDERS
   GROUP BY YEAR(ORDER_DATE), MONTH(ORDER_DATE), PRODUCT_CATEGORY) AS T1
LEFT JOIN
   (SELECT
   YEAR(RETURNED_DATE) AS YEAR,
   MONTH(RETURNED_DATE) AS MONTH,
   T1.PRODUCT_CATEGORY,
   SUM (VALUE) AS TOTAL_VALUE_OF_RETURNED
   FROM ORDERS AS T1
   RIGHT JOIN RETURNS AS T2
   ON T1.ORDER_ID=T2.ORDER_ID
   GROUP BY YEAR(RETURNED_DATE), MONTH(RETURNED_DATE), T1.PRODUCT_CATEGORY) AS T2
ON T1.YEAR=T2.YEAR AND T1.MONTH=T2.MONTH AND T1.PRODUCT_CATEGORY=T2.PRODUCT_CATEGORY;

-- UPDATED: 4/8
-- BÀI TẬP VỀ NHÀ:
-- BT1: Từ bảng dữ liệu Orders và Returns hãy tạo ra kết quả:
-- gồm 4 cột: Năm, Tháng, Tổng đơn hàng, Tổng đơn hàng bị trả lại
-- =>> Sử dụng cả phương pháp Sub query và CTE
SELECT * FROM ORDERS;
SELECT * FROM MANAGERS;
SELECT * FROM PROFILES;
SELECT * FROM RETURNS;

-- CÁCH 1: SỬ DỤNG PHƯƠNG PHÁP CTE:
WITH 
T1 AS 
   (SELECT
   YEAR(ORDER_DATE) AS YEAR,
   MONTH(ORDER_DATE) AS MONTH,
   COUNT(DISTINCT ORDER_ID) AS TOTAL_ORDERS
   FROM ORDERS
   GROUP BY YEAR(ORDER_DATE), MONTH(ORDER_DATE)),
T2 AS 
   (SELECT
   YEAR(RETURNED_DATE) AS YEAR,
   MONTH(RETURNED_DATE) AS MONTH,
   COUNT(DISTINCT ORDER_ID) AS TOTAL_RETURNS
   FROM RETURNS
   GROUP BY YEAR(RETURNED_DATE), MONTH(RETURNED_DATE))
SELECT
T1.YEAR,      -- T2.YEAR CŨNG ĐƯỢC
T2.MONTH,    -- T1.MONTH CŨNG ĐƯỢC
T1.TOTAL_ORDERS,
T2.TOTAL_RETURNS
FROM T1 AS T1
LEFT JOIN T2 AS T2
ON T1.YEAR=T2.YEAR AND T1.MONTH=T2.MONTH;

-- CÁCH 2: SỬ DỤNG PHƯƠNG PHÁP SUBQUERY:
SELECT
YEAR(T1.ORDER_DATE) AS YEAR,
MONTH(T1.ORDER_DATE) AS MONTH,
COUNT(DISTINCT T1.ORDER_ID) AS TOTAL_ORDERS,
COUNT(DISTINCT T2.ORDER_ID) AS TOTAL_RETURNS
FROM ORDERS AS T1
LEFT JOIN RETURNS AS T2
ON  YEAR(T1.ORDER_DATE)=(SELECT YEAR(T2.RETURNED_DATE)) 
AND MONTH(T1.ORDER_DATE)=(SELECT MONTH(T2.RETURNED_DATE))
GROUP BY YEAR(T1.ORDER_DATE), MONTH(T1.ORDER_DATE)
ORDER BY YEAR, MONTH ASC;

-- BT2: Từ bảng Orders và Returns hãy tạo ra kết quả gồm các cột:
-- Năm, Tháng, Loại sản phẩm, Tổng giá trị (Total_value), Tổng giá trị hoàn hàng (Total_value_of_returned)
-- =>> Sử dụng cả phương pháp Sub query và CTE

-- CÁCH 1: SỬ DỤNG PHƯƠNG PHÁP CTE:
WITH 
T1 AS 
   (SELECT
   YEAR(ORDER_DATE) AS YEAR,
   MONTH(ORDER_DATE) AS MONTH,
   PRODUCT_CATEGORY,
   SUM(VALUE) AS TOTAL_VALUE
   FROM ORDERS
   GROUP BY YEAR(ORDER_DATE), MONTH(ORDER_DATE), PRODUCT_CATEGORY),
T2 AS 
   (SELECT
   YEAR(RETURNED_DATE) AS YEAR,
   MONTH(RETURNED_DATE) AS MONTH,
   T1.PRODUCT_CATEGORY,
   SUM (VALUE) AS TOTAL_VALUE_OF_RETURNED
   FROM ORDERS AS T1
   LEFT JOIN RETURNS AS T2 -- BÀI NÀY LEFT, RIGHT, INNER, FULL JOIN ĐỀU ĐƯỢC
   ON T1.ORDER_ID=T2.ORDER_ID
   GROUP BY YEAR(RETURNED_DATE), MONTH(RETURNED_DATE), T1.PRODUCT_CATEGORY)
SELECT
T1.YEAR,      -- T2.YEAR CŨNG ĐƯỢC
T2.MONTH,    -- T1.MONTH CŨNG ĐƯỢC
T1.PRODUCT_CATEGORY,
TOTAL_VALUE,
TOTAL_VALUE_OF_RETURNED
FROM T1 
LEFT JOIN T2 
ON T1.YEAR=T2.YEAR AND T1.MONTH=T2.MONTH AND T1.PRODUCT_CATEGORY=T2.PRODUCT_CATEGORY;

-- CÁCH 2: SỬ DỤNG PHƯƠNG PHÁP SUBQUERY:
SELECT 
T1.YEAR,      -- T2.YEAR CŨNG ĐƯỢC
T2.MONTH,    -- T1.MONTH CŨNG ĐƯỢC
T1.PRODUCT_CATEGORY,
TOTAL_VALUE,
TOTAL_VALUE_OF_RETURNED
FROM
   (SELECT
   YEAR(ORDER_DATE) AS YEAR,
   MONTH(ORDER_DATE) AS MONTH,
   PRODUCT_CATEGORY,
   SUM(VALUE) AS TOTAL_VALUE
   FROM ORDERS
   GROUP BY YEAR(ORDER_DATE), MONTH(ORDER_DATE), PRODUCT_CATEGORY) AS T1
LEFT JOIN
   (SELECT
   YEAR(RETURNED_DATE) AS YEAR,
   MONTH(RETURNED_DATE) AS MONTH,
   T1.PRODUCT_CATEGORY,
   SUM (VALUE) AS TOTAL_VALUE_OF_RETURNED
   FROM ORDERS AS T1
   LEFT JOIN RETURNS AS T2 -- BÀI NÀY LEFT, RIGHT, INNER, FULL JOIN ĐỀU ĐƯỢC
   ON T1.ORDER_ID=T2.ORDER_ID
   GROUP BY YEAR(RETURNED_DATE), MONTH(RETURNED_DATE), T1.PRODUCT_CATEGORY) AS T2
ON T1.YEAR=T2.YEAR AND T1.MONTH=T2.MONTH AND T1.PRODUCT_CATEGORY=T2.PRODUCT_CATEGORY;

-- BT3: Từ tập dữ liệu đã cho, truy xuất tất cả các đơn đặt hàng trong năm 2012 (từ 2012-01-01 đến 2012-12-31) và tóm tắt thông tin như sau:
-- Trong đó:
-- number_items: tổng số mặt hàng, không bao gồm các mặt hàng bị trả lại.
-- total_quantity: tổng số lượng mặt hàng được giao cho từng người quản lý, không bao gồm các mặt hàng bị trả lại.
-- total_value: tổng giá trị của các mặt hàng được giao cho từng người quản lý, không bao gồm các mặt hàng bị trả lại.
-- total_profit: tổng lợi nhuận của các mặt hàng được giao cho từng người quản lý, không bao gồm các mặt hàng bị trả lại.

SELECT * FROM ORDERS;
SELECT * FROM MANAGERS;
SELECT * FROM PROFILES;
SELECT * FROM RETURNS;

-- Ý TƯỞNG:
----> TA BIẾT: COUNT(DISTINCT O.ORDER_ID) LÀ TỔNG SỐ ĐƠN HÀNG, MỖI ĐƠN HÀNG GỒM MỘT HOẶC NHIỀU MẶT HÀNG  
-- Ở ĐÂY MỖI ĐƠN HÀNG ĐƯỢC GIỮ NGUYÊN -> ỨNG VỚI MỘT QUAN SÁT (NẾU CÓ 1 MẶT HÀNG) 
-- HOẶC: TÁCH RA MỖI MẶT HÀNG MỘT QUAN SÁT (NẾU ĐƠN CÓ > 1 MẶT HÀNG)
-- (VỚI SỐ LƯỢNG TỪNG MẶT HÀNG Ở CỘT QUANTITY) 
YEAR(O.ORDER_DATE)=2012
M.MANAGE_NAME
M.MANAGE_LEVEL
M.MANAGE_ID
COUNT(O.ORDER_ID) AS NUMBER_ITEMS        -- KHÔNG TÍNH ĐƠN BỊ TRẢ LẠI
SUM(O.ORDER_QUANTITY) AS TOTAL_QUANTITY  -- KHÔNG TÍNH ĐƠN BỊ TRẢ LẠI
SUM(VALUE) AS TOTAL_VALUE                -- KHÔNG TÍNH ĐƠN BỊ TRẢ LẠI
SUM(ORDER_PROFIT) AS TOTAL_PROFIT        -- KHÔNG TÍNH ĐƠN BỊ TRẢ LẠI

----> KHÔNG TÍNH ĐƠN BỊ TRẢ LẠI TỨC LÀ: 
WHERE R.STATUS IS NULL -- (SAU KHI BẢNG THAM CHIẾU ĐÃ ĐƯỢC THÊM CỘT R.STATUS)
-- HOẶC LÀ:
WHERE O.ORDER_ID!=R.ORDER_ID

-- CÂU LỆNH:
-- CÁCH 1: SỬ DỤNG PHƯƠNG PHÁP CTE:
WITH A AS
   (
   SELECT 
   O.ORDER_DATE, O.ORDER_ID, O.ORDER_QUANTITY, O.VALUE, O.PROFIT,
   R.RETURNED_DATE, R.STATUS,
   M.MANAGER_NAME, M.MANAGER_ID, M.MANAGER_LEVEL, M.MANAGER_PHONE 
   FROM ORDERS AS O
   LEFT JOIN RETURNS AS R
   ON O.ORDER_ID = R.ORDER_ID
   LEFT JOIN PROFILES AS P
   ON O.PROVINCE = P.PROVINCE
   LEFT JOIN MANAGERS AS M
   ON P.MANAGER = M.MANAGER_NAME
   WHERE O.ORDER_DATE BETWEEN '2012-1-1' AND '2012-12-31'
   )
SELECT
A.MANAGER_NAME,
A.MANAGER_LEVEL,
A.MANAGER_ID,
COUNT(A.ORDER_ID) AS NUMBER_ITEMS,
SUM(A.ORDER_QUANTITY) AS TOTAL_QUANTITY,
SUM(VALUE) AS TOTAL_VALUE,
SUM(PROFIT) AS TOTAL_PROFIT
FROM A
WHERE A.STATUS IS NULL
GROUP BY A.MANAGER_NAME, A.MANAGER_ID, A.MANAGER_LEVEL;
-- HOẶC:
WITH A AS
   (
   SELECT 
   O.ORDER_DATE, O.ORDER_ID, O.ORDER_QUANTITY, O.VALUE, O.PROFIT,
   R.RETURNED_DATE,
   M.MANAGER_NAME, M.MANAGER_ID, M.MANAGER_LEVEL, M.MANAGER_PHONE 
   FROM ORDERS AS O
   LEFT JOIN RETURNS AS R
   ON O.ORDER_ID = R.ORDER_ID
   LEFT JOIN PROFILES AS P
   ON O.PROVINCE = P.PROVINCE
   LEFT JOIN MANAGERS AS M
   ON P.MANAGER = M.MANAGER_NAME
   WHERE YEAR(O.ORDER_DATE)=2012
   )
SELECT
A.MANAGER_NAME,
A.MANAGER_LEVEL,
A.MANAGER_ID,
COUNT(A.ORDER_ID) AS NUMBER_ITEMS,
SUM(A.ORDER_QUANTITY) AS TOTAL_QUANTITY,
SUM(VALUE) AS TOTAL_VALUE,
SUM(PROFIT) AS TOTAL_PROFIT
FROM A
WHERE A.RETURNED_DATE IS NULL
GROUP BY A.MANAGER_NAME, A.MANAGER_ID, A.MANAGER_LEVEL;
-- HOẶC

-- CÁCH 2: SỬ DỤNG PHƯƠNG PHÁP SUBQUERY:
SELECT 
A.MANAGER_NAME,
A.MANAGER_LEVEL,
A.MANAGER_ID,
COUNT(A.ORDER_ID) AS NUMBER_ITEMS,
SUM(A.ORDER_QUANTITY) AS TOTAL_QUANTITY,
SUM(VALUE) AS TOTAL_VALUE,
SUM(PROFIT) AS TOTAL_PROFIT
FROM 
   (
   SELECT 
   O.ORDER_DATE, O.ORDER_ID, O.ORDER_QUANTITY, O.VALUE, O.PROFIT,
   R.RETURNED_DATE,
   M.MANAGER_NAME, M.MANAGER_ID, M.MANAGER_LEVEL, M.MANAGER_PHONE 
   FROM ORDERS AS O
   LEFT JOIN RETURNS AS R
   ON O.ORDER_ID = R.ORDER_ID
   LEFT JOIN PROFILES AS P
   ON O.PROVINCE = P.PROVINCE
   LEFT JOIN MANAGERS AS M
   ON P.MANAGER = M.MANAGER_NAME
   WHERE YEAR(O.ORDER_DATE)=2012
   ) AS A
WHERE A.RETURNED_DATE IS NULL
GROUP BY A.MANAGER_NAME, A.MANAGER_ID, A.MANAGER_LEVEL;
-- HOẶC:
SELECT 
A.MANAGER_NAME,
A.MANAGER_LEVEL,
A.MANAGER_ID,
COUNT(A.ORDER_ID) AS NUMBER_ITEMS,
SUM(A.ORDER_QUANTITY) AS TOTAL_QUANTITY,
SUM(VALUE) AS TOTAL_VALUE,
SUM(PROFIT) AS TOTAL_PROFIT
FROM 
   (SELECT 
   O.ORDER_DATE, O.ORDER_ID, O.ORDER_QUANTITY, O.VALUE, O.PROFIT,
   R.RETURNED_DATE, R.STATUS,
   M.MANAGER_NAME, M.MANAGER_ID, M.MANAGER_LEVEL, M.MANAGER_PHONE 
   FROM ORDERS AS O
   LEFT JOIN RETURNS AS R
   ON O.ORDER_ID = R.ORDER_ID
   LEFT JOIN PROFILES AS P
   ON O.PROVINCE = P.PROVINCE
   LEFT JOIN MANAGERS AS M
   ON P.MANAGER = M.MANAGER_NAME
   WHERE O.ORDER_DATE BETWEEN '2012-1-1' AND '2012-12-31') AS A
WHERE A.STATUS IS NULL
GROUP BY A.MANAGER_NAME, A.MANAGER_ID, A.MANAGER_LEVEL;





