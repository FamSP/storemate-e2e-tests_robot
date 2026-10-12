*** Settings ***
Documentation       US-05 ดูรายละเอียดสินค้า (UC-05)
Resource            ../../resources/storemate.resource
Suite Setup         Open StoreMate Browser
Suite Teardown      Close Browser
Test Setup          Open Guest Page
Test Teardown       Close Context
Test Tags           US-05    guest


*** Test Cases ***
TC-05-01 (TC7001) เข้าหน้ารายละเอียดสินค้าจากหน้ารายการสินค้า
    [Documentation]    TS-05-01 เปิดหน้ารายละเอียดสินค้าและแสดงข้อมูลครบ
    [Tags]    TS-05-01    positive
    Go To Path    /
    # เลือกสินค้าที่พร้อมขาย (การ์ดที่ไม่มีป้าย "สินค้าจะมีเร็วๆนี้")
    ${card}=    Set Variable    css=[data-test="product-card"]:not(:has-text("${MSG}[comingSoon]")) >> nth=0
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
