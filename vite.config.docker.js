import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { resolve } from 'path'

export default defineConfig({
  plugins: [vue()],
  root: '.',
  server: {
    port: 5601,
    host: '0.0.0.0',
    hmr: {
      port: 5602,
      host: '0.0.0.0'
    },
    proxy: {
      '/api': {
        target: 'http://backend:5609',
        changeOrigin: true,
        secure: false
      }
    }
  },
  resolve: {
    alias: {
      '@': resolve(__dirname, 'app/javascript'),
      '~': resolve(__dirname, 'node_modules')
    }
  },
  build: {
    outDir: 'app/assets/builds',
    rollupOptions: {
      input: {
        application: resolve(__dirname, 'app/javascript/application.js')
      }
    },
    manifest: true,
    sourcemap: true
  }
})
