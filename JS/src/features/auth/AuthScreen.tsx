import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Eye, EyeOff, Loader2 } from 'lucide-react';
import { authService } from '../../services/authService';
import { useChatStore } from '../../store/useChatStore';

export const AuthScreen: React.FC = () => {
    const [isLogin, setIsLogin] = useState(true);
    const [isLoading, setIsLoading] = useState(false);
    const [showPassword, setShowPassword] = useState(false);
    const [error, setError] = useState('');

    const [formData, setFormData] = useState({
        username: '',
        password: '',
        name: ''
    });

    const navigate = useNavigate();
    const login = useChatStore((state) => state.login);

    const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        setFormData({ ...formData, [e.target.name]: e.target.value });
        setError('');
    };

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setIsLoading(true);
        setError('');

        try {
            let response;
            if (isLogin) {
                response = await authService.login({
                    username: formData.username,
                    password: formData.password
                });
            } else {
                response = await authService.register({
                    username: formData.username,
                    password: formData.password,
                    name: formData.name
                });
            }

            login(response.user, response.token);
            navigate('/');
        } catch (err: any) {
            console.error(err);
            setError(err.response?.data?.message || 'Ocorreu um erro. Tente novamente.');
        } finally {
            setIsLoading(false);
        }
    };

    return (
        <div className="flex items-center justify-center h-screen bg-whatsapp-background font-sans">
            {/* Header Background Strip */}
            <div className="absolute top-0 w-full h-52 bg-whatsapp-primary z-0" />

            <div className="bg-white p-10 rounded-lg shadow-lg z-10 w-full max-w-md animate-in fade-in zoom-in duration-300">
                <div className="flex flex-col items-center mb-8">
                    <div className="w-16 h-16 bg-whatsapp-primary rounded-full flex items-center justify-center mb-4 shadow-md">
                        <svg viewBox="0 0 33 33" width="33" height="33" className="" fill="white">
                            <path d="M16.6 0C7.4 0 0 7.4 0 16.5c0 3 .8 5.9 2.3 8.4L.6 33l8.3-2.2C11.2 32.2 13.8 33 16.6 33 25.7 33 33.1 25.6 33.1 16.5 33.1 7.4 25.7 0 16.6 0zm0 27.8c-2.5 0-4.9-.7-7-1.9l-.5-.3-5.2 1.4 1.4-5-.3-.5C3.9 19.4 3.2 17 3.2 14.5c0-7.4 6-13.4 13.4-13.4 7.4 0 13.4 6 13.4 13.4 0 7.4-6 13.3-13.4 13.3z"></path>
                        </svg>
                    </div>
                    <h1 className="text-2xl font-light text-gray-700">
                        {isLogin ? 'Entrar no WhatsApp' : 'Criar nova conta'}
                    </h1>
                </div>

                {error && (
                    <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative mb-4 text-sm">
                        {error}
                    </div>
                )}

                <form onSubmit={handleSubmit} className="flex flex-col gap-4">
                    {!isLogin && (
                        <div className="flex flex-col gap-1">
                            <label className="text-sm text-gray-600">Nome</label>
                            <input
                                type="text"
                                name="name"
                                value={formData.name}
                                onChange={handleChange}
                                className="border border-gray-300 rounded-md p-2 focus:outline-none focus:border-whatsapp-primary focus:ring-1 focus:ring-whatsapp-primary transition-all"
                                placeholder="Seu nome"
                                required={!isLogin}
                            />
                        </div>
                    )}

                    <div className="flex flex-col gap-1">
                        <label className="text-sm text-gray-600">Usuário</label>
                        <input
                            type="text"
                            name="username"
                            value={formData.username}
                            onChange={(e) => {
                                const val = e.target.value.replace(/\s/g, ''); // No spaces
                                setFormData({ ...formData, username: val });
                                setError('');
                            }}
                            className="border border-gray-300 rounded-md p-2 focus:outline-none focus:border-whatsapp-primary focus:ring-1 focus:ring-whatsapp-primary transition-all"
                            placeholder="Seu usuário"
                            required
                        />
                    </div>

                    <div className="flex flex-col gap-1 relative">
                        <label className="text-sm text-gray-600">Senha</label>
                        <div className="relative">
                            <input
                                type={showPassword ? "text" : "password"}
                                name="password"
                                value={formData.password}
                                onChange={handleChange}
                                className="border border-gray-300 rounded-md p-2 w-full focus:outline-none focus:border-whatsapp-primary focus:ring-1 focus:ring-whatsapp-primary transition-all"
                                placeholder="Sua senha"
                                required
                            />
                            <button
                                type="button"
                                onClick={() => setShowPassword(!showPassword)}
                                className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
                            >
                                {showPassword ? <EyeOff size={20} /> : <Eye size={20} />}
                            </button>
                        </div>
                    </div>

                    <button
                        type="submit"
                        disabled={isLoading}
                        className="bg-whatsapp-primary text-white py-2 rounded-md font-semibold hover:bg-whatsapp-secondary transition-colors flex items-center justify-center gap-2 mt-2 disabled:opacity-70 disabled:cursor-not-allowed"
                    >
                        {isLoading && <Loader2 size={20} className="animate-spin" />}
                        {isLogin ? 'Entrar' : 'Cadastrar'}
                    </button>
                </form>

                <div className="mt-6 text-center">
                    <button
                        onClick={() => {
                            setIsLogin(!isLogin);
                            setError('');
                            setFormData({ username: '', password: '', name: '' });
                        }}
                        className="text-whatsapp-primary hover:underline text-sm font-medium"
                    >
                        {isLogin ? 'Não tem conta? Cadastre-se' : 'Já tem conta? Entrar'}
                    </button>
                </div>

                <div className="mt-8 text-center">
                    <span className="text-xs text-gray-400">from</span>
                    <h6 className="text-xs font-bold text-gray-500 tracking-widest">META</h6>
                </div>
            </div>
        </div>
    );
};
