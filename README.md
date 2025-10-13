# M-P-Chat Backend

Backend API server para aplicação Flutter M-P-Chat usando PostgreSQL e Socket.IO.

## 🚀 Deploy no Render

### 1. Configuração do Banco PostgreSQL

**Name**: `mp-chat-postgres`
**Database**: `mpchat` (ou deixe gerar automaticamente)
**User**: `mpchat_user` (ou deixe gerar automaticamente)
**Region**: `Oregon (US West)` (ou sua região preferida)
**PostgreSQL Version**: `17`

### 2. Configuração do Web Service

**Name**: `mp-chat-backend`
**Environment**: `Node`
**Plan**: `Free`
**Build Command**: `npm install && npm run db:generate`
**Start Command**: `npm start`
**Port**: `3001`

### 3. Variáveis de Ambiente

Configure estas variáveis no Render:

```
NODE_ENV=production
PORT=3001
DATABASE_URL=<conexão do PostgreSQL do Render>
JWT_SECRET=<gerar uma chave secreta forte>
CORS_ORIGINS=*
```

### 4. Comandos Necessários

```bash
# Instalar dependências
npm install

# Gerar cliente Prisma
npm run db:generate

# Fazer push do schema para o banco
npm run db:push

# Iniciar em produção
npm start
```

### 5. Estrutura do Projeto

```
├── server.ts          # Servidor principal
├── lib/
│   ├── db.ts         # Configuração do banco
│   └── socket.ts     # Configuração Socket.IO
├── prisma/
│   └── schema.prisma # Schema do banco
├── package.json      # Dependências
└── render.yaml       # Configuração do Render
```

### 6. URLs Importantes

- **API**: `https://mp-chat-backend.onrender.com`
- **Socket.IO**: `wss://mp-chat-backend.onrender.com`
- **Health Check**: `https://mp-chat-backend.onrender.com/health`

### 7. Troubleshooting

Se houver problemas:

1. Verifique os logs no Render Dashboard
2. Confirme se o `DATABASE_URL` está correto
3. Execute `npm run db:push` para sincronizar o schema
4. Verifique se todas as variáveis de ambiente estão configuradas

### 8. Frontend Flutter

Atualize o `api_service.dart` no Flutter para usar a URL do Render:

```dart
static const String _baseUrl = 'https://mp-chat-backend.onrender.com';
```
