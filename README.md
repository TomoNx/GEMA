<p align="center">
  <h1 align="center">🕌 GEMA</h1>
  <p align="center">
    <strong>Aplikasi Audio Tour Guide untuk Haji & Umrah</strong><br>
    Real-time Audio Streaming Web App for Hajj/Umrah Pilgrims
  </p>
  <p align="center">
    <a href="#-fitur">Fitur</a> •
    <a href="#-demo">Demo</a> •
    <a href="#-instalasi">Instalasi</a> •
    <a href="#-penggunaan">Penggunaan</a> •
    <a href="#-tech-stack">Tech Stack</a> •
    <a href="#-kontribusi">Kontribusi</a>
  </p>
</p>

---

## 📖 Tentang GEMA

**GEMA** (Guide Audio Streaming) adalah sistem audio tour guide berbasis web yang dirancang khusus untuk pembimbing Haji dan Umrah. Jamaah dapat bergabung hanya dengan **scan QR code** - tanpa perlu login atau install aplikasi apapun.

### Mengapa GEMA?

- 🎯 **Tanpa Install** - Jamaah cukup scan QR code dan langsung terhubung
- 👴 **Ramah Lansia** - UI dengan tombol besar, font jelas, dan kontras tinggi
- 🔊 **Audio Dua Arah** - Komunikasi walkie-talkie antara guide dan jamaah
- 📿 **Tampilan Doa** - Teks doa real-time untuk diikuti jamaah
- 📱 **Mobile First** - Dioptimalkan untuk smartphone jamaah

---

## ✨ Fitur

### Untuk Guide (Pembimbing)
- ✅ Dashboard manajemen room
- ✅ Broadcast audio ke semua jamaah
- ✅ Mute/unmute semua jamaah sekaligus
- ✅ Tampilkan teks doa real-time
- ✅ QR code untuk share room
- ✅ Monitor jamaah online & active speaker
- ✅ Hapus room (soft delete dengan audit trail)

### Untuk Jamaah
- ✅ Join room via QR code scan
- ✅ Dengarkan audio guide
- ✅ Push-to-talk untuk bicara ke guide
- ✅ Lihat teks doa yang sedang dibacakan
- ✅ Wake lock (layar tetap nyala)
- ✅ Auto-reconnect jika koneksi terputus

### Teknis
- ✅ Real-time audio via WebRTC (LiveKit)
- ✅ Soft delete dengan tracking siapa yang menghapus
- ✅ Participant tracking (join/leave time)
- ✅ Policy-based authorization
- ✅ Responsive design

---

## 🎬 Demo

### Panel Guide
![Panel Guide](Screenshot%202026-01-01%20142235.png)

### Halaman Jamaah
![Halaman Jamaah](Screenshot%202026-01-01%20142301.png)

---

## 🛠 Tech Stack

| Layer | Technology |
|-------|------------|
| Backend | Laravel 12 (PHP 8.2+) |
| Frontend | Blade + TailwindCSS |
| Real-time Audio | LiveKit Cloud (WebRTC) |
| Database | SQLite / MySQL |
| QR Code | SimpleSoftwareIO/QrCode |

---

## 📦 Instalasi

### 🚀 Cara 1: Menggunakan Docker (Rekomendasi - Tinggal Run!)

Cocok untuk tugas kelompok, matkul Cloud Computing, atau demo cepat. **Tidak perlu install PHP, Composer, Node.js, atau MySQL manual di komputer host.**

#### Prasyarat:
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) sudah terinstall dan berjalan.

#### Langkah Cepat (Windows):
Cukup double-click file **`run.bat`** di root folder project, atau lewat terminal:
```cmd
run.bat
```

#### Langkah Cepat (macOS / Linux):
```bash
chmod +x run.sh
./run.sh
```

#### Atau Menggunakan Docker Compose Langsung:
```bash
# 1. Start containers
docker compose up -d --build

# 2. Akses aplikasi di browser
# http://localhost:8000
```

> 💡 **Otomatisasi Docker:**
> Container akan otomatis:
> - Meng-copy file `.env` dari `.env.example` jika belum ada
> - Generate `APP_KEY` jika masih kosong
> - Menunggu database MySQL siap (healthcheck)
> - Menjalankan migration (`migrate --force`)
> - Menjalankan database seeder (`db:seed --force`) untuk membuat user guide dan doa-doa
> - Mengatur permission storage & cache

---

### ⚙️ Cara 2: Instalasi Manual (Lokal)

#### Prasyarat
- PHP 8.2+ (ekstensi: `gd`, `pdo_mysql`, `bcmath`, `curl`, `mbstring`, `zip`, `intl`, `pcntl`)
- Composer
- Node.js 18+ & npm
- MySQL Server

#### Langkah:
```bash
# 1. Clone repository
git clone https://github.com/TomoNx/GEMA.git
cd GEMA

# 2. Install dependencies
composer install
npm install

# 3. Setup environment
cp .env.example .env
php artisan key:generate

# 4. Sesuaikan konfigurasi database dan LiveKit di .env

# 5. Setup database
php artisan migrate
php artisan db:seed

# 6. Build assets & jalankan
npm run build
php artisan serve
```

---

## ☁️ Arsitektur Cloud Computing

Aplikasi ini menggunakan pola arsitektur **3-Tier Container Architecture** dengan integrasi **External Cloud SaaS**:

```
┌────────────────────────────────────────────────────────┐
│                 Client (Browser / HP)                  │
└──────────────┬───────────────────────────┬─────────────┘
               │ HTTP (:8000)              │ WebRTC Audio
               ▼                           ▼
┌──────────────────────────────┐  ┌──────────────────────┐
│    Tier 1: Web Server        │  │ LiveKit Cloud (SaaS) │
│       (Nginx Alpine)         │  │  (*.livekit.cloud)   │
└──────────────┬───────────────┘  └──────────▲───────────┘
               │ FastCGI (:9000)             │ Generate
               ▼                             │ JWT Token
┌──────────────────────────────┐             │
│ Tier 2: Application Runtime  │─────────────┘
│        (PHP 8.3-FPM)         │
└──────────────┬───────────────┘
               │ MySQL (:3306)
               ▼
┌──────────────────────────────┐
│   Tier 3: Database Storage   │
│    (MySQL 8.0 + Volume)      │
└──────────────────────────────┘
```

### 🎙️ Konfigurasi LiveKit Cloud
GEMA menggunakan [LiveKit Cloud](https://cloud.livekit.io/) untuk WebRTC audio streaming:
1. Daftar gratis di [LiveKit Cloud](https://cloud.livekit.io/)
2. Buat project baru
3. Masukkan credentials ke file `.env`:

```env
LIVEKIT_API_KEY=your_api_key
LIVEKIT_API_SECRET=your_api_secret
LIVEKIT_HOST=https://your-project.livekit.cloud
LIVEKIT_WS_URL=wss://your-project.livekit.cloud
```
---

## 🚀 Penggunaan

### Login Guide

| Email | Password |
|-------|----------|
| `guide@gema.test` | `password` |

### Alur Penggunaan

**Guide:**
1. Login ke dashboard
2. Buat room baru
3. Aktifkan room
4. Share QR code ke jamaah
5. Nyalakan mic untuk broadcast
6. Pilih doa untuk ditampilkan

**Jamaah:**
1. Scan QR code dari guide
2. Masukkan nama/ID
3. Dengarkan audio guide
4. Tahan tombol mic untuk bicara (push-to-talk)

---

## 📁 Struktur Project

```
app/
├── Http/Controllers/
│   ├── GuideController.php    # Dashboard & room management
│   └── RoomController.php     # Entry point jamaah
├── Models/
│   ├── Room.php               # Audio room (soft delete)
│   ├── Prayer.php             # Daftar doa
│   └── Participant.php        # Tracking jamaah
├── Policies/
│   └── RoomPolicy.php         # Authorization
└── Services/
    └── LiveKitService.php     # LiveKit API wrapper

resources/views/
├── guide/
│   ├── dashboard.blade.php    # List & create room
│   └── room.blade.php         # Control panel guide
└── room/
    ├── login.blade.php        # Form join jamaah
    └── live.blade.php         # Live audio room
```

---

## 🤝 Kontribusi

Kontribusi sangat diterima! Silakan:

1. Fork repository ini
2. Buat branch fitur (`git checkout -b fitur/AmazingFeature`)
3. Commit perubahan (`git commit -m 'Menambahkan fitur amazing'`)
4. Push ke branch (`git push origin fitur/AmazingFeature`)
5. Buat Pull Request

### Ideas untuk Kontribusi

- [ ] Multi-language support
- [ ] Recording audio session
- [ ] Offline mode untuk jamaah
- [ ] Push notification
- [ ] Admin panel untuk kelola guide
- [ ] Analytics dashboard

---

## 📄 Lisensi

Distributed under the MIT License. See [LICENSE](LICENSE) for more information.

---

## 🙏 Acknowledgments

- [Laravel](https://laravel.com/) - PHP Framework
- [LiveKit](https://livekit.io/) - Real-time Audio/Video
- [TailwindCSS](https://tailwindcss.com/) - CSS Framework
- [SimpleSoftwareIO/QrCode](https://github.com/SimpleSoftwareIO/simple-qrcode) - QR Code Generator

---

<p align="center">
  Made with ❤️ for Hajj & Umrah pilgrims
</p>
