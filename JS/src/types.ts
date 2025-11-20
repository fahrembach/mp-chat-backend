export interface User {
    id: string;
    username: string;
    avatar?: string;
    status?: string;
}

export type MessageType = 'text' | 'image' | 'audio' | 'video' | 'document';

export interface Message {
    id: string;
    content: string;
    senderId: string;
    timestamp: string;
    type: MessageType;
    status: 'sent' | 'delivered' | 'read';
    mediaUrl?: string;
    mediaDuration?: number; // for audio/video
    fileName?: string; // for documents
    fileSize?: string; // for documents
}

export interface Chat {
    id: string;
    name: string;
    isGroup: boolean;
    avatar?: string;
    participants: User[];
    lastMessage?: Message;
    unreadCount: number;
}

export interface Call {
    id: string;
    callerId: string;
    receiverId: string;
    type: 'audio' | 'video';
    startTime: string;
    duration?: number;
    status: 'missed' | 'ended' | 'ongoing';
}
