*** Settings ***
Documentation       US-06 เพิ่มสินค้าเข้ารถเข็น (UC-07)
Resource            ../../resources/storemate.resource
Suite Setup         Prepare Customer Session
Suite Teardown      Run Keywords    Open Customer Page    AND    Clear Cart    AND    Close Browser
Test Setup          Run Keywords    Open Customer Page    AND    Clear Cart
Test Teardown       Close Context
Test Tags           US-06    customer


*** Test Cases ***
TC-06-01 (TC8001) เพิ่มสินค้าเข้ารถเข็นสำเร็จ
    [Documentation]    TS-06-01 เพิ่มสินค้าเข้ารถเข็นสำเร็จ
    [Tags]    TS-06-01    positive
    Open Product    ${PRODUCT_ID}
    ${before}=    Cart Badge
    Click    css=[data-test="btn-add-to-cart"]
    Toast Should Be Visible    ${MSG}[addedToCart]
    Wait Until Keyword Succeeds    15s    500ms    Cart Badge Should Be    ${before + 1}
    Go To Cart
    Cart Quantity Should Be    ${PRODUCT_ID}    1

TC-06-03 (TC8003) จำนวนสินค้าในสต็อกไม่เพียงพอ
    [Documentation]    TS-06-03 ระบบไม่ให้เลือกเกินสต็อก: จำนวนหยุดที่สต็อกและปุ่ม + ถูกปิด
    [Tags]    TS-06-03    negative
    Open Product    ${PRODUCT_ID}
    ${stock}=    Read Stock
    Skip If Stock Too Large    ${stock}
    Click Increase Times    ${stock - 1}
    ${qty}=    Read Buy Quantity
    Should Be Equal As Numbers    ${qty}    ${stock}
    Get Element States    css=[data-test="btn-increase"]    contains    disabled

TC-06-04 (TC8004) จำนวนในรถเข็นรวมกับจำนวนที่เพิ่มเกินสต็อก
    [Documentation]    TS-06-03 มีสินค้าในรถเข็นแล้ว 1 ชิ้น แล้วเพิ่มอีกเท่าสต็อก
    [Tags]    TS-06-03    negative
    Add To Cart    ${PRODUCT_ID}    1
    Open Product    ${PRODUCT_ID}
    ${stock}=    Read Stock
    Skip If Stock Too Large    ${stock}
    Click Increase Times    ${stock - 1}
    Click    css=[data-test="btn-add-to-cart"]
    Toast Should Be Visible    ${MSG}[alreadyInCart]
    Go To Cart
    Cart Quantity Should Be    ${PRODUCT_ID}    1


*** Keywords ***
Cart Badge Should Be
    [Arguments]    ${expected}
    ${n}=    Cart Badge
    Should Be Equal As Numbers    ${n}    ${expected}
