# Funda

> Kuasai fondasi uangmu, dari dasar sampai mahir.

**Funda** (dari kata *fundamental* dan *fund*) adalah aplikasi mobile keuangan pribadi (Android dan iOS) berbasis **Flutter** dengan konsep "belajar sambil praktik" dan fitur dompet digital pencatatan. Aplikasi ini beroperasi sepenuhnya secara offline-first, tanpa server backend eksternal, tanpa pelacak, dan tanpa iklan.

---

## Unduh Aplikasi (Download APK Langsung)

Berkas rilis resmi Funda v1.0.0 siap diunduh dan dipasang langsung pada ponsel pintar Android:

- **Tautan Unduh Langsung Utama:** [funda-v1.0.0.apk (70.5 MB)](https://github.com/zidanLPTP/funda/releases/download/v1.0.0/funda-v1.0.0.apk)
- **Tautan Unduh Alternatif:** [app-release.apk (70.5 MB)](https://github.com/zidanLPTP/funda/releases/download/v1.0.0/app-release.apk)
- **Halaman Catatan Rilis GitHub:** [Rilis Resmi Funda v1.0.0](https://github.com/zidanLPTP/funda/releases/tag/v1.0.0)

### Cara Pemasangan di Ponsel Android:
1. Unduh berkas APK melalui salah satu tautan di atas langsung dari peramban ponsel Anda.
2. Buka berkas APK yang telah selesai diunduh.
3. Berikan izin pemasangan aplikasi dari sumber ini jika diminta oleh sistem Android.
4. Tekan tombol Pasang (Install) dan buka aplikasi Funda.

---

## Gambaran Tiga Sisi Funda

1. **Dompet Digital Pencatatan:** Pencatatan arus kas, banyak dompet, alokasi kantong, jadwal tagihan rutin, pelacakan utang dan cicilan, serta kalkulasi kekayaan bersih (aplikasi tidak menyimpan atau memindahkan uang asli).
2. **Belajar Sambil Praktik:** Kurikulum micro-learning 18 modul berjenjang (Tingkat Pemula, Menengah, dan Lanjutan) yang menghubungkan teori keuangan langsung dengan data riil pengguna melalui mekanisme Gerbang Data.
3. **Mode Sandbox:** Ruang simulasi mandiri dengan saldo fiktif yang terisolasi dari pencatatan riil untuk melatih keputusan investasi dan pengalokasian dana tanpa risiko.

---

## Fitur Utama Aplikasi

### 1. Pengelolaan Keuangan Mandiri
- **Multi-Dompet:** Kelola beragam rekening bank, dompet digital, atau uang tunai dengan penyesuaian saldo terverifikasi.
- **Pencatatan Transaksi:** Catat pemasukan, pengeluaran, dan transfer antar dompet dengan kategorisasi kebutuhan, keinginan, tabungan, dan cicilan.
- **Anggaran Bulanan:** Rencanakan dan pantau batas pengeluaran per kategori setiap bulan kalender.
- **Tujuan Keuangan & Kantong:** Alokasikan dana impian dan pos dana darurat secara terstruktur di dalam dompet tanpa perlu membuka rekening baru.
- **Utang & Cicilan:** Pantau sisa pokok pinjaman, rasio cicilan terhadap arus kas, dan simulasi strategi pelunasan (metode bola salju dan longsoran).
- **Tagihan Berulang & Pengingat Lokal:** Penjadwalan jatuh tempo rutin dengan notifikasi lokal yang ramah baterai dan opsi sensor nominal di layar kunci.
- **Kekayaan Bersih:** Visualisasi selisih total saldo aset dan seluruh sisa kewajiban dengan nada komunikasi yang objektif dan menguatkan.

### 2. Kurikulum Edukasi Finansial (18 Modul Lengkap)
- **Tingkat Pemula (Modul 1 - 6):** Arus kas, tabungan, dana darurat, utang dasar, waspada penipuan dan pinjaman ilegal, serta psikologi uang.
- **Tingkat Menengah (Modul 7 - 12):** Paylater dan skor kredit, penghasilan tambahan dan kerja lepas, pajak dasar, proteksi asuransi dasar, investasi dasar, serta perencanaan tujuan besar.
- **Tingkat Lanjutan (Modul 13 - 18):** Investasi lanjutan, KPR dan kredit besar, pajak lanjutan, persiapan pensiun dan kebebasan finansial, keuangan usaha kecil, serta proteksi keluarga dan warisan dasar.
- **Fitur Belajar Interaktif:** Peta belajar terstruktur, pemantik reflektif, kartu konsep dengan glosarium kamus istilah terintegrasi, cek paham interaktif, misi praktik berbasis data riil, dan kuis kelulusan modul berstandar 70%.

### 3. Pengalaman Pengguna dan Interaksi Halus
- **Alur Sambutan (Onboarding):** Pengenalan tiga pilar nilai Funda (privasi penuh, belajar sambil praktik, dan ruang tenang tanpa penghakiman).
- **Sapaan Kontekstual:** Ucapan salam dan pesan motivasi di beranda yang menyesuaikan waktu dan periode kalender (awal/akhir bulan).
- **Animasi Angka Mengalir:** Transisi angka nominal dan bilah kemajuan yang mengalir halus tanpa patah-patah.
- **Umpan Balik Taktil (Haptik):** Getaran fisik mikro presisi pada tombol, navigasi, dan kuis dengan sakelar kendali di menu pengaturan.
- **Efek Perayaan Canvas:** Animasi partikel konfeti berbasis canvas Flutter murni saat menyelesaikan kuis modul.
- **Ikon Aplikasi Resmi:** Desain monogram F dengan daun bertumbuh di atas kanvas hijau hutan pekat dengan dukungan Android Adaptive Icon dan splash screen asli.

### 4. Laporan, Cadangan, dan Privasi
- **Laporan Bulanan:** Ringkasan komposisi pengeluaran, rasio kesehatan finansial, dan opsi ekspor cetak dokumen PDF serta kartu gambar PNG (dilengkapi sakelar sensor nominal privat).
- **Cadangan & Pemulihan Data:** Ekspor seluruh basis data ke berkas JSON terstruktur dengan validasi integritas checksum SHA-256 dan pemulihan transaksi atomik.
- **100% Offline-First:** Seluruh data tersimpan secara lokal pada basis data SQLite (Drift) di dalam memori penyimpanan perangkat pengguna.

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

Untuk menghasilkan berkas APK rilis siap pasang:
```bash
flutter build apk --release
```
Berkas keluaran akan tersedia pada lokasi:
`build/app/outputs/flutter-apk/app-release.apk`

Untuk menghasilkan berkas Android App Bundle (AAB) untuk Google Play Store:
```bash
flutter build appbundle --release
```
Berkas keluaran akan tersedia pada lokasi:
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

```
funda/
├─ lib/
│  ├─ main.dart                 # Titik masuk utama aplikasi (ProviderScope)
│  ├─ aplikasi/                 # MaterialApp, GoRouter, bilah navigasi, rute
│  ├─ tema/                     # Token warna, spasi, sudut, tipografi, ThemeData
│  ├─ komponen/                 # Komponen bersama: PetakBento, TombolFunda, TeksFunda, Animasi, Perayaan
│  ├─ fitur/                    # Modul fitur (Beranda, Catatan, Belajar, Onboarding, Dompet, Transaksi, Anggaran, Tujuan, Kantong, Utang, Tagihan, Sandbox, Cadangan, Laporan, Pengaturan, Galeri)
│  ├─ layanan/                  # Layanan sistem perangkat (Pengingat Notifikasi Lokal)
│  ├─ data/                     # Basis data Drift (SQLite), tabel, entitas, repositori, migrasi skema
│  ├─ perhitungan/              # Fungsi murni kalkulasi finansial (TDD murni)
│  └─ util/                     # Utilitas murni (formatRupiah, haptic, tanggal)
├─ aset/
│  ├─ font/                     # Font lokal Plus Jakarta Sans (Regular, SemiBold, Bold)
│  ├─ gambar/                   # Aset gambar resmi (master app icon, vektor logo)
│  └─ konten/                   # Berkas kurikulum edukasi JSON (Pemula, Menengah, Lanjutan)
├─ docs/                        # Dokumentasi teknis, spesifikasi, dan panduan proyek
│  ├─ spec.md                   # Rincian spesifikasi lengkap fitur Funda
│  ├─ agent.md                  # Panduan standar kejujuran laporan dan pengujian
│  ├─ styleguide.md             # Panduan desain Soft Bento dan pedoman suara
│  ├─ format_konten.md          # Spesifikasi format JSON kurikulum dan aturan kalimat
│  ├─ format_cadangan.md        # Spesifikasi format cadangan data dan checksum SHA-256
│  ├─ utang_teknis.md           # Catatan arsitektur dan rekam jejak teknis
│  ├─ daftar_tinjauan_konten.md # Rekapitulasi catatan tinjauan konten
│  └─ panduan_rilis.md          # Panduan penandatanganan rilis APK/AAB dan publikasi toko aplikasi
├─ test/                        # Pengujian unit, widget, dan pengawal arsitektur
├─ android/                     # Konfigurasi platform Android, manifest, mipmap, adaptive icon
├─ ios/                         # Konfigurasi platform iOS
├─ README.md
└─ CHANGELOG.md
```

---

## Dokumentasi Spesifikasi Terkait

- [docs/agent.md](docs/agent.md) — Aturan kerja pengujian, larangan, dan format laporan.
- [docs/spec.md](docs/spec.md) — Rincian spesifikasi lengkap aplikasi Funda.
- [docs/styleguide.md](docs/styleguide.md) — Token desain Soft Bento, warna, dan pedoman bahasa.
- [docs/format_konten.md](docs/format_konten.md) — Spesifikasi skema JSON kurikulum edukasi dan kamus istilah.
- [docs/format_cadangan.md](docs/format_cadangan.md) — Spesifikasi format JSON v1 berkas cadangan dan checksum SHA-256.
- [docs/panduan_rilis.md](docs/panduan_rilis.md) — Panduan penandatanganan rilis APK/AAB dan checklist uji perangkat fisik.
- [docs/utang_teknis.md](docs/utang_teknis.md) — Catatan arsitektur, dependensi native SQLite, dan rencana refaktor.

---

## Lisensi Font

Font **Plus Jakarta Sans** dirancang oleh Tokotype (Gumpita Rahayu) dan dilisensikan di bawah lisensi terbuka [SIL Open Font License (OFL)](aset/font/OFL.txt). Berkas teks lisensi resmi disertakan pada `aset/font/OFL.txt`.
