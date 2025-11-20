import { Server, Socket } from 'socket.io';
import { db } from './db';

interface AuthenticatedSocket extends Socket {
  userId?: string;
}

export const setupSocket = (io: Server) => {
  io.on('connection', (socket: AuthenticatedSocket) => {
    console.log(`\n🔌 [SOCKET] Client connected: ${socket.id}`);

    const token = socket.handshake.auth.token as string;
    if (token) {
      try {
        console.log(`   [SOCKET] Authenticating token for ${socket.id}...`);
        const decoded = Buffer.from(token, 'base64').toString('ascii');
        const [userId] = decoded.split(':');
        if (userId) {
          socket.userId = userId;
          socket.join(userId);
          console.log(`   [SOCKET] ✅ User ${userId} authenticated and joined room "${userId}".`);
        } else {
          console.warn(`   [SOCKET] ❌ Auth failed: User ID not found in token.`);
        }
      } catch (e) {
        console.warn(`   [SOCKET] ❌ Auth failed: Invalid token format.`);
      }
    } else {
      console.warn(`   [SOCKET] ⚠️ Connection from ${socket.id} without auth token.`);
    }

    socket.on('sendMessage', async (data: {
      receiverId: string;
      content: string;
      type?: string;
      mediaUrl?: string;
      fileName?: string;
      fileSize?: string;
    }) => {
      if (!socket.userId) {
        console.warn(`   [SOCKET] ❌ Message blocked from unauthenticated socket ${socket.id}.`);
        return socket.emit('error', { message: 'Not authenticated' });
      }

      console.log(`-> [MSG] User ${socket.userId} is sending a message to ${data.receiverId}`);
      console.log(`   [MSG] Content: "${data.content}"`);

      try {
        console.log('   [MSG] Saving message to database...');
        const message = await db.message.create({
          data: {
            content: data.content,
            type: data.type || 'text',
            senderId: socket.userId,
            receiverId: data.receiverId,
            mediaUrl: data.mediaUrl,
            fileName: data.fileName,
            fileSize: data.fileSize ? parseInt(data.fileSize) : null
          }
        });
        console.log(`   [MSG] ✅ Message saved with ID: ${message.id}`);

        console.log(`   [MSG] Emitting 'newMessage' to room "${data.receiverId}"...`);
        io.to(data.receiverId).emit('newMessage', message);

        console.log(`   [MSG] Emitting 'messageSent' confirmation to sender ${socket.id}...`);
        socket.emit('messageSent', message);

      } catch (error) {
        console.error(`   [MSG] ‼️  ERROR sending message from ${socket.userId}:`, error);
        socket.emit('error', { message: 'Failed to send message' });
      }
    });

    // Listeners para chamadas P2P
    socket.on('callOffer', async (data: {
      receiverId: string;
      callId: string;
      offer: { sdp: string; type: string };
    }) => {
      if (!socket.userId) {
        console.warn(`   [CALL] ❌ Call offer blocked from unauthenticated socket ${socket.id}.`);
        return socket.emit('error', { message: 'Not authenticated' });
      }

      console.log(`📞 [CALL] User ${socket.userId} is making a call to ${data.receiverId}`);
      console.log(`   [CALL] Call ID: ${data.callId}`);

      try {
        // Enviar oferta para o destinatário
        io.to(data.receiverId).emit('callOffer', {
          callerId: socket.userId,
          callId: data.callId,
          offer: data.offer,
        });
        console.log(`   [CALL] ✅ Call offer sent to ${data.receiverId}`);
      } catch (error) {
        console.error(`   [CALL] ‼️ ERROR sending call offer:`, error);
        socket.emit('error', { message: 'Failed to send call offer' });
      }
    });

    socket.on('callAnswer', async (data: {
      receiverId: string;
      callId: string;
      answer: { sdp: string; type: string };
    }) => {
      if (!socket.userId) {
        console.warn(`   [CALL] ❌ Call answer blocked from unauthenticated socket ${socket.id}.`);
        return socket.emit('error', { message: 'Not authenticated' });
      }

      console.log(`📞 [CALL] User ${socket.userId} answered call ${data.callId}`);

      try {
        // Enviar resposta para o chamador
        io.to(data.receiverId).emit('callAnswer', {
          answererId: socket.userId,
          callId: data.callId,
          answer: data.answer,
        });
        console.log(`   [CALL] ✅ Call answer sent to ${data.receiverId}`);
      } catch (error) {
        console.error(`   [CALL] ‼️ ERROR sending call answer:`, error);
        socket.emit('error', { message: 'Failed to send call answer' });
      }
    });

    socket.on('iceCandidate', async (data: {
      receiverId: string;
      callId: string;
      candidate: { candidate: string; sdpMid: string; sdpMLineIndex: number };
    }) => {
      if (!socket.userId) {
        console.warn(`   [CALL] ❌ ICE candidate blocked from unauthenticated socket ${socket.id}.`);
        return socket.emit('error', { message: 'Not authenticated' });
      }

      console.log(`🧊 [CALL] ICE candidate from ${socket.userId} for call ${data.callId}`);

      try {
        // Enviar ICE candidate para o peer
        io.to(data.receiverId).emit('iceCandidate', {
          senderId: socket.userId,
          callId: data.callId,
          candidate: data.candidate,
        });
        console.log(`   [CALL] ✅ ICE candidate sent to ${data.receiverId}`);
      } catch (error) {
        console.error(`   [CALL] ‼️ ERROR sending ICE candidate:`, error);
        socket.emit('error', { message: 'Failed to send ICE candidate' });
      }
    });

    socket.on('callEnd', async (data: {
      receiverId: string;
      callId: string;
    }) => {
      if (!socket.userId) {
        console.warn(`   [CALL] ❌ Call end blocked from unauthenticated socket ${socket.id}.`);
        return socket.emit('error', { message: 'Not authenticated' });
      }

      console.log(`📞 [CALL] User ${socket.userId} ended call ${data.callId}`);

      try {
        // Enviar sinal de fim para o peer
        io.to(data.receiverId).emit('callEnd', {
          senderId: socket.userId,
          callId: data.callId,
        });
        console.log(`   [CALL] ✅ Call end signal sent to ${data.receiverId}`);
      } catch (error) {
        console.error(`   [CALL] ‼️ ERROR sending call end:`, error);
        socket.emit('error', { message: 'Failed to send call end' });
      }
    });

    socket.on('disconnect', () => {
      console.log(`🔌 [SOCKET] Client disconnected: ${socket.id} (User: ${socket.userId || 'N/A'})`);
      if (socket.userId) {
        db.user.update({ where: { id: socket.userId }, data: { isOnline: false, lastSeen: new Date() } })
          .then(() => console.log(`   [STATUS] User ${socket.userId} marked as offline.`))
          .catch(err => console.error(`   [STATUS] ‼️  ERROR updating user status for ${socket.userId}:`, err));
        socket.broadcast.emit('userOffline', { userId: socket.userId });
      }
    });
  });
};