import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { MainLayout } from '../components/Layout/MainLayout';
import { ChatListScreen } from '../features/chat/components/ChatListScreen';
import { ChatRoom } from '../features/chat/components/ChatRoom';
import { AuthScreen } from '../features/auth/AuthScreen';
import { SettingsScreen } from '../features/settings/SettingsScreen';


import { useChatStore } from '../store/useChatStore';

export const AppRouter: React.FC = () => {
    const token = useChatStore((state) => state.token);
    const isAuthenticated = !!token;

    return (
        <BrowserRouter>
            <Routes>
                <Route path="/auth" element={<AuthScreen />} />

                <Route path="/" element={isAuthenticated ? <MainLayout /> : <Navigate to="/auth" />}>
                    <Route index element={<ChatListScreen />} />
                    <Route path="settings" element={<SettingsScreen />} />
                </Route>

                <Route path="/chat/:id" element={isAuthenticated ? <ChatRoom /> : <Navigate to="/auth" />} />
            </Routes>
        </BrowserRouter>
    );
};
