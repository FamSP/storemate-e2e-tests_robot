*** Settings ***
Documentation       US-02 เข้าสู่ระบบ (UC-02)
Resource            ../../resources/storemate.resource
Suite Setup         Open StoreMate Browser
Suite Teardown      Close Browser
Test Setup          Open Guest Page
Test Teardown       Close Context
Test Tags           US-02    guest


*** Test Cases ***
TC-02-01 (TC2001) เข้าสู่ระบบสำเร็จด้วยบัญชี Customer
    [Documentation]    TS-02-01 เข้าสู่ระบบด้วยข้อมูลที่ถูกต้อง
    [Tags]    TS-02-01    positive
    Go To Path    /
    Click    css=[data-test="login-btn"]
    Url Should Contain    /login
    Fill Text    css=[data-test="email"]    ${CUSTOMER_EMAIL}
    Fill Text    css=[data-test="password"]    ${CUSTOMER_PASSWORD}
    Click    css=[data-test="btn-submit"]
    Toast Should Be Visible    ${MSG}[loginSuccess]
    Wait Until Keyword Succeeds    15s    500ms    Url Should Match    ^${BASE_URL}/?$    # Customer ไปหน้าร้าน
    Wait For Elements State    css=[data-test="login-btn"]    hidden

TC-02-02 (TC2004) อีเมลหรือรหัสผ่านไม่ถูกต้อง
    [Tags]    TS-02-02    negative
    Login Via UI    ${CUSTOMER_EMAIL}    Wrong1234
    Toast Should Be Visible    ${MSG}[loginInvalid]
    Url Should Contain    /login

TC-02-03 (TC2005) เข้าสู่ระบบด้วยบัญชีที่ถูกระงับ
    [Tags]    TS-02-02    negative
    Skip If    not $SUSPENDED_EMAIL    ไม่ได้กำหนด SUSPENDED_EMAIL ใน .env
    Login Via UI    ${SUSPENDED_EMAIL}    ${SUSPENDED_PASSWORD}
    Toast Should Be Visible    ${MSG}[loginSuspended]
    Url Should Contain    /login

TC-02-04 (TC2006) กรอกข้อมูลไม่ครบ
    [Tags]    TS-02-02    negative
    Login Via UI    ${EMPTY}    ${EMPTY}
    Toast Should Be Visible    ${MSG}[loginIncomplete]
    Url Should Contain    /login
