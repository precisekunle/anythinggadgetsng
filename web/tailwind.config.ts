import type { Config } from 'tailwindcss'

export default {
    content: [
        "./index.html",
        "./src/**/*.{js,ts,jsx,tsx}",
    ],
    theme: {
        extend: {
            colors: {
                'brand-blue': '#007AFF',
                'brand-grey': '#333333',
                'brand-light-grey': '#F5F5F5',
            },
            fontFamily: {
                sans: ['Inter', 'sans-serif'],
            },
            borderRadius: {
                'card': '12px',
            },
        },
    },
    plugins: [],
} satisfies Config
