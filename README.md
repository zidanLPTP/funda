<div align="center">
  <img src="app-icon.svg" alt="Ikon Aplikasi Funda" width="120" height="120" />
  <h1>Funda</h1>
  <p><strong>Kuasai fondasi uangmu, dari dasar sampai mahir.</strong></p>
  <p>
    Aplikasi keuangan pribadi <em>offline-first</em> berbasis Flutter yang menggabungkan pencatatan kas harian,
    kurikulum belajar 18 modul berbasis data riil, dan mode simulasi sandbox — tanpa server, tanpa akun, dan tanpa pelacak.
  </p>

  <p>
    <a href="https://github.com/zidanLPTP/funda/releases/tag/v1.2.0">
      <img src="https://img.shields.io/badge/Rilis-v1.2.0-0F766E?style=for-the-badge" alt="Rilis v1.2.0" />
    </a>
    <img src="https://img.shields.io/badge/Flutter-%3E%3D3.38.0-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter >= 3.38.0" />
    <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Platform Android dan iOS" />
    <img src="https://img.shields.io/badge/Privasi-100%25%20Offline--First-111827?style=for-the-badge" alt="100% Offline-First" />
  </p>

  <p>
    <a href="#unduh--pasang-apk">Unduh APK</a> •
    <a href="#pembaruan-v120">Pembaruan v1.2.0</a> •
    <a href="#fitur-utama">Fitur Utama</a> •
    <a href="#kurikulum-18-modul">Kurikulum</a> •
    <a href="#memulai-pengembangan">Pengembangan</a> •
    <a href="#dokumentasi-terkait">Dokumentasi</a>
  </p>
</div>

---

## Unduh & Pasang APK

Berkas APK resmi tersedia di halaman [**GitHub Releases Funda v1.2.0**](https://github.com/zidanLPTP/funda/releases/tag/v1.2.0). Pilih varian sesuai arsitektur perangkat Android Anda:

| Varian APK | Arsitektur | Rekomendasi Penggunaan | Tautan Unduh Langsung |
| :--- | :--- | :--- | :--- |
| `app-arm64-v8a-release.apk` | 64-bit ARM | **Direkomendasikan** untuk mayoritas ponsel Android modern | [Unduh arm64-v8a](https://github.com/zidanLPTP/funda/releases/download/v1.2.0/app-arm64-v8a-release.apk) |
| `app-armeabi-v7a-release.apk` | 32-bit ARM | Perangkat Android generasi lama | [Unduh armeabi-v7a](https://github.com/zidanLPTP/funda/releases/download/v1.2.0/app-armeabi-v7a-release.apk) |
| `app-x86_64-release.apk` | 64-bit x86 | Emulator Android atau perangkat berbasis x86_64 | [Unduh x86_64](https://github.com/zidanLPTP/funda/releases/download/v1.2.0/app-x86_64-release.apk) |

> [!TIP]
> Tidak yakin arsitektur HP Anda? Mulai dengan **`app-arm64-v8a-release.apk`** — cocok untuk hampir semua ponsel Android keluaran 2017 ke atas.

### Cara Pemasangan di Android
1. Unduh berkas APK dari tabel di atas atau buka [**Halaman Rilis v1.2.0**](https://github.com/zidanLPTP/funda/releases/tag/v1.2.0).
2. Buka berkas `.apk` yang telah selesai diunduh melalui pengelola berkas.
3. Izinkan pemasangan aplikasi dari sumber tersebut bila diminta oleh sistem Android.
4. Ketuk **Pasang (Install)** lalu buka **Funda**.

---

## Pembaruan v1.2.0

- **Ikon Aplikasi Baru:** Maskot resmi Funda ([app-icon.svg](app-icon.svg)) diterapkan menyeluruh pada ikon launcher Android, Adaptive Icon, iOS `AppIcon`, dan aset in-app.
- **122 Ikon SVG Custom:** Seluruh ikon navigasi, menu, kategori, dompet, sifat transaksi, dan kontrol UI kini menggunakan aset vektor custom yang seragam.
- **62 Ilustrasi Tematik Pelajaran:** Pemetaan ilustrasi dinamis berdasarkan tahap dan konteks di seluruh **18 modul** dengan transisi kanvas halus.
- **Polesan Antarmuka & Perbaikan Bug:** Penyederhanaan layar *Onboarding*, *Lainnya*, *Pengaturan*, dan *Cadangan*, perbaikan alokasi dana kantong/tujuan, serta perbaikan rute **Bayar Cicilan** dari jadwal tagihan.

---

## Tiga Pilar Funda

1. **Dompet Pencatatan Lokal** — Catat arus kas, kelola multi-dompet, alokasi kantong, tagihan berulang, utang/cicilan, dan kekayaan bersih *(Funda tidak terhubung ke rekening bank dan tidak memindahkan uang asli)*.
2. **Belajar Sambil Praktik** — 18 modul micro-learning berjenjang yang terhubung langsung dengan data keuanganmu melalui mekanisme *Gerbang Data*.
3. **Mode Sandbox (Simulasi)** — Ruang latihan mandiri dengan saldo fiktif yang terisolasi dari catatan riil untuk menguji keputusan alokasi dana dan investasi tanpa risiko.

---

## Fitur Utama

### Pengelolaan Keuangan Mandiri
- **Multi-Dompet & Kantong:** Pisahkan rekening bank, e-wallet, dan uang tunai, serta alokasikan dana darurat atau pos khusus lewat Kantong Dompet.
- **Pencatatan Transaksi Cepat:** Catat pengeluaran, pemasukan, dan transfer antar dompet dengan pemilih dompet cepat dan tombol simpan *sticky*.
- **Anggaran Bulanan:** Tetapkan batas pengeluaran per kategori setiap bulan, lengkap dengan fitur salin anggaran bulan lalu.
- **Tujuan Keuangan & Dana Darurat:** Pantau progres target tabungan beserta estimasi waktu tercapai.
- **Utang, Cicilan, & Tagihan Berulang:** Lacak sisa pokok pinjaman, rasio cicilan terhadap arus kas, riwayat pembayaran, serta pengingat jatuh tempo lokal ramah baterai.
- **Laporan Bulanan & Kekayaan Bersih:** Ringkasan komposisi pengeluaran, tren arus kas, sakelar sembunyikan nominal, dan ekspor laporan PDF/PNG.

### Privasi, Keamanan, & Aksesibilitas
- **100% Offline-First:** Seluruh data disimpan secara lokal di perangkat menggunakan SQLite (Drift).
- **Cadangan Terverifikasi:** Ekspor dan pulihkan data dalam format JSON dengan validasi checksum SHA-256 serta pengaman pemulihan terakhir.
- **Aksesibilitas Teruji:** Target sentuh minimal `48x48dp` pada navigasi sub-layar dan dukungan skala teks sistem hingga `2.0x` pada layar `360x640`.

---

## Kurikulum 18 Modul

<details>
<summary>Lihat rincian lengkap kurikulum (Pemula, Menengah, Lanjutan)</summary>

| Tingkat | Modul | Topik Utama |
| :--- | :---: | :--- |
| **Pemula** | 1 – 6 | Anggaran & Arus Kas, Tabungan, Dana Darurat, Utang & Cicilan, Waspada Penipuan, Psikologi Uang |
| **Menengah** | 7 – 12 | Paylater & Skor Kredit, Penghasilan Tambahan, Pajak Dasar, Proteksi Dasar, Investasi Dasar, Tujuan Besar |
| **Lanjutan** | 13 – 18 | Investasi Lanjutan, KPR & Kredit Besar, Pajak Lanjutan, Pensiun & Kebebasan Finansial, Keuangan Usaha Kecil, Proteksi Keluarga & Warisan |

Setiap modul dilengkapi pemantik reflektif, kartu konsep dengan kamus istilah interaktif, contoh angka Rupiah, misi praktik berbasis data riil, dan kuis kelulusan (standar 70%).

</details>

---

## Memulai Pengembangan

### Kebutuhan Sistem
- **Flutter SDK:** `>= 3.38.0`
- **Dart SDK:** `>= 3.10.0`
- **Android SDK:** Platform API 34+ (Android 14+)
- **Target Perangkat:** Android (API 21+) dan iOS (12.0+)

### Menjalankan Secara Lokal

```bash
# 1. Pasang dependensi
flutter pub get

# 2. Generate kode basis data Drift
dart run build_runner build --delete-conflicting-outputs

# 3. Jalankan aplikasi
flutter run
```

### Build Rilis (Production)

```bash
# APK ringkas per arsitektur
flutter build apk --release --split-per-abi

# Android App Bundle (AAB) untuk Google Play Store
flutter build appbundle --release
```

Hasil build tersedia di:
- `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`
- `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk`
- `build/app/outputs/flutter-apk/app-x86_64-release.apk`
- `build/app/outputs/bundle/release/app-release.aab`

### Pengujian & Kualitas Kode

```bash
dart format lib/ test/
flutter analyze
flutter test
```

> Untuk meregenerasi ikon aplikasi dari `app-icon.svg`, jalankan `python tool/generate_app_icons.py`.

---

## Struktur Proyek

```text
funda/
├─ lib/
│  ├─ main.dart           # Titik masuk aplikasi (ProviderScope)
│  ├─ aplikasi/           # MaterialApp, GoRouter, navigasi, rute
│  ├─ tema/               # Token warna, spasi, sudut, tipografi, ThemeData
│  ├─ komponen/           # Komponen UI bersama, ikon SVG, animasi
│  ├─ fitur/              # Modul fitur (Beranda, Catatan, Belajar, Dompet, dll.)
│  ├─ layanan/            # Notifikasi lokal dan layanan perangkat
│  ├─ data/               # Basis data Drift (SQLite), repositori, migrasi
│  ├─ perhitungan/        # Fungsi murni kalkulasi finansial
│  └─ util/               # Utilitas murni (formatRupiah, haptic, tanggal)
├─ aset/
│  ├─ font/               # Plus Jakarta Sans (Regular, SemiBold, Bold)
│  ├─ gambar/             # Ikon SVG, ilustrasi tematik, dan app_icon_512.png
│  └─ konten/             # Kurikulum edukasi JSON (Modul 1–18, kamus, rekomendasi)
├─ tool/                  # Utilitas pembangun aset (generate_app_icons.py)
├─ docs/                  # Spesifikasi, pedoman desain, dan panduan rilis
├─ test/                  # Unit test, widget test, dan uji aksesibilitas
├─ app-icon.svg           # Sumber vektor utama ikon aplikasi Funda
└─ README.md
```

---

## Dokumentasi Terkait

- [docs/spec.md](docs/spec.md) — Spesifikasi lengkap fitur dan arsitektur aplikasi.
- [docs/styleguide.md](docs/styleguide.md) — Token desain editorial, warna, dan pedoman bahasa.
- [docs/format_konten.md](docs/format_konten.md) — Skema JSON kurikulum edukasi dan kamus istilah.
- [docs/format_cadangan.md](docs/format_cadangan.md) — Spesifikasi format cadangan JSON dan checksum SHA-256.
- [docs/panduan_rilis.md](docs/panduan_rilis.md) — Panduan penandatanganan APK/AAB dan checklist uji perangkat.
- [docs/utang_teknis.md](docs/utang_teknis.md) — Catatan teknis, dependensi native SQLite, dan rencana refaktor.
- [CHANGELOG.md](CHANGELOG.md) — Catatan riwayat perubahan antar versi.

---

## Lisensi Font

Font **Plus Jakarta Sans** dirancang oleh Tokotype (Gumpita Rahayu) dan dilisensikan di bawah [SIL Open Font License (OFL)](aset/font/OFL.txt).
