@echo off
title M-P Chat - Build Options
echo.
echo ========================================
echo        M-P Chat - Build Options
echo ========================================
echo.
echo Choose build type:
echo.
echo [1] Test on device/emulator
echo [2] Build Android APK
echo [3] Build Android AAB (Play Store)
echo [4] Build Windows
echo [5] Build Web
echo [6] Test API Connection
echo.
set /p choice="Choose option (1-6): "

if "%choice%"=="1" (
    echo.
    echo Starting app on device...
    flutter run
) else if "%choice%"=="2" (
    echo.
    echo Building Android APK...
    echo Checking Flutter installation...
    flutter --version
    if %errorlevel% neq 0 (
        echo ERROR: Flutter not found in PATH
        echo Please install Flutter and add it to your PATH
        echo Visit: https://flutter.dev/docs/get-started/install
        pause
        exit /b 1
    )
    
    echo.
    echo Running Flutter doctor...
    flutter doctor -v
    
    echo.
    echo Cleaning project...
    flutter clean
    
    echo.
    echo Getting dependencies...
    flutter pub get
    
    echo.
    echo Building APK...
    flutter build apk --release
    if %errorlevel% equ 0 (
        echo.
        echo APK created successfully!
        echo Location: build\app\outputs\flutter-apk\app-release.apk
        start "" "build\app\outputs\flutter-apk"
    ) else (
        echo.
        echo Build failed! Please check the error messages above.
        echo Common solutions:
        echo 1. Run 'flutter doctor' to check for missing dependencies
        echo 2. Accept Android licenses: 'flutter doctor --android-licenses'
        echo 3. Make sure Android SDK is installed
        echo 4. Check that ANDROID_HOME or ANDROID_SDK_ROOT is set
    )
) else if "%choice%"=="3" (
    echo.
    echo Building Android AAB...
    echo Checking Flutter installation...
    flutter --version
    if %errorlevel% neq 0 (
        echo ERROR: Flutter not found in PATH
        echo Please install Flutter and add it to your PATH
        echo Visit: https://flutter.dev/docs/get-started/install
        pause
        exit /b 1
    )
    
    echo.
    echo Running Flutter doctor...
    flutter doctor -v
    
    echo.
    echo Cleaning project...
    flutter clean
    
    echo.
    echo Getting dependencies...
    flutter pub get
    
    echo.
    echo Building AAB...
    flutter build appbundle --release
    if %errorlevel% equ 0 (
        echo.
        echo AAB created successfully!
        echo Location: build\app\outputs\bundle\release\app-release.aab
        start "" "build\app\outputs\bundle\release"
    ) else (
        echo.
        echo Build failed! Please check the error messages above.
        echo Common solutions:
        echo 1. Run 'flutter doctor' to check for missing dependencies
        echo 2. Accept Android licenses: 'flutter doctor --android-licenses'
        echo 3. Make sure Android SDK is installed
        echo 4. Check that ANDROID_HOME or ANDROID_SDK_ROOT is set
    )
) else if "%choice%"=="4" (
    echo.
    echo Building Windows...
    echo Checking Windows platform support...
    flutter config --enable-windows-desktop
    echo.
    flutter build windows --release
    if %errorlevel% equ 0 (
        echo.
        echo Windows build created!
        echo Location: build\windows\x64\runner\Release\
        start "" "build\windows\x64\runner\Release"
    ) else (
        echo.
        echo Windows build failed!
        echo Make sure Windows desktop support is enabled:
        echo flutter config --enable-windows-desktop
        echo flutter create . --platforms windows
    )
) else if "%choice%"=="5" (
    echo.
    echo Building Web...
    echo Checking Web platform support...
    flutter config --enable-web
    echo.
    flutter build web --release
    if %errorlevel% equ 0 (
        echo.
        echo Web build created!
        echo Location: build\web\
        start "" "build\web"
    ) else (
        echo.
        echo Web build failed!
        echo Make sure Web platform support is enabled:
        echo flutter config --enable-web
        echo flutter create . --platforms web
    )
) else if "%choice%"=="6" (
    echo.
    echo Testing API Connection...
    echo Make sure backend server is running (npm run dev in project root)
    echo.
    echo Testing health endpoint...
    curl -X GET http://localhost:3000/api/health
    echo.
    
    echo Testing login endpoint...
    curl -X POST http://localhost:3000/api/auth/login -H "Content-Type: application/json" -d "{\"username\":\"testuser\",\"password\":\"password123\"}"
    echo.
    
    echo Testing register endpoint...
    curl -X POST http://localhost:3000/api/auth/register -H "Content-Type: application/json" -d "{\"username\":\"newuser\",\"password\":\"password123\"}"
    echo.
    
    echo Testing users endpoint...
    curl -X GET http://localhost:3000/api/users
    echo.
    
    echo Testing chats endpoint...
    curl -X GET http://localhost:3000/api/messages/chats
    echo.
    
    echo Testing messages endpoint...
    curl -X GET http://localhost:3000/api/messages/2
    echo.
    
    echo.
    echo API test completed!
    echo If the tests fail, make sure the backend server is running on port 3000
) else (
    echo Invalid option!
)

echo.
pause