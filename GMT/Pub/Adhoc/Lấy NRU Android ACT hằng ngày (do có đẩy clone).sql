-- NRU ANDROID: ĐANG CHÊNH SỐ CLONE

WITH A AS 
(
SELECT distinct *
FROM
  `gamotasdk5.bidata.register_logs`
WHERE game_id = '180941' and app_id = 212251
and date >= "2023-04-27"
), 
B AS 
(
SELECT distinct *
FROM
  `gamotasdk5.bidata.appsflyer_login_postback`
WHERE game_id = '180941' and app_id = 212251
and date >= "2023-04-27"
)
SELECT a.date, count (distinct a.user_id) as users
FROM A 
LEFT JOIN B 
ON (A.date = B.date AND A.USER_ID = B.USER_ID AND A.APP_ID = B.APP_ID)
WHERE a.game_id = '180941' and a.app_id = 212251
--group by a.date; -- Lấy tổng NRU thôi
and device_id  in (
 '98135605-ff41-44a1-b764-f1256dd13135'  --gmo-646acc62cfc1af2bbc466b04
,'76d1434c-9905-4736-bcce-3cbac0878692' --gmo-643f74e29d5e0515c1605631
,'b3e6b703-d32a-487c-b859-9b16b4891ef5' --gmo-6459fa4acf75462ba9bfaf58
,'ebc6653e-db85-48a6-bba7-819922a17af2' --gmo-645f0d2c86f3e914f82c97e3
,'eb5d1d80-1d51-4a53-b784-8175a935c711' --gmo-646f0cfd65be27231eba4d95
,'f4d2858d-87ae-4e6a-8e4a-6c6f370f48f5' --gmo-646b1dcc67287128be1bdb3f
,'4721fa11-c2dc-41cd-97b3-0d046bf7049b' --gmo-64e45e9b60e9bd0fb5e3e826
,'33dda61b-9eb2-47f2-b71f-ea1280c73cda' --gmo-646b1e4453e465278c9f982c
,'11680c00-9955-4b1d-bcd0-b558b1c60da3' --gmo-646c9add17a3971b3f3c1b2d
,'9dbd877c-29c5-40e0-8f89-19a45bdecb15'
,'98135605-ff41-44a1-b764-f1256dd13135'
,'23e20a86-ff7a-4cc3-95f7-aec465a22883'
)
-- AND campaign_type = "organic" -- điều kiện là user organic (chưa chắc)
group by a.date;

-- Xử lý những trường hợp device_id null: 
-- TH1: bản ghi có ở cả 2 bảng nhưng divece null thì là do chưa tracking được (chưa rõ nguyên nhân)
-- TH2: bản ghi có ở bẳng A nhưng không có ở bảng B?? -> có là NRU nhưng không có log login là sao huhu
WITH A AS 
(
SELECT distinct *
FROM
  `gamotasdk5.bidata.register_logs`
WHERE game_id = '180941' and app_id = 212251
and user_id = 66682676
-- Có thông tin tạo tk
), 
B AS 
(
SELECT distinct *
FROM
  `gamotasdk5.bidata.appsflyer_login_postback`
WHERE game_id = '180941' and app_id = 212251
and user_id = 66682676
-- Nhưng không có thông tin login
)
SELECT distinct a.user_id, a.date, a.user_id, a.game_id, a.server_id, b.platform, b.media_source, b.device_id, b.appsflyer_id, b.city
FROM A 
left JOIN B 
ON (A.date = B.date AND A.USER_ID = B.USER_ID AND A.APP_ID = B.APP_ID)
WHERE a.game_id = '180941' and a.app_id = 212251
and device_id  is null;

-- Check số lượng user quay trở lại theo ngày:
WITH A AS 
(
SELECT distinct *
FROM
  `gamotasdk5.bidata.register_logs`
WHERE game_id = '180941' and app_id = 212251
AND Date = "2023-05-13"
), 
B AS (
SELECT *
FROM
  `gamotasdk5.bidata.appsflyer_login_postback`
WHERE game_id = '180941' and app_id = 212251
AND DATE = "2023-05-14"
)
SELECT DISTINCT(A.USER_ID), A.DATE
FROM A INNER JOIN B 
ON A.USER_ID = B.USER_ID;

----------------------------------------------------------------------------------
-- NRU IOS: ĐÚNG RỒI
SELECT COUNT(distinct USER_ID) AS USER, DATE
FROM
  `gamotasdk5.bidata.register_logs`
WHERE app_id = 200421
and date >= '2023-06-1'
GROUP BY DATE;

