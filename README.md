# StoreMate E2E Tests (Robot Framework)

ชุดทดสอบอัตโนมัติของ StoreMate ส่วนดูและค้นหาสินค้า (ไม่ต้องเข้าสู่ระบบ) เขียนด้วย **Robot Framework + Browser library**
(robotframework-browser ทำงานบน Playwright) ตรงกับโปรเจกต์ `../playwright` ทุกข้อ และเอกสาร **StoreMate-Test-Cases.docx** ฉบับ 3.0
รวม **38 Test Case ใน 3 User Story** ชื่อเทสมีรหัสเดิมจากเอกสารในวงเล็บ (ถ้ามี) เช่น `TC-03-01 (TC5001) แสดงรายการสินค้าตามหมวดหมู่`

## ติดตั้ง

ต้องมี Python 3.9+ และ Node.js 18+

```bash
pip install -r requirements.txt
rfbrowser init chromium
copy .env.example .env
```

ถ้าเรียก `rfbrowser` ไม่ได้ ให้ใช้ `python -m Browser.entry init chromium` แทน (และใช้ `python -m robot` แทน `robot`)

ไม่ต้องใช้บัญชีผู้ใช้ ค่าใน `.env` มีแค่ `BASE_URL` และ `PRODUCT_ID` ถ้าไม่มี `Robot/.env` จะอ่านจาก `../playwright/.env`

## รันเทส

| คำสั่ง | ทำอะไร |
|---|---|
| `robot -d results tests` | รันทั้งหมด (38 เทส) |
| `robot -d results tests/guest/04_search.robot` | รันทีละไฟล์ |
| `robot -d results --test "TC-04-09*" tests` | รันเทสเดียวตามรหัส |
| `robot -d results --include US-05 tests` | รันตาม User Story (tag) |
| `robot -d results --include negative tests` | รันเฉพาะกรณี Negative |
| `robot -d results -v HEADLESS:False tests` | เปิดเบราว์เซอร์ให้เห็นหน้าจอ |
| `robot --dryrun tests` | ตรวจไวยากรณ์โดยไม่เปิดเบราว์เซอร์ |

ผลลัพธ์อยู่ที่ `results/report.html` และ `results/log.html` (มีภาพหน้าจอเมื่อเทสไม่ผ่าน)

Tag ที่ใช้ได้: `US-03`, `US-04`, `US-05`, `TS-03-01`…, `positive`, `negative`, `guest`

## โครงสร้าง

```
resources/config.py              ค่าตั้งค่า (อ่าน .env) และข้อความแจ้งเตือน (&{MSG})
resources/StoreMateLibrary.py    keyword Python: To Number, Price From Text ฯลฯ
resources/common.resource        เปิดเบราว์เซอร์, ตรวจ toast
resources/shop.resource          เปิดสินค้า, อ่านสต็อก/จำนวน
resources/storemate.resource     รวมทุก resource (ไฟล์เทส import ไฟล์นี้ไฟล์เดียว)
tests/guest/                     US-03 – US-05
```

| ไฟล์ | User Story | Test Case | จำนวน |
|---|---|---|---|
| guest/03_product_list.robot | US-03 ดูรายการสินค้า | TC-03-01 – TC-03-12 | 12 |
| guest/04_search.robot | US-04 ค้นหาและกรองสินค้า | TC-04-01 – TC-04-18 | 18 |
| guest/05_product_detail.robot | US-05 ดูรายละเอียดสินค้า | TC-05-01 – TC-05-08 | 8 |

## ข้อควรรู้

- **เทสอ่านอย่างเดียว** ไม่สร้างบัญชี ไม่ใส่รถเข็น ไม่สั่งซื้อ จึงรันซ้ำได้ไม่กระทบข้อมูล
- **สินค้าต้องพร้อมขาย:** ค่าเริ่มต้นคือ 53 (สินค้า 28, 30 สต็อกหมด ณ 11/10/2569)
- **เทสที่จะถูก Skip ถ้าข้อมูลไม่พร้อม:** TC-03-02 (ทุกหมวดมีสินค้า), เทสสินค้าสต็อกหมด (ตอนนั้นไม่มีสินค้าหมด), เทสเพิ่ม/ลดจำนวน (สต็อกน้อยกว่า 3)
- ไฟล์ `address.resource`, `order.resource` และ `fixtures/` ยังอยู่จากชุดเดิม ไม่มีเทสใช้แล้ว

## เทสที่นำออก

ชุดเดิม (US-01 สมัครสมาชิก, US-02 เข้าสู่ระบบ, US-06 – US-08 รถเข็น, กรณีบัญชีใหม่) ถูกนำออกเพื่อให้เหลือเฉพาะ US-03 – US-05
ดูโค้ดเดิมได้จากประวัติ git (`git show HEAD:tests/...`) หรือไฟล์สำรอง `../backup-before-03-04-05.zip`
