*** Settings ***
Documentation       Keyword พื้นฐาน: เปิดเบราว์เซอร์ เข้าสู่ระบบ สมัครสมาชิก และตรวจ toast
Library             Browser    timeout=15s    strict=False    run_on_failure=Take Screenshot    retry_assertions_for=15s
Library             Collections
Library             String
Library             ${CURDIR}/StoreMateLibrary.py
Variables           ${CURDIR}/config.py


*** Keywords ***
# ---------- เบราว์เซอร์ ----------
Open StoreMate Browser
    [Documentation]    เปิดเบราว์เซอร์ 1 ครั้งต่อ suite
    New Browser    chromium    headless=${HEADLESS}

Open Guest Page
    [Documentation]    context ใหม่ที่ยังไม่เข้าสู่ระบบ (ใช้เป็น Test Setup)
    New Context    viewport={'width': 1440, 'height': 900}    locale=th-TH    timezoneId=Asia/Bangkok
    New Page    ${BASE_URL}/

Open Customer Page
    [Documentation]    context ใหม่ที่เข้าสู่ระบบบัญชีลูกค้าแล้ว (ใช้ session จาก Prepare Customer Session)
    New Context    viewport={'width': 1440, 'height': 900}    locale=th-TH    timezoneId=Asia/Bangkok
    ...    storageState=${CUSTOMER_STATE}
    New Page    ${BASE_URL}/

Prepare Customer Session
    [Documentation]    Suite Setup ของเทสฝั่งลูกค้า: เข้าสู่ระบบครั้งเดียว เตรียมที่อยู่ แล้วเก็บ session
    Open StoreMate Browser
    Open Guest Page
    Login Via UI    ${CUSTOMER_EMAIL}    ${CUSTOMER_PASSWORD}
    Toast Should Be Visible    ${MSG}[loginSuccess]
    Url Should Not Contain    /login
    Ensure Address
    ${state}=    Save Storage State
    Set Suite Variable    ${CUSTOMER_STATE}    ${state}
    Close Context

Go To Path
    [Arguments]    ${path}
    Go To    ${BASE_URL}${path}

Url Should Contain
    [Arguments]    ${part}
    Get Url    contains    ${part}

Url Should Not Contain
    [Arguments]    ${part}
    Wait Until Keyword Succeeds    15s    500ms    Url Does Not Contain    ${part}

Url Does Not Contain
    [Arguments]    ${part}
    ${url}=    Get Url
    Should Not Contain    ${url}    ${part}

Url Should Match
    [Arguments]    ${regex}
    Get Url    matches    ${regex}

# ---------- ตัวเลือกและการตรวจข้อความ ----------
Tid
    [Documentation]    ตัวเลือกจาก data-test เช่น [data-test="btn-submit"]
    [Arguments]    ${id}
    RETURN    css=[data-test="${id}"]

Toast Should Be Visible
    [Documentation]    toast ของ react-hot-toast อยู่ใน role="status" (ข้อความขึ้นต้นด้วย / คือ regex)
    [Arguments]    ${text}
    Wait For Elements State    css=[role="status"] >> text=${text}    visible

Text Should Be Visible
    [Arguments]    ${text}
    Wait For Elements State    text=${text}    visible

Confirm Dialog
    [Documentation]    กดปุ่มใน ConfirmToast ("ยืนยัน" หรือ "ยกเลิก")
    [Arguments]    ${answer}=ยืนยัน
    Click    xpath=(//button[normalize-space()="${answer}"])[1]

# ---------- บัญชีผู้ใช้ ----------
Fill Register Form
    [Arguments]    ${name}=    ${email}=    ${phone}=    ${password}=    ${confirm}=
    Go To Path    /register
    Fill Text    css=[data-test="reg-input-name"]    ${name}
    Fill Text    css=[data-test="reg-input-email"]    ${email}
    Fill Text    css=[data-test="reg-input-phone"]    ${phone}
    Fill Text    css=[data-test="reg-input-password"]    ${password}
    Fill Text    css=[data-test="reg-input-confirm"]    ${confirm}
    Click    css=[data-test="btn-register-submit"]

Register Via UI
    [Arguments]    ${user}
    Fill Register Form    ${user}[name]    ${user}[email]    ${user}[phone]    ${user}[password]    ${user}[password]
    Toast Should Be Visible    ${MSG}[registerSuccess]
    Wait Until Keyword Succeeds    15s    500ms    Url Should Contain    /login

Login Via UI
    [Arguments]    ${email}    ${password}
    Go To Path    /login
    Fill Text    css=[data-test="email"]    ${email}
    Fill Text    css=[data-test="password"]    ${password}
    Click    css=[data-test="btn-submit"]

Create Fresh Customer
    [Documentation]    สมัครบัญชีใหม่แล้วเข้าสู่ระบบ คืนค่า dict ผู้ใช้
    [Arguments]    ${prefix}=qa
    ${user}=    Unique User    ${prefix}
    Register Via UI    ${user}
    Login Via UI    ${user}[email]    ${user}[password]
    Toast Should Be Visible    ${MSG}[loginSuccess]
    Url Should Not Contain    /login
    RETURN    ${user}

Register Spare User
    [Documentation]    สมัครบัญชีสำรองใน context แยก (ไม่กระทบ session ปัจจุบัน) เพื่อใช้เป็นข้อมูลซ้ำ
    ${current}=    Get Context Ids    CURRENT
    New Context
    New Page    ${BASE_URL}/
    ${user}=    Unique User    spare
    Register Via UI    ${user}
    Close Context
    Switch Context    ${current}[0]
    RETURN    ${user}
