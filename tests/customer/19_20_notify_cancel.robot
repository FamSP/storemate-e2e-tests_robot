*** Settings ***
Documentation       US-19 ดูการแจ้งเตือน (UC-13) และ US-20 ยกเลิกคำสั่งซื้อ (UC-14)
...                 กรณีหมวดที่ไม่มีการแจ้งเตือน (TC-19-08) อยู่ใน tests/fresh/fresh_account.robot
Resource            ../../resources/storemate.resource
Suite Setup         Prepare Notification Suite
Suite Teardown      Close Browser
Test Setup          Open Customer Page
Test Teardown       Close Context
Test Tags           customer


*** Variables ***
# data-test ในโค้ดสะกดว่า "notification-ดitem" (มีตัว ด ปนอยู่) ต้องใช้ตามนั้น
${ITEMS}        css=[data-test="notification-ดitem"]


*** Test Cases ***
TC-19-01 (TC21001) แสดงการแจ้งเตือนทั้งหมด
    [Documentation]    TS-19-01 ดูการแจ้งเตือนตามหมวดหมู่
    [Tags]    US-19    TS-19-01    positive
    Open Notifications
    Wait For Elements State    ${ITEMS} >> nth=0    visible

TC-19-02 (TC21002) แท็บหมวดหมู่การแจ้งเตือน
    [Tags]    US-19    TS-19-01    positive
    Open Notifications
    FOR    ${id}    ${label}    IN    &{NOTIFY_FILTERS}
        Get Text    css=[data-test="filter-desktop-${id}"]    *=    ${label}
    END

TC-19-03 (TC21003) หมวด "ทั้งหมด"
    [Tags]    US-19    TS-19-01    positive
    Open Notifications
    Select Notification Filter    ORDERED
    ${ordered}=    Get Element Count    ${ITEMS}
    Select Notification Filter    ALL
    Get Element Count    ${ITEMS}    >=    ${ordered}    # ทั้งหมด >= แต่ละหมวด

TC-19-04 (TC21004) หมวด "คำสั่งซื้อ"
    [Tags]    US-19    TS-19-01    positive
    Open Notifications
    Select Notification Filter    ORDERED
    Wait For Elements State    ${ITEMS} >> nth=0    visible
    ${texts}=    Evaluate JavaScript    ${None}
    ...    () => [...document.querySelectorAll('[data-test="notification-ดitem"]')].map(e => e.innerText)
    FOR    ${t}    IN    @{texts}
        Should Match Regexp    ${t}    คำสั่งซื้อ|ออร์เดอร์
    END

TC-19-05 (TC21005) หมวด "คำขอคืนเงิน"
    [Tags]    US-19    TS-19-01    positive
    Category Should Be Subset Of All    REFUNDED

TC-19-06 (TC21006) หมวด "ร้านค้า"
    [Tags]    US-19    TS-19-01    positive
    Category Should Be Subset Of All    STORE

TC-19-07 (TC21007) รายละเอียดของการแจ้งเตือน
    [Tags]    US-19    TS-19-01    positive
    Open Notifications
    ${text}=    Get Text    ${ITEMS} >> nth=0
    ${lines}=    Evaluate    [l.strip() for l in $text.splitlines() if l.strip()]
    ${n}=    Get Length    ${lines}
    Should Be True    ${n} >= 3    ต้องมีหัวข้อ รายละเอียด และวันเวลา
    Should Match Regexp    ${text}    \\d{1,2}/\\d{1,2}/\\d{4}.*\\d{1,2}:\\d{2}    # วัน/เดือน/ปี และเวลา (th-TH)

TC-20-01 (TC22001) ยกเลิกคำสั่งซื้อสถานะ "ที่ต้องชำระ"
    [Documentation]    TS-20-01 ยกเลิกคำสั่งซื้อสำเร็จ
    [Tags]    US-20    TS-20-01    positive
    ${order_no}=    Place Pending Order    ${PRODUCT_ID}
    Go To Orders    PENDING
    ${card}=    Order Card    ${order_no}
    Cancel Order Via UI    ${card}    no_longer_want
    Toast Should Be Visible    ${MSG}[cancelSuccess]
    Wait Until Keyword Succeeds    15s    500ms    Url Should Contain    status=CANCELLED
    Wait For Elements State    ${card}    visible
    Get Text    ${card}    *=    ไม่ต้องการสินค้านี้แล้ว    # เหตุผลที่เลือก

TC-20-02 (TC22002) ยกเลิกคำสั่งซื้อเก็บเงินปลายทางสถานะ "ที่ต้องจัดส่ง"
    [Tags]    US-20    TS-20-01    positive
    ${order_no}=    Place COD Order    ${PRODUCT_ID}
    Go To Orders    PROCESSING
    ${card}=    Order Card    ${order_no}
    Cancel Order Via UI    ${card}    edit_order_details
    Toast Should Be Visible    ${MSG}[cancelSuccess]
    Wait Until Keyword Succeeds    15s    500ms    Url Should Contain    status=CANCELLED
    IF    $order_no    Get Text    ${card}    *=    สั่งซื้อสินค้าผิด

TC-20-03 (TC22003) ไม่เลือกเหตุผลในการยกเลิก
    [Documentation]    TS-20-02 ไม่เลือกเหตุผลการยกเลิก
    [Tags]    US-20    TS-20-02    negative
    ${order_no}=    Place COD Order    ${PRODUCT_ID}
    Go To Orders    PROCESSING
    ${card}=    Order Card    ${order_no}
    Cancel Order Via UI    ${card}    ${EMPTY}
    Toast Should Be Visible    ${MSG}[cancelReasonRequired]
    Url Should Contain    /cancel-orders/
    Go To Orders    PROCESSING
    IF    $order_no    Wait For Elements State    ${card}    visible    # สถานะไม่เปลี่ยน


*** Keywords ***
Prepare Notification Suite
    [Documentation]    เข้าสู่ระบบ แล้วสร้างคำสั่งซื้อ 1 รายการ เพื่อให้มีการแจ้งเตือนหมวด "คำสั่งซื้อ"
    Prepare Customer Session
    Open Customer Page
    Place COD Order    ${PRODUCT_ID}
    Close Context

Open Notifications
    Go To Path    /
    Click    css=[data-test="click-notifications"]
    Click    text=ดูทั้งหมด
    Wait Until Keyword Succeeds    15s    500ms    Url Should Contain    /notify
    Wait For Elements State    ${ITEMS}, [data-test="empty-state"]    visible

Select Notification Filter
    [Arguments]    ${id}
    Click    css=[data-test="filter-desktop-${id}"]
    Wait For Elements State    ${ITEMS}, [data-test="empty-state"]    visible

Category Should Be Subset Of All
    [Arguments]    ${id}
    Open Notifications
    Select Notification Filter    ALL
    ${all}=    Get Element Count    ${ITEMS}
    Select Notification Filter    ${id}
    ${count}=    Get Element Count    ${ITEMS}
    Should Be True    ${count} <= ${all}
    IF    ${count} == 0    Text Should Be Visible    ${MSG}[noNotification]
