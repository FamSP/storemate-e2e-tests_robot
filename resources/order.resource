*** Settings ***
Documentation       Keyword ของการสั่งซื้อ ชำระเงิน และคำสั่งซื้อ
Resource            common.resource
Resource            shop.resource


*** Keywords ***
# ---------- สั่งซื้อ / ชำระเงิน ----------
Buy Now
    [Documentation]    กด "สั่งซื้อสินค้า" จากหน้ารายละเอียดสินค้า แล้วรอหน้าสรุปคำสั่งซื้อ
    [Arguments]    ${product_id}
    Open Product    ${product_id}
    Click    css=[data-test="btn-buy-cart"]
    Wait Until Keyword Succeeds    15s    500ms    Url Should Match    /payment$
    Wait For Elements State    css=[data-test="order-item"]    visible
    # ต้องรอที่อยู่เริ่มต้นโหลดเสร็จก่อน ไม่อย่างนั้นกดยืนยันแล้วจะขึ้น "กรุณาเลือกที่อยู่ในการรับสินค้า"
    Wait For Elements State    css=[data-test="address"]    visible

Order Total Should Be
    [Arguments]    ${expected}
    Wait Until Keyword Succeeds    15s    500ms    Order Total Equals    ${expected}

Order Total Equals
    [Arguments]    ${expected}
    ${text}=    Get Text    css=[data-test="order-total-price-desktop"]
    ${n}=    To Number    ${text}
    Should Be Equal As Numbers    ${n}    ${expected}

Place COD Order
    [Documentation]    สั่งซื้อแบบเก็บเงินปลายทาง -> สถานะ "ที่ต้องจัดส่ง" คืนค่า orderNo (หรือ ${None} ถ้าอ่านไม่ได้)
    [Arguments]    ${product_id}
    Buy Now    ${product_id}
    Click    css=[data-test="select-destination-desktop"]
    ${promise}=    Promise To    Wait For Response
    ...    matcher=(response) => response.request().method() === 'POST' && response.status() < 300
    ...    timeout=30s
    Click    css=[data-test="btn-confirm-payment-desktop"]
    Toast Should Be Visible    ${MSG}[orderSuccess]
    Wait Until Keyword Succeeds    15s    500ms    Url Should Contain    /orders
    ${order_no}=    Order No From Response    ${promise}
    RETURN    ${order_no}

Order No From Response
    [Arguments]    ${promise}
    ${status}    ${response}=    Run Keyword And Ignore Error    Wait For    ${promise}
    IF    $status != 'PASS'    RETURN    ${None}
    ${order_no}=    Evaluate    ($response.get('body') or {}).get('orderNo') if isinstance($response.get('body'), dict) else None
    RETURN    ${order_no}

Start PromptPay Payment
    [Arguments]    ${product_id}
    Buy Now    ${product_id}
    Click    css=[data-test="select-promptpay-desktop"]
    Click    css=[data-test="btn-confirm-payment-desktop"]
    Wait Until Keyword Succeeds    15s    500ms    Url Should Contain    /payment-qr
    Wait For Elements State    css=[data-test="promptpay-qr-image"]    visible
    ${order_no}=    LocalStorage Get Item    orderNo
    RETURN    ${order_no}

Place Pending Order
    [Documentation]    สร้างคำสั่งซื้อ PromptPay แล้วไม่ชำระ -> สถานะ "ที่ต้องชำระ" คืนค่า orderNo
    [Arguments]    ${product_id}
    ${order_no}=    Start PromptPay Payment    ${product_id}
    Click    css=button:has-text("ข้อมูลการชำระเงิน")
    RETURN    ${order_no}

# ---------- คำสั่งซื้อ ----------
Go To Orders
    [Arguments]    ${status}=ALL
    IF    $status == 'ALL'
        Go To Path    /orders
    ELSE
        Go To Path    /orders?status=${status}
    END
    Wait For Elements State    css=[data-test^="order-card-"], p:has-text("${MSG}[noOrders]")    visible

Order Card
    [Documentation]    การ์ดคำสั่งซื้อจาก orderNo ถ้าไม่มี orderNo ให้ใช้ใบแรก
    [Arguments]    ${order_no}=${None}
    IF    $order_no
        RETURN    css=[data-test^="order-card-"]:has([data-test="card-order-${order_no}"])
    END
    RETURN    css=[data-test^="order-card-"] >> nth=0

Order Count
    ${n}=    Get Element Count    css=[data-test^="order-card-"]
    RETURN    ${n}

Cancel Order Via UI
    [Documentation]    ยกเลิกคำสั่งซื้อผ่านหน้า /cancel-orders/:orderNo (reason ว่าง = ไม่เลือกเหตุผล)
    [Arguments]    ${card}    ${reason}=no_longer_want
    Click    ${card} >> css=[data-test="btn-cancel-order"]
    Wait Until Keyword Succeeds    15s    500ms    Url Should Contain    /cancel-orders/
    IF    $reason
        Click    css=[data-test="dropdown-reason"]
        Click    css=[data-test="reason-option-${reason}"]
    END
    Click    css=[data-test="btn-submit-cancel"]
