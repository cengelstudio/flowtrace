# FlowTrace - Envanter Yönetim Sistemi

FlowTrace, organizasyonların envanterlerini QR kod etiketleriyle takip etmesini sağlayan modern bir web tabanlı uygulamadır.

## 🚀 Özellikler

### 📦 Depo Yönetimi
- Yeni depo oluşturma (ad, konum, kapasite)
- Her depo için benzersiz QR kod üretimi
- PDF olarak QR kod etiketi indirme
- Depo doluluk oranı takibi

### 🏷️ Eşya Yönetimi
- Eşya kaydı (ad, seri no, kategori, marka, model)
- Otomatik QR kod üretimi
- Durum takibi (stokta, kullanımda, bakımda)
- Değer ve garanti bilgisi yönetimi

### 🔍 Arama ve Filtreleme
- Gelişmiş arama (eşya adı, seri no, kategori)
- Bulanık arama (fuzzy search) desteği
- Kategori ve marka bazlı filtreleme
- Depo konumu ile arama

### 📱 QR Kod Tarama
- Web arayüzünde kamera ile QR tarama
- Mobil uyumlu tarama deneyimi
- Tarama sonrası hızlı işlem seçenekleri

### 📊 Hareket Takibi
- Eşya çıkış/giriş işlemleri
- Kimin aldığı, nereye gittiği bilgisi
- Dönüş tarihi takibi
- Geciken eşyalar için otomatik uyarı

### 📈 Raporlama ve Analitik
- Dashboard ile genel görünüm
- Depo doluluk grafikleri
- Eşya hareket geçmişi
- Geciken eşyalar raporu
- PDF/Excel export özelliği

### 👥 Kullanıcı Yönetimi
- Rol bazlı yetki sistemi (Admin/Personel)
- Güvenli kimlik doğrulama
- Kullanıcı aktivite takibi

## 🛠️ Teknoloji Stack

### Backend
- **Ruby on Rails 7.x** - Web framework
- **PostgreSQL 15** - Veritabanı
- **Redis** - Cache ve session store
- **Sidekiq** - Background jobs

### Frontend
- **Vue.js 3.x** - Modern JavaScript framework
- **Vue Router** - SPA routing
- **Pinia** - State management
- **Chart.js** - Veri görselleştirme
- **html5-qrcode** - QR kod tarama
- **Tailwind CSS** - Utility-first CSS

### DevOps & Infrastructure
- **Docker & Docker Compose** - Containerization
- **Nginx** - Reverse proxy
- **SSL/TLS** - Güvenli bağlantı

## 🏗️ Kurulum

### Gereksinimler
- Docker ve Docker Compose
- Git

### Hızlı Başlangıç

1. **Projeyi klonlayın:**
```bash
git clone <repository-url>
cd flowtrace
```

2. **Environment dosyasını oluşturun:**
```bash
cp .env.sample .env
# .env dosyasını ihtiyaçlarınıza göre düzenleyin
```

3. **Docker ile çalıştırın:**
```bash
docker-compose up --build
```

4. **Veritabanını hazırlayın:**
```bash
docker-compose exec web rails db:create
docker-compose exec web rails db:migrate
docker-compose exec web rails db:seed
```

5. **Uygulamaya erişin:**
- Web: https://localhost (SSL ile)
- HTTP: http://localhost:3000
- API: http://localhost:3000/api/v1

### Manuel Kurulum (Docker olmadan)

1. **Ruby, Node.js ve PostgreSQL yükleyin**

2. **Bağımlılıkları yükleyin:**
```bash
bundle install
npm install
```

3. **Veritabanını kurun:**
```bash
rails db:create db:migrate db:seed
```

4. **Assets'leri derleyin:**
```bash
npm run build
```

5. **Sunucuyu başlatın:**
```bash
rails server
```

## 👤 Varsayılan Kullanıcılar

Seed data ile birlikte aşağıdaki kullanıcılar oluşturulur:

| Email | Şifre | Rol |
|-------|-------|-----|
| admin@flowtrace.com | password123 | Admin |
| personel1@flowtrace.com | password123 | Personel |
| personel2@flowtrace.com | password123 | Personel |

## 📡 API Dokümantasyonu

### Authentication
```bash
POST /api/v1/auth/login
POST /api/v1/auth/logout
GET  /api/v1/auth/me
```

### Warehouses
```bash
GET    /api/v1/warehouses
POST   /api/v1/warehouses
GET    /api/v1/warehouses/:id
PUT    /api/v1/warehouses/:id
DELETE /api/v1/warehouses/:id
GET    /api/v1/warehouses/:id/qr_code_pdf
```

### Items
```bash
GET    /api/v1/items
POST   /api/v1/items
GET    /api/v1/items/:id
PUT    /api/v1/items/:id
DELETE /api/v1/items/:id
PATCH  /api/v1/items/:id/check_out
PATCH  /api/v1/items/:id/check_in
GET    /api/v1/items/:id/qr_code_pdf
```

### Search & Scan
```bash
GET  /api/v1/search?q=query
POST /api/v1/scan
GET  /api/v1/scan/:qr_code
```

### Reports
```bash
GET /api/v1/reports/dashboard
GET /api/v1/reports/warehouse_occupancy
GET /api/v1/reports/overdue_items
```

## 🏗️ Geliştirme

### Kod Kalitesi
```bash
# Ruby linting
bundle exec rubocop

# JavaScript linting
npm run lint

# Tests
bundle exec rspec  # Backend tests
npm test          # Frontend tests
```

### Database İşlemleri
```bash
# Yeni migration oluştur
rails generate migration CreateNewTable

# Migration çalıştır
rails db:migrate

# Rollback
rails db:rollback

# Seed data
rails db:seed
```

### QR Kod Sistemi

QR kodlar otomatik olarak oluşturulur:
- **Depolar:** `WH-XXXXXXXX` formatında
- **Eşyalar:** `IT-XXXXXXXX` formatında
- PNG ve PDF formatında export
- 300x300 piksel, 1 modül border

## 🔧 Konfigürasyon

### Environment Variables

```bash
# Database
DATABASE_HOST=localhost
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=password
DATABASE_PORT=5432

# Redis
REDIS_URL=redis://localhost:6379/0

# Application
APP_HOST=localhost:3000
APP_URL=http://localhost:3000
RAILS_ENV=development

# Security
SECRET_KEY_BASE=your_secret_key
FORCE_SSL=false

# Features
ENABLE_QR_SCANNING=true
ENABLE_REPORTS=true
```

## 📈 Performans

### Caching Strategy
- Redis cache store
- Fragment caching for reports
- Static asset caching via Nginx

### Database Optimization
- Proper indexing on search fields
- Connection pooling
- Query optimization with includes

### Frontend Optimization
- Code splitting with dynamic imports
- Asset compression
- Progressive Web App (PWA) ready

## 🔒 Güvenlik

### Authentication & Authorization
- Devise for authentication
- Pundit for authorization
- Role-based access control
- Session management

### Data Protection
- SQL injection protection
- XSS prevention
- CSRF protection
- Encrypted sensitive data

### SSL/TLS
- Force SSL in production
- Strong cipher suites
- HSTS headers

## 🚀 Deployment

### Production Checklist
- [ ] Environment variables configured
- [ ] SSL certificates installed
- [ ] Database backed up
- [ ] Assets precompiled
- [ ] Background workers running
- [ ] Monitoring configured

### Docker Production
```bash
docker-compose -f docker-compose.prod.yml up -d
```

## 🐛 Troubleshooting

### Common Issues

**QR kodlar görünmüyor:**
- `public/qr_codes` dizini yazılabilir mi kontrol edin
- ImageMagick yüklü mü kontrol edin

**Database bağlantı hatası:**
- PostgreSQL servisinin çalıştığını kontrol edin
- Database credentials'ları doğrulayın

**Assets yüklenmiyor:**
- `npm run build` komutunu çalıştırın
- Nginx konfigürasyonunu kontrol edin

## 📞 Destek

Herhangi bir sorun yaşarsanız:
1. Bu README'yi kontrol edin
2. Log dosyalarına bakın (`rails logs`)
3. GitHub Issues bölümünden issue açın

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır.

## 🙏 Katkıda Bulunma

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Commit yapın (`git commit -m 'Add amazing feature'`)
4. Push yapın (`git push origin feature/amazing-feature`)
5. Pull Request açın

---

**FlowTrace** - Modern envanter yönetimi artık parmaklarınızın ucunda! 🚀
