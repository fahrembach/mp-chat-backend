// server.ts - Backend API + Socket.IO for Flutter App with Complete Features
import { createServer, IncomingMessage, ServerResponse } from 'http';
import { Server } from 'socket.io';
import { z } from 'zod';
import { db } from './lib/db';
import { setupSocket } from './lib/socket';
import { v4 as uuidv4 } from 'uuid';
import * as fs from 'fs';
import * as path from 'path';

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
const RegisterSchema = z.object({ 
  username: z.string().min(3), 
  password: z.string().min(6),
  email: z.string().email().optional(),
  name: z.string().optional(),
  phone: z.string().optional()
});

const LoginSchema = z.object({ username: z.string(), password: z.string() });

const MessageSchema = z.object({ 
  receiverId: z.string().optional(),
  groupId: z.string().optional(),
  content: z.string(), 
  type: z.string().default("text"),
  replyToId: z.string().optional(),
  forwardedFromId: z.string().optional(),
  isTemporary: z.boolean().default(false),
  expiresAt: z.string().optional(),
  metadata: z.string().optional()
});

const GroupSchema = z.object({
  name: z.string().min(1),
  description: z.string().optional(),
  isPrivate: z.boolean().default(false),
  memberIds: z.array(z.string()).optional()
});

const StatusUpdateSchema = z.object({
  content: z.string(),
  type: z.string().default("text"),
  mediaUrl: z.string().optional(),
  expiresAt: z.string().optional()
});

const CommunitySchema = z.object({
  name: z.string().min(1),
  description: z.string().optional(),
  isPrivate: z.boolean().default(false)
});

const UserSettingsSchema = z.object({
  theme: z.string().optional(),
  language: z.string().optional(),
  notifications: z.boolean().optional(),
  soundEnabled: z.boolean().optional(),
  vibrationEnabled: z.boolean().optional(),
  readReceipts: z.boolean().optional(),
  lastSeen: z.boolean().optional(),
  profilePhoto: z.boolean().optional(),
  statusPrivacy: z.string().optional(),
  groupInvitePrivacy: z.string().optional(),
  callPrivacy: z.string().optional(),
  mediaAutoDownload: z.boolean().optional(),
  mediaDownloadWifiOnly: z.boolean().optional(),
  fontSize: z.string().optional(),
  accessibilityMode: z.boolean().optional()
});

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
            const { username, password, email, name, phone } = parsed.data;
            const existingUser = await db.user.findUnique({ where: { username } });
            if (existingUser) return sendJson(res, 409, { error: 'Username already exists' });
            const user = await db.user.create({ 
              data: { 
                username, 
                passwordHash: password, 
                email: email || `${username}@example.com`,
                name: name || username,
                phone
              } 
            });
            
            // Criar configurações padrão
            await db.userSettings.create({
              data: { userId: user.id }
            });
            
            const accessToken = Buffer.from(`${user.id}:${user.username}`).toString('base64');
            return sendJson(res, 201, { 
              message: 'User registered successfully', 
              access_token: accessToken, 
              user: { 
                id: user.id, 
                username: user.username, 
                email: user.email,
                name: user.name,
                phone: user.phone,
                avatar: user.avatar,
                status: user.status
              } 
            });
        }
        if (path === '/api/auth/login' && method === 'POST') {
            console.log('-> [AUTH] Attempting user login...');
            const body = await getBody(req);
            const parsed = LoginSchema.safeParse(body);
            if (!parsed.success) return sendJson(res, 400, { error: 'Invalid input' });
            const { username, password } = parsed.data;
            const user = await db.user.findUnique({ where: { username } });
            if (!user || user.passwordHash !== password) return sendJson(res, 401, { error: 'Invalid credentials' });
            
            // Atualizar status online
            await db.user.update({
              where: { id: user.id },
              data: { isOnline: true, lastSeen: new Date() }
            });
            
            const accessToken = Buffer.from(`${user.id}:${user.username}`).toString('base64');
            return sendJson(res, 200, { 
              message: 'Login successful', 
              access_token: accessToken, 
              user: { 
                id: user.id, 
                username: user.username, 
                email: user.email,
                name: user.name,
                phone: user.phone,
                avatar: user.avatar,
                status: user.status,
                isOnline: true
              } 
            });
        }
    }

    // --- Users Routes ---
    if (path === '/api/users' && method === 'GET') {
        console.log('-> [API] Fetching all users...');
        const users = await db.user.findMany({ 
          select: { 
            id: true, 
            username: true, 
            email: true, 
            name: true,
            phone: true,
            bio: true,
            avatar: true,
            isOnline: true, 
            lastSeen: true,
            status: true
          } 
        });
        console.log(`   [API] ✅ Found ${users.length} users.`);
        return sendJson(res, 200, users);
    }

    if (path.startsWith('/api/users/search') && method === 'GET') {
        const query = url.searchParams.get('q');
        if (!query) return sendJson(res, 400, { error: 'Query parameter required' });
        
        console.log(`-> [API] Searching users with query: ${query}`);
        const users = await db.user.findMany({
          where: {
            OR: [
              { username: { contains: query } },
              { name: { contains: query } },
              { email: { contains: query } }
            ]
          },
          select: { 
            id: true, 
            username: true, 
            email: true, 
            name: true,
            phone: true,
            bio: true,
            avatar: true,
            isOnline: true, 
            lastSeen: true,
            status: true
          }
        });
        console.log(`   [API] ✅ Found ${users.length} users matching "${query}".`);
        return sendJson(res, 200, users);
    }

    // --- Messages & Chats Routes ---
    const userId = getAuthUserId(req);
    if (!userId) return sendJson(res, 401, { error: 'Unauthorized' });

    if (path === '/api/messages/chats' && method === 'GET') {
        console.log(`-> [API] Fetching chats for user ${userId}...`);
        
        // Buscar mensagens do usuário
        const messages = await db.message.findMany({
            where: { 
              OR: [
                { senderId: userId }, 
                { receiverId: userId },
                { group: { members: { some: { userId } } } }
              ]
            },
            orderBy: { createdAt: 'desc' },
            include: { 
              sender: true, 
              receiver: true,
              group: true,
              replyTo: { include: { sender: true } }
            },
        });
        
        const chatsMap = new Map();
        messages.forEach(msg => {
            let chatKey;
            let otherUser;
            
            if (msg.groupId) {
              // Chat de grupo
              chatKey = `group_${msg.groupId}`;
              if (!chatsMap.has(chatKey)) {
                chatsMap.set(chatKey, {
                  id: msg.groupId,
                  type: 'group',
                  group: msg.group,
                  lastMessage: msg,
                  unreadCount: 0,
                  updatedAt: msg.createdAt,
                });
              }
            } else {
              // Chat individual
              otherUser = msg.senderId === userId ? msg.receiver : msg.sender;
              if (otherUser) {
                chatKey = otherUser.id;
                if (!chatsMap.has(chatKey)) {
                  chatsMap.set(chatKey, {
                    id: otherUser.id,
                    type: 'individual',
                    participant: otherUser,
                    lastMessage: msg,
                    unreadCount: 0,
                    updatedAt: msg.createdAt,
                  });
                }
              }
            }
        });
        
        const chats = Array.from(chatsMap.values());
        console.log(`   [API] ✅ Found ${chats.length} chats for user ${userId}.`);
        return sendJson(res, 200, chats);
    }

    if (path.startsWith('/api/messages/search') && method === 'GET') {
        const query = url.searchParams.get('q');
        const chatId = url.searchParams.get('chatId');
        if (!query) return sendJson(res, 400, { error: 'Query parameter required' });
        
        console.log(`-> [API] Searching messages with query: ${query}`);
        
        let whereClause: any = {
          OR: [
            { content: { contains: query } }
          ]
        };
        
        if (chatId) {
          whereClause.AND = [
            {
              OR: [
                { senderId: userId, receiverId: chatId },
                { senderId: chatId, receiverId: userId },
                { groupId: chatId }
              ]
            }
          ];
        } else {
          whereClause.AND = [
            {
              OR: [
                { senderId: userId },
                { receiverId: userId },
                { group: { members: { some: { userId } } } }
              ]
            }
          ];
        }
        
        const messages = await db.message.findMany({
          where: whereClause,
          orderBy: { createdAt: 'desc' },
          include: { sender: true, receiver: true, group: true },
          take: 50
        });
        
        console.log(`   [API] ✅ Found ${messages.length} messages matching "${query}".`);
        return sendJson(res, 200, messages);
    }

    if (path.startsWith('/api/messages/') && method === 'GET') {
        const peerId = path.split('/')[3];
        console.log(`-> [API] Fetching messages between ${userId} and ${peerId}...`);
        
        // Verificar se é um grupo ou chat individual
        const group = await db.group.findFirst({
          where: { id: peerId, members: { some: { userId } } }
        });
        
        let whereClause: any;
        if (group) {
          whereClause = { groupId: peerId };
        } else {
          whereClause = {
            OR: [
              { senderId: userId, receiverId: peerId },
              { senderId: peerId, receiverId: userId },
            ],
          };
        }
        
        const messages = await db.message.findMany({
            where: whereClause,
            orderBy: { createdAt: 'asc' },
            include: { 
              sender: true, 
              receiver: true,
              replyTo: { include: { sender: true } },
              reactions: { include: { message: true } }
            },
        });
        
        console.log(`   [API] ✅ Found ${messages.length} messages.`);
        return sendJson(res, 200, messages);
    }

    if (path === '/api/messages' && method === 'POST') {
        console.log(`-> [API] User ${userId} is creating a message...`);
        const body = await getBody(req);
        const parsed = MessageSchema.safeParse(body);
        if (!parsed.success) return sendJson(res, 400, { error: 'Invalid input' });
        
        const { receiverId, groupId, content, type, replyToId, forwardedFromId, isTemporary, expiresAt, metadata } = parsed.data;
        
        const messageData: any = {
            senderId: userId,
            content,
            type: type || 'text',
            replyToId,
            forwardedFromId,
            isTemporary: isTemporary || false,
            metadata
        };
        
        if (expiresAt) {
          messageData.expiresAt = new Date(expiresAt);
        }
        
        if (groupId) {
          messageData.groupId = groupId;
        } else if (receiverId) {
          messageData.receiverId = receiverId;
        }
        
        const message = await db.message.create({
            data: messageData,
            include: { 
              sender: true, 
              receiver: true,
              group: true,
              replyTo: { include: { sender: true } }
            }
        });
        
        console.log(`   [API] ✅ Message created with ID: ${message.id}`);
        return sendJson(res, 201, message);
    }

    // --- Groups Routes ---
    if (path === '/api/groups' && method === 'GET') {
        console.log(`-> [API] Fetching groups for user ${userId}...`);
        const groups = await db.group.findMany({
          where: { members: { some: { userId } } },
          include: { 
            creator: true,
            members: { include: { user: true } },
            _count: { select: { messages: true } }
          }
        });
        console.log(`   [API] ✅ Found ${groups.length} groups.`);
        return sendJson(res, 200, groups);
    }

    if (path === '/api/groups' && method === 'POST') {
        console.log(`-> [API] User ${userId} is creating a group...`);
        const body = await getBody(req);
        const parsed = GroupSchema.safeParse(body);
        if (!parsed.success) return sendJson(res, 400, { error: 'Invalid input' });
        
        const { name, description, isPrivate, memberIds } = parsed.data;
        
        const group = await db.group.create({
          data: {
            name,
            description,
            isPrivate: isPrivate || false,
            creatorId: userId,
            inviteCode: uuidv4(),
            members: {
              create: [
                { userId, role: 'admin' },
                ...(memberIds || []).map(id => ({ userId: id, role: 'member' }))
              ]
            }
          },
          include: { 
            creator: true,
            members: { include: { user: true } }
          }
        });
        
        console.log(`   [API] ✅ Group created with ID: ${group.id}`);
        return sendJson(res, 201, group);
    }

    // --- Status Routes ---
    if (path === '/api/status' && method === 'GET') {
        console.log(`-> [API] Fetching status updates...`);
        const statusUpdates = await db.statusUpdate.findMany({
          where: { 
            OR: [
              { userId },
              { user: { statusPrivacy: 'everyone' } },
              { user: { statusPrivacy: 'contacts' } } // TODO: implementar lógica de contatos
            ],
            expiresAt: { gt: new Date() }
          },
          orderBy: { createdAt: 'desc' },
          include: { user: true },
          take: 50
        });
        console.log(`   [API] ✅ Found ${statusUpdates.length} status updates.`);
        return sendJson(res, 200, statusUpdates);
    }

    if (path === '/api/status' && method === 'POST') {
        console.log(`-> [API] User ${userId} is creating a status update...`);
        const body = await getBody(req);
        const parsed = StatusUpdateSchema.safeParse(body);
        if (!parsed.success) return sendJson(res, 400, { error: 'Invalid input' });
        
        const { content, type, mediaUrl, expiresAt } = parsed.data;
        
        const statusUpdate = await db.statusUpdate.create({
          data: {
            userId,
            content,
            type: type || 'text',
            mediaUrl,
            expiresAt: expiresAt ? new Date(expiresAt) : new Date(Date.now() + 24 * 60 * 60 * 1000) // 24 horas por padrão
          },
          include: { user: true }
        });
        
        console.log(`   [API] ✅ Status update created with ID: ${statusUpdate.id}`);
        return sendJson(res, 201, statusUpdate);
    }

    // --- Communities Routes ---
    if (path === '/api/communities' && method === 'GET') {
        console.log(`-> [API] Fetching communities...`);
        const communities = await db.community.findMany({
          where: { 
            OR: [
              { isPrivate: false },
              { members: { some: { userId } } }
            ]
          },
          include: { 
            creator: true,
            members: { include: { user: true } },
            _count: { select: { members: true } }
          }
        });
        console.log(`   [API] ✅ Found ${communities.length} communities.`);
        return sendJson(res, 200, communities);
    }

    if (path === '/api/communities' && method === 'POST') {
        console.log(`-> [API] User ${userId} is creating a community...`);
        const body = await getBody(req);
        const parsed = CommunitySchema.safeParse(body);
        if (!parsed.success) return sendJson(res, 400, { error: 'Invalid input' });
        
        const { name, description, isPrivate } = parsed.data;
        
        const community = await db.community.create({
          data: {
            name,
            description,
            isPrivate: isPrivate || false,
            creatorId: userId,
            inviteCode: uuidv4(),
            members: {
              create: { userId, role: 'admin' }
            }
          },
          include: { 
            creator: true,
            members: { include: { user: true } }
          }
        });
        
        console.log(`   [API] ✅ Community created with ID: ${community.id}`);
        return sendJson(res, 201, community);
    }

    // --- Settings Routes ---
    if (path === '/api/settings' && method === 'GET') {
        console.log(`-> [API] Fetching settings for user ${userId}...`);
        let settings = await db.userSettings.findUnique({
          where: { userId }
        });
        
        if (!settings) {
          settings = await db.userSettings.create({
            data: { userId }
          });
        }
        
        console.log(`   [API] ✅ Settings found for user ${userId}.`);
        return sendJson(res, 200, settings);
    }

    if (path === '/api/settings' && method === 'PUT') {
        console.log(`-> [API] User ${userId} is updating settings...`);
        const body = await getBody(req);
        const parsed = UserSettingsSchema.safeParse(body);
        if (!parsed.success) return sendJson(res, 400, { error: 'Invalid input' });
        
        const settings = await db.userSettings.upsert({
          where: { userId },
          update: parsed.data,
          create: { userId, ...parsed.data }
        });
        
        console.log(`   [API] ✅ Settings updated for user ${userId}.`);
        return sendJson(res, 200, settings);
    }

    // --- Notifications Routes ---
    if (path === '/api/notifications' && method === 'GET') {
        console.log(`-> [API] Fetching notifications for user ${userId}...`);
        const notifications = await db.notification.findMany({
          where: { userId },
          orderBy: { createdAt: 'desc' },
          take: 50
        });
        console.log(`   [API] ✅ Found ${notifications.length} notifications.`);
        return sendJson(res, 200, notifications);
    }

    if (path.startsWith('/api/notifications/') && method === 'PUT') {
        const notificationId = path.split('/')[3];
        console.log(`-> [API] Marking notification ${notificationId} as read...`);
        
        const notification = await db.notification.update({
          where: { id: notificationId },
          data: { isRead: true }
        });
        
        console.log(`   [API] ✅ Notification ${notificationId} marked as read.`);
        return sendJson(res, 200, notification);
    }

    // --- Blocked Users Routes ---
    if (path === '/api/blocked-users' && method === 'GET') {
        console.log(`-> [API] Fetching blocked users for user ${userId}...`);
        const blockedUsers = await db.blockedUser.findMany({
          where: { blockerId: userId },
          include: { blocked: true }
        });
        console.log(`   [API] ✅ Found ${blockedUsers.length} blocked users.`);
        return sendJson(res, 200, blockedUsers);
    }

    if (path === '/api/blocked-users' && method === 'POST') {
        console.log(`-> [API] User ${userId} is blocking a user...`);
        const body = await getBody(req);
        const { blockedId } = body;
        
        if (!blockedId) return sendJson(res, 400, { error: 'Blocked user ID required' });
        
        const blockedUser = await db.blockedUser.create({
          data: { blockerId: userId, blockedId },
          include: { blocked: true }
        });
        
        console.log(`   [API] ✅ User ${blockedId} blocked by ${userId}.`);
        return sendJson(res, 201, blockedUser);
    }

    if (path.startsWith('/api/blocked-users/') && method === 'DELETE') {
        const blockedId = path.split('/')[3];
        console.log(`-> [API] User ${userId} is unblocking user ${blockedId}...`);
        
        await db.blockedUser.deleteMany({
          where: { blockerId: userId, blockedId }
        });
        
        console.log(`   [API] ✅ User ${blockedId} unblocked by ${userId}.`);
        return sendJson(res, 200, { message: 'User unblocked successfully' });
    }

    // --- File Upload Routes ---
    if (path === '/api/files/upload' && method === 'POST') {
        console.log(`-> [API] User ${userId} is uploading a file...`);
        // Implementar upload de arquivos aqui
        return sendJson(res, 501, { error: 'File upload not implemented yet' });
    }

    // --- Stickers Routes ---
    if (path === '/api/stickers' && method === 'GET') {
        console.log(`-> [API] Fetching stickers...`);
        const stickers = await db.sticker.findMany({
          orderBy: { createdAt: 'desc' }
        });
        console.log(`   [API] ✅ Found ${stickers.length} stickers.`);
        return sendJson(res, 200, stickers);
    }

    // --- GIFs Routes ---
    if (path === '/api/gifs' && method === 'GET') {
        console.log(`-> [API] Fetching GIFs...`);
        const gifs = await db.gif.findMany({
          orderBy: { createdAt: 'desc' }
        });
        console.log(`   [API] ✅ Found ${gifs.length} GIFs.`);
        return sendJson(res, 200, gifs);
    }

    // --- Message Reactions Routes ---
    if (path.startsWith('/api/messages/') && path.endsWith('/reactions') && method === 'POST') {
        const messageId = path.split('/')[3];
        console.log(`-> [API] User ${userId} is adding reaction to message ${messageId}...`);
        const body = await getBody(req);
        const { emoji } = body;
        
        if (!emoji) return sendJson(res, 400, { error: 'Emoji required' });
        
        const reaction = await db.messageReaction.upsert({
          where: { 
            messageId_userId_emoji: { 
              messageId, 
              userId, 
              emoji 
            } 
          },
          update: {},
          create: { messageId, userId, emoji }
        });
        
        console.log(`   [API] ✅ Reaction added to message ${messageId}.`);
        return sendJson(res, 201, reaction);
    }

    if (path.startsWith('/api/messages/') && path.endsWith('/reactions') && method === 'DELETE') {
        const messageId = path.split('/')[3];
        const emoji = url.searchParams.get('emoji');
        console.log(`-> [API] User ${userId} is removing reaction from message ${messageId}...`);
        
        if (!emoji) return sendJson(res, 400, { error: 'Emoji required' });
        
        await db.messageReaction.deleteMany({
          where: { messageId, userId, emoji }
        });
        
        console.log(`   [API] ✅ Reaction removed from message ${messageId}.`);
        return sendJson(res, 200, { message: 'Reaction removed successfully' });
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