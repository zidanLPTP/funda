# spec.md — Funda

> **v0.3.** Nama aplikasi: **Funda** (dari *fundamental* dan *fund*). Aplikasi keuangan mobile "belajar sambil praktik" dengan fitur dompet digital dan materi dari tingkat pemula sampai lanjutan. Bagian bertanda `[ASUMSI]` belum dikonfirmasi pemilik proyek.

---

## 1. Ringkasan

Funda adalah aplikasi keuangan pribadi yang **mencatat, mengajar, lalu langsung mempraktikkan**. Pengguna mengelola uangnya lewat fitur dompet digital, mempelajari konsep keuangan lewat pelajaran singkat, lalu menerapkannya memakai **data uangnya sendiri**. Karena bahan ajarnya adalah data pengguna, materi bisa naik dari dasar sampai lanjutan: makin lama data terkumpul, makin dalam yang bisa dipelajari.

Ide tagline `[ASUMSI]`: *"Kuasai fondasi uangmu, dari dasar sampai mahir."*

### Prinsip produk
1. **Micro-learning.** Satu pelajaran = 3–5 menit, satu ide inti. Tiap bagian: belajar → aksi langsung di app.
2. **Aplikatif & berorientasi aksi.** Tidak ada pelajaran tanpa praktik.
3. **Data pengguna adalah bahan ajar.** Contoh dan evaluasi memakai data pengguna sendiri.
4. **Santai, praktis, memberdayakan, bebas jargon rumit.** Positif dan membangun kepercayaan diri; tidak menghakimi.
5. **Privasi dulu.** Data tetap di perangkat.
6. **Jujur soal batas.** Edukasi, bukan nasihat keuangan berlisensi.

---

## 2. Keputusan yang Sudah Final

| Topik | Keputusan |
|---|---|
| Nama | **Funda** |
| Platform | Android + iOS |
| Framework | **Flutter (Dart)** |
| Bahasa penamaan | **Semua dalam bahasa Indonesia**: pesan commit, nama file, variabel, kelas, komentar, dokumentasi, teks antarmuka |
| Tujuan | Portofolio, dipakai umum, rilis ke Play Store. **Tanpa monetisasi** (tanpa iklan, langganan, afiliasi) |
| Target pengguna | Anak muda (mahasiswa, pekerja pemula); pengguna lain tetap boleh |
| Kebiasaan pakai | Tidak mewajibkan buka tiap hari; alasan kembali = mencatat pemasukan/pengeluaran |
| Dompet digital | **Wajib ada** (bagian 9.1) |
| Tingkat materi | **Pemula, Menengah, Lanjutan** (bagian 6) |
| Gamifikasi | **Tidak ada** (tanpa badge, level, streak). Hanya indikator progres |
| Urutan belajar | **Berurutan** dengan **gerbang data** (bagian 5) |
| Tes awal | Ada (bagian 7) |
| Kuis | Ada kuis akhir modul. **Tanpa sertifikat** |
| Personalisasi | Aplikasi menyarankan modul dari kondisi keuangan |
| Data | Sepenuhnya di perangkat. Tanpa akun, tanpa sinkronisasi cloud |
| Pencatatan | Manual. Impor mutasi rekening (CSV) = rencana masa depan |
| Kunci PIN/biometrik | Tidak ada di v1 |
| Keuangan bersama | Tidak ada |
| Sandbox | Ada untuk penerapan yang tak bisa dilakukan langsung (bagian 8) |
| Laporan bulanan | Ada; dibagikan sebagai **gambar** dan **PDF** |
| Gaya UI | **Soft bento** (lihat `styleguide.md`) |

---

## 3. Pengguna `[ASUMSI]`

Anak muda Indonesia (±17–30 tahun) yang baru mengelola uang sendiri atau ingin merapikannya. Pengetahuan awal bisa nol. Pengguna yang sudah paham bisa melompat ke tingkat lebih tinggi lewat tes awal (tetap melewati gerbang data).

---

## 4. Format Pelajaran (Micro-learning)

| Tahap | Isi |
|---|---|
| 1. Pemantik | Situasi 1–2 kalimat yang relate |
| 2. Konsep inti | Maksimal 3 kartu geser, satu ide per kartu |
| 3. Contoh angka | Contoh Rupiah yang konkret |
| 4. Cek paham | 2–3 soal singkat (bukan ujian) |
| 5. **Misi praktik** | Aksi di aplikasi memakai data sendiri |
| 6. Umpan balik | Aplikasi menampilkan hasil dari data pengguna |
| 7. Tindak lanjut | Satu kebiasaan kecil / pengingat opsional |

Pelajaran tingkat Lanjutan boleh lebih panjang (5–8 menit) dan dipecah menjadi bagian-bagian kecil.

---

## 5. Gerbang Data (inti sistem belajar)

Setiap pelajaran/modul punya **syarat data**. Pelajaran terbuka hanya bila syarat terpenuhi, dan urutan tetap berjalan.

**Status pelajaran:** `Terkunci` → `Terbuka` → `Sedang` → `Selesai`.

**Aturan:**
1. Syarat dicek **saat pelajaran akan dibuka**, dari data nyata pengguna di database.
2. Pelajaran yang sudah `Selesai` **tidak terkunci ulang**, walau data berubah.
3. Pelajaran terkunci menampilkan **apa yang kurang + tombol langsung ke layar pengisiannya** ("Catat 1 pemasukan dulu, yuk").
4. **Pernyataan kosong:** untuk syarat yang bisa tidak berlaku (mis. tidak punya utang), pengguna boleh menyatakan **"Aku tidak punya ini"**, dan itu dianggap memenuhi syarat. Tanpa opsi ini, pengguna dipaksa mengarang data.
5. Modul **selesai** = semua pelajaran selesai + kuis akhir lulus. Modul berikutnya terbuka setelah itu **dan** syarat datanya terpenuhi.
6. **Personalisasi hanya memilih di antara yang sudah terbuka.** Bila modul yang paling relevan masih terkunci, aplikasi menunjukkan *kenapa* dan langkah membukanya.
7. **Data sandbox tidak pernah dihitung** untuk memenuhi gerbang.
8. Tingkat **Lanjutan** memakai syarat **riwayat data lebih panjang** (mis. transaksi tercatat ≥ 3 bulan) `[ASUMSI]`, karena materinya menganalisis kebiasaan nyata pengguna.

**Tipe syarat:** `ada_data`, `aturan_data`, `periode_data`, `pernyataan`, `kuis_lulus`, `modul_selesai`.

---

## 6. Kurikulum

**Tipe penerapan:** [L] Langsung di app · [K] Kalkulator dari data pengguna · [S] Simulasi/sandbox · [C] Cerita bercabang · [A] Aksi dunia nyata (checklist + pengingat) · [R] Refleksi

### Tingkat Pemula — fondasi
| # | Modul | Pelajaran utama | Syarat data (gerbang) | Penerapan |
|---|---|---|---|---|
| 0 | **Mulai & Tes Awal** | Kenalan, profil keuangan, tes awal | Tidak ada | [L] |
| 1 | **Anggaran & Arus Kas** *(MVP)* | Kenapa uang "hilang"; memetakan arus kas; kebutuhan vs keinginan; anggaran pertama; evaluasi bulan | Profil + ≥1 dompet + ≥1 pemasukan; lanjut: pengeluaran tercatat ≥7 hari | [L][K][S] |
| 2 | **Tabungan** | Tabungan itu soal tujuan; bayar diri sendiri dulu; hitung kecepatan menabung | Modul 1 selesai + ada anggaran | [L][K][S] |
| 3 | **Dana Darurat** | Apa itu & kapan dipakai; berapa yang cukup; isi bertahap | Pengeluaran wajib tercatat | [C][K][L] |
| 4 | **Utang & Cicilan** | Utang sehat vs menjerat; bunga & biaya sebenarnya; rasio cicilan; strategi melunasi | Daftar utang **atau** pernyataan "tidak punya utang" | [C][K][S][L] |
| 5 | **Waspada Penipuan & Pinjol Ilegal** | Ciri tawaran mencurigakan; cek legalitas; langkah jika kena | Modul 1 selesai | [C][A] |
| 6 | **Psikologi Uang & Kebiasaan Belanja** | Kenapa impulsif; langganan diam-diam; aturan jeda | Pengeluaran 30 hari tercatat | [R][K][L] |

### Tingkat Menengah
| # | Modul | Pelajaran utama | Syarat data (gerbang) | Penerapan |
|---|---|---|---|---|
| 7 | **Paylater, Kredit & Skor Kredit** | Cara kerja paylater; riwayat kredit; menjaga reputasi kredit | Modul 4 selesai | [C][A] |
| 8 | **Penghasilan Tambahan & Freelance** | Sumber penghasilan; mencatat penghasilan tak tetap; menyisihkan untuk pajak & masa sepi | Pemasukan ≥2 sumber **atau** pernyataan "baru satu sumber" | [L][K][S] |
| 9 | **Pajak Dasar** | NPWP, penghasilan pertama, kapan wajib lapor | Penghasilan tercatat | [K][A] |
| 10 | **Proteksi (Asuransi & Jaminan Sosial)** | Kenapa butuh proteksi; jenis dasar; menghitung kebutuhan | Dana darurat dimulai (modul 3) | [C][K][A] |
| 11 | **Investasi Dasar** *(sandbox)* | Inflasi; risiko vs imbal hasil; diversifikasi; mulai kecil | Modul 3 & 4 selesai | [S][C][A] |
| 12 | **Tujuan Besar & Perencanaan** | Tujuan nikah, rumah, pendidikan; proyeksi; prioritas | Modul 2 selesai + ≥1 tujuan | [L][S][K] |

### Tingkat Lanjutan *(memakai riwayat data pengguna yang sudah menumpuk)*
| # | Modul | Pelajaran utama | Syarat data (gerbang) | Penerapan |
|---|---|---|---|---|
| 13 | **Investasi Lanjutan** *(sandbox)* | Alokasi aset; rebalancing; biaya & pajak investasi; mengukur risiko pribadi | Modul 11 selesai + riwayat ≥3 bulan | [S][C][A] |
| 14 | **KPR & Kredit Besar** | Simulasi cicilan; uang muka; sewa vs beli; uji kemampuan bayar dari arus kas nyata | Modul 4 & 12 selesai + riwayat ≥3 bulan | [K][S][C] |
| 15 | **Pajak Lanjutan** | Lapor tahunan; penghasilan beragam; perencanaan pajak yang sah | Modul 9 selesai + penghasilan ≥6 bulan tercatat | [K][A] |
| 16 | **Pensiun & Kebebasan Finansial** | Angka kebebasan finansial; proyeksi pensiun; menyesuaikan dengan inflasi | Modul 13 selesai + riwayat ≥3 bulan | [K][S] |
| 17 | **Keuangan Usaha Kecil** | Memisah uang pribadi dan usaha; arus kas usaha; modal kerja | Pemasukan usaha tercatat **atau** pernyataan "belum punya usaha" (lalu sandbox usaha) | [L][K][S] |
| 18 | **Proteksi Keluarga & Warisan Dasar** | Perencanaan keluarga; dokumen penting; gambaran warisan | Modul 10 selesai | [C][A] |

**Kandidat modul tambahan:** hidup merantau/anak kos, belanja online & langganan digital, dana sosial & sedekah, persiapan menikah, negosiasi gaji, mengelola uang di bulan tua.

> Angka syarat di tabel adalah usulan awal; boleh disetel per modul saat implementasi. Materi tingkat Menengah dan Lanjutan (pajak, kredit, investasi, warisan) **wajib melewati tinjauan kebenaran** sebelum rilis.

---

## 7. Tes Awal & Personalisasi

**Tes awal (modul 0):**
- ±10–15 soal ringan + pertanyaan kondisi (punya penghasilan? punya utang? sudah menabung? pernah investasi?).
- Hasil: **profil keuangan**, **saran modul pertama**, dan modul dengan skor tinggi ditawari **Mode Ringkas** `[ASUMSI]` (baca ringkasan + langsung misi).
- **Tes awal tidak membuka kunci.** Gerbang data tetap berlaku untuk semua orang.

**Personalisasi berjalan terus** dari data pengguna (rasio cicilan tinggi → sarankan modul 4; dana darurat nol → modul 3; pengeluaran keinginan dominan → modul 6) dengan nada menguatkan, tidak menghakimi.

**Kuis akhir modul:** 5–10 soal, penjelasan tiap jawaban, boleh diulang tanpa batas, urutan acak. Ambang lulus usulan **70%** `[ASUMSI]`.

---

## 8. Sandbox & Langkah Dunia Nyata

Untuk materi yang tidak bisa dipraktikkan langsung (investasi, proteksi, KPR, pajak, usaha, dll):

1. **Sandbox** — dunia fiktif dengan saldo fiktif; pengguna mengatur alokasi, memajukan waktu, melihat skenario naik/turun. Memakai **jenis instrumen umum** (mis. "reksa dana pasar uang", "obligasi", "saham"), **bukan merek/produk tertentu**. Selalu ada tulisan: *simulasi, bukan prediksi.*
2. **Data sandbox terpisah total** dari data asli: tidak masuk laporan, dashboard, atau gerbang. Tampilannya diberi penanda jelas ("Mode Sandbox").
3. **Langkah Dunia Nyata** — layar di akhir modul: checklist langkah, cara mengecek izin/legalitas penyedia (ke lembaga resmi), pertanyaan yang perlu diajukan, pengingat opsional. Aplikasi mengarahkan **kategori** penyedia berizin, bukan menjual atau mengiklankan.
4. **Disclaimer wajib** sebelum layar tersebut dan bisa dibaca ulang. Teks resmi tersimpan di `aset/konten/disclaimer.json`:
   > "Funda hanya memberi edukasi umum dan bukan nasihat hukum, keuangan, atau perlindungan konsumen resmi. Langkah-langkah di bawah adalah kebiasaan baik yang kamu lakukan di luar aplikasi ini."

---

## 9. Fitur Aplikasi

### 9.1 Dompet digital (wajib)
> **Penting:** Funda adalah dompet digital **pencatatan**: pengalamannya seperti dompet digital, tetapi **tidak menyimpan atau memindahkan uang asli** (tanpa isi saldo/top up, pembayaran, atau sambungan ke rekening). Itu di luar cakupan v1.

- **Banyak dompet:** tipe (tunai, rekening bank, e-wallet, lainnya), nama, ikon/warna, saldo awal, saldo berjalan, arsipkan.
- **Transaksi:** pemasukan, pengeluaran, **transfer antar dompet** (biaya admin opsional), catatan, tanggal/waktu, kategori.
- **Kategori + label sifat:** Kebutuhan / Keinginan / Tabungan & Dana Darurat / Utang / Pemasukan.
- **Kantong (pocket):** alokasi sebagian saldo dompet untuk tujuan tertentu (tabungan, dana darurat, tagihan), tanpa memindahkan uang.
- **Sesuaikan saldo:** koreksi bila saldo di aplikasi berbeda dari saldo sebenarnya (dicatat sebagai transaksi penyesuaian, bukan menimpa riwayat).
- **Tagihan & langganan berulang** dengan pengingat jatuh tempo (opsional, bisa dimatikan).
- **Riwayat/mutasi:** dikelompokkan per hari, pencarian, filter (dompet, kategori, sifat, tanggal, jumlah), ekspor CSV.
- **Catat cepat:** tombol tambah cepat, pintasan nominal, **template transaksi** favorit.
- **Ringkasan kekayaan:** total saldo semua dompet, total utang, **kekayaan bersih**.
- **Lampiran foto struk** `[ASUMSI, opsional]`, disimpan lokal.

### 9.2 Pengelolaan
Anggaran per kategori; tujuan (tabungan, dana darurat, tujuan besar); pelacak utang (pokok, bunga, tenor, jatuh tempo, sisa); dashboard bento (arus kas, sisa anggaran, progres tujuan, rasio cicilan, kekayaan bersih).

### 9.3 Belajar
Peta belajar (tingkat → modul → pelajaran, status gerbang); pemutar pelajaran; misi; kuis; tes awal; kamus istilah (tooltip); sandbox; Langkah Dunia Nyata.

### 9.4 Laporan bulanan
Lihat bagian 10.

### 9.5 Pendukung
Ekspor/impor cadangan data (berkas); pengingat opsional; data contoh untuk sandbox.

**Tidak ada di v1:** akun, sinkronisasi, PIN/biometrik, keuangan bersama, gamifikasi, sertifikat, pembayaran/top up sungguhan, impor mutasi (masa depan).

---

## 10. Laporan Bulanan

- Isi: arus kas bulan itu (masuk, keluar, selisih); komposisi kebutuhan/keinginan/tabungan/utang; realisasi vs anggaran; progres tujuan & dana darurat; kekayaan bersih; satu "temuan bulan ini" bernada menguatkan; satu saran aksi bulan depan.
- Tampilan: kartu bento ringkas.
- Ekspor: **gambar (PNG)** dan **PDF**, dibagikan lewat menu bagikan sistem.
- Sebelum dibagikan: pratinjau + opsi **sensor nominal** `[ASUMSI]` (tampilkan persentase saja), karena laporan memuat data pribadi.
- Teknis `[ASUMSI]`: gambar dari `RepaintBoundary`, PDF dari paket `pdf`/`printing`, bagikan lewat `share_plus`.

---

## 11. Sistem Misi

| Tipe misi | Verifikasi |
|---|---|
| `ada_data` | Jumlah data minimal ada |
| `aturan_data` | Data memenuhi aturan |
| `lihat_hitungan` | Pengguna membuka hasil hitung dan menekan "Mengerti" |
| `keputusan` | Pengguna memilih opsi |
| `komitmen` | Pengguna menyimpan komitmen + tanggal |
| `daftar_periksa` | Pengguna menandai langkah dunia nyata |
| `refleksi` | Jawaban teks terisi (privat) |

Selalu ada opsi **"Belum relevan buat aku"**. Hasil misi memicu umpan balik berupa angka/grafik dari data pengguna, bukan sekadar centang.

---

## 12. Format Konten (content-as-data)

Materi disimpan sebagai berkas JSON di `aset/konten/<tingkat>/<modul>/`.

```json
{
  "id": "arus_kas_1_2",
  "modul": "anggaran_arus_kas",
  "tingkat": "pemula",
  "judul": "Memetakan Arus Kas",
  "durasiMenit": 4,
  "status": "draf",
  "gerbang": [{ "tipe": "ada_data", "objek": "pemasukan", "min": 1, "pesan": "Catat 1 pemasukan dulu, yuk." }],
  "pemantik": "Gaji habis tanggal 20, padahal rasanya tidak beli apa-apa.",
  "kartu": [{ "judul": "Arus kas itu apa?", "isi": "Uang yang masuk dikurangi uang yang keluar." }],
  "contohAngka": { "masuk": 2000000, "keluar": 2300000, "hasil": -300000 },
  "cekPaham": [{ "tanya": "Mana yang termasuk uang keluar?", "pilihan": ["Gaji", "Bayar kos"], "benar": 1, "penjelasan": "Bayar kos mengurangi uangmu." }],
  "misi": { "tipe": "ada_data", "objek": "pemasukan", "min": 1, "umpanBalik": "arus_kas_bulan_ini" }
}
```

**Daftar objek resmi gerbang & misi:**
- `dompet`: jumlah akun dompet aktif (tipe `ada_data`)
- `pemasukan`: jumlah transaksi jenis pemasukan (tipe `ada_data`)
- `pengeluaran`: jumlah transaksi jenis pengeluaran (tipe `ada_data`)
- `transaksi`: jumlah seluruh transaksi (pemasukan + pengeluaran + transfer) (tipe `ada_data`)
- `anggaran`: jumlah kategori anggaran bulanan aktif (tipe `ada_data`)
- `tujuan`: jumlah tujuan/pos/kantong tabungan aktif (tipe `ada_data`)
- `utang`: jumlah catatan utang/piutang aktif (tipe `ada_data`)
- `arus_kas`: komposit pemasukan >= min DAN pengeluaran >= min (tipe `aturan_data` atau `ada_data`)
- `profil`: profil keuangan sudah diisi (bukan dilewati, bukan kosong; tipe `ada_data`)

**Aturan penulisan:** ikuti `styleguide.md` bagian Suara & Bahasa. Angka aturan praktis (rasio, jumlah bulan dana darurat, batas pajak, dll) ditandai **aturan praktis**, diberi sumber, dan **diverifikasi sebelum rilis**. Konten baru berstatus `draf` sampai pemilik proyek menyatakan `ditinjau`.

---

## 13. Model Data (garis besar)

`Dompet`, `Kategori(sifat)`, `Transaksi(jenis: masuk/keluar/transfer/penyesuaian)`, `Kantong`, `Tagihan`, `Anggaran`, `Tujuan`, `Utang`, `ProfilKeuangan`, `HasilTesAwal`, `ProgresPelajaran(status)`, `Misi`, `HasilKuis`, `Pernyataan(kunci, nilai)` (untuk "aku tidak punya ini"), `Komitmen`, `Refleksi`, `SesiSandbox` (tabel terpisah), `Pengaturan`.

**Uang = bilangan bulat Rupiah** (`int`). Tidak boleh `double` untuk jumlah uang. Perhitungan bunga memakai fungsi khusus yang diuji unit.

---

## 14. Arsitektur `[ASUMSI untuk pustaka]`

- **Flutter + Dart**, satu basis kode untuk Android dan iOS.
- Penyimpanan: **SQLite lokal** (usulan: `drift`, karena migrasi dan kueri bertipe aman). Tanpa backend.
- State: usulan `flutter_riverpod`. Navigasi: usulan `go_router`.
- Grafik: usulan `fl_chart`. Notifikasi lokal: `flutter_local_notifications`.
- Laporan: `RepaintBoundary` (PNG), `pdf` + `printing` (PDF), `share_plus` (bagikan).
- Cadangan: `path_provider` + `file_picker`.
- Konten materi: aset JSON di dalam aplikasi. Font dibundel sebagai aset (bekerja offline).
- Rilis: akun developer Google Play dan Apple punya biaya sendiri (cek harga terkini). Build iOS memerlukan macOS atau layanan build awan.

---

## 15. Non-Fungsional

- **Offline penuh.**
- **Privasi:** tanpa pengiriman data keuangan keluar perangkat; tanpa analitik yang memuat data keuangan.
- **Risiko kehilangan data** (data hanya di HP, tanpa akun): ingatkan pengguna mengekspor cadangan berkala dan mudahkan alurnya.
- **Performa:** layar utama < 2 detik di Android menengah; riwayat transaksi mulus sampai ≥ 5.000 transaksi.
- **Aksesibilitas:** teks bisa diperbesar, target sentuh ≥ 48, label `Semantics`, tidak mengandalkan warna saja.
- **Kualitas:** uji unit untuk semua perhitungan; uji widget dan alur penting.

---

## 16. Disclaimer & Etika

- Edukasi umum, bukan nasihat keuangan/hukum/pajak.
- Tidak ada rekomendasi atau iklan produk keuangan tertentu.
- Bahasa menguatkan; tidak memicu rasa malu atau takut.
- Bila data menunjukkan kondisi berat (mis. cicilan melebihi pemasukan), tampilkan panduan netral dan arahkan ke sumber bantuan resmi.

---

## 17. Roadmap Tahap (alur seperti PicLab)

Kamu mengirim **prompt per tahap** ke agent → agent kerja dan menulis laporan → laporan dikirim ke Claude untuk diperiksa → bila lolos, prompt tahap berikutnya.

| Tahap | Isi | Hasil |
|---|---|---|
| 1 | **Fondasi:** proyek Flutter, struktur, tema bento, navigasi, SQLite + migrasi, util Rupiah, uji, dokumentasi | Aplikasi kosong yang berjalan |
| 2 | **Dompet & transaksi:** banyak dompet, kategori + sifat, transaksi, transfer antar dompet, sesuaikan saldo | Pencatat inti |
| 3A | **Anggaran, Tujuan & Kantong:** alokasi kantong (pos penandaan saldo), anggaran per kategori, tujuan finansial | Pengelolaan alokasi & anggaran |
| 3B | **Utang, Kekayaan Bersih & Dashboard:** pelacak utang & cicilan, pencatatan pembayaran terhubung transaksi, kekayaan bersih, dashboard Beranda penuh | Dasbor & pelacak kewajiban |
| 3C | **Tagihan Berulang & Pengingat:** tagihan/langganan berulang, pengingat lokal, petak tagihan di Beranda | Pengingat komitmen rutin |
| 4 | **Mesin belajar:** pemutar pelajaran, kuis, misi, **gerbang data**, pembaca konten | Satu pelajaran jalan penuh |
| 5 | **Tes awal & personalisasi** | Profil + rekomendasi modul |
| 6 | **Modul 1 lengkap** | **MVP belajar** |
| 7 | **Laporan bulanan (PNG + PDF) & cadangan data** | **MVP selesai** |
| 8A | **Tingkat Pemula Bagian 1:** Modul 2 "Tabungan" & Modul 3 "Dana Darurat" | Pembelajaran tabungan & dana darurat selesai |
| 8B | **Tingkat Pemula Bagian 2:** Modul 4 "Utang & Cicilan" | Pembelajaran utang & cicilan aktif |
| 8C | **Tingkat Pemula Bagian 3:** Modul 5 "Waspada Penipuan & Pinjol Ilegal" + tipe misi keputusan dan daftar_periksa + disclaimer | Edukasi waspada penipuan selesai |
| 8D | **Tingkat Pemula Bagian 4:** Modul 6 "Psikologi Uang & Kebiasaan Belanja" + tipe misi refleksi | Fondasi pemula lengkap (selesai, seluruh Tingkat Pemula tuntas) |
| 9A | **Mesin Sandbox & Modul 11 "Investasi Dasar":** Mesin simulasi portofolio fiktif terisolasi, tipe misi sandbox, konten Modul 11 | Fitur sandbox edukasi & investasi dasar selesai |
| 9B | **Modul 7 "Paylater, Kredit & Skor Kredit" & Modul 10 "Proteksi (Asuransi & Jaminan Sosial)":** Pembelajaran paylater, reputasi kredit, proteksi dasar, serta umpan balik ringkasan proteksi | Pembelajaran paylater & proteksi selesai (Tahap 9 tuntas) |
| 10A | **Tingkat Menengah Bagian 2:** Modul 8 "Penghasilan Tambahan & Freelance" & Modul 9 "Pajak Dasar" | Pembelajaran penghasilan tambahan & pajak dasar selesai |
| 10B | **Tingkat Menengah Bagian 3:** Modul 12 "Tujuan Besar & Perencanaan" | Pembelajaran tujuan besar & perencanaan selesai (seluruh Tingkat Menengah tuntas) |
| 11 | **Tingkat Lanjutan** (modul 13–18) | Kurikulum penuh |
| 12 | **Polesan, aksesibilitas, uji pengguna, tinjauan konten, rilis** | v1.0 |

**MVP = tahap 1–7.** Bangun satu modul tuntas (belajar → gerbang → misi → umpan balik) sebelum menambah modul.

---

## 18. Kriteria Selesai per Modul

- [ ] Semua pelajaran punya konten, cek paham, misi, dan syarat data (gerbang)
- [ ] Opsi "pernyataan kosong" ada untuk syarat yang bisa tidak berlaku
- [ ] Kuis akhir modul ada dan bisa diulang
- [ ] Semua kalkulator punya uji unit dengan contoh angka tangan
- [ ] Konten sudah ditinjau kebenarannya
- [ ] Bahasa lolos uji baca orang awam
- [ ] Alur diuji, termasuk kondisi data kosong
- [ ] README dan CHANGELOG diperbarui

---

## 19. Keputusan Terbuka

1. Cakupan fitur dompet digital: apakah daftar di 9.1 sudah sesuai yang kamu bayangkan?
2. Ambang lulus kuis (usulan 70%) dan apakah modul berikutnya wajib menunggu kuis lulus.
3. Siapa yang meninjau kebenaran materi (pajak, kredit, proteksi, investasi, warisan).
4. Mode gelap di v1 atau nanti.
5. Sensor nominal di laporan: perlu atau tidak.
6. Rilis iOS: kapan, dan siapa yang mengurus akun developer + perangkat build.
7. Ketersediaan nama **Funda** di toko aplikasi dan merek (lihat catatan di percakapan).
8. Teks disclaimer final.
