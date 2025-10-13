# 🔧 **SOLUÇÃO para Plano Gratuito do Render**

## ❌ **Problema:**
- Plano gratuito não tem acesso ao Shell
- Tabelas não foram criadas no banco PostgreSQL do Render

## ✅ **Soluções:**

### **Método 1: Pre-Deploy Command (RECOMENDADO)**

1. **Acesse**: [Render Dashboard](https://dashboard.render.com)
2. **Vá para**: Seu Web Service (`projeto`)
3. **Clique em**: "Settings"
4. **Na seção "Advanced"**, adicione:
   - **Pre-Deploy Command**: `npm run db:push`
5. **Salve as configurações**
6. **Faça um novo deploy** (clique em "Manual Deploy")

### **Método 2: Modificar Build Command**

1. **No Render Dashboard**, vá para o seu Web Service
2. **Clique em**: "Settings"
3. **Mude o Build Command** de:
   ```
   npm install && npm run db:generate
   ```
   Para:
   ```
   npm install && npm run db:generate && npm run db:push
   ```
4. **Salve e faça um novo deploy**

### **Método 3: Via Terminal Local (se conseguir conectar)**

Se você conseguir conectar ao banco do Render localmente:

1. **Crie um arquivo `.env`** na raiz do projeto com:
   ```env
   DATABASE_URL="postgresql://mpchat_user:lRBgJQCTDoXymDjMIIlqZIq3bMl1fX9P@dpg-d3m7es1r0fns73egf1kg-a/mpchat"
   ```

2. **Execute**:
   ```bash
   npm run db:push
   ```

## 🎯 **Resultado Esperado:**

Após executar qualquer método, você deve ver:
```
✅ Database schema updated successfully
```

## 🚀 **Depois da Correção:**

1. **Teste o registro** no Flutter
2. **Teste o login** no Flutter
3. **Verifique se as mensagens carregam**

## 📋 **Comandos Disponíveis:**

- `npm run db:push` - Sincroniza schema com o banco
- `npm run db:generate` - Gera cliente Prisma
- `npm run db:studio` - Abre Prisma Studio (não funciona no Render)

**Execute o Método 1 (Pre-Deploy Command) para resolver rapidamente!** 🚀
