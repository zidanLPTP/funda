# Catatan Perubahan (Changelog) Funda

Semua perubahan penting pada proyek Funda akan dicatat di dalam dokumen ini.
Format penulisan mengacu pada standar Keep a Changelog dan penamaan commit Funda.

---

## [0.13.1] - 2026-11-23 — Tahap 8D-R: Revisi & Penyelarasan Lampiran Modul 6

Tahap 8D-R menuntaskan seluruh revisi dan penyelarasan lampiran resmi reviewer untuk Modul 6 ("Psikologi Uang & Kebiasaan Belanja"):
- **Penyelarasan Judul & Durasi Pelajaran (Butir A):** Menyelaraskan berkas konten JSON persis ke judul dan durasi resmi lampiran:
  - `psikologi_uang_6_1`: judul `"Kenapa Kita Belanja Impulsif?"`, durasi `5` menit.
  - `psikologi_uang_6_2`: judul `"Langganan dan Pengeluaran Diam-Diam"`, durasi `5` menit.
  - `psikologi_uang_6_3`: judul `"Aturan Jeda Sebelum Membeli"`, durasi `5` menit, `aturanPraktis: true`, dan `catatanReviewer` persis teks lampiran (`"TODO-VERIFIKASI. Aturan jeda (menunggu 24 jam atau beberapa hari sebelum membeli keinginan) adalah teknik perilaku populer di literasi keuangan; periksa kecocokan redaksinya sebagai pedoman fleksibel."`).
- **Penyelarasan Kesesuaian Lampiran & Uji Unit (Butir A & B):**
  - Memperluas `test/konten/kesesuaian_lampiran_test.dart` untuk memverifikasi secara ketat judul, durasi, dan teks `catatanReviewer` terhadap markdown lampiran resmi.
  - Memperbaiki kutipan laporan dan menegaskan implementasi `formatRingkasanLanggananDanKeinginan` sesuai prompt Bagian 2.2, dengan assertion string lengkap pada vektor V1 sampai V5 di `test/perhitungan/perhitungan_umpan_balik_tahap_08d_test.dart`.
- **Pengujian Integrasi Emulator & Otomasi Runner (Butir C):**
  - Memperbaiki parsing deteksi device ID pada skrip `tool/jalankan_test_dan_tangkapan_layar_tahap_08d.ps1`.
  - Menyiapkan berkas batch launcher interaktif `tool/buka_terminal_tahap_08d.bat` untuk menjalankan pengujian integrasi di jendela terminal baru pengguna.
- **Verifikasi Bukti Analisis & Pengujian Penuh (Butir D):**
  - Menyimpan keluaran lengkap `flutter analyze` ke `docs/bukti/tahap_08d_r_flutter_analyze.txt` (bersih tanpa galat).
  - Menyimpan keluaran lengkap `flutter test --reporter expanded` ke `docs/bukti/tahap_08d_r_flutter_test.txt` (537 pengujian lulus 100%).

---

Tahap 8D menuntaskan seluruh kurikulum Tingkat Pemula (Modul 0 sampai Modul 6) dengan mengimplementasikan Modul 6 ("Psikologi Uang & Kebiasaan Belanja": 3 pelajaran, 1 kuis 5 dari 10 bankSoal sebaran 4/3/3, 4 entri kamus baru), tipe misi baru `refleksi` (jawaban teks privat tersimpan lokal di perangkat pengguna), satu fungsi murni umpan balik baru `ringkasan_langganan_dan_keinginan`, penutupan seluruh kurikulum Pemula pada petak Beranda, pengujian unit murni TDD, evaluasi registri misi, pengujian widget, benchmark beban komputasi Tab Belajar, dan pengujian integrasi E2E emulator.

### Ditambahkan & Diselaraskan
- **Tipe Misi Baru `refleksi` (`lib/perhitungan/perhitungan_belajar.dart`, `lib/fitur/belajar/model/registri_misi.dart`, `lib/fitur/belajar/tampilan/layar_pemutar_pelajaran.dart`):**
  - Misi berbasis refleksi tulisan privat yang hanya tersimpan di perangkat pengguna (`tabel_hasil_misi: {"jawaban": "..."}`).
  - Dilengkapi label privasi: *"Privat di perangkatmu: tulisan ini hanya tersimpan di HP-mu dan tidak pernah dikirim ke mana pun."*
  - Dilengkapi validasi panjang minimal karakter (`minimalKarakter`, rentang 5–200, default 10) dengan status hitungan interaktif.
  - Tombol simpan refleksi (`Key('tombol_simpan_refleksi')`) nonaktif jika teks belum memenuhi syarat minimal karakter.
  - Memuat kembali teks refleksi yang sudah tersimpan saat pelajaran dibuka ulang.
- **Logika & Umpan Balik Murni `ringkasan_langganan_dan_keinginan` (`lib/perhitungan/perhitungan_umpan_balik_belajar.dart`):**
  - Fungsi murni TDD dengan 5 vektor pengujian komprehensif (`V1` sampai `V5`) mencakup kasus 0 langganan, 1 langganan, banyak langganan, tanpa pengeluaran keinginan, serta kombinasi penuh.
  - Seluruh nominal menggunakan tipe `int` murni (tanpa `double` atau pembulatan `round()`).
  - Terhubung reaktif via `penyediaBelajar` dengan membaca langganan aktif dari `tabel_tagihan` dan transaksi berpos/sifat keinginan bulan berjalan dari `tabel_transaksi`.
- **Konten Edukasi Resmi Modul 6 (`aset/konten/pemula/psikologi_uang/`):**
  - `modul.json`: Gerbang ganda (`modul_selesai anggaran_arus_kas` dan `ada_data pengeluaran min 5`), status `tersedia: true`, bankSoal kuis 10 butir dengan sebaran 6_1 (4), 6_2 (3), 6_3 (3) ber-`pelajaranId` valid.
  - `psikologi_uang_6_1.json`: "Mengenali Pemicu Belanja Impulsif", durasi 5 menit, contohAngka "Belanja saat lelah sepulang kerja", misi `refleksi` "Tulis pemicu belanjamu".
  - `psikologi_uang_6_2.json`: "Jebakan Langganan & \"Bocor Halus\"", durasi 6 menit, contohAngka "Langganan yang terlupakan selama berbulan-bulan", misi `lihat_hitungan` "Hitung langganan & pengeluaran keinginanmu" dengan umpan balik `ringkasan_langganan_dan_keinginan`.
  - `psikologi_uang_6_3.json`: "Membangun Jeda Sebelum Membeli", durasi 5 menit, contohAngka "Menunda pembelian sepatu baru selama 24 jam", misi `refleksi` "Pilih aturan jedamu" dengan metadata `aturanPraktis: true` dan `catatanReviewer: "TODO-VERIFIKASI: angka hanya ilustrasi"`.
- **Ekstensi Kamus Keuangan (`aset/konten/kamus.json` & `docs/materi/kamus_modul_6.md`):**
  - Menambahkan 4 entri istilah baru persis kata per kata sesuai lampiran resmi: `belanja impulsif`, `pemicu belanja`, `langganan`, dan `aturan jeda`.
- **Penutupan Kurikulum Tingkat Pemula & Integrasi Beranda (`lib/fitur/beranda/tampilan/layar_beranda.dart`, `lib/fitur/belajar/kontroler/penyedia_belajar.dart`):**
  - Menuntaskan seluruh 7 modul tingkat pemula (Modul 0 Fondasi Keuangan s.d. Modul 6 Psikologi Uang).
  - Petak Beranda menampilkan status selesai hangat: *"Hebat! Semua Materi Selesai - Kamu telah menuntaskan seluruh pelajaran yang tersedia."*
- **Suite Pengujian Unit, Widget & Integrasi (`test/`, `integration_test/`):**
  - `test/perhitungan/perhitungan_umpan_balik_tahap_08d_test.dart` (5 pengujian murni TDD V1–V5).
  - `test/fitur/evaluator_misi_tahap_08d_test.dart` (7 pengujian evaluator misi refleksi).
  - `test/konten/kesesuaian_lampiran_test.dart` (23 pengujian kesesuaian kata per kata seluruh modul & kamus).
  - `test/fitur/pemeriksa_konten_rusak_test.dart` (93 pengujian integritas parser konten).
  - `test/fitur/belajar_tahap_08d_widget_test.dart` (4 pengujian widget kartu refleksi, umpan balik 6.2, kuis, dan skala teks 2.0).
  - `test/fitur/benchmark_beban_modul_6_test.dart` (tolok ukur beban 20.000 transaksi + 20 utang + 20 tagihan: Tab Belajar median 39 ms < 100 ms, pembukaan pelajaran 6.1–6.3 median 0–1 ms < 50 ms).
  - `integration_test/tahap_08d_emulator_test.dart` (alur E2E 9 langkah lengkap, regresi 19 tabel identik 100%, 13 titik tangkapan layar).

---

Tahap 8C-R menuntaskan seluruh revisi dan pembuktian Tahap 8C sesuai panduan PROMPT TAHAP 8C-R:
- **Investigasi Pengujian & Pemulihan (Butir A):** Mengembalikan seluruh 67 kasus uji lama yang sempat terhapus di `test/fitur/pemeriksa_konten_rusak_test.dart` dan menggabungkannya dengan 17 kasus uji baru Tahap 8C (total 84 kasus uji di berkas ini, seluruhnya lolos).
- **Kesesuaian Lampiran Modul 5 & Kamus (Butir B):** Menyelaraskan 6 entri kamus Modul 5 menjadi frasa spasi persis lampiran reviewer (`OTP`, `phishing`, `pinjol ilegal`, `biaya di muka`, `verifikasi dua langkah`, `lembaga pengawas`). Menyelaraskan langkah pelajaran 5.2 menjadi 6 langkah (`l1`..`l6`) dan 5.3 menjadi 5 langkah (`l1`..`l5`). Uji kesesuaian lampiran kata per kata 100% lolos (17 pengujian).
- **Langkah 0 & Pembuktian Modul 4 (Butir C):** Memverifikasi integritas berkas materi Modul 4 (1 commit), judul keempat pelajaran persis lampiran, penanda ringkasan contohAngka `"ringkasan": true`, uji widget untuk ketiga kondisi pesan gerbang Modul 4, pengujian 5 tipe misi menulis `selesai` ke `tabel_hasil_misi`, eliminasi total `pompaAman` dan `warnIfMissed: false`, serta penjelasan kode riwayat 6 baris kuis di 8B-R dan durasi terbaru `repositori_utang_test.dart`.
- **Tolok Ukur Beban & E2E (Butir D):** Memverifikasi alur E2E emulator lengkap (opsi a->c->b dengan rekaman muatan urutan percobaan, disclaimer + centang bertahap 5.2, kuis 3/5 gagal lalu 4/5 lulus, regresi 19 tabel identik 44 baris), serta menambahkan tolok ukur beban 20.000 transaksi + 20 utang untuk pembukaan layar pelajaran 5.1, 5.2, dan 5.3 (1x pemanasan + 10 iterasi, median komputasi 1-2 ms, 2 kueri database per layar buka).

---

## [0.12.0] - 2026-11-21 — Tahap 8C: Modul 5 "Waspada Penipuan & Pinjol Ilegal" + Tipe Misi Keputusan & Daftar Periksa

Tahap 8C mengimplementasikan kurikulum lengkap Modul 5 ("Waspada Penipuan & Pinjol Ilegal": 3 pelajaran, 1 kuis 5 dari 10 bankSoal sebaran 4/3/3 ber-pelajaranId valid, 6 entri kamus baru) beserta dua tipe misi baru (`keputusan` dan `daftar_periksa`), komponen reusable `DisclaimerLangkahDuniaNyata`, aturan pemeriksa bahasa sensitif khusus Modul 5 (larangan URL, surel, nama lembaga spesifik, nomor kontak), persistensi konsisten seluruh tipe misi ke `tabel_hasil_misi`, eliminasi total `pompaAman` dan `pump(const Duration` di luar `pompa_uji.dart`, penutupan sisa Tahap 8B, suite uji unit, widget, dan skrip pengujian integrasi E2E emulator.

### Ditambahkan & Diselaraskan
- **Dua Tipe Misi Baru (`lib/perhitungan/perhitungan_belajar.dart`, `lib/fitur/belajar/model/registri_misi.dart`, `lib/fitur/belajar/tampilan/layar_pemutar_pelajaran.dart`):**
  - `keputusan`: Kartu skenario keputusan interaktif dengan opsi pilihan (tinggi >= 48dp). Memilih opsi menampilkan umpan balik edukatif; memilih opsi aman (`aman: true`) menyelesaikan misi dan mengaktifkan tombol "Lanjut"; opsi tidak aman menampilkan tombol "Coba pilihan lain" (tanpa batas, tanpa skor). Riwayat urutan percobaan dicatat ke `tabel_hasil_misi` (`muatan_json: {"opsiDipilih":["a","c","b"]}`).
  - `daftar_periksa`: Komponen daftar centang langkah nyata di luar aplikasi (Semantics, tinggi >= 48dp). Dilengkapi kartu `DisclaimerLangkahDuniaNyata` di bagian atas dengan tombol "Mengerti", penghitung *"n dari minimal m langkah dicentang"*, serta tombol "Selesai" yang aktif hanya bila syarat minimal terpenuhi. Hasil centang dicatat ke `tabel_hasil_misi` (`muatan_json: {"dicentang":["l1","l2","l3"]}`) dan dimuat kembali saat layar dibuka ulang.
- **Komponen Disclaimer Resmi (`lib/komponen/disclaimer_langkah_dunia_nyata.dart`, `aset/konten/disclaimer.json`):**
  - Menampilkan disclaimer edukasi umum langkah dunia nyata persis teks lampiran resmi reviewer tanpa hardcoded string.
- **Konten Edukasi Resmi Modul 5 (`aset/konten/pemula/waspada_penipuan/`):**
  - `modul.json`: Gerbang `modul_selesai anggaran_arus_kas`, status `tersedia: true`, bankSoal kuis 10 butir dengan sebaran 4_1 (4), 4_2 (3), 4_3 (3).
  - `waspada_penipuan_5_1.json`: "Ciri Tawaran yang Mencurigakan", durasi 5 menit, contohAngka "Hadiah yang tidak pernah datang", misi `keputusan` "Latih rem-mu".
  - `waspada_penipuan_5_2.json`: "Cek Legalitas Sebelum Percaya", durasi 5 menit, contohAngka "Biaya potongan yang baru terasa saat pencairan", misi `daftar_periksa` "Siapkan cara cek penyedia" (`disclaimer: true`, minimal 3).
  - `waspada_penipuan_5_3.json`: "Kalau Sudah Terlanjur", durasi 5 menit, contohAngka "Biaya memperpanjang pinjaman yang tidak menyelesaikan masalah", misi `daftar_periksa` "Susun rencana daruratmu" (`disclaimer: true`, minimal 3).
- **Ekstensi Kamus Keuangan (`aset/konten/kamus.json` & `docs/materi/kamus_modul_5.md`):**
  - Menambahkan 6 entri istilah baru: `biaya di muka`, `OTP`, `phishing`, `pinjol ilegal`, `akses berlebihan`, `kontak darurat` persis kata per kata sesuai lampiran resmi.
- **Pemeriksa Konten & Validasi Ketat (`lib/fitur/belajar/model/pembaca_konten.dart`):**
  - Menolak jenis misi di luar 5 tipe resmi (`ada_data`, `aturan_data`, `lihat_hitungan`, `keputusan`, `daftar_periksa`).
  - Menolak teks Modul 5 yang memuat kata sensitif ("http", "www", "@", "OJK", "BSSN", atau digit >= 8 tanpa titik) serta label judul biner "aman"/"bahaya".
- **Persistensi Konsisten `tabel_hasil_misi`:**
  - Seluruh 5 tipe misi kini mencatat `status: 'selesai'` ke `tabel_hasil_misi` saat selesai. Sumber kebenaran "Selesai tidak terkunci ulang" tetap merujuk pada `tabel_progres_pelajaran`.
- **Eliminasi Total `pompaAman` dan Pengujian Anti-Menggantung:**
  - Menghapus `pompaAman` dari seluruh direktori `test/` dan `integration_test/`.
  - Memperluas `test/penjaga/aturan_pengujian_test.dart` (7 aturan lolos).

---

## [0.11.1] - 2026-11-20 — Tahap 8B-R: Kesesuaian Lampiran Modul 4

Tahap 8B-R menyelaraskan seluruh metadata Modul 4 ("Utang & Cicilan") agar tepat dan patuh 100% pada teks lampiran resmi reviewer (`docs/materi/modul_4_utang_cicilan.md` dan `kamus_modul_4.md`), mengembalikan teks lampiran asli `catatanReviewer` pada pelajaran 4.2, 4.3, dan 4.4, menyelaraskan durasi pelajaran (5, 6, 5, 6 menit), menerapkan ambang lulus kuis global 70% (`ambangLulusKuis`) tanpa ambang khusus modul, mengoreksi sebaran soal bankSoal (3, 3, 2, 2) tanpa soal sintesis, menyelaraskan kunci pernyataan menjadi `tidak_punya_utang` di seluruh kode, provider, pengujian, dan dokumentasi, memperluas uji kesesuaian lampiran dinamis dari markdown, menyempurnakan evaluasi gerbang dan tombol "Cabut pernyataan", menutup Langkah 0 (a sampai e), serta menjalankan alur integrasi emulator Pixel 8 (Android 16 API 36) dengan assertion string lengkap, regresi 19 tabel pada kondisi berisi utang (`tabel_utang: 3 baris`), dan tolok ukur beban komputasi on-demand.

### Diperbaiki & Diselaraskan
- **Kesesuaian Metadata Modul 4 (`aset/konten/pemula/utang_cicilan/`):**
  - Durasi diselaraskan: 4_1 = 5, 4_2 = 6, 4_3 = 5, 4_4 = 6 menit.
  - Ambang kelulusan kuis dikembalikan ke konstanta global `ambangLulusKuis = 70` (ambang khusus modul dihapus dari `modul.json`).
  - Sebaran 10 bankSoal: 4_1 (soal 1-3 = 3 soal), 4_2 (soal 4-6 = 3 soal), 4_3 (soal 7-8 = 2 soal), 4_4 (soal 9-10 = 2 soal). Soal 7 menyertakan metadata `aturanPraktis: true` dan `catatanReviewer: "TODO-VERIFIKASI: angka hanya ilustrasi"`.
  - Catatan reviewer pelajaran dikembalikan persis teks lampiran untuk 4_2, 4_3, dan 4_4 (4_3 ber-`aturanPraktis: true`).
  - Kunci pernyataan distandarkan menjadi `tidak_punya_utang` (menggantikan `tanpa_utang`).
- **Penyempurnaan Gerbang Belajar & Tombol Cabut Pernyataan (`lib/perhitungan/perhitungan_belajar.dart`, `lib/fitur/belajar/tampilan/layar_belajar.dart`):**
  - Tombol "Aku tidak punya ini" hanya muncul jika modul terkunci karena syarat utang dan prasyarat Modul 3 sudah selesai.
  - Tombol "Cabut pernyataan" ditambahkan saat pengguna menyatakan `tidak_punya_utang`, sehingga pengguna dapat mengunci kembali modul secara interaktif.
  - 6 kombinasi gerbang murni dan uji widget divalidasi pada `test/fitur/belajar_tahap_08b_widget_test.dart`.
- **Aksesibilitas Skala Teks 2.0:**
  - Uji widget memvalidasi tombol "Lanjut" pemutar pelajaran dapat dijangkau dan di-scroll pada layar 360x640 dengan skala teks 2.0 tanpa error.
- **Pengujian Integrasi E2E Emulator Pixel 8 (`integration_test/tahap_08b_emulator_test.dart`):**
  - Jalur A: input utang riil melalui formulir `/utang/tambah`, assertion string lengkap pada umpan balik 4.1 s.d. 4.4, kuis percobaan 1 (skor 60% gagal) lalu percobaan 2 (lulus >= 70%), dan pembaruan petak Beranda.
  - Jalur B: verifikasi gerbang terkunci -> tombol "Aku tidak punya ini" -> terbuka -> verifikasi teks umpan balik pernyataan -> cabut pernyataan -> terkunci kembali.
  - Regresi Integritas 19 Tabel SQLite pada kondisi berisi utang (`tabel_utang: 3 baris`) membuktikan 58 baris sebelum dan sesudah cadangan/pemulihan identik 100% (`docs/bukti/tahap_08b_r_regresi_19_tabel.txt`).
  - Tolok ukur beban 20.000 transaksi + 20 utang: Tab Belajar komputasi median 67ms, frame pertama median 23ms; On-Demand Pelajaran Modul 4 komputasi median 5ms (1 kueri tunggal teroptimasi).
  - 10 tangkapan layar bersih diambil ulang secara segar ke `docs/tangkapan_layar/tahap_08b_01` s.d. `10` (nomor 11 dihapus).

---

## [0.11.0] - 2026-11-20 — Tahap 8B: Modul 4 "Utang & Cicilan"

Tahap 8B mengimplementasikan konten lengkap Modul 4 ("Utang & Cicilan": 4 pelajaran, kuis akhir 5 dari 10 bankSoal ber-pelajaranId valid, 6 entri kamus baru) beserta empat fungsi murni umpan balik belajar berbasis data pengguna riil (`ringkasan_utang`, `biaya_pinjaman_tercatat`, `rasio_cicilan_bulan_ini`, `urutan_pelunasan`), kueri rincian baris utang on-demand pada repositori utang tanpa menambah kueri pada foto data agregat, mekanisme tombol pernyataan "Aku tidak punya ini" pada modul terkunci, eliminasi total `warnIfMissed: false`, penutupan Langkah 0 (a sampai e), pengujian integrasi E2E emulator Pixel 8 (Jalur A punya utang & Jalur B tanpa utang), regresi 19 tabel via `sqlite_master`, dan tolok ukur beban 20.000 transaksi + 20 utang.

### Ditambahkan & Diselaraskan
- **Konten Edukasi Resmi Modul 4 (`aset/konten/pemula/utang_cicilan/`):**
  - `modul.json`: Gerbang `modul_selesai dana_darurat` DAN (`ada_data utang min 1` ATAU `pernyataan tidak_punya_utang`), status `tersedia: true`, bankSoal kuis 10 butir berpelajaranId valid.
  - `utang_cicilan_4_1.json`: "Utang yang Membantu dan yang Menjerat", durasi 5 menit, contohAngka "Tiga cicilan kecil yang menumpuk", misi `lihat_hitungan`, umpanBalik `ringkasan_utang`.
  - `utang_cicilan_4_2.json`: "Berapa Harga Utang Sebenarnya?", durasi 5 menit, contohAngka "Pinjaman Rp12.000.000 selama 12 bulan, bunga flat 12 persen per tahun", misi `lihat_hitungan`, umpanBalik `biaya_pinjaman_tercatat`.
  - `utang_cicilan_4_3.json`: "Batas Aman Cicilan", durasi 5 menit, contohAngka "Rasio cicilan untuk pemasukan Rp3.000.000", misi `lihat_hitungan`, umpanBalik `rasio_cicilan_bulan_ini`.
  - `utang_cicilan_4_4.json`: "Dua Cara Melunasi: Bola Salju dan Longsor", durasi 6 menit, contohAngka "Tiga utang dengan bunga berbeda (contoh)", misi `lihat_hitungan`, umpanBalik `urutan_pelunasan`.
- **Ekstensi Kamus Keuangan (`aset/konten/kamus.json` & `docs/materi/kamus_modul_4.md`):**
  - Menambahkan 6 entri istilah baru: `pokok`, `bunga flat`, `bunga efektif`, `paylater`, `bola salju`, `longsor` dengan definisi dan contoh Rupiah konkret persis kata per kata sesuai lampiran resmi.
  - Memperluas suite uji `test/konten/kesesuaian_lampiran_test.dart` untuk memvalidasi teks Modul 4 dan 6 entri kamus baru secara otomatis (18/18 lulus).
- **Fungsi Murni Umpan Balik Integer Murni Tanpa Double (`lib/perhitungan/perhitungan_umpan_balik_belajar.dart`):**
  - Mengimplementasikan 4 fungsi murni umpan balik belajar berbasis data pengguna riil:
    - `formatRingkasanUtang`: evaluasi jumlah utang aktif, sisa total utang, cicilan per bulan, dan persentase rasio cicilan terhadap pemasukan rata-rata 3 bulan terakhir.
    - `formatBiayaPinjamanTercatat`: perhitungan biaya pinjaman (bunga + biaya lain) dari salah satu pinjaman aktif ber-tenor (cicilan x tenor - pokok).
    - `formatRasioCicilanBulanIni`: rasio cicilan terhadap pemasukan rata-rata 3 bulan terakhir, serta simulasi sensitivitas risiko bila pemasukan turun 25 persen.
    - `formatUrutanPelunasan`: panduan urutan prioritas pelunasan utang aktif berdasarkan metode bola salju (sisa terkecil dahulu) dan metode longsor (bunga tertinggi dahulu).
  - Seluruh uang, persen, dan bunga menggunakan integer murni (Rupiah, persen integer, bunga basis poin per tahun) tanpa tipe `double` dan tanpa `round()`.
  - 30 kasus uji vektor V1 sampai V8 diuji dengan assertion string lengkap pada `test/perhitungan/perhitungan_umpan_balik_tahap_08b_test.dart` (lulus 100%).
- **Arsitektur On-Demand Kueri Utang & Registri Misi (`lib/data/repositori/utang_repositori.dart`, `lib/fitur/belajar/kontroler/penyedia_belajar.dart`):**
  - Menambahkan metode `ambilDaftarUtangUmpanBalik()` pada `UtangRepositori`. Kueri rincian utang dieksekusi secara on-demand HANYA saat pengguna membuka kartu misi pelajaran terkait, sehingga `FotoDataRepositori` tetap bebas dari kueri tambahan (tetap 11 kueri teroptimasi).
  - Menghubungkan tombol "Aku tidak punya ini" pada `LayarBelajar` untuk menyimpan dan mencabut klaim `tidak_punya_utang` di `tabel_pernyataan`.
- **Eliminasi Total `warnIfMissed: false`:**
  - Mengeliminasi seluruh 4 pemanggilan `warnIfMissed: false` pada suite pengujian integrasi (`integration_test/tahap_06_alur_modul_1_emulator_test.dart` dan `integration_test/tahap_08a_emulator_test.dart`), diganti dengan assertion dan tap standar yang lolos pengujian widget pada skala teks 2.0 (`TextScaler.linear(2.0)`).
- **Pengujian Integrasi Emulator & Regresi 19 Tabel SQLite (`integration_test/tahap_08b_emulator_test.dart`):**
  - Menguji alur Jalur A (pengguna punya utang: 3 utang aktif, pemasukan 3 bulan terakhir, 4 pelajaran Modul 4, kuis tidak lulus 60% lalu lulus 80%).
  - Menguji alur Jalur B (pengguna tanpa utang: tombol pernyataan "Aku tidak punya ini", verifikasi 4 teks umpan balik pernyataan, cabut pernyataan).
  - Regresi integritas 19 tabel basis data SQLite via kueri dinamis `sqlite_master` sebelum dan sesudah ekspor-impor cadangan.
  - Tolok ukur performa beban 20.000 transaksi + 20 utang mencatat waktu komputasi `ambilFotoData` dan frame render terpisah dari jeda harness.

---

## [0.10.1] - 2026-11-20 — Penyelarasan Tahap 8A (Tahap 8A-R)

Tahap 8A-R: Penyelarasan Kesesuaian Lampiran Modul 2 & 3 Kata per Kata, Penyelarasan Kamus Keuangan (6 istilah baru), Eliminasi Total Tipe `double` dan `round()` pada 5 Fungsi Murni Umpan Balik Belajar, Uji String Lengkap 41 Kasus Uji Umpan Balik, Pemulihan Cadangan Data dengan Enumerasi Dinamis 19 Tabel SQLite (`sqlite_master`), Penutupan Regresi Emulator Pixel 8 dengan 11 Tangkapan Layar Resmi, dan Tolok Ukur Beban 20.000 Transaksi (Komputasi 44 ms vs Frame Pertama 32 ms).

### Ditambahkan & Diselaraskan
- **Kamus Keuangan (`aset/konten/kamus.json` & `docs/materi/kamus_modul_2_3.md`):**
  - Menyelaraskan teks 6 istilah baru (`tenggat`, `setoran`, `kantong`, `saldo bebas`, `pengeluaran wajib`, `tonggak`) persis kata per kata dengan dokumen materi resmi.
  - Memperluas suite uji `test/konten/kesesuaian_lampiran_test.dart` untuk memvalidasi teks kamus baru secara otomatis.
- **Fungsi Murni Umpan Balik Integer Murni Tanpa Double (`lib/perhitungan/perhitungan_umpan_balik_belajar.dart`):**
  - Menghilangkan seluruh operasi bertipe `double` dan pembulatan `round()` pada uang, persen, dan konversi bulan.
  - Mengimplementasikan penghitungan pembulatan ke atas integer murni `(sisa + setoran - 1) ~/ setoran` dan format koma desimal `desimalSatuTempat()` berbasis aritmatika integer modulus/pembagian integer.
  - Menulis 41 kasus uji `test/perhitungan/perhitungan_umpan_balik_tahap_08a_test.dart` yang menguji string keluaran lengkap (bukan sekadar `contains`).
- **Foto Data & Status Konten (`lib/data/repositori/foto_data_repositori.dart`, `lib/fitur/belajar/pemeriksa_konten_rusak.dart`):**
  - Menyaring status tujuan tabungan dan dana darurat dengan `status IN ('aktif', 'tercapai')`.
  - Mengunci status konten valid hanya untuk `'draf'` dan `'ditinjau'` (status `'rilis'` atau lainnya ditolak tegas oleh pemeriksa konten).
- **Pengujian Integrasi Emulator & Cadangan Dinamis (`integration_test/tahap_08a_emulator_test.dart`):**
  - Menerapkan enumerasi dinamis kueri SQLite `sqlite_master` untuk memverifikasi kesamaan jumlah baris sebelum dan sesudah ekspor-impor cadangan di seluruh 19 tabel basis data.
  - Menghasilkan 11 berkas tangkapan layar resmi beresolusi native di `docs/tangkapan_layar/`.
  - Tolok ukur 20.000 transaksi mencatat median komputasi `ambilFotoData` 44 ms dan median frame pertama 32 ms.

---

## [0.10.0] - 2026-11-19 — Tahap 8A: Modul 2 "Tabungan" & Modul 3 "Dana Darurat"

Tahap 8A mengimplementasikan konten lengkap Modul 2 ("Tabungan": 3 pelajaran, kuis akhir 5 dari 10 soal, kamus baru) dan Modul 3 ("Dana Darurat": 3 pelajaran, kuis akhir 5 dari 10 soal, kamus baru) beserta mesin pendukungnya, agregasi SQL agregat pada SATU foto data, 5 fungsi murni umpan balik belajar berbasis data pengguna nyata, unit test kesesuaian lampiran kata per kata, widget test, penutupan utang Langkah 0(c), dan pengujian integrasi emulator dengan tangkapan layar resmi.

### Ditambahkan & Diperbarui
- **Konten Edukasi Resmi Modul 2 & 3 (`aset/konten/pemula/`):**
  - `tabungan/modul.json`: Gerbang `modul_selesai anggaran_arus_kas` DAN `ada_data anggaran min 1`, bankSoal kuis 10 butir berpelajaranId valid.
  - `tabungan/tabungan_2_1.json`: "Menabung Itu Soal Tujuan", misi `ada_data` `tujuan_tabungan` min 1, umpanBalik `ringkasan_tujuan_tabungan`.
  - `tabungan/tabungan_2_2.json`: "Bayar Diri Sendiri Dulu", gerbang `ada_data tujuan_tabungan min 1`, misi `ada_data` `isi_tujuan_tabungan` min 1, catatanReviewer verifikasi perilaku.
  - `tabungan/tabungan_2_3.json`: "Menghitung Kecepatan Menabung", gerbang `ada_data isi_tujuan_tabungan min 1`, misi `lihat_hitungan`, umpanBalik `estimasi_tabungan`.
  - `dana_darurat/modul.json`: Gerbang `modul_selesai tabungan` DAN `ada_data pengeluaran_kebutuhan min 3`, bankSoal kuis 10 butir dengan penanda aturan praktis pada soal 5 & 6.
  - `dana_darurat/dana_darurat_3_1.json`: "Apa Itu Dana Darurat?", misi `lihat_hitungan`, umpanBalik `pengeluaran_wajib_bulanan`.
  - `dana_darurat/dana_darurat_3_2.json`: "Berapa yang Cukup untukmu?", penanda `aturanPraktis: true` dan catatanReviewer TODO-VERIFIKASI, misi `ada_data` `tujuan_dana_darurat` min 1, umpanBalik `target_dana_darurat`.
  - `dana_darurat/dana_darurat_3_3.json`: "Mengisi Dana Darurat Sedikit demi Sedikit", gerbang `ada_data tujuan_dana_darurat min 1`, misi `ada_data` `isi_dana_darurat` min 1, umpanBalik `progres_dana_darurat`.
- **Ekstensi Kamus Keuangan (`aset/konten/kamus.json`):**
  - Menambahkan 6 istilah baru: `tenggat`, `setoran`, `kantong`, `saldo bebas`, `pengeluaran wajib`, `tonggak` dengan definisi dan contoh Rupiah konkret.
- **Mesin Pendukung Gerbang & Misi (`lib/perhitungan/perhitungan_belajar.dart`, `lib/data/repositori/foto_data_repositori.dart`, `lib/fitur/belajar/model/registri_misi.dart`):**
  - Memperluas `FotoDataPengguna` dengan 5 bidang agregat: `jumlahTujuanTabungan`, `jumlahIsiTujuanTabungan`, `jumlahPengeluaranKebutuhan`, `jumlahTujuanDanaDarurat`, `jumlahIsiDanaDarurat`.
  - Menambahkan 5 subkueri SQLite di dalam customSelect agregasi tunggal di `FotoDataRepositori`.
  - Memperbarui rute navigasi interaktif pada `ambilRutePengisianObjek` untuk tujuan tabungan, kantong, dan transaksi pengeluaran kebutuhan.
- **Fungsi Murni Umpan Balik Belajar (`lib/perhitungan/perhitungan_umpan_balik_belajar.dart`):**
  - `formatBulanDesimal(x)`: Format desimal koma Indonesia (mis. "1,5", bulat "3", nol "0").
  - `hitungEstimasiBulan(sisa, setoran)`: Pembulatan ke atas (integer ceiling).
  - `hitungRataRataSetoranTabungan(...)`: Jendela 3 bulan kalender berjalan/lampau.
  - `hitungPengeluaranWajibBulanan(...)`: Rata-rata kebutuhan + cicilan utang 3 bulan selesai terakhir atau bulan berjalan.
  - `formatRingkasanTujuanTabungan(...)`, `formatEstimasiTabungan(...)`, `formatTeksPengeluaranWajibBulanan(...)`, `formatTargetDanaDarurat(...)`, `formatProgresDanaDarurat(...)`.
- **Pengujian Komprehensif:**
  - `test/konten/kesesuaian_lampiran_test.dart`: Uji kesesuaian kata per kata seluruh teks JSON Modul 2 & 3 terhadap dokumen lampiran resmi.
  - `test/fitur/pemeriksa_konten_rusak_test.dart`: 7 kasus uji validasi penolakan objek gerbang/misi dan kunci umpan balik baru.
  - `test/perhitungan/perhitungan_umpan_balik_tahap_08a_test.dart`: 33 kasus uji fungsi murni umpan balik dengan vektor hitungan tangan.
  - `test/performa/performa_belajar_tahap_08a_test.dart`: Uji kesetaraan agregasi SQL vs fungsi murni dan EXPLAIN QUERY PLAN untuk 5 subkueri baru.
  - `test/fitur/belajar_tahap_08a_widget_test.dart`: Widget test contohAngka 6 pelajaran, kartu misi 5 umpan balik, kuis modul, dan skala teks 2.0.
  - `integration_test/tahap_08a_emulator_test.dart`: Pengujian E2E di emulator Pixel 8, penutupan Langkah 0(c), dan benchmark 20.000 transaksi.

---

## [0.9.1] - 2026-11-19 — Penyelarasan Tahap 7 (Tahap 7-R)

Tahap 7-R: Penyelarasan Laporan Bulanan & Cadangan Data, Penegakan Aturan Pengujian Anti-Menggantung Terpusat, Optimasi Agregasi SQL Laporan (< 15 ms), Penjaga Skema & Peningkat Cadangan, Verifikasi Font TTF U+2212 & Ekstraksi ToUnicode CMap PDF, Pengujian Regresi Tahap 5 di Emulator, dan Validasi Alur UI End-to-End dengan 7 Tangkapan Layar Resmi Emulator.

### Ditambahkan & Dioptimasi
- **Aturan Pengujian Anti-Menggantung Terpusat (`test/pembantu/pompa_uji.dart`, `test/penjaga/aturan_pengujian_test.dart`):**
  - Menerapkan helper terpusat `pompaAman(tester)` sebagai SATU-SATUNYA tempat pemanggilan `pumpAndSettle()` dengan batas aman 5 detik (menggantikan 142 pemanggilan `pumpAndSettle` langsung di seluruh repositori).
  - Menyediakan `pompaHingga(tester, kondisi)` dan `pompaHinggaAda(tester, pencari)` dengan penanganan galat cepat.
  - Komponen `IndikatorMemuat` di `lib/komponen/indikator_memuat.dart` dengan provider `penyediaTanpaAnimasi` (mengalihkan 35 pemanggilan `CircularProgressIndicator` dan `LinearProgressIndicator` di `lib/`).
  - Mengeliminasi seluruh pemanggilan `Future.delayed` pada berkas uji widget.
  - Menetapkan batas waktu suite `@Timeout(Duration(seconds: 30))` di seluruh berkas uji widget serta file konfigurasi global `dart_test.yaml`.
  - Suite linter otomatis `test/penjaga/aturan_pengujian_test.dart` yang memvalidasi 4 aturan anti-menggantung secara ketat pada setiap eksekusi CI/test.
- **Optimasi Agregasi SQL Laporan Bulanan (`lib/fitur/laporan/kontroler/penyedia_laporan.dart`):**
  - Mengalihkan penghitungan komposisi per-sifat/per-kategori ke SQL `GROUP BY` dan saldo dompet ke `hitungSaldoDompetSQL`, menghilangkan pemuatan 20.000 transaksi ke memori Dart.
  - Waktu susun laporan pada beban 20.000 transaksi dipangkas dari 458 ms menjadi 10.3 ms di host (~45x lebih cepat, jauh melampaui target < 150 ms).
  - Ditambahkan uji kesetaraan otomatis antara agregasi SQL vs fungsi murni Dart pada `test/performa/performa_laporan_dan_cadangan_test.dart`.
- **Penyelarasan Vektor Uji Laporan V1–V9 (`test/perhitungan/perhitungan_laporan_bulanan_test.dart`):**
  - Assertion lengkap pada string keluaran teks normal dan sensor sesuai prompt resmi.
  - Kasus batas pembulatan: `persenTerdekat(1, 8) == 13` (12.5% dibulatkan ke atas) dan total 0 mengembalikan `null`.
  - Pemindaian seluruh teks mode sensor bebas simbol "Rp" dan format nominal angka Rupiah bertitik.
- **Penyelarasan Cadangan & Peningkat Skema (`lib/data/cadangan/`, `test/data/cadangan_test.dart`):**
  - Penjaga tabel skema (`dapatkanDaftarTabelSkema`) memverifikasi seluruh tabel SQLite dan Drift ikut diekspor (kecuali terdaftar di `CadanganRepositori.tabelDikecualikan = {}`).
  - Penjaga peningkat skema (`RegistriPeningkatCadangan.versiSkemaCadanganPertama = 10`) memastikan rantai transformasi skema terdaftar.
  - Pengujian penolakan berkas > 50 MB, jaminan kategori bawaan tidak ganda setelah pemulihan, dan pemulihan darurat dari `sebelum_pemulihan.json`.
  - Pengujian deterministik terhadap variasi urutan penyisipan (*INSERT order independence*).
- **Verifikasi Ekspor PDF & PNG (`test/layanan/laporan_ekspor_test.dart`):**
  - Verifikasi glyph U+2212 pada font tertanam `PlusJakartaSans-Regular.ttf` dan `PlusJakartaSans-Bold.ttf`.
  - Parser ekstraksi teks byte PDF berbasis ToUnicode CMap untuk membuktikan ketiadaan kata "Rp" pada dokumen mode sensor.
  - Isolasi ekspor pengujian ke direktori sementara sistem sehingga `docs/contoh_ekspor/laporan.pdf` tidak terotori pada setiap eksekusi `flutter test`.
- **Pengujian Integrasi Emulator & Bukti Tangkapan Layar:**
  - Skenario regresi Tahap 5: "Lewati" menyimpan `profil_dilewati`, buka dompet membuka Modul 1, catat utang memicu saran Modul 4, kuis dua benih menghasilkan urutan berbeda dengan kunci benar konsisten.
  - Alur UI nyata Tahap 7: Beranda → Laporan → Sensor ON/OFF → Bagikan PNG & PDF → Cadangan → Buat Cadangan → Hapus Data → Pulihkan 2 langkah → Verifikasi tabel identik → Beranda pulih.
  - 7 tangkapan layar resmi emulator termasuk `tahap_07_pratinjau_setelah_pulih.png` dan `tahap_07_beranda_setelah_pulih.png`.

---

## [0.9.0] - 2026-11-19 — Tahap 7: Laporan Bulanan (PNG + PDF) & Cadangan Data

Tahap 7: Implementasi Lengkap Laporan Bulanan (Pratinjau Soft Bento, Ekspor PNG 1080px, Dokumen PDF A4 Teks Asli Tertanam Font TTF Plus Jakarta Sans), Saklar Sensor Privasi Nominal, Cadangan Data Mandiri (JSON v1 dengan Checksum SHA-256 Deterministik), Pemulihan Atomik dengan Cadangan Keselamatan Otomatis, Pengingat Cadangan di Beranda, Tolok Ukur Beban Nyata (20.000 Transaksi), dan Penuntasan Seluruh Milestone MVP (Tahap 1–7).

### Ditambahkan
- **Fitur Laporan Bulanan (`lib/fitur/laporan/`, `lib/perhitungan/perhitungan_laporan_bulanan.dart`):**
  - Mesin logika murni `perhitungan_laporan_bulanan.dart`:
    * Evaluasi aturan temuan (P1 sampai P6) dan saran (P1 sampai P4) sesuai hierarki urgensi keuangan.
    * Sensor nominal privasi: menghapus seluruh angka dan simbol "Rp" tanpa merusak tata letak kalimat.
    * Vektor uji komprehensif V1 sampai V9 mencakup kondisi defisit, dominasi keinginan, pelanggaran anggaran, dan tahun kabisat (29 Februari).
  - Tampilan Kartu Bento Laporan (`TampilanKartuLaporan`) dan Layar Laporan (`LayarLaporanBulanan` di rute `/laporan`):
    * Pemilih bulan kalender dinamis (dari transaksi pertama pengguna hingga bulan berjalan).
    * Saklar privasi nominal ("Sembunyikan nominal") yang persistensinya tersimpan di `tabel_pengaturan`.
    * Tata letak modular soft bento: Header, Temuan & Saran, Hero Arus Kas, Komposisi Pengeluaran, Realisasi Anggaran, Tujuan Keuangan, dan Kekayaan Bersih.
    * Responsif terhadap aksesibilitas skala font hingga 2.0x (bebas RenderFlex overflow).
- **Layanan Ekspor Dokumen Laporan (`lib/layanan/laporan/`):**
  - `PembuatGambarLaporan`: Menangkap kartu bento laporan via `RepaintBoundary` dengan rasio piksel 3.0 menghasilkan gambar PNG beresolusi tajam tepat 1080 px.
  - `PembuatPdfLaporan`: Membuat dokumen PDF A4 multi-halaman teks asli (bukan raster screenshot) dengan font tertanam TTF *Plus Jakarta Sans* (Regular dan Bold) dan minus Unicode U+2212 untuk nominal negatif. Bebas dari dependensi `printing`.
  - `LayananBagikan` & `LayananBagikanPalsu`: Membagikan berkas via `share_plus` dan membersihkan berkas cache sementara yang berusia > 24 jam.
- **Fitur Cadangan Data & Pemulihan (`lib/data/cadangan/`, `lib/fitur/cadangan/`):**
  - Format Berkas Cadangan `funda_cadangan` v1:
    * Serialisasi raw kanonikal seluruh tabel SQLite berawalan `tabel_*`.
    * Checksum kriptografis SHA-256 deterministik dengan pengurutan alfabetis kunci tabel dan baris Primary Key.
    * Penjaga integritas tabel dan kolom (`RegistriPeningkatCadangan`) untuk migrasi skema cadangan lama.
  - Alur Pemulihan Data (*Restore*) Berlapis:
    * Validasi format dan integritas hash SHA-256 (penolakan berkas rusak atau hasil modifikasi ilegal).
    * Dialog Pratinjau Data (jumlah dompet, transaksi, anggaran, tujuan, utang, tagihan, dan versi aplikasi).
    * Konfirmasi eksplisit dua langkah sebelum penggantian data.
    * Cadangan keselamatan otomatis (*safety backup*) ke berkas internal `sebelum_pemulihan.json` sebelum eksekusi pemulihan.
    * Transaksi atomik SQLite (`PRAGMA defer_foreign_keys = ON;`, penggantian seluruh baris, dan verifikasi `PRAGMA foreign_key_check;`). Bila terjadi kegagalan di tengah jalan, seluruh perubahan di-rollback tanpa sisa data setengah jadi.
  - Pengingat Cadangan Cerdas di Beranda:
    * Banner bento beranda muncul jika pengguna memiliki data aktif dan belum mencadangkan dalam 14 hari terakhir (atau setelah 10 transaksi baru).
    * Opsi "Cadangkan sekarang" dan "Nanti" (menunda pengingat selama 7 hari).
- **Tolok Ukur Performa Beban Nyata (`test/performa/performa_laporan_dan_cadangan_test.dart`):**
  - Pengukuran pada 20.000 transaksi + 20 utang + 20 tagihan:
    * Waktu ekspor cadangan: 397 ms (jauh di bawah batas 3 detik).
    * Ukuran berkas JSON: 5.398.908 bytes (~5,15 MB).
    * Waktu pemulihan atomik: 704 ms (jauh di bawah batas 3 detik).
    * Rata-rata waktu susun laporan: 460,3 ms (10 iterasi stabil).
    * Waktu render PDF: 122 ms (13,7 KB).
- **Rangkaian Pengujian Lengkap:**
  - `test/perhitungan/perhitungan_laporan_bulanan_test.dart`: 12 pengujian unit logika murni (V1–V9, sensor nominal, sensor persentase, kabisat).
  - `test/data/cadangan_test.dart`: 11 pengujian unit repositori cadangan (hash deterministik, penjaga tabel, penjaga peningkat, round-trip ekspor-impor, penolakan checksum rusak, transaksi rollback atomik, pengingat cadangan).
  - `test/layanan/laporan_ekspor_test.dart`: 3 pengujian layanan ekspor (signature PNG 1080px, header %PDF text-asli, cleanup cache 24 jam).
  - `test/fitur/laporan_dan_cadangan_widget_test.dart`: 6 pengujian widget UI (saklar sensor privasi, toleransi skala teks 2.0x, alur cadangan & pemulihan 2 langkah, penanganan berkas rusak, banner beranda).

---

## [0.8.1] - 2026-11-18 — Penyelarasan Tahap 6 (Tahap 6-R)

Tahap 6-R: Penyelarasan Kesesuaian Lampiran Resmi Materi Modul 1 "Anggaran & Arus Kas", Format Nominal Negatif Rapat (Unicode U+2212), Perbaikan Kueri Umpan Balik Transaksi, Evaluasi Profiling Performa Tab Belajar, dan Verifikasi Integrasi UI Nyata di Emulator Android 16 (API 36). Memperbaiki pesan gerbang 1_4 dan 1_5 persis 100% kata demi kata terhadap `docs/materi/modul_1_anggaran_arus_kas.md`, memastikan format nominal negatif pada contoh angka dan umpan balik menggunakan minus Unicode U+2212 sebelum "Rp" tanpa spasi (`−Rp900.000`), menyelaraskan tipe misi hanya pada 3 tipe resmi (`ada_data`, `aturan_data`, `lihat_hitungan`), memperbaiki bug kueri `penyediaTeksUmpanBalikMisi` yang sebelumnya mencari `jenis = 'pengeluaran'` menjadi `jenis = 'keluar'`, mengukur durasi profil murni Tab Belajar (hanya 25-43 ms, 5 kueri SQL bebas N+1), serta mengeksekusi suite integrasi alur Modul 1 lengkap di emulator dengan 10 tangkapan layar PNG riil.

### Diperbaiki & Diselaraskan
- **Kesesuaian Teks Lampiran Materi Modul 1 (`aset/konten/pemula/anggaran_arus_kas/`):**
  - Menyelaraskan teks pesan gerbang kondisi kedua di `anggaran_arus_kas_1_4.json` menjadi `"Catat minimal satu pemasukan bulan ini."`.
  - Menyelaraskan teks pesan gerbang kondisi kedua di `anggaran_arus_kas_1_5.json` menjadi `"Catat minimal satu pengeluaran."`.
  - Membuat suite pengujian kesesuaian kata demi kata di `test/konten/kesesuaian_lampiran_test.dart` yang memvalidasi seluruh judul, pemantik, kartu konsep, contoh angka, cek paham, misi, tindak lanjut, dan 10 butir soal kuis terhadap lampiran resmi (lulus 100%).
- **Format Nominal Negatif Rapat Unicode U+2212 (`lib/perhitungan/`, `lib/fitur/belajar/`):**
  - Mengubah `formatRupiahRapat` di `lib/perhitungan/perhitungan_umpan_balik_belajar.dart` agar nominal negatif memakai minus U+2212 tanpa spasi sebelum "Rp" (`−Rp900.000`).
  - Memperbaiki tabel contoh angka di `lib/fitur/belajar/tampilan/layar_pemutar_pelajaran.dart` agar tidak menggunakan `abs()` melainkan mempertahankan format negatif rapat.
  - Memperbarui `test/fitur/pemutar_pelajaran_contoh_angka_widget_test.dart` dan `test/perhitungan/perhitungan_umpan_balik_belajar_test.dart` untuk menguji format negatif rapat U+2212.
- **Kueri Data & Registri Misi (`lib/fitur/belajar/kontroler/`, `lib/fitur/belajar/model/`):**
  - Memperbaiki `penyediaTeksUmpanBalikMisi('catatan_pengeluaran_terbaru')` yang sebelumnya menyaring `t.jenis.equals('pengeluaran')` menjadi `t.jenis.equals('keluar')` sesuai skema database SQLite Funda.
  - Memastikan registri misi hanya menerima 3 tipe resmi (`ada_data`, `aturan_data`, `lihat_hitungan`) dan validator menolak tegas tipe lain.
- **Pengukuran Profiling Performa Tab Belajar (`integration_test/`):**
  - Menjalankan profiling performa terisolasi di emulator Pixel 8 (Android 16 API 36) dengan pemanasan 1x dan 10 iterasi pada 5.000 dan 20.000 transaksi.
  - Mengungkap bahwa komputasi murni logika bisnis dan kueri SQL Tab Belajar hanya berkisar 25–43 ms (5 kueri SQL teragregasi bebas N+1), dan durasi 800–900 ms pada laporan sebelumnya semata-mata berasal dari sleep helper frame testing `pompaAman(300ms)`.
- **Integrasi Alur Lengkap Modul 1 di Emulator (`integration_test/`):**
  - Mengimplementasikan alur 10 skenario lengkap di `integration_test/tahap_06_alur_modul_1_emulator_test.dart`.
  - Berhasil menangkap 10 berkas tangkapan layar emulator riil di `docs/tangkapan_layar/tahap_06_emulator/`.

---

## [0.8.0] - 2026-11-18 — Tahap 6: Modul 1 Lengkap "Anggaran & Arus Kas"

Tahap 6: Implementasi Lengkap Konten Edukasi Modul 1 "Anggaran & Arus Kas", Skema Baru Contoh Angka, Registri Umpan Balik Edukatif Data Riil, dan Pengujian Integrasi Emulator. Seluruh 5 pelajaran Modul 1 (1.1 "Ke Mana Uangku Pergi?", 1.2 "Memetakan Arus Kas", 1.3 "Kebutuhan vs Keinginan", 1.4 "Anggaran Pertamamu", dan 1.5 "Evaluasi Akhir Bulan") diisi penuh berdasarkan materi resmi reviewer tanpa kata terlarang dan tanpa emoji. Kuis akhir modul diperluas menjadi bank 10 soal dengan pengambilan 5 butir acak deterministik. Menambahkan skema objek `contohAngka` yang merender tabel data konkret dengan format Rupiah rapat, penandaan `aturanPraktis` dan `catatanReviewer` beranotasi `TODO-VERIFIKASI` untuk formula populer 50/30/20, 3 generator umpan balik edukatif data riil (`catatan_pengeluaran_terbaru`, `perbandingan_pola_anggaran`, `realisasi_anggaran_bulan_ini`), kamus finansial diperluas, serta pembuktian alur end-to-end Modul 1 dan profil performa di Emulator Android 16 (API 36).

### Ditambahkan
- **Materi Kurikulum Lengkap Modul 1 (`aset/konten/pemula/anggaran_arus_kas/`):**
  - `anggaran_arus_kas_1_1.json`: "Ke Mana Uangku Pergi?" (durasi 4 mnt, pemantik kebocoran kecil, 3 kartu konsep, contoh angka bocor kecil Rp709.000, cek paham, misi catat 1 pengeluaran, umpan balik `catatan_pengeluaran_terbaru`).
  - `anggaran_arus_kas_1_2.json`: "Memetakan Arus Kas" (durasi 5 mnt, pemantik arus kas, 3 kartu konsep, contoh angka masuk Rp3.000.000 keluar Rp2.100.000 sisa Rp900.000, cek paham, misi catat pemasukan + pengeluaran, umpan balik `arus_kas_bulan_ini`).
  - `anggaran_arus_kas_1_3.json`: "Kebutuhan vs Keinginan" (durasi 6 mnt, gerbang 3 pengeluaran, pemantik dua kelompok pengeluaran, 3 kartu konsep, contoh angka klasifikasi sifat pengeluaran, cek paham, misi labeli kategori, umpan balik `komposisi_sifat_bulan_ini`).
  - `anggaran_arus_kas_1_4.json`: "Anggaran Pertamamu" (durasi 6 mnt, gerbang transaksi di 7 hari berbeda + ada pemasukan, pemantik anggaran bukan penjara, 3 kartu konsep, penanda `aturanPraktis: true` dan `catatanReviewer: "TODO-VERIFIKASI:..."`, contoh angka rencana alokasi, cek paham, misi buat 3 anggaran kategori, umpan balik `perbandingan_pola_anggaran`).
  - `anggaran_arus_kas_1_5.json`: "Evaluasi Akhir Bulan" (durasi 5 mnt, gerbang punya minimal 1 anggaran, pemantik bandingkan rencana vs kenyataan, 3 kartu konsep, contoh angka evaluasi pos anggaran, cek paham, misi lihat realisasi anggaran, umpan balik `realisasi_anggaran_bulan_ini`).
  - `modul.json`: Urutan pelajaran 1 s.d. 5, bank 10 butir soal kuis (soal nomor 7 ditandai `aturanPraktis: true` dan `catatanReviewer: "TODO-VERIFIKASI:..."`), dan pengambilan 5 butir acak per sesi.
- **Skema Baru & Logika Edukasi (`lib/perhitungan/`):**
  - Objek data `ContohAngkaKonten` dan `BarisContohAngka` di `lib/perhitungan/perhitungan_belajar.dart`.
  - Generator murni teks umpan balik di `lib/perhitungan/perhitungan_umpan_balik_belajar.dart`:
    * `formatCatatanPengeluaranTerbaru`: Format nominal rapat `formatRupiahRapat` dan n pengeluaran.
    * `formatPerbandinganPolaAnggaran`: Pembagian integer murni 50/30/20, penanganan pemasukan 0, dan penanganan sisa belum dilabeli D > 0.
    * `formatRealisasiAnggaranBulanIni`: Evaluasi 3 status pos (aman <80%, mendekati 80-100%, melewati >100%), pos sisa terbanyak, dan pos melewati batas terjauh.
  - Unit test TDD di `test/perhitungan/perhitungan_umpan_balik_belajar_test.dart` (7/7 tests passed).
- **Pemeriksa Konten Rusak & Validator Kuis (`lib/fitur/belajar/model/pembaca_konten.dart`):**
  - Validasi objek `contohAngka` (judul, baris array tidak kosong, kesimpulan).
  - Validasi penanda `aturanPraktis` wajib memuat `catatanReviewer` berawalan "TODO-VERIFIKASI".
  - Validasi penolakan teks materi/soal yang memuat formula aturan praktis tanpa penanda resmi.
  - Validasi integritas `pelajaranId` soal kuis ke daftar pelajaran modul, dan syarat `bankSoal.length >= jumlahSoal`.
  - 7 kasus uji baru di `test/fitur/pemeriksa_konten_rusak_test.dart` (total 45 tests passed).
- **Pengujian Widget Baru & Integrasi Emulator (`test/fitur/`, `integration_test/`):**
  - `test/fitur/pemutar_pelajaran_contoh_angka_widget_test.dart`: 4 pengujian widget untuk rendering contohAngka berbaris, umpan balik kartu misi, pengacakan kuis dari bank 10 butir, dan aksesibilitas skala teks 2.0x (bebas overflow).
  - `integration_test/tahap_06_alur_modul_1_emulator_test.dart`: Alur penuh Modul 1 di Pixel 8 (Android 16 API 36), pengerjaan kuis gagal (<80%) lalu lulus (100%), hingga Beranda.
  - Bukti 6 berkas tangkapan layar di `docs/bukti/` dan pengukuran waktu respons Tab Belajar (median 926ms) dan Pemutar Pelajaran (median 802ms).

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
