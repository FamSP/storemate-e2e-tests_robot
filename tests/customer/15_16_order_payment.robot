*** Settings ***
Documentation       US-15 สั่งซื้อสินค้า (UC-10) และ US-16 ชำระเงิน (UC-11)
...                 หมายเหตุ: เทสในไฟล์นี้สร้างคำสั่งซื้อจริงและตัดสต็อกสินค้า PRODUCT_ID
Resource            ../../resources/storemate.resource
Suite Setup         Prepare Customer Session
Suite Teardown      Close Browser
Test Setup          Open Customer Page
Test Teardown       Close Context
Test Tags           customer


*** Test Cases ***
TC-15-01 (TC17001) สั่งซื้อจากหน้ารายละเอียดสินค้า
    [Documentation]    TS-15-01 ไปหน้าสรุปคำสั่งซื้อ
    [Tags]    US-15    TS-15-01    positive
    Go To Addresses
    ${address}=    Get Text    css=[data-test="address-detail"] >> nth=0
    ${street}=    Street Of    ${address}
    ${p}=    Read Product Info    ${PRODUCT_ID}
    Buy Now    ${PRODUCT_ID}
    Get Text    css=[data-test="address"]    *=    ${street}
    Order Summary Should Be Correct    ${p}[name]    1    ${p}[price]

TC-15-02 (TC17002) สั่งซื้อจากรถเข็นสินค้า
    [Tags]    US-15    TS-15-01    positive
    ${p}=    Read Product Info    ${PRODUCT_ID}
    Clear Cart
    Add To Cart    ${PRODUCT_ID}    2
    Go To Cart
    Check Checkbox    css=[data-test="checkbox-product-${PRODUCT_ID}"]
    Click    css=[data-test="btn-payment"]
    Wait Until Keyword Succeeds    15s    500ms    Url Should Match    /payment$
    Order Summary Should Be Correct    ${p}[name]    2    ${p}[price] * 2

TC-15-03 (TC17003) ย้อนกลับจากหน้าสรุปที่มาจากรถเข็น
    [Documentation]    TS-15-02 ย้อนกลับก่อนยืนยันคำสั่งซื้อ ระบบต้องไม่สร้างคำสั่งซื้อ
    [Tags]    US-15    TS-15-02    negative
    Clear Cart
    Add To Cart    ${PRODUCT_ID}    1
    Go To Orders
    ${before}=    Order Count
    Go To Cart
    Check Checkbox    css=[data-test="checkbox-product-${PRODUCT_ID}"]
    Click    css=[data-test="btn-payment"]
    Wait Until Keyword Succeeds    15s    500ms    Url Should Match    /payment$
    Go Back
    Wait Until Keyword Succeeds    15s    500ms    Url Should Contain    /shopping-cart
    ${row}=    Cart Row    ${PRODUCT_ID}
    Wait For Elements State    ${row}    visible
    Go To Orders
    Get Element Count    css=[data-test^="order-card-"]    ==    ${before}

TC-15-04 (TC17004) ย้อนกลับจากหน้าสรุปที่มาจากหน้ารายละเอียดสินค้า
    [Tags]    US-15    TS-15-02    negative
    ${p}=    Read Product Info    ${PRODUCT_ID}
    Click    css=[data-test="btn-buy-cart"]
    Wait Until Keyword Succeeds    15s    500ms    Url Should Match    /payment$
    Go Back
    Wait Until Keyword Succeeds    15s    500ms    Url Should Match    /product/${PRODUCT_ID}$
    ${stock}=    Read Stock
    Should Be Equal As Numbers    ${stock}    ${p}[stock]    # ไม่ตัดสต็อก

TC-16-01 (TC18001) ชำระแบบเก็บเงินปลายทาง (COD)
    [Documentation]    TS-16-01 ชำระเงินสำเร็จ
    [Tags]    US-16    TS-16-01    positive
    ${p}=    Read Product Info    ${PRODUCT_ID}
    ${order_no}=    Place COD Order    ${PRODUCT_ID}
    Go To Orders    PROCESSING
    IF    $order_no
        ${card}=    Order Card    ${order_no}
        Wait For Elements State    ${card}    visible
    END
    Open Product    ${PRODUCT_ID}
    ${stock}=    Read Stock
    Should Be Equal As Numbers    ${stock}    ${{ $p["stock"] - 1 }}

TC-16-02 (TC18002) ชำระด้วยบัตรเครดิต/เดบิต (บัตรทดสอบ Stripe)
    [Tags]    US-16    TS-16-01    positive
    Open Add Card Page    ${PRODUCT_ID}
    Fill Card
    Wait Until Keyword Succeeds    15s    500ms    Url Should Match    /payment$
    Click    css=[data-test="select-credit-desktop"]
    Click    css=[data-test="btn-select-card-method-desktop"]
    Click    css=[data-test="btn-confirm-payment-desktop"]
    Toast Should Be Visible    ${MSG}[orderSuccess]
    Wait Until Keyword Succeeds    15s    500ms    Url Should Contain    /orders

TC-16-03 (TC18003) ชำระด้วย PromptPay (ตรวจการสร้าง QR)
    [Documentation]    อัตโนมัติถึงขั้นแสดง QR Code ส่วนการสแกนและยืนยันการชำระเงินจริงต้องทดสอบด้วยมือ (Manual)
    [Tags]    US-16    TS-16-01    positive    partial-manual
    ${p}=    Read Product Info    ${PRODUCT_ID}
    Start PromptPay Payment    ${PRODUCT_ID}
    Get Text    css=[data-test="payment-countdown"]    matches    \\d{2}:\\d{2}
    ${total}=    Get Text    css=[data-test="payment-total-price-desktop"]
    ${total}=    To Number    ${total}
    Should Be Equal As Numbers    ${total}    ${p}[price]

TC-16-04 (TC18004) ไม่เลือกช่องทางการชำระเงิน
    [Documentation]    TS-16-02 ข้อมูลการชำระเงินไม่ถูกต้อง
    [Tags]    US-16    TS-16-02    negative
    Buy Now    ${PRODUCT_ID}
    Click    css=[data-test="btn-confirm-payment-desktop"]
    Toast Should Be Visible    ${MSG}[selectPayment]
    Url Should Match    /payment$

TC-16-05 (TC18005) ชื่อบนบัตรเป็นตัวเลขหรืออักขระพิเศษ
    [Tags]    US-16    TS-16-02    negative
    Open Add Card Page    ${PRODUCT_ID}
    Fill Card    name=12345@#
    Toast Should Be Visible    ${MSG}[cardNameLetters]
    Url Should Contain    /add-credit-card

TC-16-06 (TC18006) หมายเลขบัตรไม่ครบ
    [Tags]    US-16    TS-16-02    negative
    Open Add Card Page    ${PRODUCT_ID}
    Fill Card    number=424242424242
    Toast Should Be Visible    ${MSG}[cardIncomplete]
    Url Should Contain    /add-credit-card

TC-16-07 (TC18007) วันหมดอายุบัตรไม่ถูกต้อง
    [Tags]    US-16    TS-16-02    negative
    Open Add Card Page    ${PRODUCT_ID}
    Fill Card    expiry=13/30    cvc=000
    Toast Should Be Visible    ${MSG}[cardExpiry]
    Url Should Contain    /add-credit-card

TC-16-08 (TC18008) ปิดหน้าต่าง QR Code ก่อนชำระเงิน
    [Documentation]    TS-16-03 PromptPay ไม่เสร็จสมบูรณ์ คำสั่งซื้อต้องอยู่ "ที่ต้องชำระ"
    [Tags]    US-16    TS-16-03    negative
    ${order_no}=    Place Pending Order    ${PRODUCT_ID}
    Go To Orders    PENDING
    ${card}=    Order Card    ${order_no}
    Wait For Elements State    ${card}    visible
    Wait For Elements State    ${card} >> css=[data-test="btn-retry-payment"]    visible

TC-16-09 (TC18009) QR Code หมดอายุ
    [Tags]    US-16    TS-16-03    negative
    ${order_no}=    Start PromptPay Payment    ${PRODUCT_ID}
    # เลื่อนเวลาของหน้าเว็บไป 31 นาที เพื่อให้ QR หมดอายุโดยไม่ต้องรอจริง
    Evaluate JavaScript    ${None}
    ...    () => { const real = Date.now.bind(Date); Date.now = () => real() + 31 * 60 * 1000; }
    Toast Should Be Visible    ${MSG}[qrExpired]
    Wait Until Keyword Succeeds    15s    500ms    Url Should Contain    /orders
    Go To Orders    PENDING
    ${card}=    Order Card    ${order_no}
    Wait For Elements State    ${card}    visible    # ยังอยู่ "ที่ต้องชำระ"
    Wait For Elements State    ${card} >> css=[data-test="btn-retry-payment"]    visible    # ชำระใหม่ได้


*** Keywords ***
Order Summary Should Be Correct
    [Arguments]    ${name}    ${qty}    ${total}
    Get Text    css=[data-test="shipping-address"]    not contains    ยังไม่มีข้อมูลที่อยู่
    Get Text    css=[data-test="order-item"] >> nth=0 >> css=[data-test="product-name"]    *=    ${name}[:15]
    Get Text    css=[data-test="order-item"] >> nth=0 >> css=[data-test="product-quantity"]    *=    ${qty}
    ${expected}=    Evaluate    ${total}
    Order Total Should Be    ${expected}
    Get Text    css=[data-test="payment-method"]    *=    พร้อมเพย์ (PromptPay)
    Get Text    css=[data-test="payment-method"]    *=    บัตรเครดิต / บัตรเดบิต
    Get Text    css=[data-test="payment-method"]    *=    เก็บเงินปลายทาง
    Wait For Elements State    css=[data-test="btn-confirm-payment-desktop"]    visible
