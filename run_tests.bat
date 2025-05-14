@echo off
cd /d "%~dp0"

REM === Skapar dagens datum för mappnamn ===
set DATUM=%date:~0,4%-%date:~5,2%-%date:~8,2%

echo ==== Städar bort allt gammalt Results-mapp, dvs tidigare körningen innan denna körning ====
rmdir /s /q Results\
mkdir Results\

echo ==== Startar emulatorn... ====
start "" "C:\Users\IsabeldosSantosPette\AppData\Local\Android\Sdk\emulator\emulator.exe" -avd Medium_Phone_API_36

timeout /t 10

echo ==== Startar Appium server... ====
start cmd /k appium

timeout /t 10

echo ==== Kör Robot testerna... ====
REM robot --outputdir Results\%DATUM% --output output.xml Tests\first_smoke_suite.robot
robot --outputdir Results\%DATUM% --output output.xml --test "4. Deny order test" Tests\first_smoke_suite.robot

echo ==== Kör om failade tester om några... ====
robot --outputdir Results\%DATUM%\rerun --output rerun.xml --log rerun_log.html --report rerun_report.html --rerunfailed Results\%DATUM%\output.xml Tests\first_smoke_suite.robot

REM === Kombinerar båda testrundorna till en slutrapport OM rerun körts ===
IF EXIST Results\%DATUM%\rerun\rerun.xml (
    rebot --outputdir Results\%DATUM% --output final_output.xml --log final_log.html --report final_report.html Results\%DATUM%\output.xml Results\%DATUM%\rerun\rerun.xml
) ELSE (
    rebot --outputdir Results\%DATUM% --output final_output.xml --log final_log.html --report final_report.html Results\%DATUM%\output.xml
)

REM === Öppnar slutrapporten ====
start Results\%DATUM%\final_report.html

REM === Stänger emulatorn och Appium servern ===
adb -s emulator-5554 emu kill
taskkill /f /im node.exe >nul 2>&1

echo ==== Klart ====
pause