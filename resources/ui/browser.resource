*** Settings ***
Documentation       Browser lifecycle + generic UI helpers. All waiting is explicit.
...                 SeleniumLibrary captures a screenshot automatically when a keyword fails.

Library             SeleniumLibrary    run_on_failure=Capture Page Screenshot
Resource            ../common.resource


*** Variables ***
${WINDOW_SIZE}              add_argument("--window-size=1366,900")
# The demo password is in public breach lists: stop Chrome's password pop-ups covering the page.
${NO_PASSWORD_POPUPS}
...                         add_experimental_option("prefs", {"credentials_enable_service": False,
...                         "profile.password_manager_enabled": False,
...                         "profile.password_manager_leak_detection": False})


*** Keywords ***
Open App Browser
    [Documentation]    One browser per suite (Suite Setup). Tests isolate state with
    ...    Start Clean Session instead of paying for a browser start each time.
    Should Not Be Empty    ${UI_BASE_URL}    msg=UI_BASE_URL is not set (see .env.example)
    IF    '${BROWSER}' == 'firefox'
        VAR    ${options}    add_argument("-headless")
        IF    not ${HEADLESS}    VAR    ${options}    ${NONE}
    ELSE
        VAR    ${options}    ${WINDOW_SIZE}    ${NO_PASSWORD_POPUPS}    separator=;
        IF    ${HEADLESS}
            VAR    ${options}    ${options};add_argument("--headless=new")
        END
    END
    Open Browser    about:blank    ${BROWSER}    options=${options}
    Set Selenium Timeout    ${SELENIUM_TIMEOUT}
    Set Selenium Speed    ${SELENIUM_SPEED}
    Set Selenium Implicit Wait    0s    # never mix implicit and explicit waits

Start Clean Session
    [Documentation]    Test Setup: same browser, but no cookies / storage left by the last test.
    Go To    ${UI_BASE_URL}/
    Delete All Cookies
    Execute Javascript    window.localStorage.clear(); window.sessionStorage.clear();

Click Visible
    [Arguments]    ${locator}
    Wait Until Element Is Visible    ${locator}
    Click Element    ${locator}

Type Into
    [Documentation]    Input Text clears the field first; an empty value leaves it empty.
    [Arguments]    ${locator}    ${text}
    Wait Until Element Is Visible    ${locator}
    Input Text    ${locator}    ${text}

Get Texts
    [Documentation]    Texts of all matches, after waiting for at least one to be visible.
    [Arguments]    ${locator}
    Wait Until Element Is Visible    ${locator}
    ${elements}    Get WebElements    ${locator}
    VAR    @{texts}    @{EMPTY}
    FOR    ${element}    IN    @{elements}
        ${text}    Get Text    ${element}
        Append To List    ${texts}    ${text}
    END
    RETURN    ${texts}

Log Page State On Failure
    [Documentation]    Test Teardown for UI suites: on failure, print URL + title to the console,
    ...    so a CI log shows what the browser really saw (e.g. a "Just a moment..." bot check).
    IF    '${TEST STATUS}' == 'FAIL'
        ${url}    Run Keyword And Ignore Error    Get Location
        ${title}    Run Keyword And Ignore Error    Get Title
        Log To Console    \nPage at failure: ${url}[1] | title: ${title}[1]
    END
