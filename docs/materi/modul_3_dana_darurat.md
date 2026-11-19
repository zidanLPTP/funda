# Salinan Materi Lampiran Modul 3: Dana Darurat

> Sumber Kebenaran Konten: Ditulis oleh reviewer pada Prompt Tahap 8A.
> Teks di bawah adalah salinan apa adanya dari lampiran prompt untuk keperluan peninjauan pemilik proyek.

=====================================================================
LAMPIRAN  MATERI MODUL 3 (SUMBER KEBENARAN; JANGAN DIUBAH)
Tanda * menandai pilihan yang benar. Bidang gerbang ditulis secara semantik; pemetaan ke skema adalah tugas agent.
=====================================================================

MODUL: dana_darurat | tingkat: pemula | tersedia: true | urutan: 3
gerbang modul: modul_selesai tabungan DAN ada_data pengeluaran_kebutuhan min 3
pesan gerbang modul: "Selesaikan Modul 2 dulu. Lalu catat minimal 3 pengeluaran kebutuhan, misalnya makan, kos, atau transportasi, supaya hitungan dana daruratmu memakai data nyata."

---------------------------------------------------------------------
PELAJARAN dana_darurat_3_1
judul: Apa Itu Dana Darurat?
durasiMenit: 5
gerbang pelajaran: tidak ada (berlaku gerbang modul)

pemantik:
Motor mogok di tengah bulan, atau HP rusak saat kamu sedang membutuhkannya. Biayanya datang tanpa janji dan tanpa menunggu gajian.

kartu 1 | judul: Bantalan untuk hal tak terduga
{{Dana darurat}} adalah uang yang disimpan khusus untuk kejadian mendadak dan penting. Tujuannya supaya kamu tidak perlu berutang atau menjual barang saat kejadian itu datang. Ia bukan tabungan untuk liburan, gadget baru, atau diskon yang menggoda.

kartu 2 | judul: Darurat atau bukan? Tiga pertanyaan
Tanyakan tiga hal. Pertama, apakah kejadiannya mendadak? Kedua, apakah penting dan sulit ditunda, misalnya soal kesehatan, tempat tinggal, atau kuliah dan pekerjaan? Ketiga, apakah tanpa uang ini kamu terpaksa berutang atau mengorbankan kebutuhan pokok? Kalau ketiganya iya, kemungkinan itu darurat. Diskon besar terasa mendesak, tetapi bukan darurat.

kartu 3 | judul: Pisahkan dari uang harian
Dana darurat yang bercampur dengan uang harian mudah terpakai tanpa sadar. Memisahkannya memberi jeda antara dorongan membeli dan keputusan memakai. Di Funda, dana darurat punya tujuan khusus, dan hanya satu yang boleh aktif. Itu membantumu menjaganya tetap fokus.

contohAngka:
judul: Biaya mendadak Rp1.200.000 di bulan yang uangnya tipis
baris:
- Biaya perbaikan HP | 1200000
- Dana darurat yang tersedia | 3000000
- Dana darurat setelah dipakai | 1800000 | ringkasan
kesimpulan: Dengan dana darurat, biaya ini tertutup tanpa utang dan tanpa menunda kebutuhan lain. Setelah itu, dana darurat diisi lagi sedikit demi sedikit.

cekPaham:
1. tanya: Mana yang termasuk keadaan darurat?
   pilihan: Biaya rumah sakit mendadak yang tidak bisa ditunda * | Diskon besar sepatu yang hanya berlaku hari ini | Ajakan liburan dadakan dari teman
   penjelasan: Biaya rumah sakit mendadak, penting, dan sulit ditunda. Diskon dan liburan terasa mendesak, tetapi bisa dilewatkan.
2. tanya: Laptopmu rusak total seminggu sebelum ujian dan kamu belum punya penggantinya. Bagaimana tiga pertanyaan menilainya?
   pilihan: Mendadak, penting untuk kuliahmu, dan sulit ditunda, jadi kemungkinan darurat * | Bukan darurat karena laptop itu barang, bukan kesehatan | Bukan darurat karena bisa menunggu sampai gajian
   penjelasan: Kejadiannya mendadak dan penting untuk kuliahmu. Tanpa dana, kamu mungkin terpaksa berutang atau menunda hal penting.
3. tanya: Kenapa dana darurat sebaiknya dipisah dari uang harian?
   pilihan: Supaya tidak terpakai tanpa sadar untuk keperluan biasa * | Supaya bisa dipakai untuk belanja bulanan | Supaya otomatis bertambah sendiri
   penjelasan: Pemisahan memberi jeda antara dorongan membeli dan keputusan memakai.

misi: tipe lihat_hitungan
judul: Lihat pengeluaran wajibmu
instruksi: Buka ringkasan pengeluaran wajibmu, baca angkanya, lalu tekan Mengerti.
umpanBalik: pengeluaran_wajib_bulanan

tindakLanjut:
Tulis tiga kejadian mendadak yang paling mungkin menimpamu setahun ke depan, misalnya HP rusak atau biaya berobat.

---------------------------------------------------------------------
PELAJARAN dana_darurat_3_2
judul: Berapa yang Cukup untukmu?
durasiMenit: 6
aturanPraktis: true
catatanReviewer: TODO-VERIFIKASI. (1) Kisaran 3 sampai 6 kali pengeluaran wajib bulanan sebagai dana darurat: umum dijumpai di materi literasi keuangan; periksa sumber resmi (mis. materi edukasi OJK atau perencana keuangan bersertifikat), termasuk apakah kisarannya berbeda menurut status (lajang, menikah, punya tanggungan). (2) Klaim bahwa penghasilan tidak tetap atau punya tanggungan cenderung membutuhkan kisaran lebih tinggi. (3) Definisi pengeluaran wajib (kebutuhan ditambah cicilan).
gerbang pelajaran: tidak ada (berlaku gerbang modul)

pemantik:
Kalau dana darurat itu penting, pertanyaan berikutnya: seberapa banyak yang cukup? Jawabannya bergantung pada hidupmu, bukan angka yang sama untuk semua orang.

kartu 1 | judul: Mulai dari pengeluaran wajib
Dana darurat menopang hidupmu saat penghasilan terganggu. Karena itu hitung {{pengeluaran wajib}} per bulan, yaitu kebutuhan pokok ditambah cicilan. Jajan dan hiburan tidak ikut dihitung, karena bisa dihentikan sementara saat keadaan sulit.

kartu 2 | judul: Kisaran aturan praktis
Sebagai {{aturan praktis}}, banyak panduan menyebut dana darurat sekitar 3 sampai 6 kali pengeluaran wajib bulanan. Kalau penghasilanmu tidak tetap atau kamu punya tanggungan, kisarannya cenderung lebih tinggi. Ini titik awal, bukan hukum. Sesuaikan dengan kondisimu.

kartu 3 | judul: Bertahap lewat tonggak
Target penuh bisa terasa jauh. Pecah menjadi {{tonggak}}: satu bulan pengeluaran wajib dulu, lalu dua, lalu tiga. Tiap tonggak sudah memberi bantalan yang lebih baik daripada nol. Rayakan tonggak kecil, lalu lanjut ke tonggak berikutnya.

contohAngka:
judul: Contoh pengeluaran wajib Rp1.900.000 per bulan
baris:
- Kebutuhan: kos, makan, transportasi, paket data | 1700000
- Cicilan | 200000
- Pengeluaran wajib per bulan | 1900000 | ringkasan
- Titik awal, 3 kali pengeluaran wajib | 5700000
- Kisaran atas, 6 kali pengeluaran wajib | 11400000
kesimpulan: Targetmu bisa dimulai dari Rp5.700.000. Kalau terasa jauh, mulai dari tonggak pertama: satu bulan pengeluaran wajib, yaitu Rp1.900.000.

cekPaham:
1. tanya: Pengeluaran wajibmu Rp2.000.000 per bulan. Berapa titik awal dana darurat dengan kelipatan 3?
   pilihan: Rp6.000.000 * | Rp2.000.000 | Rp60.000.000
   penjelasan: Rp2.000.000 dikali 3 hasilnya Rp6.000.000.
2. tanya: Mana yang sebaiknya tidak dihitung dalam pengeluaran wajib?
   pilihan: Langganan hiburan dan jajan yang bisa dihentikan sementara * | Biaya kos | Cicilan yang sedang berjalan
   penjelasan: Pengeluaran wajib berisi hal yang tetap harus dibayar saat keadaan sulit. Hiburan dan jajan bisa dihentikan sementara.
3. tanya: Kenapa dana darurat dibuat bertahap?
   pilihan: Target penuh bisa terasa jauh, sementara tiap tonggak sudah memberi bantalan * | Karena dana darurat tidak boleh lebih dari satu bulan | Karena target boleh dilewati
   penjelasan: Tonggak kecil lebih mudah dicapai, dan setiap tonggak sudah menambah rasa aman.

misi: tipe ada_data | objek tujuan_dana_darurat | min 1
judul: Buat tujuan dana daruratmu
instruksi: Buka menu Tujuan, lalu buat tujuan berjenis Dana Darurat. Kamu boleh memulai dari tonggak pertama sebagai targetnya, dan mengubahnya nanti.
umpanBalik: target_dana_darurat

tindakLanjut:
Tentukan tonggak pertamamu: satu bulan pengeluaran wajib. Tulis angkanya di catatan HP-mu.

---------------------------------------------------------------------
PELAJARAN dana_darurat_3_3
judul: Mengisi Dana Darurat Sedikit demi Sedikit
durasiMenit: 6
gerbang pelajaran: ada_data tujuan_dana_darurat min 1
pesan gerbang: Buat tujuan Dana Darurat dulu supaya ada tempat untuk mengisinya.

pemantik:
Tujuan dana darurat sudah ada, tetapi isinya masih nol. Pertanyaannya: mulai mengisi dari mana tanpa mengganggu kebutuhan?

kartu 1 | judul: Isi dengan ritme
Isi dana darurat dengan prinsip yang sama seperti tabungan: bayar diri sendiri dulu. Sisihkan nominal kecil setiap uang masuk. Uang tambahan yang tidak rutin, seperti bonus atau hadiah, boleh sebagian masuk ke sini. Ritme yang konsisten lebih penting daripada jumlahnya.

kartu 2 | judul: Mengambil dengan aturan
Sebelum mengambil dana darurat, jalankan tiga pertanyaan darurat. Kalau lolos, ambil seperlunya dan tulis alasannya di catatan. Setelah kejadian selesai, isi lagi secara bertahap sampai ke target. Catatan alasan membantumu melihat apakah pemakaiannya benar-benar darurat.

kartu 3 | judul: Ukur dalam bulan
Selain Rupiah, ukur dana daruratmu dalam bulan. Caranya, bagi dana yang terkumpul dengan pengeluaran wajib per bulan. Hasilnya menunjukkan berapa lama kamu bisa bertahan kalau penghasilan terhenti. Dari satu bulan menjadi dua, lalu tiga, kemajuanmu terasa nyata.

contohAngka:
judul: Mengisi dana darurat Rp5.700.000 dengan Rp475.000 per bulan
baris:
- Target dana darurat | 5700000
- Setoran per bulan | 475000
- Total setoran setelah 12 bulan | 5700000
- Pengeluaran wajib per bulan | 1900000
kesimpulan: Dengan Rp475.000 per bulan, target Rp5.700.000 tercapai dalam 12 bulan. Setiap Rp1.900.000 yang terkumpul berarti satu bulan lagi kamu bisa bertahan.

cekPaham:
1. tanya: Dana darurat Rp3.800.000 dan pengeluaran wajib Rp1.900.000 per bulan. Bertahan berapa bulan?
   pilihan: 2 bulan * | 1 bulan | 4 bulan
   penjelasan: Rp3.800.000 dibagi Rp1.900.000 hasilnya 2 bulan.
2. tanya: Dana darurat terpakai untuk biaya berobat. Langkah berikutnya?
   pilihan: Mengisinya kembali sedikit demi sedikit sampai ke target * | Membiarkannya kosong | Menganggapnya sudah selesai selamanya
   penjelasan: Dana darurat perlu diisi ulang supaya siap untuk kejadian berikutnya.
3. tanya: Mana yang paling tepat dilakukan sebelum mengambil dana darurat?
   pilihan: Memeriksa tiga pertanyaan darurat: mendadak, penting dan sulit ditunda, dan tanpa uang ini kamu terpaksa berutang atau mengorbankan kebutuhan pokok * | Memeriksa apakah ada diskon | Memeriksa apakah temanmu juga membeli
   penjelasan: Tiga pertanyaan itu membantumu menilai apakah kejadiannya benar-benar darurat.

misi: tipe ada_data | objek isi_dana_darurat | min 1
judul: Isi dana daruratmu
instruksi: Buka tujuan Dana Darurat, tekan Isi, lalu pilih dompet dan jumlahnya. Nominal kecil pun boleh.
umpanBalik: progres_dana_darurat

tindakLanjut:
Pilih tanggal rutin untuk mengisi dana darurat, misalnya sehari setelah uang masuk, lalu pasang pengingat di HP-mu. Di dunia nyata, kamu juga bisa menyimpannya terpisah dari uang harian.

---------------------------------------------------------------------
KUIS AKHIR MODUL 3 (jumlahSoal 5, bankSoal 10; ambang lulus 70%; pelajaranId tiap soal)

1. [dana_darurat_3_1] tanya: Apa tujuan dana darurat?
   pilihan: Menutup kejadian mendadak dan penting tanpa harus berutang * | Membiayai liburan tahunan | Menambah uang jajan
   penjelasan: Dana darurat disiapkan untuk kejadian mendadak dan penting, bukan untuk keinginan.
2. [dana_darurat_3_1] tanya: Mana yang BUKAN bagian dari tiga pertanyaan darurat?
   pilihan: Apakah barangnya sedang diskon? * | Apakah kejadiannya mendadak? | Apakah penting dan sulit ditunda?
   penjelasan: Diskon tidak membuat sesuatu menjadi darurat. Tiga pertanyaan menilai kejadian, bukan harga.
3. [dana_darurat_3_1] tanya: Seseorang memakai dana darurat untuk tiket konser yang hampir habis. Menurut tiga pertanyaan, ini bagaimana?
   pilihan: Bukan darurat, karena bisa ditunda dan tidak menyangkut kebutuhan pokok * | Darurat, karena kesempatannya terbatas | Darurat, karena uangnya sudah tersedia
   penjelasan: Konser menyenangkan, tetapi bisa ditunda dan tidak menyangkut kebutuhan pokok.
4. [dana_darurat_3_2] tanya: Pengeluaran wajibmu Rp1.500.000 per bulan. Kisaran 3 sampai 6 kali menghasilkan berapa?
   pilihan: Rp4.500.000 sampai Rp9.000.000 * | Rp3.000.000 sampai Rp6.000.000 | Rp1.500.000 sampai Rp4.500.000
   penjelasan: Rp1.500.000 dikali 3 adalah Rp4.500.000, dan dikali 6 adalah Rp9.000.000.
5. [dana_darurat_3_2] aturanPraktis true | catatanReviewer: TODO-VERIFIKASI (lihat catatan pelajaran 3_2) | tanya: Kisaran 3 sampai 6 kali pengeluaran wajib sebaiknya diperlakukan sebagai apa?
   pilihan: Titik awal yang boleh disesuaikan dengan kondisimu * | Aturan hukum yang harus dipatuhi | Angka yang sama untuk semua orang
   penjelasan: Kisaran itu aturan praktis. Kondisi tiap orang berbeda, jadi angkanya boleh bergeser.
6. [dana_darurat_3_2] aturanPraktis true | catatanReviewer: TODO-VERIFIKASI (lihat catatan pelajaran 3_2) | tanya: Penghasilanmu tidak tetap dan kamu punya tanggungan. Kemungkinan kebutuhan dana daruratmu?
   pilihan: Cenderung lebih besar dari kisaran bawah * | Pasti nol | Selalu sama dengan orang yang bergaji tetap
   penjelasan: Penghasilan yang tidak pasti dan tanggungan biasanya membuat bantalan yang lebih besar terasa lebih aman.
7. [dana_darurat_3_2] tanya: Mana yang paling tepat sebagai tonggak pertama dana darurat?
   pilihan: Satu bulan pengeluaran wajib * | Sepuluh bulan pengeluaran wajib | Seluruh penghasilan setahun
   penjelasan: Tonggak pertama sebaiknya terjangkau. Satu bulan pengeluaran wajib sudah memberi bantalan awal.
8. [dana_darurat_3_3] tanya: Dana darurat Rp5.700.000 dan pengeluaran wajib Rp1.900.000 per bulan. Setara berapa bulan?
   pilihan: 3 bulan * | 2 bulan | 6 bulan
   penjelasan: Rp5.700.000 dibagi Rp1.900.000 hasilnya 3 bulan.
9. [dana_darurat_3_3] tanya: Kenapa menulis catatan alasan saat mengambil dana darurat itu berguna?
   pilihan: Jejaknya membantu menilai apakah pemakaiannya benar-benar darurat * | Karena aplikasi memakainya untuk menghitung bunga | Supaya saldo bertambah
   penjelasan: Catatan alasan membantumu mengevaluasi kebiasaan memakai dana darurat.
10. [dana_darurat_3_3] tanya: Cara mengisi dana darurat yang paling berkelanjutan?
   pilihan: Setoran kecil rutin setelah uang masuk * | Sekali besar lalu berhenti | Hanya saat ada sisa di akhir bulan
   penjelasan: Ritme yang konsisten lebih mudah dipertahankan daripada setoran besar yang tidak berlanjut.
