MODUL: paylater_kredit | tingkat: menengah | tersedia: true | urutan: 7
gerbang modul: modul_selesai utang_cicilan
pesan gerbang modul: "Selesaikan Modul 4 (Utang & Cicilan) dulu sebelum mempelajari cara kerja paylater dan reputasi kredit."

---------------------------------------------------------------------
PELAJARAN paylater_kredit_7_1
judul: Cara Kerja Paylater di Balik Layar
durasiMenit: 5
gerbang pelajaran: tidak ada (berlaku gerbang modul)
catatanReviewer: TODO-VERIFIKASI. Gambaran umum biaya layanan, bunga, dan denda paylater bersifat ilustratif; periksa istilah umum terkini.

pemantik:
Promo cicilan 0 persen terasa seperti diskon gratis. Padahal, di baliknya tetap ada kewajiban bayar di bulan-bulan berikutnya.

kartu 1 | judul: Paylater tetaplah utang
{{Paylater}} memudahkanmu membeli sekarang dan membayar nanti. Meski prosesnya hanya satu ketukan, secara keuangan ia tetap utang yang mengurangi ruang pemasukan bulan depan.

kartu 2 | judul: Biaya di balik kemudahan
Selain harga barang, perhatikan {{biaya layanan}}, bunga cicilan, dan {{denda keterlambatan}}. Promo cicilan tanpa bunga pun kadang tetap mengenakan biaya layanan di awal. Selalu hitung total yang keluar sampai lunas.

kartu 3 | judul: Jebakan cicilan kecil yang menumpuk
Satu cicilan Rp150.000 terasa ringan. Tetapi lima transaksi serupa dalam sebulan langsung menjadi Rp750.000 yang mengikat gajimu berikutnya. Catat semua tagihan paylater di Funda agar totalnya selalu terlihat.

contohAngka:
judul: Belanja Rp1.000.000 dengan paylater 3 bulan (ilustrasi)
baris:
- Harga barang tunai | 1000000
- Biaya layanan dan bunga selama 3 bulan | 95000
- Total yang dibayar sampai lunas | 1095000 | ringkasan
kesimpulan: Membeli lewat paylater membuatmu membayar Rp95.000 lebih mahal dibanding tunai, dan mengikat pemasukan selama 3 bulan.

cekPaham:
1. tanya: Secara keuangan, paylater paling tepat diperlakukan sebagai apa?
   pilihan: Utang yang mengikat pemasukan bulan depan * | Uang tambahan gratis | Tabungan otomatis
   penjelasan: Paylater menunda pembayaran, bukan menghilangkan kewajiban membayarnya.
2. tanya: Apa yang perlu dicek selain cicilan per bulan saat memakai paylater?
   pilihan: Biaya layanan, bunga, denda keterlambatan, dan total sampai lunas * | Warna tombol bayar | Jumlah iklan di aplikasi
   penjelasan: Total biaya sampai lunas menunjukkan harga sebenarnya dari transaksi tersebut.
3. tanya: Mengapa beberapa transaksi paylater kecil bisa memberatkan?
   pilihan: Karena saat digabung, total cicilan bulanannya bisa memakan banyak pemasukan * | Karena nominal kecil tidak bisa dibayar | Karena tagihan hilang sendiri
   penjelasan: Cicilan kecil yang menumpuk mempersempit ruang untuk kebutuhan pokok.

misi: tipe keputusan
judul: Cek sebelum menekan bayar nanti
instruksi: Baca skenarionya, lalu pilih keputusan yang paling masuk akal.
skenario pemantik: Sepatu seharga Rp600.000 sedang diskon. Uang tunaimu bulan ini pas untuk kebutuhan, tetapi ada opsi paylater 3 bulan dengan biaya layanan Rp45.000.
opsi:
- a | Pakai paylater saja karena cicilannya terasa kecil | aman: false | umpanBalik: Cicilan itu tetap mengurangi pemasukanmu tiga bulan ke depan padahal uangmu sedang pas. Coba pilihan lain.
- b | Tunda dulu dan sisihkan uang di tujuan tabungan sampai cukup * | aman: true | umpanBalik: Tepat. Menabung dulu menghindarkanmu dari biaya tambahan dan tekanan cicilan bulan depan.
- c | Ambil tenor lebih panjang supaya cicilannya makin kecil | aman: false | umpanBalik: Tenor lebih panjang biasanya membuat total biaya layanan dan bunga makin besar. Coba pilihan lain.

tindakLanjut:
Jika kamu memakai paylater, catat tanggal jatuh temponya di menu Tagihan agar tidak pernah kena denda keterlambatan.

---------------------------------------------------------------------
PELAJARAN paylater_kredit_7_2
judul: Mengenal Riwayat dan Skor Kredit
durasiMenit: 5
gerbang pelajaran: tidak ada (berlaku gerbang modul)
catatanReviewer: TODO-VERIFIKASI. Penjelasan umum tentang catatan riwayat kredit dan faktor yang memengaruhinya; tidak menyebut nama sistem lembaga tertentu.

pemantik:
Pernah dengar pengajuan kredit rumah atau kendaraan ditolak karena tunggakan kecil beberapa tahun lalu? Itu berhubungan dengan riwayat kredit.

kartu 1 | judul: Apa itu riwayat kredit?
{{Riwayat kredit}} adalah catatan tentang pinjaman, kartu kredit, atau paylater berizin yang pernah kamu pakai, termasuk apakah kamu membayarnya tepat waktu. Catatan ini menjadi bahan pertimbangan penyedia pinjaman di masa depan.

kartu 2 | judul: Apa itu skor kredit?
{{Skor kredit}} adalah gambaran ringkas dari riwayat pembayaranmu. Makin rapi kamu membayar tepat waktu dan menjaga sisa pinjaman tetap wajar, makin baik pula reputasi kreditmu di mata pemberi pinjaman.

kartu 3 | judul: Tunggakan kecil tetap tercatat
Banyak orang mengira tunggakan paylater Rp100.000 tidak berpengaruh. Padahal, keterlambatan pada layanan berizin tetap bisa tercatat dan memengaruhi pengajuan kredit besar di kemudian hari, seperti kredit rumah.

contohAngka:
judul: Ilustrasi dampak keterlambatan pada tagihan Rp500.000
baris:
- Tagihan pokok | 500000
- Denda keterlambatan 1 bulan (ilustrasi) | 50000
- Total yang harus dibayar | 550000 | ringkasan
kesimpulan: Selain menambah biaya Rp50.000, keterlambatan juga meninggalkan jejak pada riwayat kreditmu.

cekPaham:
1. tanya: Apa yang dicatat dalam riwayat kredit?
   pilihan: Jejak pinjaman dan ketepatan pembayaran pada layanan kredit berizin * | Daftar belanja tunai di warung | Jumlah pengikut media sosial
   penjelasan: Riwayat kredit merekam kedisiplinanmu membayar kewajiban kredit berizin.
2. tanya: Mengapa tunggakan paylater bernilai kecil tetap perlu diperhatikan?
   pilihan: Karena tetap bisa tercatat dan memengaruhi pengajuan kredit besar nanti * | Karena nominal kecil tidak perlu dibayar | Karena langsung dihapus esok hari
   penjelasan: Keterlambatan sekecil apa pun pada layanan berizin dapat memengaruhi penilaian kredit di masa depan.
3. tanya: Kebiasaan mana yang paling membantu menjaga reputasi kredit?
   pilihan: Membayar tagihan tepat waktu dan tidak menumpuk cicilan * | Membayar hanya jika sempat | Membuka banyak akun paylater sekaligus
   penjelasan: Ketepatan bayar adalah fondasi utama reputasi kredit yang sehat.

misi: tipe keputusan
judul: Saat tagihan mendekati jatuh tempo
instruksi: Pilih langkah yang paling sehat untuk menjaga riwayat kreditmu.
skenario pemantik: Tagihan paylater Rp400.000 jatuh tempo besok. Kamu punya uangnya, tetapi kamu juga ingin memakainya untuk nongkrong akhir pekan.
opsi:
- a | Bayar tagihan dulu hari ini, lalu sesuaikan rencana akhir pekan dengan sisanya * | aman: true | umpanBalik: Tepat. Membayar tepat waktu menghindarkanmu dari denda dan menjaga riwayat kredit tetap bersih.
- b | Tunda bayar seminggu dulu, nanti bayar dendanya saja | aman: false | umpanBalik: Selain menambah biaya denda, keterlambatan bisa tercatat di riwayat kreditmu. Coba pilihan lain.
- c | Tutup tagihan dengan pinjaman dari aplikasi lain | aman: false | umpanBalik: Menutup utang dengan utang baru hanya memperbesar beban dan risiko. Coba pilihan lain.

tindakLanjut:
Periksa semua akun kredit atau paylater yang masih aktif di HP-mu. Pastikan tidak ada tagihan kecil yang terlupa.

---------------------------------------------------------------------
PELAJARAN paylater_kredit_7_3
judul: Menjaga Reputasi Kredit Tetap Sehat
durasiMenit: 5
gerbang pelajaran: tidak ada (berlaku gerbang modul)
catatanReviewer: TODO-VERIFIKASI. Langkah praktis menjaga reputasi kredit dan mengecek catatan riwayat kredit lewat jalur resmi; tanpa menyebut nama sistem/situs tertentu.

pemantik:
Reputasi kredit dibangun pelan-pelan lewat kebiasaan kecil, tetapi bisa rusak hanya karena satu kali lalai.

kartu 1 | judul: Bayar penuh dan tepat waktu
Bila memakai kartu kredit atau paylater, usahakan membayar penuh sebelum jatuh tempo. Membayar jumlah minimum saja membuat sisa tagihan terus berbunga dan memperpanjang bebanmu.

kartu 2 | judul: Pakai seperlunya, bukan sampai batas
Memiliki batas kredit besar bukan berarti semuanya harus dipakai. Menjaga pemakaian jauh di bawah batas memberi ruang bernapas dan menunjukkan pengelolaan yang terkendali.

kartu 3 | judul: Cek catatan secara berkala
Di dunia nyata, kamu berhak memeriksa catatan riwayat kreditmu lewat layanan resmi {{lembaga pengawas}} keuangan. Pemeriksaan berkala membantumu memastikan tidak ada tagihan salah catat atau penyalahgunaan data.

contohAngka:
judul: Membandingkan bayar penuh vs bayar minimum (tagihan Rp1.000.000)
baris:
- Bayar penuh sebelum jatuh tempo: biaya tambahan | 0
- Bayar sebagian dan menunda: perkiraan bunga dan biaya (ilustrasi) | 60000
kesimpulan: Membayar penuh tepat waktu menjaga biayamu tetap Rp0 dan riwayat kredit tetap bersih.

cekPaham:
1. tanya: Mengapa membayar penuh sebelum jatuh tempo lebih disarankan?
   pilihan: Menghindari bunga berjalan dan menjaga riwayat kredit tetap bersih * | Supaya batas kredit langsung nol | Supaya denda makin besar
   penjelasan: Membayar penuh tepat waktu mencegah penumpukan bunga dan denda.
2. tanya: Mengapa memeriksa riwayat kredit secara berkala itu berguna?
   pilihan: Memastikan catatan akurat dan mendeteksi penyalahgunaan data lebih awal * | Supaya bisa menambah utang otomatis | Supaya tagihan lama hilang sendiri
   penjelasan: Pengecekan berkala lewat jalur resmi melindungi reputasi kreditmu.
3. tanya: Jika kamu punya batas kredit Rp5.000.000, sikap yang paling sehat adalah?
   pilihan: Memakai hanya sesuai kemampuan bayar di anggaranmu * | Menghabiskan seluruh batas setiap bulan | Meminjamkannya ke orang yang tidak dikenal
   penjelasan: Batas kredit bukan tambahan penghasilan; sesuaikan selalu dengan kemampuan bayarmu.

misi: tipe daftar_periksa | disclaimer: true | minimalDicentang: 3
judul: Daftar jaga reputasi kredit
instruksi: Baca catatan di atas, lalu centang kebiasaan yang kamu siapkan untuk menjaga riwayat kreditmu. Minimal tiga langkah.
langkah:
- l1 | Aku mencatat setiap jatuh tempo cicilan atau paylater di Funda agar tidak terlewat.
- l2 | Aku mengutamakan bayar penuh sebelum jatuh tempo bila memakai fasilitas kredit.
- l3 | Aku membatasi pemakaian kredit sesuai anggaran, bukan mengikuti batas maksimal.
- l4 | Aku tahu bahwa riwayat kredit bisa dicek lewat layanan resmi lembaga pengawas.
- l5 | Aku tidak membagikan data identitas atau akun kreditku ke orang lain.

tindakLanjut:
Jika ada akun paylater yang sudah tidak terpakai dan lunas, pertimbangkan menonaktifkannya agar lebih tenang.

---------------------------------------------------------------------
KUIS AKHIR MODUL 7 (jumlahSoal 5, bankSoal 10; ambang lulus 70% global; pelajaranId tiap soal)

1. [paylater_kredit_7_1] tanya: Bagaimana seharusnya kamu memandang fasilitas paylater?
   pilihan: Sebagai utang yang harus dibayar dari pemasukan mendatang * | Sebagai diskon belanja gratis | Sebagai tambahan gaji
   penjelasan: Paylater tetaplah kewajiban utang yang mengurangi ruang pemasukan berikutnya.
2. [paylater_kredit_7_1] tanya: Promo cicilan 0 persen tetap perlu dicek apanya?
   pilihan: Biaya layanan, denda keterlambatan, dan total bayar sampai lunas * | Warna aplikasinya | Jumlah ulasan bintang lima
   penjelasan: Beberapa promo tetap mengenakan biaya layanan di muka atau denda bila terlambat.
3. [paylater_kredit_7_1] tanya: Mengapa beberapa cicilan kecil sekaligus bisa berbahaya bagi arus kas?
   pilihan: Total gabungannya dapat mengikat sebagian besar pemasukan bulanan * | Karena cicilan kecil tidak bisa dilunasi | Karena saldo dompet otomatis bertambah
   penjelasan: Akumulasi cicilan kecil mempersempit ruang kebutuhan pokok dan tabungan.
4. [paylater_kredit_7_1] tanya: Harga barang Rp1.000.000, total bayar lewat paylater Rp1.095.000. Berapa biaya tambahannya?
   pilihan: Rp95.000 * | Rp100.000 | Rp1.095.000
   penjelasan: Rp1.095.000 dikurangi Rp1.000.000 menghasilkan biaya tambahan Rp95.000.
5. [paylater_kredit_7_2] tanya: Apa yang dimaksud dengan riwayat kredit?
   pilihan: Catatan pinjaman dan ketepatan pembayaran pada layanan kredit berizin * | Catatan uang saku harian | Daftar barang di keranjang belanja
   penjelasan: Riwayat kredit menjadi rekam jejak kedisiplinan pembayaranmu.
6. [paylater_kredit_7_2] tanya: Apakah keterlambatan paylater bernilai kecil tetap bisa memengaruhi reputasi kredit?
   pilihan: Ya, bila penyedianya berizin dan melaporkan catatan pembayaran * | Tidak pernah berpengaruh sama sekali | Hanya berpengaruh jika di atas Rp100.000.000
   penjelasan: Tunggakan kecil tetap bisa tercatat dan memengaruhi pengajuan kredit besar kelak.
7. [paylater_kredit_7_2] tanya: Faktor utama yang menjaga skor kredit tetap baik adalah?
   pilihan: Membayar kewajiban tepat waktu * | Sering menunda pembayaran | Mengajukan banyak pinjaman bersamaan
   penjelasan: Ketepatan waktu membayar adalah pilar utama reputasi kredit.
8. [paylater_kredit_7_3] tanya: Mengapa membayar hanya jumlah minimum pada kartu kredit kurang disarankan?
   pilihan: Sisa tagihan terus berbunga sehingga total bayar makin besar * | Karena pembayaran minimum selalu ditolak | Karena utang langsung lunas
   penjelasan: Membayar penuh sebelum jatuh tempo mencegah bunga berjalan.
9. [paylater_kredit_7_3] tanya: Di mana kamu bisa memeriksa catatan riwayat kredit secara aman?
   pilihan: Lewat layanan resmi lembaga pengawas keuangan * | Lewat tautan acak di pesan singkat | Lewat pihak tidak dikenal yang meminta OTP
   penjelasan: Gunakan selalu kanal resmi lembaga pengawas untuk mengecek data kreditmu.
10. [paylater_kredit_7_3] tanya: Sikap yang sehat terhadap batas kredit yang besar adalah?
    pilihan: Tetap memakainya sesuai anggaran dan kemampuan bayar * | Menghabiskan seluruh batasnya | Menganggapnya sebagai uang tabungan
    penjelasan: Batas kredit adalah batas pinjaman, bukan uang milikmu.
