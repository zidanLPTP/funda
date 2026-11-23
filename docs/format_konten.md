# Format Konten Kurikulum Belajar Funda

Dokumen ini mendefinisikan struktur berkas JSON, skema data, aturan penulisan kalimat, dan batasan konten edukasi finansial pada aplikasi Funda.

---

## 1. Lokasi & Organisasi Berkas

Seluruh konten edukasi bersifat statis dan tersimpan pada folder aset aplikasi:
```
aset/konten/
├── kamus.json
└── pemula/
    └── anggaran_arus_kas/
        ├── modul.json
        ├── anggaran_arus_kas_1_2.json
        └── anggaran_arus_kas_1_3.json
```

1. **`kamus.json`**: Menyimpan daftar istilah finansial yang dapat dipanggil di teks pelajaran menggunakan format `{{istilah}}`.
2. **`[tingkat]/[modul_id]/modul.json`**: Metadata modul, daftar pelajaran, dan bank soal kuis akhir modul.
3. **`[tingkat]/[modul_id]/[pelajaran_id].json`**: Detail alur pelajaran berurutan (pemantik, kartu konsep, contoh angka, cek paham, misi praktik nyata, umpan balik, dan tindak lanjut).

---

## 2. Format `kamus.json`

```json
{
  "versi": 1,
  "istilah": {
    "arus kas": {
      "istilah": "Arus Kas",
      "arti": "Perpindahan uang masuk (pemasukan) dan uang keluar (pengeluaran) dalam rentang waktu tertentu.",
      "contohRupiah": 500000,
      "contohKonkret": "Gaji bulanan Rp3.000.000 dikurangi belanja dapur Rp2.500.000 menyisakan arus kas bersih Rp500.000."
    }
  }
}
```

- **`istilah`**: Kunci pencarian dalam huruf kecil.
- **`arti`**: Definisi singkat maksimal 25 kata dalam bahasa Indonesia sederhana.
- **`contohRupiah`**: Integer nominal Rupiah (`int`), bukan desimal.
- **`contohKonkret`**: Contoh nyata dalam kehidupan sehari-hari.

---

## 3. Format `modul.json`

```json
{
  "id": "anggaran_arus_kas",
  "judul": "Anggaran & Arus Kas",
  "tingkat": "pemula",
  "urutan": 1,
  "deskripsiSingkat": "Fondasi penting menguasai arus kas dan membedakan kebutuhan dari keinginan.",
  "tersedia": true,
  "gerbang": [],
  "daftarPelajaran": [
    "anggaran_arus_kas_1_2",
    "anggaran_arus_kas_1_3"
  ],
  "kuis": {
    "jumlahSoal": 5,
    "bankSoal": [
      {
        "id": "soal_1",
        "pelajaranId": "anggaran_arus_kas_1_2",
        "tanya": "Apa tanda bahwa arus kas bulananmu sehat?",
        "pilihan": [
          "Pengeluaran lebih besar dari pemasukan",
          "Pemasukan lebih besar dari pengeluaran sehingga ada sisa saldo",
          "Semua uang langsung dihabiskan tanpa sisa",
          "Meminjam uang setiap akhir bulan"
        ],
        "benar": 1,
        "penjelasan": "Arus kas sehat ditandai pemasukan melebihi pengeluaran, menyisakan ruang bernapas untuk menabung."
      }
    ]
  }
}
```

- **`tingkat`**: Hanya boleh `pemula`, `menengah`, atau `lanjutan`.
- **`tersedia`**: Boolean. Jika `false`, modul berlabel "Segera Hadir".
- **`gerbang`**: Daftar syarat prasyarat membuka modul (bila ada).
- **`kuis.jumlahSoal`**: Jumlah soal yang dipilih secara acak deterministik (nilai kelulusan minimal 70%).

---

## 4. Format Berkas Pelajaran (`[pelajaran_id].json`)

```json
{
  "id": "anggaran_arus_kas_1_2",
  "modulId": "anggaran_arus_kas",
  "judul": "Memetakan Arus Kas",
  "durasiMenit": 5,
  "status": "draf",
  "gerbang": [],
  "pemantik": "Pernah merasa uang gaji numpang lewat tanpa jejak yang jelas?",
  "kartu": [
    {
      "urutan": 1,
      "judul": "Uang Masuk vs Uang Keluar",
      "isi": "{{arus kas}} adalah rekaman sederhana tentang seberapa deras uang mengalir masuk dan keluar dari dompetmu setiap hari."
    }
  ],
  "contohAngka": {
    "judul": "Pengeluaran kecil yang menumpuk (uang bulanan Rp2.000.000)",
    "baris": [
      { "label": "Kopi susu 20 hari", "jumlah": -360000 },
      { "label": "Camilan sore", "jumlah": -200000 },
      { "label": "Langganan tidak terpakai", "jumlah": -149000 },
      { "label": "Total bocor kecil", "jumlah": -709000, "ringkasan": true }
    ],
    "kesimpulan": "Hampir sepertiga uang bulanan terpakai untuk pos yang jarang disadari."
  },
  "aturanPraktis": false,
  "catatanReviewer": null,
  "cekPaham": [
    {
      "id": "cek_1",
      "tanya": "Jika kamu menerima gaji Rp4.000.000 dan belanja Rp4.500.000, bagaimana kondisi arus kasmu?",
      "pilihan": [
        "Arus kas positif dan saldo bertambah",
        "Arus kas negatif dan saldo berkurang",
        "Arus kas seimbang tanpa perubahan"
      ],
      "benar": 1,
      "penjelasan": "Belanja lebih besar dari pemasukan menghasilkan defisit atau arus kas negatif."
    }
  ],
  "misi": {
    "tipe": "ada_data",
    "objek": "arus_kas",
    "min": 1,
    "judul": "Catat Arus Kas Pertamamu",
    "deskripsi": "Catat minimal 1 uang masuk dan 1 uang keluar di dompetmu untuk melihat arus kas bulan ini.",
    "perkiraanMenit": 2,
    "umpanBalik": "arus_kas_bulan_ini"
  },
  "tindakLanjut": "Jadikan mencatat transaksi sebagai rutinitas ringan setiap kali selesai berbelanja."
}
```

### 4.1 Daftar Objek Resmi Gerbang & Misi
Berikut adalah daftar objek resmi yang valid untuk syarat `gerbang` (modul/pelajaran) dan target `misi`:
- **`dompet`**: Jumlah akun dompet aktif (tipe `ada_data`).
- **`pemasukan`**: Jumlah transaksi jenis pemasukan (tipe `ada_data`).
- **`pengeluaran`**: Jumlah transaksi jenis pengeluaran (tipe `ada_data`).
- **`transaksi`**: Jumlah seluruh transaksi (pemasukan + pengeluaran + transfer) (tipe `ada_data`).
- **`anggaran`**: Jumlah kategori anggaran bulanan aktif (tipe `ada_data`).
- **`tujuan`**: Jumlah tujuan/pos/kantong tabungan aktif (tipe `ada_data`).
- **`utang`**: Jumlah catatan utang/piutang aktif (tipe `ada_data`).
- **`arus_kas`**: Komposit pemasukan >= min DAN pengeluaran >= min (tipe `aturan_data` atau `ada_data`).
- **`profil`**: Profil keuangan pengguna sudah diisi (bukan dilewati, bukan kosong; tipe `ada_data`).

### 4.2 Skema Baru Tahap 6: `contohAngka` & Penanda `aturanPraktis`
1. **`contohAngka`**: Objek berstruktur dengan properti:
   - `judul`: String judul contoh angka konkret.
   - `baris`: Array objek `{ "label": String, "jumlah": int, "ringkasan": bool (opsional) }`. Nilai negatif dirender dengan format Rupiah rapat positif (contoh `Rp900.000`) karena kolom label sudah membedakan arah pos pengeluaran.
   - `kesimpulan`: Kalimat kesimpulan ringkas.
2. **`aturanPraktis` & `catatanReviewer`**:
   - Jika materi atau soal memuat formula/aturan praktis populer (seperti 50/30/20), bidang `aturanPraktis: true` wajib disematkan.
   - Setiap berkas/soal dengan `aturanPraktis: true` wajib menyertakan `catatanReviewer` berawalan `"TODO-VERIFIKASI:"`.

### 4.3 Registri Kunci Umpan Balik Misi
Berikut adalah registri kunci umpan balik edukatif yang diolah dari data riil pengguna:
- **`arus_kas_bulan_ini`**: Ringkasan uang masuk vs uang keluar pengguna bulan berjalan.
- **`komposisi_sifat_bulan_ini`**: Distribusi pengeluaran pengguna per sifat (kebutuhan, keinginan, tabungan, utang).
- **`catatan_pengeluaran_terbaru`**: Evaluasi jumlah catatan pengeluaran, kategori pengeluaran terakhir, dan nominal Rupiah rapat.
- **`perbandingan_pola_anggaran`**: Perbandingan anggaran riil pengguna (Kebutuhan, Keinginan, Tabungan/Utang, Belum Dilabeli) terhadap pola aturan praktis 50/30/20.
- **`realisasi_anggaran_bulan_ini`**: Evaluasi status pemakaian pos anggaran berjalan (aman <80%, mendekati 80-100%, melewati >100%), sisa pos terbanyak, dan pos melewati batas terjauh.
- **`ringkasan_tujuan_tabungan`**: Evaluasi tujuan tabungan pertama pengguna, nama tujuan, nominal terkumpul, dan target total.
- **`estimasi_tabungan`**: Estimasi kecepatan menabung, sisa dana yang perlu dikumpulkan, dan proyeksi bulan ketercapaian berdasarkan setoran bulanan.
- **`pengeluaran_wajib_bulanan`**: Rata-rata pengeluaran wajib bulanan (kebutuhan + cicilan) berdasarkan rata-rata 3 bulan kalender terakhir yang sudah selesai.
- **`target_dana_darurat`**: Perhitungan titik awal masuk akal dana darurat (3 kali pengeluaran wajib bulanan).
- **`progres_dana_darurat`**: Rasio akumulasi dana darurat terhadap pengeluaran wajib bulanan (dinyatakan dalam kelipatan bulan pengeluaran wajib).
- **`ringkasan_utang`**: Ringkasan jumlah utang aktif, sisa total utang, cicilan per bulan, dan persentase rasio cicilan terhadap pemasukan rata-rata 3 bulan terakhir.
- **`biaya_pinjaman_tercatat`**: Rincian biaya pinjaman (bunga + biaya lain) dari salah satu pinjaman aktif ber-tenor yang dicatat pengguna (cicilan x tenor - pokok).
- **`rasio_cicilan_bulan_ini`**: Evaluasi porsi cicilan per bulan terhadap pemasukan rata-rata 3 bulan terakhir, serta simulasi sensitivitas risiko bila pemasukan turun 25 persen.
- **`urutan_pelunasan`**: Panduan urutan prioritas pelunasan utang aktif berdasarkan metode bola salju (sisa terkecil dahulu) dan metode longsor (bunga tertinggi dahulu).

### 4.4 Skema Baru Tahap 8C: Tipe Misi `keputusan`, `daftar_periksa`, dan Berkas `disclaimer.json`
1. **Tipe Misi `keputusan`**:
   - Skema:
     ```json
     {
       "tipe": "keputusan",
       "judul": "Judul Misi",
       "instruksi": "Instruksi pengerjaan.",
       "skenario": {
         "pemantik": "Deskripsi situasi nyata atau dilema keputusan.",
         "opsi": [
           {
             "id": "a",
             "teks": "Teks opsi pilihan tindakan.",
             "aman": false,
             "umpanBalik": "Penjelasan mengapa opsi ini kurang aman."
           },
           {
             "id": "b",
             "teks": "Teks opsi pilihan tindakan aman.",
             "aman": true,
             "umpanBalik": "Penjelasan apresiasi tindakan aman."
           }
         ]
       }
     }
     ```
   - Aturan validasi:
     - Minimal 2 opsi pilihan.
     - Minimal 1 opsi dengan `aman: true`.
     - Setiap opsi wajib memiliki `umpanBalik` yang tidak kosong.
     - Opsi `aman: true` mengaktifkan tombol "Lanjut" dan menandai misi selesai.
     - Opsi tidak aman menampilkan umpan balik dan tombol "Coba pilihan lain" (boleh diulang tanpa skor dan tanpa batas).
     - Hasil tersimpan di `tabel_hasil_misi`: `status: 'selesai'`, `muatan_json: {"opsiDipilih": ["a", "c", "b"]}` mencatat seluruh urutan percobaan.
2. **Tipe Misi `daftar_periksa`**:
   - Skema:
     ```json
     {
       "tipe": "daftar_periksa",
       "judul": "Judul Misi",
       "instruksi": "Instruksi daftar periksa.",
       "disclaimer": true,
       "minimalDicentang": 3,
       "langkah": [
         {
           "id": "l1",
           "teks": "Langkah konkret yang dilakukan pengguna di luar aplikasi."
         }
       ]
     }
     ```
   - Aturan validasi:
     - Wajib `disclaimer: true`.
     - Minimal 3 butir `langkah`.
     - `1 <= minimalDicentang <= jumlah langkah`.
     - Pelajaran wajib memiliki `catatanReviewer` yang memuat teks `"TODO-VERIFIKASI"`.
     - Komponen `DisclaimerLangkahDuniaNyata` membaca berkas `aset/konten/disclaimer.json`. Pengguna harus mengetuk "Mengerti" sebelum mencentang langkah.
     - Tombol "Selesai" hanya aktif bila `jumlahDicentang >= minimalDicentang`.
     - Hasil tersimpan di `tabel_hasil_misi`: `status: 'selesai'`, `muatan_json: {"dicentang": ["l1", "l2", "l3"]}`. Saat dibuka ulang, centang tersimpan dimuat kembali.
3. **Pengecualian Aturan Misi**:
   - Tipe-tipe misi perilaku (`lihat_hitungan`, `keputusan`, `daftar_periksa`, dan `refleksi`) dikecualikan dari aturan *"misi tidak boleh lebih longgar dari gerbang"* karena menguji pemahaman, refleksi privat, atau keputusan perilaku pengguna di luar aplikasi dan tidak bergantung pada data agregat transaksi riil.
4. **Format Berkas `aset/konten/disclaimer.json`**:
   ```json
   {
     "versi": 1,
     "langkahDuniaNyata": "Funda hanya memberi edukasi umum. Ini bukan ajakan membeli produk keuangan atau nasihat keuangan, hukum, maupun pajak. Keputusan dan risikonya ada padamu. Funda tidak bertanggung jawab atas kerugian dari tindakan di luar aplikasi. Pastikan penyedia berizin sebelum memakai uangmu."
   }
   ```

### 4.5 Skema Baru Tahap 8D: Tipe Misi `refleksi` & Umpan Balik `ringkasan_langganan_dan_keinginan`
1. **Tipe Misi `refleksi` (Privat di Perangkat)**:
   - Skema:
     ```json
     {
       "tipe": "refleksi",
       "judul": "Tulis pemicu belanjamu",
       "instruksi": "Kenali situasi atau emosi yang paling sering membuatmu ingin belanja tanpa rencana.",
       "pertanyaan": "Kapan terakhir kali kamu membeli sesuatu yang sebenarnya tidak kamu butuhkan? Apa yang kamu rasakan saat itu?",
       "petunjukInput": "Misalnya: saat stres sepulang kerja, saat melihat diskon kilat di ponsel...",
       "minimalKarakter": 10
     }
     ```
   - Karakteristik & Perilaku:
     - Dilengkapi label privasi: *"Privat di perangkatmu: tulisan ini hanya tersimpan di HP-mu dan tidak pernah dikirim ke mana pun."*
     - Memiliki `minimalKarakter` (antara 5 sampai 200 karakter, default 10 bila diabaikan).
     - Tombol simpan nonaktif selama panjang teks (setelah `trim()`) kurang dari minimal karakter.
     - Menyimpan refleksi pengguna ke `tabel_hasil_misi`: `status: 'selesai'`, `tipe: 'refleksi'`, `muatan_json: {"jawaban": "Teks jawaban pengguna..."}`.
     - Saat layar dibuka kembali, jawaban tersimpan dimuat ulang secara otomatis.
2. **Fungsi Umpan Balik Murni `ringkasan_langganan_dan_keinginan`**:
   - Menghasilkan ringkasan komitmen rutin dari data aktif `tabel_tagihan` (jenis langganan) dan pengeluaran aktual bertanda pos/sifat 'keinginan' bulan ini.
   - Format:
     ```
     Spotify Premium: Rp54.000/bln
     Netflix: Rp186.000/bln
     Total langganan aktif: 2 layanan (Rp240.000/bln)
     Pengeluaran keinginan bulan ini: Rp150.000
     Total komitmen & keinginan: Rp390.000/bln
     ```
     Bila tidak ada langganan aktif:
     ```
     Belum ada langganan aktif yang dicatat.
     Pengeluaran keinginan bulan ini: Rp150.000
     Total komitmen & keinginan: Rp150.000/bln
     ```

---

## 5. Aturan Penulisan Kalimat & Gaya Bahasa

1. **Panjang Kalimat**: Maksimal 25 kata per kalimat. Gunakan kalimat aktif, ringkas, dan jelas. Kalimat > 25 kata menghasilkan **peringatan** (bukan galat).
2. **Daftar Kata Terlarang (Tunggal & Terpusat di `PembacaKonten`)**:
   - Dilarang keras menggunakan kata-kata menghakimi: *boros, bodoh, malas, ceroboh, payah, miskin*.
   - Dilarang menyalahkan perilaku pengguna dengan frasa menghakimi (misal: *"kamu salah"*, *"cara yang salah"*, *"perilaku salah"*).
   - Kata wajar seperti *harus* dan *wajib* **sah digunakan** pada konteks kalimat reguler dan tidak dilarang sebagai galat.
3. **Penyebutan Istilah & Aturan Tooltip Istilah Teknis**:
   - Istilah teknis finansial (*surplus, defisit, aset, liabilitas*) **HANYA boleh muncul** di teks pengguna dalam bentuk `{{istilah}}` agar memiliki bantuan tooltip interaktif dari kamus.
   - Kemunculan istilah teknis sebagai teks polos tanpa kurung kurawal ganda (`{{ }}`) adalah **GALAT** pada pemeriksa bahasa.
   - Teks umpan balik data nyata (`arus_kas_bulan_ini` dan `komposisi_sifat_bulan_ini`) **DILARANG memakai kata surplus atau defisit sama sekali**; wajib menggunakan padanan bahasa awam seperti *"uang masuk lebih besar"* atau *"uang keluar lebih besar"* disertai nominal Rupiah nyata.
4. **Aturan Khusus Konten Modul 5 (Keselamatan & Informasi Sensitif)**:
   - Pada teks yang dilihat pengguna (judul, pemantik, kartu, contohAngka, cekPaham, misi, kuis, tindakLanjut), DILARANG memuat:
     - Tautan web atau alamat URL: kata `"http"`, `"https"`, `"www"`.
     - Alamat surel: simbol `"@"`.
     - Nama lembaga spesifik: `"OJK"`, `"BSSN"`.
     - Nomor kontak/telepon: urutan angka $\ge 8$ digit tanpa titik pemisah ribuan (misal `0812345678`).
   - Judul pelajaran Modul 5 DILARANG memuat kata label biner seperti `"aman"` atau `"bahaya"`.
5. **Relasi Misi vs Gerbang Data**:
   - Misi pada berkas pelajaran **tidak boleh otomatis terpenuhi oleh gerbang pelajarannya sendiri** (misi tidak boleh lebih longgar atau sama dengan gerbang), kecuali bertipe `lihat_hitungan`, `keputusan`, `daftar_periksa`, atau `refleksi`.
   - Aturan `semua_kategori_berlabel` terpenuhi **HANYA** bila terdapat minimal 1 kategori pengeluaran yang pernah dipakai dalam transaksi dan seluruhnya berlabel sifat (pada data kosong = belum terpenuhi).
6. **Contoh Angka Nyata**:
   - Contoh angka wajib menggunakan mata uang Rupiah nominal bulat (`int`).
   - Hindari persentase abstrak tanpa padanan Rupiah (misal: "simpan 20% atau sekitar Rp600.000 dari gaji Rp3.000.000").
7. **Nada Edukasi**:
   - Bersahabat, suportif, dan realistis terhadap kondisi ekonomi Indonesia sehari-hari.
   - Pilihan "Belum relevan buat aku" selalu tersedia pada misi praktik nyata untuk menghargai kenyamanan pengguna.

---

## 6. Format Berkas Tes Awal (`aset/konten/pemula/mulai_tes_awal/tes_awal.json`)

Berkas ini memuat kuesioner profil awal pengguna dan butir soal tes pemahaman konsep dasar.

### 6.1 Pertanyaan Profil Keuangan (`pertanyaanProfil`)
Tepat 6 pertanyaan kondisi profil finansial pengguna dengan kunci dan nilai pilihan yang sesuai skema database:
- **`punya_penghasilan`**: `rutin`, `tidak_rutin`, `belum`
- **`punya_utang`**: `ya`, `tidak`, `tidak_yakin`
- **`dana_darurat`**: `belum`, `sedikit`, `sudah`
- **`menabung`**: `belum`, `kadang`, `rutin`
- **`investasi`**: `belum`, `pernah`, `aktif`
- **`mencatat_keuangan`**: `belum`, `kadang`, `rutin`
- **`tujuanUtama`**: Sasaran keuangan teks bebas opsional (maksimal 100 karakter).

*Catatan: Kolom `rentang` dan `tanggungan` tidak digunakan sesuai keputusan produk (data penghasilan dan jumlah keluarga tidak diminta).*

### 6.2 Soal Tes Awal (`soalTesAwal`)
- Tepat **12 butir soal** (tepat 2 butir soal untuk 6 modul tingkat pemula: `anggaran_arus_kas`, `tabungan`, `dana_darurat`, `utang_cicilan`, `waspada_penipuan`, `psikologi_uang`).
- Setiap butir soal wajib memiliki tepat 4 pilihan jawaban:
  - Pilihan indeks 0 s.d. 2: Pilihan konsep materi.
  - Pilihan indeks 3: Pilihan tetap persis `"Belum tahu, nggak apa-apa"` (dihitung tidak benar dan tidak dihukum).
  - Indeks `benar`: Hanya boleh bernilai 0, 1, atau 2 (tidak boleh menunjuk ke opsi indeks 3).
- **Batasan Isi**: Hanya menguji konsep dasar keuangan. **DILARANG** memuat angka aturan praktis (mis. 50/30/20, jumlah bulan dana darurat), ambang rasio persentase cicilan, tarif spesifik, atau pasal regulasi.

---

## 7. Format Berkas Rekomendasi (`aset/konten/rekomendasi.json`)

Berkas ini memetakan kode alasan heuristik personalisasi ke teks penjelasan yang ramah dan memberdayakan. Aturan evaluasi logika berada di kode murni, **bukan** di data.

### 7.1 Kode Alasan Resmi
1. **`skor_tes_rendah`**: Modul tingkat pemula yang skor tes awalnya < 70%.
2. **`punya_utang_tercatat`**: Ada utang aktif dengan sisa > 0 atau profil `punya_utang == 'ya'`.
3. **`dana_darurat_kosong`**: Tidak ada pos dana darurat aktif atau dana terkumpul 0, atau profil `dana_darurat == 'belum'`.
4. **`keinginan_terbesar`**: Komposisi pengeluaran bulan ini di mana keinginan merupakan sifat terbesar secara STRIK (bukan seri, bukan gabungan) dan total > 0.
5. **`belum_ada_modul_selesai`**: Belum ada modul yang diselesaikan, menyarankan modul terbuka pertama sebagai fondasi awal.

### 7.2 Struktur JSON
```json
{
  "versi": 1,
  "alasan": {
    "skor_tes_rendah": {
      "judul": "Perdalam Pemahaman",
      "deskripsi": "Topik ini bagus untuk diperdalam agar kamu semakin percaya diri mengelola keuangan."
    },
    "punya_utang_tercatat": {
      "judul": "Prioritas Pelunasan Utang",
      "deskripsi": "Membantu menata strategi pelunasan dan beban cicilan agar arus kas lebih lega."
    },
    "dana_darurat_kosong": {
      "judul": "Bantalan Keuangan",
      "deskripsi": "Membangun pos dana darurat memberi ketenangan pikiran saat hal tak terduga terjadi."
    },
    "keinginan_terbesar": {
      "judul": "Keseimbangan Pengeluaran",
      "deskripsi": "Menyadari dan mengelola porsi keinginan membantu pengeluaran tetap seimbang dan terarah."
    },
    "belum_ada_modul_selesai": {
      "judul": "Langkah Fondasi",
      "deskripsi": "Pijakan awal terbaik untuk memetakan uang masuk dan uang keluar sehari-hari."
    }
  }
}
```

---

## 8. Format Berkas Template Laporan Bulanan (`aset/konten/laporan.json`)

Berkas ini adalah sumber kebenaran teks (*single source of truth*) untuk antarmuka pratinjau, ekspor gambar kartu PNG (1080 px), dan dokumen cetak PDF A4. Dilarang mengubah kata-kata dalam template ini tanpa persetujuan reviewer.

### 8.1 Struktur JSON
```json
{
  "versi": 1,
  "judulBagian": {
    "temuan": "Temuan Bulan Ini",
    "saran": "Saran untuk Bulan Depan",
    "arusKas": "Arus Kas Bulan Ini",
    "komposisi": "Komposisi Pengeluaran",
    "anggaran": "Realisasi Anggaran",
    "tujuan": "Tujuan dan Dana Darurat",
    "kekayaan": "Kekayaan Bersih"
  },
  "label": {
    "uangMasuk": "Uang masuk",
    "uangKeluar": "Uang keluar",
    "selisih": "Selisih",
    "kebutuhan": "Kebutuhan",
    "keinginan": "Keinginan",
    "tabungan": "Tabungan & Investasi",
    "utang": "Pembayaran Utang",
    "belumDilabeli": "Belum dilabeli",
    "saldoDompet": "Saldo di dompet",
    "sisaUtang": "Sisa utang tercatat",
    "kekayaanBersih": "Kekayaan bersih",
    "posLain": "pos lain",
    "tujuanBelumAda": "Belum ada tujuan aktif.",
    "posAnggaranAman": "Semua pos anggaran aman terkendali."
  },
  "catatanKaki": {
    "aplikasi": "Laporan ini dibuat otomatis oleh Funda di perangkatmu. Angka dan analisis bersifat edukatif.",
    "ekspor": "Dibuat otomatis oleh Funda di perangkat pengguna. Bersifat edukatif dan rahasia."
  },
  "temuan": {
    "posMelewati": {
      "kode": "pos_melewati",
      "normal": "Pos {nama} melewati batasnya sebesar {jumlah}. Ini bahan belajar, bukan penilaian.",
      "sensor": "Pos {nama} sudah terpakai {persen} persen dari batasnya. Ini bahan belajar, bukan penilaian."
    },
    "arusKasTanpaPemasukan": {
      "kode": "arus_kas_tanpa_pemasukan",
      "normal": "Bulan ini ada uang keluar, tetapi belum ada uang masuk yang tercatat.",
      "sensor": "Bulan ini ada uang keluar, tetapi belum ada uang masuk yang tercatat."
    },
    "arusKasNegatif": {
      "kode": "arus_kas_negatif",
      "normal": "Uang keluarmu lebih besar {jumlah} dari uang masukmu bulan ini. Ini informasi untuk membantumu memutuskan.",
      "sensor": "Uang keluarmu setara {persen} persen dari uang masukmu bulan ini. Ini informasi untuk membantumu memutuskan."
    },
    "sifatTerbesar": {
      "kode": "sifat_terbesar",
      "normal": "Bagian pengeluaran terbesarmu bulan ini ada di {sifat}: {persen} persen.",
      "sensor": "Bagian pengeluaran terbesarmu bulan ini ada di {sifat}: {persen} persen."
    },
    "arusKasPositif": {
      "kode": "arus_kas_positif",
      "normal": "Uang masukmu lebih besar {jumlah} dari uang keluar bulan ini.",
      "sensor": "Uang keluarmu setara {persen} persen dari uang masukmu bulan ini."
    },
    "dataBelumCukup": {
      "kode": "data_belum_cukup",
      "normal": "Datamu bulan ini masih sedikit. Setiap catatan membantu gambarannya makin jelas.",
      "sensor": "Datamu bulan ini masih sedikit. Setiap catatan membantu gambarannya makin jelas."
    }
  },
  "saran": {
    "buatAnggaran": {
      "kode": "buat_anggaran",
      "teks": "Buat anggaran untuk bulan depan di menu Anggaran. Mulai dari tiga kategori saja."
    },
    "tinjauPos": {
      "kode": "tinjau_pos",
      "teks": "Tinjau lagi pos {nama}: ubah batasnya atau kebiasaannya, pilih satu saja."
    },
    "beriLabel": {
      "kode": "beri_label",
      "teks": "Beri label pada kategori {nama} supaya gambaran pengeluaranmu lebih jelas."
    },
    "salinAnggaran": {
      "kode": "salin_anggaran",
      "teks": "Salin anggaran bulan ini ke bulan depan, lalu sesuaikan bagian yang perlu."
    }
  }
}
```

### 8.2 Prioritas Pemilihan Temuan (P1 sampai P6)
1. **P1 (`pos_melewati`):** Ada pos anggaran yang melewati batas (`terpakai > batas`). Dipilih pos dengan selisih melewati terbesar.
2. **P2 (`arus_kas_tanpa_pemasukan`):** Ada pengeluaran tetapi pemasukan sama dengan 0.
3. **P3 (`arus_kas_negatif`):** Uang keluar > uang masuk (defisit), dengan uang masuk > 0.
4. **P4 (`sifat_terbesar`):** Salah satu sifat (`kebutuhan`, `keinginan`, `tabungan`, `utang`, `belum_dilabeli`) mendominasi secara strik (persentase terbesar tunggal).
5. **P5 (`arus_kas_positif`):** Uang masuk > uang keluar (surplus), dengan uang keluar > 0.
6. **P6 (`data_belum_cukup`):** Tidak ada transaksi, atau masuk == 0 dan keluar == 0.

### 8.3 Prioritas Pemilihan Saran (P1 sampai P4)
1. **P1 (`buat_anggaran`):** Pengguna belum memiliki anggaran aktif sama sekali di bulan bersangkutan.
2. **P2 (`tinjau_pos`):** Ada pos anggaran yang melewati batas (prioritas pada pos dengan selisih melewati terbesar).
3. **P3 (`beri_label`):** Ada pengeluaran kategori yang belum dilabeli sifat (`belum_dilabeli > 0`).
4. **P4 (`salin_anggaran`):** Pengguna sudah memiliki anggaran dan semua pos aman terkendali.

---

## 9. Objek Gerbang/Misi & Kunci Umpan Balik Baru (Tahap 8A: Modul 2 & 3)

### 9.1 Objek Gerbang dan Misi (`objek`)
1. **`tujuan_tabungan`**: Menghitung jumlah pos tujuan berjenis `tabungan` dengan status `aktif` atau `tercapai` (`tabel_tujuan`).
2. **`isi_tujuan_tabungan`**: Menghitung jumlah entri pengisian kantong berjenis `isi` ke pos tujuan tabungan (`tabel_alokasi_kantong` join `tabel_kantong` join `tabel_tujuan`).
3. **`pengeluaran_kebutuhan`**: Menghitung jumlah transaksi pengeluaran (`jenis = 'keluar'`) pada kategori yang berlabel sifat `kebutuhan` (`tabel_transaksi` join `tabel_kategori`).
4. **`tujuan_dana_darurat`**: Menghitung jumlah pos tujuan berjenis `dana_darurat` dengan status `aktif` atau `tercapai` (`tabel_tujuan`).
5. **`isi_dana_darurat`**: Menghitung jumlah entri pengisian kantong berjenis `isi` ke pos tujuan dana darurat (`tabel_alokasi_kantong` join `tabel_kantong` join `tabel_tujuan`).

### 9.2 Kunci Umpan Balik Misi Nyata (`umpanBalik`)
1. **`ringkasan_tujuan_tabungan`**: Merangkum capaian tujuan tabungan aktif terdekat (nama, dana terkumpul, target, persentase rapat, serta setoran bulanan yang diperlukan jika ada tenggat).
2. **`estimasi_tabungan`**: Menghitung sisa target dan proyeksi waktu tercapai (integer ceiling bulan) berdasarkan rata-rata setoran riil 3 bulan kalender, dilengkapi simulasi penambahan Rp50.000 per bulan.
3. **`pengeluaran_wajib_bulanan`**: Menghitung rata-rata pengeluaran wajib bulanan (kebutuhan pokok + cicilan utang) dari 3 bulan kalender selesai terakhir atau bulan berjalan.
4. **`target_dana_darurat`**: Menghitung kisaran aturan praktis dana darurat 3 sampai 6 kali pengeluaran wajib bulanan dan menyarankan titik awal 3 kali.
5. **`progres_dana_darurat`**: Merangkum posisi dana darurat saat ini (Rupiah, persentase) dan mengonversinya ke dalam satuan bulan bertahan (`formatBulanDesimal`).

---

## 10. Objek Gerbang/Misi, Kunci Pernyataan & Umpan Balik Baru (Tahap 8B: Modul 4)

### 10.1 Gerbang Modul & Kunci Pernyataan
1. **Gerbang Modul:**
   - Syarat 1: `modul_selesai` -> `dana_darurat`
   - Syarat 2: `ada_data` -> `utang` minimal 1, atau pernyataan dengan kunci `tidak_punya_utang`.
2. **Kunci Pernyataan (`atauPernyataan`):**
   - Menggunakan nilai resmi `tidak_punya_utang` (tersimpan di `tabel_pernyataan`).

### 10.2 Ambang Kelulusan Kuis
- Ambang kelulusan kuis bersifat **global** mengacu pada konstanta `ambangLulusKuis = 70%` (skor minimal 70%, atau 4 benar dari 5 soal acak). Tidak ada ambang kelulusan khusus per modul.

### 10.3 Kunci Umpan Balik Misi Belajar Modul 4 (`umpanBalik`)
1. **`ringkasan_utang`**: Merangkum jumlah utang aktif, sisa total utang, cicilan per bulan, dan porsi cicilan terhadap pemasukan bulanan (3 bulan terakhir atau bulan berjalan).
2. **`biaya_pinjaman_tercatat`**: Menghitung biaya pinjaman (total cicilan x tenor - pokok awal) dari utang aktif ber-tenor lengkap.
3. **`rasio_cicilan_bulan_ini`**: Menghitung rasio cicilan terhadap pemasukan bulanan serta menghitung proyeksi kenaikan rasio jika pemasukan turun 25 persen.
4. **`urutan_pelunasan`**: Menghitung urutan pelunasan utang aktif berdasarkan strategi bola salju (sisa pokok terkecil) dan longsor (bunga persen tertinggi).



