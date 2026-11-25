# Funda

> Kuasai fondasi uangmu, dari dasar sampai mahir.

**Funda** (dari kata *fundamental* dan *fund*) adalah aplikasi mobile keuangan pribadi (Android dan iOS) berbasis **Flutter** dengan konsep "belajar sambil praktik" dan fitur dompet digital pencatatan. Aplikasi ini beroperasi sepenuhnya secara offline-first, tanpa server backend eksternal, tanpa pelacak, dan tanpa iklan.

---

## Rilis Versi 1.1.0 & Unduh APK

Rilis terbaru **Funda v1.1.0** menghadirkan pembaruan menyeluruh antarmuka editorial (*Clean Editorial Finance UI*), alur pencatatan cepat dengan kanvas dinamis, kartu putih border `1px` berpemisah tipis, tombol aksi utama berbentuk pil gelap (`TombolFunda.pilGelap`), serta kepatuhan penuh skala teks hingga `2.0x`.

- **Halaman Rilis GitHub v1.1.0:** [Rilis Resmi Funda v1.1.0](https://github.com/zidanLPTP/funda/releases/tag/v1.1.0)
- **Berkas APK per Arsitektur (`--split-per-abi`):**
  - `app-arm64-v8a-release.apk` — direkomendasikan untuk mayoritas ponsel Android modern (64-bit ARM).
  - `app-armeabi-v7a-release.apk` — untuk perangkat Android 32-bit lama.
  - `app-x86_64-release.apk` — untuk emulator atau perangkat berbasis x86_64.

### Cara Pemasangan di Ponsel Android
1. Unduh berkas APK yang sesuai dengan arsitektur perangkat (umumnya `arm64-v8a`) dari halaman rilis GitHub v1.1.0.
2. Buka berkas APK yang telah selesai diunduh.
3. Berikan izin pemasangan aplikasi dari sumber ini jika diminta oleh sistem Android.
4. Tekan tombol **Pasang (Install)** dan buka aplikasi Funda.

---

## Gambaran Tiga Sisi Funda

1. **Dompet Digital Pencatatan:** Pencatatan arus kas, banyak dompet, alokasi kantong, jadwal tagihan rutin, pelacakan utang dan cicilan, serta kalkulasi kekayaan bersih (aplikasi tidak menyimpan atau memindahkan uang asli).
2. **Belajar Sambil Praktik:** Kurikulum micro-learning 18 modul berjenjang (Tingkat Pemula, Menengah, dan Lanjutan) yang menghubungkan teori keuangan langsung dengan data riil pengguna melalui mekanisme Gerbang Data.
3. **Mode Sandbox:** Ruang simulasi mandiri dengan saldo fiktif yang terisolasi dari pencatatan riil untuk melatih keputusan investasi dan pengalokasian dana tanpa risiko.

---

## Fitur Utama Aplikasi

### 1. Pengelolaan Keuangan Mandiri
- **Multi-Dompet & Kantong:** Kelola beragam rekening bank, dompet digital, atau uang tunai serta alokasikan dana darurat dan pos tabungan khusus melalui Kantong Dompet tanpa perlu rekening baru.
- **Pencatatan Transaksi Cepat:** Catat pengeluaran (kanvas koral), pemasukan (kanvas mint), dan transfer antar dompet (kanvas biru) dengan pemilih dompet 1-ketukan dan tombol simpan *sticky* di bagian bawah layar.
- **Anggaran Bulanan:** Rencanakan dan pantau batas pengeluaran per kategori setiap bulan kalender, lengkap dengan opsi salin anggaran dari bulan sebelumnya.
- **Tujuan Keuangan:** Pantau kemajuan dana impian dan dana darurat dengan proyeksi waktu tercapai.
- **Utang & Cicilan:** Pantau sisa pokok pinjaman, rasio cicilan terhadap arus kas, pelacakan riwayat pembayaran, serta strategi pelunasan.
- **Tagihan Berulang & Pengingat Lokal:** Penjadwalan jatuh tempo rutin dengan notifikasi lokal ramah baterai dan opsi sensor nominal di layar kunci.
- **Kekayaan Bersih:** Visualisasi selisih total saldo aset dan seluruh sisa kewajiban dengan bahasa yang objektif dan menenangkan.

### 2. Kurikulum Edukasi Finansial (18 Modul Lengkap)
- **Tingkat Pemula (Modul 1 - 6):** Arus kas, tabungan, dana darurat, utang dasar, waspada penipuan dan pinjaman ilegal, serta psikologi uang.
- **Tingkat Menengah (Modul 7 - 12):** Paylater dan skor kredit, penghasilan tambahan dan kerja lepas, pajak dasar, proteksi asuransi dasar, investasi dasar, serta perencanaan tujuan besar.
- **Tingkat Lanjutan (Modul 13 - 18):** Investasi lanjutan, KPR dan kredit besar, pajak lanjutan, persiapan pensiun dan kebebasan finansial, keuangan usaha kecil, serta proteksi keluarga dan warisan dasar.
- **Fitur Belajar Interaktif:** Pemetaan profil awal adaptif, peta jalur belajar editorial, pemantik reflektif, kartu konsep dengan glosarium kamus istilah terintegrasi, cek paham interaktif, misi praktik berbasis data riil, dan kuis kelulusan modul berstandar 70%.

### 3. Pengalaman Pengguna, Aksesibilitas, dan Privasi
- **Bahasa Visual Editorial Bersih:** Kartu hero kanvas berwarna cerah, kartu daftar putih border `1px` dengan garis pemisah tipis, ikon vektor bersih tanpa kotak berlebihan, dan tombol pil gelap kontras tinggi (`>= 4.5:1`).
- **Aksesibilitas Terverifikasi:** Area sentuh minimal `48x48dp` pada navigasi sub-layar (`HeaderSubLayarEditorial`) dan dukungan penuh skala teks sistem hingga `2.0x` pada layar `360x640`.
- **Alur Sambutan & Sapaan Kontekstual:** Pengenalan nilai Funda (privasi penuh, belajar sambil praktik, ruang tenang tanpa penghakiman) serta ucapan beranda yang menyesuaikan waktu dan periode bulan.
- **Laporan Bulanan & Ekspor:** Ringkasan komposisi pengeluaran, rasio kesehatan finansial, ekspor dokumen PDF dan kartu gambar PNG, dilengkapi sakelar sembunyikan nominal.
- **Cadangan & Pemulihan Data:** Ekspor seluruh basis data ke berkas JSON terstruktur dengan validasi integritas checksum SHA-256 dan pengaman pemulihan data terakhir.
- **100% Offline-First:** Seluruh data tersimpan lokal pada basis data SQLite (Drift) di memori penyimpanan perangkat pengguna.

---

## Kebutuhan Sistem

- **Flutter SDK:** >= 3.38.0
- **Dart SDK:** >= 3.10.0
- **Android SDK:** Platform API 34+ (Android 14+)
- **Perangkat Target:** Android (API 21+) dan iOS (12.0+)

---

## Cara Menjalankan Aplikasi

1. Pasang dependensi proyek:
   ```bash
   flutter pub get
   ```

2. Jalankan generator kode basis data Drift:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

3. Jalankan aplikasi pada perangkat atau emulator:
   ```bash
   flutter run
   ```

---

## Membangun Berkas Rilis (Production Build)

Untuk menghasilkan berkas APK rilis ringkas per arsitektur (`--split-per-abi`):
```bash
flutter build apk --release --split-per-abi
```
Berkas keluaran tersedia pada lokasi:
- `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`
- `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk`
- `build/app/outputs/flutter-apk/app-x86_64-release.apk`

Untuk menghasilkan satu berkas Android App Bundle (AAB) bagi Google Play Store:
```bash
flutter build appbundle --release
```
Berkas keluaran tersedia pada lokasi:
`build/app/outputs/bundle/release/app-release.aab`

---

## Pengujian dan Kualitas Kode

Menjalankan seluruh rangkaian pengujian unit dan widget:
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

## Struktur Direktori Proyek

```text
funda/
├─ lib/
│  ├─ main.dart                 # Titik masuk utama aplikasi (ProviderScope)
│  ├─ aplikasi/                 # MaterialApp, GoRouter, bilah navigasi, rute
│  ├─ tema/                     # Token warna, spasi, sudut, tipografi, ThemeData
│  ├─ komponen/                 # Komponen bersama: PetakBento, TombolFunda, TeksFunda, HeaderSubLayarEditorial, Animasi, Perayaan
│  ├─ fitur/                    # Modul fitur (Beranda, Catatan, Belajar, Onboarding, Dompet, Transaksi, Anggaran, Tujuan, Kantong, Utang, Tagihan, Sandbox, Cadangan, Laporan, Kategori, Pengaturan)
│  ├─ layanan/                  # Layanan sistem perangkat (Pengingat Notifikasi Lokal)
│  ├─ data/                     # Basis data Drift (SQLite), tabel, entitas, repositori, migrasi skema
│  ├─ perhitungan/              # Fungsi murni kalkulasi finansial
│  └─ util/                     # Utilitas murni (formatRupiah, haptic, tanggal)
├─ aset/
│  ├─ font/                     # Font lokal Plus Jakarta Sans (Regular, SemiBold, Bold)
│  ├─ gambar/                   # Aset gambar resmi (master app icon, vektor logo)
│  └─ konten/                   # Berkas kurikulum edukasi JSON (Pemula, Menengah, Lanjutan)
├─ docs/                        # Dokumentasi teknis, spesifikasi, dan panduan proyek
├─ test/                        # Pengujian unit, widget, aksesibilitas, dan penjaga aturan
├─ android/                     # Konfigurasi platform Android, manifest, mipmap, adaptive icon
├─ ios/                         # Konfigurasi platform iOS
├─ README.md
└─ CHANGELOG.md
```

---

## Dokumentasi Spesifikasi Terkait

- [docs/agent.md](docs/agent.md) — Aturan kerja pengujian, larangan, dan format laporan.
- [docs/spec.md](docs/spec.md) — Rincian spesifikasi lengkap aplikasi Funda.
- [docs/styleguide.md](docs/styleguide.md) — Token desain editorial, warna, dan pedoman bahasa.
- [docs/format_konten.md](docs/format_konten.md) — Spesifikasi skema JSON kurikulum edukasi dan kamus istilah.
- [docs/format_cadangan.md](docs/format_cadangan.md) — Spesifikasi format JSON v1 berkas cadangan dan checksum SHA-256.
- [docs/panduan_rilis.md](docs/panduan_rilis.md) — Panduan penandatanganan rilis APK/AAB dan checklist uji perangkat fisik.
- [docs/utang_teknis.md](docs/utang_teknis.md) — Catatan arsitektur, dependensi native SQLite, dan rencana refaktor.

---

## Lisensi Font

Font **Plus Jakarta Sans** dirancang oleh Tokotype (Gumpita Rahayu) dan dilisensikan di bawah lisensi terbuka [SIL Open Font License (OFL)](aset/font/OFL.txt). Berkas teks lisensi resmi disertakan pada `aset/font/OFL.txt`.
