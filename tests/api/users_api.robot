*** Settings ***
Documentation       Login with the published demo customer. Negative cases use an UNKNOWN email,
...                 never a wrong password on the shared demo account (could lock it for others).

Resource            ../../resources/api/users_api.resource

Suite Setup         Run Keywords    Create API Session    AND    Skip Without Demo Credentials

Test Tags           api


*** Variables ***
${UNKNOWN_EMAIL}    nobody.robot.drill@example.com


*** Test Cases ***
A7 Demo Customer Logs In And The Token Opens Their Profile
    [Tags]    smoke
    ${response}    Login    ${CUSTOMER_EMAIL}    ${CUSTOMER_PASSWORD}
    Should Be Equal    ${response.json()}[token_type]    bearer
    Should Be True    ${response.json()}[expires_in] > 0

    Create Authorized Session    ${response.json()}[access_token]
    ${profile}    Get Current User

    Should Be Equal    ${profile.json()}[email]    ${CUSTOMER_EMAIL}

A7b Unknown Email Is Rejected With 401
    ${response}    Login    ${UNKNOWN_EMAIL}    not-the-password    expected_status=401

    Should Be Equal    ${response.json()}[error]    Unauthorized
    Dictionary Should Not Contain Key    ${response.json()}    access_token

A7c Profile Without A Token Is Rejected With 401
    ${_}    Get Current User    session=anonymous    expected_status=401
