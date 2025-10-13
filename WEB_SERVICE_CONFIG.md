# Configuração do Web Service no Render

## Passos para criar o Web Service:

1. **Acesse o Render Dashboard**
2. **Clique em "New +" → "Web Service"**
3. **Conecte seu repositório GitHub**

## Configurações do Web Service:

**Name**: `mp-chat-backend`
**Environment**: `Node`
**Plan**: `Free`
**Build Command**: `npm install && npm run db:generate`
**Start Command**: `npm start`
**Port**: `3001`

## Variáveis de Ambiente no Render:

```
NODE_ENV=production
PORT=3001
DATABASE_URL=postgresql://mpchat_user:lRBgJQCTDoXymDjMIIlqZIq3bMl1fX9P@dpg-d3m7es1r0fns73egf1kg-a/mpchat
JWT_SECRET=mp-chat-super-secret-jwt-key-2024
CORS_ORIGINS=*
```

## URLs que você receberá:

- **API**: `https://mp-chat-backend.onrender.com`
- **Socket.IO**: `wss://mp-chat-backend.onrender.com`
- **Health Check**: `https://mp-chat-backend.onrender.com/health`

## Próximos passos:

1. **Criar o Web Service** com as configurações acima
2. **Adicionar as variáveis de ambiente**
3. **Fazer deploy**
4. **Atualizar o Flutter** para usar a URL do Render