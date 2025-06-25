#!/bin/bash

echo "🚀 FlowTrace Development Environment"
echo "===================================="
echo ""

# Script dizinini kontrol et
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

# Menü göster
show_menu() {
    echo "Seçenekler:"
    echo "1) 🔧 Backend'i başlat (Port: 5609)"
    echo "2) 🎨 Frontend'i başlat (Port: 5601)"
    echo "3) 🚀 Her ikisini birlikte başlat"
    echo "4) 🛑 Çıkış"
    echo ""
}

# Hem backend hem frontend'i başlat (parallel)
start_both() {
    echo "🚀 Backend ve Frontend birlikte başlatılıyor..."
    echo ""

    # Terminal'de concurrently kullan
    if command -v concurrently &> /dev/null; then
        npx concurrently \
            -n "backend,frontend" \
            -c "blue,green" \
            "bash $SCRIPT_DIR/dev-backend.sh" \
            "bash $SCRIPT_DIR/dev-frontend.sh"
    else
        echo "⚠️ Concurrently bulunamadı, sırayla başlatılıyor..."
        echo "Önce backend başlatılıyor..."
        bash "$SCRIPT_DIR/dev-backend.sh" &
        BACKEND_PID=$!

        sleep 5

        echo "Şimdi frontend başlatılıyor..."
        bash "$SCRIPT_DIR/dev-frontend.sh" &
        FRONTEND_PID=$!

        # Cleanup function
        cleanup() {
            echo ""
            echo "🛑 Servisler durduruluyor..."
            kill $BACKEND_PID $FRONTEND_PID 2>/dev/null
            exit 0
        }

        trap cleanup SIGINT SIGTERM

        wait
    fi
}

# Ana döngü
while true; do
    show_menu
    read -p "Seçiminizi yapın (1-4): " choice
    echo ""

    case $choice in
        1)
            echo "🔧 Backend başlatılıyor..."
            bash "$SCRIPT_DIR/dev-backend.sh"
            ;;
        2)
            echo "🎨 Frontend başlatılıyor..."
            bash "$SCRIPT_DIR/dev-frontend.sh"
            ;;
        3)
            start_both
            ;;
        4)
            echo "👋 Görüşürüz!"
            exit 0
            ;;
        *)
            echo "❌ Geçersiz seçenek. Lütfen 1-4 arası bir sayı girin."
            ;;
    esac

    echo ""
    echo "Devam etmek için Enter'a basın..."
    read
    clear
done
