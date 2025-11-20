import React, { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { format } from 'date-fns';
import { Check, CheckCheck } from 'lucide-react';
import api from '../../../services/api';
import { useChatStore } from '../../../store/useChatStore';

export const ChatListScreen: React.FC = () => {
    const navigate = useNavigate();
    const { chats, setChats, currentUser } = useChatStore();

    useEffect(() => {
        const fetchChats = async () => {
            try {
                const response = await api.get('/messages/chats');
                setChats(response.data);
            } catch (error) {
                console.error('Error fetching chats:', error);
            }
        };

        fetchChats();
    }, [setChats]);

    return (
        <div className="h-full overflow-y-auto bg-white">
            {chats.map((chat) => {
                const otherParticipant = chat.isGroup
                    ? null
                    : chat.participants.find(p => p.id !== currentUser?.id) || chat.participants[0];

                const chatName = chat.isGroup ? chat.name : (otherParticipant?.username || chat.name);
                const avatarUrl = chat.isGroup ? chat.avatar : otherParticipant?.avatar;

                return (
                    <div
                        key={chat.id}
                        onClick={() => navigate(`/chat/${chat.id}`)}
                        className="flex items-center px-4 py-3 cursor-pointer hover:bg-gray-100 active:bg-gray-200 transition-colors"
                    >
                        {/* Avatar */}
                        <div className="w-12 h-12 rounded-full bg-gray-300 flex-shrink-0 mr-3 overflow-hidden">
                            {avatarUrl ? (
                                <img src={avatarUrl} alt={chatName} className="w-full h-full object-cover" />
                            ) : (
                                <div className="w-full h-full flex items-center justify-center bg-gray-400 text-white font-bold text-xl">
                                    {chatName?.charAt(0).toUpperCase()}
                                </div>
                            )}
                        </div>

                        {/* Content */}
                        <div className="flex-1 border-b border-gray-100 pb-3 min-w-0">
                            <div className="flex justify-between items-baseline mb-1">
                                <h3 className="font-semibold text-base text-whatsapp-messageText truncate">{chatName}</h3>
                                <span className="text-xs text-whatsapp-secondaryText">
                                    {chat.lastMessage && format(new Date(chat.lastMessage.timestamp), 'HH:mm')}
                                </span>
                            </div>

                            <div className="flex justify-between items-center">
                                <div className="flex items-center text-sm text-whatsapp-secondaryText truncate pr-2">
                                    {chat.lastMessage?.senderId === currentUser?.id && (
                                        <span className="mr-1">
                                            {chat.lastMessage?.status === 'read' ? <CheckCheck size={16} className="text-blue-500" /> : <Check size={16} />}
                                        </span>
                                    )}
                                    <span className="truncate">{chat.lastMessage?.content}</span>
                                </div>

                                {chat.unreadCount > 0 && (
                                    <div className="w-5 h-5 rounded-full bg-whatsapp-secondary text-white text-xs font-bold flex items-center justify-center flex-shrink-0">
                                        {chat.unreadCount}
                                    </div>
                                )}
                            </div>
                        </div>
                    </div>
                );
            })}
        </div>
    );
};
