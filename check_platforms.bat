@echo off
title M-P Chat - Platform Check
echo.
echo ========================================
echo     M-P Chat - Platform Support Check
echo ========================================
echo.

echo Checking Flutter installation...
flutter --version
if %errorlevel% neq 0 (
    echo ERROR: Flutter not found in PATH
    pause
    exit /b 1
)

echo.
echo Checking platform support...
echo.

echo [Android Support]
flutter config --enable-android
echo.

echo [Web Support]
flutter config --enable-web
echo.

echo [Windows Support]
flutter config --enable-windows-desktop
echo.

echo [Checking available platforms]
flutter devices
echo.

echo [Project Status]
echo Checking if platform directories exist...
if exist "android" (
    echo ✓ Android platform configured
) else (
    echo ✗ Android platform missing
)

if exist "web" (
    echo ✓ Web platform configured
) else (
    echo ✗ Web platform missing - run: flutter create . --platforms web
)

if exist "windows" (
    echo ✓ Windows platform configured
) else (
    echo ✗ Windows platform missing - run: flutter create . --platforms windows
)

echo.
echo [Android Manifest Check]
if exist "android\app\src\main\AndroidManifest.xml" (
    echo ✓ AndroidManifest.xml exists
    findstr "flutterEmbedding" android\app\src\main\AndroidManifest.xml >nul
    if %errorlevel% equ 0 (
        echo ✓ Flutter v2 embedding found
    ) else (
        echo ✗ Flutter v2 embedding missing
    )
) else (
    echo ✗ AndroidManifest.xml missing
)

echo.
echo Platform check completed!
pause