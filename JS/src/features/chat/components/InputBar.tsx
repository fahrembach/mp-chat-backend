import React, { useState, useRef, useEffect } from 'react';
import { Smile, Paperclip, Camera, Mic, Send, Lock, FileText, Image, Headphones, MapPin, User, Trash2 } from 'lucide-react';
import clsx from 'clsx';
import { uploadFile, getMediaType } from '../../../services/uploadService';
import { MessageType } from '../../../types';

interface InputBarProps {
    onSend?: (text: string) => void;
    onSendMedia?: (mediaUrl: string, type: MessageType, fileName?: string) => void;
}

export const InputBar: React.FC<InputBarProps> = ({ onSend, onSendMedia }) => {
    const [message, setMessage] = useState('');
    const [isRecording, setIsRecording] = useState(false);
    const [recordingTime, setRecordingTime] = useState(0);
    const [isLocked, setIsLocked] = useState(false);
    const [showAttachments, setShowAttachments] = useState(false);
    const [isUploading, setIsUploading] = useState(false);

    const timerRef = useRef<ReturnType<typeof setInterval> | null>(null);
    const fileInputRef = useRef<HTMLInputElement>(null);
    const imageInputRef = useRef<HTMLInputElement>(null);

    useEffect(() => {
        if (isRecording) {
            timerRef.current = setInterval(() => {
                setRecordingTime(prev => prev + 1);
            }, 1000);
        } else {
            if (timerRef.current) clearInterval(timerRef.current);
            setRecordingTime(0);
        }
        return () => {
            if (timerRef.current) clearInterval(timerRef.current);
        };
    }, [isRecording]);

    const formatTime = (seconds: number) => {
        const mins = Math.floor(seconds / 60);
        const secs = seconds % 60;
        return `${mins}:${secs.toString().padStart(2, '0')}`;
    };

    const handleSend = () => {
        if (message.trim() || isRecording) {
            if (onSend && message.trim()) {
                onSend(message);
            } else {
                console.log('Sending:', message || 'Audio Message');
            }
            setMessage('');
            setIsRecording(false);
            setIsLocked(false);
        }
    };

    const startRecording = () => {
        setIsRecording(true);
    };

    const stopRecording = () => {
        if (!isLocked) {
            setIsRecording(false);
        }
    };

    const cancelRecording = () => {
        setIsRecording(false);
        setIsLocked(false);
    };

    const handleFileUpload = async (file: File) => {
        if (!onSendMedia) return;

        setIsUploading(true);
        setShowAttachments(false);

        try {
            const { url } = await uploadFile(file);
            const mediaType = getMediaType(file);
            onSendMedia(url, mediaType, file.name);
        } catch (error) {
            console.error('Error uploading file:', error);
            alert('Erro ao enviar arquivo. Tente novamente.');
        } finally {
            setIsUploading(false);
        }
    };

    const handleFileSelect = (type: 'document' | 'image') => {
        const input = type === 'document' ? fileInputRef.current : imageInputRef.current;
        input?.click();
    };

    return (
        <div className="relative">
            {/* Hidden File Inputs */}
            <input
                ref={fileInputRef}
                type="file"
                className="hidden"
                accept="*/*"
                onChange={(e) => e.target.files?.[0] && handleFileUpload(e.target.files[0])}
            />
            <input
                ref={imageInputRef}
                type="file"
                className="hidden"
                accept="image/*,video/*"
                onChange={(e) => e.target.files?.[0] && handleFileUpload(e.target.files[0])}
            />

            {/* Attachment Menu (Bottom Sheet) */}
            {showAttachments && (
                <div className="absolute bottom-16 left-2 bg-white rounded-xl shadow-xl p-4 grid grid-cols-3 gap-4 z-50 animate-in slide-in-from-bottom-4 fade-in duration-200 mb-2">
                    <AttachmentItem
                        icon={<FileText size={24} />}
                        color="bg-indigo-500"
                        label="Documento"
                        onClick={() => handleFileSelect('document')}
                    />
                    <AttachmentItem
                        icon={<Camera size={24} />}
                        color="bg-pink-500"
                        label="Câmera"
                        onClick={() => handleFileSelect('image')}
                    />
                    <AttachmentItem
                        icon={<Image size={24} />}
                        color="bg-purple-500"
                        label="Galeria"
                        onClick={() => handleFileSelect('image')}
                    />
                    <AttachmentItem icon={<Headphones size={24} />} color="bg-orange-500" label="Áudio" />
                    <AttachmentItem icon={<MapPin size={24} />} color="bg-green-500" label="Localização" />
                    <AttachmentItem icon={<User size={24} />} color="bg-blue-500" label="Contato" />
                </div>
            )}

            <div className="flex items-end p-2 bg-[#f0f2f5] gap-2 min-h-[60px]">
                {isRecording && !isLocked ? (
                    <div className="flex-1 flex items-center justify-between px-4 animate-pulse text-gray-600">
                        <div className="flex items-center gap-2">
                            <Mic size={20} className="text-red-500 animate-pulse" />
                            <span>{formatTime(recordingTime)}</span>
                        </div>
                        <span className="text-sm text-gray-400">Deslize para cancelar &lt;</span>
                    </div>
                ) : (
                    <>
                        <div className={clsx("flex-1 bg-white rounded-2xl flex items-end px-2 py-2 shadow-sm transition-all", isLocked && "hidden")}>
                            <button className="p-2 hover:bg-gray-100 rounded-full text-gray-500 transition-colors">
                                <Smile size={24} />
                            </button>

                            <input
                                type="text"
                                placeholder="Mensagem"
                                className="flex-1 mx-2 py-2 outline-none text-base min-h-[24px] max-h-[100px]"
                                value={message}
                                onChange={(e) => setMessage(e.target.value)}
                                onKeyDown={(e) => e.key === 'Enter' && handleSend()}
                            />

                            <button
                                className="p-2 hover:bg-gray-100 rounded-full text-gray-500 transition-colors -rotate-45"
                                onClick={() => setShowAttachments(!showAttachments)}
                            >
                                <Paperclip size={24} />
                            </button>

                            {!message && (
                                <button className="p-2 hover:bg-gray-100 rounded-full text-gray-500 transition-colors">
                                    <Camera size={24} />
                                </button>
                            )}
                        </div>
                    </>
                )}

                {/* Mic/Send Button Area */}
                <div className="relative flex items-center justify-center w-12 h-12">
                    {isRecording && isLocked ? (
                        <div className="flex items-center gap-3 absolute right-0 bottom-0 bg-[#f0f2f5] pl-2">
                            <button onClick={cancelRecording} className="p-3 text-red-500 hover:bg-red-50 rounded-full">
                                <Trash2 size={24} />
                            </button>
                            <span className="text-gray-600 font-mono">{formatTime(recordingTime)}</span>
                            <button onClick={handleSend} className="p-3 bg-whatsapp-primary text-white rounded-full shadow-md hover:bg-whatsapp-secondary">
                                <Send size={20} />
                            </button>
                        </div>
                    ) : (
                        <button
                            className={clsx(
                                "flex items-center justify-center w-12 h-12 rounded-full text-white shadow-md transition-all duration-200 z-20",
                                isRecording ? "bg-red-500 scale-110" : "bg-whatsapp-primary hover:bg-whatsapp-secondary"
                            )}
                            onMouseDown={!message ? startRecording : undefined}
                            onMouseUp={!message ? stopRecording : undefined}
                            onMouseLeave={!message ? stopRecording : undefined}
                            onClick={message ? handleSend : undefined}
                        >
                            {message ? <Send size={20} /> : <Mic size={20} />}
                        </button>
                    )}

                    {/* Lock Indicator (Visual cue for dragging up) */}
                    {isRecording && !isLocked && (
                        <div className="absolute -top-16 flex flex-col items-center animate-bounce opacity-80">
                            <Lock size={16} className="text-gray-500 mb-1" />
                            <div className="w-8 h-20 bg-gradient-to-t from-gray-200 to-transparent rounded-full opacity-50" />
                        </div>
                    )}
                </div>
            </div>
        </div>
    );
};

const AttachmentItem: React.FC<{ icon: React.ReactNode; color: string; label: string; onClick?: () => void }> = ({ icon, color, label, onClick }) => (
    <div
        className="flex flex-col items-center gap-2 cursor-pointer hover:opacity-80 transition-opacity"
        onClick={onClick}
    >
        <div className={clsx("w-14 h-14 rounded-full flex items-center justify-center text-white shadow-md", color)}>
            {icon}
        </div>
        <span className="text-xs text-gray-600">{label}</span>
    </div>
);
