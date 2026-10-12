*** Settings ***
Documentation       Keyword ของสินค้าและรถเข็น
Resource            common.resource


*** Keywords ***
# ---------- สินค้า ----------
Open Product
    [Arguments]    ${product_id}
    Go To Path    /product/${product_id}
    Wait For Elements State    css=[data-test="btn-add-to-cart"]    visible

Read Stock
    [Documentation]    อ่านจาก "มีสินค้าทั้งหมด N ชิ้น"
    ${text}=    Get Text    text=/มีสินค้าทั้งหมด\\s*\\d+\\s*ชิ้น/
    ${n}=    To Number    ${text}
    RETURN    ${n}

Read Buy Quantity
    ${text}=    Get Text    css=[data-test="buy-quantity"]
    ${n}=    To Number    ${text}
    RETURN    ${n}

Read Product Info
    [Documentation]    คืนค่า dict: name, price, stock ของหน้ารายละเอียดสินค้า
    [Arguments]    ${product_id}
    Open Product    ${product_id}
    ${name}=    Get Text    css=[data-test="product-name"]
    ${price_text}=    Get Text    text=/฿\\s*[\\d,]+/ >> nth=0
    ${price}=    To Number    ${price_text}
    ${stock}=    Read Stock
    ${name}=    Strip String    ${name}
    &{info}=    Create Dictionary    name=${name}    price=${price}    stock=${stock}
    RETURN    ${info}

Click Increase Times
    [Arguments]    ${times}
    FOR    ${i}    IN RANGE    ${times}
        Click    css=[data-test="btn-increase"]
    END

Add To Cart
    [Arguments]    ${product_id}    ${quantity}=1
    Open Product    ${product_id}
    Click Increase Times    ${${quantity} - 1}
    Click    css=[data-test="btn-add-to-cart"]
    Toast Should Be Visible    ${MSG}[addedToCart]

Skip If Stock Too Large
    [Arguments]    ${stock}
    Skip If    ${stock} > 150    สต็อกมี ${stock} ชิ้น มากเกินไปสำหรับการกดทีละชิ้น ให้ใช้สินค้าที่สต็อกน้อยกว่า

# ---------- รถเข็น ----------
Go To Cart
    Go To Path    /shopping-cart
    Wait For Elements State    css=[data-test="total-price"], p:has-text("${MSG}[emptyCart]")    visible

Cart Row
    [Documentation]    แถวสินค้าในรถเข็น = div (border-b) ที่ใกล้ที่สุดซึ่งครอบ checkbox ของสินค้า
    [Arguments]    ${product_id}
    RETURN    xpath=//*[@data-test="checkbox-product-${product_id}"]/ancestor::div[contains(@class,"border-b")][1]

Cart Quantity Should Be
    [Arguments]    ${product_id}    ${expected}
    ${row}=    Cart Row    ${product_id}
    Get Text    ${row} >> css=[data-test="item-quantity"]    ==    ${expected}

Read Row Subtotal
    [Arguments]    ${product_id}
    ${row}=    Cart Row    ${product_id}
    ${text}=    Get Text    ${row} >> css=[data-test="subtotal-product"]
    ${n}=    To Number    ${text}
    RETURN    ${n}

Cart Product Ids
    ${ids}=    Evaluate JavaScript    ${None}
    ...    () => [...document.querySelectorAll('[data-test^="checkbox-product-"]')].map(e => e.dataset.test.replace('checkbox-product-', ''))
    RETURN    ${ids}

Clear Cart
    [Documentation]    ลบสินค้าทุกรายการในรถเข็น ยกเว้นสินค้าที่ระบุใน keep (เช่น UNAVAILABLE_PRODUCT_ID)
    [Arguments]    ${keep}=${UNAVAILABLE_PRODUCT_ID}
    Go To Cart
    FOR    ${i}    IN RANGE    30
        ${ids}=    Cart Product Ids
        ${targets}=    Evaluate    [x for x in $ids if x != str($keep)]
        IF    not $targets    BREAK
        ${row}=    Cart Row    ${targets}[0]
        Click    ${row} >> css=[data-test="btn-remove-item"]
        Confirm Dialog
        Toast Should Be Visible    ${MSG}[itemRemoved]
        Wait For Elements State    css=[data-test="checkbox-product-${targets}[0]"]    detached
    END

Cart Badge
    ${count}=    Get Element Count    css=[data-test="click-shop-cart"] span
    IF    ${count} == 0    RETURN    ${0}
    ${text}=    Get Text    css=[data-test="click-shop-cart"]
    ${n}=    To Number    ${text}
    RETURN    ${n}
