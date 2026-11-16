# Funda

> Kuasai fondasi uangmu, dari dasar sampai mahir.

**Funda** (dari kata *fundamental* dan *fund*) adalah aplikasi mobile keuangan pribadi (Android + iOS) berbasis **Flutter** dengan konsep "belajar sambil praktik" dan fitur dompet digital pencatatan.

---

## 🎯 Gambaran Tiga Sisi Funda
1. **Dompet Digital Pencatatan:** Pencatatan kas, banyak dompet, alokasi kantong, tagihan berulang, dan transfer antar dompet (aplikasi **tidak** menyimpan atau memindahkan uang asli).
2. **Belajar Sambil Praktik:** Pelajaran micro-learning berjenjang (Pemula, Menengah, Lanjutan) yang berujung pada misi praktik menggunakan **data uang pengguna sendiri** melalui mekanisme **Gerbang Data**.
3. **Sandbox:** Ruang simulasi terpisah untuk topik non-langsung (seperti simulasi investasi atau skenario darurat) tanpa memengaruhi data asli.

---

## 🚀 Cara Menjalankan Aplikasi

### Kebutuhan Sistem
- **Flutter SDK:** >= 3.38.0
- **Dart SDK:** >= 3.10.0
- **Android SDK:** Platform API 34+
- **Editor:** VS Code / Android Studio dengan ekstensi Flutter & Dart

### Langkah Menjalankan
1. Pasang dependensi:
   ```bash
   flutter pub get
   ```
2. Jalankan pembangkit kode Drift (jika ada perubahan skema database):
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
3. Jalankan aplikasi di emulator atau perangkat yang terhubung:
   ```bash
   flutter run
   ```

---

## 🧪 Pengujian & Analisis Kode

Menjalankan uji unit dan widget:
```bash
flutter test
```

Menjalankan analisis statis kode:
```bash
flutter analyze
```

Format kode:
```bash
dart format .
```

---

## 📁 Struktur Direktori

```
funda/
├─ lib/
│  ├─ main.dart                 # Titik masuk utama aplikasi (ProviderScope)
│  ├─ aplikasi/                 # MaterialApp, konfigurasi GoRouter, bilah navigasi
│  ├─ tema/                     # Token warna, spasi, sudut, tipografi, ThemeData
│  ├─ komponen/                 # Widget bersama: PetakBento, TombolFunda, TeksFunda, KeadaanKosong, PembungkusLayar
│  ├─ fitur/                    # Modul fitur (Beranda, Catatan, Belajar, Lainnya, Dompet, Transaksi, Anggaran, Tujuan, Kantong, Utang, Kekayaan Bersih, Tagihan, Pengaturan, Galeri)
│  ├─ layanan/                  # Layanan perangkat (Pengingat Lokal Notifikasi)
│  ├─ data/                     # Basis data Drift (SQLite), model, tabel, repositori & migrasi bertingkat
│  ├─ perhitungan/              # Fungsi murni keuangan teruji (TDD)
│  └─ util/                     # Utilitas murni (formatRupiah, ambilAngkaRupiah)
├─ aset/
│  ├─ font/                     # Font lokal Plus Jakarta Sans (Regular, SemiBold, Bold)
│  ├─ ilustrasi/                # Aset ilustrasi
│  └─ konten/                   # Aset materi kurikulum JSON
├─ docs/                        # Dokumentasi spesifikasi, panduan agen, panduan gaya, dan kamus penamaan
│  ├─ spec.md                   # Spesifikasi fungsional dan teknis
│  ├─ agent.md                  # Panduan kerja agen koding & format laporan
│  ├─ styleguide.md             # Panduan desain Soft Bento & suara merek
│  └─ kamus_penamaan.md         # Standar istilah bahasa Indonesia
├─ test/                        # Pengujian unit & widget
│  ├─ data/                     # Uji basis data, migrasi bertingkat, repositori
│  ├─ fitur/                    # Uji widget fitur (galeri debug, form transaksi, catatan)
│  ├─ performa/                 # Uji performa kalkulasi & kueri 5.000 transaksi
│  ├─ perhitungan/              # Uji logika murni perhitungan keuangan (TDD)
│  ├─ komponen/                 # Uji widget komponen dasar
│  └─ util/                     # Uji utilitas format Rupiah
├─ README.md
└─ CHANGELOG.md
```

---

## 📚 Dokumen Terkait
- [docs/agent.md](docs/agent.md) — Aturan kerja, larangan, dan format laporan per tahap.
- [docs/spec.md](docs/spec.md) — Rincian spesifikasi lengkap aplikasi Funda.
- [docs/styleguide.md](docs/styleguide.md) — Token desain Soft Bento, warna, dan pedoman bahasa.
- [docs/kamus_penamaan.md](docs/kamus_penamaan.md) — Kamus istilah penamaan kode berbahasa Indonesia.
- [docs/utang_teknis.md](docs/utang_teknis.md) — Catatan utang teknis, dependensi native SQLite, dan rencana refaktor.

---

## 📸 Tangkapan Layar Aplikasi
Tangkapan layar otomatis yang dihasilkan dari pengujian dan emulator tersimpan pada:
- **Tahap 3C-R (Tagihan Berulang, Pengingat Lokal & Emulator):** [docs/tangkapan_layar/tahap_03c_emulator/](docs/tangkapan_layar/tahap_03c_emulator/)
  - `01_beranda.png` — Dasbor Beranda dengan Petak Bento Tagihan Terdekat
  - `02_jadwal_tagihan.png` — Layar Jadwal Tagihan Gabungan (Tagihan & Cicilan Utang)
  - `03_semua_tagihan.png` — Daftar Master Tagihan & Status Saklar
  - `04_form_tagihan.png` — Form Tagihan dengan Bantuan Nominal Fleksibel
  - `05_pengaturan.png` — Layar Pengaturan Pengingat Lokal & Catatan Jendela 45 Hari
  - `06_daftar_utang.png` — Daftar Utang & Rasio Cicilan
  - `07_kekayaan_bersih.png` — Rincian Kekayaan Bersih (Aset - Utang)
  - `08_notifikasi_tirai.png` & `dumpsys_notification.txt` — Bukti Notifikasi Android Nyata
- **Tahap 3C (Tagihan Berulang & Pengingat Lokal Widget Test):** [docs/tangkapan_layar/tahap_03c/](docs/tangkapan_layar/tahap_03c/)
- **Tahap 3B (Utang, Kekayaan Bersih & Dashboard):** [docs/tangkapan_layar/tahap_03b/](docs/tangkapan_layar/tahap_03b/)
  - `01_beranda_penuh.png` — Dashboard Beranda modular Soft Bento
  - `02_daftar_utang.png` — Layar Daftar Utang (Aktif, Lunas, Rasio Cicilan)
  - `03_form_catat_utang.png` — Form Catat Utang Baru
  - `04_detail_utang_aktif.png` — Detail Utang Berjalan
  - `05_detail_utang_lunas.png` — Detail Utang Lunas (Pesan hangat tanpa gamifikasi)
  - `06_kekayaan_bersih_menguatkan.png` — Kekayaan Bersih Negatif (Nada menguatkan)
  - `07_kekayaan_bersih_positif.png` — Kekayaan Bersih Positif
  - `08_form_transaksi_taut_utang.png` — Form Transaksi tertaut Pembayaran Utang
  - `09_menu_lainnya_utang.png` — Menu Akses di Layar Lainnya
- **Tahap 3A (Anggaran, Tujuan & Kantong):** [docs/tangkapan_layar/tahap_03a/](docs/tangkapan_layar/tahap_03a/)
- **Tahap 2 (Dompet & Transaksi):** [docs/tangkapan_layar/tahap_02/](docs/tangkapan_layar/tahap_02/)

---

## 🔔 Pengujian Pengingat Lokal di Emulator Android
Untuk memverifikasi integrasi pengingat lokal secara nyata di Android Emulator:
1. Jalankan aplikasi pada perangkat/emulator target (`flutter run`).
2. Buka menu **Lainnya** -> **Pengaturan** (`/pengaturan`).
3. Aktifkan saklar **Aktifkan Pengingat**.
4. Di mode debug (`kDebugMode`), tekan tombol **Jadwalkan Pengingat Uji (2 Menit Lagi)**.
5. Periksa status antrean notifikasi pada Android OS melalui terminal:
   ```bash
   adb shell dumpsys notification --noredact
   ```
6. Majukan waktu emulator atau tunggu 2 menit untuk melihat tirai notifikasi muncul.
7. Simulasikan reboot perangkat untuk menguji `ScheduledNotificationBootReceiver`:
   ```bash
   adb shell am broadcast -a android.intent.action.BOOT_COMPLETED
   ```

---

## 🔤 Lisensi Font
Font **Plus Jakarta Sans** dirancang oleh Tokotype (Gumpita Rahayu) dan dilisensikan di bawah lisensi terbuka [SIL Open Font License (OFL)](aset/font/OFL.txt). Berkas teks lisensi resmi disertakan pada `aset/font/OFL.txt`.
