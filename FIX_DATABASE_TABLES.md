# 🔧 **SOLUÇÃO: Criar Tabelas no Banco do Render**

## ❌ **Problema:**
```
The table `public.users` does not exist in the current database.
```

## ✅ **Solução:**

### **Método 1: Via Render Dashboard (Mais Fácil)**

1. **Acesse**: [Render Dashboard](https://dashboard.render.com)
2. **Vá para**: Seu Web Service (`projeto`)
3. **Clique em**: "Shell" (terminal)
4. **Execute**:
   ```bash
   npm run db:push
   ```

### **Método 2: Via Pre-Deploy Command**

1. **No Render Dashboard**, vá para o seu Web Service
2. **Clique em**: "Settings"
3. **Na seção "Advanced"**, adicione:
   - **Pre-Deploy Command**: `npm run db:push`
4. **Salve e faça um novo deploy**

### **Método 3: Via Terminal Local**

Se você conseguir acessar o banco diretamente:

```bash
# Conectar ao banco do Render
PGPASSWORD=lRBgJQCTDoXymDjMIIlqZIq3bMl1fX9P psql -h dpg-d3m7es1r0fns73egf1kg-a.oregon-postgres.render.com -U mpchat_user mpchat

# Depois executar:
npm run db:push
```

## 🎯 **Resultado Esperado:**

Após executar `npm run db:push`, você deve ver:
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

**Execute o Método 1 (via Shell do Render) para resolver rapidamente!** 🚀
