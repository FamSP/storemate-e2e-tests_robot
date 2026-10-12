*** Settings ***
Documentation       US-04 ค้นหาและกรองสินค้า (UC-06)
Resource            ../../resources/storemate.resource
Suite Setup         Open StoreMate Browser
Suite Teardown      Close Browser
Test Setup          Open Guest Page
Test Teardown       Close Context
Test Tags           US-04    guest


*** Variables ***
${CARDS}        css=[data-test="product-card"]:visible


*** Test Cases ***
TC-04-01 (TC6001) ค้นหาสินค้าด้วย Keyword
    [Tags]    TS-04-01    positive
    Search Products    keyword=น้ำ
    Get Element Count    ${CARDS}    >    0
    Wait Until Keyword Succeeds    15s    500ms    Every Card Should Contain    น้ำ

TC-04-02 (TC6002) กรองด้วยหมวดหมู่โดยไม่ระบุ Keyword
    [Tags]    TS-04-01    positive
    Search Products    category=drink
    Url Should Contain    category=drinks
    Get Element Count    ${CARDS}    >    0

TC-04-03 (TC6004) กรองสินค้าด้วยช่วงราคา 35-500
    [Tags]    TS-04-01    positive
    Search Products    min=35    max=500
    Get Element Count    ${CARDS}    >    0
    Every Price Should Be Between    35    500

TC-04-04 (TC6005) ค้นหาด้วย Keyword ร่วมกับช่วงราคา
    [Tags]    TS-04-01    positive
    Search Products    keyword=น้ำ    min=35    max=500
    Get Element Count    ${CARDS}    >    0
    Wait Until Keyword Succeeds    15s    500ms    Every Card Should Contain    น้ำ
    Every Price Should Be Between    35    500

TC-04-05 (TC6003) ค้นหาสินค้าที่ไม่มีในระบบ
    [Tags]    TS-04-02    negative
    Search Products    keyword=มือถือ
    Text Should Be Visible    ${MSG}[searchNotFound]
    Get Element Count    ${CARDS}    ==    0


*** Keywords ***
Search Products
    [Arguments]    ${keyword}=${None}    ${category}=${None}    ${min}=${None}    ${max}=${None}
    Go To Path    /search
    IF    $keyword is not None    Fill Text    css=[data-test="input-search"]    ${keyword}
    IF    $category    Click    css=[data-test="category-${category}"]
    IF    $min is not None    Fill Text    css=[data-test="input-min-price"]    ${min}
    IF    $max is not None    Fill Text    css=[data-test="input-max-price"]    ${max}
    Click    css=[data-test="apply-price-filter"]
    # รอให้ URL มีเงื่อนไขค้นหา แล้วรอผลค้นหาชุดใหม่โหลดเสร็จ
    IF    $keyword    Wait Until Keyword Succeeds    15s    500ms    Url Should Contain    keyword=
    IF    $min is not None    Wait Until Keyword Succeeds    15s    500ms    Url Should Contain    minPrice=
    Wait For Load State    networkidle
    Wait For Elements State    css=[data-test="product-card"], p:has-text("${MSG}[searchNotFound]")    visible
    Wait Until Keyword Succeeds    15s    500ms    Shown Count Should Match Cards

Shown Count Should Match Cards
    [Documentation]    จำนวนใน "พบสินค้า N รายการ" ต้องเท่ากับจำนวนการ์ดที่เห็น
    ${text}=    Get Text    css=[data-test="filteredProduct"]
    ${shown}=    To Number    ${text}
    Get Element Count    ${CARDS}    ==    ${shown}

Every Card Should Contain
    [Arguments]    ${word}
    ${texts}=    Get All Card Texts
    FOR    ${t}    IN    @{texts}
        Should Contain    ${t}    ${word}
    END

Every Price Should Be Between
    [Arguments]    ${low}    ${high}
    ${texts}=    Get All Card Texts
    FOR    ${t}    IN    @{texts}
        ${price}=    Price From Text    ${t}
        Should Be True    ${low} <= ${price} <= ${high}    ราคา ${price} อยู่นอกช่วง ${low}-${high}
    END

Get All Card Texts
    ${texts}=    Evaluate JavaScript    ${None}
    ...    () => [...document.querySelectorAll('[data-test="product-card"]')].filter(e => e.offsetParent !== null).map(e => e.innerText)
    RETURN    ${texts}
