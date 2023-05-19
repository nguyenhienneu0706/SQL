--Buổi 1: CẤU TRÚC TRUY VẤN CƠ BẢN
--Database: Là CSDL chứa các bảng dữ liệu có mối liên hệ với nhau 
---> giúp cho việc lưu dữ liệu có tính nhất quán, hỗ trợ tìm kiếm nhanh các bảng
--Table: Bắt buộc có cột (trường thông tin) và hàng (bản ghi)
--Dữ liệu có cấu trúc: Lưu trữ dưới dạng bảng có các cột và hàng (trọng tâm)
--Dữ liệu bán cấu trúc: Email, Messenger, ...
--Dữ liệu phi cấu trúc: Video, Record, ...
Select 5%2
Select 5*2
--Tạo và xóa Database
----Cú pháp: TẠO DATABASE TÊN_CỦA_DB
CREATE DATABASE DB_NAME 
CREATE DATABASE GEN2;
----Cú pháp: XÓA DATABASE TÊN_CỦA_DB
DROP DATABASE DB_NAME
DROP DATABASE GEN2;
--Tạo và xóa bảng:
---Cú pháp: TẠO BẢNG
CREATE TABLE TABLE_NAME
(COL1 TYPE1,
COL2 TYPE2,
COL3 TYPE3)
--Thực hành: Tạo bảng trong DB GEN2 gồm các cột: ID (số nguyên); tuổi (số nguyên); name (nvarchar)
USE GEN2 
GO
CREATE TABLE STUDENTS
(ID INT,
NAME NVARCHAR,
AGE INT)
DROP TABLE STUDENTS
--THAY ĐỔI TRONG BẢNG:
--Thêm cột vào bảng: THÊM CLASS DẠNG VARCHAR VÀO BẢNG STUDENTS
ALTER TABLE STUDENTS
ADD CLASS VARCHAR;
--Xóa cột ở bảng: XÓA CLASS DẠNG VARCHAR VÀO BẢNG STUDENTS
ALTER TABLE STUDENTS
DROP COLUMN CLASS;
--Mệnh đề: SELECT FORM
--HIỂN THỊ CÁC CỘT TRONG BẢNG DỮ LIỆU TRONG DB
--THỰC HÀNH: HIỂN THỊ DỮ LIỆU CỦA TẤT CẢ CÁC TRƯỜNG THÔNG TIN TỪ BẢNG ORDER
SELECT * FROM Orders;
--HIỂN THỊ MỘT SỐ CỘT TÙY CHỌN TỪ BẢNG:
SELECT COL1, COL2, COL3 FROM TABLE_NAME
--THỰC HÀNH: VIẾT CÂU TRUY VẤN HIỂN THỊ DỮ LIỆU CỦA CỘT ORDER_ID, ORDER_DATE, VALUE, PROFIT TỪ BẢNG ORDERS
SELECT ORDER_ID, ORDER_DATE, VALUE, PROFIT FROM ORDERS
--CHUYỂN TÊN CỘT TRONG SQL: AS
SELECT 
COL1 AS NEW_NAME_COL1,
COL2 AS NEW_NAME_COL2,
COL3 AS NEW_NAME_COL3
FROM TABLE_NAME
--THỰC HÀNH: VIẾT CÂU TRUY VẤN BẢNG KQ GỒM MA_DON_HANG, NGAY_DAT_HANG,
SELECT 
ID AS MA_DON_HANG,
ORDER_DATE AS NGAY_DAT_HANG,
VALUE AS GIA_TRI,
PROFIT AS LOI_NHUAN
FROM ORDERS;
--LƯU Ý: NẾU MUỐN ĐẶT TÊN CÓ DẤU CÁCH Ở GIỮA CÁC KÝ TỰ THÌ DÙNG DẤU [] HOẶC ""
--THỰC HÀNH: "LOI_NHUAN" HOẶC [LOI_NHUAN]
SELECT 
ID AS "MÃ ĐƠN HÀNG",
ORDER_DATE AS NGAY_DAT_HANG,
VALUE AS GIA_TRI,
PROFIT AS LOI_NHUAN
FROM ORDERS;
--TẠO CỘT MỚI KHI GHÉP HAI CỘT (VÍ DỤ CỘT HỌ + TÊN = HỌ TÊN)
---> SỬ DỤNG TOÁN TỬ TRONG MỆNH ĐỀ SELECT ĐỂ HIỆN THỊ THÊM CÁC CỘT MỚI
SELECT CÁC CỘT CÓ SẴN,
"TÍNH TOÁN" AS TÊN CỘT
FROM TABLE_NAME
--THỰC HÀNH: TRUY VẤN BẢNG KQ GỒM CÁC CỘT:
---order_id, order_date, order_quantity, value, profit , revenue từ bảng Orders. Trong đó:
--Revenue được tính bằng công thức: order_quantity* unit_price*(1- discount)--Revenucount)
SELECT 
order_id, 
order_date, 
order_quantity, 
value, 
profit,
order_quantity * unit_price * (1- discount) AS REVANUE
FROM ORDERS;
--HIỂN THỊ N DÒNG ĐẦU TIÊN CỦA MỘT SỐ CỘT:
SELECT TOP N COL1 COL2 COL3 FROM TABLE_NAME;
--HIỂN THỊ N% SỐ DÒNG ĐẦU TIÊN CỦA MỘT SỐ CỘT:
SELECT TOP N PERCENT COL1 COL2 COL3 FROM TABLE_NAME;
--THỰC HÀNH: HIỂN THỊ TOP 10 DÒNG ĐẦU TIÊN CỦA DỮ LIỆU TẤT CẢ CÁC CỘT TỪ BẢNG ORDERS
SELECT TOP 10 * FROM ORDERS;
--XEM SỐ LƯỢNG 1% SỐ DÒNG:
SELECT TOP 1 PERCENT * FROM ORDERS;
--BTVN: LÀM BTVN TRONG SLIDE BUỔI 1 VÀ 2 (BUỔI 1).
