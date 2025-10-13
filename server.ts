// server.ts - Backend API + Socket.IO for Flutter App
import { createServer, IncomingMessage, ServerResponse } from 'http';
import { Server } from 'socket.io';
import { z } from 'zod';
import { db } from './lib/db';
import { setupSocket } from './lib/socket';

const port = process.env.PORT || 3001;
const hostname = '0.0.0.0';

// --- Helper Functions ---
const getBody = (req: IncomingMessage): Promise<any> => {
  return new Promise((resolve, reject) => {
    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', () => {
      if (body === '') return resolve({});
      try {
        resolve(JSON.parse(body));
      } catch (error) {
        console.error('[HELPER] Error parsing JSON body:', error);
        reject('Invalid JSON');
      }
    });
  });
};

const sendJson = (res: ServerResponse, statusCode: number, data: any) => {
  res.writeHead(statusCode, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify(data));
};

const getAuthUserId = (req: IncomingMessage): string | null => {
    const authHeader = req.headers['authorization'];
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        console.warn('   [AUTH] ❌ Auth failed: Missing or invalid Authorization header.');
        return null;
    }
    const token = authHeader.split(' ')[1];
    try {
        const decoded = Buffer.from(token, 'base64').toString('ascii');
        const [userId] = decoded.split(':');
        if (!userId) console.warn('   [AUTH] ❌ Auth failed: User ID not found in token.');
        return userId || null;
    } catch (e) {
        console.warn('   [AUTH] ❌ Auth failed: Invalid token format.');
        return null;
    }
};

// --- Zod Schemas ---
const RegisterSchema = z.object({ username: z.string().min(3), password: z.string().min(6) });
const LoginSchema = z.object({ username: z.string(), password: z.string() });
const MessageSchema = z.object({ receiverId: z.string(), content: z.string(), type: z.string().optional() });

// --- Main Request Handler ---
const requestHandler = async (req: IncomingMessage, res: ServerResponse) => {
  const url = new URL(req.url || '', `http://${req.headers.host}`);
  const path = url.pathname;
  const method = req.method;
  
  console.log(`\n➡️  [HTTP] Received ${method} request for ${path}`);

  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (method === 'OPTIONS') {
    console.log('➡️  [HTTP] Responding to OPTIONS preflight request.');
    res.writeHead(204);
    res.end();
    return;
  }

  try {
    // --- Health Check ---
    if (path === '/api/health' && method === 'GET') {
      console.log('✔️  [HEALTH] Health check successful.');
      return sendJson(res, 200, { status: 'ok', message: 'm-p-chat backend is running', timestamp: new Date().toISOString() });
    }

    // --- Auth Routes ---
    if (path.startsWith('/api/auth')) {
        if (path === '/api/auth/register' && method === 'POST') {
            console.log('-> [AUTH] Attempting user registration...');
            const body = await getBody(req);
            const parsed = RegisterSchema.safeParse(body);
            if (!parsed.success) return sendJson(res, 400, { error: 'Invalid input', details: parsed.error.issues });
            const { username, password } = parsed.data;
            const existingUser = await db.user.findUnique({ where: { username } });
            if (existingUser) return sendJson(res, 409, { error: 'Username already exists' });
            const user = await db.user.create({ data: { username, passwordHash: password, email: `${username}@example.com` } });
            const accessToken = Buffer.from(`${user.id}:${user.username}`).toString('base64');
            return sendJson(res, 201, { message: 'User registered successfully', access_token: accessToken, user: { id: user.id, username: user.username, email: user.email } });
        }
        if (path === '/api/auth/login' && method === 'POST') {
            console.log('-> [AUTH] Attempting user login...');
            const body = await getBody(req);
            const parsed = LoginSchema.safeParse(body);
            if (!parsed.success) return sendJson(res, 400, { error: 'Invalid input' });
            const { username, password } = parsed.data;
            const user = await db.user.findUnique({ where: { username } });
            if (!user || user.passwordHash !== password) return sendJson(res, 401, { error: 'Invalid credentials' });
            const accessToken = Buffer.from(`${user.id}:${user.username}`).toString('base64');
            return sendJson(res, 200, { message: 'Login successful', access_token: accessToken, user: { id: user.id, username: user.username, email: user.email } });
        }
    }

    // --- Users Route ---
    if (path === '/api/users' && method === 'GET') {
        console.log('-> [API] Fetching all users...');
        const users = await db.user.findMany({ select: { id: true, username: true, email: true, isOnline: true, lastSeen: true } });
        console.log(`   [API] ✅ Found ${users.length} users.`);
        return sendJson(res, 200, users);
    }

    // --- Messages & Chats Routes ---
    const userId = getAuthUserId(req);
    if (!userId) return sendJson(res, 401, { error: 'Unauthorized' });

    if (path === '/api/messages/chats' && method === 'GET') {
        console.log(`-> [API] Fetching chats for user ${userId}...`);
        
        // Buscar mensagens do usuário
        const messages = await db.message.findMany({
            where: { OR: [{ senderId: userId }, { receiverId: userId }] },
            orderBy: { createdAt: 'desc' },
            include: { sender: true, receiver: true },
        });
        const chatsMap = new Map();
        messages.forEach(msg => {
            const otherUser = msg.senderId === userId ? msg.receiver : msg.sender;
            if (!chatsMap.has(otherUser.id)) {
                chatsMap.set(otherUser.id, {
                    id: otherUser.id,
                    participant: otherUser,
                    lastMessage: msg,
                    unreadCount: 0, // Simplified for now
                    updatedAt: msg.createdAt,
                });
            }
        });
        const chats = Array.from(chatsMap.values());
        console.log(`   [API] ✅ Found ${chats.length} chats for user ${userId}.`);
        return sendJson(res, 200, chats);
    }

    if (path.startsWith('/api/messages/') && method === 'GET') {
        const peerId = path.split('/')[3];
        console.log(`-> [API] Fetching messages between ${userId} and ${peerId}...`);
        const messages = await db.message.findMany({
            where: {
                OR: [
                    { senderId: userId, receiverId: peerId },
                    { senderId: peerId, receiverId: userId },
                ],
            },
            orderBy: { createdAt: 'asc' },
        });
        console.log(`   [API] ✅ Found ${messages.length} messages.`);
        return sendJson(res, 200, messages);
    }

    if (path === '/api/messages' && method === 'POST') {
        console.log(`-> [API] User ${userId} is creating a message...`);
        const body = await getBody(req);
        const parsed = MessageSchema.safeParse(body);
        if (!parsed.success) return sendJson(res, 400, { error: 'Invalid input' });
        const { receiverId, content, type } = parsed.data;
        const message = await db.message.create({
            data: { senderId: userId, receiverId, content, type: type || 'text' },
        });
        console.log(`   [API] ✅ Message created with ID: ${message.id}`);
        return sendJson(res, 201, message);
    }

    // --- 404 Not Found ---
    console.warn(`   [HTTP] ❌ Route not found: ${method} ${path}`);
    return sendJson(res, 404, { error: 'Route not found' });

  } catch (error) {
    console.error(`\n‼️  [SERVER ERROR] An unexpected error occurred for ${method} ${path}`);
    console.error('   Error Details:', error);
    return sendJson(res, 500, { error: 'Internal Server Error', details: error instanceof Error ? error.message : 'Unknown error' });
  }
};

// --- Server Initialization ---
const server = createServer(requestHandler);
const io = new Server(server, { cors: { origin: "*", methods: ["GET", "POST"] } });
setupSocket(io);
server.listen(port, hostname, () => {
  console.log(`\n🚀 m-p-chat Backend Server is live!`);
  console.log(`   Listening on http://${hostname}:${port}`);
  console.log('   Waiting for connections...');
});