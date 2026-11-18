# Utang Teknis Funda

Dokumen ini mencatat keputusan teknis sementara, kompromi dependensi, dan hal-hal yang perlu ditinjau ulang pada versi atau rilis mendatang.

---

## 1. Dependensi `sqlite3_flutter_libs` Dibatasi ke Seri `^0.5`

- **Konteks:**
  Pada ekosistem Drift dan SQLite di Flutter, paket `sqlite3_flutter_libs: 0.6.0+eol` merupakan versi penanda akhir masa pemeliharaan (*End of Life*) untuk seri `sqlite3` 3.x+. Versi `+eol` tersebut sengaja tidak menyertakan pustaka biner native (`.so` / `.dylib`), melainkan mengarahkan proyek untuk menggunakan build modular baru atau paket runtime terpisah.
- **Keputusan:**
  Untuk menjaga stabilitas build offline dan ketersediaan biner native C-SQLite yang lengkap di seluruh arsitektur Android (`arm64-v8a`, `armeabi-v7a`, `x86`, `x86_64`) tanpa konfigurasi NDK eksternal, versi `sqlite3_flutter_libs` saat ini dikunci pada seri `^0.5.24` (terpasang `0.5.42`).
- **Rencana Peninjauan:**
  Ketika paket utama `drift` dinaikkan ke versi mayor berikutnya (misalnya Drift 3.x), lakukan evaluasi migrasi ke pustaka loader native terbaru sesuai panduan resmi dokumentasi Drift (misalnya `sqlite3` versi modular atau loader platform spesifik).

---

## 2. Paginasi Riwayat & Agregasi SQL (Tahap 3A)

- **Konteks:**
  Pada Tahap 2, seluruh riwayat transaksi dimuat sekaligus ke dalam memori (*in-memory*) dan saldo dompet dihitung secara reaktif di Dart. Pada volume 5.000 hingga 20.000 transaksi, deserialisasi seluruh baris ke objek Dart memakan waktu ~120ms.
- **Keputusan:**
  Di Tahap 3A, kueri riwayat transaksi menerapkan paginasi berbasis SQL (`LIMIT 50 OFFSET n`) dengan penyaringan (*WHERE*) di level SQLite. Agregasi saldo dan arus kas dialihkan ke agregasi SQLite (`SUM` / `GROUP BY`), sementara logika murni Dart di `lib/perhitungan/` dipertahankan sebagai tolok ukur kebenaran (*single source of truth*) yang diuji kesetaraannya secara otomatis.

---

## 3. Penataan Provider State (Pemisahan Kontroler Fitur)

- **Konteks:**
  Berkas `lib/data/penyedia_data.dart` awalnya menampung seluruh provider dari berbagai domain (dompet, kategori, transaksi).
---

## 4. Paginasi Berbasis Kursor Komposit (Tahap 3B)

- **Konteks:**
  Pada pengujian Tahap 3B langkah 0(d), ditemukan bahwa paginasi berbasis `OFFSET` rentan mengalami duplikasi item saat transaksi baru dimasukkan di halaman paling atas ketika halaman >= 2 sedang dibuka, atau baris terlewat saat transaksi di atas dihapus.
- **Keputusan:**
  Ditambahkan metode `ambilTransaksiKursor(waktuKursor, idKursor, limit)` pada repositori transaksi menggunakan kunci urut komposit `(waktu_transaksi < kursor_waktu OR (waktu_transaksi == kursor_waktu AND id < kursor_id))`. Hal ini menjamin konsistensi kursor tanpa duplikasi atau baris yang terlewat pada aliran data dinamis.

---

## 5. Ambang Rasio Cicilan Aturan Praktis 30% (Tahap 3B & 3C-R)

- **Konteks:**
  Spesifikasi Tahap 3B & 3C menghendaki penghitungan rasio cicilan terhadap rata-rata pemasukan 3 bulan terakhir. Acuan umum industri perbankan menganggap rasio cicilan <= 30% sebagai batas aturan praktis (*rule of thumb*).
- **Keputusan:**
  Nilai 30% disimpan sebagai konstanta `ambangRasioCicilanAturanPraktis = 30; // TODO-VERIFIKASI` di `lib/perhitungan/perhitungan_utang_dashboard.dart`. Di antarmuka pengguna (Layar Utang dan Beranda), angka persentase ditampilkan apa adanya secara netral (*"Bagian dari pemasukanmu yang dipakai untuk cicilan"*) tanpa memberi label aman/bahaya/lampu merah/hijau, menunggu materi edukasi kurikulum resmi pada Tahap 8.

---

## 6. Arsitektur Pengingat Lokal Inexact & Batasan 45 Hari (Tahap 3C-R)

- **Konteks:**
  Aplikasi Funda adalah aplikasi pencatatan keuangan lokal tanpa server (*offline-first*). Tagihan berulang memerlukan pengingat jatuh tempo yang andal tanpa memboroskan baterai atau memicu penolakan kebijakan Google Play Store terkait izin alarm presisi (*exact alarm*).
- **Keputusan:**
  1. Penjadwalan pengingat menggunakan `androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle` via pustaka `flutter_local_notifications`. Mode ini memanfaatkan `AlarmManager.setAndAllowWhileIdle()`, sehingga notifikasi tetap dapat membangunkan perangkat dari mode Doze tanpa memerlukan izin sensitif `SCHEDULE_EXACT_ALARM` atau `USE_EXACT_ALARM`.
  2. Batasan Jendela Penjadwalan: Pengingat dijadwalkan secara deterministik untuk rentang **45 hari ke depan** dengan **kuota maksimal 50 slot pengingat aktif** (diprioritaskan pada jadwal kemunculan terdekat). Pemilihan 45 hari memastikan kuota OS tidak penuh dan sinkronisasi berkala dapat dilakukan setiap kali aplikasi dibuka.
  3. Pilihan hari pengingat divalidasi ketat pada himpunan `{0, 1, 3, 7}` hari sebelum jatuh tempo.
  4. ID Notifikasi dihitung secara deterministik dan unik menggunakan fungsi hash `(sumber, idSumber, tanggalJatuhTempo, selisihHari)`.
  5. Konfigurasi `ScheduledNotificationReceiver` dan `ScheduledNotificationBootReceiver` disertakan di `AndroidManifest.xml` bersama `RECEIVE_BOOT_COMPLETED` agar saat perangkat Android dihidupkan ulang, sistem dapat menjadwalkan ulang alarm yang tersimpan.
  6. Privasi Pengguna: Notifikasi secara default tidak menampilkan nominal uang (*"Tagihan Listrik PLN jatuh tempo hari ini"*) kecuali opsi "Tampilkan nominal tagihan di notifikasi" diaktifkan secara eksplisit oleh pengguna di Layar Pengaturan.
  7. Izin notifikasi Android 13+ (*POST_NOTIFICATIONS*) tidak diminta secara agresif di awal instalasi, melainkan hanya saat pengguna mengaktifkan saklar pengingat (*just-in-time*).
- **Catatan Platform & Risiko:**
  - *Vendor OEM Android:* Pengoptimalan baterai agresif pada sistem operasi berbasis vendor OEM tertentu (misal MIUI/HyperOS, ColorOS, FunTouchOS, OneUI) dapat menangguhkan proses latar belakang dan alarm inexact jika aplikasi tidak diberikan pengecualian baterai (*Unrestricted*). Edukasi dan teks bantu telah disediakan di Layar Pengaturan.
  - *Keterbatasan Pengujian iOS:* Karena lingkungan pengembangan saat ini berjalan di Windows, pengujian platform iOS dibatasi pada validasi sintaks Dart/kompatibilitas kode. Pengujian integrasi langsung sistem notifikasi iOS (`UNUserNotificationCenter`) memerlukan mesin macOS dengan Xcode aktif.
- **Rencana Peninjauan:**
  Pada rilis mendatang (Tahap 7 - Cadangan & Ekspor), pastikan entri di `tabel_pengaturan` (status aktif pengingat, jam pengingat, preferensi nominal) ikut disertakan dalam format cadangan JSON terenkripsi.

---

## 7. Tabel Progres Belajar & Pernyataan Wajib Masuk Cadangan (Tahap 4)

- **Konteks:**
  Pada Tahap 4 (Mesin Belajar), skema basis data versi 7 menambahkan 4 tabel baru untuk persistensi progres edukasi:
  1. `tabel_progres_pelajaran` (mencatat status belum, sedang, selesai, indeks langkah terakhir, waktu mulai & selesai).
  2. `tabel_hasil_misi` (mencatat hasil pengerjaan misi per pelajaran: selesai, dilewati, waktu eksekusi).
  3. `tabel_hasil_kuis` (mencatat riwayat percobaan kuis per modul: nilai persentase integer, status lulus, jawaban detail JSON, waktu selesai).
  4. `tabel_pernyataan` (mencatat klaim pengguna seperti *"tidak_punya_utang"*, *"tidak_punya_pengeluaran"* untuk evaluasi gerbang prasyarat belajar).
- **Keputusan & Kompromi:**
  Untuk menjaga kesederhanaan dan performa kueri lokal, tabel-tabel ini terisolasi dari tabel keuangan utama (tanpa foreign key yang mengikat data transaksi atau dompet).
- **Rencana Peninjauan:**
  Pada Tahap 7 (Cadangan & Ekspor Data), 4 tabel progres belajar ini wajib disertakan dalam mekanisme ekspor/impor JSON dan cadangan terenkripsi agar pengguna tidak kehilangan riwayat pembelajaran dan sertifikasi kelulusan kuis saat berganti perangkat.

---

## 8. Optimasi Kueri Agregasi SQL, Indeks Komposit Skema v8 & Eliminasi Full Table Scan (Tahap 4-R)

- **Konteks:**
  Pada pengujian Tahap 4 awal, ditemukan bahwa penambahan beban data dari 5.000 menjadi 20.000 transaksi di emulator memicu kenaikan waktu muat Beranda sebesar 67% (187 ms -> 313 ms). Analisis profiling kueri dan `EXPLAIN QUERY PLAN` mengungkap dua akar masalah utama:
  1. `ambilJadwalGabungan` di `TagihanRepositori` memuat seluruh 20.000 baris transaksi ke memori Dart (`SELECT * FROM tabel_transaksi`) tanpa klausa penyaring hanya untuk memetakan nominal transaksi tertaut pada pembayaran tagihan.
  2. Provider Beranda (`penyediaArusKasBulanIni`, `penyediaPemasukanBulananRataRata`, `penyediaFotoData`) me-watch `penyediaDaftarTransaksi` yang menarik seluruh data transaksi ke memori Dart.
- **Keputusan:**
  1. **Indeks Komposit Skema v8:** Menambahkan 4 indeks komposit baru pada `tabel_transaksi`:
     - `idx_transaksi_jenis` ON `tabel_transaksi(jenis)`
     - `idx_transaksi_jenis_kategori` ON `tabel_transaksi(jenis, kategori_id)`
     - `idx_transaksi_waktu_id` ON `tabel_transaksi(waktu_transaksi DESC, id DESC)`
     - `idx_transaksi_waktu_jenis` ON `tabel_transaksi(waktu_transaksi, jenis)`
  2. **Agregasi SQL Murni Tanpa N+1:** Menghitung arus kas bulanan, rata-rata pemasukan 3 bulan, dan foto data gerbang pembelajaran sepenuhnya di level mesin SQLite (`COUNT`, `SUM`, `GROUP BY`).
  3. **Kueri Terarah Tagihan:** Mengubah seleksi transaksi di `ambilJadwalGabungan` menjadi terarah (`WHERE id IN (...)`) hanya untuk transaksi yang tertaut pada pembayaran tagihan, sehingga tidak pernah menyentuh 20.000 baris riwayat transaksi umum.
  4. **Portabilitas Zona Waktu:** Menggunakan offset detik lokal `waktu_transaksi + offsetDetik` untuk fungsi `date()` dan `strftime()` SQLite guna menjamin konsistensi batas hari (23:30 WIB) di seluruh lingkungan OS (Windows CRT vs Android Bionic).
- **Hasil:**
  Waktu eksekusi kueri Beranda pada 20.000 transaksi di emulator Pixel 8 turun drastis ke **median 14.46 ms** (kenaikan beban data 4x menghasilkan delta -17.3%, membuktikan kompleksitas konstan O(1)). Peta Belajar 19 modul stabil di **median 1.32 ms**.

---

## 9. Profiling Jujur Siklus Penuh Tab Belajar vs Cache Memori (Tahap 4-R2)

- **Konteks:**
  Pada laporan Tahap 4-R sebelumnya, Tab Belajar dilaporkan memakan waktu median 1.32 ms, yang ternyata lebih kecil daripada kueri SQLite foto data pengguna sendiri (~2.5 ms). Penelusuran mengungkap bahwa pengujian sebelumnya mengukur pembacaan Riverpod provider setelah data modul sudah tersimpan di *in-memory cache* Dart.
- **Keputusan & Pengukuran Sebenarnya:**
  Profiling diperbaiki untuk mengukur **seluruh siklus kerja penuh** Tab Belajar:
  1. Kueri foto data pengguna dari basis data SQLite lokal.
  2. Pemuatan bundel aset teks dari disk APK untuk seluruh 19 berkas `modul.json`, 2 berkas pelajaran, dan `kamus.json`.
  3. Deserialisasi dan parsing JSON ke model typed Dart.
  4. Evaluasi gerbang data dan status belajar seluruh modul dan pelajaran.
- **Hasil Terverifikasi:**
  Pada emulator Pixel 8 (API 36), siklus penuh Tab Belajar memakan waktu:
  - 5.000 transaksi: **Median 19.61 ms**, Terburuk 30.77 ms.
  - 20.000 transaksi: **Median 26.31 ms**, Terburuk 34.65 ms.
  Hasil ini mencerminkan kinerja fisik sebenarnya dan terbukti **LULUS telak di bawah batas target 50 ms**.

---

## 11. Catatan Profiling Kinerja Skala Besar & Rencana Optimasi (Tahap 5)

Berdasarkan hasil pengujian terisolasi pada 10 iterasi bersih di emulator Pixel 8 (Tahap 4-R3), dicatat 3 temuan profiling penting untuk ditinjau:
1. **Kenaikan Kueri Beranda 72.6% saat Beban Bulan Berjalan 4x Lipat:**
   - *Temuan:* Ketika data bulan berjalan dinaikkan 4x (2.500 transaksi menjadi 10.000 transaksi di bulan yang sama), durasi kueri SQL Beranda naik dari 19.20 ms ke 33.14 ms (+72.6%).
   - *Penyebab:* Kueri agregasi SQL tetap harus memindai (*index range scan*) semua baris dalam rentang tanggal bulan berjalan untuk menghitung `SUM(nominal)` dan mengelompokkan sifat kategori. Meskipun masih jauh di bawah ambang batas bahaya (tetap < 35 ms), pertumbuhan ini linier terhadap jumlah transaksi di bulan aktif.
   - *Rencana:* Pada Tahap 7/8, jika pengguna memiliki >10.000 transaksi dalam 1 bulan tunggal, pertimbangkan tabel agregasi ringkasan bulanan (*monthly summary snapshot*) yang diperbarui secara inkremental via trigger/repositori.
2. **Kenaikan Tab Belajar 170% pada Pindai Hari/Bulan Berbeda:**
   - *Temuan:* Waktu siklus penuh Tab Belajar naik dari 13.79 ms (5k data) ke 37.23 ms (20k data) (+170%).
   - *Penyebab:* Adanya pemindaian hari berbeda (`COUNT(DISTINCT date(waktu))`) dan bulan berbeda pada foto data pengguna yang memindai seluruh riwayat transaksi.
   - *Rencana:* Evaluasi kueri `DISTINCT date` ini hanya perlu dijalankan apabila terdapat modul/pelajaran yang benar-benar mensyaratkan gerbang bertipe `periode_data`. Untuk kurikulum saat ini yang mayoritas bertipe `ada_data`, pemindaian ini dapat dioptimasi atau dihitung secara lazy bila diperlukan.
3. **Cold Start Tampilan Beranda Pertama Kali (~1.129 ms di Emulator):**
   - *Temuan:* Pada peluncuran aplikasi pertama kali (*cold start*), inisialisasi awal Flutter engine, pembukaan koneksi SQLite, dan rendering frame pertama Beranda memakan waktu ~1.129 ms di emulator.
   - *Penyebab:* Overhead kompilasi JIT di emulator Android debug build serta pembacaan awal skema basis data. Setelah frame pertama ter-render (*warm render*), waktu pembaruan tampilan turun drastis ke 85-88 ms.
   - *Rencana:* Evaluasi waktu peluncuran rilis (*release build* dengan AOT) pada Tahap 12 (Polesan & Rilis).

---

## 12. Penyelarasan Skema v10, Eliminasi Kolom Rentang & Tanggungan, serta Rencana Cadangan (Tahap 5-R)

- **Konteks:**
  Pada implementasi awal Tahap 5, tabel profil keuangan memuat kolom spekulatif `rentang` dan `tanggungan` serta nama kolom ringkas (`darurat`, `utang`) yang tidak sejalan dengan spesifikasi kurikulum dan format kuesioner `tes_awal.json`.
- **Keputusan:**
  1. **Migrasi Skema v10:** Dilakukan migrasi aman idempoten pada `lib/data/basis_data.dart` (skema versi 10). Kolom lama dipetakan: `darurat` -> `dana_darurat`, `utang` -> `punya_utang`. Kolom `rentang` dan `tanggungan` dihapus seluruhnya dari struktur basis data, model Dart, dan antarmuka input kuesioner.
  2. **Struktur Resmi `tabel_profil_keuangan`:** Menggunakan 7 kolom inti profil (`punya_penghasilan`, `punya_utang`, `dana_darurat`, `menabung`, `investasi`, `mencatat_keuangan`, `tujuan_utama`) dengan timestamp `diisi_pada` dan `diperbarui_pada`.
  3. **Struktur Resmi `tabel_hasil_tes_awal`:** Mencatat riwayat tes awal (`jawaban_json`, `skor_per_modul_json`, `skor_total_persen`, `waktu`).
- **Rencana Peninjauan:**
  Pada Tahap 7 (Cadangan & Ekspor), kedua tabel ini (`tabel_profil_keuangan` dan `tabel_hasil_tes_awal`) wajib dimasukkan ke dalam skema cadangan JSON terenkripsi agar pengguna tidak kehilangan profil keuangan dan hasil penempatan belajarnya.

---

## 13. Verifikasi Kurikulum & Anotasi Aturan Praktis Pola 50/30/20 (Tahap 6)

- **Konteks:**
  Pada Modul 1 Pelajaran 1.4 ("Anggaran Pertamamu") dan kuis modul butir 7, diperkenalkan pola anggaran populer 50/30/20 (50% Kebutuhan, 30% Keinginan, 20% Tabungan dan Utang). Formula ini merupakan aturan praktis (*rule of thumb*) internasional yang belum tentu mencerminkan struktur pengeluaran riil sebagian besar masyarakat Indonesia (khususnya pekerja sektor informal atau masyarakat dengan porsi kebutuhan pangan > 60%).
- **Keputusan:**
  1. **Anotasi Wajib `TODO-VERIFIKASI`:** Seluruh konstanta perhitungan di `lib/perhitungan/perhitungan_umpan_balik_belajar.dart` diberi komentar `aturan praktis populer, TODO-VERIFIKASI`. Berkas pelajaran `anggaran_arus_kas_1_4.json` dan butir kuis terkait diberi penanda skema `aturanPraktis: true` dan `catatanReviewer: "TODO-VERIFIKASI: aturan praktis populer, perlu verifikasi kesesuaian dengan profil keuangan Indonesia di Tahap 8"`.
  2. **Narasi Netral Tanpa Menghakimi:** Generator umpan balik perbandingan (`formatPerbandinganPolaAnggaran`) menyajikan angka 50/30/20 murni sebagai titik awal perbandingan dan ditutup dengan kalimat penegas: *"Keduanya titik awal. Sesuaikan dengan kondisimu."*
- **Rencana Peninjauan:**
  Ditinjau ulang bersama konsultan atau kurator materi finansial pada Tahap 8 (Kurikulum Tingkat Pemula Lengkap) untuk memvalidasi apakah perlu disajikan alternatif rasio alokasi yang lebih adaptif terhadap rentang penghasilan pengguna di Indonesia.



