*** Settings ***
Documentation       US-17 ดูคำสั่งซื้อของตนเอง และ US-18 ดูรายละเอียดคำสั่งซื้อ (UC-12)
...                 กรณีไม่มีคำสั่งซื้อ (TC-17-03) อยู่ใน tests/fresh/fresh_account.robot
Resource            ../../resources/storemate.resource
Suite Setup         Prepare Orders Suite
Suite Teardown      Close Browser
Test Setup          Open Customer Page
Test Teardown       Close Context
Test Tags           customer


*** Test Cases ***
TC-17-01 (TC19001) ดูรายการคำสั่งซื้อทั้งหมด
    [Documentation]    TS-17-01 ดูและกรองคำสั่งซื้อ
    [Tags]    US-17    TS-17-01    positive
    Go To Orders
    ${card}=    Order Card
    Get Text    ${card} >> css=[data-test="order-item-name"] >> nth=0    !=    ${EMPTY}
    Get Text    ${card} >> css=[data-test="order-item-quantity"] >> nth=0    matches    \\d
    Get Text    ${card}    matches    ยอดรวมสุทธิ\\s*฿\\s*[\\d,.]+
    ${statuses}=    Evaluate    '|'.join(list($ORDER_STATUS.values())[1:])
    Get Text    ${card}    matches    ${statuses}

TC-17-02 (TC19002) กรองคำสั่งซื้อตามสถานะ
    [Tags]    US-17    TS-17-01    positive
    Go To Orders
    Click    text=${ORDER_STATUS}[PROCESSING] >> nth=0
    Wait Until Keyword Succeeds    15s    500ms    Url Should Contain    status=PROCESSING
    Wait For Elements State    css=[data-test^="order-card-"] >> nth=0    visible
    ${texts}=    Evaluate JavaScript    ${None}
    ...    () => [...document.querySelectorAll('[data-test^="order-card-"]')].map(e => e.innerText)
    FOR    ${t}    IN    @{texts}
        Should Contain    ${t}    ${ORDER_STATUS}[PROCESSING]
    END

TC-17-04 (TC19004) ปุ่มของสถานะ "ที่ต้องชำระ"
    [Documentation]    TS-17-03 ปุ่มดำเนินการตามสถานะ
    [Tags]    US-17    TS-17-03    positive
    ${order_no}=    Place Pending Order    ${PRODUCT_ID}
    Go To Orders    PENDING
    ${card}=    Order Card    ${order_no}
    Get Text    ${card} >> css=[data-test="btn-retry-payment"]    ==    ชำระเงิน
    Get Text    ${card} >> css=[data-test="btn-cancel-order"]    ==    ยกเลิกคำสั่งซื้อ

TC-17-05 (TC19005) ปุ่มของสถานะ "ที่ต้องจัดส่ง" (เก็บเงินปลายทาง)
    [Tags]    US-17    TS-17-03    positive
    ${order_no}=    Place COD Order    ${PRODUCT_ID}
    Go To Orders    PROCESSING
    ${card}=    Order Card    ${order_no}
    Get Text    ${card} >> css=[data-test="btn-cancel-order"]    ==    ยกเลิกคำสั่งซื้อ
    Get Element Count    ${card} >> css=[data-test="btn-retry-payment"]    ==    0

TC-17-06 (TC19006) ปุ่มของสถานะ "ที่ต้องได้รับ"
    [Documentation]    ตาม UC-12 สถานะนี้ไม่มีปุ่มชำระเงิน/ยกเลิก
    [Tags]    US-17    TS-17-03    positive
    ${card}=    Skip If No Orders    RECEIVED
    Get Element Count    ${card} >> css=[data-test="btn-retry-payment"]    ==    0
    Get Element Count    ${card} >> css=[data-test="btn-cancel-order"]    ==    0

TC-17-07 (TC19007) ปุ่มของสถานะ "สำเร็จ" ที่ยังไม่รีวิว
    [Tags]    US-17    TS-17-03    positive
    ${card}=    Skip If No Orders    COMPLETED    btn-add-review
    Get Text    ${card} >> css=[data-test="btn-add-review"]    *=    เขียนรีวิว
    Get Text    ${card} >> css=[data-test="btn-retry-orders"]    *=    ซื้ออีกครั้ง

TC-17-08 (TC19008) ปุ่มของสถานะ "สำเร็จ" ที่รีวิวแล้ว
    [Tags]    US-17    TS-17-03    positive
    ${card}=    Skip If No Orders    COMPLETED    btn-see-review
    Get Text    ${card} >> css=[data-test="btn-see-review"]    *=    ดูรีวิว
    Get Text    ${card} >> css=[data-test="btn-retry-orders"]    *=    ซื้ออีกครั้ง
    Get Element Count    ${card} >> css=[data-test="btn-add-review"]    ==    0

TC-17-09 (TC19009) ปุ่มของสถานะ "ยกเลิก"
    [Tags]    US-17    TS-17-03    positive
    ${order_no}=    Place Pending Order    ${PRODUCT_ID}
    Go To Orders    PENDING
    ${card}=    Order Card    ${order_no}
    Cancel Order Via UI    ${card}
    Wait Until Keyword Succeeds    15s    500ms    Url Should Contain    status=CANCELLED
    Get Text    ${card} >> css=[data-test="btn-retry-orders"]    *=    ซื้ออีกครั้ง
    Get Element Count    ${card} >> css=[data-test="btn-cancel-order"]    ==    0

TC-17-10 (TC190010) ปุ่มของสถานะ "คืนเงิน/คืนสินค้า"
    [Tags]    US-17    TS-17-03    positive
    ${card}=    Skip If No Orders    REFUNDED
    Get Text    ${card} >> css=[data-test="btn-retry-orders"]    *=    ซื้ออีกครั้ง

TC-18-01 (TC20001) เปิดหน้ารายละเอียดคำสั่งซื้อ
    [Documentation]    TS-18-01 ดูรายละเอียดคำสั่งซื้อ
    [Tags]    US-18    TS-18-01    positive
    Open Order Detail
    IF    $DETAIL_ORDER_NO
        Url Should Match    /orders/${DETAIL_ORDER_NO}$
    END
    Text Should Be Visible    สถานะปัจจุบัน

TC-18-02 (TC20002) ความถูกต้องของข้อมูลในคำสั่งซื้อ
    [Tags]    US-18    TS-18-01    positive
    Open Order Detail
    Text Should Be Visible    ${DETAIL_PRODUCT}[name][:15]
    Text Should Be Visible    ราคาต่อหน่วย ฿ ${DETAIL_PRODUCT}[price]
    Text Should Be Visible    ยอดรวมสุทธิ
    Text Should Be Visible    /ช่องทาง(การ)?ชำระเงิน/

TC-18-03 (TC20004) ข้อมูลผู้รับสินค้า
    [Tags]    US-18    TS-18-01    positive
    Open Order Detail
    Text Should Be Visible    ชื่อผู้สั่งซื้อ
    Text Should Be Visible    เบอร์โทรศัพท์
    Text Should Be Visible    ที่อยู่สำหรับการจัดส่ง
    Text Should Be Visible    ${DETAIL_STREET}    # ตรงกับที่อยู่เริ่มต้นของบัญชี


*** Keywords ***
Prepare Orders Suite
    [Documentation]    เข้าสู่ระบบ แล้วสร้างคำสั่งซื้อเก็บเงินปลายทาง 1 รายการไว้ใช้กับ US-18
    Prepare Customer Session
    Open Customer Page
    Go To Addresses
    ${address}=    Get Text    css=[data-test="address-detail"] >> nth=0
    ${street}=    Street Of    ${address}
    ${product}=    Read Product Info    ${PRODUCT_ID}
    ${order_no}=    Place COD Order    ${PRODUCT_ID}
    Set Suite Variable    ${DETAIL_STREET}    ${street}
    Set Suite Variable    ${DETAIL_PRODUCT}    ${product}
    Set Suite Variable    ${DETAIL_ORDER_NO}    ${order_no}
    Close Context

Open Order Detail
    Go To Orders    PROCESSING
    ${card}=    Order Card    ${DETAIL_ORDER_NO}
    Click    ${card} >> css=[data-test="btn-order-details"]
    Wait Until Keyword Succeeds    15s    500ms    Url Should Match    /orders/[^/?]+$
