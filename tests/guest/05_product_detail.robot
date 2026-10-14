*** Settings ***
Documentation       US-05 ดูรายละเอียดสินค้า (UC-05) — ชุดหลัก + ชุดเพิ่มเติม รวมในไฟล์เดียว
...                 ชุดเพิ่มเติมไม่มีในเอกสารเดิม จึงใช้ป้าย (เพิ่มเติม) แทนรหัสเดิม
Resource            ../../resources/storemate.resource
Suite Setup         Open StoreMate Browser
Suite Teardown      Close Browser
Test Setup          Open Guest Page
Test Teardown       Close Context
Test Tags           US-05    guest


*** Variables ***
${COMING_SOON}      สินค้าจะมีเร็วๆนี้


*** Test Cases ***
# ---------- ชุดหลัก (ตามเอกสาร) ----------
TC-05-01 (TC7001) เข้าหน้ารายละเอียดสินค้าจากหน้ารายการสินค้า
    [Documentation]    TS-05-01 เปิดหน้ารายละเอียดสินค้าและแสดงข้อมูลครบ
    [Tags]    TS-05-01    positive
    Go To Path    /
    # เลือกสินค้าที่พร้อมขาย (การ์ดที่ไม่มีป้าย "สินค้าจะมีเร็วๆนี้")
    ${card}=    Set Variable    css=[data-test="product-card"]:not(:has-text("${COMING_SOON}")) >> nth=0
    Wait For Elements State    ${card}    visible
    ${href}=    Get Attribute    ${card}    href
    ${card_text}=    Get Text    ${card}
    Click    ${card}

    Wait Until Keyword Succeeds    15s    500ms    Url Should Match    ${href}$
    ${name}=    Get Text    css=[data-test="product-name"]
    ${name}=    Strip String    ${name}
    Should Contain    ${card_text}    ${name}[:15]    # ชื่อบนการ์ดตรงกับชื่อในหน้ารายละเอียด
    Wait For Elements State    css=img >> nth=0    visible    # รูปภาพ
    Wait For Elements State    text=/฿\\s*[\\d,]+/ >> nth=0    visible    # ราคา
    Wait For Elements State    text=/มีสินค้าทั้งหมด\\s*\\d+\\s*ชิ้น/    visible    # สต็อก
    Wait For Elements State    css=[data-test="btn-add-to-cart"]    visible
    Wait For Elements State    css=[data-test="btn-buy-cart"]    visible

# ---------- ชุดเพิ่มเติม ----------
TC-05-02 (เพิ่มเติม) จำนวนเริ่มต้นเป็น 1 และปุ่ม − กดไม่ได้
    [Tags]    TS-05-02    positive
    Open Product    ${PRODUCT_ID}
    ${qty}=    Read Buy Quantity
    Should Be Equal As Numbers    ${qty}    1
    Get Element States    css=[data-test="btn-decrease"]    contains    disabled
    Get Element States    css=[data-test="btn-increase"]    contains    enabled

TC-05-03 (เพิ่มเติม) กด + แล้วกด − จำนวนเพิ่มและลดถูกต้อง
    [Tags]    TS-05-02    positive
    Open Product    ${PRODUCT_ID}
    ${stock}=    Read Stock
    Skip If    ${stock} < 3    สต็อกเหลือ ${stock} ชิ้น ไม่พอทดสอบ
    Click Increase Times    2
    ${qty}=    Read Buy Quantity
    Should Be Equal As Numbers    ${qty}    3
    Get Element States    css=[data-test="btn-decrease"]    contains    enabled
    Click    css=[data-test="btn-decrease"]
    ${qty}=    Read Buy Quantity
    Should Be Equal As Numbers    ${qty}    2

TC-05-04 (เพิ่มเติม) สินค้าสต็อกหมดกดเพิ่มลงรถเข็นและสั่งซื้อไม่ได้
    [Tags]    TS-05-03    negative
    Go To Path    /search
    Wait For Load State    networkidle
    ${n}=    Get Element Count    css=[data-test="product-card"]:has-text("${COMING_SOON}")
    Skip If    ${n} == 0    ตอนนี้ไม่มีสินค้าที่สต็อกหมด
    Click    css=[data-test="product-card"]:has-text("${COMING_SOON}") >> nth=0
    Wait For Elements State    css=[data-test="product-name"]    visible
    ${stock}=    Read Stock
    Should Be Equal As Numbers    ${stock}    0
    Get Element States    css=[data-test="btn-increase"]    contains    disabled
    Get Element States    css=[data-test="btn-add-to-cart"]    contains    disabled
    Get Element States    css=[data-test="btn-buy-cart"]    contains    disabled

TC-05-05 (เพิ่มเติม) เปิดรหัสสินค้าที่ไม่มีอยู่จริง
    [Tags]    TS-05-04    negative
    Go To Path    /product/999999
    Wait For Elements State    text="ไม่พบสินค้า"    visible
    Get Element Count    css=[data-test="btn-add-to-cart"]    ==    0

TC-05-06 (เพิ่มเติม) ลิงก์ "หน้าหลัก" พากลับหน้าแรก
    [Tags]    TS-05-05    positive
    Open Product    ${PRODUCT_ID}
    Click    css=[data-test="click-home"]
    Wait Until Keyword Succeeds    15s    500ms    Url Should Match    ^${BASE_URL}/?$
    Wait For Elements State    css=[data-test="product-card"] >> nth=0    visible

TC-05-07 (เพิ่มเติม) ชื่อและราคาตรงกับการ์ดในหน้าค้นหา
    [Tags]    TS-05-05    positive
    Go To Path    /search
    ${card}=    Set Variable    css=[data-test="product-card"][href="/product/${PRODUCT_ID}"]
    Wait For Elements State    ${card}    visible
    ${card_name}=    Get Text    ${card} >> css=h2
    ${card_text}=    Get Text    ${card}
    ${card_price}=    Price From Text    ${card_text}
    Click    ${card}
    Get Text    css=[data-test="product-name"]    ==    ${card_name.strip()}
    ${price_text}=    Evaluate    f"฿{${card_price}:,}"
    Wait For Elements State    text=${price_text} >> nth=0    visible

TC-05-08 (เพิ่มเติม) ยังไม่เข้าสู่ระบบแล้วกด "สั่งซื้อสินค้า"
    [Tags]    TS-05-05    negative
    Open Product    ${PRODUCT_ID}
    Click    css=[data-test="btn-buy-cart"]
    Toast Should Be Visible    กรุณาเข้าสู่ระบบก่อนทำการสั่งซื้อ
    Wait Until Keyword Succeeds    15s    500ms    Url Should Contain    /login
