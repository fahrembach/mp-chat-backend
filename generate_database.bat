@echo off
echo =================================================
echo   Gerando arquivos do banco de dados Drift...
echo =================================================
cd /d "%~dp0"

flutter pub run build_runner build --delete-conflicting-outputs

if %errorlevel% neq 0 (
    echo.
    echo =================================================
    echo   ERRO: Falha ao gerar os arquivos do banco de dados.
    echo   Verifique os erros acima.
    echo =================================================
    pause
    exit /b 1
)

echo.
echo =================================================
echo   SUCESSO: Arquivos do banco de dados gerados com sucesso!
echo =================================================
pause