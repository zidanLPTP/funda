# styleguide.md — Panduan Gaya Funda

> v1.1.0 (Funda, Flutter). Gaya yang disepakati: **Colorful Bento + Card Combo** (pengembangan dari *soft bento UI* agar lebih hidup, kuat, dan *playable* tanpa menghilangkan ketenangan). Semua nilai kontras telah diverifikasi memenuhi WCAG AA >= 4.5:1. Keluaran skill desain tidak boleh menyalahi dokumen ini tanpa persetujuan pemilik proyek.

---

## 1. Karakter Rasa (Brand Feel)

Aplikasi ini harus terasa seperti **teman yang paham uang dan sabar**, bukan bank, bukan guru yang menceramahi.

| Kata kunci | Artinya di desain |
|---|---|
| **Tenang** | Banyak ruang kosong, warna lembut, tidak ramai |
| **Ramah** | Sudut membulat, bahasa santai, ilustrasi hangat |
| **Jelas** | Satu fokus per layar, angka besar dan terbaca |
| **Dipercaya** | Konsisten, rapi, tidak berlebihan animasinya |
| **Menguatkan** | Merayakan kemajuan kecil, tidak menghakimi pengeluaran |

**Hindari:** nuansa "bank kaku", warna merah menyala di mana-mana (memicu cemas), gaya kasino/trading, jargon, gamifikasi yang bising.

---

## 1b. Gaya Soft Bento

Antarmuka tersusun dari **petak-petak (tile) membulat** berukuran beragam di atas grid, seperti kotak bento: tiap petak berisi **satu ide**, ukuran petak menunjukkan **tingkat kepentingan**.

- **Grid:** 2 kolom di ponsel, jarak antarpetak **12dp**. Ukuran petak: `1×1`, `2×1` (lebar penuh), `2×2` (hero, jarang).
- **Satu petak = satu ide.** Judul kecil + satu angka/visual utama + satu aksi opsional. Jangan menumpuk tabel padat di dalam petak.
- **Lembut:** radius besar (24), warna latar petak berupa **tint pastel**, batas halus atau bayangan sangat tipis. Tidak ada garis tebal atau bayangan keras.
- **Napas:** padding dalam petak 16–20dp; ruang kosong disengaja.
- **Hierarki:** satu petak hero per layar (mis. arus kas bulan ini). Sisanya pendukung.
- **Ikon** ditempatkan dalam kotak membulat kecil berwarna tint.
- **Konsisten:** petak serupa selalu berukuran dan berposisi serupa di layar berbeda.

**Contoh tata letak Beranda:**
1. `2×1` Hero: arus kas bulan ini (angka besar)
2. `1×1` Sisa anggaran | `1×1` Progres dana darurat
3. `2×1` Lanjut belajar (pelajaran berikutnya + status gerbang)
4. `1×1` Rasio cicilan | `1×1` Tujuan tabungan terdekat
5. `2×1` Transaksi terakhir

---

## 2. Warna `[ASUMSI]`

### Palet dasar
| Token | Hex | Pemakaian |
|---|---|---|
| `warnaUtama` | `#0F766E` | Tombol utama, tab aktif, tautan |
| `warnaUtamaGelap` | `#0E5133` | Tekan/aktif, variasi hijau tua Funda |
| `warnaUtamaTipis` | `#BDF5E8` | Latar lencana, sorotan lembut |
| `latar` | `#F6FAF8` | Latar layar |
| `permukaan` | `#FFFFFF` | Kartu putih bersih, lembar bawah |
| `garis` | `#D8E3DF` | Pemisah, batas kartu |
| `teks` | `#0F1F1D` | Teks utama |
| `teksRedup` | `#475855` | Teks sekunder (kontras >= 4.5:1 di atas seluruh tint pastel) |
| `aksen` | `#F59E0B` | Sorotan pencapaian (hemat dipakai) |

### Warna makna (semantik)
| Token | Hex | Pemakaian |
|---|---|---|
| `pemasukan` | `#047857` | Uang masuk |
| `pengeluaran` | `#D9480F` | Uang keluar (koral hangat tegas, **bukan merah alarm**) |
| `bahaya` | `#B91C1C` | Hanya untuk peringatan nyata (hapus data, lewat jatuh tempo) |
| `peringatan` | `#B45309` | Mendekati batas anggaran |
| `sukses` | `#047857` | Misi selesai, target tercapai |
| `info` | `#1D4ED8` | Info netral |

### Tint petak bento (latar petak, teks tetap `teks`)
| Token | Hex | Batas Serasi | Dipakai untuk |
|---|---|---|---|
| `tintHijau` | `#D5F5EA` | `#A7E8D4` | Arus kas, tabungan, dana darurat |
| `tintBiru` | `#DBEAFE` | `#BFDBFE` | Kebutuhan, anggaran, tujuan |
| `tintUngu` | `#EDE2FE` | `#DDD6FE` | Keinginan, refleksi, belajar |
| `tintAmber` | `#FEF0C7` | `#FDE68A` | Utang, peringatan lembut, mode sandbox |
| `tintMawar` | `#FCE0EC` | `#FBCFE8` | Tagihan lewat, beban cicilan, kekayaan bersih negatif bernada menguatkan |
| `tintNetral` | `#EEF4F2` | `#DCE7E3` | Kartu sekunder netral |

### Warna sifat pengeluaran (inti konsep aplikasi)
| Sifat | Hex | Ikon pendamping wajib |
|---|---|---|
| Kebutuhan | `#2563EB` | ikon "perisai/rumah" (`shield`) |
| Keinginan | `#7C3AED` | ikon "hadiah/tas belanja" (`gift` / `shoppingBag`, **tanpa ikon bintang**) |
| Tabungan & Dana Darurat | `#0F766E` | ikon "celengan/brankas" (`piggyBank`) |
| Utang/Cicilan | `#B45309` | ikon "rantai/kalender" (`calendarClock`) |

**Aturan:**
- **Jangan mengandalkan warna saja.** Selalu pasangkan dengan ikon atau teks.
- Kontras teks normal minimal **4.5:1**, teks besar dan komponen UI minimal **3:1** terhadap latarnya.
- Warna "pengeluaran" bukan tanda "buruk". Pengeluaran itu normal; jangan beri nuansa menyalahkan.
- Mode gelap: **belum di v1** `[ASUMSI]`. Gunakan token agar bisa ditambahkan nanti tanpa mengubah komponen.

---

## 3. Tipografi

- **Font:** `Plus Jakarta Sans` (satu keluarga untuk semua), **dibundel sebagai aset aplikasi** (tidak diunduh saat berjalan, agar bekerja offline); cadangan: font sistem.
- Skala (dp / sp, mengikuti ukuran teks sistem pengguna):

| Peran | Ukuran | Berat | Tinggi baris |
|---|---|---|---|
| Angka besar (saldo, hasil hitung) | 32 | Bold | 40 |
| Judul layar | 24 | Bold | 32 |
| Judul bagian | 18 | SemiBold | 26 |
| Isi | 16 | Regular | 24 |
| Isi kecil / keterangan | 14 | Regular | 20 |
| Label/tombol | 15 | SemiBold | 20 |
| Catatan kaki | 12 | Regular | 16 |

- **Isi materi pelajaran** memakai 16–17 dengan tinggi baris longgar (±1,6) untuk kenyamanan membaca.
- **Angka uang** memakai angka rata-lebar (tabular) bila font mendukung agar kolom rapi.
- Mendukung pembesaran teks sistem sampai 200% tanpa terpotong.

---

## 4. Spasi, Bentuk, Elevasi

- **Grid 4dp.** Skala spasi: `4, 8, 12, 16, 24, 32, 48`.
- Margin layar: **16** (kartu penuh), **24** (layar pelajaran).
- **Radius:** kecil `8`, kartu biasa `16`, **petak bento `24`**, lembar bawah `28`, tombol/penanda `999` (pil).
- **Elevasi:** minim. Utamakan batas halus (`garis`) dan perbedaan latar daripada bayangan tebal.
- Satu layar = **satu aksi utama** (satu tombol primer).

---

## 5. Komponen Inti

### Petak Bento
- Latar tint, radius 24, padding 16–20, jarak antarpetak 12.
- Struktur: label kecil (`teksRedup`) → angka/visual utama → keterangan satu baris → (opsional) aksi.
- Petak yang bisa diketuk punya efek tekan halus (skala ±0,98) dan label akses yang jelas.
- Petak terkunci (pelajaran dengan gerbang data) menampilkan **apa yang kurang** + tombol ke layar pengisiannya.

### Tombol
- **Primer** (isi `warnaUtama`, teks putih), **Sekunder** (garis), **Teks** (tanpa latar).
- Tinggi min. **48dp**, lebar penuh untuk aksi utama di layar pelajaran/misi.
- Status: normal, ditekan, nonaktif, memuat. Tombol nonaktif tetap menjelaskan *kenapa* nonaktif.

### Kartu Pelajaran (peta belajar)
- Judul, durasi (mis. "4 menit"), status (belum / sedang / selesai), ikon modul.
- Pelajaran terkunci memberi petunjuk cara membukanya, bukan hanya ikon gembok.

### Layar Pelajaran
- Kartu geser dengan penanda kemajuan di atas. **Satu ide per kartu.**
- Tombol "Lanjut" besar di bawah; tombol kembali selalu ada.
- Istilah teknis ber-**garis bawah putus-putus** → ketuk untuk penjelasan singkat + contoh Rupiah.

### Kartu Misi
- Tampil menonjol di akhir pelajaran: judul tugas, apa yang akan dilakukan, perkiraan waktu.
- Selalu ada pilihan **"Lewati / belum relevan"** dan **"Coba pakai data contoh"**.
- Setelah selesai: tampilkan **umpan balik dari data pengguna** (angka/grafik), bukan hanya centang.

### Input uang
- Papan angka besar, pemisah ribuan otomatis, awalan `Rp`.
- Pintasan cepat nominal (mis. +10rb, +50rb) di entri transaksi.
- Pemilih sifat (Kebutuhan / Keinginan / Tabungan / Utang) berupa **chip** dengan ikon.

### Daftar Transaksi
- Per hari, subjumlah harian. Jumlah rata kanan, warna makna + tanda `+`/`−`.
- Geser untuk ubah/hapus dengan konfirmasi + opsi "Urungkan".

### Grafik & Ringkasan
- Maksimal satu grafik utama per kartu; judul menjelaskan kesimpulannya ("Pengeluaran keinginanmu 38% bulan ini").
- Bar progres anggaran: normal → peringatan (≥ 80%) → melewati; **ikon + teks** menyertai warna.

### Keadaan Kosong (Empty State)
- Ilustrasi sederhana + satu kalimat + satu tombol. Contoh: "Belum ada transaksi. Yuk catat yang pertama." Jangan pernah biarkan layar kosong tanpa arahan.

### Umpan balik sistem
- **Toast** untuk aksi kecil; **dialog** hanya untuk aksi merusak.
- Pesan galat: sebut masalah + solusi, tanpa menyalahkan ("Jumlah belum diisi" bukan "Input salah!").

---

## 6. Ikon & Ilustrasi

- Satu pustaka ikon konsisten (garis, tebal seragam). **Tidak memakai emoji sebagai ikon UI.**
- Ilustrasi: sederhana, hangat, bentuk geometris lembut, palet sama dengan aplikasi. Tidak ada gambar stok "orang tersenyum memegang uang".
- Tidak ada ikon yang terasa "template AI generik".

---

## 7. Gerak (Motion)

- Singkat dan bermakna: **150–250 ms**, easing lembut.
- Dipakai untuk: transisi kartu pelajaran, kemajuan progres, perayaan misi selesai (kecil, sebentar).
- Hormati pengaturan sistem **"kurangi gerakan"**.
- Perayaan: hemat. **Tanpa badge, level, atau streak** (keputusan produk). Cukup pesan hangat dan indikator progres.

---

## 8. Suara & Bahasa (sangat penting)

**Sapaan:** "kamu" (santai-sopan), bukan "Anda", bukan "lo/gue".

**Pilar gaya bahasa (disepakati):**
1. **Santai & praktis** — seperti teman yang paham uang.
2. **Memberdayakan** — pengguna yang mengendalikan, aplikasi membantu.
3. **Bebas jargon rumit** — istilah teknis dijelaskan dengan contoh Rupiah.
4. **Mudah dicerna** — kalimat pendek, satu ide per kartu (micro-learning).
5. **Aplikatif & berorientasi aksi** — setiap bagian berujung langkah nyata di aplikasi.
6. **Positif & membangun kepercayaan diri** — rayakan langkah kecil, jangan menghakimi.

**Aturan menulis materi:**
1. Kalimat pendek. Satu ide per kalimat.
2. Mulai dari situasi nyata, baru konsep.
3. Setiap istilah teknis: jelaskan dengan **contoh angka Rupiah**.
4. Aktif, bukan pasif. "Catat pemasukanmu" bukan "Pemasukan harus dicatat."
5. Tidak menghakimi. Jangan pakai kata "boros", "salah", "bodoh" untuk perilaku pengguna.
6. Tidak menjanjikan hasil pasti ("pasti kaya"). Gunakan "biasanya", "umumnya", "bisa".
7. Perayaan yang tulus, bukan berlebihan.

**Contoh baik vs buruk**

| ❌ Hindari | ✅ Pakai |
|---|---|
| "Anda mengalami defisit arus kas operasional." | "Bulan ini uang keluarmu lebih besar Rp300.000 dari uang masukmu." |
| "Pengeluaranmu terlalu boros!" | "Keinginan memakai 38% uangmu bulan ini. Mau kita lihat bareng?" |
| "Tidak ada transaksi." | "Belum ada catatan. Yuk mulai dari yang pertama." |
| "Input tidak valid." | "Jumlahnya belum diisi." |

**Daftar istilah** (tooltip) disimpan di `aset/konten/kamus.json`; setiap entri: istilah, arti satu kalimat, contoh Rupiah.

---

## 9. Aksesibilitas

- Target sentuh ≥ 48×48dp.
- Semua elemen interaktif punya label untuk pembaca layar; grafik punya ringkasan teks.
- Urutan fokus logis; tidak ada informasi hanya lewat warna.
- Dukungan teks besar, dan layar tidak rusak pada 200%.
- Uji dengan pembaca layar (TalkBack di Android, VoiceOver di iOS) pada alur utama: catat transaksi, selesaikan pelajaran + misi.

---

## 10. Token Tema (acuan implementasi Flutter)

Penamaan memakai bahasa Indonesia (lihat `agent.md` bagian 5).

```dart
// lib/tema/token.dart
import 'package:flutter/material.dart';

class WarnaFunda {
  static const utama = Color(0xFF0F766E);
  static const utamaGelap = Color(0xFF115E59);
  static const utamaTipis = Color(0xFFCCFBF1);
  static const latar = Color(0xFFF8FAF9);
  static const permukaan = Color(0xFFFFFFFF);
  static const garis = Color(0xFFE2E8E6);
  static const teks = Color(0xFF0F1F1D);
  static const teksRedup = Color(0xFF5B6B68);
  static const aksen = Color(0xFFF59E0B);

  static const pemasukan = Color(0xFF15803D);
  static const pengeluaran = Color(0xFFC2410C);
  static const bahaya = Color(0xFFB91C1C);
  static const peringatan = Color(0xFFB45309);
  static const sukses = Color(0xFF15803D);
  static const info = Color(0xFF1D4ED8);

  // Warna sifat pengeluaran
  static const sifatKebutuhan = Color(0xFF2563EB);
  static const sifatKeinginan = Color(0xFF7C3AED);
  static const sifatTabungan = Color(0xFF0F766E);
  static const sifatUtang = Color(0xFFB45309);

  // Tint petak bento
  static const tintHijau = Color(0xFFE6F4F1);
  static const tintBiru = Color(0xFFE8F0FE);
  static const tintUngu = Color(0xFFF1EBFD);
  static const tintAmber = Color(0xFFFEF3E2);
  static const tintNetral = Color(0xFFF1F5F4);
}

class SpasiFunda {
  static const double xs = 4, s = 8, m = 12, l = 16, xl = 24, xxl = 32, xxxl = 48;
  static const double jarakPetak = 12;
}

class SudutFunda {
  static const double kecil = 8, kartu = 16, petak = 24, lembar = 28, pil = 999;
}
```

Semua komponen **wajib** memakai token ini; tidak ada warna/ukuran hard-coded.
