*** Settings ***
Documentation       Catalog service: categories and products (read-only, anonymous).
...                 `expected_status` makes RequestsLibrary fail with status + body on mismatch.

Resource            api_session.resource


*** Keywords ***
Get Category Tree By Slug
    [Arguments]    ${slug}    ${expected_status}=200
    VAR    &{params}    by_category_slug=${slug}
    ${response}    GET On Session    anonymous    /categories/tree    params=${params}
    ...    expected_status=${expected_status}
    RETURN    ${response}

Get Category Ids By Slug
    [Documentation]    The parent id plus every sub-category id, comma-separated, which is what
    ...    the UI sends: products hang off sub-categories, so the parent id alone returns none.
    [Arguments]    ${slug}
    ${response}    Get Category Tree By Slug    ${slug}
    VAR    ${root}    ${response.json()}[0]
    VAR    @{ids}    ${root}[id]
    FOR    ${sub}    IN    @{root}[sub_categories]
        Append To List    ${ids}    ${sub}[id]
    END
    ${joined}    Evaluate    ",".join($ids)
    RETURN    ${joined}

Search Products
    [Documentation]    GET /products with any query params, e.g. by_category=... sort=price,asc
    [Arguments]    ${expected_status}=200    &{params}
    ${response}    GET On Session    anonymous    /products    params=${params}
    ...    expected_status=${expected_status}
    RETURN    ${response}

Get Product
    [Arguments]    ${product_id}    ${expected_status}=200
    ${response}    GET On Session    anonymous    /products/${product_id}
    ...    expected_status=${expected_status}
    RETURN    ${response}
