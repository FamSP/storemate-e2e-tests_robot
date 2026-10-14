*** Settings ***
Documentation       US-03 ดูรายการสินค้า (UC-05) — ชุดหลัก + ชุดเพิ่มเติม รวมในไฟล์เดียว
...                 ชุดเพิ่มเติมไม่มีในเอกสารเดิม จึงใช้ป้าย (เพิ่มเติม) แทนรหัสเดิม
Resource            ../../resources/storemate.resource
Suite Setup         Open StoreMate Browser
Suite Teardown      Close Browser
Test Setup          Open Guest Page
Test Teardown       Close Context
Test Tags           US-03    guest


*** Variables ***
${CARDS}            css=[data-test="product-card"]
${COMING_SOON}      สินค้าจะมีเร็วๆนี้
@{SECTIONS}         promotion-section    soap-section    drinks-section    shampoo-section


*** Test Cases ***
# ---------- ชุดหลัก (ตามเอกสาร) ----------
TC-03-01 (TC5001) แสดงรายการสินค้าตามหมวดหมู่
    [Documentation]    TS-03-01 แสดงสินค้าตามหมวดหมู่ หมวดละไม่เกิน 4 รายการ
    [Tags]    TS-03-01    positive
    Open Home
    FOR    ${section}    IN    @{SECTIONS}
        Wait For Elements State    id=${section}    visible
        ${count}=    Get Element Count    id=${section} >> css=[data-test="product-card"]
        Should Be True    ${count} <= 4    หมวด ${section} แสดงสินค้า ${count} รายการ (เกิน 4)
    END
    Get Element Count    ${CARDS}    >    0

TC-03-02 (TC5002) หมวดหมู่ที่ไม่มีสินค้า
    [Documentation]    TS-03-02 หมวดหมู่ที่ไม่มีสินค้าต้องแสดง "ไม่พบรายการสินค้า"
    [Tags]    TS-03-02    negative
    Open Home
    ${empty}=    Get Element Count    css=section:has-text("${MSG}[emptyCategory]")
    Skip If    ${empty} == 0    ตอนนี้ทุกหมวดมีสินค้า จึงทดสอบกรณีหมวดว่างไม่ได้
    Get Element Count    css=section:has-text("${MSG}[emptyCategory]") >> nth=0 >> css=[data-test="product-card"]    ==    0

# ---------- ชุดเพิ่มเติม ----------
TC-03-03 (เพิ่มเติม) แสดงแบนเนอร์หลักและหัวข้อครบ 4 หมวด
    [Tags]    TS-03-03    positive
    Open Home
    Wait For Elements State    id=hero-banner    visible
    Get Text    id=promotion-section >> css=h2 >> nth=0    ==    โปรโมชั่นสุดพิเศษ
    Get Text    id=soap-section >> css=h2 >> nth=0    ==    สบู่สมุนไพร
    Get Text    id=drinks-section >> css=h2 >> nth=0    ==    เครื่องดื่ม
    Get Text    id=shampoo-section >> css=h2 >> nth=0    ==    แชมพูสมุนไพร

TC-03-04 (เพิ่มเติม) การ์ดสินค้าทุกใบมีรูป ชื่อ และราคา
    [Tags]    TS-03-03    positive
    Open Home
    ${count}=    Get Element Count    ${CARDS}
    Should Be True    ${count} > 0
    FOR    ${i}    IN RANGE    ${count}
        Wait For Elements State    ${CARDS} >> nth=${i} >> css=img >> nth=0    visible
        Get Text    ${CARDS} >> nth=${i} >> css=h2    !=    ${EMPTY}
        Get Text    ${CARDS} >> nth=${i}    matches    ฿\\s*[\\d,]+
    END

TC-03-05 (เพิ่มเติม) สินค้าที่สต็อกหมดแสดงป้าย "สินค้าจะมีเร็วๆนี้"
    [Tags]    TS-03-03    positive
    Open Home
    ${sold_out}=    Set Variable    ${CARDS}:has-text("${COMING_SOON}") >> nth=0
    ${n}=    Get Element Count    ${CARDS}:has-text("${COMING_SOON}")
    Skip If    ${n} == 0    ตอนนี้ไม่มีสินค้าที่สต็อกหมดบนหน้าแรก
    ${href}=    Get Attribute    ${sold_out}    href
    Go To Path    ${href}
    Wait For Elements State    text=/มีสินค้าทั้งหมด\\s*0\\s*ชิ้น/    visible

TC-03-06 (เพิ่มเติม) ปุ่ม "ดูทั้งหมด" ของหมวด โปรโมชั่นสุดพิเศษ
    [Tags]    TS-03-04    positive
    [Template]    See All Should Open Category
    promotion-section    promotion

TC-03-07 (เพิ่มเติม) ปุ่ม "ดูทั้งหมด" ของหมวด สบู่สมุนไพร
    [Tags]    TS-03-04    positive
    [Template]    See All Should Open Category
    soap-section    soap

TC-03-08 (เพิ่มเติม) ปุ่ม "ดูทั้งหมด" ของหมวด เครื่องดื่ม
    [Tags]    TS-03-04    positive
    [Template]    See All Should Open Category
    drinks-section    drinks

TC-03-09 (เพิ่มเติม) ปุ่ม "ดูทั้งหมด" ของหมวด แชมพูสมุนไพร
    [Tags]    TS-03-04    positive
    [Template]    See All Should Open Category
    shampoo-section    shampoo

TC-03-10 (เพิ่มเติม) เมนู "สินค้า" พาไปหน้ารวมสินค้า
    [Tags]    TS-03-04    positive
    Open Home
    Click    css=[data-test="list-search"]
    Wait Until Keyword Succeeds    15s    500ms    Url Should Match    /search$
    Wait For Elements State    css=[data-test="input-search"]    visible

TC-03-11 (เพิ่มเติม) เมนู "โปรโมชั่น" พาไปหน้าค้นหาหมวดโปรโมชั่น
    [Tags]    TS-03-04    positive
    Open Home
    Click    css=[data-test="list-promo"]
    Wait Until Keyword Succeeds    15s    500ms    Url Should Contain    category=promotion

TC-03-12 (เพิ่มเติม) กดการ์ดแล้วไปหน้ารายละเอียดของสินค้านั้นถูกตัว
    [Tags]    TS-03-04    positive
    Open Home
    ${count}=    Get Element Count    ${CARDS}
    ${total}=    Evaluate    min(${count}, 3)
    FOR    ${i}    IN RANGE    ${total}
        Open Home
        ${card}=    Set Variable    ${CARDS} >> nth=${i}
        ${href}=    Get Attribute    ${card}    href
        ${text}=    Get Text    ${card}
        ${price}=    Price From Text    ${text}
        Click    ${card}
        Wait Until Keyword Succeeds    15s    500ms    Url Should Match    ${href}$
        Wait For Elements State    css=[data-test="product-name"]    visible
        ${price_text}=    Evaluate    f"฿{${price}:,}"
        Wait For Elements State    text=${price_text} >> nth=0    visible
    END


*** Keywords ***
Open Home
    Go To Path    /
    Wait For Elements State    ${CARDS} >> nth=0    visible
    Wait For Load State    networkidle

See All Should Open Category
    [Arguments]    ${section}    ${category}
    Open Home
    Click    id=${section} >> css=[data-test="see-all-link"]
    Wait Until Keyword Succeeds    15s    500ms    Url Should Match    /search\\?category=${category}$
    Wait For Elements State    css=[data-test="filteredProduct"]    visible
