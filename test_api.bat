@echo off
title M-P Chat - API Test
echo.
echo ========================================
echo     M-P Chat - API Connection Test
echo ========================================
echo.

echo Testing backend connection...
curl -X GET http://localhost:3000/api/health
echo.

echo.
echo Testing login endpoint...
curl -X POST http://localhost:3000/api/auth/login ^
  -H "Content-Type: application/json" ^
  -d "{\"username\":\"testuser\",\"password\":\"password123\"}"
echo.

echo.
echo Testing register endpoint...
curl -X POST http://localhost:3000/api/auth/register ^
  -H "Content-Type: application/json" ^
  -d "{\"username\":\"newuser\",\"password\":\"password123\"}"
echo.

echo.
echo API test completed!
pause