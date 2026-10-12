# -*- coding: utf-8 -*-
"""Robot variable file: ค่าตั้งค่าและข้อความแจ้งเตือนของ StoreMate

อ่านค่าจาก Robot/.env (ถ้าไม่มีจะใช้ ../playwright/.env ของโปรเจกต์ Playwright)
"""
import os
from pathlib import Path

try:
    from dotenv import load_dotenv

    _root = Path(__file__).resolve().parent.parent
    for _env in (_root / ".env", _root.parent / "playwright" / ".env"):
        if _env.exists():
            load_dotenv(_env)
            break
except ImportError:  # python-dotenv ไม่ได้ติดตั้ง ใช้ environment variables อย่างเดียว
    pass


def _env(key, default=""):
    return (os.getenv(key) or default).strip()


ROOT = str(Path(__file__).resolve().parent.parent)
BASE_URL = _env("BASE_URL", "https://storemate-final.vercel.app").rstrip("/")
HEADLESS = _env("HEADLESS", "true").lower() != "false"
AUTH_FILE = str(Path(ROOT) / "results" / "auth" / "customer.json")
IMAGES = str(Path(ROOT) / "fixtures" / "images")

CUSTOMER_EMAIL = _env("CUSTOMER_EMAIL", "customer@test.com")
CUSTOMER_PASSWORD = _env("CUSTOMER_PASSWORD", "Customer1234")
SUSPENDED_EMAIL = _env("SUSPENDED_EMAIL")
SUSPENDED_PASSWORD = _env("SUSPENDED_PASSWORD")
EXISTING_EMAIL = _env("EXISTING_EMAIL")
EXISTING_PHONE = _env("EXISTING_PHONE")

PRODUCT_ID = _env("PRODUCT_ID", "53")
SECOND_PRODUCT_ID = _env("SECOND_PRODUCT_ID", "64")
UNAVAILABLE_PRODUCT_ID = _env("UNAVAILABLE_PRODUCT_ID")

CARD_NUMBER = _env("TEST_CARD_NUMBER", "4242424242424242")
CARD_EXPIRY = _env("TEST_CARD_EXPIRY", "12/30")
CARD_CVC = _env("TEST_CARD_CVC", "123")
CARD_NAME = "SOMCHAI JAIDEE"
VALID_PASSWORD = "Test1234"

# ข้อความจากโค้ดหน้าเว็บ ค่าที่ขึ้นต้นและลงท้ายด้วย / เป็น regex (ใช้กับ text=/.../ ของ Playwright)
DICT__MSG = {
    "registerSuccess": "ลงทะเบียนสำเร็จ",
    "requiredName": "กรุณากรอกชื่อ-นามสกุล",
    "requiredEmail": "กรุณากรอกอีเมล",
    "requiredPhone": "กรุณากรอกเบอร์โทรศัพท์",
    "requiredPassword": "กรุณากรอกรหัสผ่าน",
    "requiredConfirm": "กรุณายืนยันรหัสผ่าน",
    "invalidEmail": "กรุณากรอกอีเมลให้ถูกต้อง",
    "invalidPhone": "เบอร์โทรต้องขึ้นต้นด้วย 0 และมี 10 หลัก",
    "pwMin": "รหัสผ่านต้องมีความยาวอย่างน้อย 8 ตัวอักษร",
    "pwUpper": "รหัสผ่านต้องมีตัวพิมพ์ใหญ่อย่างน้อย 1 ตัวอักษร",
    # ในโค้ดสะกดว่า "ตัวตัวพิมพ์เล็ก" (คำซ้ำ) จึงรับทั้งสองแบบ
    "pwLower": "/รหัสผ่านต้องมีตัว(ตัว)?พิมพ์เล็กอย่างน้อย 1 ตัวอักษร/",
    "pwDigit": "รหัสผ่านต้องมีตัวเลขอย่างน้อย 1 ตัวเลข",
    "pwMismatch": "รหัสผ่านและยืนยันรหัสผ่านไม่ตรงกัน",
    "duplicateEmail": "/อีเมลนี้ถูกใช้งานแล้ว|Exist by email/i",
    "duplicatePhone": "/เบอร์โทรศัพท์นี้มีผู้ใช้แล้ว|Exist by phone/i",
    "loginSuccess": "เข้าสู่ระบบสำเร็จ",
    "loginInvalid": "อีเมลหรือรหัสผ่านไม่ถูกต้อง",
    "loginSuspended": "บัญชีนี้ถูกระงับการใช้งาน",
    "loginIncomplete": "กรุณากรอกข้อมูลให้ครบถ้วน",
    "emptyCategory": "ไม่พบรายการสินค้า",
    "searchNotFound": "ไม่พบสินค้าที่คุณค้นหา",
    "addedToCart": "เพิ่มสินค้าเข้ารถเข็นเรียบร้อยแล้ว",
    "loginBeforeCart": "กรุณาเข้าสู่ระบบก่อนเพิ่มสินค้าลงรถเข็น",
    "alreadyInCart": "/ไม่สามารถเพิ่มจำนวนสินค้าได้ เนื่องจากคุณเพิ่มสินค้านี้ไว้ในรถเข็นแล้ว \\d+ ชิ้น/",
    "cartStockLimit": "ขออภัย สินค้าชิ้นนี้มีจำนวนจำกัดในคลังไม่สามารถเพิ่มได้",
    "confirmRemoveItem": "คุณต้องการลบสินค้านี้ใช่หรือไม่?",
    "confirmRemoveAll": "คุณต้องการลบสินค้าทั้งหมดนี้ใช่หรือไม่?",
    "itemRemoved": "ลบสินค้าแล้ว",
    "itemsRemoved": "ลบสินค้าสำเร็จ",
    "selectItemFirst": "กรุณาเลือกสินค้าก่อน",
    "emptyCart": "ไม่มีสินค้าในรถเข็น",
    "unavailable": "ไม่พร้อมจำหน่าย",
    "comingSoon": "สินค้าจะมีเร็วๆนี้",
    "profileSaved": "แก้ไขข้อมูลโปรไฟล์สำเร็จ",
    "fileTooLarge": "ขนาดไฟล์ต้องไม่เกิน 5 MB",
    "fileType": "รองรับเฉพาะไฟล์ PNG, JPEG และ JPG",
    "noAddress": "ไม่มีข้อมูลที่อยู่ของคุณ",
    "addressAdded": "เพิ่มที่อยู่สำเร็จ",
    "addressEdited": "แก้ไขที่อยู่สำเร็จ",
    "addressDeleted": "ลบที่อยู่สำเร็จ",
    "addressDefault": "ตั้งค่าที่อยู่เริ่มต้นสำเร็จ",
    "addressRequired": "กรุณากรอกข้อมูลให้ครบถ้วน",
    "lastAddress": "ไม่สามารถลบได้ เนื่องจากต้องมีที่อยู่เริ่มต้นอย่างน้อย 1 รายการ",
    "confirmDeleteAddress": "คุณต้องการลบที่อยู่นี้ใช่หรือไม่?",
    "orderSuccess": "คำสั่งซื้อสำเร็จ",
    "selectPayment": "กรุณาเลือกช่องทางการชำระเงิน",
    "cardNameLetters": "กรุณากรอกชื่อผู้ถือบัตรเป็นตัวอักษรเท่านั้น",
    "cardIncomplete": "กรุณากรอกหมายเลขบัตรให้ครบ",
    "cardExpiry": "วันหมดอายุไม่ถูกต้อง กรุณาตรวจสอบข้อมูลอีกครั้ง",
    "qrExpired": "QR Code หมดอายุการใช้งาน",
    "noOrders": "ยังไม่มีรายการคำสั่งซื้อ",
    "noNotification": "ไม่มีการแจ้งเตือนในหมวดหมู่นี้",
    "cancelSuccess": "ส่งคำขอยกเลิกสำเร็จ",
    "cancelReasonRequired": "กรุณาเลือกเหตุผลในการยกเลิกคำสั่งซื้อ",
}

# แท็บสถานะในหน้า "การซื้อของฉัน" (/orders?status=...)
DICT__ORDER_STATUS = {
    "ALL": "ทั้งหมด",
    "COMPLETED": "คำสั่งซื้อสำเร็จ",
    "PENDING": "ที่ต้องชำระ",
    "PROCESSING": "ที่ต้องจัดส่ง",
    "RECEIVED": "ที่ต้องได้รับ",
    "CANCELLED": "ยกเลิก",
    "REFUNDED": "คืนเงิน",
}

DICT__NOTIFY_FILTERS = {"ALL": "ทั้งหมด", "ORDERED": "คำสั่งซื้อ", "REFUNDED": "คำขอคืนเงิน", "STORE": "ร้านค้า"}
