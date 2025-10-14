@echo off
echo 🚀 Iniciando testes automatizados...
echo ⏰ Aguardando backend atualizar (30 segundos)...
timeout /t 30 /nobreak

echo 🧪 Criando usuários de teste...

echo ✅ Criando Usuário 1...
curl -X POST "https://mp-chat-backend.onrender.com/api/auth/register" ^
  -H "Content-Type: application/json" ^
  -d "{\"username\":\"testuser1\",\"email\":\"test1@example.com\",\"password\":\"password123\",\"name\":\"Usuário Teste 1\",\"phone\":\"+5511999999991\"}"

echo.
echo ✅ Criando Usuário 2...
curl -X POST "https://mp-chat-backend.onrender.com/api/auth/register" ^
  -H "Content-Type: application/json" ^
  -d "{\"username\":\"testuser2\",\"email\":\"test2@example.com\",\"password\":\"password123\",\"name\":\"Usuário Teste 2\",\"phone\":\"+5511999999992\"}"

echo.
echo ✅ Testes concluídos!
pause
