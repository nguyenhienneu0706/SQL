-- BÀI TEST ỨNG VIÊN: NGUYỄN THỊ HIỀN --

USE AdventureWorksDW2019
GO

-- BÀI LÀM:
/* Câu 1: Từ bảng FactResellerSales, DimReseller hãy truy vấn danh sách các đơn hàng được đặt trong năm 2013. 
Đồng thời có CarrierTrackingNumber bắt đầu bằng 2 chữ cái, kết thúc bằng 2 chữ số và chữ cái thứ 7 là chữ “C” hoặc chữ “F”. 
Kết quả trả về gồm các thông tin sau: OrderDate, SalesOrderNumber, SalesOrderLineNumber, ResellerName, BusinessType, SalesAmount? */

SELECT * FROM FactResellerSales;
SELECT * FROM DimReseller;

-- CÁCH 1:
SELECT 
	FRS.CarrierTrackingNumber,
	FRS.OrderDate, 
	FRS.SalesOrderNumber,
	FRS.SalesOrderLineNumber,
	DR.ResellerName,
	DR.BusinessType,
	FRS.SalesAmount 
FROM FactResellerSales AS FRS
LEFT JOIN DimReseller AS DR
ON FRS.ResellerKey = DR.ResellerKey
WHERE YEAR(FRS.OrderDate) = 2013
    AND SUBSTRING(FRS.CarrierTrackingNumber, 1, 2) LIKE '[A-Z][A-Z]' -- CÓ THỂ SỬ DỤNG LEFT THAY CHO SUBSTRING
    AND RIGHT(FRS.CarrierTrackingNumber, 2) LIKE '[0-9][0-9]'
    AND SUBSTRING(FRS.CarrierTrackingNumber, 7, 1) IN ('C', 'F');
--> KẾT QUẢ TRẢ VỀ 357 ROWS THỎA MÃN ĐIỀU KIỆN

/* Câu 2: Từ bảng FactResellerSales, DimReseller, DimGeography, hãy tính toán tổng doanh thu (đặt tên là ResellerSalesAmount), 
số lượng mã đơn đã đặt (NumberofOrders) của từng năm đối với mỗi BussinessType. Chỉ tính toán trên các Reseller đến từ City = “London” 
Kết quả trả về gồm các thông tin sau: OrderYear, OrderMonth, BussinessType, ResellerSalesAmount, NumberofOrders ? */

SELECT * FROM FactResellerSales;
SELECT * FROM DimReseller;
SELECT * FROM DimGeography;

-- CÁCH 1:
SELECT
    YEAR(FRS.OrderDate) AS OrderYear,
    MONTH(FRS.OrderDate) AS OrderMonth,
    DR.BusinessType,
    SUM(FRS.SalesAmount) AS ResellerSalesAmount,
    COUNT(FRS.SalesOrderNumber) AS NumberofOrders
FROM FactResellerSales AS FRS
INNER JOIN DimReseller AS DR 
ON FRS.ResellerKey = DR.ResellerKey
INNER JOIN DimGeography AS DG 
ON DR.GeographyKey = DG.GeographyKey
WHERE DG.City = 'London'
GROUP BY YEAR(FRS.OrderDate), MONTH(FRS.OrderDate), DR.BusinessType
ORDER BY YEAR(FRS.OrderDate); -- Sắp xếp để nhìn kết quả dễ hơn
--> KẾT QUẢ TRẢ VỀ 43 ROWS THỎA MÃN ĐIỀU KIỆN

-- CÁCH 2:
WITH CTE_ResellerSales AS 
(
    SELECT
        YEAR(FRS.OrderDate) AS OrderYear,
        MONTH(FRS.OrderDate) AS OrderMonth,
        DR.BusinessType,
        FRS.SalesAmount,
        FRS.SalesOrderNumber
    FROM FactResellerSales AS FRS
    INNER JOIN DimReseller AS DR 
	ON FRS.ResellerKey = DR.ResellerKey
    INNER JOIN DimGeography AS DG 
	ON DR.GeographyKey = DG.GeographyKey
    WHERE DG.City = 'London'
)
SELECT
    OrderYear,
    OrderMonth,
    BusinessType,
    SUM(SalesAmount) AS ResellerSalesAmount,
    COUNT(SalesOrderNumber) AS NumberofOrders
FROM CTE_ResellerSales
GROUP BY OrderYear, OrderMonth, BusinessType
ORDER BY OrderYear; -- Sắp xếp để nhìn cho dễ
--> KẾT QUẢ TRẢ VỀ 43 ROWS THỎA MÃN ĐIỀU KIỆN

/* Câu 3: Từ bảng FactResellerSales, DimEmployee, 
a. Hãy truy vấn ra danh sách top 5 nhân viên có tổng doanh thu tháng (đặt tên là EmployeeMonthAmount) cao nhất trong hệ thống theo mỗi tháng. 
Kết quả trả về gồm các thông tin sau: OrderYear, OrderMonth, EmployeeKey, EmployeeFullName (kết hợp từ FirstName, MiddleName và LastName) & EmployeeMonthAmount? */

-- CÁCH 1: SỬ DỤNG BẢNG TẠM
-- 1.1:
WITH RankEmployeeSales AS 
(
    SELECT
        YEAR(FRS.OrderDate) AS OrderYear,
        MONTH(FRS.OrderDate) AS OrderMonth,
        FRS.EmployeeKey,
        REPLACE(CONCAT(DE.FirstName, ' ', DE.MiddleName, ' ', DE.LastName), '  ', ' ') AS EmployeeFullName,
        SUM(FRS.SalesAmount) AS EmployeeMonthAmount,
        ROW_NUMBER() OVER (PARTITION BY YEAR(FRS.OrderDate), MONTH(FRS.OrderDate) ORDER BY SUM(FRS.SalesAmount) DESC) AS RowNumber
    FROM FactResellerSales AS FRS
    INNER JOIN DimEmployee AS DE ON FRS.EmployeeKey = DE.EmployeeKey
    GROUP BY YEAR(FRS.OrderDate), MONTH(FRS.OrderDate), FRS.EmployeeKey, CONCAT(DE.FirstName, ' ', DE.MiddleName, ' ', DE.LastName)
)
SELECT
    OrderYear,
    OrderMonth,
    EmployeeKey,
    EmployeeFullName,
    EmployeeMonthAmount
FROM RankEmployeeSales
WHERE RowNumber <= 5;
--> KẾT QUẢ TRẢ VỀ 165 ROWS THỎA MÃN ĐIỀU KIỆN

-- 1.2:
WITH RankEmployeeSales AS 
(
    SELECT
        YEAR(FRS.OrderDate) AS OrderYear,
        MONTH(FRS.OrderDate) AS OrderMonth,
        FRS.EmployeeKey,
        CONCAT_WS(' ', DE.FirstName, DE.MiddleName, DE.LastName) AS EmployeeFullName,
        SUM(FRS.SalesAmount) AS EmployeeMonthAmount,
        ROW_NUMBER() OVER (PARTITION BY YEAR(FRS.OrderDate), MONTH(FRS.OrderDate) ORDER BY SUM(FRS.SalesAmount) DESC) AS RowNumber
    FROM FactResellerSales AS FRS
    INNER JOIN DimEmployee AS DE ON FRS.EmployeeKey = DE.EmployeeKey
    GROUP BY YEAR(FRS.OrderDate), MONTH(FRS.OrderDate), FRS.EmployeeKey, CONCAT_WS(' ', DE.FirstName, DE.MiddleName, DE.LastName) 
)
SELECT
    OrderYear,
    OrderMonth,
    EmployeeKey,
    EmployeeFullName,
    EmployeeMonthAmount
FROM RankEmployeeSales
WHERE RowNumber <= 5;
--> KẾT QUẢ TRẢ VỀ 165 ROWS THỎA MÃN ĐIỀU KIỆN

-- 1.3:
WITH RankEmployeeSales AS 
(
    SELECT
        YEAR(FRS.OrderDate) AS OrderYear,
        MONTH(FRS.OrderDate) AS OrderMonth,
        FRS.EmployeeKey,
        CONCAT(FirstName, ISNULL(' ' + MiddleName, ''), ' ', LastName) AS EmployeeFullName,
        SUM(FRS.SalesAmount) AS EmployeeMonthAmount,
        ROW_NUMBER() OVER (PARTITION BY YEAR(FRS.OrderDate), MONTH(FRS.OrderDate) ORDER BY SUM(FRS.SalesAmount) DESC) AS RowNumber
    FROM FactResellerSales AS FRS
    INNER JOIN DimEmployee AS DE ON FRS.EmployeeKey = DE.EmployeeKey
    GROUP BY YEAR(FRS.OrderDate), MONTH(FRS.OrderDate), FRS.EmployeeKey, CONCAT(FirstName, ISNULL(' ' + MiddleName, ''), ' ', LastName) 
)
SELECT
    OrderYear,
    OrderMonth,
    EmployeeKey,
    EmployeeFullName,
    EmployeeMonthAmount
FROM RankEmployeeSales
WHERE RowNumber <= 5;
--> KẾT QUẢ TRẢ VỀ 165 ROWS THỎA MÃN ĐIỀU KIỆN

-- CÁCH 2: SỬ DỤNG BẢNG PHỤ (SUBQUERY)
-- 2.1:
SELECT
    OrderYear,
    OrderMonth,
    EmployeeKey,
    EmployeeFullName,
    EmployeeMonthAmount
FROM (
    SELECT
        YEAR(FRS.OrderDate) AS OrderYear,
        MONTH(FRS.OrderDate) AS OrderMonth,
        FRS.EmployeeKey,
        REPLACE(CONCAT(DE.FirstName, ' ', DE.MiddleName, ' ', DE.LastName), '  ', ' ') AS EmployeeFullName,
        SUM(FRS.SalesAmount) AS EmployeeMonthAmount,
        ROW_NUMBER() OVER (PARTITION BY YEAR(FRS.OrderDate), MONTH(FRS.OrderDate) ORDER BY SUM(FRS.SalesAmount) DESC) AS RowNumber
    FROM FactResellerSales AS FRS
    INNER JOIN DimEmployee AS DE ON FRS.EmployeeKey = DE.EmployeeKey
    GROUP BY YEAR(FRS.OrderDate), MONTH(FRS.OrderDate), FRS.EmployeeKey, REPLACE(CONCAT(DE.FirstName, ' ', DE.MiddleName, ' ', DE.LastName), '  ', ' ') 
	) 
	AS RankEmployeeSales 
WHERE RowNumber <= 5;
--> KẾT QUẢ TRẢ VỀ 165 ROWS THỎA MÃN ĐIỀU KIỆN

-- 2.2:
SELECT
    OrderYear,
    OrderMonth,
    EmployeeKey,
    EmployeeFullName,
    EmployeeMonthAmount
FROM (
    SELECT
        YEAR(FRS.OrderDate) AS OrderYear,
        MONTH(FRS.OrderDate) AS OrderMonth,
        FRS.EmployeeKey,
        CONCAT_WS(' ', DE.FirstName, DE.MiddleName, DE.LastName) AS EmployeeFullName,
        SUM(FRS.SalesAmount) AS EmployeeMonthAmount,
        ROW_NUMBER() OVER (PARTITION BY YEAR(FRS.OrderDate), MONTH(FRS.OrderDate) ORDER BY SUM(FRS.SalesAmount) DESC) AS RowNumber
    FROM FactResellerSales AS FRS
    INNER JOIN DimEmployee AS DE ON FRS.EmployeeKey = DE.EmployeeKey
    GROUP BY YEAR(FRS.OrderDate), MONTH(FRS.OrderDate), FRS.EmployeeKey, CONCAT_WS(' ', DE.FirstName, DE.MiddleName, DE.LastName) 
	)
	AS RankEmployeeSales
WHERE RowNumber <= 5;
--> KẾT QUẢ TRẢ VỀ 165 ROWS THỎA MÃN ĐIỀU KIỆN

-- 2.3:
SELECT
    OrderYear,
    OrderMonth,
    EmployeeKey,
    EmployeeFullName,
    EmployeeMonthAmount
FROM (
    SELECT
        YEAR(FRS.OrderDate) AS OrderYear,
        MONTH(FRS.OrderDate) AS OrderMonth,
        FRS.EmployeeKey,
        CONCAT(FirstName, ISNULL(' ' + MiddleName, ''), ' ', LastName) AS EmployeeFullName,
        SUM(FRS.SalesAmount) AS EmployeeMonthAmount,
        ROW_NUMBER() OVER (PARTITION BY YEAR(FRS.OrderDate), MONTH(FRS.OrderDate) ORDER BY SUM(FRS.SalesAmount) DESC) AS RowNumber
    FROM FactResellerSales AS FRS
    INNER JOIN DimEmployee AS DE ON FRS.EmployeeKey = DE.EmployeeKey
    GROUP BY YEAR(FRS.OrderDate), MONTH(FRS.OrderDate), FRS.EmployeeKey, CONCAT(FirstName, ISNULL(' ' + MiddleName, ''), ' ', LastName) 
	) AS RankEmployeeSales
WHERE RowNumber <= 5;
--> KẾT QUẢ TRẢ VỀ 165 ROWS THỎA MÃN ĐIỀU KIỆN

/* b. Mở rộng kết quả câu a, tính toán thêm thông tin về doanh thu cùng kỳ năm ngoái của các nhân viên này.
Kết quả trả về gồm các thông tin sau: OrderYear, OrderMonth, EmployeeKey, EmployeeFullname, EmployeeMonthAmount, EmployeeMonthAmount_LastYear? */

-- CÁCH 1: 
WITH 
RankEmployeeSales AS 
(
    SELECT
        YEAR(FRS.OrderDate) AS OrderYear,
        MONTH(FRS.OrderDate) AS OrderMonth,
        FRS.EmployeeKey,
        CONCAT_WS(' ', DE.FirstName, DE.MiddleName, DE.LastName) AS EmployeeFullName, -- TƯƠNG TỰ CŨNG CÓ NHIỀU CÁCH THỂ HIỆN EmployeeFullName
        SUM(FRS.SalesAmount) AS EmployeeMonthAmount,
        ROW_NUMBER() OVER (PARTITION BY YEAR(FRS.OrderDate), MONTH(FRS.OrderDate) ORDER BY SUM(FRS.SalesAmount) DESC) AS RowNumber
    FROM FactResellerSales AS FRS
    INNER JOIN DimEmployee AS DE ON FRS.EmployeeKey = DE.EmployeeKey
    GROUP BY YEAR(FRS.OrderDate), MONTH(FRS.OrderDate), FRS.EmployeeKey, CONCAT_WS(' ', DE.FirstName, DE.MiddleName, DE.LastName)
),
LastYearEmployeeSales AS
(
    SELECT
        YEAR(OrderDate) - 1 AS LastYear,
        MONTH(OrderDate) AS OrderMonth,
        EmployeeKey,
        SUM(SalesAmount) AS EmployeeMonthAmount_LastYear
    FROM FactResellerSales
    GROUP BY YEAR(OrderDate) - 1, MONTH(OrderDate), EmployeeKey
)
SELECT
    RES.OrderYear,
    RES.OrderMonth,
    RES.EmployeeKey,
    RES.EmployeeFullName,
    RES.EmployeeMonthAmount,
    LY.EmployeeMonthAmount_LastYear
FROM RankEmployeeSales AS RES
LEFT JOIN LastYearEmployeeSales AS LY ON RES.OrderYear = LY.LastYear AND RES.OrderMonth = LY.OrderMonth AND RES.EmployeeKey = LY.EmployeeKey
WHERE RES.RowNumber <= 5;
--> KẾT QUẢ TRẢ VỀ 165 ROWS THỎA MÃN ĐIỀU KIỆN

-- CÁCH 2:
WITH 
RankEmployeeSales AS 
(
    SELECT
        YEAR(FRS.OrderDate) AS OrderYear,
        MONTH(FRS.OrderDate) AS OrderMonth,
        FRS.EmployeeKey,
        CONCAT(FirstName, ISNULL(' ' + MiddleName, ''), ' ', LastName) AS EmployeeFullName, -- TƯƠNG TỰ CŨNG CÓ NHIỀU CÁCH THỂ HIỆN EmployeeFullName
        SUM(FRS.SalesAmount) AS EmployeeMonthAmount,
        ROW_NUMBER() OVER (PARTITION BY YEAR(FRS.OrderDate), MONTH(FRS.OrderDate) ORDER BY SUM(FRS.SalesAmount) DESC) AS RowNumber
    FROM FactResellerSales AS FRS
    INNER JOIN DimEmployee AS DE ON FRS.EmployeeKey = DE.EmployeeKey
    GROUP BY YEAR(FRS.OrderDate), MONTH(FRS.OrderDate), FRS.EmployeeKey, CONCAT(FirstName, ISNULL(' ' + MiddleName, ''), ' ', LastName)
),
LastYearSales AS
(
    SELECT
        RES.OrderYear AS OrderYear_LastYear,
        RES.OrderMonth AS OrderMonth_LastYear,
        RES.EmployeeKey AS EmployeeKey_LastYear,
        SUM(FRS.SalesAmount) AS EmployeeMonthAmount_LastYear
    FROM FactResellerSales AS FRS
    INNER JOIN DimEmployee AS DE ON FRS.EmployeeKey = DE.EmployeeKey
    INNER JOIN RankEmployeeSales AS RES ON YEAR(FRS.OrderDate) = RES.OrderYear - 1 
										AND MONTH(FRS.OrderDate) = RES.OrderMonth 
										AND FRS.EmployeeKey = RES.EmployeeKey
    GROUP BY RES.OrderYear, RES.OrderMonth, RES.EmployeeKey
)
SELECT
    RES.OrderYear,
    RES.OrderMonth,
    RES.EmployeeKey,
    RES.EmployeeFullName,
    RES.EmployeeMonthAmount,
    LY.EmployeeMonthAmount_LastYear
FROM RankEmployeeSales AS RES
LEFT JOIN LastYearSales AS LY ON RES.OrderYear = LY.OrderYear_LastYear 
							AND RES.OrderMonth = LY.OrderMonth_LastYear 
							AND RES.EmployeeKey = LY.EmployeeKey_LastYear
WHERE RES.RowNumber <= 5;
--> KẾT QUẢ TRẢ VỀ 165 ROWS THỎA MÃN ĐIỀU KIỆN

/* Câu 4: Từ bảng FactInternetSales, FactResellerSales, DimProduct, hãy tính tổng doanh thu từ kênh Internet (đặt tên InternetTotalSalesAmount) và tổng doanh thu từ kênh Reseller 
(đặt tên là ResellerTotalSalesAmount) của từng sản phẩm. Đối với những sản phẩm chưa bán được thì hiển thị doanh số bằng 0. 
Kết quả trả về gồm các thông tin sau: ProductKey, EnglishProductName, InternetTotalSalesAmount, ResellerTotalSalesAmount? */

-- CÁCH 1:
SELECT
    DP.ProductKey,
    DP.EnglishProductName,
    COALESCE(InternetSUM.TotalSalesAmount, 0) AS InternetTotalSalesAmount,
    COALESCE(ResellerSUM.TotalSalesAmount, 0) AS ResellerTotalSalesAmount
FROM DimProduct AS DP
LEFT JOIN 
( -- Tạo ra bảng chứa TotalSalesAmount từng sản phẩm của bảng FactInternetSales
    SELECT
        FIS.ProductKey,
        SUM(FIS.SalesAmount) AS TotalSalesAmount
    FROM FactInternetSales AS FIS
    GROUP BY FIS.ProductKey
) 
AS InternetSUM 
	ON DP.ProductKey = InternetSUM.ProductKey
LEFT JOIN 
( -- Tạo ra bảng chứa TotalSalesAmount từng sản phẩm của bảng FactResellerSales
    SELECT
        FRS.ProductKey,
        SUM(FRS.SalesAmount) AS TotalSalesAmount
    FROM FactResellerSales AS FRS
    GROUP BY FRS.ProductKey
) 
AS ResellerSUM 
	ON DP.ProductKey = ResellerSUM.ProductKey;
--> KẾT QUẢ TRẢ VỀ 606 ROWS THỎA MÃN ĐIỀU KIỆN

-- CÁCH 2:
SELECT
    DP.ProductKey,
    DP.EnglishProductName,
    ISNULL(InternetSUM.TotalSalesAmount, 0) AS InternetTotalSalesAmount,
    ISNULL(ResellerSUM.TotalSalesAmount, 0) AS ResellerTotalSalesAmount
FROM DimProduct AS DP
LEFT JOIN 
( -- Tạo ra bảng chứa TotalSalesAmount từng sản phẩm của bảng FactInternetSales
    SELECT
        FIS.ProductKey,
        SUM(FIS.SalesAmount) AS TotalSalesAmount
    FROM FactInternetSales AS FIS
    GROUP BY FIS.ProductKey
) 
AS InternetSUM 
	ON DP.ProductKey = InternetSUM.ProductKey
LEFT JOIN 
( -- Tạo ra bảng chứa TotalSalesAmount từng sản phẩm của bảng FactResellerSales
    SELECT
        FRS.ProductKey,
        SUM(FRS.SalesAmount) AS TotalSalesAmount
    FROM FactResellerSales AS FRS
    GROUP BY FRS.ProductKey
) 
AS ResellerSUM 
	ON DP.ProductKey = ResellerSUM.ProductKey;
--> KẾT QUẢ TRẢ VỀ 606 ROWS THỎA MÃN ĐIỀU KIỆN

-- CÁCH 3:
WITH InternetSUM AS (
    SELECT
        FIS.ProductKey,
        SUM(FIS.SalesAmount) AS TotalSalesAmount
    FROM FactInternetSales AS FIS
    GROUP BY FIS.ProductKey
),
ResellerSUM AS (
    SELECT
        FRS.ProductKey,
        SUM(FRS.SalesAmount) AS TotalSalesAmount
    FROM FactResellerSales AS FRS
    GROUP BY FRS.ProductKey
)
SELECT
    DP.ProductKey,
    DP.EnglishProductName,
    COALESCE(InternetSUM.TotalSalesAmount, 0) AS InternetTotalSalesAmount,
    COALESCE(ResellerSUM.TotalSalesAmount, 0) AS ResellerTotalSalesAmount
FROM DimProduct AS DP
LEFT JOIN InternetSUM ON DP.ProductKey = InternetSUM.ProductKey
LEFT JOIN ResellerSUM ON DP.ProductKey = ResellerSUM.ProductKey;

-- I sincerely appreciate the time you took to review my exam. Thank you!