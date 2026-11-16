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
| cash | tunai | Jenis dompet fisik uang tunai |
| bank account | rekeningBank (`rekening_bank`) | Jenis dompet akun perbankan |
| e-wallet | eWallet (`e_wallet`) | Jenis dompet dompet digital |
| initial balance | saldoAwalRupiah | Saldo awal pembukaan dompet |
| admin fee | biayaAdminRupiah | Biaya admin transfer antar-dompet |
| transaction time | waktuTransaksi | Waktu pencatatan transaksi |
| expense nature | sifatKategori | Sifat pos pengeluaran (`kebutuhan`, `keinginan`, `tabungan`, `utang`, `belum_dilabeli`, `tidak_berlaku`) |
| balance adjustment | penyesuaianSaldo | Transaksi penyesuaian saldo riil (`penyesuaian_masuk`, `penyesuaian_keluar`) |
| budget limit | batasRupiah | Batas alokasi pengeluaran bulanan per pos kategori |
| copy budget | salinAnggaran | Menyalin seluruh batas anggaran dari periode bulan sebelumnya |
| financial goal | tujuan | Target capaian finansial (`tabungan`, `dana_darurat`, `tujuan_besar`, `lainnya`) |
| emergency fund | danaDarurat | Tujuan dana darurat (maksimal 1 aktif) |
| unallocated balance | saldoBebas | Saldo dompet riil dikurangi total saldo seluruh kantong di dompet tersebut |
| pocket allocation | alokasiKantong | Mutasi penambahan/pengurangan saldo kantong (`isi`, `ambil`, `penyesuaian`) |
| budget realization | realisasiAnggaran | Evaluasi batas vs riil pengeluaran (`aman` < 80%, `mendekati` 80-100%, `melewati` > 100%) |
| debt entity | EntitasUtang (`tabel_utang`) | Entitas data pencatatan utang / kewajiban |
| debt type | jenisUtang | Jenis pinjaman (`kartuKredit`, `paylater`, `kpr`, `kendaraan`, `pinjamanOnline`, `pinjamanPribadi`, `lainnya`) |
| interest type | jenisBunga | Tipe bunga utang (`tetap`, `efektif`, `tanpaBunga`) |
| debt status | statusUtang | Status kelangsungan utang (`aktif`, `lunas`) |
| basis points | basisPoin | Satuan suku bunga per tahun dalam integer (100 bp = 1%, tanpa tipe `double`) |
| remaining debt | sisaRupiah | Sisa pokok / total utang yang belum terbayar |
| debt payment | EntitasPembayaranUtang (`tabel_pembayaran_utang`) | Pembayaran utang yang atomik tertaut ke transaksi pengeluaran |
| debt adjustment | EntitasPenyesuaianUtang (`tabel_penyesuaian_utang`) | Koreksi manual sisa utang (`tambah`, `kurang`) |
| debt ratio | rasioCicilan | Persentase total cicilan bulanan terhadap rata-rata pemasukan 3 bulan terakhir |
| net worth | kekayaanBersih | Nilai bersih finansial (total saldo dompet aktif dikurangi total sisa utang aktif) |
| cursor pagination | ambilTransaksiKursor | Paginasi stabil berbasis kursor komposit `(waktu_transaksi, id)` |
| recurring bill | tagihan | Entitas tagihan / langganan berkala (`TabelTagihan`) |
| bill payment | pembayaranTagihan | Riwayat penandaan tagihan per periode (`TabelPembayaranTagihan`) |
| bill frequency | frekuensiTagihan | Frekuensi jatuh tempo (`mingguan`, `bulanan`, `tahunan`) |
| bill type | jenisTagihan | Jenis pos tagihan (`tagihanRutin`, `langganan`) |
| bill payment status | statusPembayaranTagihan | Status jatuh tempo periode (`sudahDibayar`, `dilewati`) |
| bill due date | jatuhTempo | Tanggal jatuh tempo spesifik tagihan pada periode tertentu |
| local notification | pengingatLokal | Layanan pemberitahuan jadwal jatuh tempo lokal (`LayananPengingat`) |
| inexact alarm | pengingatHematDaya | Jadwal notifikasi ramah baterai tanpa exact alarm permission |
| nominal privacy | privasiNominal | Pengaturan untuk menyembunyikan angka Rupiah pada teks notifikasi |
| first due date | jatuhTempoPertama | Tanggal dasar dimulainya perhitungan kemunculan tagihan (`jatuh_tempo_pertama`) |
| end date | berakhirPada | Tanggal akhir masa berlaku kemunculan tagihan (`berakhir_pada`, inklusif) |
| combined schedule | jadwalGabungan | Penyatuan jadwal tagihan dan cicilan utang bulanan (`gabungkanJadwal`) |
| loan installment item | CicilanUtangKalkulasi | Baris cicilan utang dalam jadwal gabungan dengan status baca-saja |
| reminder days set | pilihanHariPengingatValid | Himpunan hari pengingat valid `{0, 1, 3, 7}` hari sebelum jatuh tempo |
| rule-of-thumb ratio | ambangRasioCicilanAturanPraktis | Batas rasio cicilan aturan praktis (30%) tanpa menghakimi pengguna |
| lesson player | LayarPemutarPelajaran | Pemutar alur micro-learning kartu berurutan |
| module quiz | LayarKuisModul | Layar kuis akhir modul dengan nilai ambang 70% |
| user declaration | tabel_pernyataan | Tabel pernyataan pengguna untuk melewati syarat data |
| lesson progress | tabel_progres_pelajaran | Tabel pencatatan progres per langkah pelajaran |
| mission result | tabel_hasil_misi | Tabel pencatatan status misi pengguna |
| quiz result | tabel_hasil_kuis | Tabel pencatatan riwayat skor kuis pengguna |
| dictionary reader | TeksDenganIstilah | Komponen teks interaktif dengan tooltip kamus |
| learning map | LayarBelajar | Tab Belajar menampilkan peta tingkat, modul, dan pelajaran |
| content reader | PembacaKonten | Utilitas pembaca berkas JSON kurikulum dan kamus |
| continue learning tile | penyediaLanjutBelajarBeranda | Petak Beranda reaktif penunjuk pelajaran siap buka |

## Aturan Cabang Kerja (Git)
- Setiap tahap dikerjakan pada cabang khusus (contoh: `tahap-02-dompet-transaksi`).
- Push cabang ke remote `origin <nama-cabang>`.
- **DILARANG MERGE** ke cabang `main` sebelum pengguna/pemilik menyatakan tahap lolos verifikasi.

## Pengecualian
- API bawaan Flutter/Dart/paket eksternal (`StatelessWidget`, `build`, `BuildContext`, `State`, `override`, `dispose`, dll).
- File tergenerate (`*.g.dart`).
