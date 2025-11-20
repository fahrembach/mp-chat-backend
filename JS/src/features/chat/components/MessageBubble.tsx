import React from 'react';
import { Message } from '../../../types';
import { Check, CheckCheck } from 'lucide-react';
import clsx from 'clsx';
import { format } from 'date-fns';

interface MessageBubbleProps {
    message: Message;
    isOwn: boolean;
}

export const MessageBubble: React.FC<MessageBubbleProps> = ({ message, isOwn }) => {
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
                "relative max-w-[65%] rounded-lg p-2 shadow-sm text-sm z-10",
                isOwn ? "bg-whatsapp-outgoing rounded-tr-none" : "bg-white rounded-tl-none"
            )}>
                <div className="mb-1 break-words leading-relaxed text-whatsapp-messageText">
                    {message.content}
                </div>

                <div className="flex justify-end items-center gap-1 select-none">
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
