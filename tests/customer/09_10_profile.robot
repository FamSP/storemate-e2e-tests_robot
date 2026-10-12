*** Settings ***
Documentation       US-09 ดูโปรไฟล์ และ US-10 แก้ไขโปรไฟล์ (UC-08)
...                 TC-10-02 (แก้ไขอีเมลสำเร็จ) อยู่ใน tests/fresh เพราะระบบจะออกจากระบบหลังเปลี่ยนอีเมล
Resource            ../../resources/storemate.resource
Suite Setup         Prepare Customer Session
Suite Teardown      Close Browser
Test Setup          Open Profile Page
Test Teardown       Close Context
Test Tags           customer


*** Test Cases ***
TC-09-01 (TC11001) เข้าหน้าโปรไฟล์และแสดงข้อมูลครบ
    [Documentation]    TS-09-01 เปิดหน้าโปรไฟล์จากเมนูผู้ใช้
    [Tags]    US-09    TS-09-01    positive
    Go To Path    /
    Click    css=[data-test="btn-user-profile"]
    Click    css=[data-test="btn-edit-profile"]
    Wait Until Keyword Succeeds    15s    500ms    Url Should Contain    /profile
    Wait For Elements State    css=[data-test="profile-image"], [data-test="default-profile-icon"]    visible
    Get Text    css=[data-test="profile-name"]    !=    ${EMPTY}
    Get Text    css=[data-test="profile-email"]    *=    @
    Get Text    css=[data-test="profile-phone"]    matches    \\d{2}$
    Get Text    css=[data-test="profile-created-at"]    !=    ${EMPTY}

TC-10-01 (TC12001) แก้ไขชื่อ-นามสกุลสำเร็จ
    [Tags]    US-10    TS-10-01    positive
    ${original}=    Get Text    css=[data-test="profile-name"]
    ${stamp}=    Timestamp
    ${new_name}=    Set Variable    สมชาย ใจดี QA${stamp}[-3:]
    Edit Profile Field    name    ${new_name}
    Toast Should Be Visible    ${MSG}[profileSaved]
    Get Text    css=[data-test="profile-name"]    *=    ${new_name}
    Edit Profile Field    name    ${original.strip()}    # คืนค่าเดิม
    Toast Should Be Visible    ${MSG}[profileSaved]

TC-10-03 (TC12003) อัปโหลดรูปโปรไฟล์ JPG/JPEG
    [Tags]    US-10    TS-10-01    positive
    Upload Profile Image    profile-valid.jpg
    Click    css=[data-test="btn-save-crop"]
    Toast Should Be Visible    ${MSG}[profileSaved]
    Wait For Elements State    css=[data-test="profile-image"]    visible

TC-10-04 (TC12004) อัปโหลดรูปโปรไฟล์ PNG
    [Tags]    US-10    TS-10-01    positive
    Upload Profile Image    profile-valid.png
    Click    css=[data-test="btn-save-crop"]
    Toast Should Be Visible    ${MSG}[profileSaved]
    Wait For Elements State    css=[data-test="profile-image"]    visible

TC-10-05 (TC12005) อัปโหลดไฟล์เกิน 5 MB
    [Tags]    US-10    TS-10-02    negative
    Upload Profile Image    4k-invalid.jpg    # ~7 MB
    Toast Should Be Visible    ${MSG}[fileTooLarge]
    Get Element Count    css=[data-test="btn-save-crop"]:visible    ==    0

TC-10-06 (TC12006) อัปโหลดไฟล์ที่ไม่ใช่ PNG/JPG/JPEG
    [Tags]    US-10    TS-10-02    negative
    Upload Profile Image    profile-invalid.txt
    Toast Should Be Visible    ${MSG}[fileType]
    Get Element Count    css=[data-test="btn-save-crop"]:visible    ==    0

TC-10-07 (TC12007) อีเมลผิดรูปแบบ
    [Tags]    US-10    TS-10-03    negative
    ${before}=    Get Text    css=[data-test="profile-email"]
    Edit Profile Field    email    somchaigmail.com
    Toast Should Be Visible    ${MSG}[invalidEmail]
    Reload
    Get Text    css=[data-test="profile-email"]    ==    ${before}

TC-10-08 (TC12008) อีเมลซ้ำกับผู้ใช้อื่น
    [Tags]    US-10    TS-10-03    negative
    ${email}=    Set Variable    ${EXISTING_EMAIL}
    IF    not $email
        ${spare}=    Register Spare User
        ${email}=    Set Variable    ${spare}[email]
    END
    Edit Profile Field    email    ${email}
    Toast Should Be Visible    ${MSG}[duplicateEmail]
    Url Should Contain    /profile    # ไม่ถูกออกจากระบบ

TC-10-09 (TC12009) เบอร์โทรศัพท์ซ้ำกับผู้ใช้อื่น
    [Tags]    US-10    TS-10-03    negative
    ${phone}=    Set Variable    ${EXISTING_PHONE}
    IF    not $phone
        ${spare}=    Register Spare User
        ${phone}=    Set Variable    ${spare}[phone]
    END
    ${before}=    Get Text    css=[data-test="profile-phone"]
    Edit Profile Field    phone    ${phone}
    Toast Should Be Visible    ${MSG}[duplicatePhone]
    Reload
    Get Text    css=[data-test="profile-phone"]    ==    ${before}


*** Keywords ***
Open Profile Page
    Open Customer Page
    Go To Path    /profile
    Wait For Elements State    css=[data-test="profile-name"]    visible

Edit Profile Field
    [Arguments]    ${field}    ${value}
    Click    css=[data-test="btn-change-${field}"]
    Fill Text    css=[data-test="input-${field}"]    ${value}
    Click    css=[data-test="edit-modal-save-button"]

Upload Profile Image
    [Arguments]    ${file}
    Click    css=[data-test="btn-open-image-modal"]
    Wait For Elements State    css=[data-test="image-modal"]    visible
    Upload File By Selector    css=[data-test="file-input"]    ${IMAGES}${/}${file}
