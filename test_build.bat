@echo off
echo Testing Android build configuration...
echo.

echo Checking Flutter installation...
flutter --version
if %errorlevel% neq 0 (
    echo ERROR: Flutter not found in PATH
    pause
    exit /b 1
)

echo.
echo Checking doctor...
flutter doctor -v
echo.

echo Cleaning project...
flutter clean
echo.

echo Getting dependencies...
flutter pub get
echo.

echo Testing Android build...
flutter build apk --debug
echo.

if %errorlevel% equ 0 (
    echo SUCCESS: Android build completed successfully!
    echo APK location: build\app\outputs\flutter-apk\app-debug.apk
) else (
    echo ERROR: Android build failed
    echo Please check the error messages above
)

echo.
pause