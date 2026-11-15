# Catatan Perubahan (Changelog) Funda

Semua perubahan penting pada proyek Funda akan dicatat di dalam dokumen ini.
Format penulisan mengacu pada standar Keep a Changelog dan penamaan commit Funda.

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
