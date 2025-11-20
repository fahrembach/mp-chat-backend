import React, { useState } from 'react';
import { Outlet, useNavigate } from 'react-router-dom';
import { Camera, Search, MoreVertical, MessageSquare, Phone } from 'lucide-react';
import clsx from 'clsx';

type Tab = 'chats' | 'status' | 'calls';

export const MainLayout: React.FC = () => {
    const [activeTab, setActiveTab] = useState<Tab>('chats');
    const [isMenuOpen, setIsMenuOpen] = useState(false);
    const navigate = useNavigate();

    const handleTabChange = (tab: Tab) => {
        setActiveTab(tab);
        // In a real app, you might navigate to different routes here
        // navigate(`/${tab}`);
    };

    const toggleMenu = () => setIsMenuOpen(!isMenuOpen);

    return (
        <div className="flex flex-col h-screen bg-whatsapp-background relative">
            {/* Header */}
            <div className="bg-whatsapp-primary text-white pt-4 shadow-md z-20">
                <div className="flex justify-between items-center px-4 mb-4">
                    <h1 className="text-xl font-bold">WhatsApp</h1>
                    <div className="flex gap-5 items-center relative">
                        <Camera size={22} className="cursor-pointer" />
                        <Search size={22} className="cursor-pointer" />
                        <button onClick={toggleMenu} className="focus:outline-none">
                            <MoreVertical size={22} className="cursor-pointer" />
                        </button>

                        {/* Dropdown Menu */}
                        {isMenuOpen && (
                            <div className="absolute top-8 right-0 bg-white text-gray-800 rounded-lg shadow-xl py-2 w-48 z-50 origin-top-right">
                                <MenuItem label="Novo Grupo" onClick={() => { }} />
                                <MenuItem label="Nova Transmissão" onClick={() => { }} />
                                <MenuItem label="Aparelhos Conectados" onClick={() => { }} />
                                <MenuItem label="Mensagens Favoritas" onClick={() => { }} />
                                <MenuItem label="Configurações" onClick={() => navigate('/settings')} />
                                <MenuItem label="Reiniciar Sessão" onClick={() => window.location.reload()} />
                            </div>
                        )}
                    </div>
                </div>

                {/* Tabs */}
                <div className="flex text-gray-200 font-medium uppercase text-sm">
                    <div className="w-8 flex justify-center items-center pb-3 cursor-pointer hover:bg-white/10">
                        <Camera size={20} className="opacity-60" />
                    </div>
                    <TabItem
                        label="Conversas"
                        isActive={activeTab === 'chats'}
                        onClick={() => handleTabChange('chats')}
                    />
                    <TabItem
                        label="Status"
                        isActive={activeTab === 'status'}
                        onClick={() => handleTabChange('status')}
                    />
                    <TabItem
                        label="Ligações"
                        isActive={activeTab === 'calls'}
                        onClick={() => handleTabChange('calls')}
                    />
                </div>
            </div>

            {/* Content */}
            <div className="flex-1 overflow-hidden relative" onClick={() => setIsMenuOpen(false)}>
                <Outlet />

                {/* FAB */}
                <button className="absolute bottom-6 right-6 w-14 h-14 bg-whatsapp-secondary rounded-full flex items-center justify-center text-white shadow-lg hover:bg-whatsapp-primary transition-colors z-10">
                    {activeTab === 'chats' && <MessageSquare size={24} fill="white" />}
                    {activeTab === 'status' && <Camera size={24} />}
                    {activeTab === 'calls' && <Phone size={24} fill="white" />}
                </button>
            </div>
        </div>
    );
};

const TabItem: React.FC<{ label: string; isActive: boolean; onClick: () => void }> = ({ label, isActive, onClick }) => (
    <div
        onClick={onClick}
        className={clsx(
            "flex-1 text-center pb-3 cursor-pointer transition-colors",
            isActive ? "border-b-[3px] border-white text-white" : "opacity-70 hover:opacity-100 hover:bg-white/10"
        )}
    >
        {label}
    </div>
);

const MenuItem: React.FC<{ label: string; onClick: () => void }> = ({ label, onClick }) => (
    <button
        onClick={onClick}
        className="w-full text-left px-4 py-3 hover:bg-gray-100 text-base"
    >
        {label}
    </button>
);
