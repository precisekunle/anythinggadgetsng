import React, { useEffect, useState } from 'react';
import { CheckCircle2, X } from 'lucide-react';

interface ToastProps {
    message: string;
    onClose: () => void;
    duration?: number;
}

const Toast: React.FC<ToastProps> = ({ message, onClose, duration = 2500 }) => {
    const [visible, setVisible] = useState(false);

    useEffect(() => {
        const show = setTimeout(() => setVisible(true), 10);
        const hide = setTimeout(() => {
            setVisible(false);
            setTimeout(onClose, 300);
        }, duration);
        return () => {
            clearTimeout(show);
            clearTimeout(hide);
        };
    }, [onClose, duration]);

    return (
        <div className={`fixed bottom-6 left-1/2 -translate-x-1/2 z-[9999] transition-all duration-300 ${visible ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-4'}`}>
            <div className="bg-gray-900 text-white px-5 py-3 rounded-xl shadow-xl flex items-center gap-3 min-w-[220px]">
                <CheckCircle2 size={18} className="text-green-400 flex-shrink-0" />
                <span className="text-sm font-medium">{message}</span>
                <button onClick={() => { setVisible(false); setTimeout(onClose, 300); }} className="ml-auto text-gray-400 hover:text-white">
                    <X size={16} />
                </button>
            </div>
        </div>
    );
};

export default Toast;

export const useToast = () => {
    const [toasts, setToasts] = useState<{ id: number; message: string }[]>([]);
    let counter = 0;

    const showToast = (message: string) => {
        const id = ++counter;
        setToasts(prev => [...prev, { id, message }]);
    };

    const removeToast = (id: number) => {
        setToasts(prev => prev.filter(t => t.id !== id));
    };

    const ToastContainer = () => (
        <>
            {toasts.map(t => (
                <Toast key={t.id} message={t.message} onClose={() => removeToast(t.id)} />
            ))}
        </>
    );

    return { showToast, ToastContainer };
};
