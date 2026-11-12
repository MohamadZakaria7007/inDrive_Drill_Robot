*** Settings ***
Documentation       Shared by every layer: settings, standard libraries, generic keywords.

Library             Collections
Variables           ../variables/settings.py


*** Keywords ***
Known Bug
    [Documentation]    Robot's strict-xfail. Runs ${keyword} and REQUIRES it to fail with
    ...    ${expected_error} (glob, or prefix with REGEXP: / STARTS:), then marks the test SKIP
    ...    with the bug text.
    ...    - Still fails as expected -> SKIP (visible in the report, build stays green).
    ...    - Passes -> FAIL: "Expected error ... did not occur" = bug fixed, remove the marker.
    ...    - Fails differently (outage, wrong status) -> FAIL: a real problem is not hidden.
    [Arguments]    ${bug}    ${expected_error}    ${keyword}    @{args}
    Run Keyword And Expect Error    ${expected_error}    ${keyword}    @{args}
    Skip    Known bug, failing as expected: ${bug}
