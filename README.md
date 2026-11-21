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
- [docs/format_konten.md](docs/format_konten.md) — Spesifikasi skema JSON kurikulum edukasi, kamus istilah, template laporan, dan aturan penulisan kalimat <= 25 kata.
- [docs/format_cadangan.md](docs/format_cadangan.md) — Spesifikasi format JSON v1 berkas cadangan, checksum SHA-256, dan mekanisme rollback transaksi atomik.
- [docs/utang_teknis.md](docs/utang_teknis.md) — Catatan utang teknis, dependensi native SQLite, dan rencana refaktor.

---

## 📸 Tangkapan Layar Aplikasi
Tangkapan layar otomatis yang dihasilkan dari pengujian dan emulator tersimpan pada:
- **Tahap 8C (Modul 5 "Waspada Penipuan & Pinjol Ilegal" di Emulator Pixel 8):** [docs/tangkapan_layar/](docs/tangkapan_layar/)
  - `tahap_08c_01_modul_5_terkunci.png` — Modul 5 terkunci untuk pengguna baru dengan pesan lampiran resmi
  - `tahap_08c_02_modul_5_terbuka.png` — Modul 5 terbuka setelah prasyarat Modul 1 diselesaikan
  - `tahap_08c_03_pelajaran_5_1_opsi_a.png` — Pelajaran 5.1 misi keputusan: memilih opsi a (tidak aman) dengan umpan balik edukatif
  - `tahap_08c_04_pelajaran_5_1_opsi_c.png` — Pelajaran 5.1 misi keputusan: memilih opsi c (tidak aman) dengan umpan balik edukatif
  - `tahap_08c_05_pelajaran_5_1_opsi_b_selesai.png` — Pelajaran 5.1 misi keputusan: memilih opsi b (aman) dan tombol Lanjut aktif
  - `tahap_08c_06_pelajaran_5_2_disclaimer.png` — Pelajaran 5.2 misi daftar periksa: komponen disclaimer tampil di atas
  - `tahap_08c_07_pelajaran_5_2_dua_centang.png` — Pelajaran 5.2 misi daftar periksa: 2 langkah dicentang (tombol Selesai nonaktif)
  - `tahap_08c_08_pelajaran_5_2_tiga_centang_selesai.png` — Pelajaran 5.2 misi daftar periksa: 3 langkah dicentang (tombol Selesai aktif)
  - `tahap_08c_09_pelajaran_5_3_selesai.png` — Pelajaran 5.3 misi daftar periksa: rencana darurat selesai
  - `tahap_08c_10_kuis_percobaan_1_tidak_lulus.png` — Kuis Modul 5 percobaan 1 (skor 60% tidak lulus)
  - `tahap_08c_11_kuis_percobaan_2_lulus.png` — Kuis Modul 5 percobaan 2 (skor 80% lulus)
  - `tahap_08c_12_beranda_modul_5_selesai.png` — Dasbor Beranda menampilkan petak Modul 5 selesai
  - `tahap_08c_13_regresi_pemulihan_selesai.png` — Pembuktian integritas pemulihan seluruh tabel SQLite (termasuk tabel_hasil_misi)
- **Tahap 8B (Modul 4 "Utang & Cicilan" di Emulator Pixel 8):** [docs/tangkapan_layar/](docs/tangkapan_layar/)
  - `tahap_08b_01_umpan_balik_ringkasan_utang.png` — Pelajaran 4.1 dengan umpan balik `ringkasan_utang`
  - `tahap_08b_02_umpan_balik_biaya_pinjaman.png` — Pelajaran 4.2 dengan umpan balik `biaya_pinjaman_tercatat`
  - `tahap_08b_03_umpan_balik_rasio_cicilan.png` — Pelajaran 4.3 dengan umpan balik `rasio_cicilan_bulan_ini`
  - `tahap_08b_04_umpan_balik_urutan_pelunasan.png` — Pelajaran 4.4 dengan umpan balik `urutan_pelunasan` (bola salju & longsor)
  - `tahap_08b_05_kuis_tidak_lulus.png` — Layar hasil Kuis Akhir Modul 4 percobaan pertama tidak lulus (skor 60%)
  - `tahap_08b_06_kuis_lulus.png` — Layar kelulusan Kuis Akhir Modul 4 percobaan kedua lulus (skor >= 70%)
  - `tahap_08b_07_beranda_modul_selesai.png` — Dasbor Beranda setelah Modul 4 lulus
  - `tahap_08b_08_modul_terkunci_tombol_pernyataan.png` — Modul 4 terkunci untuk pengguna tanpa utang dengan tombol "Aku tidak punya ini"
  - `tahap_08b_09_umpan_balik_pernyataan_tanpa_utang.png` — Pelajaran 4.1 dengan umpan balik adaptif pernyataan tanpa utang
  - `tahap_08b_10_modul_terkunci_kembali.png` — Modul 4 terkunci kembali setelah pernyataan dicabut
  - `tahap_08b_11_regresi_19_tabel.png` — Pembuktian integritas pemulihan 19 tabel SQLite via `sqlite_master`
- **Tahap 8A (Modul 2 "Tabungan" & Modul 3 "Dana Darurat" di Emulator Pixel 8):** [docs/tangkapan_layar/](docs/tangkapan_layar/)
  - `tahap_08a_peta_belajar_modul_2_terbuka.png` — Tab Belajar dengan Modul 2 terbuka setelah Modul 1 selesai
  - `tahap_08a_pelajaran_2_1_umpan_balik.png` — Pelajaran 2_1 dengan umpan balik `ringkasan_tujuan_tabungan`
  - `tahap_08a_pelajaran_2_2_misi.png` — Pelajaran 2_2 dengan misi pengisian kantong tujuan tabungan
  - `tahap_08a_pelajaran_2_3_estimasi.png` — Pelajaran 2_3 dengan umpan balik `estimasi_tabungan` dan simulasi setoran
  - `tahap_08a_kuis_modul_2_lulus.png` — Layar kelulusan Kuis Akhir Modul 2 (skor >= 70%)
  - `tahap_08a_modul_3_terkunci.png` — Modul 3 terkunci menunggu syarat 3 pengeluaran berlabel kebutuhan
  - `tahap_08a_modul_3_terbuka.png` — Modul 3 terbuka setelah 3 pengeluaran kebutuhan tercatat
  - `tahap_08a_pelajaran_3_1_pengeluaran_wajib.png` — Pelajaran 3_1 dengan umpan balik `pengeluaran_wajib_bulanan`
  - `tahap_08a_pelajaran_3_2_target_darurat.png` — Pelajaran 3_2 dengan umpan balik `target_dana_darurat` (aturan praktis 3–6x)
  - `tahap_08a_pelajaran_3_3_progres_darurat.png` — Pelajaran 3_3 dengan umpan balik `progres_dana_darurat` dalam bulan bertahan
  - `tahap_08a_kuis_modul_3_lulus.png` — Layar kelulusan Kuis Akhir Modul 3
- **Tahap 7 (Laporan Bulanan & Cadangan Data di Emulator Pixel 8):** [docs/tangkapan_layar/](docs/tangkapan_layar/)
  - `tahap_07_banner_beranda.png` — Banner pengingat cadangan data 14 hari di Beranda
  - `tahap_07_cadangan.png` — Layar Cadangan & Pemulihan (`/cadangan`)
  - `tahap_07_pratinjau_pemulihan.png` — Dialog Pratinjau Data Cadangan sebelum konfirmasi pemulihan
  - `tahap_07_laporan_normal.png` — Layar Laporan Bulanan mode normal (`/laporan`)
  - `tahap_07_laporan_sensor.png` — Layar Laporan Bulanan dengan saklar sensor nominal aktif
  - `tahap_07_pratinjau_setelah_pulih.png` — Dialog Pratinjau Pemulihan dengan data yang terbukti pulih
  - `tahap_07_beranda_setelah_pulih.png` — Tampilan Beranda setelah pemulihan data berhasil diselesaikan
  - Dokumen dan gambar hasil ekspor tersimpan pada: [docs/contoh_ekspor/](docs/contoh_ekspor/)
    * `laporan.pdf` — Dokumen cetak PDF A4 teks asli tertanam font Plus Jakarta Sans
    * `laporan_normal.png` — Kartu bento laporan resolusi 1080 px
    * `laporan_sensor.png` — Kartu bento laporan resolusi 1080 px bebas angka/simbol Rupiah
- **Tahap 6-R (Materi Modul 1 Lengkap di Emulator Pixel 8):** [docs/tangkapan_layar/tahap_06_emulator/](docs/tangkapan_layar/tahap_06_emulator/)
- **Tahap 5 (Tes Awal & Personalisasi Belajar di Emulator Pixel 8):** [docs/tangkapan_layar/tahap_05_emulator/](docs/tangkapan_layar/tahap_05_emulator/)
  - `07_tab_belajar_dengan_rekomendasi.png` — Kartu rekomendasi personalisasi ramah di bagian atas Tab Belajar setelah menyelesaikan tes awal dan pembentukan profil keuangan
- **Tahap 4-R (Revisi & Pembuktian Mesin Belajar di Emulator Pixel 8):** [docs/tangkapan_layar/tahap_04_emulator/](docs/tangkapan_layar/tahap_04_emulator/)
  - `01_tab_belajar_peta.png` — Peta belajar lengkap 19 modul pada 3 tingkat (Pemula, Menengah, Lanjutan)
  - `02_pelajaran_terbuka_pemantik.png` — Pemutar pelajaran micro-learning langkah pemantik reflektif
  - `03_kartu_konsep_istilah.png` — Kartu konsep dengan istilah kamus interaktif (`{{arus kas}}`)
  - `04_cek_paham_interaktif.png` — Cek paham interaktif dengan pilihan jawaban dan umpan balik langsung
  - `05_misi_praktik_belum_selesai.png` — Misi praktik nyata memeriksa data riil pengguna sebelum data tercatat
  - `06_misi_praktik_selesai_umpan_balik.png` — Misi praktik selesai dan umpan balik objektif dari data riil
  - `07_pelajaran_terkunci_gerbang_data.png` — Pelajaran terkunci gerbang data dengan tombol "Lengkapi Data Sekarang"
  - `08_kuis_akhir_modul.png` — Kuis akhir modul dengan bilah kemajuan dan pilihan jawaban acak
  - `09_kuis_selesai_lulus.png` — Hasil kelulusan kuis modul (nilai >= 70% dan lencana lulus)
  - `10_beranda_petak_belajar.png` — Petak Beranda "Lanjut Belajar" reaktif mengarahkan ke materi aktif
- **Tahap 4 (Mesin Belajar Widget Test):** [docs/tangkapan_layar/tahap_04/](docs/tangkapan_layar/tahap_04/)
  - `01_tab_belajar_peta.png` — Tab Belajar menampilkan peta 3 tingkat (Pemula, Menengah, Lanjutan)
  - `02_pelajaran_terkunci_apa_yang_kurang.png` — Pelajaran terkunci dengan dialog apa yang kurang & tombol pernyataan
  - `03_pemutar_pemantik.png` — Pemutar pelajaran micro-learning langkah pemantik reflektif
  - `04_pemutar_kartu_konsep_tooltip.png` — Kartu konsep dengan teks istilah interaktif & dialog kamus terbuka
  - `05_pemutar_cek_paham.png` — Langkah cek paham interaktif dengan pilihan jawaban dan penjelasan langsung
  - `06_pemutar_kartu_misi.png` — Kartu misi praktik nyata yang memeriksa data keuangan riil pengguna
  - `07_pemutar_umpan_balik.png` — Umpan balik nyata tanpa kata menghakimi dari data pengguna
  - `08_kuis_soal.png` — Kuis akhir modul dengan bilah kemajuan dan pilihan jawaban acak
  - `09_kuis_hasil_lulus.png` — Hasil kuis kelulusan modul (nilai >= 70%)
  - `10_beranda_lanjut_belajar.png` — Petak Beranda "Lanjut Belajar" reaktif mengarahkan ke pelajaran aktif
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

## 📸 Skrip Pengambilan Tangkapan Layar Emulator
Pembangkit tangkapan layar berada di luar rangkaian pengujian unit/widget untuk mencegah interferensi I/O dan pending timer pada test binding:
- **Perintah Resmi ADB**:
  ```bash
  adb exec-out screencap -p > docs/tangkapan_layar/tahap_04_emulator/<nama_berkas>.png
  ```
- **Skrip Pembantu PowerShell**:
  Jalankan skrip pembantu untuk mengambil tangkapan layar aktif dari emulator secara aman:
  ```powershell
  powershell -ExecutionPolicy Bypass -File tool/ambil_tangkapan_layar.ps1 -NamaBerkas "01_tab_belajar_peta.png"
  ```

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
