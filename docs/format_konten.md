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
  "contohAngka": 1500000,
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
4. **Relasi Misi vs Gerbang Data**:
   - Misi pada berkas pelajaran **tidak boleh otomatis terpenuhi oleh gerbang pelajarannya sendiri** (misi tidak boleh lebih longgar atau sama dengan gerbang), kecuali bertipe `lihat_hitungan`.
   - Aturan `semua_kategori_berlabel` terpenuhi **HANYA** bila terdapat minimal 1 kategori pengeluaran yang pernah dipakai dalam transaksi dan seluruhnya berlabel sifat (pada data kosong = belum terpenuhi).
5. **Contoh Angka Nyata**:
   - Contoh angka wajib menggunakan mata uang Rupiah nominal bulat (`int`).
   - Hindari persentase abstrak tanpa padanan Rupiah (misal: "simpan 20% atau sekitar Rp600.000 dari gaji Rp3.000.000").
6. **Nada Edukasi**:
   - Bersahabat, suportif, dan realistis terhadap kondisi ekonomi Indonesia sehari-hari.
   - Pilihan "Belum relevan buat aku" selalu tersedia pada misi praktik nyata untuk menghargai kenyamanan pengguna.
