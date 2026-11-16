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
    "objek": "transaksi",
    "min": 1,
    "judul": "Catat Arus Kas Pertamamu",
    "deskripsi": "Buka menu Catatan dan masukkan satu transaksi pemasukan atau pengeluaran yang kamu lakukan hari ini apa adanya.",
    "perkiraanMenit": 2,
    "umpanBalik": "arus_kas_bulan_ini"
  },
  "tindakLanjut": "Jadikan mencatat transaksi sebagai rutinitas ringan setiap kali selesai berbelanja."
}
```

---

## 5. Aturan Penulisan Kalimat & Gaya Bahasa

1. **Panjang Kalimat**: Maksimal 25 kata per kalimat. Gunakan kalimat aktif, ringkas, dan jelas.
2. **Tanpa Kata Terlarang**:
   - Dilarang keras menggunakan kata-kata menghakimi seperti: *boros, salah, bodoh, payah, gagal, malas, ceroboh*.
   - Dilarang menggunakan janji palsu atau skema cepat kaya seperti: *pasti kaya, cuan instan, bebas finansial 1 tahun*.
3. **Penyebutan Istilah**: Istilah keuangan yang memiliki entri di kamus wajib dibungkus dalam tag `{{nama istilah}}` dengan huruf kecil.
4. **Contoh Angka Nyata**:
   - Contoh angka wajib menggunakan mata uang Rupiah nominal bulat (`int`).
   - Hindari persentase abstrak tanpa padanan Rupiah (misal: "simpan 20% atau sekitar Rp600.000 dari gaji Rp3.000.000").
5. **Nada Edukasi**:
   - Bersahabat, suportif, dan realistis terhadap kondisi ekonomi Indonesia sehari-hari.
   - Pilihan "Belum relevan buat aku" selalu tersedia pada misi praktik nyata untuk menghargai kenyamanan pengguna.
