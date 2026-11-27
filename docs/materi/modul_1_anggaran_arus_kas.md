# Salinan Materi Lampiran Modul 1: Anggaran & Arus Kas

> Sumber Kebenaran Konten: Ditulis oleh reviewer pada Prompt Tahap 6.
> Teks di bawah adalah salinan apa adanya dari lampiran prompt untuk keperluan peninjauan pemilik proyek.

=====================================================================
LAMPIRAN  MATERI MODUL 1 (SUMBER KEBENARAN; JANGAN DIUBAH)
Tanda * menandai pilihan yang benar. Bidang gerbang ditulis secara semantik; pemetaan ke skema adalah tugas agent.
=====================================================================

MODUL: anggaran_arus_kas | tingkat: pemula | tersedia: true

---------------------------------------------------------------------
PELAJARAN anggaran_arus_kas_1_1
judul: Ke Mana Uangku Pergi?
durasiMenit: 4
gerbang pelajaran: tidak ada (berlaku gerbang modul)

pemantik:
Uang saku atau gaji baru masuk. Seminggu kemudian dompet sudah tipis, dan kamu bingung ke mana perginya.

kartu 1 | judul: Uang tidak hilang, hanya tidak terlihat
Uang tidak lenyap begitu saja. Ia berpindah ke tempat yang jarang kita perhatikan, seperti jajan, ongkos, top up, dan langganan. Satu per satu terasa ringan. Setelah sebulan, jumlahnya bisa mengejutkan. Itu hal yang umum terjadi, dan bukan tanda kamu tidak mampu mengatur uang.

kartu 2 | judul: Melihat dulu, berhemat belakangan
Kita sulit mengatur sesuatu yang tidak terlihat. Karena itu langkah pertama bukan berhemat, tetapi melihat. Catat setiap uang yang keluar, sekecil apa pun. Tidak perlu rapi atau sempurna. Catatan yang agak berantakan tetap jauh lebih berguna daripada tidak ada catatan sama sekali.

kartu 3 | judul: Dua pertanyaan untuk memulai
Di Funda, kita mulai dari dua pertanyaan. Berapa uang yang masuk? Berapa uang yang keluar? Selisih keduanya disebut {{arus kas}}. Di pelajaran berikutnya kita memetakannya. Hari ini cukup satu langkah kecil: catat satu pengeluaran terakhirmu. Kamu pasti masih ingat belinya apa dan di mana.

contohAngka:
judul: Pengeluaran kecil yang menumpuk (uang bulanan Rp2.000.000)
baris:
- Kopi, 20 hari x Rp18.000 | 360000
- Ojek online, 20 hari x Rp12.000 | 240000
- Cemilan, 20 hari x Rp10.000 | 200000
- Top up game dan langganan | 85000
- Jumlah pengeluaran kecil | 885000 | ringkasan
kesimpulan: Pengeluaran yang terasa kecil itu menjadi Rp885.000 dalam sebulan, sekitar 44 persen dari uang bulanan Rp2.000.000.

cekPaham:
1. tanya: Kenapa langkah pertama mengatur uang adalah mencatat?
   pilihan: Supaya uang terlihat dan bisa dipahami * | Supaya kamu malu saat jajan | Supaya semua pengeluaran dihentikan
   penjelasan: Mencatat membuat aliran uang terlihat. Dari situ kamu bisa memutuskan dengan sadar, tanpa perlu menahan diri berlebihan.
2. tanya: Pengeluaran kecil yang berulang sebaiknya bagaimana?
   pilihan: Tetap dicatat karena jumlahnya bisa menumpuk * | Diabaikan karena nominalnya kecil | Dicatat hanya kalau di atas Rp100.000
   penjelasan: Rp18.000 terasa kecil, tetapi dua puluh kali dalam sebulan menjadi Rp360.000.
3. tanya: Apa yang dimaksud dengan arus kas?
   pilihan: Selisih antara uang yang masuk dan uang yang keluar * | Jumlah tabungan di bank | Daftar barang yang ingin dibeli
   penjelasan: Arus kas adalah uang masuk dikurangi uang keluar dalam satu periode, misalnya sebulan.

misi: tipe ada_data | objek pengeluaran | min 1
judul: Catat satu pengeluaranmu
instruksi: Buka Catatan, lalu catat satu pengeluaran terakhirmu. Yang paling kecil pun boleh.
umpanBalik: catatan_pengeluaran_terbaru

tindakLanjut:
Untuk dipikirkan, tidak perlu dijawab di aplikasi: pengeluaran kecil apa yang paling sering muncul dalam seminggu terakhirmu?

---------------------------------------------------------------------
PELAJARAN anggaran_arus_kas_1_2
judul: Memetakan Arus Kas
durasiMenit: 5
gerbang pelajaran: ada_data dompet min 1
pesan gerbang: Buat satu dompet dulu agar uangmu punya tempat dicatat.

pemantik:
Temanmu bertanya, "Uangmu bulan ini cukup?" Kamu menjawab, "Kayaknya cukup." Tapi "kayaknya" belum jawaban yang bisa kamu pegang.

kartu 1 | judul: Arus kas: uang masuk dikurangi uang keluar
{{Arus kas}} itu sederhana. Uang yang masuk dikurangi uang yang keluar dalam satu periode, misalnya sebulan. Di aplikasi, uang masuk disebut {{pemasukan}} dan uang keluar disebut {{pengeluaran}}. Kalau hasilnya plus, uangmu bertambah. Kalau minus, uangmu berkurang. Keduanya wajar dan bisa diubah. Yang penting kamu tahu posisinya.

kartu 2 | judul: Petakan dari mana dan ke mana
Peta arus kas punya dua sisi. Sisi masuk berisi gaji, uang saku, kiriman keluarga, atau hasil freelance. Sisi keluar kita bagi dua. {{Pengeluaran tetap}} jumlahnya hampir sama tiap bulan, seperti kos dan paket internet. {{Pengeluaran berubah-ubah}} naik turun, seperti makan, jajan, dan transportasi. Pisahkan keduanya. Yang tetap mudah direncanakan. Yang berubah-ubah adalah ruang untuk menyesuaikan.

kartu 3 | judul: Membaca hasilnya dengan tenang
Setelah dipetakan, lihat satu angka: selisihnya. Kalau uang masuk lebih besar, kamu punya ruang untuk menabung atau menyiapkan {{dana darurat}}. Kalau uang keluar lebih besar, uangmu terkuras tiap bulan. Dari angka itu, cari dulu bagian mana yang paling besar. Satu perubahan kecil di bagian itu sering lebih terasa daripada mengubah semuanya.

contohAngka:
judul: Contoh arus kas satu bulan
baris:
- Uang saku dan gaji paruh waktu | 2500000
- Kos | -900000
- Paket data dan pulsa | -100000
- Makan | -800000
- Transportasi | -300000
- Jajan dan hiburan | -350000
- Arus kas bulan ini | 50000 | ringkasan
kesimpulan: Uang masuk lebih besar Rp50.000 dari uang keluar. Posisinya tipis, jadi menarik untuk melihat bagian mana yang bisa disesuaikan.

cekPaham:
1. tanya: Pemasukan Rp3.000.000 dan pengeluaran Rp3.200.000. Bagaimana arus kasnya?
   pilihan: Minus Rp200.000, uang keluar lebih besar * | Plus Rp200.000 | Nol, karena keduanya hampir sama
   penjelasan: Rp3.000.000 dikurangi Rp3.200.000 hasilnya minus Rp200.000. Artinya uang keluar lebih besar dari uang masuk.
2. tanya: Mana yang termasuk pengeluaran tetap?
   pilihan: Biaya kos bulanan * | Jajan sore | Parkir sesekali
   penjelasan: Kos jumlahnya hampir sama tiap bulan. Jajan dan parkir naik turun.
3. tanya: Arus kasmu bulan ini minus. Langkah yang masuk akal?
   pilihan: Cari bagian pengeluaran terbesar dan lihat mana yang bisa disesuaikan * | Berhenti mencatat supaya tidak stres | Menunggu bulan depan tanpa melihat apa pun
   penjelasan: Angka minus adalah informasi. Dengan melihat bagian terbesar, kamu tahu di mana perubahan kecil paling terasa.

misi: tipe ada_data | objek arus_kas | min 1 (minimal 1 pemasukan DAN 1 pengeluaran)
judul: Petakan uang masuk dan keluar
instruksi: Di Catatan, catat minimal satu pemasukan dan satu pengeluaran bulan ini.
umpanBalik: arus_kas_bulan_ini

tindakLanjut:
Setiap kali uang saku atau gaji masuk, langsung catat. Dua menit di awal membuat hari-hari berikutnya lebih tenang.

---------------------------------------------------------------------
PELAJARAN anggaran_arus_kas_1_3
judul: Kebutuhan vs Keinginan
durasiMenit: 6
gerbang pelajaran: ada_data pengeluaran min 3
pesan gerbang: Catat minimal 3 pengeluaran dulu, supaya ada contoh nyata yang bisa kita labeli bersama.

pemantik:
Kamu membeli kopi. Itu kebutuhan atau keinginan? Jawabannya bisa dua-duanya, tergantung keadaanmu.

kartu 1 | judul: Dua kelompok, satu tujuan
{{Kebutuhan}} adalah hal yang perlu ada agar hidup dan kewajibanmu berjalan. Contohnya tempat tinggal, makan harian, transportasi ke kampus atau kerja, listrik, dan kesehatan. {{Keinginan}} adalah hal yang membuat hidup lebih nyaman atau menyenangkan, tetapi bisa ditunda atau dikurangi. Contohnya nongkrong, hiburan, dan langganan tontonan. Keduanya wajar ada, dan membedakannya membantumu memilih pengeluaran dengan sadar.

kartu 2 | judul: Wilayah abu-abu itu wajar
Banyak pengeluaran berada di tengah. Makan itu kebutuhan. Makan di tempat mahal tiap hari lebih dekat ke keinginan. Paket data itu kebutuhan. Paket data jumbo untuk streaming lebih dekat ke keinginan. Ada pertanyaan bantu: kalau uangku sedang tipis, apakah ini yang pertama kukurangi? Kalau iya, kemungkinan itu keinginan. Kamu yang menentukan label sesuai kondisimu.

kartu 3 | judul: Empat label di Funda
Di Funda, pengeluaran diberi label: kebutuhan, keinginan, tabungan dan dana darurat, atau utang. Tidak ada komposisi yang cocok untuk semua orang. Cukup pahami gambarannya, lalu sesuaikan dengan tujuanmu.

contohAngka:
judul: Pengeluaran sebulan Rp2.450.000 menurut label
baris:
- Kebutuhan: kos | 900000
- Kebutuhan: paket data | 100000
- Kebutuhan: makan harian | 600000
- Kebutuhan: transportasi | 300000
- Jumlah kebutuhan | 1900000 | ringkasan
- Keinginan: makan di luar dan nongkrong | 200000
- Keinginan: jajan dan hiburan | 350000
- Jumlah keinginan | 550000 | ringkasan
kesimpulan: Komposisinya 78 persen kebutuhan dan 22 persen keinginan. Ini gambaran, bukan nilai.

cekPaham:
1. tanya: Pengeluaran mana yang paling dekat dengan kebutuhan?
   pilihan: Biaya kos bulanan * | Tiket konser | Langganan film tiap bulan
   penjelasan: Tempat tinggal perlu ada agar hidup berjalan. Konser dan film menyenangkan, tetapi bisa ditunda.
2. tanya: Kopi di kafe tiap pagi sebaiknya dilabeli apa?
   pilihan: Tergantung kondisi dan alasanmu, bisa kebutuhan bisa keinginan * | Selalu kebutuhan | Selalu keinginan
   penjelasan: Satu pengeluaran bisa punya arti berbeda untuk orang berbeda. Pilih label yang paling jujur untuk keadaanmu.
3. tanya: Untuk apa pengeluaran diberi label kebutuhan atau keinginan?
   pilihan: Untuk melihat gambaran pengeluaran dan memilih dengan sadar * | Untuk menilai pantas atau tidaknya kamu jajan | Untuk mencari pengeluaran yang dilarang
   penjelasan: Label membantumu melihat pola pengeluaran, lalu menyesuaikannya dengan tujuanmu.

misi: tipe aturan_data | aturan semua_kategori_berlabel
judul: Labeli kategori pengeluaranmu
instruksi: Buka Kelola Kategori, lalu beri label pada setiap kategori pengeluaran yang pernah kamu pakai.
umpanBalik: komposisi_sifat_bulan_ini

tindakLanjut:
Minggu ini, pilih satu pengeluaran yang labelnya kamu ragukan. Tanyakan pada dirimu: kalau uangku tipis, ini yang pertama kukurangi atau bukan?

---------------------------------------------------------------------
PELAJARAN anggaran_arus_kas_1_4
judul: Anggaran Pertamamu
durasiMenit: 7
aturanPraktis: true
catatanReviewer: TODO-VERIFIKASI. (1) Sumber pola 50/30/20: dikenal dari buku "All Your Worth" oleh Elizabeth Warren dan Amelia Warren Tyagi (2005); periksa rumusannya (kebutuhan 50%, keinginan 30%, tabungan dan pelunasan utang 20% dari penghasilan setelah pajak). (2) Klaim pengalaman: anggaran yang terlalu ketat sering gugur dalam beberapa minggu.
gerbang pelajaran: periode_data transaksi tercatat di minimal 7 hari berbeda DAN ada_data pemasukan min 1
pesan gerbang: Anggaran yang bagus dimulai dari data nyata. Catat transaksimu di 7 hari yang berbeda, dan sudah ada minimal satu pemasukan bulan ini, lalu pelajaran ini terbuka.

pemantik:
Dengan catatan seminggu ke belakang, kamu punya bahan nyata. Saatnya memberi uangmu arah sebelum ia pergi.

kartu 1 | judul: Anggaran itu rencana, bukan penjara
{{Anggaran}} adalah rencana tentang berapa uang yang kamu izinkan keluar untuk tiap kategori dalam sebulan. Satu batas untuk satu kategori disebut {{pos anggaran}}. Fungsinya memberi arah, bukan melarang. Anggaran yang bagus itu realistis. Anggaran yang terlalu ketat sering gugur dalam beberapa minggu. Mulailah dari kenyataanmu, lalu tetapkan batas yang masuk akal.

kartu 2 | judul: Tiga langkah menyusunnya
Satu, mulai dari pemasukan bulan ini. Itu batas atas uang yang bisa kamu atur. Dua, tulis dulu pengeluaran yang pasti ada, seperti kos, makan, transportasi, dan cicilan. Tiga, sisihkan tabunganmu di awal, bukan dari sisa. Sisanya baru dibagi untuk keinginan. Urutan ini membuat hal yang penting terpenuhi lebih dulu.

kartu 3 | judul: Dua cara memulai
Cara pertama adalah pola populer 50/30/20, yang termasuk {{aturan praktis}}. Idenya, sekitar 50 persen pemasukan untuk kebutuhan, 30 persen untuk keinginan, dan 20 persen untuk tabungan dan pelunasan utang. Ini titik awal, bukan hukum. Kalau biaya kosmu besar, angkanya wajar bergeser. Cara kedua adalah anggaran buatanmu sendiri dari data nyata. Setelah misi ini, kamu akan melihat keduanya berdampingan memakai uangmu.

contohAngka:
judul: Dua susunan untuk pemasukan Rp2.500.000
baris:
- Pola 50/30/20: kebutuhan | 1250000
- Pola 50/30/20: keinginan | 750000
- Pola 50/30/20: tabungan dan utang | 500000
- Buatan sendiri: kebutuhan | 1500000
- Buatan sendiri: keinginan | 600000
- Buatan sendiri: tabungan dan utang | 400000
kesimpulan: Keduanya sah. Susunan kedua menyesuaikan biaya kos yang lebih besar.

cekPaham:
1. tanya: Apa fungsi utama anggaran?
   pilihan: Memberi arah pada uang sebelum dipakai * | Melarang semua jajan | Membuktikan bahwa kamu hemat
   penjelasan: Anggaran adalah rencana. Ia membantumu memilih lebih dulu, bukan menyesali belakangan.
2. tanya: Urutan menyusun anggaran yang disarankan?
   pilihan: Pemasukan, lalu pengeluaran pasti, lalu tabungan, lalu keinginan * | Keinginan dulu, lalu sisanya untuk kebutuhan | Tabungan hanya dari sisa di akhir bulan
   penjelasan: Dengan urutan ini, hal yang penting terpenuhi lebih dulu dan tabungan tidak bergantung pada sisa.
3. tanya: Pola 50/30/20 sebaiknya diperlakukan sebagai apa?
   pilihan: Titik awal yang boleh disesuaikan * | Aturan yang berlaku sama untuk semua orang | Satu-satunya cara menabung
   penjelasan: Pola ini aturan praktis. Kondisi tiap orang berbeda, jadi angkanya boleh bergeser.

misi: tipe ada_data | objek anggaran | min 3
judul: Buat anggaran pertamamu
instruksi: Di menu Anggaran, buat anggaran bulan ini untuk minimal tiga kategori.
umpanBalik: perbandingan_pola_anggaran

tindakLanjut:
Anggaran pertamamu tidak perlu sempurna. Cukup dijalankan sebulan, lalu kita evaluasi di pelajaran berikutnya.

---------------------------------------------------------------------
PELAJARAN anggaran_arus_kas_1_5
judul: Evaluasi Akhir Bulan
durasiMenit: 6
gerbang pelajaran: ada_data anggaran min 1 DAN ada_data pengeluaran min 1
pesan gerbang: Buat minimal satu anggaran dan catat pengeluaranmu dulu, supaya ada yang bisa dievaluasi.

pemantik:
Akhir bulan adalah waktu untuk membaca data pengeluaran dan belajar darinya.

kartu 1 | judul: Bandingkan rencana dan kenyataan
Evaluasi akhir bulan membandingkan dua hal: yang kamu rencanakan dan yang benar-benar terjadi. Angka kenyataannya disebut {{realisasi anggaran}}. Kalau realisasi mendekati rencana, bagus. Kalau berbeda jauh, itu informasi. Mungkin rencananya terlalu ketat, atau ada pengeluaran yang belum terpikir. Keduanya bisa diperbaiki.

kartu 2 | judul: Tiga pertanyaan evaluasi
Pertama, pos mana yang paling dekat atau melewati batas? Kedua, apa penyebabnya: kebutuhan yang memang naik, atau keinginan yang tidak terasa? Ketiga, apa yang ingin kamu ubah bulan depan: batasnya, kebiasaannya, atau dua-duanya? Pilih satu perubahan kecil saja. Perubahan kecil yang konsisten lebih mudah dijalankan daripada rencana besar yang ditinggalkan.

kartu 3 | judul: Anggaran adalah draf yang terus diperbarui
Anggaran pertama jarang langsung pas. Itu wajar. Tiap bulan kamu mengumpulkan data baru, dan anggaranmu makin sesuai dengan hidupmu. Di Funda kamu bisa menyalin anggaran bulan lalu, lalu mengubah bagian yang perlu. Setelah beberapa bulan, kamu akan mengenali pola uangmu sendiri.

contohAngka:
judul: Evaluasi tiga pos anggaran (sisa dari rencana)
baris:
- Makan harian: rencana Rp800.000, kenyataan Rp560.000 (70 persen) | 240000
- Transportasi: rencana Rp300.000, kenyataan Rp255.000 (85 persen) | 45000
- Jajan dan nongkrong: rencana Rp300.000, kenyataan Rp345.000 (115 persen) | -45000
- Jumlah sisa dari rencana | 240000 | ringkasan
kesimpulan: Satu pos masih longgar, satu mendekati batas, dan satu melewati batas Rp45.000. Dari sini kamu bisa memutuskan: ubah batasnya atau kebiasaannya.

cekPaham:
1. tanya: Apa yang dimaksud realisasi anggaran?
   pilihan: Jumlah yang benar-benar terpakai pada sebuah pos * | Jumlah yang kamu harapkan terpakai | Jumlah tabungan akhir bulan
   penjelasan: Realisasi adalah kenyataannya. Rencana adalah batasnya. Keduanya dibandingkan saat evaluasi.
2. tanya: Pos jajan melewati batas bulan ini. Sikap yang masuk akal?
   pilihan: Cari penyebabnya, lalu putuskan mengubah batas atau kebiasaannya * | Menyerah dan berhenti memakai anggaran | Menghapus catatan supaya terlihat rapi
   penjelasan: Melewati batas adalah informasi. Dengan mengetahui penyebabnya, kamu bisa memperbaiki rencana atau kebiasaan.
3. tanya: Kenapa anggaran perlu diperbarui tiap bulan?
   pilihan: Kondisi dan kebiasaan berubah, dan data baru membuatnya lebih pas * | Supaya angkanya terlihat berbeda | Supaya batas selalu dinaikkan
   penjelasan: Anggaran yang diperbarui mengikuti hidupmu. Karena itu ia makin berguna dari bulan ke bulan.

misi: tipe lihat_hitungan
judul: Baca ringkasan realisasi bulan ini
instruksi: Buka ringkasan realisasi anggaran bulan ini, baca isinya, lalu tekan Mengerti.
umpanBalik: realisasi_anggaran_bulan_ini

tindakLanjut:
Pilih satu perubahan kecil untuk bulan depan dan tulis di catatan HP-mu. Misalnya, turunkan sedikit batas jajan, atau naikkan batas makan agar lebih realistis.

---------------------------------------------------------------------
KUIS AKHIR MODUL (jumlahSoal 5, bankSoal 10; ambang lulus 70%; pelajaranId tiap soal)

1. [pelajaranId anggaran_arus_kas_1_1] tanya: Kenapa uang sering terasa hilang di akhir bulan?
   pilihan: Pengeluaran kecil yang berulang tidak terlihat sampai dijumlahkan * | Uang memang selalu berkurang dengan sendirinya | Karena uang di awal bulan selalu kurang
   penjelasan: Pengeluaran kecil terasa ringan satu per satu. Saat dijumlahkan, nilainya bisa besar.
2. [pelajaranId anggaran_arus_kas_1_1] tanya: Langkah pertama yang disarankan untuk mengatur uang?
   pilihan: Melihat dulu ke mana uang pergi lewat pencatatan * | Berhenti membeli hal yang kamu sukai | Membuka rekening baru
   penjelasan: Kita sulit mengatur yang tidak terlihat. Mencatat membuat uangmu terlihat.
3. [pelajaranId anggaran_arus_kas_1_2] tanya: Pemasukan Rp4.000.000 dan pengeluaran Rp3.500.000. Bagaimana arus kasnya?
   pilihan: Plus Rp500.000 * | Minus Rp500.000 | Nol
   penjelasan: Rp4.000.000 dikurangi Rp3.500.000 hasilnya plus Rp500.000.
4. [pelajaranId anggaran_arus_kas_1_2] tanya: Cicilan HP dengan jumlah sama tiap bulan termasuk apa?
   pilihan: Pengeluaran tetap * | Pengeluaran berubah-ubah | Pemasukan
   penjelasan: Jumlahnya hampir sama tiap bulan, jadi ia pengeluaran tetap.
5. [pelajaranId anggaran_arus_kas_1_3] tanya: Tiket nonton bioskop paling dekat dengan apa?
   pilihan: Keinginan * | Kebutuhan | Pemasukan
   penjelasan: Nonton menyenangkan, tetapi bisa ditunda atau dikurangi, jadi lebih dekat ke keinginan.
6. [pelajaranId anggaran_arus_kas_1_3] tanya: Sebuah kategori membuatmu ragu soal labelnya. Apa yang masuk akal?
   pilihan: Pilih sesuai kondisimu dan boleh diubah nanti * | Biarkan tanpa label selamanya | Hapus kategorinya
   penjelasan: Label membantumu melihat pola. Kamu boleh mengubahnya saat keadaanmu berubah.
7. [pelajaranId anggaran_arus_kas_1_4] aturanPraktis true | tanya: Dari pemasukan Rp3.000.000, pola 50/30/20 memberi bagian kebutuhan sebesar berapa?
   pilihan: Rp1.500.000 * | Rp900.000 | Rp600.000
   penjelasan: Lima puluh persen dari Rp3.000.000 adalah Rp1.500.000. Pola ini aturan praktis, jadi boleh disesuaikan.
8. [pelajaranId anggaran_arus_kas_1_4] tanya: Urutan menyusun anggaran yang disarankan?
   pilihan: Pemasukan, pengeluaran pasti, tabungan, lalu keinginan * | Keinginan, tabungan, lalu kebutuhan | Tabungan dari sisa di akhir bulan
   penjelasan: Hal yang penting dipenuhi lebih dulu, dan tabungan disisihkan di awal.
9. [pelajaranId anggaran_arus_kas_1_5] tanya: Batas sebuah pos Rp300.000 dan realisasinya Rp345.000. Apa artinya?
   pilihan: Pos itu melewati rencana sebesar Rp45.000 * | Pos itu hemat Rp45.000 | Pos itu tepat sesuai rencana
   penjelasan: Rp345.000 dikurangi Rp300.000 hasilnya Rp45.000 di atas rencana.
10. [pelajaranId anggaran_arus_kas_1_5] tanya: Apa tujuan evaluasi akhir bulan?
   pilihan: Belajar dari data untuk memperbaiki anggaran bulan depan * | Mencari kekurangan dirimu | Menghapus anggaran yang tidak berhasil
   penjelasan: Evaluasi adalah proses belajar. Datanya dipakai untuk memperbaiki rencana, bukan menilai dirimu.

---------------------------------------------------------------------
KAMUS (tambahkan; sesuaikan nama bidang dengan kamus.json yang ada: istilah, arti, contohRupiah)

- pemasukan | Uang yang masuk ke tanganmu, seperti gaji, uang saku, atau hasil freelance. | Gaji Rp3.000.000 dan uang lembur Rp500.000 berarti pemasukan Rp3.500.000.
- pengeluaran | Uang yang keluar dari tanganmu untuk membeli atau membayar sesuatu. | Makan Rp25.000 dan ojek Rp12.000 berarti pengeluaran Rp37.000.
- pengeluaran tetap | Pengeluaran yang jumlahnya hampir sama tiap bulan. | Kos Rp900.000 dan paket internet Rp100.000 tiap bulan.
- pengeluaran berubah-ubah | Pengeluaran yang jumlahnya naik turun dari bulan ke bulan. | Jajan bisa Rp300.000 bulan ini dan Rp450.000 bulan depan.
- kebutuhan | Pengeluaran yang perlu ada agar hidup dan kewajibanmu berjalan. | Kos, makan harian, dan transportasi ke kampus.
- keinginan | Pengeluaran yang membuat hidup lebih nyaman, tetapi bisa ditunda atau dikurangi. | Tiket konser atau langganan film.
- pos anggaran | Satu batas pengeluaran untuk satu kategori dalam sebulan. | Pos Makan Harian dengan batas Rp800.000.
- realisasi anggaran | Jumlah yang benar-benar terpakai pada sebuah pos anggaran. | Batas jajan Rp300.000 dan terpakai Rp345.000 berarti realisasinya Rp345.000.
- aturan praktis | Pedoman sederhana untuk memulai, yang boleh disesuaikan dengan kondisimu. | Pola 50/30/20 membagi pemasukan menjadi kebutuhan, keinginan, dan tabungan.
(Istilah arus kas, anggaran, dan dana darurat sudah ada di kamus; jangan diduplikasi.)
