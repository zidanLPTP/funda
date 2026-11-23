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

---

## 14. Penyelarasan Lampiran Resmi & Profiling Waktu Respons UI (Tahap 6-R)

- **Konteks:**
  Pada implementasi awal Tahap 6, terdapat dua kalimat pesan gerbang pada pelajaran 1_4 dan 1_5 yang menggunakan ringkasan kalimat bebas alih-alih teks lampiran resmi reviewer (`docs/materi/modul_1_anggaran_arus_kas.md`). Selain itu, laporan awal Tahap 6 mencatat durasi Tab Belajar sebesar 926 ms dan Pemutar Pelajaran 802 ms, yang ternyata disebabkan oleh stopwatch test harness yang mengikutsertakan sleep waktu frame buatan (`pompaAman(tester, 300)`).
- **Keputusan:**
  1. **Kesesuaian Teks Kata demi Kata:** Teks kedua pesan gerbang diselaraskan 100% dengan lampiran:
     - 1_4: `"Catat transaksi di minimal 7 hari kalender berbeda."` dan `"Catat minimal satu pemasukan bulan ini."`
     - 1_5: `"Buat minimal satu anggaran bulan ini."` dan `"Catat minimal satu pengeluaran."`
     Suite pengujian otomatis `test/konten/kesesuaian_lampiran_test.dart` ditambahkan untuk memastikan tidak ada perubahan kata tanpa persetujuan.
  2. **Format Tanda Minus Rapat U+2212:** Format nominal negatif pada tabel contoh angka dan umpan balik edukatif distandarkan menggunakan minus Unicode U+2212 sebelum "Rp" tanpa spasi (`−Rp900.000`).
  3. **Profiling Realistis:** Pengujian profiling di Android 16 (API 36) pada volume 5.000 dan 20.000 transaksi membuktikan bahwa komputasi murni logika bisnis dan kueri SQL Tab Belajar hanya memerlukan 25–43 ms (5 kueri SQL teragregasi bebas N+1). Namun, waktu foto data naik dari 20,55 ms ke 35,15 ms (+71%) saat data bertambah 4x (perilaku sub-linear pemindaian indeks SQLite, bukan strictly konstan O(1)). Selain itu, durasi "Render build widget UI" berkisar 340 hingga 353 ms di emulator.
- **Rencana Peninjauan:**
  Pada Tahap 8 (Kurikulum Lengkap Pemula), seluruh berkas pelajaran baru wajib melalui pipeline validasi kesesuaian lampiran otomatis sebelum merge. Durasi "Render build widget UI" (340–353 ms) perlu diukur ulang pada perangkat HP fisik sungguhan di Tahap 12 setelah memastikan jeda buatan harness test tidak ikut terukur.

---

## 16. Penyelarasan Pengujian Anti-Menggantung & Agregasi SQL Laporan (Tahap 7-R)

- **Konteks:**
  1. *Masalah Pengujian Menggantung:* Pemanggilan `pumpAndSettle()` tanpa batas waktu dapat menunggu hingga 10 menit bila widget memiliki animasi tak terbatas (`CircularProgressIndicator`/`LinearProgressIndicator`) atau timer aliran data yang tertahan di dalam `FakeAsync`. Selain itu, pemanggilan `Future.delayed()` sebagai penunggu data asinkron menyebabkan flakiness pengujian.
  2. *Skalabilitas Foto Data:* Waktu foto data pengguna naik dari 20,55 ms (5.000 tx) ke 35,15 ms (20.000 tx), mencatat kenaikan +71% saat data bertambah 4x (perilaku sub-linear indeks SQLite, bukan strictly konstan O(1)).
  3. *Bottleneck Deserialisasi Laporan:* Pada implementasi awal, penyusunan laporan bulanan memuat seluruh 20.000 transaksi ke memori Dart (`select(tabelTransaksi).get()`) untuk menghitung saldo dompet dan komposisi per sifat, menghabiskan waktu 455 ms di host.
- **Keputusan:**
  1. **Helper Terpusat & Komponen Anti-Animasi:** Berkas `test/pembantu/pompa_uji.dart` dijadikan SATU-SATUNYA tempat pemanggilan `pumpAndSettle` dengan batas waktu pendek (5 detik). Semua progress indicator dialihkan ke `IndikatorMemuat` yang membaca provider `penyediaTanpaAnimasi` (saat pengujian bernilai `true`, progress bar berprogres tetap sehingga bebas ticker tak terbatas).
  2. **Batas Waktu Suite 30 Detik:** Seluruh berkas uji widget diikat oleh anotasi `@Timeout(Duration(seconds: 30))` dan `dart_test.yaml`. Suite `test/penjaga/aturan_pengujian_test.dart` secara otomatis mendeteksi pelanggaran.
  3. **Agregasi SQL Murni:** Seluruh penghitungan komposisi per sifat dan per kategori dialihkan ke kueri SQL `GROUP BY`, dan saldo dompet menggunakan `hitungSaldoDompetSQL`. Waktu komputasi susun laporan terpangkas dari 458 ms menjadi 10.3 ms di host.
- **Rencana Peninjauan:**
  1. *Sub-Linear Foto Data (+71% pada data x4):* Terus pantau pada volume data 50.000 transaksi di Tahap 8/12 untuk memastikan indeks komposit `idx_transaksi_waktu` tetap optimal.
  2. *Pengukuran Ulang Render Build UI di HP Sungguhan (Tahap 12):* Durasi "Render build widget UI" (340–353 ms) di emulator perlu diukur ulang pada perangkat Android/iOS fisik di Tahap 12 setelah memastikan jeda buatan harness test tidak ikut terukur.


- **Konteks:**
  Pada Tahap 7, fitur cadangan data diekspor sebagai JSON teks terbuka kanonikal dengan ringkasan integritas SHA-256 deterministik. Berkas ini mencakup seluruh tabel pengguna (transaksi, utang, anggaran, profil, progres belajar).
- **Keputusan:**
  1. **Transparansi & Portabilitas Teks Terbuka:** Berkas cadangan sengaja tidak dienkripsi dengan kata sandi demi portabilitas, transparansi data, dan menghindari risiko kehilangan data permanen bila pengguna lupa kata sandi lokal (sejalan dengan model *local-first auditability*). Pengguna diberi peringatan eksplisit (*"Berkas cadangan berisi seluruh data keuanganmu dan tidak dienkripsi. Simpan hanya di tempat yang aman."*).
  2. **Integritas Atomik SQLite:** Pemulihan cadangan memanfaatkan transaksi atomik SQLite dengan penangguhan foreign keys (`PRAGMA defer_foreign_keys = ON;`) dan verifikasi integritas relasional (`PRAGMA foreign_key_check;`) di akhir transaksi. Jika gagal di tengah proses, seluruh perubahan dibatalkan (*rollback*).
  3. **Cadangan Keselamatan Otomatis:** Sebelum proses pemulihan mengeksekusi penghapusan data lama, dibuat cadangan keselamatan internal otomatis (`sebelum_pemulihan.json`) di direktori dokumen aplikasi agar data pengguna dapat dikembalikan kapan saja.
  4. **Nonaktifkan Kotlin Incremental di Multi-Drive Windows:** Pengaturan `kotlin.incremental=false` disetel di `android/gradle.properties` untuk mencegah bug kompilasi Kotlin Gradle Plugin pada lingkungan Windows di mana berkas proyek berada pada partisi `D:` sementara cache pub global berada pada partisi `C:`.
- **Rencana Peninjauan:**
  Pada rilis pasca-MVP (misalnya Tahap 9 atau versi 1.1), evaluasi penambahan fitur ekspor terenkripsi opsional (AES-GCM 256-bit berbasis kata kunci yang ditentukan pengguna) bagi pengguna tingkat lanjut yang ingin mengunggah cadangan ke penyedia cloud publik.

---

## 17. Penghapusan Dependency Overrides `image: 4.10.2` (Tahap 8A Langkah 0d)

- **Konteks & Alasan:**
  Pada Tahap 7, `dependency_overrides: image: 4.10.2` sempat ditambahkan ke `pubspec.yaml` untuk mengatasi resolusi transitif pemrosesan gambar laporan. Pada Tahap 8A, dependensi pustaka `pdf`, `qr`, dan ekosistem Flutter telah memperbarui batasan versinya sehingga Dart pub resolver mampu menyelesaikan grafik dependensi secara normal (*clean resolution*) tanpa pemaksaan. Blok `dependency_overrides` dicabut agar dependensi aplikasi tetap bersih dan tidak menutupi potensi konflik dependensi di masa depan.
- **Kapan Boleh Dipasang Kembali:**
  Blok `dependency_overrides` HANYA boleh dipasang kembali dalam keadaan darurat teknis sementara jika terjadi *breaking change* atau tabrakan versi mayor antar-pustaka pihak ketiga di ekosistem pub yang menyebabkan `flutter pub get` gagal total, dan harus dicabut kembali segera setelah pustaka upstream terkait merilis pembaruan perbaikan.
- **Status:** Tuntas / Ditutup pada Tahap 8A.

---

## 18. Evaluasi Akar Masalah Pengukuran 1.910 ms Buka Layar Laporan di Emulator (Tahap 8A Langkah 0a)

- **Konteks:**
  Laporan Tahap 7 mencatat durasi *"Waktu Buka Layar Laporan Sampai Tampil: 1.910 ms"* pada benchmark emulator dengan 20.000 transaksi. Angka ini awalnya dikhawatirkan sebagai masalah kinerja render UI atau komputasi query.
- **Temuan Investigasi:**
  Pemeriksaan pada `integration_test/tahap_07_laporan_dan_cadangan_emulator_test.dart` baris 499–514 membuktikan bahwa stopwatch mengukur blok:
  ```dart
  final swRenderUi = Stopwatch()..start();
  await tester.pumpWidget(...);
  await pompaAman(tester, 800);
  swRenderUi.stop();
  ```
  Fungsi `pompaAman(tester, 800)` mengeksekusi `await tester.pump(800ms)` sebanyak 2 kali berturut-turut (1.600 ms tidur simulasi harness pengujian). Jadi, dari total 1.910 ms yang tercatat, **1.600 ms adalah jeda buatan harness test**, sedangkan komputasi agregasi SQL dan rendering widget aktual aplikasi hanya memakan waktu **~310 ms**.
- **Tindakan Lanjutan:**
  Harness benchmark emulator berikutnya dipisahkan secara tegas antara pengukuran komputasi kueri/render dan jeda frame simulasi pump agar tidak bias oleh tidur buatan harness.

---

## 19. Investigasi Gradle Daemon JVM Mismatch dan Arsitektur Kueri On-Demand Utang Belajar (Tahap 8B)

- **Konteks & Akar Masalah Gradle Daemon (Langkah 0a):**
  Pada eksekusi pengujian integrasi emulator di mesin Windows pengguna, sempat teramati proses Gradle berjalan sangat lama atau keluar mendadak dengan asynchronous gap pada `AndroidDevice.startApp`.
  Investigasi mendalam pada log Gradle (`C:\Users\M S I\.gradle\daemon\8.14\`) dan lingkungan JDK menemukan penyebab utama:
  1. Terdapat beberapa instalasi Java berbeda di mesin host: JBR Android Studio (`jdk-21.0.10`), Adoptium OpenJDK (`21.0.11`), dan Oracle JDK (`jdk-21`).
  2. Ketika environment `JAVA_HOME` tidak di-pin secara eksplisit ke instalasi JBR Android Studio yang kompatibel dengan Android Gradle Plugin, Gradle mendeteksi *incompatible JVM* dan menolak me-reuse daemon yang ada (`3 incompatible and 13 stopped Daemons could not be reused`), lalu men-spawn daemon baru secara berulang.
  3. Pemanggilan `powershell -ExecutionPolicy Bypass -File .\tool\jalankan_test_dan_tangkapan_layar_tahap_08b.ps1` yang mengeksekusi `flutter test` di latar belakang tanpa jendela terlihat membuat pengguna menunggu tanpa kejelasan progres log.
  4. Penyelesaian: Skrip `tool/jalankan_test_dan_tangkapan_layar_tahap_08b.ps1` kini menetapkan fallback `$env:JAVA_HOME` ke jalur JBR Android Studio (`"C:\Program Files\Android\Android Studio\jbr"`) bila belum disetel di lingkungan pengguna.
  *Catatan Portabilitas Lingkungan:* Penetapan jalur JBR ini disesuaikan khusus untuk mesin pengembang lokal Windows ini. Pada mesin lain atau lingkungan CI/CD, pengembang dapat menyetel variabel lingkungan `JAVA_HOME` sistem secara global atau menyesuaikan jalur JDK di awal skrip powershell tersebut agar menunjuk ke instalasi JDK yang kompatibel dengan Gradle Android.

- **Arsitektur Kueri On-Demand Utang Belajar vs Foto Data Agregat:**
  Pada kurikulum Modul 4 ("Utang & Cicilan"), terdapat 4 kartu umpan balik yang membutuhkan data rincian baris utang aktif (`nama`, `pokok`, `sisa`, `cicilan`, `tenor`, `bunga`, `jenis_bunga`).
  Untuk menjaga kinerja Tab Belajar dan Beranda tetap berkecepatan konstan O(1) di bawah 50 ms pada beban 20.000 transaksi + 20 utang:
  1. `FotoDataRepositori` (`ambilFotoData`) TIDAK menambahkan kueri baru dan tetap mempertahankan **11 kueri tunggal teroptimasi** (`jumlahTransaksi`, `jumlahAkun`, `jumlahKategori`, `jumlahAnggaran`, `jumlahTujuanTabungan`, `jumlahDanaDarurat`, `jumlahUtang`, `jumlahTagihan`, `rataRataPemasukan3Bulan`, `arusKasBulanIni`, `persentasePengeluaranWajib`).
  2. Data rincian baris utang ditarik secara **On-Demand** oleh `penyediaTeksUmpanBalikMisi` melalui `UtangRepositori.ambilDaftarUtangUmpanBalik()` HANYA saat pengguna benar-benar membuka kartu pelajaran mikro terkait.
  3. Dengan pemisahan ini, Tab Belajar dan Peta Belajar utama tidak terbebani pemuatan baris utang, dan hasil benchmark pada 20.000 transaksi + 20 utang membuktikan waktu komputasi median tetap stabil di **57 ms** dan frame pertama di **18 ms**.

---

## 20. Rekaman Status Misi di `tabel_hasil_misi` dan Riwayat Retroaktif (Tahap 8C)

- **Konteks:**
  Sebelum Tahap 8C, `tabel_hasil_misi` hanya diisi oleh tipe misi tertentu atau saat misi dilewati (`status: 'dilewati'`). Pada Tahap 8C, diperkenalkan dua tipe misi baru (`keputusan` dan `daftar_periksa`) yang mencatat muatan jawaban pengguna (`muatan_json`) ke `tabel_hasil_misi`.
- **Keputusan & Kebijakan:**
  Mulai Tahap 8C, **SEMUA tipe misi** (`ada_data`, `aturan_data`, `lihat_hitungan`, `keputusan`, `daftar_periksa`) secara konsisten menulis baris `status: 'selesai'` ke `tabel_hasil_misi` ketika misi berhasil diselesaikan oleh pengguna (bidang `muatan_json` bernilai `null` untuk tiga tipe misi lama yang berbasis data riil).
- **Batasan Retroaktif:**
  Penyelesaian pelajaran/misi yang terjadi pada basis data sebelum Tahap 8C tidak memiliki baris retroaktif di `tabel_hasil_misi`. Sumber kebenaran mutlak status *"Pelajaran Selesai tidak terkunci ulang"* tetap merujuk pada `tabel_progres_pelajaran` (`status: 'selesai'`), sehingga modul dan pelajaran yang telah selesai sebelum Tahap 8C tetap berstatus selesai dan tidak terpengaruh oleh ketiadaan baris lama di `tabel_hasil_misi`.

---

## 21. Desain Privasi Misi Refleksi & Kueri On-Demand Langganan/Keinginan (Tahap 8D)

- **Konteks & Privasi Misi Refleksi:**
  Pada Modul 6 ("Psikologi Uang & Kebiasaan Belanja"), pengguna diajak mengenali pemicu belanja emosional dan menetapkan aturan jeda melalui tipe misi `refleksi`. Teks jawaban pengguna bersifat sangat personal dan sensitif.
- **Keputusan:**
  1. Jawaban refleksi disimpan secara lokal murni di `tabel_hasil_misi` dalam kolom `muatan_json` (`{"jawaban": "..."}`).
  2. Aplikasi Funda tidak memiliki backend server, analitik eksternal, atau pelacak pihak ketiga, sehingga data teks tidak pernah meninggalkan perangkat.
  3. UI Kartu Misi Refleksi menyertakan pemberitahuan transparan: *"Privat di perangkatmu: tulisan ini hanya tersimpan di HP-mu dan tidak pernah dikirim ke mana pun."*
- **Kueri On-Demand Langganan & Pengeluaran Keinginan:**
  Fungsi umpan balik `ringkasan_langganan_dan_keinginan` memerlukan data tagihan aktif dan akumulasi pengeluaran pos keinginan bulan berjalan. Kueri ini dieksekusi secara *on-demand* oleh `penyediaTeksUmpanBalikMisi` hanya saat kartu pelajaran 6.2 dibuka, sehingga Tab Belajar utama dan Beranda tetap beroperasi menggunakan agregasi SQL cepat tanpa pemuatan data tidak perlu.








