# Configuração para Render PostgreSQL
# Copie este conteúdo para um arquivo .env na raiz do projeto

# Database - Render PostgreSQL
DATABASE_URL="postgresql://mpchat_user:YOUR_PASSWORD@dpg-d3m7es1r0fns73egf1kg-a:5432/mpchat"

# Server
PORT=3001
NODE_ENV=development

# JWT Secret
JWT_SECRET="your-super-secret-jwt-key-here-change-this"

# CORS Origins
CORS_ORIGINS="http://localhost:3000,http://127.0.0.1:3000"

# INSTRUÇÕES:
# 1. Copie o conteúdo acima para um arquivo .env na raiz do projeto
# 2. Substitua YOUR_PASSWORD pela senha real do banco (que está oculta no Render)
# 3. Execute: npm run db:push para sincronizar o schema
# 4. Execute: npm run dev para testar localmente
