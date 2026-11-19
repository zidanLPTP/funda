# Salinan Materi Lampiran Modul 2: Tabungan

> Sumber Kebenaran Konten: Ditulis oleh reviewer pada Prompt Tahap 8A.
> Teks di bawah adalah salinan apa adanya dari lampiran prompt untuk keperluan peninjauan pemilik proyek.

=====================================================================
LAMPIRAN  MATERI MODUL 2 (SUMBER KEBENARAN; JANGAN DIUBAH)
Tanda * menandai pilihan yang benar. Bidang gerbang ditulis secara semantik; pemetaan ke skema adalah tugas agent.
=====================================================================

MODUL: tabungan | tingkat: pemula | tersedia: true | urutan: 2
gerbang modul: modul_selesai anggaran_arus_kas DAN ada_data anggaran min 1
pesan gerbang modul: "Selesaikan Modul 1 dulu. Lalu buat minimal satu anggaran, supaya tabungan punya tempat di rencana uangmu."

---------------------------------------------------------------------
PELAJARAN tabungan_2_1
judul: Menabung Itu Soal Tujuan
durasiMenit: 5
gerbang pelajaran: tidak ada (berlaku gerbang modul)

pemantik:
Kamu sering bilang, "Nanti mau nabung." Tapi uangnya selalu habis lebih dulu. Mungkin masalahnya bukan niat, tetapi tujuannya belum jelas.

kartu 1 | judul: Uang tanpa nama gampang terpakai
Uang yang tidak punya tujuan terasa bebas dipakai kapan saja. Karena itu, menabung tanpa tujuan sering berhenti di tengah jalan. Uang yang punya nama dan alasan lebih mudah dijaga. Setiap kali ingin memakainya, kamu ingat untuk apa ia disimpan.

kartu 2 | judul: Tiga bagian tujuan yang jelas
Tujuan tabungan yang jelas punya tiga bagian. Pertama, nama, misalnya laptop untuk skripsi. Kedua, target, misalnya Rp6.000.000. Ketiga, {{tenggat}}, misalnya 12 bulan lagi. Dari target dan tenggat, kamu bisa menghitung berapa yang perlu disisihkan tiap bulan. Tanpa tenggat, tujuan mudah terus tertunda.

kartu 3 | judul: Mulai dari satu tujuan
Mulailah dari satu tujuan yang paling terasa penting. Terlalu banyak tujuan membuat uangmu terpecah, dan semuanya terasa jauh. Kalau targetnya besar, pecah menjadi tahap yang lebih kecil. Setiap tahap yang tercapai memberi alasan untuk lanjut.

contohAngka:
judul: Dari target ke setoran bulanan
baris:
- Target laptop untuk skripsi | 6000000
- Sudah terkumpul | 0
- Disisihkan per bulan kalau tenggatnya 12 bulan | 500000
- Disisihkan per bulan kalau tenggatnya 18 bulan | 333334
kesimpulan: Target Rp6.000.000 dalam 12 bulan berarti sekitar Rp500.000 per bulan. Kalau terasa berat, tenggat bisa diperpanjang menjadi 18 bulan, dengan setoran sekitar Rp333.334 per bulan (dibulatkan ke atas).

cekPaham:
1. tanya: Kenapa tabungan yang punya tujuan lebih mudah bertahan?
   pilihan: Uangnya punya nama dan alasan, jadi lebih sulit terpakai tanpa sadar * | Karena tabungan dengan tujuan selalu berbunga lebih tinggi | Karena uangnya otomatis tidak bisa diambil
   penjelasan: Uang yang punya nama dan alasan lebih jarang terpakai tanpa sadar. Bunga dan akses tidak ada hubungannya dengan tujuan.
2. tanya: Mana tujuan tabungan yang paling jelas?
   pilihan: Laptop untuk skripsi, Rp6.000.000, dalam 12 bulan * | Ingin punya tabungan yang banyak | Menabung kalau ada sisa
   penjelasan: Tujuan yang jelas punya nama, target, dan tenggat. Dari ketiganya, setoran bulanan bisa dihitung.
3. tanya: Tujuan Rp3.000.000 dalam 10 bulan. Berapa yang disisihkan per bulan?
   pilihan: Rp300.000 * | Rp30.000 | Rp3.000.000
   penjelasan: Rp3.000.000 dibagi 10 bulan hasilnya Rp300.000 per bulan.

misi: tipe ada_data | objek tujuan_tabungan | min 1
judul: Buat tujuan tabunganmu
instruksi: Buka menu Tujuan, lalu buat satu tujuan tabungan. Isi nama, target, dan tenggat bila kamu sudah tahu.
umpanBalik: ringkasan_tujuan_tabungan

tindakLanjut:
Untuk dipikirkan, tidak perlu dijawab di aplikasi: kalau tujuan ini tercapai, apa yang berubah untukmu?

---------------------------------------------------------------------
PELAJARAN tabungan_2_2
judul: Bayar Diri Sendiri Dulu
durasiMenit: 5
gerbang pelajaran: ada_data tujuan_tabungan min 1
pesan gerbang: Buat satu tujuan tabungan dulu supaya ada tempat untuk menyisihkan uangmu.
catatanReviewer: Kartu 1 memuat klaim perilaku umum ("pengeluaran cenderung mengisi ruang uang yang tersedia") dan prinsip "bayar diri sendiri dulu". Verifikasi sumber atau lunakkan bila perlu.

pemantik:
Uang saku atau gaji masuk. Lalu tagihan dan jajan mengambil bagiannya satu per satu. Di akhir bulan, tidak ada yang tersisa untuk ditabung.

kartu 1 | judul: Tabungan di depan, bukan dari sisa
Banyak orang menabung dari sisa di akhir bulan. Masalahnya, sisa itu sering tidak ada, karena pengeluaran cenderung mengisi ruang uang yang tersedia. Cara lain disebut bayar diri sendiri dulu. Begitu uang masuk, sisihkan bagian tabungan. Baru sisanya dipakai.

kartu 2 | judul: Kecil tapi rutin
Mulailah dari nominal yang hampir tidak terasa, misalnya Rp50.000 setiap uang masuk. Nominal kecil yang konsisten lebih kuat daripada nominal besar yang berhenti di bulan kedua. Setelah terbiasa, naikkan sedikit demi sedikit sesuai kemampuanmu.

kartu 3 | judul: Di Funda, isi kantong tujuanmu
Di Funda, kamu mengisi tujuan dari sebuah dompet. {{Kantong}} tujuan hanya menandai bagian saldo, jadi saldo dompet tidak berubah. Yang berkurang adalah {{saldo bebas}}, yaitu uang yang belum punya nama. Kalau mau lebih aman, kamu juga bisa memindahkannya sungguhan ke tempat simpan yang terpisah.

contohAngka:
judul: Dua cara menabung dari uang bulanan Rp2.500.000
baris:
- Uang masuk bulan ini | 2500000
- Cara 1, dari sisa: tabungan di akhir bulan | 0
- Cara 2, di depan: disisihkan saat uang masuk | 200000
- Cara 2: tersisa untuk pengeluaran lain | 2300000 | ringkasan
kesimpulan: Dalam 6 bulan, cara kedua mengumpulkan Rp1.200.000. Pada contoh ini, cara pertama tidak mengumpulkan apa-apa. Bukan karena niatnya kurang, tetapi karena tidak ada bagian yang disisihkan lebih dulu.

cekPaham:
1. tanya: Apa arti "bayar diri sendiri dulu"?
   pilihan: Menyisihkan bagian tabungan segera setelah uang masuk, sebelum dipakai untuk hal lain * | Membeli sesuatu untuk diri sendiri lebih dulu | Membayar semua keinginan sebelum kebutuhan
   penjelasan: Tabungan disisihkan di depan, bukan menunggu sisa di akhir bulan.
2. tanya: Kamu mengisi kantong tujuan dari sebuah dompet di Funda. Apa yang terjadi pada saldo dompet itu?
   pilihan: Saldo dompet tidak berubah, Funda hanya menandai bagiannya * | Saldo dompet berkurang sebesar isinya | Uang pindah ke rekening bank lain
   penjelasan: Kantong hanya menandai. Uangmu tidak berpindah, dan yang berkurang adalah saldo bebasnya.
3. tanya: Mana langkah awal yang paling masuk akal?
   pilihan: Mulai dari nominal kecil yang bisa dijalankan rutin * | Menunggu sampai ada sisa yang besar | Menabung sebesar mungkin lalu berhenti bulan depan
   penjelasan: Nominal kecil yang konsisten lebih mudah dipertahankan. Setelah terbiasa, kamu bisa menaikkannya.

misi: tipe ada_data | objek isi_tujuan_tabungan | min 1
judul: Isi tujuan tabunganmu
instruksi: Buka tujuan tabunganmu, tekan Isi, lalu pilih dompet dan jumlahnya. Nominal kecil pun boleh.
umpanBalik: ringkasan_tujuan_tabungan

tindakLanjut:
Pilih satu waktu tetap untuk mengisi tujuanmu, misalnya setiap gajian atau awal bulan. Lalu pasang pengingat di HP-mu.

---------------------------------------------------------------------
PELAJARAN tabungan_2_3
judul: Menghitung Kecepatan Menabung
durasiMenit: 6
gerbang pelajaran: ada_data isi_tujuan_tabungan min 1
pesan gerbang: Isi tujuan tabunganmu minimal sekali dulu, supaya hitungannya memakai data nyatamu.

pemantik:
Targetnya sudah ada, dan setoran pertama sudah masuk. Pertanyaan berikutnya: kapan tercapai?

kartu 1 | judul: Tiga angka yang menentukan
Kecepatan menabung ditentukan tiga angka: sisa target, {{setoran}} per bulan, dan waktu. Sisa target adalah target dikurangi dana yang sudah terkumpul. Waktu kira-kira sisa target dibagi setoran per bulan, lalu dibulatkan ke atas. Dengan tiga angka ini, kapan tercapai berubah dari tebakan menjadi hitungan.

kartu 2 | judul: Tambahan kecil, hasil yang terasa
Setoran yang naik sedikit bisa mempercepat target. Misalnya, tambahan Rp50.000 per bulan kadang memangkas beberapa bulan. Tapi jangan menambah dengan mengorbankan kebutuhan pokok. Setoran yang bisa kamu jalankan terus lebih berguna daripada setoran besar yang berhenti.

kartu 3 | judul: Menyesuaikan, bukan menyerah
Kalau hitungannya terasa terlalu lama, kamu punya tiga tuas: naikkan setoran, perpanjang tenggat, atau turunkan target. Pilih yang paling masuk akal untuk kondisimu. Cek lagi tiap bulan, karena penghasilan dan pengeluaranmu bisa berubah, dan hitungannya ikut berubah.

contohAngka:
judul: Target Rp3.000.000, belum ada yang terkumpul
baris:
- Sisa yang perlu dikumpulkan | 3000000
- Setoran per bulan sekarang | 250000
- Setoran per bulan kalau ditambah Rp50.000 | 300000
kesimpulan: Dengan Rp250.000 per bulan, target tercapai dalam 12 bulan. Dengan Rp300.000, dalam 10 bulan. Tambahan Rp50.000 mempercepat 2 bulan.

cekPaham:
1. tanya: Sisa target Rp4.000.000 dan setoran Rp400.000 per bulan. Berapa bulan sampai tercapai?
   pilihan: 10 bulan * | 8 bulan | 12 bulan
   penjelasan: Rp4.000.000 dibagi Rp400.000 hasilnya 10 bulan.
2. tanya: Setoran naik dari Rp400.000 menjadi Rp450.000 untuk sisa Rp4.000.000. Apa yang terjadi?
   pilihan: Waktunya menjadi 9 bulan (dibulatkan ke atas), lebih cepat 1 bulan * | Waktunya tetap 10 bulan | Waktunya menjadi 8 bulan
   penjelasan: Rp4.000.000 dibagi Rp450.000 sekitar 8,9. Dibulatkan ke atas menjadi 9 bulan.
3. tanya: Hitungan menunjukkan targetmu butuh 3 tahun, padahal kamu ingin 1 tahun. Pilihan yang masuk akal?
   pilihan: Pertimbangkan menaikkan setoran, memperpanjang tenggat, atau menurunkan target * | Berhenti menabung | Mengurangi kebutuhan pokok sampai nol
   penjelasan: Ketiga tuas itu bisa disesuaikan dengan kondisimu. Mengorbankan kebutuhan pokok bukan jalan yang sehat.

misi: tipe lihat_hitungan
judul: Baca hitungan kecepatan menabungmu
instruksi: Buka hitungan kecepatan menabung, baca isinya, lalu tekan Mengerti.
umpanBalik: estimasi_tabungan

tindakLanjut:
Awal bulan depan, buka lagi hitungan ini. Kalau setoranmu berubah, hasilnya ikut berubah.

---------------------------------------------------------------------
KUIS AKHIR MODUL 2 (jumlahSoal 5, bankSoal 10; ambang lulus 70%; pelajaranId tiap soal)

1. [tabungan_2_1] tanya: Kombinasi mana yang membuat tujuan tabungan jelas?
   pilihan: Nama tujuan, jumlah target, dan tenggat * | Hanya jumlah target | Hanya niat untuk menabung
   penjelasan: Ketiga bagian itu membuat tujuan jelas dan bisa dihitung setoran bulanannya.
2. [tabungan_2_1] tanya: Tujuan Rp1.200.000 dalam 6 bulan. Berapa yang disisihkan per bulan?
   pilihan: Rp200.000 * | Rp120.000 | Rp600.000
   penjelasan: Rp1.200.000 dibagi 6 bulan hasilnya Rp200.000.
3. [tabungan_2_1] tanya: Kamu punya beberapa keinginan besar sekaligus. Langkah awal yang disarankan?
   pilihan: Mulai dari satu tujuan dulu * | Mulai dari semuanya sekaligus | Menunda sampai punya banyak uang
   penjelasan: Satu tujuan yang jelas lebih mudah dijalankan daripada banyak tujuan yang terasa jauh.
4. [tabungan_2_2] tanya: Kapan bagian tabungan sebaiknya disisihkan?
   pilihan: Segera setelah uang masuk * | Di akhir bulan dari sisa | Hanya kalau ada uang berlebih
   penjelasan: Menyisihkan di depan membuat tabungan tidak bergantung pada sisa yang sering tidak ada.
5. [tabungan_2_2] tanya: Saldo dompetmu Rp1.000.000. Di Funda, kamu mengisi tujuan tabungan Rp200.000 dari dompet itu. Bagaimana kondisinya?
   pilihan: Saldo dompet tetap Rp1.000.000 dan saldo bebasnya Rp800.000 * | Saldo dompet menjadi Rp800.000 | Saldo dompet menjadi Rp1.200.000
   penjelasan: Kantong hanya menandai. Saldo dompet tidak berubah, dan saldo bebasnya berkurang Rp200.000.
6. [tabungan_2_2] tanya: Kenapa nominal kecil tapi rutin cocok untuk memulai?
   pilihan: Lebih mudah dijalankan terus-menerus * | Karena tabungan kecil tidak butuh tujuan | Karena nominal kecil pasti berbunga
   penjelasan: Kebiasaan yang bisa dijalankan terus lebih berharga daripada nominal besar yang cepat berhenti.
7. [tabungan_2_3] tanya: Sisa target Rp2.500.000 dan setoran Rp500.000 per bulan. Berapa bulan?
   pilihan: 5 bulan * | 4 bulan | 6 bulan
   penjelasan: Rp2.500.000 dibagi Rp500.000 hasilnya 5 bulan.
8. [tabungan_2_3] tanya: Sisa Rp1.000.000 dan setoran Rp300.000 per bulan. Berapa bulan (dibulatkan ke atas)?
   pilihan: 4 bulan * | 3 bulan | 5 bulan
   penjelasan: Rp1.000.000 dibagi Rp300.000 sekitar 3,3. Dibulatkan ke atas menjadi 4 bulan.
9. [tabungan_2_3] tanya: Mana yang termasuk cara menyesuaikan rencana tabungan?
   pilihan: Menaikkan setoran, memperpanjang tenggat, atau menurunkan target * | Berhenti mencatat | Menghapus tujuannya
   penjelasan: Ketiga tuas itu menyesuaikan rencana tanpa meninggalkannya.
10. [tabungan_2_3] tanya: Kenapa hitungan kecepatan menabung perlu dicek ulang tiap bulan?
   pilihan: Karena setoran dan kondisimu bisa berubah * | Karena angkanya selalu keliru | Karena target naik sendiri tiap bulan
   penjelasan: Hitungan memakai data terbaru. Kalau datamu berubah, hasilnya ikut berubah.
