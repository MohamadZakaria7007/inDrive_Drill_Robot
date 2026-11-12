*** Settings ***
Documentation       Users service: login (JWT) and the current user's profile.

Resource            api_session.resource


*** Keywords ***
Login
    [Documentation]    Logs at WARN only: the VAR assignment and RequestsLibrary's request log
    ...    would otherwise write the password into log.html and the CI artifact.
    [Arguments]    ${email}    ${password}    ${expected_status}=200
    ${previous_level}    Set Log Level    WARN
    VAR    &{credentials}    email=${email}    password=${password}
    ${response}    POST On Session    anonymous    /users/login    json=${credentials}
    ...    expected_status=${expected_status}
    RETURN    ${response}
    [Teardown]    Set Log Level    ${previous_level}

Skip Without Demo Credentials
    [Documentation]    Suite Setup guard: a visible SKIP with the reason, not a confusing 401.
    Skip If    not $CUSTOMER_EMAIL or not $CUSTOMER_PASSWORD
    ...    CUSTOMER_EMAIL / CUSTOMER_PASSWORD not set (.env locally, repository secrets in CI)

Get Current User
    [Arguments]    ${session}=authorized    ${expected_status}=200
    ${response}    GET On Session    ${session}    /users/me    expected_status=${expected_status}
    RETURN    ${response}
