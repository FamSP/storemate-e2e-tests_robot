*** Settings ***
Documentation       US-04 ค้นหาและกรองสินค้า (UC-06) — ชุดหลัก + ชุดเพิ่มเติม รวมในไฟล์เดียว
...                 ชุดเพิ่มเติมไม่มีในเอกสารเดิม จึงใช้ป้าย (เพิ่มเติม) แทนรหัสเดิม
Resource            ../../resources/storemate.resource
Suite Setup         Open StoreMate Browser
Suite Teardown      Close Browser
Test Setup          Open Guest Page
Test Teardown       Close Context
Test Tags           US-04    guest


*** Variables ***
${CARDS}        css=[data-test="product-card"]:visible


*** Test Cases ***
# ---------- ชุดหลัก (ตามเอกสาร) ----------
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

# ---------- ชุดเพิ่มเติม ----------
TC-04-09 (เพิ่มเติม) ค้นหาด้วยอักขระพิเศษ
    [Tags]    TS-04-02    negative
    Open Search
    Fill Text    css=[data-test="input-search"]    @@@
    Click    css=[data-test="apply-price-filter"]
    Wait Until Keyword Succeeds    15s    500ms    Url Should Contain    keyword=
    Wait For Results
    Text Should Be Visible    ${MSG}[searchNotFound]
    Get Element Count    ${CARDS}    ==    0

TC-04-06 (เพิ่มเติม) กด Enter ในช่องค้นหา
    [Tags]    TS-04-03    positive
    Open Search
    Fill Text    css=[data-test="input-search"]    สบู่
    Keyboard Key    press    Enter
    Wait Until Keyword Succeeds    15s    500ms    Url Should Contain    keyword=
    Wait For Results
    Get Element Count    ${CARDS}    >    0
    Wait Until Keyword Succeeds    15s    500ms    Every Card Should Contain    สบู่

TC-04-07 (เพิ่มเติม) ค้นหาจากไอคอนแว่นขยายบนแถบเมนู
    [Tags]    TS-04-03    positive
    Go To Path    /
    Click    css=[data-test="search"] svg >> nth=0
    Fill Text    css=[data-test="search-input"]    สบู่
    Keyboard Key    press    Enter
    Wait Until Keyword Succeeds    15s    500ms    Url Should Contain    /search?keyword=
    Wait For Results
    Get Element Count    ${CARDS}    >    0

TC-04-08 (เพิ่มเติม) เปิดลิงก์ที่มีคำค้น ช่องค้นหาแสดงคำนั้น
    [Tags]    TS-04-03    positive
    ${q}=    Evaluate    urllib.parse.quote('สบู่')    modules=urllib.parse
    Open Search    ?keyword=${q}
    Get Property    css=[data-test="input-search"]    value    ==    สบู่
    Get Element Count    ${CARDS}    >    0

TC-04-10 (เพิ่มเติม) หมวด "ทั้งหมด" แสดงจำนวนเท่ากับไม่กรอง
    [Tags]    TS-04-04    positive
    Open Search
    ${all}=    Get Element Count    ${CARDS}
    Click    css=[data-test="category-soap"]
    Wait For Results
    Click    css=[data-test="category-all"]
    Wait Until Keyword Succeeds    15s    500ms    Url Should Not Match    category=
    Wait For Results
    Get Element Count    ${CARDS}    ==    ${all}

TC-04-11 (เพิ่มเติม) หมวด "สบู่" แสดงผลตรงกับจำนวนที่พบ
    [Tags]    TS-04-04    positive
    [Template]    Category Filter Should Work
    soap    soap

TC-04-12 (เพิ่มเติม) หมวด "แชมพู" แสดงผลตรงกับจำนวนที่พบ
    [Tags]    TS-04-04    positive
    [Template]    Category Filter Should Work
    shampoo    shampoo

TC-04-13 (เพิ่มเติม) หมวด "เครื่องดื่ม" แสดงผลตรงกับจำนวนที่พบ
    [Tags]    TS-04-04    positive
    [Template]    Category Filter Should Work
    drink    drinks

TC-04-14 (เพิ่มเติม) ใส่ราคาต่ำสุดอย่างเดียว
    [Tags]    TS-04-05    positive
    Open Search
    Apply Price    min=300
    Url Should Contain    minPrice=300
    Every Price Should Be Between    300    1000000

TC-04-15 (เพิ่มเติม) ใส่ราคาสูงสุดอย่างเดียว
    [Tags]    TS-04-05    positive
    Open Search
    Apply Price    max=100
    Url Should Contain    maxPrice=100
    Every Price Should Be Between    0    100

TC-04-16 (เพิ่มเติม) ราคาต่ำสุดมากกว่าราคาสูงสุด
    [Tags]    TS-04-05    negative
    Open Search
    Apply Price    min=500    max=100
    Text Should Be Visible    ${MSG}[searchNotFound]
    Get Element Count    ${CARDS}    ==    0

TC-04-17 (เพิ่มเติม) ผลลัพธ์เรียงจากราคาน้อยไปมาก
    [Tags]    TS-04-05    positive
    Open Search
    ${prices}=    Get Card Prices
    ${n}=    Get Length    ${prices}
    Should Be True    ${n} > 1
    ${sorted}=    Evaluate    sorted($prices)
    Should Be Equal    ${prices}    ${sorted}

TC-04-18 (เพิ่มเติม) กด "ล้างค่า" แล้วคำค้นและตัวกรองถูกล้าง
    [Tags]    TS-04-06    positive
    Open Search
    ${all}=    Get Element Count    ${CARDS}
    Fill Text    css=[data-test="input-search"]    สบู่
    Apply Price    min=100    max=300
    Url Should Match    keyword=.*minPrice=100
    Click    css=[data-test="clear-filter"]
    Wait Until Keyword Succeeds    15s    500ms    Url Should Match    /search$
    Get Property    css=[data-test="input-search"]    value    ==    ${EMPTY}
    Get Property    css=[data-test="input-min-price"]    value    ==    ${EMPTY}
    Get Property    css=[data-test="input-max-price"]    value    ==    ${EMPTY}
    Wait For Results
    Get Element Count    ${CARDS}    ==    ${all}


*** Keywords ***
Search Products
    [Documentation]    กรอกเงื่อนไขในหน้าค้นหาแล้วกด "ตกลง"
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
    Wait For Results

Open Search
    [Arguments]    ${query}=${EMPTY}
    Go To Path    /search${query}
    Wait For Results

Wait For Results
    [Documentation]    รอผลค้นหาชุดล่าสุด และ "พบสินค้า N รายการ" ตรงกับจำนวนการ์ด
    Wait For Load State    networkidle
    Wait For Elements State    css=[data-test="product-card"], p:has-text("${MSG}[searchNotFound]")    visible
    Wait Until Keyword Succeeds    15s    500ms    Shown Count Should Match Cards

Shown Count Should Match Cards
    ${text}=    Get Text    css=[data-test="filteredProduct"]
    ${shown}=    To Number    ${text}
    Get Element Count    ${CARDS}    ==    ${shown}

Apply Price
    [Arguments]    ${min}=${None}    ${max}=${None}
    IF    $min is not None    Fill Text    css=[data-test="input-min-price"]    ${min}
    IF    $max is not None    Fill Text    css=[data-test="input-max-price"]    ${max}
    Click    css=[data-test="apply-price-filter"]
    Wait For Results

Category Filter Should Work
    [Arguments]    ${button}    ${param}
    Open Search
    ${all}=    Get Element Count    ${CARDS}
    Click    css=[data-test="category-${button}"]
    Wait Until Keyword Succeeds    15s    500ms    Url Should Contain    category=${param}
    Wait For Results
    ${count}=    Get Element Count    ${CARDS}
    Should Be True    ${count} <= ${all}
    IF    ${count} == 0    Text Should Be Visible    ${MSG}[searchNotFound]    # หมวดว่างต้องแจ้งไม่พบ

Url Should Not Match
    [Arguments]    ${regex}
    ${url}=    Get Url
    Should Not Match Regexp    ${url}    ${regex}

Get Card Texts
    ${texts}=    Evaluate JavaScript    ${None}
    ...    () => [...document.querySelectorAll('[data-test="product-card"]')].filter(e => e.offsetParent !== null).map(e => e.innerText)
    RETURN    ${texts}

Get Card Prices
    ${texts}=    Get Card Texts
    ${prices}=    Create List
    FOR    ${t}    IN    @{texts}
        ${p}=    Price From Text    ${t}
        Append To List    ${prices}    ${p}
    END
    RETURN    ${prices}

Every Card Should Contain
    [Arguments]    ${word}
    ${texts}=    Get Card Texts
    FOR    ${t}    IN    @{texts}
        Should Contain    ${t}    ${word}
    END

Every Price Should Be Between
    [Arguments]    ${low}    ${high}
    ${prices}=    Get Card Prices
    FOR    ${p}    IN    @{prices}
        Should Be True    ${low} <= ${p} <= ${high}    ราคา ${p} อยู่นอกช่วง ${low}-${high}
    END
