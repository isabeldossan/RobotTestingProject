*** Settings ***
Library    DateTime
Resource    ../Resources/CustomizedKeywords.robot

Suite Setup    Open App
Test Setup    Prepare Check
Test Teardown    Return To Home
Suite Teardown    Terminate Application    barkfors.fleet.t5app

*** Test Cases ***
1. Sucessful login test
    Log    ✅ Login performed via Test Setup
    Text Should Be Visible    ${resource}
    Text Should Be Visible    ${expected_version}
    
2. Accept order test
    Log    ✅ Logged in
    Open order dashboard
    Find and open new order
    Accept order
    Text Should Be Visible    Current status: Accepted

3. Start order test
    Log    ✅ Logged in
    Open order dashboard
    Find and open accepted order
    Start order
    Text Should Be Visible    Current status: Started

4. Deny order test
    Log    ✅ Logged in
    Open order dashboard
    Find and open new order
    Deny order
    Text Should Be Visible    Current status: Denied 

5. Report unloading test
    Log    ✅ Logged in
    Open order dashboard
    Find and open new order
    Open more options menu
    Create new addition
    Create new unloading report
    Find unloading report on order dashboard
    Text Should Be Visible    ${unloading_description}

6. Report deviation including photo test
    Log    ✅ Logged in
    Open order dashboard
    Find and open started order
    Open more options menu
    Report deviation with photo
    Find deviation report on order dashboard
    Text Should Be Visible    ${test_description}

7. E2E - Scenario A - Create a new order in app using existing template test
    Log    ✅ Logged in
    Open order dashboard
    Open more options menu
    Create a new order from template
    Page Should Contain Text    Orders

8. E2E - Scenario B - Edit and sign new order test
    Log    ✅ Logged in
    Open order dashboard
    Find and open new order
    Edit an address on a new order
    Open more options menu
    Sign an order with new contact
    Wait Until Page Contains    signatur_

9. E2E - Scenario C - Create a new activity test
    Log    ✅ Logged in    
    Open activity dashboard
    Create new activity
    Page Should Contain Text    ${test_activity_title}

10. Archive all completed orders
    Log    ✅ Logged in
    Open order dashboard
    Open more options menu
    Archive completed orders
    Wait Until Page Contains    Orders

11. Open an attached pdf from a recieved order
    Log    ✅ Logged in
    Open order dashboard
    Find and open order with attached pdf
    Wait Until Page Contains Element    id=barkfors.fleet.t5app:id/pdf_pages_container     

12. Bug 8377 - Copy an order and open the new order through notifications without crash test
    Log    ✅ Logged in
    Open order dashboard
    Find and open new order
    Open more options menu
    Copy an order
    Open new order from dropdown notifications
    Wait Until Page Contains    Orders 
    #because dashboard should be visible again if no crash
