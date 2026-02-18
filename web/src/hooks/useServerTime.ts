import { useState, useEffect, useRef } from 'react';

// Single source of truth for the offset
let globalOffset = 0;
let isInitialized = false;

export const useServerTime = () => {
    // We update this state every second to trigger re-renders in consumers
    const [now, setNow] = useState(Date.now() + globalOffset);
    const hasInitialized = useRef(false);

    useEffect(() => {
        const fetchServerTime = async () => {
            if (isInitialized) return;

            try {
                // Mock Server Time fetch
                // In production: const response = await fetch('/api/time');
                // const serverIso = await response.json(); 
                // const serverTime = new Date(serverIso).getTime();

                // Mocking server time 5 minutes ahead
                const serverTime = Date.now();

                globalOffset = serverTime - Date.now();
                isInitialized = true;
            } catch (error) {
                console.error("Failed to sync time:", error);
                // Fallback to local time is automatic since offset stays 0
            }
        };

        if (!hasInitialized.current) {
            fetchServerTime();
            hasInitialized.current = true;
        }

        const interval = setInterval(() => {
            setNow(Date.now() + globalOffset);
        }, 1000);

        return () => clearInterval(interval);
    }, []);

    return new Date(now);
};
