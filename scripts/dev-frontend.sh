#!/bin/bash

echo "🎨 FlowTrace Frontend Başlatılıyor..."
echo "Port: 5601"
echo "Ortam: Development"
echo ""

# Node modules kontrolü
if [ ! -d "node_modules" ] || [ "package.json" -nt "node_modules" ]; then
    echo "📦 NPM install çalıştırılıyor..."
    npm install
fi

# Vite config dosyasını geçici olarak güncelle
echo "⚙️ Vite konfigürasyonu güncelleniyor..."
cat > vite.config.dev.js << 'EOL'
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
      port: 5602
    },
    proxy: {
      '/api': {
        target: 'http://localhost:5609',
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
EOL

echo ""
echo "✅ Frontend hazır!"
echo "🌐 http://localhost:5601 adresinde çalışacak"
echo "🔄 API istekleri http://localhost:5609'a yönlendirilecek"
echo ""
echo "Durdurmak için Ctrl+C"
echo "=========================="
echo ""

# Vite dev server'ı başlat
npx vite --config vite.config.dev.js
