# Format Berkas Cadangan Data Funda (`docs/format_cadangan.md`)

Dokumen ini mendefinisikan spesifikasi format berkas cadangan data lokal aplikasi Funda.

---

## 1. Ikhtisar & Filosofi Desain

Funda adalah aplikasi edukasi dan pencatatan keuangan pribadi yang sepenuhnya berjalan di perangkat pengguna (*local-first*), tanpa ketergantungan pada server komputasi awan (*cloudless*) dan tanpa analitik pihak ketiga. Selaras dengan prinsip privasi dan kedaulatan data pengguna:
1. **Kepemilikan Penuh Pengguna:** Seluruh data catatan keuangan dapat diekspor kapan saja ke berkas JSON mandiri dan dibagikan/disimpan ke penyimpanan pilihan pengguna (Google Drive pribadi, memori lokal, email, dll.).
2. **Keterbacaan Standar (Open Standard):** Format cadangan berbasis JSON teks murni UTF-8 sehingga mudah diperiksa secara transparan (*auditable*).
3. **Integritas Deterministik:** Menggunakan ringkasan kriptografis SHA-256 untuk memverifikasi bahwa berkas tidak rusak atau terpotong saat pengiriman.
4. **Keamanan Transaksional (ACID):** Pemulihan data dijalankan dalam satu transaksi atomik SQLite. Bila terjadi galat di tengah proses, seluruh perubahan dibatalkan (*rollback*) dan basis data kembali utuh.

---

## 2. Struktur Dokumen Cadangan (JSON v1)

Berkas cadangan diberi nama kanonikal dengan format:
`funda_cadangan_YYYY-MM-DD_HHmmss.json` (misalnya: `funda_cadangan_2026-11-19_101530.json`).

### Skema Dokumen Tingkat Atas

```json
{
  "aplikasi": "funda",
  "versi_skema": 1,
  "versi_aplikasi": "0.9.0",
  "dibuat_pada": "2026-11-19T10:15:30.123456Z",
  "checksum_sha256": "a3f5b7...",
  "tabel": {
    "tabel_pengaturan": [ ... ],
    "tabel_kategori": [ ... ],
    "tabel_dompet": [ ... ],
    "tabel_transaksi": [ ... ],
    "tabel_anggaran": [ ... ],
    "tabel_tujuan": [ ... ],
    "tabel_alokasi_dana": [ ... ],
    "tabel_utang": [ ... ],
    "tabel_penyesuaian_utang": [ ... ],
    "tabel_pembayaran_utang": [ ... ],
    "tabel_tagihan": [ ... ],
    "tabel_riwayat_pembayaran_tagihan": [ ... ],
    "tabel_progres_belajar": [ ... ],
    "tabel_jawaban_kuis": [ ... ],
    "tabel_hasil_tes_awal": [ ... ],
    "tabel_profil_keuangan": [ ... ]
  }
}
```

### Rincian Bidang Tingkat Atas

| Bidang | Tipe | Keterangan |
| :--- | :--- | :--- |
| `aplikasi` | `String` | Pengenal aplikasi, selalu bernilai tetap `"funda"`. |
| `versi_skema` | `int` | Versi skema berkas cadangan data (dimulai dari `1`). |
| `versi_aplikasi` | `String` | Versi aplikasi Funda saat berkas dibuat (contoh `"0.9.0"`). |
| `dibuat_pada` | `String` (ISO-8601 UTC) | Waktu persis saat ekspor data dilakukan. |
| `checksum_sha256` | `String` (Hex 64 karakter) | Hash SHA-256 dari representasi JSON kanonikal isi `tabel`. |
| `tabel` | `Map<String, List<Map<String, dynamic>>>` | Peta seluruh tabel basis data SQLite Funda beserta baris-baris datanya. |

---

## 3. Algoritma Checksum SHA-256 Deterministik

Untuk memastikan nilai hash konsisten terlepas dari urutan pengembalian baris atau kunci JSON oleh mesin platform yang berbeda:
1. **Pengurutan Nama Tabel:** Kunci-kunci pada objek `tabel` diurutkan secara alfabetis (A-Z).
2. **Pengurutan Baris:** Baris dalam setiap tabel diurutkan berdasarkan kolom *Primary Key* tabel bersangkutan secara menaik (*ascending*).
3. **Pengurutan Kolom (Kunci Baris):** Setiap baris diubah menjadi `SplayTreeMap` sehingga pasangan kunci-nilai kolom tersusun urut alfabetis.
4. **Serialisasi Kanonikal:** Objek `tabel` kanonikal diubah menjadi string JSON murni tanpa spasi tambahan.
5. **Kalkulasi Hash:** String UTF-8 kanonikal dihitung ringkasannya menggunakan algoritma `sha256` dari pustaka `crypto`.

Saat pemulihan (*restore*), Funda menghitung ulang SHA-256 dari blok `tabel` berkas yang dipilih pengguna. Jika nilai tidak persis sama dengan `checksum_sha256`, pemulihan langsung ditolak dengan pesan: *"Berkas cadangan rusak atau telah dimodifikasi (checksum tidak cocok)."*

---

## 4. Mekanisme & Alur Pemulihan Data (*Restore*)

Proses pemulihan data dirancang dengan perlindungan ganda:

```
[Pengguna Pilih Berkas]
         │
         ▼
[Validasi Format & Checksum SHA-256] ──(Gagal)──> [Tampilkan Pesan Galat & Batalkan]
         │ (Sah)
         ▼
[Tampilkan Dialog Pratinjau Data]
         │ (Pengguna Tekan "Lanjut")
         ▼
[Dialog Konfirmasi Penggantian Data (Langkah 2)]
         │ (Pengguna Tekan "Ya, Pulihkan Sekarang")
         ▼
[1. Buat Cadangan Keselamatan Otomatis (sebelum_pemulihan.json)]
         │
         ▼
[2. Buka Transaksi Atomik SQLite]
         ├── PRAGMA defer_foreign_keys = ON;
         ├── DELETE FROM semua tabel_*;
         ├── INSERT baris-baris dari berkas cadangan;
         ├── PRAGMA foreign_key_check; (Validasi integritas relasi)
         └── Catat 'terakhir_cadangan' di tabel_pengaturan
         │
         ├──(Jika Ada Galat / FK Langgar)──> [ROLLBACK & Pulihkan State Semula]
         │
         └──(Sukses)──> [COMMIT Transaksi & Refresh State UI]
```

### Cadangan Keselamatan (*Safety Backup*)
Sebelum menghapus data lama, aplikasi secara otomatis mengekspor seluruh isi database saat itu ke berkas internal `sebelum_pemulihan.json` di direktori dokumen aplikasi. Jika pengguna tidak sengaja menimpa data, tersedia opsi darurat untuk mengembalikan data sebelum pemulihan terakhir.

---

## 5. Peningkat Versi Skema Cadangan (*Schema Upgrader*)

Jika berkas cadangan yang dipulihkan dibuat pada versi skema masa lalu (`versi_skema < basisData.schemaVersion`), kelas `RegistriPeningkatCadangan` secara berantai menjalankan transformasi data antarversi sebelum disisipkan ke basis data (misalnya: penambahan kolom default, pemetaan nama kolom lama ke baru).

---

## 6. Peringatan Keamanan & Privasi

> [!WARNING]
> Berkas cadangan Funda berisi riwayat transaksi, saldo, utang, dan profil keuangan pengguna dalam teks JSON yang **tidak dienkripsi**. Pengguna disarankan untuk menyimpan berkas cadangan hanya pada media penyimpanan pribadi yang aman dan tidak membagikannya ke pihak yang tidak tepercaya.
