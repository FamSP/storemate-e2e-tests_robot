*** Settings ***
Documentation       Keyword ของที่อยู่จัดส่ง
Resource            common.resource


*** Keywords ***
Go To Addresses
    Go To Path    /address-profile
    Wait For Elements State    css=[data-test="address-detail"], p:has-text("${MSG}[noAddress]")    visible

Has No Address
    ${count}=    Get Element Count    css=p:has-text("${MSG}[noAddress]")
    RETURN    ${count > 0}

Select First Option
    [Arguments]    ${select}
    Wait For Elements State    ${select}    enabled
    Wait For Elements State    ${select} >> css=option:not([hidden]) >> nth=0    attached
    ${value}=    Get Attribute    ${select} >> css=option:not([hidden]) >> nth=0    value
    Select Options By    ${select}    value    ${value}

Add Address
    [Documentation]    เพิ่มที่อยู่ใหม่ (เลือกจังหวัด/อำเภอ/ตำบลตัวแรก) คืนค่าบ้านเลขที่ที่ใช้
    [Arguments]    ${street}=${EMPTY}
    IF    not $street
        ${stamp}=    Timestamp
        ${street}=    Set Variable    99/9 หมู่ 1 QA-${stamp}
    END
    Go To Addresses
    Click    css=[data-test="btn-add-address"]
    Fill Text    css=input[name="streetAddress"]    ${street}
    Select First Option    css=select[name="province"]
    Select First Option    css=select[name="district"]
    Select First Option    css=select[name="subDistrict"]
    ${zip}=    Set Variable    css=select:not([name]) >> nth=-1
    ${states}=    Get Element States    ${zip}
    ${zip_value}=    Get Property    ${zip}    value
    IF    'enabled' in $states and not $zip_value    Select First Option    ${zip}
    Click    css=[data-test="btn-save-address"]
    Toast Should Be Visible    ${MSG}[addressAdded]
    Wait For Elements State    css=[data-test="address-detail"]:has-text("${street}")    visible
    RETURN    ${street}

Ensure Address
    Go To Addresses
    ${none}=    Has No Address
    IF    ${none}    Add Address

Address Card
    [Documentation]    การ์ดที่อยู่ = div (p-4) ที่ใกล้ที่สุดซึ่งครอบข้อความที่อยู่
    [Arguments]    ${street}
    RETURN    xpath=//*[@data-test="address-detail"][contains(., "${street}")]/ancestor::div[contains(@class,"p-4")][1]

Default Badge Should Be Visible
    [Documentation]    ป้าย "ค่าเริ่มต้น" (exact เพราะปุ่ม "ตั้งเป็นค่าเริ่มต้น" ก็มีคำนี้)
    [Arguments]    ${street}
    ${card}=    Address Card    ${street}
    Wait For Elements State    ${card} >> xpath=.//span[normalize-space()="ค่าเริ่มต้น"]    visible

Set Default Address
    [Arguments]    ${street}
    ${card}=    Address Card    ${street}
    ${states}=    Get Element States    ${card} >> css=[data-test="btn-set-default"]
    IF    'enabled' in $states
        Click    ${card} >> css=[data-test="btn-set-default"]
        Toast Should Be Visible    ${MSG}[addressDefault]
    END
    Default Badge Should Be Visible    ${street}

Delete Address
    [Arguments]    ${street}
    ${card}=    Address Card    ${street}
    Click    ${card} >> css=[data-test^="btn-delete-address-"]
    Text Should Be Visible    ${MSG}[confirmDeleteAddress]
    Confirm Dialog
    Toast Should Be Visible    ${MSG}[addressDeleted]
    Get Element Count    css=[data-test="address-detail"]:has-text("${street}")    ==    0

Delete QA Addresses
    [Documentation]    ลบที่อยู่ที่เทสสร้าง (มีคำว่า QA-) แต่คงไว้อย่างน้อย 1 รายการ
    Go To Addresses
    FOR    ${i}    IN RANGE    20
        ${all}=    Get Element Count    css=[data-test="address-detail"]
        ${qa}=    Get Element Count    css=[data-test="address-detail"]:has-text("QA-")
        IF    ${all} <= 1 or ${qa} == 0    BREAK
        ${text}=    Get Text    css=[data-test="address-detail"]:has-text("QA-") >> nth=0
        ${street}=    Street Of    ${text}
        Delete Address    ${street}
    END
