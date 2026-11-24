LAMPIRAN  MATERI MODUL 17, MODUL 18, DAN KAMUS (SUMBER KEBENARAN; JANGAN DIUBAH)
Tanda * menandai pilihan yang benar. Bidang gerbang ditulis secara semantik; pemetaan ke skema adalah tugas agent.
=====================================================================

MODUL: keuangan_usaha_kecil | tingkat: lanjutan | tersedia: true | urutan: 17
gerbang modul: ada_data sumber_pemasukan min 2 ATAU pernyataan belum_punya_usaha
pesan gerbang modul: "Catat pemasukan dari minimal 2 kategori berbeda dulu. Kalau kamu belum punya usaha saat ini, pilih Aku tidak punya ini."

---------------------------------------------------------------------
PELAJARAN keuangan_usaha_kecil_17_1
judul: Memisahkan Uang Pribadi dan Uang Usaha
durasiMenit: 5
gerbang pelajaran: tidak ada (berlaku gerbang modul)

pemantik:
Jualanmu ramai setiap hari, tetapi di akhir bulan uang untuk beli bahan baku habis. Penyebab paling sering: uang usaha bercampur dengan uang jajan pribadi.

kartu 1 | judul: Dua dompet, dua tujuan
Aturan nomor satu dalam {{keuangan usaha}} adalah memisahkan tempat simpan uang pribadi dan uang usaha. Meski usahamu masih berskala kecil dari kamar kos atau rumah, pemisahan ini membuatmu tahu apakah usahamu benar-benar untung atau hanya ramai di luar.

kartu 2 | judul: Gaji dirimu sendiri secara teratur
Jangan mengambil uang dari kas usaha setiap kali ingin jajan. Tetapkan nominal gaji pribadi yang wajar untuk dirimu setiap bulan atau minggu, lalu pindahkan dari dompet usaha ke dompet pribadi. Di Funda, kamu bisa memakai fitur transfer antar dompet.

kartu 3 | judul: Lindungi modal dari pengeluaran harian
Ketika uang pribadi dan usaha tercampur, modal usaha mudah tergerus tanpa terasa. Memisahkannya sejak awal membuatmu lebih tenang saat mengambil keputusan menambah stok atau mengembangkan usaha.

contohAngka:
judul: Memisahkan kas usaha dan kas pribadi dalam sebulan
baris:
- Penjualan kotor usaha | 6000000
- Biaya bahan baku dan operasional | -3800000
- Sisa laba usaha | 2200000 | ringkasan
- Gaji pemilik yang ditransfer ke dompet pribadi | -1500000
- Laba ditahan untuk modal usaha | 700000 | ringkasan
kesimpulan: Dengan memisahkan kas, kamu bisa menikmati Rp1.500.000 dengan tenang sambil membesarkan modal usaha Rp700.000.

cekPaham:
1. tanya: Apa risiko utama jika uang usaha dicampur dengan uang pribadi?
   pilihan: Sulit mengetahui untung rugi sebenarnya dan modal mudah terpakai tanpa sadar * | Penjualan otomatis meningkat dua kali lipat | Biaya bahan baku menjadi gratis
   penjelasan: Pemisahan kas menjaga kejelasan laba dan melindungi kelangsungan modal.
2. tanya: Cara paling rapi bagi pemilik usaha kecil mengambil uang untuk kebutuhan pribadi adalah?
   pilihan: Menetapkan jatah gaji pemilik secara teratur dari kas usaha ke kas pribadi * | Mengambil uang laci kapan saja tanpa dicatat | Menghabiskan seluruh hasil penjualan hari itu
   penjelasan: Memberi diri sendiri gaji tetap menjaga kas usaha tetap terkendali.
3. tanya: Penjualan Rp6.000.000 dan biaya bahan baku Rp3.800.000. Berapa laba usahanya?
   pilihan: Rp2.200.000 * | Rp6.000.000 | Rp3.800.000
   penjelasan: Penjualan dikurangi biaya operasional menghasilkan laba Rp2.200.000.

misi: tipe keputusan
judul: Menjaga batas kas usaha
instruksi: Baca skenarionya, lalu pilih langkah yang paling sehat untuk usahamu.
skenario pemantik: Hari ini usahamu mendapat pembayaran pesanan Rp1.500.000. Besok kamu harus membeli bahan baku Rp1.000.000, tetapi malam ini teman mengajak makan di tempat mahal.
opsi:
- a | Pakai uang kas usaha dulu karena besok masih bisa cari pinjaman untuk bahan baku | aman: false | umpanBalik: Mengambil uang modal kerja untuk keinginan pribadi bisa mengganggu pesanan besok. Coba pilihan lain.
- b | Biarkan Rp1.500.000 tetap di dompet usaha, dan pakai anggaran jajan dari dompet pribadimu * | aman: true | umpanBalik: Tepat. Menjaga batas kas usaha memastikan operasional besok berjalan lancar tanpa utang.
- c | Jangan catat penjualan hari ini agar bisa dipakai langsung | aman: false | umpanBalik: Tidak mencatat transaksi membuat laporan laba rugi usahamu meleset. Coba pilihan lain.

tindakLanjut:
Jika kamu punya usaha sampingan, buat satu dompet khusus bernama "Kas Usaha" di Funda agar terpisah dari dompet harianmu.

---------------------------------------------------------------------
PELAJARAN keuangan_usaha_kecil_17_2
judul: Membaca Arus Kas Usaha dan Laba
durasiMenit: 6
gerbang pelajaran: tidak ada (berlaku gerbang modul)

pemantik:
Di catatan penjualan tertulis untung Rp5.000.000, tetapi saldo di rekening usaha kosong karena pelanggan belum membayar. Di sinilah bedanya laba dan arus kas.

kartu 1 | judul: Omzet bukan berarti untung
{{Omzet}} adalah total uang yang masuk dari penjualan sebelum dikurangi biaya apa pun. Sedangkan {{laba bersih}} adalah sisa uang setelah seluruh biaya bahan baku, ongkos kirim, kemasan, dan biaya operasional lainnya dibayar.

kartu 2 | judul: Arus kas menjaga napas usaha
Usaha bisa terlihat untung di atas kertas tetapi tetap macet jika uang tunai tidak cukup saat harus membayar pemasok. Karena itu, pantau jadwal uang masuk dari pelanggan dan jadwal uang keluar untuk biaya rutin.

kartu 3 | judul: Catat biaya kecil operasional
Biaya plastik kemasan, lakban, kuota internet, hingga listrik tempat usaha sering terlupa dicatat. Padahal bila digabung sebulan, biaya kecil ini sangat memengaruhi harga jual dan keuntungan sebenarnya.

contohAngka:
judul: Beda omzet dan laba bersih pada usaha camilan rumahan
baris:
- Omzet penjualan sebulan | 5000000
- Bahan baku dan kemasan | -3000000
- Listrik, gas, dan promosi | -500000
- Laba bersih sebenarnya | 1500000 | ringkasan
kesimpulan: Omzet Rp5.000.000 menghasilkan laba bersih Rp1.500.000. Harga jual yang sehat harus menutup seluruh biaya tersebut.

cekPaham:
1. tanya: Apa perbedaan antara omzet dan laba bersih?
   pilihan: Omzet adalah total penjualan kotor, sedangkan laba bersih adalah sisa setelah dikurangi semua biaya * | Keduanya selalu bernilai sama persis | Omzet adalah uang yang tersisa di akhir tahun
   penjelasan: Omzet besar belum tentu untung besar jika biayanya juga sangat tinggi.
2. tanya: Mengapa usaha yang untung di catatan tetap bisa kehabisan uang tunai?
   pilihan: Karena uang dari pelanggan belum cair sementara biaya pemasok harus dibayar sekarang * | Karena omzet tidak perlu dicatat | Karena biaya kemasan selalu nol
   penjelasan: Keseimbangan waktu antara uang masuk dan keluar (arus kas) menentukan kelancaran operasional harian.
3. tanya: Mengapa biaya kecil seperti kemasan dan ongkos kirim tetap harus dicatat?
   pilihan: Agar perhitungan laba bersih dan penentuan harga jual akurat * | Supaya pelanggan bingung | Supaya pajak menjadi nol
   penjelasan: Biaya tersembunyi yang tidak dicatat bisa membuatmu tanpa sadar menjual di bawah modal.

misi: tipe lihat_hitungan
judul: Tinjau kesiapan dompet dan arus kasmu
instruksi: Buka ringkasan jumlah dompet aktif dan arus kasmu bulan ini, baca gambarannya, lalu tekan Mengerti.
umpanBalik: ringkasan_usaha_kecil

tindakLanjut:
Hitung ulang satu produk atau jasa yang kamu tawarkan: apakah seluruh biaya kecil seperti kemasan dan kuota sudah masuk ke dalam modalnya?

---------------------------------------------------------------------
PELAJARAN keuangan_usaha_kecil_17_3
judul: Menjaga Modal Kerja dan Dana Cadangan Usaha
durasiMenit: 6
gerbang pelajaran: tidak ada (berlaku gerbang modul)

pemantik:
Ada pesanan besar mendadak dari pelanggan baru, tetapi kamu tidak punya cukup uang tunai untuk membeli bahan bakunya.

kartu 1 | judul: Apa itu modal kerja?
{{Modal kerja}} adalah dana yang terus berputar untuk menjalankan operasional harian usaha, seperti membeli stok barang, bahan baku, dan membayar biaya rutin sebelum uang penjualan kembali masuk.

kartu 2 | judul: Sisihkan dana cadangan usaha
Sama seperti keuangan pribadi butuh dana darurat, usaha kecil juga butuh cadangan kas. Cadangan ini melindungi usahamu saat penjualan sedang lesu, ada alat kerja rusak, atau harga bahan baku naik mendadak.

kartu 3 | judul: Tumbuh pelan tapi sehat
Menyisihkan sebagian laba bersih kembali ke kas usaha membuat usahamu tumbuh tanpa harus langsung bergantung pada pinjaman berbunga tinggi. Catat setiap perkembangan modalmu dengan jujur.

contohAngka:
judul: Membagi laba bersih usaha Rp2.000.000 per bulan
baris:
- Laba bersih bulan ini | 2000000
- Ditransfer sebagai gaji pemilik | 1200000
- Ditahan untuk menambah modal kerja | 500000
- Disisihkan untuk cadangan alat dan masa sepi | 300000
kesimpulan: Membagi laba dengan porsi yang jelas membuat pemilik tetap terbayar sementara usaha makin kuat tiap bulan.

cekPaham:
1. tanya: Apa fungsi utama modal kerja dalam usaha kecil?
   pilihan: Membiayai perputaran operasional harian seperti bahan baku dan stok * | Membeli barang konsumtif pribadi pemilik | Membayar liburan keluarga
   penjelasan: Modal kerja memastikan usahamu selalu siap menerima dan menyelesaikan pesanan.
2. tanya: Mengapa usaha kecil juga membutuhkan dana cadangan terpisah?
   pilihan: Menghadapi masa penjualan sepi, kenaikan harga bahan, atau kerusakan alat kerja * | Supaya tidak perlu melayani pelanggan | Supaya seluruh laba langsung habis
   penjelasan: Cadangan kas mencegah usaha berhenti mendadak saat menghadapi gangguan operasional.
3. tanya: Bagaimana cara paling sehat memperbesar modal usaha kecil?
   pilihan: Menyisihkan sebagian laba bersih secara rutin kembali ke kas usaha * | Mengambil pinjaman ilegal berbunga tinggi | Mencampurnya dengan uang makan harian
   penjelasan: Pertumbuhan dari laba ditahan menjaga usaha tetap ringan tanpa tekanan cicilan berat.

misi: tipe refleksi | minimalKarakter: 10
judul: Aturan emas kas usahamu
instruksi: Tulis satu aturan sederhana yang ingin kamu terapkan untuk menjaga uang usaha (atau persiapan jika nanti memulai usaha). Catatan ini privat di HP-mu.
pertanyaan: Bagaimana caramu memisahkan kas usaha dan menentukan porsi laba yang ditahan untuk modal kerja?
petunjukInput: Contoh: Aku akan pakai rekening terpisah untuk kas usaha dan menyisihkan 30 persen laba untuk modal kerja.

tindakLanjut:
Jika kamu sudah berjualan, tinjau catatan omzet dan biaya operasionalmu setiap akhir minggu agar selalu terkendali.

---------------------------------------------------------------------
KUIS AKHIR MODUL 17 (jumlahSoal 5, bankSoal 10; ambang lulus 70% global; pelajaranId tiap soal)

1. [keuangan_usaha_kecil_17_1] tanya: Apa langkah paling mendasar dalam mengelola keuangan usaha kecil?
   pilihan: Memisahkan tempat simpan dan catatan uang pribadi dengan uang usaha * | Mencampur semua uang di satu dompet | Tidak mencatat pengeluaran bahan baku
   penjelasan: Pemisahan kas adalah fondasi agar untung rugi usaha terlihat jelas.
2. [keuangan_usaha_kecil_17_1] tanya: Mengapa pemilik usaha kecil sebaiknya menetapkan gaji rutin untuk dirinya sendiri?
   pilihan: Agar pengambilan uang pribadi terkendali dan tidak menggerus modal usaha * | Agar usaha tidak pernah punya laba | Agar tidak perlu membayar pemasok
   penjelasan: Gaji pemilik yang teratur menjaga batas tegas antara kas pribadi dan kas usaha.
3. [keuangan_usaha_kecil_17_1] tanya: Penjualan Rp4.000.000, biaya bahan dan operasional Rp2.500.000. Berapa laba usahanya?
   pilihan: Rp1.500.000 * | Rp4.000.000 | Rp2.500.000
   penjelasan: Penjualan dikurangi biaya menghasilkan laba Rp1.500.000.
4. [keuangan_usaha_kecil_17_1] tanya: Fitur apa di Funda yang memudahkan pemisahan kas pribadi dan kas usaha?
   pilihan: Membuat dompet terpisah dan mencatat transfer antar dompet * | Menghapus semua transaksi keluar | Menggunakan Mode Sandbox saja
   penjelasan: Banyak dompet di Funda membantu memantau saldo pribadi dan usaha secara terpisah.
5. [keuangan_usaha_kecil_17_2] tanya: Apa arti omzet dalam usaha?
   pilihan: Total nilai penjualan kotor sebelum dikurangi biaya operasional * | Sisa uang bersih setelah semua biaya dibayar | Total utang kepada pemasok
   penjelasan: Omzet menunjukkan volume penjualan, belum mencerminkan keuntungan bersih.
6. [keuangan_usaha_kecil_17_2] tanya: Mengapa biaya kecil seperti kemasan dan ongkos kirim tetap wajib dicatat?
   pilihan: Karena akumulasinya memengaruhi laba bersih dan ketepatan harga jual * | Karena tidak memengaruhi apa pun | Karena selalu ditanggung pembeli secara otomatis
   penjelasan: Pencatatan biaya yang lengkap mencegah kerugian tersembunyi.
7. [keuangan_usaha_kecil_17_2] tanya: Apa risiko jika arus kas usaha tidak seimbang waktunya?
   pilihan: Usaha bisa kesulitan membayar pemasok meski di catatan terlihat untung * | Laba bersih otomatis naik dua kali lipat | Modal kerja tidak dibutuhkan lagi
   penjelasan: Arus kas tunai menjaga napas operasional usaha sehari-hari.
8. [keuangan_usaha_kecil_17_3] tanya: Apa yang dimaksud dengan modal kerja?
   pilihan: Dana yang berputar untuk membiayai operasional harian usaha seperti bahan baku * | Uang saku harian pemilik | Biaya hiburan akhir pekan
   penjelasan: Modal kerja membuat aktivitas produksi dan penjualan berjalan lancar.
9. [keuangan_usaha_kecil_17_3] tanya: Untuk apa usaha kecil menyiapkan dana cadangan?
   pilihan: Menopang usaha saat penjualan sepi atau ada kerusakan alat mendadak * | Menghabiskan sisa laba secepatnya | Membayar denda keterlambatan pribadi
   penjelasan: Dana cadangan menjaga ketahanan usaha menghadapi situasi tak terduga.
10. [keuangan_usaha_kecil_17_3] tanya: Cara paling sehat membesarkan modal usaha kecil secara bertahap adalah?
    pilihan: Menyisihkan sebagian laba bersih kembali ke kas usaha * | Mengambil pinjaman ilegal | Menghentikan pencatatan keuangan
    penjelasan: Laba ditahan memperkuat modal tanpa membebani usaha dengan cicilan berbunga tinggi.

---------------------------------------------------------------------
