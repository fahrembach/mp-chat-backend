import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import { Chat, Message, User } from '../types';

interface ChatState {
    currentUser: User | null;
    token: string | null;
    activeChat: Chat | null;
    chats: Chat[];
    messages: Record<string, Message[]>; // chat_id -> messages

    setCurrentUser: (user: User) => void;
    setToken: (token: string) => void;
    login: (user: User, token: string) => void;
    logout: () => void;
    setActiveChat: (chat: Chat) => void;
    setChats: (chats: Chat[]) => void;
    addMessage: (chatId: string, message: Message) => void;
}

export const useChatStore = create<ChatState>()(
    persist(
        (set) => ({
            currentUser: null,
            token: null,
            activeChat: null,
            chats: [],
            messages: {},

            setCurrentUser: (user) => set({ currentUser: user }),
            setToken: (token) => set({ token }),
            login: (user, token) => set({ currentUser: user, token }),
            logout: () => set({ currentUser: null, token: null, activeChat: null, chats: [], messages: {} }),
            setActiveChat: (chat) => set({ activeChat: chat }),
            setChats: (chats) => set({ chats }),
            addMessage: (chatId, message) => set((state) => ({
                messages: {
                    ...state.messages,
                    [chatId]: [...(state.messages[chatId] || []), message]
                }
            })),
        }),
        {
            name: 'chat-storage',
            partialize: (state) => ({ currentUser: state.currentUser, token: state.token }), // Only persist user and token
        }
    )
);
