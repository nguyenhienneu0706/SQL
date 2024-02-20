with get_device as 
(
select
  distinct (device_id) as device_id,
  min(date(event_time)) as fdate
from
  `gamotasdk5.bidata.appsflyer_login_postback`
where 
  app_id = 212251
  and device_id  not in (
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
group by device_id
)
select count (distinct get_device.device_id) as no_device, fdate
from get_device
where fdate >= "2023-09-01"
group by fdate
