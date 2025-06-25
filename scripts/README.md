# FlowTrace Development Scripts

Bu klasör, FlowTrace projesinin geliştirme ortamında çalıştırılması için gerekli shell scriptlerini içerir.

## Scriptler

### 🚀 Ana Script - `dev-start.sh`
**Kullanım:** `./scripts/dev-start.sh`

Interaktif menü ile istediğiniz servisi başlatabilirsiniz:
- Backend'i ayrı başlat (Port: 5609)
- Frontend'i ayrı başlat (Port: 5601)
- Her ikisini birlikte başlat
- Çıkış

### 🔧 Backend Script - `dev-backend.sh`
**Kullanım:** `./scripts/dev-backend.sh`

Rails backend'ini port 5609'da başlatır:
- Bundle install kontrolü
- Veritabanı migration'ları
- Seed verilerini yükleme
- Rails server başlatma

### 🎨 Frontend Script - `dev-frontend.sh`
**Kullanım:** `./scripts/dev-frontend.sh`

Vue.js frontend'ini port 5601'de başlatır:
- NPM install kontrolü
- Vite konfigürasyonu (geçici dosya oluşturur)
- API proxy ayarları (localhost:5609'a yönlendirir)
- Hot Module Replacement (HMR) aktif

### 🛑 Stop Script - `stop-dev.sh`
**Kullanım:** `./scripts/stop-dev.sh`

Tüm development servislerini durdurur:
- Port 5609 (Backend)
- Port 5601 (Frontend)
- Port 5602 (HMR)
- Geçici dosyaları temizler

## Port Yapılandırması

| Servis | Port | URL |
|--------|------|-----|
| Backend (Rails) | 5609 | http://localhost:5609 |
| Frontend (Vue) | 5601 | http://localhost:5601 |
| HMR | 5602 | (İç kullanım) |

## Hızlı Başlangıç

```bash
# Tüm servisleri başlat
./scripts/dev-start.sh

# Veya seçenek 3'ü seç (Her ikisini birlikte başlat)
```

## Bağımsız Başlatma

```bash
# Sadece backend
./scripts/dev-backend.sh

# Sadece frontend
./scripts/dev-frontend.sh
```

## Durdurma

```bash
# Tüm servisleri durdur
./scripts/stop-dev.sh

# Veya Ctrl+C ile manuel durdurma
```

## Dikkat Edilmesi Gerekenler

1. **İlk çalıştırma:** Backend script otomatik olarak:
   - Bundle install yapar
   - Veritabanını oluşturur/migrate eder
   - Seed verilerini yükler

2. **Frontend proxy:** Frontend, API isteklerini otomatik olarak backend'e yönlendirir

3. **Hot reload:** Her iki serviste de kod değişikliklerinde otomatik yenileme aktif

4. **Geçici dosyalar:** Frontend script geçici bir `vite.config.dev.js` dosyası oluşturur, stop script ile temizlenir

## Sorun Giderme

**Port zaten kullanımda hatası:**
```bash
./scripts/stop-dev.sh
```

**Backend başlamıyor:**
- Ruby ve bundler kurulu olduğundan emin olun
- `bundle install` çalıştırın

**Frontend başlamıyor:**
- Node.js kurulu olduğundan emin olun
- `npm install` çalıştırın

**Veritabanı hatası:**
```bash
bundle exec rails db:drop db:create db:migrate db:seed
```
