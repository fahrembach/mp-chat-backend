/** @type {import('tailwindcss').Config} */
export default {
    content: [
        "./index.html",
        "./src/**/*.{js,ts,jsx,tsx}",
    ],
    theme: {
        extend: {
            colors: {
                whatsapp: {
                    primary: '#00a884',    // Teal Green (Header/Buttons)
                    secondary: '#008069',  // Darker Teal
                    background: '#e9edef', // Global Light Gray
                    chatBg: '#efeae2',     // Chat Background (Beige)
                    outgoing: '#d9fdd3',   // Light Green Bubble (User)
                    incoming: '#ffffff',   // White Bubble (Contact)
                    messageText: '#111b21',
                    secondaryText: '#667781', // Timestamps, checkmarks
                    danger: '#ea0038',
                }
            },
            backgroundImage: {
                'chat-doodles': "url('https://user-images.githubusercontent.com/15075759/28719144-86dc0f70-73b1-11e7-911d-60d70fcded21.png')" // Standard WA Doodle
            }
        },
    },
    plugins: [],
}
