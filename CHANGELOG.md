# Catatan Perubahan (Changelog) Funda

Semua perubahan penting pada proyek Funda akan dicatat di dalam dokumen ini.
Format penulisan mengacu pada standar Keep a Changelog dan penamaan commit Funda.

---

## [0.7.1] - 2026-11-17 — Penyelarasan Tahap 5 (Tahap 5-R)

Tahap 5-R: Penyelarasan skema profil keuangan, tabel hasil tes awal, kode alasan rekomendasi, validator konten, dan pembuktian integrasi emulator. Menyelaraskan seluruh nama kolom profil ke snake_case resmi prompt (`punya_penghasilan`, `punya_utang`, `dana_darurat`, `menabung`, `investasi`, `mencatat_keuangan`, `tujuan_utama`), menghapus pertanyaan dan kolom `rentang` serta `tanggungan`, menaikkan versi basis data ke skema 10 dengan migrasi idempoten yang memetakan kolom lama dan membuang data rentang/tanggungan. Memindahkan seluruh logika evaluasi rekomendasi modul ke fungsi murni dengan konstanta bernama (`alasanSkorTesRendah`, `alasanPunyaUtangTercatat`, `alasanDanaDaruratKosong`, `alasanKeinginanTerbesar`, `alasanBelumAdaModulSelesai`), menerapkan aturan STRIK pengeluaran keinginan (seri tidak memicu), memperluas validator konten untuk `tes_awal.json` dan `rekomendasi.json` (mencegah angka aturan praktis/tarif/regulasi dan klaim keuangan menghakimi), menambahkan 8 kasus uji konten rusak baru, serta membuktikan 5 skenario integrasi dengan interaksi nyata dan assertion di Emulator Android 16 (API 36).

### Ditambahkan
- **Skema & Migrasi Basis Data Versi 10 (`lib/data/`):**
  - Kenaikan versi skema basis data menjadi 10 (`schemaVersion => 10`) pada `lib/data/basis_data.dart`.
  - Migrasi `case 10:` idempoten yang memetakan data kolom lama (`darurat` -> `dana_darurat`, `utang` -> `punya_utang`) dan membuang kolom `rentang` dan `tanggungan`.
  - Pengujian beruntun migrasi bertingkat skema v1 s.d. v10 dengan data terisi lengkap (`test/data/basis_data_test.dart` dan `test/data/migrasi_beruntun_test.dart`) lulus 100%.
- **Logika Murni & Personalisasi Berbasis Kode (`lib/perhitungan/`):**
  - Konstanta bernama heuristik saran di `lib/perhitungan/perhitungan_tes_awal_personalisasi.dart`.
  - Evaluasi Aturan 1 s.d. 5 murni di fungsi Dart: skor tes rendah (< 70 vs 70), sisa utang aktif > 0, dana darurat kosong, sifat keinginan terbesar secara STRIK (bukan seri), dan modul terbuka pertama bila belum ada modul selesai.
  - Penanganan modul `tersedia: false` ("segera hadir") dan informasi `apaYangKurang` dari gerbang modul.
  - 10 nama uji spesifik untuk setiap aturan pada `test/perhitungan/perhitungan_tes_awal_personalisasi_test.dart`.
- **Pemeriksa Konten Mendalam & Uji Konten Rusak (`lib/fitur/belajar/`, `test/fitur/`):**
  - Validasi ketat `tes_awal.json`: tepat 12 butir soal (2 per modul pemula), 4 opsi jawaban dengan opsi ke-4 persis "Belum tahu, nggak apa-apa", indeks benar 0..2, tanpa angka aturan praktis (mis. 50/30/20), tanpa tarif pajak/bunga pinjol spesifik, dan tanpa kutipan regulasi.
  - Validasi kuesioner profil: 6 pertanyaan dengan kunci dan nilai pilihan yang sesuai skema database SQLite.
  - Validasi `rekomendasi.json`: kode alasan dua arah wajib cocok dengan kode murni aplikasi, bebas kata terlarang, dan bebas klaim keuangan/penilaian menghakimi.
  - 8 kasus uji konten rusak baru pada `test/fitur/pemeriksa_konten_rusak_test.dart` (total 38 uji).
- **Pengujian Integrasi Emulator Android 16 (`integration_test/`):**
  - Bukti 5 skenario lengkap dengan interaksi nyata (`tap`, `enterText`) dan assertion database/UI pada `integration_test/tahap_05_alur_tes_awal_emulator_test.dart`.
  - Pengambilan tangkapan layar otomatis via `tool/ambil_tangkapan_layar.ps1`.
  - Versi rilis Android diverifikasi langsung dari emulator via `adb shell getprop ro.build.version.release` = 16.

---

## [0.7.0] - 2026-11-17 — Tahap 5: Tes Awal & Personalisasi

Tahap 5: Tes Awal Keuangan (Modul 0), Pembentukan Profil Keuangan, dan Personalisasi Saran Modul Belajar. Pengguna baru dapat mengikuti tes mandiri penempatan yang terdiri dari 6 pertanyaan profil keuangan (tujuan, sumber penghasilan, rentang, tanggungan, dana darurat, utang) dan 12 butir soal pemahaman awal (2 butir per modul dengan opsi ke-4 "Belum tahu, nggak apa-apa"). Sistem menghasilkan skor total dan skor per topik pemula, menyimpannya ke skema basis data SQLite (migrasi versi 9), serta menghasilkan rekomendasi personalisasi modul berbasis aturan deterministik yang ramah dan bebas menghakimi. Dilengkapi kartu rekomendasi di bagian atas Tab Belajar, kemampuan melewati tes awal (`profil_dilewati`), opsi tes ulang, serta gerbang data Modul 1 yang menyelaraskan opsi pengisian profil atau lewati.

### Ditambahkan
- **Skema & Migrasi Basis Data Versi 9 (`lib/data/`):**
  - `TabelProfilKeuangan`: Menyimpan data profil keuangan pengguna (`tujuan_utama`, `sumber_penghasilan`, `rentang_penghasilan`, `tanggungan`, `status_darurat`, `status_utang`, `dibuat_pada`).
  - `TabelHasilTesAwal`: Menyimpan riwayat hasil tes awal (`skor_total_persen`, `total_soal`, `total_benar`, `skor_per_modul_json`, `selesai_pada`) dengan indeks performa `idx_hasil_tes_awal_waktu`.
  - Migrasi idempoten `case 9` dan pengujian beruntun migrasi v1 -> v9 lulus 100%.
- **Konten Tes Awal & Rekomendasi (`aset/konten/`):**
  - `aset/konten/pemula/mulai_tes_awal/tes_awal.json`: 6 pertanyaan profil dan 12 butir soal tes awal berbobot 0/1 dengan opsi ke-4 selalu "Belum tahu, nggak apa-apa".
  - `aset/konten/rekomendasi.json`: Matriks aturan rekomendasi modul berbasis kode alasan (`fondasi_awal`, `skor_rendah`, `ada_utang`, `dana_darurat_kosong`, `keinginan_terbesar`) dengan narasi ramah tanpa kata menghakimi.
- **Logika Murni & TDD (`lib/perhitungan/perhitungan_tes_awal_personalisasi.dart`):**
  - `hitungSkorTesAwal`: Menghitung skor total persen dan skor per modul secara adil dan deterministik.
  - `bangunProfil`: Memetakan jawaban kuesioner profil pengguna ke objek data terstruktur.
  - `rekomendasiModul`: Menentukan urutan rekomendasi modul berdasarkan gabungan kondisi riil pengguna dan nilai pemahaman awal.
  - `tentukanTargetLanjutBelajar`: Menentukan prioritas pelajaran berikutnya di Beranda (sedang berjalan > rekomendasi terbuka pertama > modul terbuka pertama).
- **Antarmuka Pengguna & Integrasi State (`lib/fitur/belajar/`):**
  - `LayarTesAwal` (`/belajar/tes-awal`): Alur bertahap (Pembuka -> Profil 6 pertanyaan -> Soal Tes 12 butir -> Hasil & Rekomendasi).
  - Kartu rekomendasi personalisasi dinamis di bagian atas Tab Belajar (`LayarBelajar`) dengan tombol "Profilku" / "Mulai Tes Ulang".
  - Pengacakan kuis modul yang deterministik dengan dukungan parameter benih (`benih`) di `LayarKuisModul`.
- **Pengujian Lengkap & Bukti Resmi (`test/`, `integration_test/`, `docs/bukti/`):**
  - Uji murni tes awal & personalisasi (`test/perhitungan/perhitungan_tes_awal_personalisasi_test.dart`): 13 skenario lengkap.
  - Uji widget tes awal (`test/fitur/tes_awal_widget_test.dart`): Melewati tes awal dan alur pengisian lengkap.
  - Uji integrasi emulator Pixel 8 (`integration_test/tahap_05_alur_tes_awal_emulator_test.dart`): Pengujian end-to-end lengkap dari Beranda -> Peta Belajar -> Tes Awal -> Profil -> 12 Soal -> Hasil Rekomendasi -> Kembali ke Tab Belajar.
  - Bukti keluaran nyata: `docs/bukti/tahap_05_analyze.txt` (0 issues) dan `docs/bukti/tahap_05_test.txt` (270 passed).
  - Tangkapan layar resmi: `docs/tangkapan_layar/tahap_05_emulator/07_tab_belajar_dengan_rekomendasi.png`.

---

## [0.6.3] - 2026-11-17 — Penyelarasan Terakhir Tahap 4 (Tahap 4-R3)

Tahap 4-R3: Penyelarasan terakhir dan pengukuhan arsitektur mesin belajar Funda. Menyelaraskan dua pelajaran contoh persis spesifikasi (1.2 "Memetakan Arus Kas", gerbang dompet >= 1, misi arus kas [masuk >= 1 DAN keluar >= 1], umpan balik arus_kas_bulan_ini; 1.3 "Kebutuhan vs Keinginan", gerbang pengeluaran >= 3, misi semua_kategori_berlabel, umpan balik komposisi_sifat_bulan_ini). Mengoreksi evaluasi misi agar tidak lolos pada data kosong dan menambahkan aturan pemeriksa konten yang menolak misi yang otomatis terpenuhi oleh gerbang pelajarannya sendiri. Pembersihan UTF-8 BOM pada berkas JSON kurikulum, penegasan daftar kata terlarang di satu tempat sentral dengan kalimat > 25 kata sebagai peringatan, pembuktian kesetaraan SQL batas bulan pukul 23:30 WIB, pengukuran performa ulang 10 iterasi bersih di emulator Pixel 8, serta pengujian alur interaktif end-to-end lengkap dan pembuktian eliminasi penulisan berkas ke `docs/tangkapan_layar` dari seluruh berkas uji.

### Ditambahkan
- **Pemeriksa Konten Relasi Misi vs Gerbang (`lib/fitur/belajar/model/pembaca_konten.dart`):**
  - Pemeriksa konten otomatis menolak berkas pelajaran bila misinya sudah otomatis terpenuhi oleh gerbang pelajarannya sendiri (misi sama atau lebih longgar dari gerbang), kecuali misi bertipe `lihat_hitungan`.
  - Dukungan objek gerbang & misi `'arus_kas'` yang mensyaratkan minimal 1 pemasukan DAN 1 pengeluaran tercatat.
- **Pengujian Kasus Data Kosong & Batas Waktu (`test/`):**
  - Uji murni: Pada data kosong, gerbang 1.2 dan 1.3 terkunci, serta misi 1.2 dan 1.3 BELUM lolos.
  - Uji kesetaraan batas bulan: Transaksi pukul 23:30 WIB pada akhir bulan (31 Januari) dan 00:30 WIB awal bulan (1 Februari) membuktikan kesetaraan antara agregasi SQL berbasis offset lokal WIB dengan fungsi murni Dart.
  - Berkas bukti resmi keluaran lengkap `flutter analyze` (`docs/bukti/tahap_04_r3_analyze.txt`) dan `flutter test --reporter expanded` (`docs/bukti/tahap_04_r3_test.txt`).

### Diperbaiki
- **Penyelarasan Konten Pelajaran Contoh:**
  - `anggaran_arus_kas_1_2.json`: Gerbang `ada_data` `dompet >= 1`, misi `ada_data` `arus_kas >= 1` (masuk >= 1 dan keluar >= 1), umpan balik `arus_kas_bulan_ini`.
  - `anggaran_arus_kas_1_3.json`: Gerbang `ada_data` `pengeluaran >= 3`, misi `aturan_data` `semua_kategori_berlabel`, umpan balik `komposisi_sifat_bulan_ini`.
  - Evaluasi `semua_kategori_berlabel`: Terpenuhi HANYA bila ada minimal 1 kategori keluar yang pernah dipakai transaksi dan semuanya berlabel (data kosong = belum terpenuhi).
- **Integritas Berkas Konten & Kebersihan Repositori:**
  - Pembersihan UTF-8 BOM (`\xef\xbb\xbf`) dari seluruh 18 berkas `modul.json` sehingga menjadi format UTF-8 standar murni.
  - Pembuktian `git grep -n "docs/tangkapan_layar" -- test` menghasilkan kosong (0 keluaran): seluruh berkas uji di `test/` tidak lagi menulis ke direktori `docs/`.
  - Tangkapan layar resmi emulator 100% diambil dari luar uji menggunakan `tool/ambil_tangkapan_layar.ps1` via `adb exec-out screencap -p`.
- **Pengukuran Ulang 10 Iterasi Bersih di Emulator Pixel 8:**
  - Basis data diisolasi bersih tiap iterasi dengan proporsi data bulan berjalan 4x lipat (2.500 vs 10.000 transaksi di bulan Maret 2026).
  - Waktu kueri Beranda: 5k Median = **19.20 ms**, 20k Median = **33.14 ms** (kenaikan wajar sesuai B-Tree index scan).
  - Waktu data tampil Beranda: 5k Median = **85.83 ms**, 20k Median = **88.39 ms** (kenaikan 3.0%).
  - Tab Belajar siklus penuh: 5k Median = **13.79 ms**, 20k Median = **37.23 ms** (tetap < 50 ms).
  - Jumlah kueri: Beranda = **9 kueri**, Tab Belajar = **5 kueri**.

---

## [0.6.2] - 2026-11-16 — Penyelarasan & Pembuktian Sebenarnya (Tahap 4-R2)

Tahap 4-R2: Penyelarasan ketat skema konten dengan spesifikasi, perbaikan penggunaan istilah teknis pada teks pelajaran, penguatan fungsi murni komposisi sifat dengan aturan pemecah seri deterministik, penambahan pengujian konten rusak dan pemeriksa bahasa lengkap, pemisahan skrip tangkapan layar emulator ke luar pengujian unit/widget, serta pengukuran profiling jujur siklus penuh Tab Belajar dan Beranda di emulator Pixel 8.

### Ditambahkan
- **Pengujian Lengkap Butir B (`test/fitur/pemeriksa_konten_rusak_test.dart` & `test/fitur/gerbang_dan_misi_lengkap_test.dart`):**
  - Uji `hitungKomposisiSifat`: 3 bagian sama besar (pemecah seri deterministik), 1 sifat saja = 100%, 5 sifat tidak merata, tidak ada pengeluaran (mengembalikan Map kosong, bebas pembagian nol), nilai nominal besar (puluhan milyar Rupiah).
  - Uji kelulusan kuis ambang 70%: 3 dari 5 GAGAL (60%), 4 dari 5 LULUS (80%), 6 dari 10 GAGAL (60%), 7 dari 10 LULUS (70%).
  - Uji pembaca konten rusak dengan galat terstruktur menyebut berkas dan kolom: ID duplikat pada modul/kuis, format ID tidak stabil `<modul>_<nomor>`, referensi pelajaranId/gerbang tidak terdaftar, istilah `{{...}}` tidak ada di kamus, kartu > 3, durasi di luar 3..8 menit, jenis misi belum didukung.
  - Uji pemeriksa bahasa: deteksi kata terlarang (*boros, bodoh, malas, ceroboh, payah*, frasa menyalahkan pengguna), deteksi teks polos istilah teknis (*surplus, defisit, aset, liabilitas*) tanpa `{{ }}`, serta peringatan kalimat > 25 kata.
  - Uji kuis akhir terkunci selama pelajaran belum semua selesai (uji murni logika dan uji widget tombol disabled).
- **Alat Bantu Tangkapan Layar Terpisah (`tool/ambil_tangkapan_layar.ps1`):**
  - Mengambil tangkapan layar langsung dari framebuffer emulator via `adb exec-out screencap -p` di luar proses pengujian Flutter untuk mencegah pending timer dan interferensi I/O.

### Diperbaiki
- **Penyelarasan Teks Pelajaran & Kamus:**
  - `anggaran_arus_kas_1_3.json`: Baris 44 diperbaiki dari teks polos `"defisit"` menjadi `"{{defisit}}"` agar memiliki interaktivitas tooltip kamus dan mematuhi aturan bahasa.
  - `investasi_lanjutan/modul.json` & `proteksi_dasar/modul.json`: Deskripsi modul diperbarui menggantikan kata teknis "aset" dengan bahasa awam yang ramah ("alokasi instrumen", "barang berharga").
  - `RegistriUmpanBalik`: Memastikan teks umpan balik `arus_kas_bulan_ini` dan `komposisi_sifat_bulan_ini` sepenuhnya bebas dari kata surplus/defisit, menggunakan kalimat awam "lebih besar" / "lebih kecil" disertai angka Rupiah.
- **Pengukuran Profiling Jujur di Emulator Pixel 8:**
  - Tab Belajar Siklus Lengkap (19 modul + 2 pelajaran + kueri foto data + evaluasi gerbang): Median **19.61 ms** (5k transaksi) dan **26.31 ms** (20k transaksi), terburuk 34.65 ms (memenuhi target < 50 ms).
  - Beranda Kueri Paralel: Median **17.86 ms** (5k transaksi) dan **13.24 ms** (20k transaksi), kenaikan waktu **-25.8%** (konstan O(1), memenuhi target < 60 ms dan kenaikan < 25%).

---

## [0.6.1] - 2026-11-16 — Revisi & Pembuktian Mesin Belajar (Tahap 4-R)

Tahap 4-R: Revisi menyeluruh dan pembuktian performa empiris mesin belajar di emulator Android (Pixel 8, API 36). Mengoptimalkan kueri agregasi SQL Beranda dan foto data pengguna sehingga waktu muat Beranda pada 20.000 transaksi turun drastis ke median 14.46 ms (jauh melampaui target < 60 ms), kenaikan waktu beban data 4x (5k -> 20k) bersifat konstan O(1) (-17.3%, di bawah batas 25%), Tab Belajar 19 modul stabil di median 1.32 ms, migrasi skema basis data versi 8 (4 indeks komposit baru), pengujian validasi gerbang data menyeluruh (14 uji), pemeriksa otomatis konten rusak (12 kasus) dan pemeriksa bahasa untuk seluruh berkas kurikulum statis, serta dokumentasi tangkapan layar emulator baru.

### Diperbaiki & Dioptimalkan
- **Performa Beranda & Tab Belajar pada 20.000 Transaksi di Emulator:**
  - `TransaksiRepositori`: Ditambahkan kueri agregasi SQL murni `hitungPemasukanRataRataSQL`, `pantauPemasukanRataRataSQL`, dan `pantauKomposisiSifatBulanIniSQL`.
  - `TagihanRepositori`: Eliminasi penarikan seluruh baris transaksi (`SELECT * FROM tabel_transaksi`) pada `ambilJadwalGabungan`. Kueri transaksi kini diarahkan secara presisi hanya untuk ID transaksi yang tertaut pada pembayaran tagihan (`SELECT id, jumlah_rupiah WHERE id IN (...)`).
  - `PenyediaTransaksi`: `penyediaArusKasBulanIni` kini membaca agregasi SQL `pantauArusKasSQL` alih-alih memuat daftar transaksi ke memori Dart.
  - `PenyediaUtang`: `penyediaPemasukanBulananRataRata` membaca agregasi SQL 3 bulan alih-alih memproses list transaksi di Dart.
  - `PenyediaBelajar`: `penyediaFotoData` me-watch sinyal ringan `pantauJumlahTransaksi()` (O(1)) dan `penyediaDaftarSemuaModul` memanfaatkan in-memory caching untuk modul statis.
  - Hasil profil empiris di emulator Android Pixel 8 API 36:
    * Kueri Beranda (20.000 transaksi): **Median 14.46 ms** (target < 60 ms terpenuhi).
    * Kenaikan waktu 5.000 -> 20.000 transaksi: **-17.3%** (target < 25% terpenuhi).
    * Peta Belajar 19 modul: **Median 1.32 ms** (target < 50 ms terpenuhi).
- **Skema Basis Data Versi 8 (`lib/data/basis_data.dart`):**
  - Ditambahkan 4 indeks komposit baru:
    * `idx_transaksi_jenis` ON `tabel_transaksi(jenis)`
    * `idx_transaksi_jenis_kategori` ON `tabel_transaksi(jenis, kategori_id)`
    * `idx_transaksi_waktu_id` ON `tabel_transaksi(waktu_transaksi DESC, id DESC)`
    * `idx_transaksi_waktu_jenis` ON `tabel_transaksi(waktu_transaksi, jenis)`
  - Seluruh kueri transaksi Beranda terbukti pada `EXPLAIN QUERY PLAN` menggunakan `INDEX` / `COVERING INDEX` tanpa temporary b-tree untuk pengurutan.
  - Migrasi idempoten v7 -> v8 lolos 100% pada uji migrasi beruntun v1 s.d. v8.

### Ditambahkan
- **Kebenaran Foto Data & Pengujian Gerbang Data (`test/fitur/gerbang_dan_misi_lengkap_test.dart`):**
  - 14 pengujian lengkap mencakup seluruh tipe syarat (`ada_data`, `aturan_data` mengabaikan kategori tak terpakai & mendeteksi `belum_dilabeli`, `periode_data` hari & bulan berbeda pada batas 23:30 WIB, `pernyataan`, `kuis_lulus`, `modul_selesai`).
  - Pembuktian syarat `ATAU` + pencabutan pernyataan (kembali terkunci bila dicabut).
  - Pembuktian pelajaran selesai TIDAK PERNAH terkunci ulang saat data dihapus.
  - Pembuktian urutan prasyarat pelajaran dan modul.
  - Pembuktian ambang kelulusan kuis 70% bilangan bulat murni (3/5 gagal, 4/5 lulus, 7/10 lulus, 6/10 gagal) dan rekor skor terbaik tidak tertimpa skor lebih rendah.
  - Pembuktian komposisi sifat total selalu tepat 100% (termasuk 3 bagian sama besar).
  - Pembuktian foto data kosong pengguna baru menghasilkan status terkunci ramah tanpa eksepsi null.
  - Peta rute pengisian lengkap untuk 9 objek syarat dan widget test tombol aksi pada kartu terkunci.
  - Pembuktian misi dilewati tidak membuka gerbang data yang membutuhkan data nyata.
- **Pemeriksa Konten Rusak & Seluruh Berkas Kurikulum (`test/fitur/pemeriksa_konten_rusak_test.dart` & `test/konten/pemeriksa_semua_konten_test.dart`):**
  - 12 uji terstruktur untuk konten rusak dengan rujukan nama berkas dan kolom galat yang jelas.
  - Pengujian otomatis memvalidasi seluruh 19 berkas `modul.json`, berkas pelajaran, dan `kamus.json` di `aset/konten/`.
  - Pemeriksa gaya bahasa non-judgmental (bebas kata menghakimi: boros, bodoh, malas, ceroboh, payah) dan pendeteksi kalimat > 25 kata serta istilah kamus yang belum terpakai.
  - Pembuktian penolakan jenis misi yang belum memiliki evaluator di `RegistriMisi`.
- **Klarifikasi Dependensi & Ikon:**
  - Penjelasan transparan bahwa `flutter_svg` tidak pernah dipasang/dipakai (penyebutan sebelumnya adalah kekeliruan laporan). Seluruh ikon menggunakan `lucide_icons_flutter: ^4.0.3`.
  - Bukti `git diff origin/main -- pubspec.yaml` hanya menambahkan deklarasi folder aset kurikulum.

---

## [0.6.0] - 2026-11-16 — Mesin Belajar (Tahap 4)

Tahap 4: Implementasi lengkap arsitektur Mesin Belajar (*Learning Engine*) Funda, mencakup pemutar materi micro-learning kartu berurutan, kuis akhir modul dengan nilai ambang 70% dan pengacak deterministik, misi praktik nyata yang berinteraksi langsung dengan data pengguna riil tanpa kata-kata menghakimi, gerbang data prasyarat dengan opsi pernyataan pengguna (*"Aku tidak punya ini"*), pembaca konten statis & kamus istilah interaktif (`{{istilah}}`), skema basis data versi 7 (4 tabel baru: `tabel_progres_pelajaran`, `tabel_hasil_misi`, `tabel_hasil_kuis`, `tabel_pernyataan`), petak Beranda reaktif *"Lanjut Belajar"*, serta pembuktian benchmark Beranda bebas N+1 pada 5.000 vs 20.000 transaksi.

### Ditambahkan
- **Skema Basis Data & Migrasi Bertingkat Skema v7 (`lib/data/basis_data.dart`):**
  - Tabel `tabel_progres_pelajaran`: mencatat status belajar (`belum`, `sedang`, `selesai`), indeks langkah terakhir yang dicapai, waktu mulai dan waktu penyelesaian.
  - Tabel `tabel_hasil_misi`: mencatat hasil eksekusi misi praktik per pelajaran (`selesai`, `dilewati`) beserta waktu selesai.
  - Tabel `tabel_hasil_kuis`: mencatat rekam jejak percobaan kuis per modul (skor persentase integer, status lulus/gagal, detail jawaban JSON, waktu selesai).
  - Tabel `tabel_pernyataan`: menyimpan klaim pengguna (mis. `tidak_punya_pengeluaran`, `tidak_punya_utang`) untuk membuka materi terkunci saat pengguna belum memiliki data riil terkait.
  - Migrasi idempoten v6 -> v7 aman dan teruji pada migrasi beruntun v1 hingga v7.
- **Logika Murni Perhitungan TDD (`lib/perhitungan/perhitungan_belajar.dart`):**
  - Evaluasi gerbang data prasyarat modul dan pelajaran (`evaluasiSyaratData`, `evaluasiGerbangData`, `evaluasiPetaModul`) dengan toleransi pernyataan `ATAU`.
  - Penilaian kuis modul berbasis bilangan bulat integer (`hitungSkorKuis`, ambang kelulusan 70%).
  - Pengacak bank soal kuis yang deterministik (`acakSoalDeterministik`).
  - Penentuan status belajar pelajaran (`tentukanStatusPelajaran`).
  - Analisis komposisi pengeluaran per sifat (`hitungKomposisiSifat`).
- **Pembaca Konten & Kamus Istilah (`lib/fitur/belajar/model/pembaca_konten.dart`):**
  - Pembaca aset JSON kurikulum bertingkat (`aset/konten/pemula/anggaran_arus_kas/modul.json`, `anggaran_arus_kas_1_2.json`, `anggaran_arus_kas_1_3.json`, dan stub 18 modul lainnya).
  - Pembaca `aset/konten/kamus.json` yang memuat 10 istilah keuangan dengan definisi ramah dan contoh konkret Rupiah.
  - Komponen `TeksDenganIstilah`: membedah tag `{{istilah}}` menjadi teks interaktif bergaris bawah putus-putus yang menampilkan dialog arti istilah saat diketuk.
- **Registri Misi & Umpan Balik Nyata (`lib/fitur/belajar/model/registri_misi.dart`):**
  - Pengecekan kondisi data riil pengguna (`ada_data`, `aturan_data`, `lihat_hitungan`).
  - Umpan balik yang objektif, mendidik, dan bebas kata-kata menghakimi (*non-judgmental*).
- **Antarmuka Pengguna & Navigasi Pembelajaran:**
  - `LayarBelajar` (Tab Navigasi Belajar): Peta belajar terstruktur dalam 3 tingkat (Pemula, Menengah, Lanjutan), indikator status modul, daftar pelajaran, tombol kuis, dan dialog syarat kurang bagi pelajaran terkunci.
  - `LayarPemutarPelajaran`: Alur bertahap micro-learning (Pemantik -> Konsep Inti -> Contoh Nyata -> Cek Paham -> Misi Praktik Nyata -> Umpan Balik Datamu -> Tindak Lanjut) dengan penanda kemajuan progress bar dan lencana draf.
  - `LayarKuisModul`: Kuis interaktif dengan umpan balik langsung per soal dan layar kelulusan modul.
  - Petak Beranda *"Lanjut Belajar"*: Memandu pengguna secara reaktif ke pelajaran yang sedang berjalan atau siap dipelajari.
- **Pengujian & Verifikasi Mutu:**
  - 204 dari 204 uji unit dan widget lulus 100% (`flutter test`).
  - 10 tangkapan layar lengkap tersimpan di `docs/tangkapan_layar/tahap_04/`.
  - Aksesibilitas skala teks 2.0x bebas overflow di seluruh layar baru.
  - `flutter analyze` 100% bersih tanpa peringatan.
- **Dokumentasi:**
  - Berkas baru `docs/format_konten.md` yang merinci skema JSON dan aturan penulisan kalimat <= 25 kata tanpa kata terlarang.
  - Pembaruan `docs/utang_teknis.md` dan `docs/kamus_penamaan.md`.

---

## [0.5.1] - 2026-11-16 — Revisi & Penutupan Tahap 3C (Tahap 3C-R)

Tahap 3C-R: Penutupan dan penyempurnaan resmi Tahap 3C meliputi revisi skema migrasi v6 (nominal tagihan opsional, kolom `jatuh_tempo_pertama` dan `berakhir_pada` inklusif), pembersihan logika murni jatuh tempo (dukungan pilihan pengingat {0, 1, 3, 7}, batas kedaluwarsa > 60 hari), penggabungan jadwal tagihan dengan cicilan utang bulanan (status baca-saja dan pembukaan detail utang), batasan deterministik jendela 45 hari dan maksimal 50 slot pengingat, mode penjadwalan `inexactAllowWhileIdle`, pendaftaran receiver boot Android, tombol pengingat uji debug 2 menit, serta dokumentasi rasio kontras warna dan tolok ukur benchmark di emulator Android API 36.

### Ditambahkan & Diperbaiki
- **Skema Basis Data & Migrasi Bertingkat Skema v6 (`lib/data/basis_data.dart`):**
  - Kolom `jumlah_perkiraan_rupiah` di `tabel_tagihan` kini opsional (nullable), memungkinkan pencatatan tagihan yang nominalnya berubah-ubah tiap bulan (misal tagihan listrik pascabayar/air).
  - Kolom `jatuh_tempo_pertama` (DateTime) sebagai acuan awal perhitungan kemunculan, mencegah munculnya kemunculan lewat palsu saat tagihan baru dibuat.
  - Kolom `berakhir_pada` (DateTime opsional, inklusif) untuk menentukan batas akhir tagihan berkala.
  - Migrasi idempoten v5 -> v6 dengan pengisian default nilai `jatuh_tempo_pertama` dari `dibuat_pada` untuk data lama.
- **Logika Murni Perhitungan TDD (`lib/perhitungan/perhitungan_tagihan.dart`, `perhitungan_utang_dashboard.dart`):**
  - Fungsi `serialisasiHariPengingat` dan `uraiHariPengingat` tangguh terhadap masukan kotor, menyaring nilai hanya pada `{0, 1, 3, 7}`, membuang duplikat, dan mengurutkan menaik.
  - Kemunculan jatuh tempo lewat lebih dari 60 hari (`selisihHari < -60`) otomatis ditandai `lewatKedaluwarsa` dan diabaikan dari daftar aktif pengingat.
  - Fungsi murni `gabungkanJadwal(tagihan, utang)` menggabungkan entri tagihan aktif dan cicilan utang aktif bulanan; cicilan utang berstatus baca-saja dan otomatis berstatus `dibayar` bila terdapat pembayaran utang pada bulan kalender yang bersangkutan.
  - Fungsi `rencanakanPengingat` membatasi jadwal pada rentang maksimal 45 hari ke depan dan maksimal 50 total pengingat terdekat untuk mencegah kepenuhan antrean OS.
  - Pengubahan nama konstanta menjadi `ambangRasioCicilanAturanPraktis = 30; // TODO-VERIFIKASI`.
- **Integrasi Android & Layanan Pengingat Nyata:**
  - Pendaftaran `ScheduledNotificationReceiver` dan `ScheduledNotificationBootReceiver` di `android/app/src/main/AndroidManifest.xml` bersama izin `RECEIVE_BOOT_COMPLETED`.
  - Mode penjadwalan diatur ke `AndroidScheduleMode.inexactAllowWhileIdle` agar alarm dapat membangunkan perangkat saat Doze mode tanpa izin sensitif exact alarm.
  - Tombol uji debug "Jadwalkan Pengingat Uji (2 Menit Lagi)" di Layar Pengaturan di bawah penjaga `kDebugMode`.
- **Penyempurnaan Antarmuka Pengguna Soft Bento:**
  - Form Tagihan: Teks bantuan ramah *"Kosongkan jika nominal berubah-ubah tiap bulan."* saat nominal tidak diisi.
  - Layar Jadwal Tagihan: Tampilan hero ringkasan menyertakan keterangan *"N tagihan belum ada perkiraan"*, serta kartu cicilan utang dilengkapi badge "Cicilan Utang" dan tombol "Bayar" yang mengarahkan langsung ke rute detail utang terkait.
  - Layar Pengaturan: Ditambahkan catatan edukasi transparan mengenai jendela 45 hari dan batas 50 pengingat.
- **Pengujian & Verifikasi:**
  - 180 uji otomatis lulus 100% (`flutter test`).
  - Verifikasi benchmark di emulator Pixel 8 (Android 16, API 36) pada volume 20.000 transaksi + 20 utang + 20 tagihan: Halaman pertama riwayat (50 baris) Median = 14.67 ms (Terburuk = 18.72 ms, 1 kueri SQL); Agregasi Beranda Median = 0.91 ms (Terburuk = 1.38 ms, 2 kueri SQL).
  - Verifikasi kontras warna `tintMawar` (#FCE7F3) terhadap teks utama (#0F1F1D) sebesar 14.5:1 (memenuhi WCAG AAA).

---

## [0.5.0] - 2026-11-15 — Tagihan Berulang & Pengingat Lokal (Tahap 3C)

Tahap 3C: Menutup Tahap 3 secara tuntas meliputi Pengelolaan Tagihan Rutin & Langganan (mingguan, bulanan, tahunan), Jadwal Jatuh Tempo Dinamis (penanganan akhir bulan kabisat 28/29 Feb), Pembayaran Tagihan Atomik tertaut Transaksi Pengeluaran, Layanan Pengingat Lokal Ramah Baterai (Inexact Alarm, Boot Receiver, Timezone), Layar Pengaturan Pengingat & Privasi Nominal, serta Petak Bento Tagihan Terdekat di Beranda.

### Ditambahkan
- **Skema Basis Data & Migrasi Bertingkat Skema v5 (`lib/data/basis_data.dart`):**
  - Tabel `tabel_tagihan`: id, nama, jenis (`tagihan_rutin`, `langganan`), jumlah_rupiah (int > 0), frekuensi (`mingguan`, `bulanan`, `tahunan`), hari_dalam_minggu (1-7), tanggal_dalam_bulan (1-31), bulan_dalam_tahun (1-12), dompet_id, kategori_id, pengingat_hari_sebelumnya (teks daftar integer dipisah koma, misal "0,1,3"), aktif (boolean), diarsipkan, dibuat_pada.
  - Tabel `tabel_pembayaran_tagihan`: id, tagihan_id, tanggal_jatuh_tempo, status (`sudah_dibayar`, `dilewati`), transaksi_id (opsional, onDelete: Cascade), waktu_dibayar, dibuat_pada. Unik (tagihan_id, tanggal_jatuh_tempo).
  - Indeks komposit `idx_tagihan_aktif_diarsipkan` pada `(aktif, diarsipkan)` untuk kueri cepat tagihan aktif.
  - Indeks komposit `idx_pembayaran_tagihan_jatuh_tempo` pada `(tagihan_id, tanggal_jatuh_tempo)` untuk pengecekan status periode.
  - Verifikasi otomatis `PRAGMA foreign_keys = ON` pada callback `beforeOpen` database.
- **Logika Murni Perhitungan TDD (`lib/perhitungan/perhitungan_tagihan.dart`):**
  - `hitungJatuhTempoDalamRentang`: Algoritma cerdas yang menghasilkan jadwal jatuh tempo mingguan, bulanan, dan tahunan dalam rentang tanggal tertentu, menangani kasus batas akhir bulan (seperti tagihan tanggal 31 di bulan Februari/April yang otomatis menyesuaikan ke hari terakhir bulan, kabisat 29 Feb -> 28 Feb pada tahun non-kabisat).
  - `tentukanStatusJatuhTempo`: Menentukan status jatuh tempo spesifik (`terlewat`, `hariIni`, `akanDatang`) relatif terhadap hari ini.
  - `hitungRingkasanTagihanBulan`: Menghitung total tagihan aktif, total nominal jatuh tempo bulan berjalan, total yang sudah dibayar, total yang belum dibayar, dan jumlah tagihan yang lewat jatuh tempo.
  - `hitungRencanaPengingat`: Menghitung daftar waktu notifikasi yang perlu dijadwalkan secara deterministik berdasarkan preferensi hari sebelumnya dan jam notifikasi pengguna.
- **Layanan Pengingat Lokal Ramah Baterai (`lib/layanan/layanan_pengingat.dart`):**
  - Kontrak antarmuka `LayananPengingat`, implementasi uji `LayananPengingatPalsu`, dan implementasi riil `LayananPengingatNyata` (`flutter_local_notifications: ^22.3.3`, `timezone: ^0.11.2`, `flutter_timezone: ^5.1.1`).
  - Penjadwalan *inexact* (`androidScheduleMode: AndroidScheduleMode.inexact`) yang hemat daya dan tidak membutuhkan izin sensitif `USE_EXACT_ALARM` atau `SCHEDULE_EXACT_ALARM`.
  - Dukungan `RECEIVE_BOOT_COMPLETED` di Android untuk sinkronisasi ulang pengingat otomatis pasca perangkat dinyalakan ulang.
  - Penanganan payload rute (`/tagihan`) saat notifikasi ditekan.
  - Permintaan izin notifikasi Android 13+ ditunda (*just-in-time*), hanya saat pengguna mengaktifkan saklar pengingat di Layar Pengaturan.
- **Repositori & State Management Riverpod (`lib/data/repositori/tagihan_repositori.dart`, `penyedia_tagihan.dart`, `penyedia_pengaturan.dart`):**
  - CRUD master tagihan, jeda/aktifkan tagihan, dan pengarsipan tagihan.
  - `tandaiTagihanDibayar`: Pencatatan transaksi pengeluaran dan status `sudah_dibayar` secara atomik di dalam satu blok transaksi database.
  - `tandaiTagihanDilewati`: Menandai tagihan periode tertentu dilewati tanpa mencatat transaksi pengeluaran.
  - `batalkanPenandaanPeriode`: Membatalkan penandaan status periode, menghapus entri pembayaran, dan menghapus transaksi tertaut secara otomatis via foreign key cascade.
  - `ambilJadwalGabungan`: Kueri gabungan cerdas jadwal jatuh tempo tagihan aktif beserta status bayar/lewati per periode.
  - `sinkronkanPengingat`: Penjadwalan ulang seluruh pengingat yang relevan ke layanan pengingat sesuai status saklar, jam, dan privasi nominal pengguna.
  - Notifier Riverpod untuk pengaturan pengingat (`penyediaPengingatAktif`, `penyediaJamPengingat`, `penyediaTampilkanNominalNotifikasi`).
- **Antarmuka Pengguna Soft Bento Baru:**
  - **Layar Jadwal Tagihan (`layar_jadwal_tagihan.dart`):** Navigasi pemilih bulan, Hero ringkasan total tagihan & nominal jatuh tempo bulan terpilih, pengelompokan rapi (Perlu Perhatian, Akan Datang, Sudah Ditandai), aksi sekali ketuk untuk menandai dibayar atau lewati, serta tombol ke daftar master tagihan.
  - **Layar Master Tagihan (`layar_semua_tagihan.dart`):** Daftar seluruh tagihan, saklar jeda/aktifkan, menu kelola (ubah, arsipkan, hapus permanen), dan FAB tambah tagihan.
  - **Layar Form Tagihan (`layar_form_tagihan.dart`):** Input jenis (tagihan rutin/langganan), nama, nominal, frekuensi, pemilih hari/tanggal, multi-select chip pengingat (H-3, H-1, Hari H), pemilih dompet & kategori, serta banner peringatan informatif bila pengingat sistem sedang nonaktif.
  - **Layar Pengaturan (`layar_pengaturan.dart`):** Saklar aktivasi pengingat lokal, pemilih jam pengingat (`showTimePicker`), saklar privasi nominal pada teks notifikasi, dan catatan edukatif transparan mengenai jadwal ramah baterai.
  - **Petak Bento Tagihan Terdekat di Beranda (`layar_beranda.dart`):** Petak Bento berdimensi 2x1 yang menampilkan tagihan terdekat (jatuh tempo dalam 7 hari ke depan atau sudah terlewat) sebelum 5 Transaksi Terakhir, dengan indikator status warna dan tombol bayar langsung.
  - **Integrasi Pembayaran Form Transaksi (`layar_form_transaksi.dart`):** Prefill otomatis nominal, dompet, dan kategori saat membayar tagihan dari jadwal atau petak beranda, serta penandaan atomik status tagihan terbayar saat formulir disimpan.
  - **Layar Menu Lainnya (`layar_lainnya.dart`):** Ditambahkan menu akses cepat "Tagihan & Langganan" dan "Pengaturan".
- **Pengujian & Verifikasi:**
  - Uji foreign key cascade SQLite dan pembuktian pragma ON (`test/data/foreign_key_test.dart`).
  - Uji atomisitas transaksi, urungkan, sinkronisasi sisa utang dinamis, penolakan pembayaran lebih, dan waktu muat Beranda bebas N+1 (`test/data/bukti_uji_tahap_03b_lengkap_test.dart`).
  - Uji migrasi beruntun skema v1 hingga v5 (`test/data/migrasi_beruntun_test.dart`).
  - Uji skala teks 2.0x pada seluruh layar baru tagihan dan pengaturan tanpa overflow (`test/fitur/tagihan_skala_teks_test.dart`, `test/fitur/skala_teks_membesar_test.dart`).
  - 100% kelulusan uji suite proyek (168/168 tests passed) dan 0 isu pada `flutter analyze`.
  - 6 tangkapan layar baru tersimpan di `docs/tangkapan_layar/tahap_03c/`.

---

## [0.4.0] - 2026-11-15 — Utang, Kekayaan Bersih & Dashboard (Tahap 3B)

Tahap 3B: Pengelolaan Utang & Kewajiban (kartu kredit, paylater, KPR, kendaraan, pinjol, pribadi), Pencatatan Pembayaran Utang Atomik tertaut Transaksi, Penyesuaian Sisa Utang 2 Arah, Evaluasi Rasio Cicilan Bulanan, Perhitungan Kekayaan Bersih (Aset - Utang), serta Dashboard Penuh Soft Bento di Beranda.

### Ditambahkan
- **Skema Basis Data & Migrasi Bertingkat Skema v4 (`lib/data/basis_data.dart`):**
  - Tabel `tabel_utang`: id, nama, jenis (`kartu_kredit`, `paylater`, `kpr`, `kendaraan`, `pinjaman_online`, `pinjaman_pribadi`, `lainnya`), pokok_awal_rupiah (int > 0), sisa_awal_rupiah (int > 0), bunga_basis_poin (int >= 0, 100 bp = 1%, tanpa tipe `double`), jenis_bunga (`tetap`, `efektif`, `tanpa_bunga`), tenor_bulan (int > 0), cicilan_bulanan_rupiah (int >= 0), tanggal_jatuh_tempo (1-31), status (`aktif`, `lunas`), diarsipkan, dibuat_pada.
  - Tabel `tabel_pembayaran_utang`: id, utang_id, transaksi_id (unik, onDelete: Cascade), dibuat_pada. Menjamin pembayaran utang selalu atomik dan sinkron dengan transaksi pengeluaran.
  - Tabel `tabel_penyesuaian_utang`: id, utang_id, arah (`tambah`, `kurang`), jumlah_rupiah (int > 0), catatan, waktu, dibuat_pada.
  - Indeks komposit `idx_utang_status_diarsipkan` pada `(status, diarsipkan)` untuk kueri cepat utang aktif.
- **Logika Murni Perhitungan TDD (`lib/perhitungan/perhitungan_utang_dashboard.dart`):**
  - `hitungSisaUtang`: Sisa awal dikurangi total pembayaran ditambah penyesuaian tambah dikurangi penyesuaian kurang. Sisa utang tidak disimpan statis.
  - `hitungKekayaanBersih`: Total saldo semua dompet aktif dikurangi total sisa utang aktif. Mendukung nilai negatif dengan pesan menguatkan yang ramah tanpa kepanikan.
  - `hitungRasioCicilan`: Persentase integer total cicilan bulanan terhadap rata-rata pemasukan 3 bulan terakhir yang selesai. Dilengkapi konstanta `ambangBatasRasioCicilanSehat = 30` (TODO-VERIFIKASI) yang belum digunakan untuk menghakimi aman/bahaya di antarmuka.
  - `hitungPemasukanBulananRataRata`: Algoritma cerdas yang menghitung rata-rata dari 3 bulan kalender terakhir yang sudah selesai, dengan fallback ke bulan berjalan bila belum ada data lampau.
  - `konversiBasisPoinKePersen`: Format representasi persen dari basis poin (misal 1500 bp = "15%").
  - `pilihTujuanTerdekat`: Memilih tujuan non-darurat dengan progres dana tertinggi di bawah 100% untuk ditampilkan di Beranda.
- **Repositori & State Management Riverpod (`lib/data/repositori/utang_repositori.dart`, `penyedia_utang.dart`):**
  - `catatPembayaranUtang`: Transaksi database atomik yang serentak mencatat `tabel_transaksi` pengeluaran dan `tabel_pembayaran_utang`.
  - Otomatisasi status `lunas` saat sisa utang mencapai Rp 0 dan kembali `aktif` bila pembayaran dibatalkan/dihapus via foreign key cascade.
  - Penyesuaian sisa utang 2 arah (menambah/mengurangi beban utang).
  - Paginasi kursor stabil `ambilTransaksiKursor` berbasis komposit `(waktu_transaksi, id)` yang terbukti imun dari duplikasi atau baris terlewat saat ada penambahan/penghapusan data.
  - Uji kesetaraan agregasi SQL vs fungsi murni Dart lulus identik 100% pada data acak (`test/data/repositori_utang_test.dart`).
- **Antarmuka Pengguna Soft Bento Baru:**
  - **Layar Beranda Penuh:** 8-9 Petak Bento modular (Arus Kas Bulan Ini, Total Saldo, Kekayaan Bersih, Sisa Anggaran, Dana Darurat, Rasio Cicilan, Tujuan Terdekat, Lanjut Belajar bertanda jelas, 5 Transaksi Terakhir). Responsif pada skala teks 2.0 (susun bertumpuk saat teks besar).
  - **Layar Daftar Utang (`layar_daftar_utang.dart`):** Hero total sisa utang aktif, total cicilan bulanan, rasio cicilan, daftar utang aktif vs lunas terpisah, dan FAB catat utang.
  - **Layar Form Utang (`layar_form_utang.dart`):** Input jenis utang, pokok, sisa awal, bunga basis poin, tenor, cicilan per bulan, dan tanggal jatuh tempo bulanan.
  - **Layar Detail Utang (`layar_detail_utang.dart`):** Hero sisa utang, pesan hangat kelulusan tanpa gamifikasi berlebih, modal catat pembayaran atomik, modal penyesuaian sisa, riwayat pembayaran & penyesuaian, dan opsi arsip.
  - **Layar Kekayaan Bersih (`layar_kekayaan_bersih.dart`):** Hero kekayaan bersih, nada menguatkan saat negatif, rincian per dompet aktif vs per utang aktif.
  - **Integrasi Form Transaksi (`layar_form_transaksi.dart`):** Pemilih utang aktif saat kategori bertipe `utang`, mencatat pembayaran utang secara atomik.
  - **Layar Lainnya (`layar_lainnya.dart`):** Menu akses cepat "Utang & Cicilan", "Kekayaan Bersih", dan "Daftar Dompet".
- **Aksesibilitas & Pengujian:**
  - Uji skala teks 2.0 pada seluruh 12 layar utama aplikasi tanpa teks terpotong atau overflow (`test/fitur/aksesibilitas_skala_teks_tahap_03b_test.dart`).
  - Uji paginasi kursor deterministik (`test/data/paginasi_transaksi_test.dart`).
  - Uji benchmark performa bersih 1x pemanasan + 5 iterasi pada 5.000 dan 20.000 transaksi (`test/performa/benchmark_tahap_03b_test.dart`).
  - 9 tangkapan layar PNG di `docs/tangkapan_layar/tahap_03b/`.

---

## [0.3.0] - 2026-11-15 — Anggaran, Tujuan & Kantong (Tahap 3A)

Tahap 3A: Pengelolaan Anggaran Bulanan per kategori, Sistem Kantong Dompet (mental accounting / envelope budgeting lokal tanpa pemindahan dana riil), Tujuan Finansial (Tabungan, Dana Darurat, Tujuan Besar), serta optimalisasi performa paginasi riwayat dan agregasi SQL.

### Ditambahkan
- **Skema Basis Data & Migrasi Bertingkat Skema v3 (`lib/data/basis_data.dart`):**
  - Tabel `tabel_anggaran`: id, tahun, bulan (1-12), kategori_id, batas_rupiah (int > 0), dibuat_pada, diubah_pada. Unik (tahun, bulan, kategori_id).
  - Tabel `tabel_tujuan`: id, nama, jenis (`tabungan`, `dana_darurat`, `tujuan_besar`, `lainnya`), target_rupiah (int > 0), tenggat, ikon, warna, status (`aktif`, `tercapai`, `batal`), dibuat_pada. Integritas sistem: maksimal hanya satu tujuan `dana_darurat` berstatus aktif.
  - Tabel `tabel_kantong`: id, nama, dompet_id, tujuan_id (opsional), ikon, warna, diarsipkan, dibuat_pada. Unik (dompet_id, tujuan_id) untuk kantong tertaut tujuan via indeks parsial SQLite.
  - Tabel `tabel_alokasi_kantong`: id, kantong_id, jenis (`isi`, `ambil`, `penyesuaian`), jumlah_rupiah (int > 0), catatan, waktu, dibuat_pada.
- **Logika Murni Perhitungan TDD (`lib/perhitungan/perhitungan_anggaran_tujuan.dart`):**
  - `hitungRealisasiAnggaran`: Evaluasi batas vs riil pengeluaran dengan status `aman` (< 80%), `mendekati` (80-100%), atau `melewati` (> 100%).
  - `hitungRingkasanAnggaran`: Menghitung total batas anggaran, total terpakai, total sisa, dan persentase keseluruhan.
  - `hitungSaldoKantong`: Akumulasi alokasi isi - ambil +/- penyesuaian untuk satu kantong.
  - `hitungSaldoBebasDompet`: Saldo dompet riil dikurangi total seluruh saldo kantong di dompet tersebut.
  - `hitungSetoranBulananDibutuhkan`: Hitung setoran bulanan target tujuan dengan integer ceiling division murni tanpa tipe `double`.
  - `hitungProgresTujuan`: Persentase progres dana terkumpul terhadap target tujuan (dibatasi 0-100%).
  - `validasiAlokasiKantong`: Validasi pengambilan dana tidak boleh melebihi saldo kantong saat ini.
- **Repositori & State Management Riverpod (`lib/fitur/*/kontroler/`):**
  - Pemecahan `penyedia_data.dart` menjadi penyedia independen per domain fitur (`kontroler/`).
  - `AnggaranRepositori`: Atur anggaran per kategori, salin anggaran dari bulan sebelumnya, dan kueri realisasi bulanan via SQL JOIN.
  - `TujuanRepositori`: CRUD tujuan dengan validasi database 1 dana darurat aktif, pemantauan progres dan kantong tertaut.
  - `KantongRepositori`: Buat kantong bebas & tertaut tujuan, alokasi dana (isi/ambil) dengan validasi saldo, serta pencegahan pengarsipan kantong yang bersaldo > Rp 0.
- **Optimasi Performa & Aksesibilitas:**
  - Paginasi 50 item dan filter `WHERE` langsung di level SQL pada Layar Catatan dan Riwayat Dompet.
  - Subjumlah harian SQL dengan agregasi `customSelect`.
  - Agregasi SQL teruji identik 100% dengan fungsi Dart murni pada data acak via `test/perhitungan/kesetaraan_sql_test.dart`.
  - Benchmark performa 5.000 dan 20.000 transaksi di `test/performa/performa_tahap_03a_test.dart`: halaman pertama riwayat ~2ms, saldo dompet ~10ms, arus kas ~2ms (< batas aman 200ms).
  - Aksesibilitas: Semantics lengkap pada petak bento, tombol aksi, dan pengujian skala teks 2.0 tanpa teks terpotong atau overflow.
- **Antarmuka Pengguna Soft Bento Baru:**
  - Layar Anggaran (`layar_anggaran.dart`): Navigasi bulan, hero ringkasan sisa anggaran, baris progres kategori dikelompokkan 4 sifat pengeluaran, status warna (hijau/kuning/merah), tombol salin dari bulan lalu, dan dialog atur batas anggaran.
  - Layar Daftar & Detail Tujuan (`layar_daftar_tujuan.dart`, `layar_detail_tujuan.dart`, `layar_form_tujuan.dart`): Target progres %, setoran bulanan yang dibutuhkan, tombol isi/ambil dana lintas dompet, riwayat alokasi kantong tujuan, dan status tercapai.
  - Layar Kantong (`layar_daftar_kantong.dart`): Teks edukasi kejelasan mental accounting ("Ini hanya penandaan. Uangmu tidak berpindah antar rekening"), pemilih dompet, saldo bebas, aksi isi/ambil kantong bebas, dan arsipkan kantong kosong.
  - Integrasi Data Nyata Beranda: Petak Bento Sisa Anggaran Bulan Ini dan Tujuan Terdekat terhubung langsung ke basis data lokal.
  - 9 tangkapan layar PNG di `docs/tangkapan_layar/tahap_03a/`.
  - Dokumentasi utang teknis di `docs/utang_teknis.md`.

---

## [0.2.0] - 2026-11-15 — Dompet & Transaksi

Tahap 2: Pengelolaan dompet multi-akun, sistem kategori 4 sifat pengeluaran, pencatatan transaksi masuk/keluar/transfer/penyesuaian, perhitungan murni keuangan reaktif, dan antarmuka Soft Bento.

### Ditambahkan
- **Skema Basis Data & Migrasi Skema v2 (`lib/data/basis_data.dart`):**
  - Tabel `tabel_dompet`: id, nama, jenis (`tunai`, `rekening_bank`, `e_wallet`, `lainnya`), ikon, warna (token tint), saldo awal rupiah (int >= 0), urutan, diarsipkan, dibuat_pada.
  - Tabel `tabel_kategori`: id, nama, arus (`masuk`, `keluar`), sifat (`kebutuhan`, `keinginan`, `tabungan`, `utang`, `belum_dilabeli`, `tidak_berlaku`), ikon, bawaan, diarsipkan.
  - Tabel `tabel_transaksi`: id, jenis (`masuk`, `keluar`, `transfer`, `penyesuaian_masuk`, `penyesuaian_keluar`), jumlah rupiah (int > 0), dompet_id, dompet_tujuan_id, kategori_id, biaya_admin_rupiah, catatan, waktu_transaksi, dibuat_pada, diubah_pada dengan indeks pada `waktu_transaksi` dan `dompet_id`.
  - Seeder idempoten 25 kategori bawaan sistem (`lib/data/seeder/kategori_bawaan.dart`).
- **Logika Murni Perhitungan Keuangan TDD (`lib/perhitungan/perhitungan_keuangan.dart`):**
  - `hitungSaldoDompet`: Menghitung saldo berjalan murni dari baris transaksi (saldo awal + masuk - keluar + penyesuaian masuk - penyesuaian keluar + transfer masuk - transfer keluar - biaya admin). Saldo tidak disimpan statis.
  - `hitungPenyesuaianSaldo`: Otomatis menghitung jenis penyesuaian (masuk/keluar) dan nominal selisih dari saldo riil pengguna.
  - `hitungArusKas`: Menghitung total pemasukan, pengeluaran, dan selisih untuk rentang waktu tertentu. Biaya admin transfer dihitung sebagai pengeluaran, perpindahan dana transfer murni tidak memengaruhi arus kas masuk/keluar.
  - `hitungTotalSaldo`: Akumulasi saldo seluruh dompet aktif (mengabaikan dompet diarsipkan).
  - `validasiTransaksi`: Validasi nominal > 0 dan <= 999.999.999.999, pencegahan transfer ke dompet yang sama, kewajiban kategori untuk masuk/keluar dengan pesan bahasa Indonesia ramah.
  - `ambilTanggalLokalPerangkat`: Normalisasi waktu UTC ke tanggal lokal perangkat untuk pengelompokan riwayat per hari.
- **Lapisan Repositori & State Management Reaktif Riverpod (`lib/data/`):**
  - `DompetRepositori`: Operasi tambah, ubah, arsipkan/pulihkan, serta pencegahan hapus permanen jika memiliki transaksi terkait.
  - `KategoriRepositori`: Tambah kategori kustom, ubah sifat kategori bawaan, arsipkan, serta proteksi penghapusan kategori bawaan/terpakai.
  - `TransaksiRepositori`: Tambah, ubah, dan hapus transaksi dengan pengembalian urungkan (undo).
  - Stream providers reaktif Drift: `penyediaDaftarDompet`, `penyediaDaftarDompetAktif`, `penyediaDaftarKategori`, `penyediaDaftarTransaksi`, `penyediaPetaSaldoDompet`, `penyediaTotalSaldoAktif`, `penyediaArusKasBulanIni`.
- **Antarmuka Pengguna Soft Bento (`lib/fitur/`):**
  - Layar Form Dompet (`layar_form_dompet.dart`): Pemilihan jenis, ikon Lucide, palet token tint, saldo awal Rupiah, dan peringatan lembut jika mengubah saldo awal dompet yang sudah bertransaksi.
  - Layar Detail Dompet (`layar_detail_dompet.dart`): Saldo berjalan, dialog sesuaikan saldo otomatis, riwayat transaksi khusus dompet, tombol arsip/pulihkan, dan opsi hapus dompet kosong.
  - Layar Daftar Dompet (`layar_daftar_dompet.dart`): Kartu ringkasan total saldo, daftar dompet aktif dan diarsipkan, serta keadaan kosong ramah.
  - Layar Kategori (`layar_daftar_kategori.dart`): Tab pengeluaran dan pemasukan, pengelompokan 4 sifat pengeluaran dengan warna dan ikon makna, penanda lembut pos "belum dilabeli", dialog penambahan kategori kustom, dialog pengubahan sifat, dan pengarsipan.
  - Layar Form Transaksi (`layar_form_transaksi.dart`): Segmen Masuk/Keluar/Transfer, input nominal besar otomatis format Rupiah, pintasan nominal (+10rb, +50rb, +100rb, +500rb), filter chip kategori berdasarkan arus, biaya admin transfer, pemilih tanggal/waktu ramah, dan peringatan lembut jika saldo dompet menjadi minus.
  - Layar Catatan (`layar_catatan.dart`): Riwayat transaksi dikelompokkan per hari lokal dengan subjumlah harian, bilah pencarian catatan & kategori, lembar bawah filter multi-kriteria dengan badge aktif dan reset filter, serta dialog konfirmasi hapus dengan SnackBar "Urungkan".
  - Layar Beranda (`layar_beranda.dart`): Integrasi data nyata untuk Total Saldo Dompet Aktif dan Hero Arus Kas Bulan Ini.
- **Pembersihan & Pengujian:**
  - Migrasi dependensi `sqlite3_flutter_libs: ^0.5.24` (terpasang 0.5.42) dengan binary native Android lengkap.
  - Akses Galeri Komponen debug-only (`kDebugMode`) pada rute `/galeri`, banner Beranda, dan kartu Lainnya.
  - Berkas lisensi font SIL Open Font License disimpan di `aset/font/OFL.txt`.
  - Audit kode: 0 warna hard-coded di luar `lib/tema/token.dart`.
  - Pengujian performa dengan 5.000 transaksi dummy: kueri ~126ms, perhitungan saldo murni ~0,39ms (< 50ms).
  - 58 pengujian otomatis (unit, widget, repositori, migrasi bertingkat, dan performa) dengan tingkat kelulusan 100%.

---

## [0.1.0] - 2026-11-15 — Fondasi

Tahap 1: Pembentukan fondasi proyek aplikasi Flutter Funda yang siap dibangun fitur di atasnya.

### Ditambahkan
- Inisialisasi proyek Flutter untuk platform Android dan iOS dengan nama paket `funda` dan nama tampilan **Funda**.
- Struktur folder lengkap sesuai panduan `agent.md` bagian 4.
- Token tema lengkap (`lib/tema/token.dart`): `WarnaFunda`, `SpasiFunda`, `SudutFunda`, `TipografiFunda` sesuai panduan gaya `styleguide.md`.
- `ThemeData` Material 3 (`lib/tema/tema.dart`) terikat ke token tema.
- Bundel font lokal **Plus Jakarta Sans** (Regular, SemiBold, Bold) di `aset/font/` yang bekerja penuh secara luring (offline).
- Komponen dasar antarmuka Soft Bento (`lib/komponen/`):
  - `PetakBento`: Ukuran 1x1 dan 2x1, latar tint pastel, mikro-animasi ketukan, dan label aksesibilitas `Semantics`.
  - `TombolFunda`: Varian primer, sekunder, teks; status normal, ditekan, nonaktif, memuat; tinggi target sentuh minimal 48dp.
  - `TeksFunda`: Varian angkaBesar, judulLayar, judulBagian, isi, isiKecil, label, catatan dengan dukungan angka tabular.
  - `KeadaanKosong`: Wadah ikon ber-tint, satu kalimat arahan ramah tanpa menghakimi, dan satu tombol aksi.
  - `PembungkusLayar`: SafeArea dan margin standar 16dp.
- Layar khusus pengembangan **Galeri Komponen UI** (`/galeri`) untuk memverifikasi seluruh komponen dan token.
- Navigasi 4 tab berbasis `go_router` (`StatefulShellRoute`): Beranda, Catatan, Belajar, Lainnya.
- Penyiapan state management `flutter_riverpod` dengan `ProviderScope`.
- Basis data lokal SQLite via `drift` + `sqlite3_flutter_libs` dengan mekanisme migrasi bertingkat yang aman diulang (idempotent) dan skema awal `tabel_pengaturan`.
- Fungsi murni utilitas Rupiah (`lib/util/format_rupiah.dart`): `formatRupiah` dan `ambilAngkaRupiah` berbasis bilangan bulat (`int`), tanpa pecahan desimal `double`.
- Pengujian unit dan widget lengkap (23 pengujian) untuk utilitas Rupiah, migrasi basis data, `TombolFunda`, dan `PetakBento`.
- Kamus penamaan kode bahasa Indonesia (`docs/kamus_penamaan.md`).
- Dokumentasi `README.md` dan salinan panduan arsitektur di `docs/`.
