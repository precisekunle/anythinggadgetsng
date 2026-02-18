import React, { useEffect, useState } from 'react';
import { useServerTime } from '../hooks/useServerTime';
import { Clock } from 'lucide-react';

interface CountdownTimerProps {
    endTime: Date;
}

const CountdownTimer: React.FC<CountdownTimerProps> = ({ endTime }) => {
    const now = useServerTime();

    const diff = endTime.getTime() - now.getTime();

    const getTimeLeft = () => {
        if (diff <= 0) {
            return { hours: '00', minutes: '00', seconds: '00' };
        }

        const hours = Math.floor((diff / (1000 * 60 * 60))).toString().padStart(2, '0');
        const minutes = Math.floor((diff / (1000 * 60)) % 60).toString().padStart(2, '0');
        const seconds = Math.floor((diff / 1000) % 60).toString().padStart(2, '0');

        return { hours, minutes, seconds };
    };

    const timeLeft = getTimeLeft();

    return (
        <div className="bg-[#EF4444] text-white text-xs sm:text-sm font-mono font-bold px-3 py-1 rounded flex items-center gap-2 shadow-sm">
            <Clock size={14} />
            <span>
                {timeLeft.hours}:{timeLeft.minutes}:{timeLeft.seconds}
            </span>
        </div>
    );
};

export default CountdownTimer;
