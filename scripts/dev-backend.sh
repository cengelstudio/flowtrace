#!/bin/bash

echo "🚀 FlowTrace Backend Başlatılıyor..."
echo "Port: 5609"
echo "Ortam: Development"
echo ""

# rbenv'i initialize et
if command -v rbenv >/dev/null 2>&1; then
    eval "$(rbenv init -)"
    echo "✅ rbenv initialized - Ruby $(ruby --version)"
else
    echo "⚠️ rbenv bulunamadı, sistem Ruby kullanılacak"
fi

# Gerekli dizinlerin varlığını kontrol et
if [ ! -d "tmp" ]; then
    mkdir -p tmp/pids
fi

if [ ! -d "log" ]; then
    mkdir -p log
fi

# Ruby version ve PATH kontrolü
echo "🔍 Ruby version: $(ruby --version)"
echo "🔍 Gem version: $(gem --version)"
echo "🔍 Which ruby: $(which ruby)"

# Bundler kurulumu kontrolü
if ! command -v bundle >/dev/null 2>&1; then
    echo "📦 Bundler kuruluyor..."
    gem install bundler
fi

# Gemfile.lock kontrolü
echo "📦 Bundle install çalıştırılıyor..."
bundle install

# Rails kurulumu kontrolü
if ! bundle exec rails --version >/dev/null 2>&1; then
    echo "❌ Rails düzgün kurulmamış!"
    exit 1
fi

echo "✅ Rails version: $(bundle exec rails --version)"

# Veritabanı kontrolü ve hazırlama
echo "🗄️ Veritabanı hazırlanıyor..."

# Veritabanı oluştur (eğer yoksa)
echo "Creating database if it doesn't exist..."
bundle exec rails db:create 2>/dev/null || echo "Database might already exist"

# Migration'ları çalıştır
echo "Running migrations..."
bundle exec rails db:migrate

# Seed verilerini yükle
echo "🌱 Loading seed data..."
bundle exec rails db:seed

echo ""
echo "✅ Backend hazır!"
echo "🌐 http://localhost:5609 adresinde çalışacak"
echo ""
echo "Durdurmak için Ctrl+C"
echo "=========================="
echo ""

# Rails server'ı başlat
export PORT=5609
export RAILS_ENV=development
bundle exec rails server -p 5609 -b 0.0.0.0
