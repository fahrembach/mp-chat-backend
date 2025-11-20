import api from './api';
import { User } from '../types';

interface AuthResponse {
    user: User;
    token: string;
}

export const authService = {
    login: async (data: any): Promise<AuthResponse> => {
        const response = await api.post('/auth/login', data);
        return response.data;
    },

    register: async (data: any): Promise<AuthResponse> => {
        const response = await api.post('/auth/register', data);
        return response.data;
    },
};
