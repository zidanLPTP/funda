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
- **Keputusan:**
  Mulai Tahap 3A, berkas tersebut dipecah ke folder kontroler tiap fitur (`lib/fitur/<fitur>/kontroler/`) agar modularitas kode tetap terjaga seiring bertambahnya fitur anggaran, tujuan, dan kantong.
