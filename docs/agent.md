# agent.md — Aturan Kerja Agent (Funda)

> Dokumen ini ditujukan untuk **agent koding**. Baca `spec.md` (apa yang dibangun) dan `styleguide.md` (tampilan dan suara) sebelum mengerjakan apa pun. Bagian bertanda `[ASUMSI]` bisa diubah pemilik proyek.

---

## 1. Peran & Cara Kerja

- **Pemilik proyek (Fathin):** project manager. Memberi prompt per tahap, mengirim laporan ke reviewer, memutuskan arah.
- **Agent (kamu):** rekan koding. Mengerjakan satu tahap per prompt dan melapor.
- **Alur per tahap:** terima prompt → rencanakan singkat → kerjakan di cabang `tahap-XX-<nama-tahap>` → uji → perbarui dokumentasi → push cabang ke remote (JANGAN merge ke `main` sebelum disetujui) → **tulis laporan tahap** (format di bagian 9) → berhenti dan tunggu prompt berikutnya.
- Jangan mengerjakan tahap berikutnya sebelum diminta.
- Jika ada hal ambigu yang berdampak besar (arsitektur, data, keamanan), **tanya dulu**. Untuk hal kecil, ambil keputusan masuk akal dan **catat asumsinya** di laporan.

---

## 2. Gambaran Proyek (ringkas)

**Funda** (dari *fundamental* dan *fund*) adalah aplikasi mobile keuangan pribadi (Android + iOS) dengan tiga sisi:
1. **Dompet digital pencatatan:** banyak dompet, transaksi, transfer, kantong, tagihan berulang. Aplikasi **tidak** menyimpan atau memindahkan uang asli.
2. **Belajar sambil praktik:** pelajaran singkat (micro-learning) dari tingkat Pemula sampai Lanjutan, lalu "misi" memakai data uang pengguna sendiri.
3. **Sandbox:** dunia fiktif untuk materi yang tak bisa dipraktikkan langsung (investasi, dll), terpisah total dari data asli.

Pelajaran **berurutan** dan setiap pelajaran punya **syarat data** (gerbang data). Detail ada di `spec.md`.

Empat hal yang tidak boleh hilang:
1. Materi **sederhana**, tanpa istilah ribet.
2. Setiap pelajaran berujung **praktik nyata** di aplikasi.
3. Data keuangan pengguna **tetap di perangkat** (v1).
4. **Gerbang data:** materi baru terbuka setelah pengguna mengisi data yang relevan dengan kondisinya (spec.md bagian 5).

---

## 3. Tech Stack (Flutter disepakati; pustaka `[ASUMSI]`)

| Bagian | Pilihan |
|---|---|
| Framework | **Flutter + Dart** (Android + iOS satu basis kode) |
| Basis data | SQLite lokal lewat **`drift`** (migrasi bertingkat dan kueri bertipe) + `sqlite3_flutter_libs` |
| State | `flutter_riverpod` |
| Navigasi | `go_router` |
| Grafik | `fl_chart` |
| Notifikasi | `flutter_local_notifications` |
| Laporan | PNG dari `RepaintBoundary`; PDF dari `pdf` + `printing`; bagikan lewat `share_plus` |
| Cadangan | `path_provider` + `file_picker` |
| Format angka/tanggal | `intl` (lokal `id_ID`) |
| Ikon | **Satu** pustaka ikon saja (mis. Lucide untuk Flutter). **Tanpa emoji sebagai ikon UI.** |
| Font | Plus Jakarta Sans **dibundel sebagai aset** (bukan diunduh saat berjalan) |
| Analisis kode | `flutter_lints`; `flutter analyze` harus bersih; `dart format` |
| Pengujian | `flutter_test` (unit + widget), `integration_test` (alur utama) |

- Cek versi Flutter/Dart terpasang di laptop pemilik sebelum memilih versi paket. Pakai versi stabil.
- Jangan menambah dependensi tanpa alasan; setiap dependensi baru dicatat beserta alasannya di laporan.
- Jika `drift` (pembangkit kode) terbukti menyulitkan, boleh usul alternatif (`sqflite`) lewat laporan; jangan ganti diam-diam.

---

## 4. Struktur Folder `[ASUMSI]`

```
funda/
├─ lib/
│  ├─ main.dart
│  ├─ aplikasi/          # MaterialApp, rute (go_router), pembungkus
│  ├─ tema/              # token, tema, tipografi
│  ├─ komponen/          # widget bersama: petak_bento, tombol_funda, teks_funda, keadaan_kosong
│  ├─ fitur/             # satu folder per fitur
│  │   ├─ dompet/  transaksi/  kantong/  tagihan/  anggaran/  tujuan/  utang/
│  │   ├─ beranda/  belajar/  gerbang/  kuis/  tes_awal/  misi/
│  │   └─ sandbox/  laporan/  cadangan/  pengaturan/
│  │      (di dalamnya: model/, repositori/, kontroler/, tampilan/)
│  ├─ data/              # basis data (drift), migrasi, repositori bersama
│  ├─ perhitungan/       # fungsi murni: arus kas, bunga, dana darurat, cicilan, dll (WAJIB diuji)
│  └─ util/              # format Rupiah, tanggal, dll
├─ aset/
│  ├─ font/
│  ├─ ilustrasi/
│  └─ konten/            # materi JSON: konten/<tingkat>/<modul>/
├─ test/                 # uji unit & widget (nama folder baku Flutter)
├─ integration_test/     # uji alur (nama folder baku Flutter)
├─ docs/                 # spec.md, agent.md, styleguide.md, kamus_penamaan.md
├─ README.md
└─ CHANGELOG.md
```

Folder baku Flutter (`lib`, `test`, `android`, `ios`, `integration_test`) dan `pubspec.yaml` **tidak diubah namanya**.

---

## 5. Penamaan & Bahasa — SEMUA BAHASA INDONESIA (WAJIB)

Semua yang **kita buat sendiri** memakai bahasa Indonesia:

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

**Pengecualian (tidak diubah):**
- Kata kunci Dart dan API Flutter/pustaka: `StatelessWidget`, `build`, `BuildContext`, `override`, `dispose`, `toString`, dll.
- Nama paket di `pubspec.yaml` (`funda`) dan nama folder baku di atas.
- Kode hasil pembangkit (`*.g.dart`, dll). Namanya tetap diturunkan dari definisi kita yang berbahasa Indonesia.

**Kamus penamaan:** buat dan rawat `docs/kamus_penamaan.md` agar istilah konsisten. Awal:

| Konsep | Nama kode | Konsep | Nama kode |
|---|---|---|---|
| wallet | dompet | pocket | kantong |
| transaction | transaksi | transfer | transfer |
| budget | anggaran | goal | tujuan |
| debt | utang | installment | cicilan |
| lesson | pelajaran | module | modul |
| level | tingkat | gate | gerbang |
| mission | misi | quiz | kuis |
| placement test | tes_awal | sandbox | sandbox |
| report | laporan | backup | cadangan |
| net worth | kekayaanBersih | cash flow | arusKas |

Bila ragu, pakai istilah Indonesia yang wajar atau istilah serapan umum, lalu catat di kamus. **Jangan mencampur** (mis. `walletSaldo`).

---

## 6. Aturan Khusus Domain Keuangan (WAJIB)

1. **Uang = `int` Rupiah.** Dilarang memakai `double` untuk jumlah uang. Hitungan bunga/persen: hitung lalu **bulatkan dengan aturan konsisten** dan terdokumentasi. Hati-hati pembagian: gunakan pembagian bilangan bulat dan tangani sisa secara eksplisit.
2. **Semua perhitungan keuangan** berada di `lib/perhitungan/` sebagai **fungsi murni** (tanpa akses database/UI) dan **wajib punya uji unit**: kasus normal, nol, negatif bila relevan, nilai besar, dan kasus tepi.
3. **Format tampilan:** `Rp 1.250.000` (titik pemisah ribuan, tanpa desimal; negatif `−Rp 300.000`). Satu fungsi format saja, dipakai di mana-mana.
4. **Tanggal & zona waktu:** simpan ISO/UTC dengan jelas; tampilkan format Indonesia. Hati-hati batas bulan/tahun (anggaran bulanan, jatuh tempo tanggal 31, Februari).
5. **Migrasi database** bertingkat dan **tidak boleh menghapus data pengguna**. Setiap perubahan skema = migrasi baru + uji.
6. **Tidak ada klaim keuangan di kode/konten tanpa sumber.** Angka aturan praktis (rasio, jumlah bulan dana darurat, dll) disimpan sebagai **konstanta bernama** dengan komentar sumber.
7. **Aplikasi tidak memberi rekomendasi produk** (investasi, asuransi, pinjaman) tertentu. Sandbox memakai **jenis instrumen umum**, bukan merek.
8. **Gerbang data = fungsi murni** (`lib/fitur/gerbang/`): masukan = data pengguna + definisi syarat dari konten, keluaran = status + pesan "apa yang kurang". Wajib uji unit: data kosong, syarat terpenuhi, **pernyataan kosong** ("aku tidak punya ini"), dan pelajaran `Selesai` yang tidak terkunci ulang.
9. **Pernyataan kosong** tersedia untuk syarat yang bisa tidak berlaku. Jangan memaksa pengguna mengarang data agar bisa lanjut.
10. **Tes awal tidak membuka kunci.** Personalisasi hanya memilih di antara modul yang sudah terbuka.
11. **Data sandbox terpisah total** (tabel dan repositori sendiri). Tidak pernah ikut dalam laporan, dashboard, perhitungan kekayaan bersih, atau gerbang data.
12. **Dompet = pencatatan.** Tidak ada fitur yang seolah menyimpan/memindahkan uang asli. Transfer antar dompet hanya mencatat. "Sesuaikan saldo" membuat **transaksi penyesuaian**, tidak menimpa riwayat.
13. **Tanpa gamifikasi** (badge, level, streak, konfeti besar). Indikator progres sederhana saja.
14. Setiap layar sandbox dan "Langkah Dunia Nyata" **wajib** menampilkan disclaimer (spec.md bagian 8).

---

## 7. Aturan Kode Flutter

- Widget kecil dan terfokus; pakai `const` bila bisa. Berkas > ±300 baris dipecah.
- **Tidak ada logika bisnis di widget.** Logika di `perhitungan/`, repositori, atau kontroler Riverpod.
- Akses database hanya lewat repositori.
- Tidak ada warna/ukuran/teks ajaib di widget: warna dan ukuran dari `lib/tema/`, teks dari konstanta/berkas konten.
- Tangani **tiga keadaan** di setiap layar data: memuat, kosong, galat (dan keadaan data banyak).
- Hormati pembesaran teks sistem; semua elemen interaktif punya `Semantics`/label; target sentuh ≥ 48.
- Hindari kebocoran: tutup kontroler/langganan; jangan `setState` setelah `dispose`.
- Operasi berat (laporan PDF, impor/ekspor) tidak boleh memblokir UI.

---

## 8. Aturan Konten, Keamanan & Privasi

**Konten & bahasa**
- Materi mengikuti **format di spec.md bagian 12** (konten sebagai data).
- Suara & gaya: ikuti `styleguide.md` bagian "Suara & Bahasa".
- Konten yang ditulis agent berstatus `"status": "draf"`. Boleh `"ditinjau"` hanya setelah pemilik proyek menyatakannya.
- **Jangan mengarang fakta/regulasi/angka.** Jika tidak yakin, tulis `TODO-VERIFIKASI` di konten dan sebutkan di laporan. Materi Menengah & Lanjutan (pajak, kredit, investasi, warisan) paling rawan.

**Keamanan & privasi**
- Data keuangan **tidak keluar dari perangkat** (v1). Dilarang menambah analitik/pelacak/SDK pihak ketiga yang mengirim data tanpa persetujuan eksplisit pemilik proyek.
- **Tidak ada PIN/biometrik di v1.** Jangan menambahkannya tanpa diminta.
- Berkas cadangan: beri peringatan jelas bahwa isinya data pribadi; opsi enkripsi `[ASUMSI]`.
- Laporan bulanan memuat data pribadi: tampilkan pratinjau sebelum dibagikan; sediakan opsi sensor nominal bila disepakati.
- Jangan mencatat (log) data keuangan pengguna pada build rilis.
- Validasi semua masukan (jumlah, tanggal, teks); tolak nilai tak masuk akal sesuai konteks.
- Tidak ada rahasia/kunci di kode. Periksa dependensi sebelum rilis.

---

## 9. Definisi Selesai & Format Laporan Tahap

Sebuah tahap **selesai** hanya jika:
- [ ] Fitur sesuai spec dan bisa dijalankan
- [ ] `flutter analyze` bersih; `dart format` sudah dijalankan
- [ ] Uji unit untuk perhitungan baru lulus; uji widget/alur penting lulus (sertakan keluaran terminal)
- [ ] Kondisi **data kosong**, **data banyak**, dan **masukan salah** sudah ditangani
- [ ] Semua penamaan mengikuti bagian 5 (Indonesia)
- [ ] `README.md` dan `CHANGELOG.md` diperbarui
- [ ] Tampilan mengikuti `styleguide.md` (soft bento)
- [ ] Bila menyentuh pelajaran/modul: gerbang data dan pernyataan kosong sudah diuji
- [ ] Commit rapi (bahasa Indonesia)

**Format laporan (tulis di terminal di akhir tahap):**

```
LAPORAN TAHAP: <nama tahap>
1. Yang dikerjakan: ...
2. File penting yang dibuat/diubah: ...
3. Cara menjalankan & mencoba: ...
4. Hasil uji & analisis: <jumlah lulus/gagal + keluaran flutter analyze/test>
5. Keputusan/asumsi yang saya ambil: ...
6. Masalah yang belum selesai / risiko: ...
7. Yang saya sarankan untuk tahap berikutnya: ...
8. Hal yang butuh keputusan pemilik proyek: ...
```

Laporan harus jujur. Jika sesuatu belum jalan, katakan. Jangan menyatakan "selesai" untuk hal yang belum diuji.

### Aturan Kejujuran Laporan (WAJIB & KETAT Mulai Tahap 5)
1. **DILARANG** menulis isi berkas, nama bidang/tabel/kelas, atau keluaran perintah yang tidak berasal dari perintah yang **BENAR-BENAR dijalankan di sesi kerja ini**. Setiap kutipan isi berkas atau klaim "berkas X berisi Y" harus disertai perintah dan keluaran mentah riil (maksimal 40 baris per kutipan).
2. Klaim apa pun yang belum dibuktikan dengan perintah nyata di sesi ini **WAJIB ditulis "BELUM TERVERIFIKASI"**, bukan "selesai" atau "lolos".
3. Kata **"LOLOS"** adalah hak pemilik proyek dan reviewer, **BUKAN agen**. Di laporan, agen hanya menyatakan "pengujian lulus: X/Y" atau "verifikasi mandiri terpenuhi", tidak pernah menyatakan tahap lolos.

### Aturan Pengujian Anti-Menggantung (WAJIB & KETAT Mulai Tahap 7-R)
1. **Pemisahan Lingkup Pengujian:**
   - **Uji Widget:** Hanya menguji antarmuka pengguna (UI) murni dengan provider palsu/mock (override bernilai langsung seperti `AsyncValue.data(...)` atau `Stream.value(...)`) tanpa basis data nyata.
   - **Uji Repositori & Perhitungan:** Menggunakan `test()` biasa dengan `NativeDatabase.memory()`.
   - **Alur Nyata End-to-End:** Dijalankan di dalam `integration_test/` pada emulator atau perangkat fisik.
   - Bila uji widget terpaksa memakai basis data nyata: wajib dibungkus dengan `await tester.runAsync(...)`.
2. **Helper Terpusat `pompa_uji.dart`:**
   - Berkas `test/pembantu/pompa_uji.dart` adalah **SATU-SATUNYA** tempat memanggil `pumpAndSettle()`.
   - Pemanggilan selalu menggunakan batas waktu pendek aman (default 5 detik: `pumpAndSettle(100 ms, EnginePhase.sendSemanticsUpdate, 5 detik)`).
   - Dilarang memanggil `tester.pumpAndSettle()` langsung di berkas uji di luar helper.
   - Sediakan helper `pompaHingga(tester, kondisi)` dan `pompaHinggaAda(tester, pencari)`.
3. **Komponen Indikator Memuat Terpusat (`IndikatorMemuat`):**
   - Seluruh pemanggilan `CircularProgressIndicator` dan `LinearProgressIndicator` di `lib/` dialihkan ke `IndikatorMemuat` di `lib/komponen/indikator_memuat.dart`.
   - Komponen ini membaca provider `penyediaTanpaAnimasi` (default `false`). Pengujian widget meng-override `penyediaTanpaAnimasi: true` sehingga animasi tidak berulang tanpa akhir di dalam `FakeAsync`.
4. **Batas Waktu Pengujian 30 Detik:**
   - Setiap berkas uji widget wajib menyertakan anotasi `@Timeout(Duration(seconds: 30))`.
   - Berkas `dart_test.yaml` di root proyek mengunci `timeout: 30s` secara global.
5. **Pelepasan Widget Sebelum Teardown:**
   - Pada `addTearDown`, sebelum menutup basis data, pohon widget wajib dilepas menggunakan `await tester.pumpWidget(const SizedBox.shrink())` lalu `await tester.pump(Duration.zero)`.
6. **Larangan Penunggu Buta:**
   - DILARANG menggunakan `Future.delayed()` di dalam berkas uji widget.
   - DILARANG menggunakan `tester.pump(Duration)` tetap sebagai penunggu data asinkron.
7. **Linter Penjaga Pengujian Otomatis:**
   - Suite `test/penjaga/aturan_pengujian_test.dart` secara otomatis memeriksa seluruh berkas sumber dan GAGAL jika menemukan:
     * `pumpAndSettle(` di luar `pompa_uji.dart`.
     * `Future.delayed(` di uji widget.
     * `Circular/LinearProgressIndicator` di `lib/` di luar `IndikatorMemuat`.
     * Berkas uji widget tanpa timeout.

---

## 10. Hal yang Dilarang

- Memakai `double` untuk uang.
- Menamai sesuatu dengan bahasa Inggris atau mencampur bahasa (di luar pengecualian bagian 5).
- Mengirim data pengguna ke jaringan tanpa persetujuan.
- Menghapus/mengubah data pengguna lewat migrasi tanpa uji.
- Mencampur data sandbox dengan data asli.
- Menambah fitur di luar tahap yang diminta (catat sebagai saran saja).
- Menulis klaim keuangan tanpa sumber atau merekomendasikan produk.
- Menaruh warna/ukuran hard-coded yang menyalahi `styleguide.md`.
- Menyatakan sesuatu sudah teruji padahal belum.

---

## 11. Urutan Pengerjaan

Ikuti **roadmap tahap di spec.md bagian 17** (12 tahap). Ringkas:
Fondasi → Dompet & transaksi → Pengelolaan → Mesin belajar + gerbang data → Tes awal → **Modul 1 lengkap** → Laporan & cadangan (**MVP selesai**) → Tingkat Pemula → Sandbox + modul non-langsung → Tingkat Menengah → Tingkat Lanjutan → Polesan & rilis.

Selalu selesaikan satu irisan vertikal (belajar → gerbang → misi → umpan balik dari data) sebelum memperluas.

---

## 12. Skill / Alat Bantu (Antigravity)

**Proses kerja**
- `using-superpowers` (orkestrator), `brainstorming` (sebelum tahap besar), `writing-plans` + `executing-plans` (rencana bertahap per tahap).
- `test-driven-development`: **wajib** untuk `lib/perhitungan/`, gerbang data, kuis, skor tes awal, dan migrasi.
- `systematic-debugging` saat ada bug; `verification-before-completion`: **jangan klaim selesai tanpa bukti** (keluaran uji/terminal).
- `requesting-code-review` / `receiving-code-review`, `using-git-worktrees`, `finishing-a-development-branch` bila memakai cabang.

**Desain & merek**
- `ui-ux-pro-max`, `design-taste-frontend`, `design-system` (petakan token tiga lapis ke `lib/tema/`), `brand` (nada bahasa), `design` (logo & ikon SVG Funda).
- Skill desain banyak berorientasi web: **ambil prinsipnya, bukan kodenya**. **`styleguide.md` menang** bila bertentangan dengan keluaran skill, kecuali pemilik proyek memutuskan lain.
- `ui-styling` (Tailwind/Shadcn) dan `nextjs-modern-architecture` adalah skill web: **jangan dipakai** di proyek Flutter ini.

**Kualitas & keamanan**
- `owasp-secure-coding`: validasi masukan, penyimpanan lokal, dependensi, tidak ada rahasia di kode. Abaikan bagian khusus server/web.
- `ponytail`, `ponytail-review`, `ponytail-audit`: jaga kode ringkas. Pustaka yang memang dibutuhkan platform (SQLite, PDF, bagikan berkas) boleh dipakai dengan alasan singkat di laporan.
- `playwright-browser-testing` khusus peramban: **tidak dipakai**. Uji alur memakai `integration_test` dan uji widget.

**Tidak dipakai sekarang:** `coolify-devops-deployment` (tidak ada server), `slides` dan `banner-design` (nanti untuk materi rilis: tangkapan layar toko aplikasi), `skills-manager` (hanya bila diminta).

Jika sebuah skill tidak tersedia, kerjakan manual dan catat di laporan.
