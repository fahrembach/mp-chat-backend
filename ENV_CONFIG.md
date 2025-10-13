# Configuração do .env para Render PostgreSQL
# Copie este conteúdo para um arquivo .env na raiz do projeto

# Database - Render PostgreSQL
DATABASE_URL="postgresql://mpchat_user:lRBgJQCTDoXymDjMIIlqZIq3bMl1fX9P@dpg-d3m7es1r0fns73egf1kg-a/mpchat"

# Server
PORT=3001
NODE_ENV=development

# JWT Secret
JWT_SECRET="mp-chat-super-secret-jwt-key-2024"

# CORS Origins
CORS_ORIGINS="http://localhost:3000,http://127.0.0.1:3000"

# INSTRUÇÕES:
# 1. Copie o conteúdo acima para um arquivo .env na raiz do projeto
# 2. Execute: npm run db:push para sincronizar o schema
# 3. Execute: npm run dev para testar localmente
