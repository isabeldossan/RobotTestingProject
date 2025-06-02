#!/bin/bash
set -e

# === Skapa datumsträng ===
DATUM=$(date +%Y-%m-%d)

echo "==== Städar tidigare körningar ===="
rm -rf Results/
mkdir -p Results/

echo "==== Startar emulator ===="
"$ANDROID_HOME/emulator/emulator" -avd Medium_Phone_API_36 -no-audio -no-window -no-boot-anim -accel auto &
EMULATOR_PID=$!

# Väntar tills emulatorn är redo
$ANDROID_HOME/platform-tools/adb wait-for-device
$ANDROID_HOME/platform-tools/adb shell input keyevent 82
sleep 10

echo "==== Startar Appium-server ===="
appium > appium.log 2>&1 &
APPIUM_PID=$!
sleep 10

if [ "$DRY_RUN" == "true" ]; then
    echo "[INFO] Dry run aktiv – hoppar över robotkörning."
else
    echo "== Kör Robot Framework tester =="
    robot --outputdir Results/$DATUM --output output.xml Tests/first_smoke_suite.robot
    ...
fi

echo "==== Kör om failade tester (om några) ===="
mkdir -p Results/$DATUM/rerun
robot --outputdir Results/$DATUM/rerun --output rerun.xml --log rerun_log.html --report rerun_report.html --rerunfailed Results/$DATUM/output.xml Tests/first_smoke_suite.robot

echo "==== Skapar slutrapport ===="
if [ -f Results/$DATUM/rerun/rerun.xml ]; then
    rebot --outputdir Results/$DATUM --output final_output.xml --log final_log.html --report final_report.html Results/$DATUM/output.xml Results/$DATUM/rerun/rerun.xml
else
    rebot --outputdir Results/$DATUM --output final_output.xml --log final_log.html --report final_report.html Results/$DATUM/output.xml
fi

# === Visa var rapporten finns (öppnar ej i CI) ===
if [ -f Results/$DATUM/final_report.html ]; then
    echo "==== Rapporten skapades: Results/$DATUM/final_report.html ===="
else
    echo "[WARNING] Rapporten kunde inte skapas – filen saknas."
fi

echo "==== Stänger emulator och Appium-server ===="
$ANDROID_HOME/platform-tools/adb -s emulator-5554 emu kill
kill $APPIUM_PID || true
kill $EMULATOR_PID || true

echo "==== Klart! ===="