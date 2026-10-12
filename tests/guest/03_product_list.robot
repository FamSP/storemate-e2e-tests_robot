*** Settings ***
Documentation       US-03 ดูรายการสินค้า (UC-05)
Resource            ../../resources/storemate.resource
Suite Setup         Open StoreMate Browser
Suite Teardown      Close Browser
Test Setup          Open Guest Page
Test Teardown       Close Context
Test Tags           US-03    guest


*** Variables ***
@{SECTIONS}         promotion-section    soap-section    drinks-section    shampoo-section


*** Test Cases ***
TC-03-01 (TC5001) แสดงรายการสินค้าตามหมวดหมู่
    [Documentation]    TS-03-01 แสดงสินค้าตามหมวดหมู่ หมวดละไม่เกิน 4 รายการ
    [Tags]    TS-03-01    positive
    Wait For Home Products
    FOR    ${section}    IN    @{SECTIONS}
        Wait For Elements State    id=${section}    visible
        ${count}=    Get Element Count    id=${section} >> css=[data-test="product-card"]
        Should Be True    ${count} <= 4    หมวด ${section} แสดงสินค้า ${count} รายการ (เกิน 4)
    END
    Get Element Count    css=[data-test="product-card"]    >    0

TC-03-02 (TC5002) หมวดหมู่ที่ไม่มีสินค้า
    [Documentation]    TS-03-02 หมวดหมู่ที่ไม่มีสินค้าต้องแสดง "ไม่พบรายการสินค้า"
    [Tags]    TS-03-02    negative
    Wait For Home Products
    ${empty}=    Get Element Count    css=section:has-text("${MSG}[emptyCategory]")
    Skip If    ${empty} == 0    ตอนนี้ทุกหมวดมีสินค้า จึงทดสอบกรณีหมวดว่างไม่ได้
    Get Element Count    css=section:has-text("${MSG}[emptyCategory]") >> nth=0 >> css=[data-test="product-card"]    ==    0


*** Keywords ***
Wait For Home Products
    Go To Path    /
    Wait For Elements State    css=[data-test="product-card"] >> nth=0    visible
    Wait For Load State    networkidle
