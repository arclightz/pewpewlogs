// frontend/vite.config.js
import { defineConfig } from 'vite';
import vue from '@vitejs/plugin-vue';

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [vue()],
  server: {
    host: '0.0.0.0', // This allows connections from any IP address
    port: 5173,      // Your frontend port
    // Add the allowedHosts configuration to explicitly allow 'pew.mrdj.stream'
    // This is crucial when accessing your Vite development server via a custom domain or proxy.
    allowedHosts: [
      'pew.mrdj.stream', // Add the problematic host here
      // You might also want to include 'localhost' if you access it directly
      'localhost',
      // Add any other hosts or IP addresses from which you expect requests
    ],
  },
  // If you are using a proxy for API calls (e.g., in production or for specific dev setups),
  // ensure your proxy configuration is also correct.
  // proxy: {
  //   '/api': {
  //     target: 'http://backend:3000', // Or your backend service name/IP in Docker
  //     changeOrigin: true,
  //     rewrite: (path) => path.replace(/^\/api/, ''),
  //   },
  // },
});