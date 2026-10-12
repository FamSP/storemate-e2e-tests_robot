*** Settings ***
Documentation       US-07 จัดการสินค้าในรถเข็น (UC-07)
...                 TC-07-08 (TC9008) อยู่ใน tests/guest/06_cart_guest.robot เพราะต้องยังไม่เข้าสู่ระบบ
Resource            ../../resources/storemate.resource
Suite Setup         Prepare Customer Session
Suite Teardown      Run Keywords    Open Customer Page    AND    Clear Cart    AND    Close Browser
Test Setup          Run Keywords    Open Customer Page    AND    Clear Cart
Test Teardown       Close Context
Test Tags           US-07    customer


*** Test Cases ***
TC-07-01 (TC9001) เพิ่มจำนวนสินค้าในรถเข็น
    [Tags]    TS-07-01    positive
    Add To Cart    ${PRODUCT_ID}    1
    Go To Cart
    ${before}=    Read Row Subtotal    ${PRODUCT_ID}
    ${row}=    Cart Row    ${PRODUCT_ID}
    Click    ${row} >> css=[data-test="increase-product"]
    Cart Quantity Should Be    ${PRODUCT_ID}    2
    Wait Until Keyword Succeeds    15s    500ms    Row Subtotal Should Be    ${PRODUCT_ID}    ${before * 2}

TC-07-02 (TC9003) ลดจำนวนสินค้าในรถเข็น
    [Tags]    TS-07-01    positive
    Add To Cart    ${PRODUCT_ID}    2
    Go To Cart
    ${before}=    Read Row Subtotal    ${PRODUCT_ID}
    ${row}=    Cart Row    ${PRODUCT_ID}
    Click    ${row} >> css=[data-test="decrease-product"]
    Cart Quantity Should Be    ${PRODUCT_ID}    1
    Wait Until Keyword Succeeds    15s    500ms    Row Subtotal Should Be    ${PRODUCT_ID}    ${before / 2}

TC-07-03 (TC9004) ลดจำนวนจนเหลือ 0 ชิ้น
    [Tags]    TS-07-01    negative
    Add To Cart    ${PRODUCT_ID}    1
    Go To Cart
    ${row}=    Cart Row    ${PRODUCT_ID}
    Click    ${row} >> css=[data-test="decrease-product"]
    Text Should Be Visible    ${MSG}[confirmRemoveItem]
    Confirm Dialog    ยกเลิก
    Cart Quantity Should Be    ${PRODUCT_ID}    1    # กดยกเลิก สินค้ายังอยู่

TC-07-04 (TC9002) เพิ่มจำนวนสินค้าเกินสต็อก
    [Tags]    TS-07-02    negative
    Open Product    ${PRODUCT_ID}
    ${stock}=    Read Stock
    Skip If Stock Too Large    ${stock}
    Add To Cart    ${PRODUCT_ID}    ${stock}    # ใส่รถเข็นเท่ากับสต็อก
    Go To Cart
    Cart Quantity Should Be    ${PRODUCT_ID}    ${stock}
    ${row}=    Cart Row    ${PRODUCT_ID}
    Click    ${row} >> css=[data-test="increase-product"]
    Toast Should Be Visible    ${MSG}[cartStockLimit]
    Cart Quantity Should Be    ${PRODUCT_ID}    ${stock}

TC-07-05 (TC9005) ลบสินค้ารายการเดียว
    [Tags]    TS-07-03    positive
    Add To Cart    ${PRODUCT_ID}    1
    Add To Cart    ${SECOND_PRODUCT_ID}    1
    Go To Cart
    ${row}=    Cart Row    ${PRODUCT_ID}
    Click    ${row} >> css=[data-test="btn-remove-item"]
    Text Should Be Visible    ${MSG}[confirmRemoveItem]
    Confirm Dialog
    Toast Should Be Visible    ${MSG}[itemRemoved]
    Wait For Elements State    css=[data-test="checkbox-product-${PRODUCT_ID}"]    detached
    Wait For Elements State    css=[data-test="checkbox-product-${SECOND_PRODUCT_ID}"]    visible

TC-07-06 (TC9006) ลบสินค้าที่เลือกทั้งหมด
    [Tags]    TS-07-03    positive
    Add To Cart    ${PRODUCT_ID}    1
    Add To Cart    ${SECOND_PRODUCT_ID}    1
    Go To Cart
    Click    css=[data-test="radio-all-product"]
    Click    css=button:has-text("ลบออกทั้งหมด")
    Text Should Be Visible    ${MSG}[confirmRemoveAll]
    Confirm Dialog
    Toast Should Be Visible    ${MSG}[itemsRemoved]
    Wait For Elements State    css=[data-test="checkbox-product-${PRODUCT_ID}"]    detached
    Wait For Elements State    css=[data-test="checkbox-product-${SECOND_PRODUCT_ID}"]    detached
    # ถ้าไม่มีสินค้าไม่พร้อมจำหน่ายค้างอยู่ รถเข็นต้องว่าง
    IF    not $UNAVAILABLE_PRODUCT_ID    Text Should Be Visible    ${MSG}[emptyCart]

TC-07-07 (TC9007) กดลบออกทั้งหมดโดยไม่เลือกสินค้า
    [Tags]    TS-07-04    negative
    Add To Cart    ${PRODUCT_ID}    1
    Add To Cart    ${SECOND_PRODUCT_ID}    1
    Go To Cart
    ${before}=    Get Element Count    css=[data-test^="checkbox-product-"]
    Click    css=button:has-text("ลบออกทั้งหมด")
    Toast Should Be Visible    ${MSG}[selectItemFirst]
    Get Element Count    css=[data-test^="checkbox-product-"]    ==    ${before}


*** Keywords ***
Row Subtotal Should Be
    [Arguments]    ${product_id}    ${expected}
    ${n}=    Read Row Subtotal    ${product_id}
    Should Be Equal As Numbers    ${n}    ${expected}
