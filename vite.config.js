import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { resolve } from 'path'

export default defineConfig({
  plugins: [vue()],
  root: '.',
  build: {
    outDir: 'app/assets/builds',
    rollupOptions: {
      input: {
        application: resolve(__dirname, 'app/javascript/application.js')
      },
      output: {
        entryFileNames: 'application.js',
        assetFileNames: '[name].[ext]'
      }
    },
    manifest: true,
    sourcemap: true
  },
  resolve: {
    alias: {
      '@': resolve(__dirname, 'app/javascript'),
      '~': resolve(__dirname, 'node_modules')
    }
  },
  server: {
    port: 3036,
    hmr: {
      port: 3037
    }
  }
})
