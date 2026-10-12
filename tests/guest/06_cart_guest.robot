*** Settings ***
Documentation       กรณีผู้ใช้ยังไม่เข้าสู่ระบบ ของ US-06 และ US-07
Resource            ../../resources/storemate.resource
Suite Setup         Open StoreMate Browser
Suite Teardown      Close Browser
Test Setup          Open Guest Page
Test Teardown       Close Context
Test Tags           guest


*** Test Cases ***
TC-06-02 (TC8002) บังคับเข้าสู่ระบบก่อนเพิ่มสินค้าเข้ารถเข็น
    [Documentation]    TS-06-02 เพิ่มสินค้าโดยยังไม่เข้าสู่ระบบ
    [Tags]    US-06    TS-06-02    negative
    Open Product    ${PRODUCT_ID}
    Click    css=[data-test="btn-add-to-cart"]
    Toast Should Be Visible    ${MSG}[loginBeforeCart]
    Wait Until Keyword Succeeds    15s    500ms    Url Should Contain    /login

TC-07-08 (TC9008) เปิดหน้ารถเข็นโดยยังไม่เข้าสู่ระบบ
    [Documentation]    TS-07-04 ผู้ที่ยังไม่เข้าสู่ระบบจะไม่เห็นไอคอนรถเข็นบนแถบเมนู จึงเปิด URL ตรง
    [Tags]    US-07    TS-07-04    negative
    Go To Path    /
    Wait For Elements State    css=[data-test="login-btn"]    visible
    Get Element Count    css=[data-test="click-shop-cart"]    ==    0
    Go To Path    /shopping-cart
    Wait Until Keyword Succeeds    15s    500ms    Url Should Contain    /login
