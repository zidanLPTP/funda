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
