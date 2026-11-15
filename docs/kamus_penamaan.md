# Kamus Penamaan Funda

> Sesuai `agent.md` bagian 5. Semua kode yang kita buat sendiri menggunakan **Bahasa Indonesia**.

## Aturan Format Penamaan

| Hal | Aturan | Contoh |
|---|---|---|
| Pesan commit | `jenis: ringkasan` dengan jenis: `fitur`, `perbaikan`, `dokumentasi`, `uji`, `refaktor`, `gaya`, `tugas` | `fitur: tambah transfer antar dompet` |
| Nama cabang | huruf kecil, tanda hubung | `fitur/transfer-antar-dompet` |
| Nama berkas & folder | `snake_case` | `daftar_transaksi.dart`, `hitung_arus_kas.dart` |
| Kelas, enum, ekstensi | `UpperCamelCase` | `Transaksi`, `GerbangData`, `JenisTransaksi` |
| Variabel, fungsi, parameter | `lowerCamelCase` | `hitungArusKas`, `saldoDompet`, `jumlahRupiah` |
| Konstanta | `lowerCamelCase` (gaya Dart) | `ambangLulusKuis`, `batasMaksimalDompet` |
| Tabel & kolom database | `snake_case` | `tabel_transaksi`, `jumlah_rupiah`, `dompet_id` |
| Kunci JSON konten | `lowerCamelCase` | `durasiMenit`, `contohAngka` |
| Komentar & dokumen kode (`///`) | Bahasa Indonesia | |
| Teks antarmuka, pesan galat, log | Bahasa Indonesia | |
| README, CHANGELOG, laporan | Bahasa Indonesia | |

## Daftar Istilah Domain

| Konsep Asal (Inggris) | Nama Kode (Indonesia) | Keterangan / Penggunaan |
|---|---|---|
| wallet | dompet | Wadah akun keuangan / kas / rekening |
| pocket | kantong | Pos alokasi uang di dalam dompet |
| transaction | transaksi | Catatan keluar / masuk / transfer |
| transfer | transfer | Pindah dana antar dompet |
| budget | anggaran | Batas pengeluaran terencana per periode |
| goal | tujuan | Target tabungan untuk hal spesifik |
| debt | utang | Kewajiban pinjaman / cicilan |
| installment | cicilan | Pembayaran berkala untuk utang |
| lesson | pelajaran | Unit materi micro-learning |
| module | modul | Kumpulan pelajaran tematik |
| level | tingkat | Jenjang belajar (Pemula, Menengah, Lanjutan) |
| gate | gerbang | Syarat data sebelum modul/pelajaran terbuka |
| mission | misi | Tindakan praktik nyata menggunakan data pengguna |
| quiz | kuis | Uji pemahaman di akhir modul |
| placement test | tes_awal | Tes mandiri di awal untuk mengetahui profil keuangan |
| sandbox | sandbox | Ruang simulasi terpisah untuk materi non-langsung |
| report | laporan | Ringkasan berkala / bulanan |
| backup | cadangan | Ekspor / impor data lokal |
| net worth | kekayaanBersih | Total aset/saldo dikurangi utang |
| cash flow | arusKas | Pemasukan dikurangi pengeluaran |
| expense need | kebutuhan | Sifat pengeluaran wajib pokok |
| expense want | keinginan | Sifat pengeluaran opsional/gaya hidup |
| savings | tabungan | Sifat pengeluaran simpanan masa depan |
| settings | pengaturan | Konfigurasi aplikasi pengguna |
| empty state | keadaanKosong | Tampilan bila belum ada data |

## Pengecualian
- API bawaan Flutter/Dart/paket eksternal (`StatelessWidget`, `build`, `BuildContext`, `State`, `override`, `dispose`, dll).
- File tergenerate (`*.g.dart`).
