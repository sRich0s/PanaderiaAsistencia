import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

// El frontend llama a /api y /uploads; Vite los reenvía al servidor Express.
// Así no hay problemas de CORS y la tableta solo necesita abrir el puerto 5173.
export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    proxy: {
      '/api': 'http://localhost:4000',
      '/uploads': 'http://localhost:4000',
    },
  },
});
