import axios from 'axios';
import { useChatStore } from '../store/useChatStore';

const api = axios.create({
    baseURL: 'http://localhost:3002/api',
});

api.interceptors.request.use((config) => {
    const token = useChatStore.getState().token;
    if (token) {
        config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
});

export default api;
