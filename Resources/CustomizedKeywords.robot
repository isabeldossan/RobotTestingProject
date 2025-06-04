*** Settings ***
Library    AppiumLibrary
#Library    WinAppDriver
Library    DateTime

*** Variables ***
${company_key}    35336194  
${expected_version}    Your version: 14.2.1   
${test_email}     XXX
${test_password}    XXX
${wrong_password}    XXX
${resource}    T5Test    
${test_description}    This is a testing description
${name}    Mr. Test
${test_address}    Test Address 20
${test_zipcode}    114 14
${test_city}    Visby
${test_country}    Sverige
${unloading_description}    This is an unloading description
${test_activity_title}    Testing Title
${emulator}    emulator-5554 
${T5App}    app-release.apk             
${platform}    Android

*** Keywords ***
Open App
    [Documentation]      Opens the Android app on the emulator using Appium Server.
    ...                  Automatically grants permissions, disables keystore, mocks the camera and resets the storage/chache.
    ...                  App path, automation engine: UiAutomator2.   
    Open Application    http://127.0.0.1:4723
    ...    platformName=${platform}
    ...    appium:automationName=UiAutomator2
    ...    appium:deviceName=${emulator}
    ...    appium:app=${T5App}
    ...    appium:appWaitActivity=*
    ...    appium:autoGrantPermissions=${True}
    ...    appium:useKeystore=${False}
    ...    appium:camera=mock
    ...    noReset=${False}
    ...    ignoreHiddenApiPolicyError=${True}

Check App Health
    [Documentation]    Will check if the app is still running, if crashed will log an Error message for information
     ${alive}=    Run Keyword And Return Status    Get Source
    Run Keyword Unless    ${alive}    Fail    ❌ App har kraschat. Testet kan inte köras!

Prepare Check
    [Documentation]    Used in the Test Setup, before every test confirm that app is still running.
    ...                Also checks in logged in or not, if not logged in login-keyword will run
    Check App Health
    Check if logged in

Init App If Needed
    ${app_should_start}=    Run Keyword And Return Status    Check App Health
    Run Keyword If    not ${app_should_start}    Log To Console    🔄 App startas eftersom den inte är igång
    Run Keyword If    not ${app_should_start}    Open App    

Company key input
    [Documentation]    Input of the mandatory company key
    Click Element    //android.widget.TextView[@text="Active company key"]
    Wait Until Element Is Visible    id=barkfors.fleet.t5app:id/textView_textInput
    Input Text    id=barkfors.fleet.t5app:id/textView_textInput    ${company_key}
    Click Element    id=android:id/button1
    Text Should Be Visible    ${company_key}
    Click Element  //android.widget.ImageButton[@content-desc="Navigate up"]

Return To Home
    [Documentation]    Will return to the "homepage", used mostly after a test to prepare for a new test
    FOR    ${i}    IN RANGE    3
        ${on_home}=    Run Keyword And Return Status    Page Should Contain Element    text=${resource}
        Exit For Loop If    ${on_home}
        Go Back
        Sleep    0.5s
    END    
    
Email right input
    [Documentation]    Input of a valid email
    Wait Until Element Is Visible    id=barkfors.fleet.t5app:id/email
    Click Element    id=barkfors.fleet.t5app:id/email
    Input Text Into Current Element    ${test_email}

Password right input
    [Documentation]    Input of a valid password and tries to sign in
    Input Password    id=barkfors.fleet.t5app:id/password    ${test_password}
    Click Button    SIGN IN

Password wrong input
    [Documentation]    Input of a non-valid password
    Input Password    id=barkfors.fleet.t5app:id/password    ${wrong_password}
    Click Button    SIGN IN

Choose resource
    [Documentation]    Searches, finds and chooses any resource
    Wait Until Element Is Visible    id=barkfors.fleet.t5app:id/editTextSearch    10s 
    Input Text    id=barkfors.fleet.t5app:id/editTextSearch    ${resource} 
    Wait Until Element Is Visible    //android.widget.TextView[@text="${resource}"]
    Click Element    //android.widget.TextView[@text="${resource}"]
    Wait Until Element Is Visible    android=new UiScrollable(new UiSelector().scrollable(true)).scrollIntoView(new UiSelector().resourceId("barkfors.fleet.t5app:id/status_connection_textview"))

Open order dashboard
    [Documentation]    Opens up the navigation side menu and then goes to the order dashboard
    Click Element    //android.widget.ImageButton[@content-desc="Open navigation drawer"]
    Wait Until Element Is Visible    //android.widget.CheckedTextView[@text="Order processing"]
    Click Element    //android.widget.CheckedTextView[@text="Order processing"]
    Wait Until Page Contains    Orders

Find and open new order
    [Documentation]    Finds an order with the status New through scrolling and then opens it
    Wait Until Element Is Visible
    ...    android=new UiScrollable(new UiSelector().scrollable(true)).scrollIntoView(new UiSelector().text("New"))

    ${wrong_order_title}=    Get Text
    ...    xpath=//android.widget.TextView[@text="New"]/../../android.widget.TextView[@resource-id="barkfors.fleet.t5app:id/textview_order_header"]

    # Kontrollera om det börjar med "Resenr"
    ${is_resenr}=    Evaluate    '${wrong_order_title}'[0:6] == "Resenr"

    Run Keyword If    ${is_resenr}
    ...    Scroll Down     android=new UiScrollable(new UiSelector().scrollable(true)).scrollIntoView(new UiSelector().text("New"))
    ...    ELSE
    ...    Click Element    android=new UiScrollable(new UiSelector().scrollable(true)).scrollIntoView(new UiSelector().text("New"))
    Wait Until Page Contains    Order

Accept order
    [Documentation]    Scrolls on a new order until Statuses visible and then clicks Accept
    Wait Until Element Is Visible    android=new UiScrollable(new UiSelector().scrollable(true)).scrollIntoView(new UiSelector().text("Current status: New"))
    Handle the accept status button
    Sleep    3s

Handle the accept status button
    [Documentation]    Will find the right button even if it is not directly visible on the order dashboard
    ${is_accepted_visible}=    Run Keyword And Return Status    Element Should Be Visible    //android.widget.Button[@text="ACCEPTED"]
    IF    ${is_accepted_visible}
        Click Element    //android.widget.Button[@text="ACCEPTED"]
    ELSE
        ${is_change_visible}=    Run Keyword And Return Status    Element Should Be Visible    //android.widget.Button[@text="CHANGE STATUS"]
        IF    ${is_change_visible}
            Click Element    //android.widget.Button[@text="CHANGE STATUS"]
            Wait Until Page Contains    T5 - Status change
            Click Element    //android.widget.Button[@text="ACCEPTED"]
            Wait Until Page Contains    Report back
            Click Element    xpath=//*[contains(@text, "Last")]
            Input Text Into Current Element    ${name}
            Click Element    xpath=//*[contains(@text, "Lossad")]
            Input Text Into Current Element    ${name}
            Click Element    id=barkfors.fleet.t5app:id/menu_tillagg_save
        ELSE
            Fail    neither ACCEPTED or CHANGE STATUS button is visible
        END
    END  

Handle the start status button  
    [Documentation]    Will find the right button even if it is not directly visible on the order dashboard  
    ${is_started_visible}=    Run Keyword And Return Status    Element Should Be Visible    //android.widget.Button[@text="STARTED"]
    IF    ${is_started_visible}
        Click Element    //android.widget.Button[@text="STARTED"]
    ELSE
        ${is_change_visible}=    Run Keyword And Return Status    Element Should Be Visible    //android.widget.Button[@text="CHANGE STATUS"]
        IF    ${is_change_visible}
            Click Element    //android.widget.Button[@text="CHANGE STATUS"]
            Wait Until Page Contains    T5 - Status change
            Click Element    //android.widget.Button[@text="STARTED"]
            Wait Until Page Contains    Report back
            Click Element    xpath=//*[contains(@text, "Start")]
            Wait Until Page Contains    T5 - Enter Date + Time
            Click Element    id=barkfors.fleet.t5app:id/menu_datetime_save
            Wait Until Page Contains    Report back
            Click Element    xpath=//*[contains(@text, "Slut")]
            Wait Until Page Contains    T5 - Enter Date + Time
            Click Element    id=barkfors.fleet.t5app:id/menu_datetime_save
            Click Element    id=barkfors.fleet.t5app:id/menu_tillagg_save
        ELSE
            Fail    neither STARTED or CHANGE STATUS button is visible
        END
    END 
Start order
    [Documentation]    Scrolls on an accepted order until Statuses visible and then click Start
    Wait Until Element Is Visible    android=new UiScrollable(new UiSelector().scrollable(true)).scrollIntoView(new UiSelector().text("Current status: Accepted"))
    Handle the start status button
    Sleep    3s

Find and open started order
    [Documentation]    Finds an order with the status Started through scrolling and then opens it
    Click Element    android=new UiScrollable(new UiSelector().scrollable(true)).scrollIntoView(new UiSelector().text("Started"))
    Wait Until Page Contains    Order

Find and open accepted order
    [Documentation]    Finds an order with the status Accepted through scrolling and then opens it
    Click Element    android=new UiScrollable(new UiSelector().scrollable(true)).scrollIntoView(new UiSelector().text("Accepted"))
    Wait Until Page Contains    Order

Deny order    
    [Documentation]    Scrolls on an order until Statuses visible and then Denies it
    Click Element    android=new UiScrollable(new UiSelector().scrollable(true)).scrollIntoView(new UiSelector().text("NEKA"))
    Handle the deny status button
    Sleep    3s

Handle the deny status button
    [Documentation]    Will find the right button even if it is not directly visible on the order dashboard 
    ${is_deny_visible}=    Run Keyword And Return Status    Element Should Be Visible    //android.widget.Button[@text="NEKA"]
    IF    ${is_deny_visible}
        Click Element    //android.widget.Button[@text="NEKA"]
    ELSE
        ${is_change_visible}=    Run Keyword And Return Status    Element Should Be Visible    //android.widget.Button[@text="CHANGE STATUS"]
        IF    ${is_change_visible}
            Click Element    //android.widget.Button[@text="CHANGE STATUS"]
            Wait Until Page Contains    T5 - Status change
            Click Element    //android.widget.Button[@text="NEKA"]
            Wait Until Page Contains    Deny order - Enter reason
            Input Text    xpath=//android.widget.EditText    ${test_description}
            Click Element    id=android:id/button1
        ELSE
            Fail    neither NEKA or CHANGE STATUS button is visible
        END
    END 

Open more options menu
    [Documentation]    Opens up the "more options" side menu 
    Click Element    //android.widget.ImageView[@content-desc="More options"]

Create new addition
    [Documentation]    From the "more options" side menu, this goes to the page for New addition 
    Wait Until Page Contains Element    //android.widget.TextView[@text="New addition"]
    Click Element    //android.widget.TextView[@text="New addition"]
    Wait Until Page Contains    Select extensions

Accept warning for multiple unloading reports
    [Documentation]    This accepts and closes the warning that shows up when trying to create another unloading report 
    Wait Until Element Is Visible    id=android:id/button1
    Click Element    id=android:id/button1

Create new unloading report
    [Documentation]  Creates a new report for unloading, even if there is already existing unloading reports on the order
    Click Element    //android.widget.TextView[@text="Lossrapport"]
    ${error_visible}=    Run Keyword And Return Status    Element Should Be Visible    //android.widget.TextView[@resource-id="barkfors.fleet.t5app:id/alertTitle"]
    IF    ${error_visible} == True
        Accept warning for multiple unloading reports
    END
    Wait Until Page Contains    New
    Click Text    GET TIME    
    Click Element   //android.widget.EditText[@text="Slut (mandatory for Lossad)"]
    Click Element    id=barkfors.fleet.t5app:id/menu_datetime_save
    Wait Until Element Is Visible    id=barkfors.fleet.t5app:id/editTextTillaggAlfaNumeric
    Input Text    id=barkfors.fleet.t5app:id/editTextTillaggAlfaNumeric    ${unloading_description}
    Click Element    id=barkfors.fleet.t5app:id/menu_tillagg_save

Find unloading report on order dashboard
    [Documentation]    Finds an unloading report by scrolling on an order and stops when found
    Wait Until Element Is Visible    android=new UiScrollable(new UiSelector().scrollable(true)).scrollIntoView(new UiSelector().text("Current status: New"))

Find deviation report on order dashboard
    [Documentation]    Finds a deviation report by scrolling on an order and stops when found
    Wait Until Element Is Visible    android=new UiScrollable(new UiSelector().scrollable(true)).scrollIntoView(new UiSelector().text("deviation"))

Report deviation with photo  
    [Documentation]    Creates a deviation report from the "more options" side menu on a order and includes a photo in the report   
    Wait Until Element Is Visible    //android.widget.TextView[@text="Report deviation"]
    Click Element    //android.widget.TextView[@text="Report deviation"]
    Wait Until Page Contains    T5 - Choose deviation
    Click Element    //android.widget.TextView[@text="Skadat gods"]
    Element Should Be Visible    //android.widget.RadioButton[@checked="true"]
    Click Element    id=android:id/button1
    Take a photo in app
    Input Text    id=barkfors.fleet.t5app:id/editTextTillaggAlfaNumeric   ${test_description}
    Click Element    id=barkfors.fleet.t5app:id/menu_avvikelse_save

Create a new order from template
    [Documentation]    Creates a new order using a template, from the Order dashboard using "more options" side menu
    Wait Until Element Is Visible   //android.widget.TextView[@text="Create a new order (order template)"]
    Click Element    //android.widget.TextView[@text="Create a new order (order template)"]
    Wait Until Page Contains    T5 - Select order template
    Click Element    //android.widget.TextView[@text="Barkfors till Göteborg"]
    Page Should Contain Text    T5 - New order
    Click Element    id=barkfors.fleet.t5app:id/menu_new_order_commit

Edit an address on a new order
    [Documentation]    Edit the To address on a new order using multiple inputs and then saves the new address
    Wait Until Page Contains  New  
    Click Element    id=barkfors.fleet.t5app:id/cardview_orderdetail_till
    Wait Until Page Contains    Enter new address
    Click Text    Enter new address
    Wait Until Page Contains    "T5 - Select address (to)"
    Click Element    id=barkfors.fleet.t5app:id/menu_add_new_entity 
    Wait Until Page Contains    T5 - New address
    Input Text    id=barkfors.fleet.t5app:id/editTextNamn    ${name}
    Input Text    id=barkfors.fleet.t5app:id/editTextAdress1    ${test_address}
    Input Text    id=barkfors.fleet.t5app:id/editTextPostnummer    ${test_zipcode}
    Input Text    id=barkfors.fleet.t5app:id/editTextOrt    ${test_city}
    Input Text    id=barkfors.fleet.t5app:id/editTextLand    ${test_country}
    Click Element    id=barkfors.fleet.t5app:id/menu_entity_save
    Wait Until Page Contains    ${name}

Archive completed orders
    [Documentation]    Removes all the completed orders from the order dashboard to Archived
    Wait Until Page Contains    Archive completed orders
    Click Element    //android.widget.TextView[@text="Archive completed orders"]
    Wait Until Page Contains    T5 - Enter Date + Time
    Click Element    id=barkfors.fleet.t5app:id/menu_datetime_save
    Wait Until Element Is Visible    id=barkfors.fleet.t5app:id/alertTitle
    Click Element    id=android:id/button1
    Wait Until Page Contains    Orders

Sign an order with new contact
    [Documentation]    Creates a signature on an order from the "more options" side menu using a new contact that is also created
    Wait Until Page Contains Element    //android.widget.TextView[@text="Sign order"]
    Click Element    //android.widget.TextView[@text="Sign order"]
    Wait Until Page Contains    T5 - Signature
    Click Element    id=barkfors.fleet.t5app:id/editTextKontakt
    Wait Until Page Contains    T5 - Select contact
    Click Element    id=barkfors.fleet.t5app:id/menu_add_new_entity
    Wait Until Page Contains    T5 - New contact
    Input Text    id=barkfors.fleet.t5app:id/editTextNamn    ${name}
    Input Text    id=barkfors.fleet.t5app:id/editTextTelefon    ${test_zipcode}
    Click Element    id=barkfors.fleet.t5app:id/menu_entity_save
    Wait Until Page Contains    T5 - Signature
    Create a signature by freehand

Open activity dashboard
    [Documentation]    Opens up the navigation side menu and then goes to the Activity dashboard
    Click Element    //android.widget.ImageButton[@content-desc="Open navigation drawer"]
    Wait Until Element Is Visible    //android.widget.CheckedTextView[@text="Activities"]
    Click Element    //android.widget.CheckedTextView[@text="Activities"]
    Wait Until Page Contains    Activities

Create new activity
    [Documentation]    Creates a new activity on todays date with multiple inputs from the Activity dashboard and also validates the new activity
    Click Element    id=barkfors.fleet.t5app:id/menu_ny_schema_aktivitet
    Wait Until Page Contains    New activity
    Input Text    id=barkfors.fleet.t5app:id/editTextTitle    ${test_activity_title}
    Input Text    id=barkfors.fleet.t5app:id/editTextDescription    ${test_description}
    Click Element    id=barkfors.fleet.t5app:id/editTextFromDate
    Wait Until Page Contains    T5 - Enter Date + Time
    Click Element    id=barkfors.fleet.t5app:id/menu_datetime_save
    Wait Until Page Contains    New activity   
    Click Element    id=barkfors.fleet.t5app:id/editTextToDate
    Wait Until Page Contains    T5 - Enter Date + Time
    Click Element    id=barkfors.fleet.t5app:id/menu_datetime_save
    Wait Until Page Contains    New activity
    Click Element    id=barkfors.fleet.t5app:id/menu_schema_aktivitet_save
    Wait Until Element Is Visible    id=barkfors.fleet.t5app:id/framelayout_schemaAktivitet_header

Copy an order
    [Documentation]    Creates a copy of an order from the "more options" side menu and validates that it was sucessful
    Wait Until Element Is Visible    //android.widget.TextView[@text="Create a copy"]
    Click Element    //android.widget.TextView[@text="Create a copy"]
    Element Should Be Visible    id=barkfors.fleet.t5app:id/alertTitle
    Click Element    id=android:id/button1  
    Wait Until Page Contains    Orders 

Find and open order with attached pdf    
    [Documentation]    Find and open a new order from the order dashboard, only open order if it includes attached pdf
    Click Element    android=new UiScrollable(new UiSelector().scrollable(true)).scrollIntoView(new UiSelector().text("106771, Direkttransport, Barkfors Internkund"))
    Wait Until Page Contains    Order
    Click Element    id=barkfors.fleet.t5app:id/imageview_orderfil 
    Click Text    Open file    

Open new order from dropdown notifications
    [Documentation]    If user has created new orders or have gotten orders this opens a New order from Androids notification 
    Open Notifications
    Wait Until Page Contains Element    id=com.android.systemui:id/keyguard_message_area_container
    Wait Until Page Contains Element    xpath=//*[contains(@text, "New assignment")]    15s
    Click Element    xpath=//*[contains(@text, "New assignment")]

Create a signature by freehand
    [Documentation]    Creates a freehand signature from the signature page and also at the end finds the new signature by scrolling down on the order
    Swipe    300    1200    500    1150    400
    Swipe    500    1150    700    1300    400
    Swipe    700    1300    800    1250    400
    Swipe    800    1250    850    1350    400
    Swipe    850    1350    700    1400    400
    Swipe    700    1400    600    1350    400
    Swipe    600    1350    400    1450    400
    Swipe    400    1450    1000   1500   400
    Click Element    id=barkfors.fleet.t5app:id/menu_signature_save
    Wait Until Page Contains    Order
    Wait Until Element Is Visible    android=new UiScrollable(new UiSelector().scrollable(true)).scrollIntoView(new UiSelector().resourceId("barkfors.fleet.t5app:id/textview_current_status"))

Take a photo in app
    [Documentation]  Mock-photo and validates a new photo
    Wait Until Page Contains Element    id=com.android.camera2:id/shutter_button
    Click Element    id=com.android.camera2:id/shutter_button
    Wait Until Element Is Visible    id=com.android.camera2:id/done_button
    Click Element    id=com.android.camera2:id/done_button
    Wait Until Page Contains    Number of attached photos: 1

Login
    [Documentation]    Collection a mandatory actions needed to log in 
    Company key input
    Email right input
    Password right input
    Choose resource

Check if logged in   
    [Documentation]    Will confirm if logged in and if not will run the login keyword
    ${text}=    Get Text    id=barkfors.fleet.t5app:id/textview_lbl_resurs
    ${is_logged_in}=    Run Keyword And Return Status   Should Match Regexp    ${text}    (?i).*(${expected_version}|${resource}).*  
    Run Keyword Unless    ${is_logged_in}    Login    

    ${text}=          Get Text    id=barkfors.fleet.t5app:id/textview_lbl_resurs
    ${is_match}=      Run Keyword And Return Status    Should Match Regexp    ${text}    .*(${expected_version}|${resource}).*
    Run Keyword Unless    ${is_match}    Fail    Ingen matchning mot version eller resurs!
