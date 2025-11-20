import React, { useEffect } from 'react';
import { ArrowLeft, Phone, Video, MoreVertical } from 'lucide-react';
import { MessageBubble } from './MessageBubble';
import { InputBar } from './InputBar';
import { useChatStore } from '../../../store/useChatStore';
import { useParams, useNavigate } from 'react-router-dom';
import api from '../../../services/api';
import { useSocket } from '../../../hooks/useSocket';

export const ChatRoom: React.FC = () => {
    const { id } = useParams<{ id: string }>();
    const navigate = useNavigate();
    const { messages, activeChat, addMessage, currentUser } = useChatStore();
    const socket = useSocket();

    useEffect(() => {
        if (id) {
            const fetchMessages = async () => {
                try {
                    const response = await api.get(`/messages/${id}`);
                    // Assuming response.data is an array of messages
                    // We need to update the store. For now, let's iterate and add them if not present
                    // Or better, we should have a setMessages action in the store.
                    // Since addMessage appends, we might need to clear or set.
                    // For simplicity, let's assume the store handles this or we just rely on realtime for new ones
                    // and this load is for history.
                    // Ideally: setMessages(id, response.data);
                    // But let's just log for now as we might need to update the store structure to support bulk set
                    console.log('Fetched messages:', response.data);
                    response.data.forEach((msg: any) => addMessage(id, msg));
                } catch (error) {
                    console.error('Error fetching messages:', error);
                }
            };
            fetchMessages();
        }
    }, [id, addMessage]);

    const handleSendMessage = (text: string) => {
        <div className="flex flex-col h-full bg-whatsapp-chatBg relative">
            {/* Background Doodle */}
            <div className="absolute inset-0 bg-chat-doodles opacity-40 pointer-events-none" />

            {/* Header */}
            <div className="flex items-center justify-between px-4 py-2 bg-whatsapp-primary text-white z-10">
                <div className="flex items-center gap-2">
                    <button onClick={() => navigate('/')} className="p-1">
                        <ArrowLeft size={24} />
                    </button>
                    <div className="flex items-center gap-2 cursor-pointer">
                        <div className="w-10 h-10 rounded-full bg-gray-300 overflow-hidden">
                            {activeChat?.avatar ? (
                                <img src={activeChat.avatar} alt={activeChat.name} className="w-full h-full object-cover" />
                            ) : (
                                <div className="w-full h-full flex items-center justify-center bg-gray-400 text-white font-bold">
                                    {activeChat?.name?.charAt(0) || '?'}
                                </div>
                            )}
                        </div>
                        <div className="flex flex-col">
                            <span className="font-semibold text-base leading-tight">{activeChat?.name || 'Contato'}</span>
                            <span className="text-xs opacity-90">Online</span>
                        </div>
                    </div>
                </div>

                <div className="flex items-center gap-4">
                    <Video size={24} className="cursor-pointer" />
                    <Phone size={22} className="cursor-pointer" />
                    <MoreVertical size={22} className="cursor-pointer" />
                </div>
            </div>

            {/* Messages Area */}
            <div className="flex-1 overflow-y-auto p-4 z-10 scrollbar-thin">
                {chatMessages.map((msg) => (
                    <MessageBubble
                        key={msg.id}
                        message={msg}
                        isOwn={msg.senderId === currentUser?.id}
                    />
                ))}
            </div>

            {/* Input Area */}
            <div className="z-10">
                <InputBar onSend={handleSendMessage} onSendMedia={handleSendMedia} />
            </div>
        </div>
    );
};
