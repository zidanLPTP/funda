# Catatan Perubahan (Changelog) Funda

Semua perubahan penting pada proyek Funda akan dicatat di dalam dokumen ini.
Format penulisan mengacu pada standar Keep a Changelog dan penamaan commit Funda.

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
