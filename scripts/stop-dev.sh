#!/bin/bash

echo "🛑 FlowTrace Development Servisleri Durduruluyor..."
echo ""

# Port'larda çalışan process'leri bul ve durdur
stop_process_on_port() {
    local port=$1
    local service_name=$2

    echo "🔍 Port $port kontrolü ($service_name)..."

    # PID'yi bul
    PID=$(lsof -ti :$port)

    if [ ! -z "$PID" ]; then
        echo "⚠️ Port $port'da çalışan process bulundu (PID: $PID)"
        echo "🛑 $service_name durduruluyor..."
        kill -9 $PID

        # Kontrol et
        sleep 1
        if lsof -ti :$port > /dev/null; then
            echo "❌ Port $port'daki process durdurulamadı"
        else
            echo "✅ $service_name başarıyla durduruldu"
        fi
    else
        echo "ℹ️ Port $port'da çalışan process bulunamadı"
    fi

    echo ""
}

# Rails server'ı durdur (port 5609)
stop_process_on_port 5609 "Backend (Rails)"

# Vite dev server'ı durdur (port 5601)
stop_process_on_port 5601 "Frontend (Vite)"

# HMR port'unu da durdur (port 5602)
stop_process_on_port 5602 "Frontend HMR"

# Geçici dosyaları temizle
echo "🧹 Geçici dosyalar temizleniyor..."

if [ -f "vite.config.dev.js" ]; then
    rm vite.config.dev.js
    echo "✅ Geçici vite config dosyası silindi"
fi

if [ -f "tmp/pids/server.pid" ]; then
    rm tmp/pids/server.pid
    echo "✅ Rails PID dosyası temizlendi"
fi

echo ""
echo "✅ Tüm development servisleri durduruldu!"
echo "🔄 Yeniden başlatmak için ./scripts/dev-start.sh çalıştırın"
