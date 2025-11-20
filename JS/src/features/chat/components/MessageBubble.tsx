import React from 'react';
import { Message } from '../../../types';
import { Check, CheckCheck, FileText, Download } from 'lucide-react';
import clsx from 'clsx';
import { format } from 'date-fns';

interface MessageBubbleProps {
    message: Message;
    isOwn: boolean;
}

const MediaContent: React.FC<{ message: Message }> = ({ message }) => {
    if (!message.mediaUrl) return null;

    switch (message.type) {
        case 'image':
            return (
                <img
                    src={message.mediaUrl}
                    alt="Imagem"
                    className="rounded-lg max-w-full h-auto mb-1"
                    loading="lazy"
                />
            );

        case 'video':
            return (
                <video
                    src={message.mediaUrl}
                    controls
                    className="rounded-lg max-w-full h-auto mb-1"
                    preload="metadata"
                />
            );

        case 'audio':
            return (
                <audio
                    src={message.mediaUrl}
                    controls
                    className="w-full mb-1"
                    preload="metadata"
                />
            );

        case 'document':
            return (
                <a
                    href={message.mediaUrl}
                    download={message.fileName}
                    className="flex items-center gap-2 p-2 bg-gray-100 rounded-lg mb-1 hover:bg-gray-200 transition-colors"
                >
                    <FileText size={24} className="text-gray-600" />
                    <div className="flex-1 min-w-0">
                        <div className="text-sm font-medium truncate">{message.fileName || 'Documento'}</div>
                        {message.fileSize && <div className="text-xs text-gray-500">{message.fileSize}</div>}
                    </div>
                    <Download size={20} className="text-gray-600" />
                </a>
            );

        default:
            return null;
    }
};

export const MessageBubble: React.FC<MessageBubbleProps> = ({ message, isOwn }) => {
    const hasMedia = message.mediaUrl && message.type !== 'text';

    return (
        <div className={clsx(
            "flex w-full mb-2 relative",
            isOwn ? "justify-end" : "justify-start"
        )}>
            {/* Tail SVG */}
            <div className={clsx(
                "absolute top-0 z-0",
                isOwn ? "-right-2" : "-left-2"
            )}>
                {isOwn ? (
                    <svg viewBox="0 0 8 13" height="13" width="8" preserveAspectRatio="xMidYMid slice" version="1.1">
                        <path opacity="0.13" d="M5.188,1H0v11.193l6.467-8.625 C7.526,2.156,6.958,1,5.188,1z"></path>
                        <path fill="currentColor" className="text-whatsapp-outgoing" d="M5.188,0H0v11.193l6.467-8.625C7.526,1.156,6.958,0,5.188,0z"></path>
                    </svg>
                ) : (
                    <svg viewBox="0 0 8 13" height="13" width="8" preserveAspectRatio="xMidYMid slice" version="1.1">
                        <path opacity="0.13" d="M1.533,3.568L8,12.193V1H2.812 C1.042,1,0.474,2.156,1.533,3.568z"></path>
                        <path fill="currentColor" className="text-white" d="M1.533,2.568L8,11.193V0L2.812,0C1.042,0,0.474,1.156,1.533,2.568z"></path>
                    </svg>
                )}
            </div>

            <div className={clsx(
                "relative max-w-[65%] rounded-lg shadow-sm text-sm z-10",
                hasMedia ? "p-1" : "p-2",
                isOwn ? "bg-whatsapp-outgoing rounded-tr-none" : "bg-white rounded-tl-none"
            )}>
                {/* Media Content */}
                {hasMedia && <MediaContent message={message} />}

                {/* Text Content */}
                {message.content && (
                    <div className={clsx(
                        "break-words leading-relaxed text-whatsapp-messageText",
                        hasMedia ? "px-1 pb-1" : "mb-1"
                    )}>
                        {message.content}
                    </div>
                )}

                {/* Timestamp and Status */}
                <div className={clsx(
                    "flex justify-end items-center gap-1 select-none",
                    hasMedia && "px-1 pb-1"
                )}>
                    <span className="text-[11px] text-whatsapp-secondaryText min-w-fit">
                        {format(new Date(message.timestamp), 'HH:mm')}
                    </span>
                    {isOwn && (
                        <span>
                            {message.status === 'read' ? (
                                <CheckCheck size={16} className="text-[#53bdeb]" />
                            ) : message.status === 'delivered' ? (
                                <CheckCheck size={16} className="text-gray-500" />
                            ) : (
                                <Check size={16} className="text-gray-500" />
                            )}
                        </span>
                    )}
                </div>
            </div>
        </div>
    );
};
