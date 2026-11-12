*** Settings ***
Documentation       Page object: /category/<slug> product listing (Power Tools, Hand Tools, ...).
...                 Locators are the app's data-test ids; the filter uses its visible label text.

Library             ../../libraries/Money.py
Resource            browser.resource


*** Variables ***
${PAGE_TITLE}       css:[data-test="page-title"]
${SORT_SELECT}      css:[data-test="sort"]
${PRODUCT_NAME}     css:[data-test="product-name"]
${PRODUCT_PRICE}    css:[data-test="product-price"]


*** Keywords ***
Open Category Page
    [Arguments]    ${slug}    ${expected_title}
    Go To    ${UI_BASE_URL}/category/${slug}
    Wait Until Element Contains    ${PAGE_TITLE}    ${expected_title}

Wait For Product Count
    [Documentation]    The grid renders after the API call returns: wait for exactly ${count}.
    [Arguments]    ${count}
    Wait Until Page Contains Element    ${PRODUCT_NAME}    limit=${count}

Get Product Names
    ${names}    Get Texts    ${PRODUCT_NAME}
    RETURN    ${names}

Get Product Prices
    [Documentation]    Displayed prices as Decimal ("$58.48" -> 58.48), in grid order.
    ${texts}    Get Texts    ${PRODUCT_PRICE}
    VAR    @{prices}    @{EMPTY}
    FOR    ${text}    IN    @{texts}
        ${price}    Parse Money    ${text}
        Append To List    ${prices}    ${price}
    END
    RETURN    ${prices}

Get Product Price Texts
    ${texts}    Get Texts    ${PRODUCT_PRICE}
    RETURN    ${texts}

Sort Products By
    [Documentation]    ${option_label} is the visible text, e.g. "Price (Low - High)".
    [Arguments]    ${option_label}
    Wait Until Element Is Enabled    ${SORT_SELECT}
    Select From List By Label    ${SORT_SELECT}    ${option_label}

Filter By Subcategory
    [Arguments]    ${label}
    Click Visible    xpath://label[normalize-space()="${label}"]//input[@type="checkbox"]
