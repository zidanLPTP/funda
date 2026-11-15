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
│  ├─ fitur/                    # Modul fitur (Beranda, Catatan, Belajar, Lainnya, Galeri)
│  ├─ data/                     # Basis data Drift (SQLite) & migrasi bertingkat
│  ├─ perhitungan/              # Fungsi murni keuangan teruji
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
│  ├─ data/                     # Uji basis data & migrasi
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
