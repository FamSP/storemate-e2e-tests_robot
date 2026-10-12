# StoreMate E2E Tests (Robot Framework)

ชุดทดสอบอัตโนมัติฟังก์ชันฝั่งลูกค้าของ StoreMate เขียนด้วย **Robot Framework + Browser library**
(robotframework-browser ทำงานบน Playwright) แปลงมาจากโปรเจกต์ `../playwright` ครบ 101 Test Case (US-01 ถึง US-20)
ชื่อเทสมีรหัสใหม่และรหัสเดิม เช่น `TC-01-01 (TC1001) สมัครสมาชิกสำเร็จ`

## ติดตั้ง

ต้องมี Python 3.9+ และ Node.js 18+

```bash
pip install -r requirements.txt
rfbrowser init chromium
copy .env.example .env
```

ถ้าเรียก `rfbrowser` ไม่ได้ ให้ใช้ `python -m Browser.entry init chromium` แทน

แก้ค่าใน `.env` (บัญชีลูกค้า สินค้าที่ใช้ทดสอบ ฯลฯ) ถ้าไม่มี `Robot/.env` จะอ่านจาก `../playwright/.env`

## รันเทส

| คำสั่ง | ทำอะไร |
|---|---|
| `robot -d results tests` | รันทั้งหมด |
| `robot -d results tests/guest` | เฉพาะเทสที่ไม่ต้องเข้าสู่ระบบ |
| `robot -d results tests/customer` | เฉพาะเทสบัญชีลูกค้าหลัก |
| `robot -d results tests/fresh` | เฉพาะเทสที่สมัครบัญชีใหม่ขึ้นมาใช้ |
| `robot -d results --test "TC-16-01*" tests` | รันเทสเดียวตามรหัส |
| `robot -d results --include US-07 tests` | รันตาม User Story (tag) |
| `robot -d results --include negative tests` | รันเฉพาะกรณี Negative |
| `robot -d results -v HEADLESS:False tests` | เปิดเบราว์เซอร์ให้เห็นหน้าจอ |
| `robot --dryrun tests` | ตรวจไวยากรณ์โดยไม่เปิดเบราว์เซอร์ |

ผลลัพธ์อยู่ที่ `results/report.html` และ `results/log.html` (มีภาพหน้าจอเมื่อเทสไม่ผ่าน)

Tag ที่ใช้ได้: `US-01`…`US-20`, `TS-01-01`…, `positive`, `negative`, `guest`, `customer`, `fresh`, `partial-manual`

## โครงสร้าง

```
resources/config.py              ค่าตั้งค่า (อ่าน .env) และข้อความแจ้งเตือนทั้งหมด (&{MSG})
resources/StoreMateLibrary.py    keyword Python: Unique User, To Number, Price From Text, Street Of
resources/common.resource        เปิดเบราว์เซอร์, เข้าสู่ระบบ, สมัครสมาชิก, ตรวจ toast
resources/shop.resource          สินค้าและรถเข็น
resources/address.resource       ที่อยู่จัดส่ง
resources/order.resource         สั่งซื้อ, ชำระเงิน, คำสั่งซื้อ, ยกเลิก
resources/storemate.resource     รวมทุก resource (ไฟล์เทส import ไฟล์นี้ไฟล์เดียว)
tests/guest/                     US-01 ถึง US-05 และกรณียังไม่เข้าสู่ระบบ
tests/customer/                  US-06 ถึง US-20
tests/fresh/                     กรณีบัญชีว่าง และการเปลี่ยนอีเมล
fixtures/images/                 ไฟล์รูปสำหรับเทสอัปโหลด
```

| ไฟล์ | Test Case |
|---|---|
| guest/01_register.robot | TC-01-01 – TC-01-15 |
| guest/02_login.robot | TC-02-01 – TC-02-04 |
| guest/03_product_list.robot | TC-03-01 – TC-03-02 |
| guest/04_search.robot | TC-04-01 – TC-04-05 |
| guest/05_product_detail.robot | TC-05-01 |
| guest/06_cart_guest.robot | TC-06-02, TC-07-08 |
| customer/06_add_to_cart.robot | TC-06-01, TC-06-03, TC-06-04 |
| customer/07_manage_cart.robot | TC-07-01 – TC-07-07 |
| customer/08_view_cart.robot | TC-08-01 – TC-08-05 |
| customer/09_10_profile.robot | TC-09-01, TC-10-01, TC-10-03 – TC-10-09 |
| customer/11_14_address.robot | TC-11-01, TC-12-01, TC-12-02, TC-13-01, TC-13-02, TC-14-01, TC-14-02 |
| customer/15_16_order_payment.robot | TC-15-01 – TC-15-04, TC-16-01 – TC-16-09 |
| customer/17_18_orders.robot | TC-17-01, TC-17-02, TC-17-04 – TC-17-10, TC-18-01 – TC-18-03 |
| customer/19_20_notify_cancel.robot | TC-19-01 – TC-19-07, TC-20-01 – TC-20-03 |
| fresh/fresh_account.robot | TC-10-02, TC-11-02, TC-14-03, TC-14-04, TC-17-03, TC-19-08 |

## การทำงาน

- **บัญชีลูกค้า:** แต่ละ suite ใน `tests/customer` เข้าสู่ระบบครั้งเดียวใน Suite Setup (`Prepare Customer Session`) เก็บ session ไว้ แล้วทุกเทสเปิด context ใหม่ด้วย session นั้น
- **ล้างข้อมูล:** เทสรถเข็นล้างรถเข็นก่อนทุกเทส เทสที่อยู่ลบที่อยู่ที่มีคำว่า `QA-` ตอนจบ suite
- **iframe ของ Stripe:** ใช้ตัวเลือก `... iframe >>> css=input[name="cardnumber"]`
- **QR หมดอายุ (TC-16-09):** เลื่อน `Date.now()` ของหน้าเว็บไป 31 นาทีด้วย JavaScript จึงไม่ต้องรอจริง

## ข้อควรรู้

- **ข้อมูลจริงจะเปลี่ยน:** เทสสั่งซื้อ/ชำระเงินสร้างคำสั่งซื้อจริงและตัดสต็อก `PRODUCT_ID` เทส guest/fresh สมัครบัญชีใหม่ (`@storemate-test.com`)
- **สินค้าต้องพร้อมขาย:** ค่าเริ่มต้นคือ 53 และ 64 (สินค้า 28, 30 สต็อกหมด ณ 11/10/2569)
- **เทสที่จะถูก Skip ถ้าข้อมูลไม่พร้อม:** TC-02-03 (ไม่มี `SUSPENDED_EMAIL`), TC-03-02 (ทุกหมวดมีสินค้า), TC-06-03/06-04/07-04 (สต็อกเกิน 150), TC-08-05 (ไม่มี `UNAVAILABLE_PRODUCT_ID`), TC-17-06/07/08/10 (ไม่มีคำสั่งซื้อสถานะนั้น)
- **TC-12-01:** ถ้าที่อยู่ใหม่ไม่เป็นค่าเริ่มต้นตามเอกสาร จะขึ้น WARN ใน log แต่ไม่ทำให้เทสตก
- **ความต่างจากเอกสาร** ดู README ของโปรเจกต์ `../playwright` (หัวข้อ "สิ่งที่เทสพบว่าต่างจากเอกสาร")
