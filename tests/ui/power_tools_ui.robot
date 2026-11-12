*** Settings ***
Documentation       Power Tools category page in Chrome. One browser per suite, clean session per
...                 test. The API is the oracle for what the page must show (U2).

Resource            ../../resources/ui/category_page.resource
Resource            ../../resources/api/catalog_api.resource

Suite Setup         Run Keywords    Open App Browser    AND    Create API Session
Suite Teardown      Close All Browsers
Test Setup          Start Clean Session
Test Teardown       Log Page State On Failure

Test Tags           ui


*** Variables ***
${SEEDED_POWER_TOOLS}       8
${POWER_TOOLS_TITLE}        Category: Power Tools


*** Test Cases ***
U1 Power Tools Page Shows Every Product With Name And Price
    [Tags]    smoke
    Open Category Page    power-tools    ${POWER_TOOLS_TITLE}

    Wait For Product Count    ${SEEDED_POWER_TOOLS}

    ${names}    Get Product Names
    ${prices}    Get Product Prices
    Length Should Be    ${names}    ${SEEDED_POWER_TOOLS}
    Length Should Be    ${prices}    ${SEEDED_POWER_TOOLS}
    FOR    ${price}    IN    @{prices}
        Should Be True    ${price} > 0    msg=Non-positive price shown: ${price}
    END

U2 Power Tools Page Shows The Same Products And Prices As The API
    [Tags]    smoke
    ${category_ids}    Get Category Ids By Slug    power-tools
    ${response}    Search Products    by_category=${category_ids}
    ${api_products}    Evaluate
    ...    sorted((p["name"], decimal.Decimal(str(p["price"]))) for p in $response.json()["data"])
    ...    modules=decimal

    Open Category Page    power-tools    ${POWER_TOOLS_TITLE}
    Wait For Product Count    ${SEEDED_POWER_TOOLS}

    ${names}    Get Product Names
    ${prices}    Get Product Prices
    ${ui_products}    Evaluate    sorted(zip($names, $prices))
    Lists Should Be Equal    ${ui_products}    ${api_products}

U3 Sorting By Price Low To High Reorders The Grid
    Open Category Page    power-tools    ${POWER_TOOLS_TITLE}
    Wait For Product Count    ${SEEDED_POWER_TOOLS}

    Sort Products By    Price (Low - High)

    # The grid re-renders after a new API call: retry the assertion, never sleep.
    Wait Until Keyword Succeeds    10s    250ms    Displayed Prices Should Be Ascending

U4 Filtering By Sander Shows Only Sanders
    ${category_ids}    Get Category Ids By Slug    power-tools
    ${response}    Search Products    by_category=${category_ids}
    ${expected_sanders}    Evaluate
    ...    sorted(p["name"] for p in $response.json()["data"] if p["category"]["slug"] == "sander")
    Should Not Be Empty    ${expected_sanders}    msg=Seed data has no sanders: test would prove nothing
    Open Category Page    power-tools    ${POWER_TOOLS_TITLE}
    Wait For Product Count    ${SEEDED_POWER_TOOLS}

    Filter By Subcategory    Sander

    Wait Until Keyword Succeeds    10s    250ms
    ...    Displayed Product Names Should Be    ${expected_sanders}

U6 Prices Are Shown As Currency With Two Decimals
    [Documentation]    Expected "$46.50"; the page shows the raw API number "$46.5".
    [Tags]    known-bug
    Open Category Page    power-tools    ${POWER_TOOLS_TITLE}
    Wait For Product Count    ${SEEDED_POWER_TOOLS}

    ${texts}    Get Product Price Texts
    Known Bug    PRICE-FORMAT: "$46.5" shown instead of "$46.50" on category grid
    ...    Price not shown with two decimals: *    Every Price Should Have Two Decimals    @{texts}


*** Keywords ***
Displayed Product Names Should Be
    [Arguments]    ${expected_names}
    ${names}    Get Product Names
    Lists Should Be Equal    ${names}    ${expected_names}    ignore_order=True

Displayed Prices Should Be Ascending
    ${prices}    Get Product Prices
    Length Should Be    ${prices}    ${SEEDED_POWER_TOOLS}
    ${expected}    Evaluate    sorted($prices)
    Lists Should Be Equal    ${prices}    ${expected}

Every Price Should Have Two Decimals
    [Arguments]    @{texts}
    FOR    ${text}    IN    @{texts}
        Should Match Regexp    ${text}    ^\\$\\d+\\.\\d{2}$
        ...    msg=Price not shown with two decimals: '${text}'    values=False
    END
