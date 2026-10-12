# -*- coding: utf-8 -*-
"""Keyword ช่วยงานที่เขียนด้วย Python (สร้างข้อมูลทดสอบ, แปลงตัวเลข)"""
import random
import re
import time


class StoreMateLibrary:
    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def unique_user(self, prefix="qa"):
        """คืนค่า dict ผู้ใช้ใหม่: name, email, phone (09 + 8 หลัก), password"""
        stamp = f"{int(time.time() * 1000)}{random.randint(0, 999):03d}"
        return {
            "name": "สมชาย ใจดี",
            "email": f"{prefix}.{stamp}@storemate-test.com",
            "phone": f"09{stamp[-8:]}",
            "password": "Test1234",
        }

    def to_number(self, text):
        """ดึงตัวเลขจากข้อความ เช่น '฿ 1,200' -> 1200"""
        digits = re.sub(r"[^\d.]", "", str(text or ""))
        if not digits:
            return 0
        value = float(digits)
        return int(value) if value.is_integer() else value

    def price_from_text(self, text):
        """ราคาแรกที่อยู่หลัง ฿ ในข้อความ"""
        match = re.search(r"฿\s*([\d,]+(?:\.\d+)?)", str(text))
        return self.to_number(match.group(1)) if match else 0

    def street_of(self, address_text):
        """ตัดส่วนบ้านเลขที่/ถนน ออกจาก 'street ต.xxx อ.yyy จ.zzz 12345'"""
        return str(address_text).split(" ต.")[0].strip()

    def timestamp(self):
        return str(int(time.time() * 1000))
