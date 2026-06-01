# SIAKAD Keuangan — Flutter App

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Web%20%7C%20Android%20%7C%20iOS-lightgrey?style=for-the-badge)
![DevicePreview](https://img.shields.io/badge/Device_Preview-Enabled-orange?style=for-the-badge)

**Aplikasi Mobile/Web Sistem Informasi Akademik Keuangan**  
Portal Admin · Portal Mahasiswa · Tagihan UKT · Riwayat Pembayaran

</div>

---

## Daftar Isi

- [Tentang Aplikasi](#tentang-aplikasi)
- [Fitur](#fitur)
- [Struktur Project](#struktur-project)
- [Prasyarat](#prasyarat)
- [Instalasi & Menjalankan](#instalasi--menjalankan)
- [Konfigurasi Base URL](#konfigurasi-base-url)
- [Role & Navigasi](#role--navigasi)
- [Dependensi](#dependensi)
- [Troubleshooting](#troubleshooting)

---

## Tentang Aplikasi

SIAKAD Keuangan Flutter App adalah antarmuka pengguna untuk sistem informasi keuangan akademik. Aplikasi terhubung ke [SIAKAD Keuangan API](../SiakadKeuangan.API/README.md) dan menyediakan dua portal terpisah berdasarkan peran pengguna.

---

## Fitur

### 👨‍💼 Portal Admin
| Fitur | Keterangan |
|-------|------------|
| **Dashboard** | Statistik total mahasiswa, tagihan lunas/belum bayar, total penerimaan, progress bar persentase |
| **Kelola Tagihan** | Lihat semua tagihan UKT beserta status, buat tagihan baru via bottom sheet |
| **Riwayat Pembayaran** | Histori semua transaksi pembayaran dari seluruh mahasiswa |
| **Sinkronisasi** | Preview & sinkron data mahasiswa dari API eksternal ke database |

### 👨‍🎓 Portal Mahasiswa
| Fitur | Keterangan |
|-------|------------|
| **Cari Nama** | Cari data diri menggunakan nama lengkap |
| **Tagihan Saya** | Lihat semua tagihan UKT milik sendiri beserta status dan jatuh tempo |
| **Bayar UKT** | Bayar tagihan dengan pilihan metode: Transfer Bank, Virtual Account, QRIS, Tunai |
| **Riwayat Bayar** | Histori pembayaran milik sendiri |

---

## Struktur Project

```
lib/
├── main.dart                          # Entry point, RoleSelectionScreen,
│                                      #   AdminApp, MahasiswaApp
├── models/
│   └── models.dart                    # Mahasiswa, TagihanUkt,
│                                      #   RiwayatPembayaran, DashboardSummary
├── services/
│   └── api_service.dart               # HTTP client ke backend API
└── screens/
    ├── admin/
    │   ├── admin_dashboard_screen.dart  # Dashboard statistik
    │   ├── admin_tagihan_screen.dart    # Kelola tagihan + riwayat pembayaran
    │   └── admin_sinkronisasi_screen.dart # Sinkronisasi data mahasiswa
    └── mahasiswa/
        └── mahasiswa_screen.dart         # Cari mahasiswa, tagihan, bayar
```

---

## Prasyarat

| Kebutuhan | Versi | Keterangan |
|-----------|-------|------------|
| [Flutter SDK](https://docs.flutter.dev/get-started/install) | 3.x+ | Framework utama |
| [Dart SDK](https://dart.dev/get-dart) | 3.x+ | Sudah termasuk dalam Flutter |
| [Chrome](https://www.google.com/chrome/) | Terbaru | Untuk Flutter Web |
| [Android Studio](https://developer.android.com/studio) | Terbaru | Untuk Android Emulator (opsional) |
| Backend API | — | Pastikan [SIAKAD Keuangan API](../SiakadKeuangan.API/README.md) sudah berjalan |

---

## Instalasi & Menjalankan

### Step 1 — Clone & Install Dependensi

```bash
git clone https://github.com/renaldeva/siakad-keuangan.git
cd siakad-keuangan/flutter_app

flutter pub get
```

### Step 2 — Konfigurasi Base URL

Edit file `lib/services/api_service.dart` sesuai environment:

```dart
// Flutter Web (Chrome) — development
static const String baseUrl = 'http://localhost:5049';

// Android Emulator
// static const String baseUrl = 'http://10.0.2.2:5049';

// Device fisik (ganti dengan IP laptop)
// static const String baseUrl = 'http://192.168.x.x:5049';

// Docker Compose
// static const String baseUrl = 'http://localhost:5000';

// Production (setelah deploy ke cloud)
// static const String baseUrl = 'https://your-api.up.railway.app';
```

> Cek IP laptop: **Windows** → `ipconfig` → IPv4 Address · **Mac/Linux** → `ifconfig` → inet

### Step 3 — Jalankan Aplikasi

**Flutter Web (Chrome):**
```bash
flutter run -d chrome --web-browser-flag "--disable-web-security"
```

> Flag `--disable-web-security` diperlukan saat API masih HTTP (localhost).  
> Tidak diperlukan lagi setelah API di-deploy ke HTTPS.

**Android Emulator:**
```bash
# Pastikan emulator sudah berjalan di Android Studio
flutter run -d emulator-5554
```

**Device Fisik:**
```bash
# Hubungkan device via USB, aktifkan USB Debugging
flutter devices          # Lihat daftar device
flutter run -d <device-id>
```

**List semua device tersedia:**
```bash
flutter devices
```

### Build Production

```bash
# Web
flutter build web
# Output: build/web/

# APK Android
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

# App Bundle (Google Play)
flutter build appbundle --release
```

---

## Konfigurasi Base URL

Tabel referensi cepat:

| Environment | Base URL |
|-------------|----------|
| Flutter Web (Chrome) | `http://localhost:5049` |
| Flutter Web + Docker | `http://localhost:5000` |
| Android Emulator | `http://10.0.2.2:5049` |
| Android Emulator + Docker | `http://10.0.2.2:5000` |
| Device Fisik | `http://192.168.x.x:5049` |
| Production (Railway) | `https://nama-app.up.railway.app` |
| Production (Render) | `https://nama-app.onrender.com` |

---

## Role & Navigasi

```
┌─────────────────────────┐
│    Halaman Pilih Portal  │  ← Tampil pertama kali saat buka app
└────────┬────────┬────────┘
         │        │
         ▼        ▼
   ┌──────────┐  ┌──────────────┐
   │  Admin   │  │  Mahasiswa   │
   └────┬─────┘  └──────┬───────┘
        │                │
        ▼                ▼
   NavigationBar      Search Bar
   ┌──────────┐       ┌──────────┐
   │Dashboard │       │Cari Nama │
   │Tagihan   │       │    ▼     │
   │Sinkron   │       │ Pilih    │
   │Keluar    │       │    ▼     │
   └──────────┘       │Tagihan & │
                      │Riwayat   │
                      └──────────┘
```

### Cara Berpindah Portal
- Klik tombol **Keluar** (Admin: tab ke-4 di NavigationBar · Mahasiswa: tombol di AppBar kanan atas)
- Dialog konfirmasi akan muncul → klik **Ya, Keluar**
- Kembali ke halaman pemilihan portal

---

## Dependensi

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0                  # HTTP client untuk REST API
  provider: ^6.1.1              # State management
  shared_preferences: ^2.2.2   # Penyimpanan lokal
  intl: ^0.20.2                 # Format tanggal & mata uang Rupiah
  fl_chart: ^0.66.2             # Chart & grafik
  shimmer: ^3.0.0               # Loading skeleton
  cached_network_image: ^3.3.1  # Cache gambar dari network
  cupertino_icons: ^1.0.6       # Icon iOS style
  device_preview: ^1.1.0        # Preview berbagai ukuran device
```

---

## Troubleshooting

### ❌ TimeoutException / Connection Refused
API belum berjalan atau base URL salah.
```bash
# Pastikan API berjalan
curl http://localhost:5049/
# atau
curl http://localhost:5000/

# Cek base URL di lib/services/api_service.dart
```

### ❌ CORS Error di Chrome
Jalankan Flutter dengan flag disable web security:
```bash
flutter run -d chrome --web-browser-flag "--disable-web-security"
```

### ❌ LocaleDataException (intl)
Pastikan `main.dart` sudah memanggil inisialisasi locale:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(...);
}
```

### ❌ Device Preview tidak muncul
Pastikan `device_preview: ^1.1.0` ada di `pubspec.yaml` dan sudah jalankan:
```bash
flutter pub get
```

### ❌ Android tidak bisa connect ke API
Gunakan `10.0.2.2` bukan `localhost` untuk Android Emulator.  
Untuk device fisik, gunakan IP address laptop (bukan `localhost`).

### ❌ Sinkronisasi berhasil tapi data mahasiswa kosong
API Mahasiswa menggunakan MongoDB `_id` bukan `nim`. Pastikan file `DTOs.cs` di backend sudah menggunakan:
```csharp
[JsonProperty("_id")]
public string? MongoId { get; set; }
```

---

## Alur Penggunaan

### Admin
1. Buka app → pilih **Admin / Bagian Keuangan**
2. Tab **Sinkronisasi** → klik **Preview** untuk melihat data → klik **Mulai Sinkronisasi**
3. Tab **Tagihan** → klik **+ Buat Tagihan** → isi form → **Simpan**
4. Tab **Dashboard** → lihat statistik pembayaran

### Mahasiswa
1. Buka app → pilih **Mahasiswa**
2. Ketik nama di search bar → klik **Cari**
3. Pilih nama dari daftar hasil pencarian
4. Tab **Tagihan** → pilih tagihan → klik **Bayar**
5. Pilih metode pembayaran → klik **Konfirmasi Pembayaran**
6. Tab **Riwayat** → lihat histori pembayaran

---

<div align="center">
  <sub>Tugas Mandiri PAA · 2026</sub>
</div>
