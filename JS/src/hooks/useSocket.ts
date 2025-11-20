import { useEffect, useRef } from 'react';
import { io, Socket } from 'socket.io-client';
import { useChatStore } from '../store/useChatStore';

const SOCKET_URL = 'http://localhost:3002';

export const useSocket = () => {
    const { token, currentUser, addMessage } = useChatStore();
    const socketRef = useRef<Socket | null>(null);

    useEffect(() => {
        if (token && !socketRef.current) {
            console.log('🔌 Connecting to socket...');
            socketRef.current = io(SOCKET_URL, {
                auth: {
                    token: token // Pass token directly as expected by backend
                }
            });

            socketRef.current.on('connect', () => {
                console.log('✅ Socket connected:', socketRef.current?.id);
            });

            socketRef.current.on('connect_error', (err) => {
                console.error('❌ Socket connection error:', err);
            });

            socketRef.current.on('newMessage', (message: any) => {
                console.log('📩 New message received:', message);
                // Determine chat ID based on context (group or individual)
                const chatId = message.groupId || (message.senderId === currentUser?.id ? message.receiverId : message.senderId);
                if (chatId) {
                    addMessage(chatId, message);
                }
            });

            socketRef.current.on('messageSent', (message: any) => {
                console.log('📤 Message sent confirmation:', message);
                // Determine chat ID based on context (group or individual)
                const chatId = message.groupId || (message.senderId === currentUser?.id ? message.receiverId : message.senderId);
                if (chatId) {
                    addMessage(chatId, message);
                }
            });
        }

        return () => {
            if (!token && socketRef.current) {
                console.log('🔌 Disconnecting socket...');
                socketRef.current.disconnect();
                socketRef.current = null;
            }
        };
    }, [token, currentUser, addMessage]);

    return socketRef.current;
};
