MODUL: kpr_kredit_besar | tingkat: lanjutan | tersedia: true | urutan: 14
gerbang modul: modul_selesai utang_cicilan DAN modul_selesai tujuan_besar DAN periode_data transaksi min 3 bulan_berbeda
pesan gerbang modul: "Selesaikan Modul 4 (Utang & Cicilan), Modul 12 (Tujuan Besar), dan catat transaksimu minimal di 3 bulan berbeda sebelum belajar KPR dan kredit besar."

---------------------------------------------------------------------
PELAJARAN kpr_kredit_besar_14_1
judul: Memahami Uang Muka dan Biaya Awal KPR
durasiMenit: 6
gerbang pelajaran: tidak ada (berlaku gerbang modul)
catatanReviewer: TODO-VERIFIKASI. Gambaran umum komponen uang muka (DP) dan biaya awal pembelian rumah (notaris, pajak jual beli, provisi/admin bank) tanpa menyebut tarif tetap yang bergantung lokasi dan aturan terkini.

pemantik:
Harga rumah Rp400.000.000 dan uang mukanya Rp40.000.000. Banyak orang kaget karena saat akad ternyata masih ada biaya tambahan puluhan juta di luar uang muka.

kartu 1 | judul: Uang muka bukan satu-satunya biaya awal
Saat mengambil {{KPR}} atau kredit hunian, kamu perlu menyiapkan {{uang muka}} sebagai bagian harga yang dibayar di awal. Namun di luar itu, ada biaya lain seperti biaya administrasi kredit, notaris, pajak pembelian, dan asuransi yang menyertai akad.

kartu 2 | judul: Dampak uang muka terhadap cicilan
Makin besar uang muka yang kamu siapkan, makin kecil pokok pinjaman yang harus dicicil selama bertahun-tahun. Pokok yang lebih kecil berarti cicilan bulanan lebih ringan dan total bunga jangka panjang jauh lebih rendah.

kartu 3 | judul: Jangan habiskan dana darurat untuk uang muka
Kesalahan yang sering terjadi adalah menguras seluruh tabungan dan dana darurat demi membayar uang muka. Padahal setelah pindah rumah, sering muncul biaya tak terduga seperti perbaikan, perabot dasar, dan tagihan rutin baru.

contohAngka:
judul: Ilustrasi persiapan awal pembelian rumah Rp400.000.000
baris:
- Uang muka 15 persen (ilustrasi) | 60000000
- Perkiraan biaya akad, pajak, dan notaris (ilustrasi) | 25000000
- Total dana awal yang perlu disiapkan | 85000000 | ringkasan
kesimpulan: Menyiapkan pos biaya akad sejak awal menghindarkanmu dari utang tambahan tepat sebelum pindah rumah.

cekPaham:
1. tanya: Mengapa menyiapkan uang muka saja sering belum cukup saat mengambil KPR?
   pilihan: Karena masih ada biaya akad, notaris, pajak pembelian, dan biaya pindah * | Karena uang muka selalu dikembalikan saat akad | Karena rumah langsung lunas
   penjelasan: Biaya pendukung akad jumlahnya cukup besar dan perlu masuk dalam target tabungan sejak awal.
2. tanya: Apa dampak menyiapkan uang muka yang lebih besar?
   pilihan: Pokok pinjaman lebih kecil sehingga cicilan dan total bunga lebih ringan * | Total bunga menjadi jauh lebih besar | Tenor otomatis menjadi 50 tahun
   penjelasan: Semakin kecil yang dipinjam, semakin kecil beban bunga yang ditanggung selama tenor.
3. tanya: Apakah dana darurat sebaiknya dihabiskan untuk menambah uang muka rumah?
   pilihan: Sebaiknya jangan, karena setelah pindah sering muncul biaya tak terduga * | Ya, habiskan semuanya sampai saldo nol | Dana darurat tidak dibutuhkan pemilik rumah
   penjelasan: Menjaga dana darurat tetap utuh melindungimu di bulan-bulan awal menempati rumah baru.

misi: tipe keputusan
judul: Menyiapkan dana akad rumah
instruksi: Baca skenarionya, lalu pilih keputusan yang paling aman bagi arus kasmu.
skenario pemantik: Kamu punya tabungan Rp70.000.000, termasuk Rp15.000.000 dana darurat. Ada penawaran rumah dengan uang muka dan biaya akad total Rp68.000.000.
opsi:
- a | Tunda dulu beberapa bulan sampai dana akad terkumpul tanpa menyentuh dana darurat * | aman: true | umpanBalik: Tepat. Membeli rumah dengan dana darurat tetap utuh membuat awal masa cicilanmu jauh lebih tenang.
- b | Pakai seluruh tabungan termasuk dana darurat agar bisa langsung akad besok | aman: false | umpanBalik: Saldo nol setelah akad sangat rentan jika ada perbaikan rumah atau biaya mendadak bulan depan. Coba pilihan lain.
- c | Tutup kekurangannya dengan pinjaman online berbunga tinggi | aman: false | umpanBalik: Menambah utang berbunga tinggi sebelum memulai cicilan KPR akan sangat menekan arus kasmu. Coba pilihan lain.

tindakLanjut:
Jika kamu punya tujuan uang muka rumah di Funda, pastikan targetnya sudah memperhitungkan perkiraan biaya akad dan perbaikan awal.

---------------------------------------------------------------------
PELAJARAN kpr_kredit_besar_14_2
judul: Sewa vs Beli dan Risiko Bunga Mengambang
durasiMenit: 6
gerbang pelajaran: tidak ada (berlaku gerbang modul)
catatanReviewer: TODO-VERIFIKASI. Konsep umum bunga tetap (fixed) vs bunga mengambang (floating) pada KPR dan pertimbangan sewa vs beli; edukasi umum, bukan nasihat properti.

pemantik:
Cicilan dua tahun pertama terasa ringan. Di tahun ketiga, cicilan tiba-tiba naik jutaan rupiah per bulan karena masa bunga promo berakhir.

kartu 1 | judul: Bunga tetap vs bunga mengambang
Pada banyak kredit rumah, cicilan awal memakai {{bunga tetap}} selama beberapa tahun pertama. Setelah masa itu habis, cicilan biasanya beralih ke {{bunga mengambang}} yang mengikuti suku bunga pasar, sehingga nominal cicilan bisa naik cukup signifikan.

kartu 2 | judul: Sewa bukan berarti uang terbuang
Banyak orang merasa harus buru-buru membeli rumah padahal belum siap. Padahal menyewa memberi fleksibilitas lokasi, bebas biaya perbaikan besar, dan memberi waktu bagimu untuk mengumpulkan uang muka lebih besar tanpa tekanan cicilan.

kartu 3 | judul: Pertimbangkan biaya kepemilikan
Memiliki rumah tidak hanya soal cicilan bulanan. Ada biaya perawatan berkala, pajak bumi dan bangunan, iuran lingkungan, hingga biaya transportasi jika lokasinya jauh dari tempat kerja. Masukkan semua itu dalam hitunganmu.

contohAngka:
judul: Ilustrasi kenaikan cicilan saat beralih ke bunga mengambang
baris:
- Cicilan masa bunga tetap (tahun 1 sampai 3) | 2800000
- Perkiraan cicilan saat bunga mengambang (ilustrasi) | 3800000
- Kenaikan beban per bulan | 1000000 | ringkasan
kesimpulan: Sebelum menyetujui kredit rumah, selalu tanyakan perkiraan cicilan setelah masa bunga tetap berakhir.

cekPaham:
1. tanya: Apa yang perlu diwaspadai setelah masa bunga tetap KPR berakhir?
   pilihan: Cicilan bulanan bisa naik saat beralih ke bunga mengambang * | Cicilan otomatis menjadi gratis | Rumah langsung lunas otomatis
   penjelasan: Bunga mengambang mengikuti pasar sehingga nominal cicilan dapat meningkat dari masa promo awal.
2. tanya: Mengapa menyewa rumah sementara bisa menjadi pilihan yang masuk akal?
   pilihan: Memberi fleksibilitas dan waktu mengumpulkan uang muka tanpa memaksakan cicilan * | Karena membeli rumah selalu dilarang | Karena sewa tidak butuh anggaran
   penjelasan: Menyewa memberi ruang untuk mempersiapkan keuangan hingga benar-benar siap membeli.
3. tanya: Biaya apa saja yang tetap muncul setelah memiliki rumah sendiri selain cicilan?
   pilihan: Biaya perawatan, pajak tahunan properti, dan iuran lingkungan * | Tidak ada biaya apa pun lagi | Hanya biaya internet saja
   penjelasan: Biaya kepemilikan rutin perlu diperhitungkan agar anggaran bulanan tidak kaget.

misi: tipe keputusan
judul: Menguji kesiapan saat cicilan naik
instruksi: Pilih sikap yang paling bijak saat menerima tawaran KPR.
skenario pemantik: Penjual menawarkan KPR dengan cicilan promo Rp2.500.000 selama 2 tahun pertama. Namun setelah masuk bunga mengambang, perkiraan cicilannya bisa naik menjadi Rp3.700.000, yang hampir memakan separuh gajimu.
opsi:
- a | Hitung ulang dengan harga rumah lebih terjangkau atau perbesar uang muka dulu * | aman: true | umpanBalik: Tepat. Mengukur kemampuan bayar dari skenario cicilan normal jauh lebih aman daripada hanya melihat cicilan promo.
- b | Ambil saja dulu, urusan tahun ketiga dipikirkan nanti | aman: false | umpanBalik: Kenaikan cicilan Rp1.200.000 per bulan bisa langsung mengganggu kebutuhan pokok jika tidak disiapkan. Coba pilihan lain.
- c | Abaikan perkiraan bunga mengambang karena belum tentu naik | aman: false | umpanBalik: Mengabaikan risiko bunga mengambang adalah salah satu penyebab tersering kredit rumah terasa berat di tengah jalan. Coba pilihan lain.

tindakLanjut:
Jika sedang mencari hunian, bandingkan total biaya sewa tahunan dengan total cicilan plus biaya perawatan kepemilikan.

---------------------------------------------------------------------
PELAJARAN kpr_kredit_besar_14_3
judul: Uji Kemampuan Bayar dari Arus Kas Nyata
durasiMenit: 6
aturanPraktis: true
catatanReviewer: TODO-VERIFIKASI. Penggunaan patokan umum 30 persen rasio cicilan terhadap pemasukan sebagai simulasi awal kemampuan bayar KPR; periksa kesesuaiannya dengan aturan perbankan terkini.
gerbang pelajaran: tidak ada (berlaku gerbang modul)

pemantik:
Bank mungkin menyetujui pinjamanmu, tetapi hanya kamu yang tahu apakah sisa uang setelah cicilan masih cukup untuk hidup dengan tenang.

kartu 1 | judul: Uji dengan data 3 bulan terakhirmu
Kredit besar mengikat arus kasmu selama 10 hingga 20 tahun. Karena itu, ujilah kemampuan bayarmu memakai data pemasukan dan pengeluaran nyatamu di Funda, bukan sekadar angan-angan.

kartu 2 | judul: Sisakan ruang untuk hidup dan menabung
Sebagai {{aturan praktis}}, banyak panduan memakai patokan total seluruh cicilan maksimal sekitar 30 persen dari pemasukan bulanan. Jika kamu masih punya cicilan lain, ruang untuk cicilan baru tentu berkurang.

kartu 3 | judul: Coba simulasi hidup dengan cicilan
Cara paling jujur menguji kesiapan KPR adalah simulasi selama 3 sampai 6 bulan: sisihkan selisih antara biaya kos/sewa sekarang dan calon cicilan KPR ke kantong khusus. Kalau kamu tetap nyaman menjalani bulan-bulan itu, tanda kesiapanmu makin kuat.

contohAngka:
judul: Uji ruang cicilan dari pemasukan Rp10.000.000 per bulan
baris:
- Patokan 30 persen untuk total semua cicilan | 3000000
- Cicilan aktif yang sudah berjalan | -1000000
- Sisa ruang untuk cicilan baru | 2000000 | ringkasan
kesimpulan: Melunasi cicilan lama lebih dulu langsung memperbesar ruang amanmu untuk kredit besar.

cekPaham:
1. tanya: Mengapa menguji kemampuan bayar dari catatan arus kas nyata lebih akurat daripada tebakan?
   pilihan: Karena mencerminkan kebutuhan hidup dan cicilan aktualmu setiap bulan * | Karena catatan selalu membuat cicilan lebih murah | Karena bank tidak pernah menghitung
   penjelasan: Data nyata menunjukkan berapa ruang tersisa yang benar-benar nyaman untukmu.
2. tanya: Bagaimana cara praktis menguji kesiapan sebelum resmi mengambil KPR?
   pilihan: Menyisihkan selisih calon cicilan ke tabungan khusus selama beberapa bulan * | Langsung menandatangani akad tanpa menghitung | Menghentikan seluruh tabungan
   penjelasan: Simulasi menabung selisih cicilan membuktikan secara nyata apakah arus kasmu sanggup menahannya.
3. tanya: Pemasukan Rp10.000.000, patokan cicilan 30 persen (Rp3.000.000), dan cicilan aktif saat ini Rp1.000.000. Berapa sisa ruang cicilannya?
   pilihan: Rp2.000.000 * | Rp3.000.000 | Rp4.000.000
   penjelasan: Rp3.000.000 dikurangi cicilan aktif Rp1.000.000 menyisakan ruang Rp2.000.000.

misi: tipe lihat_hitungan
judul: Uji ruang cicilanmu dari data nyata
instruksi: Buka hasil simulasi ruang cicilan berdasarkan data pemasukan dan cicilan aktifmu saat ini, baca isinya, lalu tekan Mengerti.
umpanBalik: uji_kemampuan_kpr

tindakLanjut:
Jika berencana mengambil kredit besar dalam beberapa tahun ke depan, prioritaskan melunasi cicilan konsumtif kecil lebih dulu.

---------------------------------------------------------------------
KUIS AKHIR MODUL 14 (jumlahSoal 5, bankSoal 10; ambang lulus 70% global; pelajaranId tiap soal)

1. [kpr_kredit_besar_14_1] tanya: Selain uang muka, biaya apa saja yang perlu disiapkan saat akad KPR?
   pilihan: Biaya administrasi, notaris, pajak pembelian, dan asuransi akad * | Hanya harga cat tembok | Tidak ada biaya lain sama sekali
   penjelasan: Biaya pendukung akad perlu dihitung sejak awal agar tabungan tidak kurang mendadak.
2. [kpr_kredit_besar_14_1] tanya: Apa manfaat menyiapkan uang muka yang lebih besar saat mengambil KPR?
   pilihan: Pokok pinjaman lebih kecil sehingga cicilan dan total bunga lebih ringan * | Cicilan menjadi lebih mahal | Biaya akad otomatis hilang
   penjelasan: Uang muka besar mengurangi jumlah uang yang harus kamu pinjam.
3. [kpr_kredit_besar_14_1] tanya: Mengapa dana darurat sebaiknya tidak dihabiskan untuk uang muka rumah?
   pilihan: Untuk berjaga-jaga menghadapi biaya tak terduga setelah pindah rumah * | Karena dana darurat tidak bisa dipakai beli rumah | Karena cicilan baru mulai 5 tahun lagi
   penjelasan: Tetap punya dana darurat menjaga kestabilan keuangan di masa awal kepemilikan rumah.
4. [kpr_kredit_besar_14_1] tanya: Harga rumah Rp400.000.000 dengan uang muka 15 persen. Berapa uang mukanya?
   pilihan: Rp60.000.000 * | Rp40.000.000 | Rp15.000.000
   penjelasan: 15 persen dari Rp400.000.000 adalah Rp60.000.000.
5. [kpr_kredit_besar_14_2] tanya: Apa perbedaan bunga tetap dan bunga mengambang pada KPR?
   pilihan: Bunga tetap cicilannya sama selama periode tertentu, bunga mengambang mengikuti pasar * | Keduanya selalu nol persen | Bunga mengambang selalu lebih murah selamanya
   penjelasan: Saat masuk masa bunga mengambang, cicilan bulanan dapat berubah mengikuti suku bunga pasar.
6. [kpr_kredit_besar_14_2] tanya: Kapan menyewa rumah bisa menjadi pilihan yang lebih bijak daripada memaksakan membeli?
   pilihan: Saat dana awal belum cukup atau lokasi kerja masih sering berpindah * | Tidak pernah bijak dalam kondisi apa pun | Saat ingin menghindari mencatat keuangan
   penjelasan: Menyewa memberi fleksibilitas dan waktu untuk mematangkan kesiapan finansial.
7. [kpr_kredit_besar_14_2] tanya: Biaya rutin apa yang perlu diperhitungkan pemilik rumah di luar cicilan KPR?
   pilihan: Perawatan rumah, pajak properti tahunan, dan iuran lingkungan * | Tidak ada biaya tambahan apa pun | Hanya biaya membeli perabot sekali saja
   penjelasan: Kepemilikan properti membawa biaya perawatan berkala yang masuk ke anggaran.
8. [kpr_kredit_besar_14_3] tanya: Mengapa cicilan aktif yang sudah berjalan mengurangi ruang untuk mengambil KPR baru?
   pilihan: Karena seluruh cicilan diambil dari pemasukan bulanan yang sama * | Karena cicilan lama otomatis lunas saat ambil KPR | Karena bank melarang punya tabungan
   penjelasan: Semakin banyak cicilan berjalan, semakin sempit ruang aman di arus kasmu.
9. [kpr_kredit_besar_14_3] tanya: Bagaimana cara paling nyata menguji apakah kamu sanggup membayar calon cicilan KPR?
   pilihan: Rutin menyisihkan selisih calon cicilan ke kantong khusus selama beberapa bulan * | Hanya membayangkannya tanpa mencoba | Mengosongkan pos makan harian
   penjelasan: Simulasi menabung selisih cicilan menguji ketahanan arus kas secara langsung.
10. [kpr_kredit_besar_14_3] tanya: Apa peran simulasi ruang cicilan di Funda?
    pilihan: Gambaran edukatif awal dari datamu sendiri, bukan persetujuan kredit bank * | Jaminan pengajuan KPR pasti disetujui | Tempat mengajukan pinjaman rumah
    penjelasan: Funda membantu kamu mengukur kesiapan sendiri sebelum mengambil keputusan di dunia nyata.
