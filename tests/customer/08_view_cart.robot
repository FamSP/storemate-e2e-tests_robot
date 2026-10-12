*** Settings ***
Documentation       US-08 ดูสินค้าทั้งหมดในรถเข็น (UC-07)
Resource            ../../resources/storemate.resource
Suite Setup         Prepare Customer Session
Suite Teardown      Run Keywords    Open Customer Page    AND    Clear Cart    AND    Close Browser
Test Setup          Prepare Cart With Two Products
Test Teardown       Close Context
Test Tags           US-08    customer


*** Test Cases ***
TC-08-01 (TC10001) แสดงรายการสินค้าในรถเข็นครบ
    [Tags]    TS-08-01    positive
    ${expected}=    Set Variable If    $UNAVAILABLE_PRODUCT_ID    3    2
    Get Element Count    css=[data-test^="checkbox-product-"]    ==    ${expected}
    FOR    ${id}    IN    ${PRODUCT_ID}    ${SECOND_PRODUCT_ID}
        ${row}=    Cart Row    ${id}
        Wait For Elements State    ${row}    visible
    END

TC-08-02 (TC10002) รายละเอียดสินค้าในรถเข็น
    [Tags]    TS-08-01    positive
    FOR    ${id}    IN    ${PRODUCT_ID}    ${SECOND_PRODUCT_ID}
        ${p}=    Set Variable    ${PRODUCTS}[${id}]
        ${row}=    Cart Row    ${id}
        Get Text    ${row}    *=    ${p}[name]
        Wait For Elements State    ${row} >> css=img >> nth=0    visible
        Get Text    ${row}    *=    ฿ ${p}[price]
        Cart Quantity Should Be    ${id}    ${p}[qty]
        Get Text    ${row}    *=    พร้อมจำหน่าย
    END

TC-08-03 (TC10003) การคำนวณยอดรวม
    [Tags]    TS-08-01    positive
    Click    css=[data-test="radio-all-product"]
    ${a}=    Set Variable    ${PRODUCTS}[${PRODUCT_ID}]
    ${b}=    Set Variable    ${PRODUCTS}[${SECOND_PRODUCT_ID}]
    ${expected}=    Evaluate    ${a}[price] * ${a}[qty] + ${b}[price] * ${b}[qty]
    Wait Until Keyword Succeeds    15s    500ms    Total Price Should Be    ${expected}

TC-08-04 (TC10004) ปุ่มดำเนินการในหน้ารถเข็น
    [Tags]    TS-08-01    positive
    FOR    ${id}    IN    ${PRODUCT_ID}    ${SECOND_PRODUCT_ID}
        ${row}=    Cart Row    ${id}
        Get Element States    ${row} >> css=[data-test="increase-product"]    contains    enabled
        Get Element States    ${row} >> css=[data-test="decrease-product"]    contains    enabled
    END
    Get Element States    css=[data-test="btn-payment"]    contains    disabled    # ยังไม่เลือกสินค้า
    Check Checkbox    css=[data-test="checkbox-product-${PRODUCT_ID}"]
    Get Element States    css=[data-test="btn-payment"]    contains    enabled
    Click    css=[data-test="btn-payment"]
    Wait Until Keyword Succeeds    15s    500ms    Url Should Match    /payment$

TC-08-05 (TC10005) สินค้าไม่พร้อมจำหน่ายเลือกไม่ได้
    [Tags]    TS-08-02    negative
    Skip If    not $UNAVAILABLE_PRODUCT_ID
    ...    ไม่ได้กำหนด UNAVAILABLE_PRODUCT_ID (ต้องเพิ่มสินค้าเข้ารถเข็นก่อนแล้วให้เจ้าของร้านเปลี่ยนสถานะ)
    ${row}=    Cart Row    ${UNAVAILABLE_PRODUCT_ID}
    Get Text    ${row}    *=    ${MSG}[unavailable]
    Get Element States    css=[data-test="checkbox-product-${UNAVAILABLE_PRODUCT_ID}"]    contains    disabled


*** Keywords ***
Prepare Cart With Two Products
    [Documentation]    ล้างรถเข็น แล้วใส่ PRODUCT_ID 1 ชิ้น และ SECOND_PRODUCT_ID 2 ชิ้น
    Open Customer Page
    Clear Cart
    &{products}=    Create Dictionary
    FOR    ${id}    ${qty}    IN    ${PRODUCT_ID}    1    ${SECOND_PRODUCT_ID}    2
        ${info}=    Read Product Info    ${id}
        Set To Dictionary    ${info}    qty=${qty}
        Set To Dictionary    ${products}    ${id}=${info}
        Add To Cart    ${id}    ${qty}
    END
    Set Test Variable    ${PRODUCTS}    ${products}
    Go To Cart

Total Price Should Be
    [Arguments]    ${expected}
    ${text}=    Get Text    css=[data-test="total-price"]
    ${n}=    To Number    ${text}
    Should Be Equal As Numbers    ${n}    ${expected}
