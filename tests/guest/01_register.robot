*** Settings ***
Documentation       US-01 สมัครสมาชิก (UC-01)
Resource            ../../resources/storemate.resource
Suite Setup         Open StoreMate Browser
Suite Teardown      Close Browser
Test Setup          Open Guest Page
Test Teardown       Close Context
Test Tags           US-01    guest


*** Test Cases ***
TC-01-01 (TC1001) สมัครสมาชิกสำเร็จ
    [Documentation]    TS-01-01 สมัครสมาชิกด้วยข้อมูลครบถ้วนและถูกต้อง
    [Tags]    TS-01-01    positive
    ${user}=    Unique User    register
    Register Via UI    ${user}
    Login Via UI    ${user}[email]    ${user}[password]
    Toast Should Be Visible    ${MSG}[loginSuccess]
    Url Should Not Contain    /login

TC-01-02 (TC1002) ไม่กรอกชื่อ-นามสกุล
    [Tags]    TS-01-02    negative
    [Template]    Register With Missing Field Should Fail
    name    ${MSG}[requiredName]

TC-01-03 (TC1003) ไม่กรอกอีเมล
    [Tags]    TS-01-02    negative
    [Template]    Register With Missing Field Should Fail
    email    ${MSG}[requiredEmail]

TC-01-04 (TC1004) ไม่กรอกเบอร์โทรศัพท์
    [Tags]    TS-01-02    negative
    [Template]    Register With Missing Field Should Fail
    phone    ${MSG}[requiredPhone]

TC-01-05 (TC1005) ไม่กรอกรหัสผ่าน
    [Tags]    TS-01-02    negative
    [Template]    Register With Missing Field Should Fail
    password    ${MSG}[requiredPassword]

TC-01-06 (TC1006) ไม่กรอกยืนยันรหัสผ่าน
    [Tags]    TS-01-02    negative
    [Template]    Register With Missing Field Should Fail
    confirm    ${MSG}[requiredConfirm]

TC-01-07 (TC1007) รูปแบบอีเมลไม่ถูกต้อง
    [Tags]    TS-01-03    negative
    ${u}=    Unique User    format
    Fill Register Form    ${u}[name]    somchaigmail.com    ${u}[phone]    ${u}[password]    ${u}[password]
    Text Should Be Visible    ${MSG}[invalidEmail]
    Url Should Contain    /register

TC-01-08 (TC1009) เบอร์โทรศัพท์ไม่ถูกต้อง (เกิน 10 หลัก)
    [Tags]    TS-01-03    negative
    ${u}=    Unique User    format
    Fill Register Form    ${u}[name]    ${u}[email]    08111112345678    ${u}[password]    ${u}[password]
    Text Should Be Visible    ${MSG}[invalidPhone]
    Url Should Contain    /register

TC-01-09 (TC1008) อีเมลซ้ำในระบบ
    [Tags]    TS-01-04    negative
    ${u}=    Unique User    dup
    ${email}=    Set Variable If    $EXISTING_EMAIL    ${EXISTING_EMAIL}    ${CUSTOMER_EMAIL}
    Fill Register Form    ${u}[name]    ${email}    ${u}[phone]    ${u}[password]    ${u}[password]
    Toast Should Be Visible    ${MSG}[duplicateEmail]
    Url Should Contain    /register

TC-01-10 (TC10010) เบอร์โทรศัพท์ซ้ำในระบบ
    [Tags]    TS-01-04    negative
    ${phone}=    Set Variable    ${EXISTING_PHONE}
    IF    not $phone
        # ไม่ได้กำหนดเบอร์ที่มีอยู่แล้ว -> สมัครบัญชีขึ้นมาก่อน แล้วใช้เบอร์นั้นซ้ำ
        ${first}=    Unique User    dupphone
        Register Via UI    ${first}
        ${phone}=    Set Variable    ${first}[phone]
    END
    ${u}=    Unique User    dup
    Fill Register Form    ${u}[name]    ${u}[email]    ${phone}    ${u}[password]    ${u}[password]
    Toast Should Be Visible    ${MSG}[duplicatePhone]
    Url Should Contain    /register

TC-01-11 (TC10011) รหัสผ่านน้อยกว่า 8 ตัวอักษร
    [Tags]    TS-01-05    negative
    [Template]    Register With Password Should Fail
    Test1    Test1    ${MSG}[pwMin]

TC-01-12 (TC10012) รหัสผ่านไม่มีตัวพิมพ์ใหญ่
    [Tags]    TS-01-05    negative
    [Template]    Register With Password Should Fail
    test1234    test1234    ${MSG}[pwUpper]

TC-01-13 (TC10013) รหัสผ่านไม่มีตัวพิมพ์เล็ก
    [Tags]    TS-01-05    negative
    [Template]    Register With Password Should Fail
    TEST1234    TEST1234    ${MSG}[pwLower]

TC-01-14 (TC10014) รหัสผ่านไม่มีตัวเลข
    [Tags]    TS-01-05    negative
    [Template]    Register With Password Should Fail
    TESTtest    TESTtest    ${MSG}[pwDigit]

TC-01-15 (TC10015) รหัสผ่านและยืนยันรหัสผ่านไม่ตรงกัน
    [Tags]    TS-01-05    negative
    [Template]    Register With Password Should Fail
    ${VALID_PASSWORD}    Test5678    ${MSG}[pwMismatch]


*** Keywords ***
Register With Missing Field Should Fail
    [Arguments]    ${field}    ${message}
    &{u}=    Unique User    required
    Set To Dictionary    ${u}    confirm=${u}[password]
    Set To Dictionary    ${u}    ${field}=${EMPTY}
    Fill Register Form    ${u}[name]    ${u}[email]    ${u}[phone]    ${u}[password]    ${u}[confirm]
    Text Should Be Visible    ${message}
    Url Should Contain    /register

Register With Password Should Fail
    [Arguments]    ${password}    ${confirm}    ${message}
    ${u}=    Unique User    password
    Fill Register Form    ${u}[name]    ${u}[email]    ${u}[phone]    ${password}    ${confirm}
    Text Should Be Visible    ${message}
    Url Should Contain    /register
