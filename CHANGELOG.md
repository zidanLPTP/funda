# Catatan Perubahan (Changelog) Funda

Semua perubahan penting pada proyek Funda akan dicatat di dalam dokumen ini.
Format penulisan mengacu pada standar Keep a Changelog dan penamaan commit Funda.

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
