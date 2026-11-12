*** Settings ***
Documentation       Generic API session. Service resources (one per API resource) build on it;
...                 every service keyword takes `expected_status=` so negative tests read like
...                 positive ones. The suites here are read-only, so no cleanup registry yet.

Library             RequestsLibrary
Library             ../../libraries/Contracts.py
Resource            ../common.resource


*** Keywords ***
Create API Session
    [Documentation]    Suite Setup: one `anonymous` session. Retries only gateway errors
    ...    (502/503/504) on idempotent methods, never real failures.
    Should Not Be Empty    ${API_BASE_URL}    msg=API_BASE_URL is not set (see .env.example)
    VAR    &{headers}    Accept=application/json    Content-Type=application/json
    VAR    @{retry_statuses}    ${502}    ${503}    ${504}
    Create Session    anonymous    ${API_BASE_URL}    headers=${headers}    timeout=${API_TIMEOUT}
    ...    max_retries=2    retry_status_list=${retry_statuses}    verify=${True}
    # RequestsLibrary defaults to verify=False: TLS certificates would not be checked.

Create Authorized Session
    [Documentation]    `authorized` session with a bearer token. Auth goes in per-session
    ...    HEADERS: RequestsLibrary 0.9.7 keeps `cookies=` library-wide (would leak across sessions).
    [Arguments]    ${token}
    VAR    &{headers}    Accept=application/json    Content-Type=application/json
    ...    Authorization=Bearer ${token}
    Create Session    authorized    ${API_BASE_URL}    headers=${headers}    timeout=${API_TIMEOUT}
    ...    verify=${True}
