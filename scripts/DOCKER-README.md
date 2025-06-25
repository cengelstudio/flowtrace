# FlowTrace Docker Development Environment

Bu klasör, FlowTrace projesinin Docker ile geliştirme ortamında çalıştırılması için gerekli scriptleri ve yapılandırmaları içerir.

## Gereksinimler

- Docker
- Docker Compose

## Docker Scriptleri

### 🐳 Ana Script - `docker-dev.sh`
**Kullanım:** `./scripts/docker-dev.sh`

Tüm servisleri Docker ile başlatır:
- Backend (Rails) - Port: 5609
- Frontend (Vue.js) - Port: 5601
- Database (PostgreSQL) - Port: 5432
- Redis - Port: 6379

### 🔧 Backend Only - `docker-backend.sh`
**Kullanım:** `./scripts/docker-backend.sh`

Sadece backend servislerini başlatır:
- Database + Redis + Backend

### 🎨 Frontend Only - `docker-frontend.sh`
**Kullanım:** `./scripts/docker-frontend.sh`

Sadece frontend'i başlatır:
- API istekleri localhost:5609'a yönlendirilir

### 🛑 Stop Services - `docker-stop.sh`
**Kullanım:** `./scripts/docker-stop.sh`

Tüm Docker servislerini durdurur

## Port Yapılandırması

| Servis | Port | URL |
|--------|------|-----|
| Backend (Rails) | 5609 | http://localhost:5609 |
| Frontend (Vue) | 5601 | http://localhost:5601 |
| Database (PostgreSQL) | 5432 | localhost:5432 |
| Redis | 6379 | localhost:6379 |
| HMR | 5602 | (İç kullanım) |

## Hızlı Başlangıç

```bash
# Tüm servisleri başlat
./scripts/docker-dev.sh
```

## Ayrı Servis Başlatma

```bash
# Sadece backend
./scripts/docker-backend.sh

# Sadece frontend
./scripts/docker-frontend.sh
```

## Durdurma

```bash
# Tüm servisleri durdur
./scripts/docker-stop.sh
```

## Docker Compose Dosyaları

- **docker-compose.dev.yml**: Development environment için optimize edilmiş
- **docker-compose.yml**: Production ortamı için

## Dockerfile'lar

- **docker/ruby/Dockerfile.dev**: Development Rails container
- **docker/nodejs/Dockerfile.dev**: Development Node.js container

## Özellikler

### ✅ Avantajlar
- **Tutarlı Environment**: Herkes aynı Ruby, Node.js, PostgreSQL versiyonlarını kullanır
- **Kolay Setup**: Tek komutla tüm servisler ayakta
- **Volume Mounting**: Kod değişiklikleri anında yansır
- **Hot Reload**: Hem backend hem frontend otomatik yenilenir
- **Database Persistence**: Veriler Docker volume'ında kalıcı

### 🔧 Development Features
- Rails development mode
- Vite hot module replacement
- Database migrations otomatik çalışır
- Seed veriler otomatik yüklenir

## Veri Yönetimi

### Database Reset
```bash
# Tüm verileri sil ve baştan başla
docker-compose -f docker-compose.dev.yml down -v
./scripts/docker-dev.sh
```

### Logs
```bash
# Tüm servislerin loglarını görüntüle
docker-compose -f docker-compose.dev.yml logs -f

# Sadece backend logları
docker-compose -f docker-compose.dev.yml logs -f backend

# Sadece frontend logları
docker-compose -f docker-compose.dev.yml logs -f frontend
```

## Sorun Giderme

**Port zaten kullanımda:**
```bash
./scripts/docker-stop.sh
```

**Container build hatası:**
```bash
docker-compose -f docker-compose.dev.yml build --no-cache
```

**Database connection hatası:**
```bash
docker-compose -f docker-compose.dev.yml restart db
```

**Volume sorunları:**
```bash
docker-compose -f docker-compose.dev.yml down -v
docker volume prune
```

## Rails Komutları

Backend container içinde Rails komutları çalıştırmak için:

```bash
# Container içine gir
docker-compose -f docker-compose.dev.yml exec backend bash

# Rails console
docker-compose -f docker-compose.dev.yml exec backend bundle exec rails console

# Migration
docker-compose -f docker-compose.dev.yml exec backend bundle exec rails db:migrate

# Test
docker-compose -f docker-compose.dev.yml exec backend bundle exec rspec
```

## Node.js Komutları

Frontend container içinde Node.js komutları çalıştırmak için:

```bash
# Container içine gir
docker-compose -f docker-compose.dev.yml exec frontend sh

# NPM install
docker-compose -f docker-compose.dev.yml exec frontend npm install

# Linting
docker-compose -f docker-compose.dev.yml exec frontend npm run lint
```
