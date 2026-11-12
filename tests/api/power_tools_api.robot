*** Settings ***
Documentation       Power Tools category via the Toolshop REST API (read-only, anonymous).
...                 Expected names/counts come from the demo seed data (reset by the site).

Resource            ../../resources/api/catalog_api.resource

Suite Setup         Create API Session

Test Tags           api


*** Variables ***
@{POWER_TOOLS_SUBCATEGORIES}    grinder    sander    saw    drill
${SEEDED_POWER_TOOLS}           8
${UNKNOWN_PRODUCT_ID}           01ZZZZZZZZZZZZZZZZZZZZZZZZ


*** Test Cases ***
A1 Category Tree Lists The Power Tools Subcategories
    [Tags]    smoke
    ${response}    Get Category Tree By Slug    power-tools

    VAR    ${root}    ${response.json()}[0]
    Should Be Equal    ${root}[slug]    power-tools
    Should Be Equal    ${root}[parent_id]    ${NONE}
    ${slugs}    Evaluate    [sub["slug"] for sub in $root["sub_categories"]]
    Lists Should Be Equal    ${slugs}    ${POWER_TOOLS_SUBCATEGORIES}    ignore_order=True

A2 Power Tools Products Match The Contract And Stay In The Category
    [Tags]    smoke
    ${category_ids}    Get Category Ids By Slug    power-tools

    ${response}    Search Products    by_category=${category_ids}

    Response Should Match Schema    ${response}    product_page
    VAR    ${page}    ${response.json()}
    Should Be Equal As Integers    ${page}[total]    ${SEEDED_POWER_TOOLS}
    Length Should Be    ${page}[data]    ${SEEDED_POWER_TOOLS}
    FOR    ${product}    IN    @{page}[data]
        Should Contain    ${POWER_TOOLS_SUBCATEGORIES}    ${product}[category][slug]
        ...    msg=${product}[name] is in '${product}[category][slug]', not a power-tools subcategory
    END

A3 Sorting Power Tools By Price Returns An Ordered List
    [Template]    Power Tools Sorted By ${sort} Should Be Ordered By Price
    price,asc
    price,desc

A6 Unknown Product Id Returns 404 With A Message
    ${response}    Get Product    ${UNKNOWN_PRODUCT_ID}    expected_status=404

    Should Be Equal    ${response.json()}[message]    Requested item not found


*** Keywords ***
Power Tools Sorted By ${sort} Should Be Ordered By Price
    ${category_ids}    Get Category Ids By Slug    power-tools
    ${response}    Search Products    by_category=${category_ids}    sort=${sort}
    ${prices}    Evaluate    [product["price"] for product in $response.json()["data"]]
    Length Should Be    ${prices}    ${SEEDED_POWER_TOOLS}
    ${expected}    Evaluate    sorted($prices, reverse='''${sort}'''.endswith("desc"))
    Lists Should Be Equal    ${prices}    ${expected}    msg=Not ordered for sort=${sort}
