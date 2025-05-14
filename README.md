📱 FIRSTROBOT – Automated Test Suite for Android application T5App

FIRSTROBOT is an automation project based on Robot Framework and Appium designed to validate critical workflows in the Android application T5. The goal is to ensure that essential functionality such as login, order management, and UI components perform according to requirements, the suite is used as a Smoke test. The project supports both standalone test execution and full-suite runs, including automatic report generation.

✅ Key Features

Automated UI testing on Android emulators
Integration with Appium server
Daily log and report generation with date-based folder structure
Support for mocked tests where login is not always required
Automatic return to the app's home screen after each test case
Sanity checks on application
Mocked use of camera
Use of freehand creations in test

🛠️ Technical Overview

Robot Framework	            Test automation framework
Appium	                    Mobile automation server (Android)
Python 3.x	                Scripting language
Android Emulator	        Virtual test environment (AVD Manager)
VS Code	                    Development environment
.BAT Script	                Automated execution and report handling

📁 Project Structure

FIRSTROBOT/
├── Resources/              # Custom keywords and AppiumLibrary keywords
├── Tests/                  # Test cases written in .robot format
├── Results/YYYY-MM-DD/     # Dated folders for test logs and reports
├── run_tests.bat           # Batch file to start emulator, Appium, and tests
├── Requirements.txt        # List of Python dependencies
└── README.md               # Project documentation

▶️ Running Tests

1. Install dependencies
pip install -r Requirements.txt

2. Execute the test suite
Run via double-click on run_tests.bat or from the terminal: run_tests.bat

The script will:

Clear previous results
Start the Android emulator (AVD)
Launch the Appium server
Execute the Robot Framework test suite
Save results in Results\YYYY-MM-DD
Rerun all the tests that failed
Create and combine the Results-reports
Automatically open report.html upon completion

The script can be adjusted to run a specific test case by using the --test flag.

🔍 Running Tests Locally
To run the test suite locally, follow these steps:

✅ Prerequisites
Make sure you have the following installed on your machine:
Python 3.7+
pip
Robot Framework
All dependencies listed in requirements.txt

💾 Install Dependencies
Run the following command from the root of the project:  pip install -r requirements.txt

▶️ Run the Tests
To execute all tests in the suite:

robot tests/
Replace tests/ with the actual path to your .robot files if your structure is different.

📄 Test Results
After running the tests, the following files will be generated:
output.xml – Raw test results in XML format (used in CI/CD)
report.html – Summary of test results
log.html – Detailed log of each test step

🔍 Example Test Scenarios

Test Case	                        Purpose
Successful login	                Verifies the login flow and credential input
Accepting an order	                Ensures orders can be received and confirmed
Version and UI validation	        Confirms expected UI elements and version info
Checking attached files on orders   Ensures that the right files on incoming orders is shown in app

ℹ️ Additional Information

Tests are designed to run both individually and as part of a full test suite.
State isolation is implemented to return the app to a consistent home screen after each test.
noReset=False is used to ensure a clean app state before each session.
Emulator and Appium server are automatically shut down after test execution.
Use cmd: robot --dryrun C:\Users\... to dryrun the suite and check for possible syntax errors
