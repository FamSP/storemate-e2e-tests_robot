*** Settings ***
Documentation       เทสที่ต้องใช้บัญชีใหม่ที่ยังไม่มีข้อมูล (ไม่มีที่อยู่ / คำสั่งซื้อ / การแจ้งเตือน)
...                 และเทสที่ทำให้ออกจากระบบ (เปลี่ยนอีเมล) จึงแยกออกจากบัญชีลูกค้าหลัก
Resource            ../../resources/storemate.resource
Suite Setup         Register Fresh Suite User
Suite Teardown      Close Browser
Test Setup          Login Fresh User
Test Teardown       Close Context
Test Tags           fresh


*** Test Cases ***
TC-11-02 (TC13002) แสดงผลเมื่อไม่มีที่อยู่
    [Documentation]    TS-11-02 ยังไม่มีที่อยู่
    [Tags]    US-11    TS-11-02    negative
    Go To Addresses
    Text Should Be Visible    ${MSG}[noAddress]
    Get Element Count    css=[data-test="address-detail"]    ==    0
    Wait For Elements State    css=[data-test="btn-add-address"]    visible

TC-14-04 (TC16004) หน้าจอเมื่อไม่มีที่อยู่เหลือ
    [Tags]    US-14    TS-14-02    negative
    Go To Addresses
    Text Should Be Visible    ${MSG}[noAddress]

TC-17-03 (TC19003) ไม่มีประวัติคำสั่งซื้อ
    [Tags]    US-17    TS-17-02    negative
    Go To Orders
    Text Should Be Visible    ${MSG}[noOrders]

TC-19-08 (TC21008) ไม่พบการแจ้งเตือนในหมวดหมู่ที่เลือก
    [Tags]    US-19    TS-19-02    negative
    Go To Path    /notify
    Click    css=[data-test="filter-desktop-REFUNDED"]
    Wait For Elements State    css=[data-test="empty-state"]    visible
    Text Should Be Visible    ${MSG}[noNotification]

TC-14-03 (TC16003) ลบที่อยู่สุดท้ายที่เหลืออยู่
    [Documentation]    ต้องรันหลังเทสบัญชีว่างข้างบน เพราะเพิ่มที่อยู่ให้บัญชี
    [Tags]    US-14    TS-14-02    negative
    ${street}=    Add Address    ${{ "99/9 หมู่ 1 QA-last-" + str(__import__('time').time_ns()) }}
    Get Element Count    css=[data-test="address-detail"]    ==    1
    Click    css=[data-test^="btn-delete-address-"] >> nth=0
    Toast Should Be Visible    ${MSG}[lastAddress]
    Wait For Elements State    css=[data-test="address-detail"]:has-text("${street}")    visible    # ที่อยู่ยังอยู่

TC-10-02 (TC12002) แก้ไขอีเมลสำเร็จ
    [Documentation]    TS-10-01 ใช้บัญชีแยกอีกบัญชี เพราะระบบจะออกจากระบบหลังเปลี่ยนอีเมล
    [Tags]    US-10    TS-10-01    positive
    [Setup]    Open Guest Page
    ${own}=    Create Fresh Customer    email
    ${other}=    Unique User    newmail
    Go To Path    /profile
    Click    css=[data-test="btn-change-email"]
    Fill Text    css=[data-test="input-email"]    ${other}[email]
    Click    css=[data-test="edit-modal-save-button"]
    Toast Should Be Visible    ${MSG}[profileSaved]
    Wait Until Keyword Succeeds    15s    500ms    Url Should Contain    /login    # ระบบให้เข้าสู่ระบบใหม่
    Login Via UI    ${other}[email]    ${own}[password]
    Toast Should Be Visible    ${MSG}[loginSuccess]    # เข้าสู่ระบบด้วยอีเมลใหม่ได้


*** Keywords ***
Register Fresh Suite User
    Open StoreMate Browser
    Open Guest Page
    ${user}=    Unique User    fresh
    Register Via UI    ${user}
    Set Suite Variable    ${FRESH_USER}    ${user}
    Close Context

Login Fresh User
    Open Guest Page
    Login Via UI    ${FRESH_USER}[email]    ${FRESH_USER}[password]
    Toast Should Be Visible    ${MSG}[loginSuccess]
    Url Should Not Contain    /login
