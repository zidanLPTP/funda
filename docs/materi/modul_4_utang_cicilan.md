# MODUL 4: UTANG & CICILAN

MODUL: utang_cicilan | tingkat: pemula | tersedia: true | urutan: 4
gerbang modul: modul_selesai dana_darurat DAN (ada_data utang min 1 ATAU pernyataan tidak_punya_utang)
pesan gerbang modul: "Selesaikan Modul 3 dulu. Lalu catat utang atau cicilanmu di menu Utang. Kalau kamu memang tidak punya utang, pilih Aku tidak punya ini."

---------------------------------------------------------------------
PELAJARAN utang_cicilan_4_1
judul: Utang yang Membantu dan yang Menjerat
durasiMenit: 5
gerbang pelajaran: tidak ada (berlaku gerbang modul)

pemantik:
Cicilan pertama terasa ringan. Beberapa bulan kemudian, cicilan lain ikut menumpuk, dan akhir bulan terasa makin sempit.

kartu 1 | judul: Utang itu alat
{{Utang}} adalah uang yang kamu pakai sekarang dan harus dikembalikan nanti, biasanya dengan tambahan biaya. Utang bisa membantu, misalnya untuk biaya kuliah atau alat kerja yang menambah penghasilan. Utang menjadi masalah saat dipakai untuk hal yang cepat habis, dan cicilannya terus menekan pemasukanmu.

kartu 2 | judul: Tiga pertanyaan sebelum berutang
Tanyakan tiga hal. Pertama, untuk apa uang ini: kebutuhan atau keinginan? Kedua, berapa total yang harus kukembalikan, termasuk biayanya? Ketiga, apakah cicilannya masih nyaman kalau pemasukanku turun? Kalau jawabannya masih samar, tunda dulu.

kartu 3 | judul: Tanda utang mulai menjerat
Waspadai beberapa tanda: menutup utang lama dengan utang baru, hanya sanggup membayar jumlah minimum, cicilan memakan sebagian besar pemasukan, dan rasa cemas setiap tagihan datang. Kalau tanda itu muncul, itu sinyal untuk bertindak lebih awal. Itu bukan alasan untuk malu. Di Funda, semua utang dicatat supaya terlihat jelas.

contohAngka:
judul: Tiga cicilan kecil yang menumpuk (pemasukan Rp3.000.000 per bulan)
baris:
- Cicilan HP | 450000
- Paylater | 300000
- Pinjaman teman | 250000
- Jumlah cicilan per bulan | 1000000 | ringkasan
kesimpulan: Tiga cicilan yang masing-masing terasa kecil menjadi Rp1.000.000 per bulan, sekitar sepertiga dari pemasukan Rp3.000.000.

cekPaham:
1. tanya: Mana yang paling dekat dengan utang yang membantu?
   pilihan: Pinjaman untuk membeli alat kerja yang menambah penghasilan * | Cicilan gadget baru hanya karena sedang diskon | Paylater untuk mentraktir teman
   penjelasan: Utang yang membantu biasanya menambah kemampuanmu menghasilkan atau memenuhi kebutuhan penting. Diskon dan traktiran bukan itu.
2. tanya: Mana yang termasuk tanda utang mulai menjerat?
   pilihan: Menutup utang lama dengan utang baru * | Membayar cicilan tepat waktu | Mencatat semua utang di Funda
   penjelasan: Utang baru untuk menutup utang lama membuat beban terus berpindah dan membesar. Membayar tepat waktu dan mencatat justru langkah yang sehat.
3. tanya: Pertanyaan mana yang BUKAN bagian dari tiga pertanyaan sebelum berutang?
   pilihan: Apakah pemberi pinjamannya terkenal? * | Berapa total yang harus kukembalikan? | Apakah cicilannya masih nyaman kalau pemasukanku turun?
   penjelasan: Nama besar tidak menunjukkan seberapa nyaman cicilannya bagimu. Total dan kenyamanan saat pemasukan turun lebih menentukan.

misi: tipe lihat_hitungan
judul: Lihat ringkasan utangmu
instruksi: Buka ringkasan utangmu, baca isinya, lalu tekan Mengerti.
umpanBalik: ringkasan_utang

tindakLanjut:
Untuk dipikirkan, tidak perlu dijawab di aplikasi: kalau pemasukanmu turun sedikit bulan depan, cicilan mana yang paling terasa?

---------------------------------------------------------------------
PELAJARAN utang_cicilan_4_2
judul: Bunga dan Biaya yang Sebenarnya
durasiMenit: 6
catatanReviewer: TODO-VERIFIKASI. (1) Penjelasan bunga flat dan bunga efektif. (2) Klaim bahwa pada paylater dan kartu kredit, membayar jumlah minimum bisa membuat bunga terus berjalan. (3) Angka bunga pada contoh hanya ilustrasi.
gerbang pelajaran: tidak ada (berlaku gerbang modul)

pemantik:
Cicilan Rp1.120.000 per bulan terdengar ringan. Tapi berapa total yang akhirnya kamu bayar?

kartu 1 | judul: Lihat total, bukan hanya cicilan
{{Pokok}} adalah jumlah yang kamu pinjam. Total bayar adalah cicilan dikali jumlah bulan. Selisih antara total bayar dan pokok adalah biaya pinjaman, yaitu bunga ditambah biaya lain. Cicilan bulanan yang kecil bisa menyembunyikan total yang besar.

kartu 2 | judul: Bunga flat dan bunga efektif
{{Bunga flat}} dihitung dari pokok awal terus, walau sisa pokokmu sudah menurun. {{Bunga efektif}} dihitung dari sisa pokok yang menurun. Karena itu bunga flat dengan persen yang sama terasa lebih mahal daripada bunga efektif. Saat membandingkan dua penawaran, pastikan jenis bunganya sama, atau minta total bayarnya.

kartu 3 | judul: Biaya yang sering terlupa
Selain bunga, ada biaya admin, asuransi, dan denda keterlambatan. Pada {{paylater}} dan kartu kredit, membayar jumlah minimum saja bisa membuat bunga terus berjalan. Pertanyaan sederhana ini sah kamu ajukan: total yang harus saya bayar sampai lunas berapa?

contohAngka:
judul: Pinjaman Rp12.000.000 selama 12 bulan, bunga flat 12 persen per tahun
baris:
- Pokok | 12000000
- Bunga flat selama 12 bulan | 1440000
- Total yang dibayar | 13440000 | ringkasan
- Cicilan per bulan | 1120000
kesimpulan: Cicilan Rp1.120.000 terlihat ringan, tetapi total yang dibayar Rp13.440.000, atau Rp1.440.000 lebih besar dari pokok.

cekPaham:
1. tanya: Pokok Rp6.000.000, cicilan Rp550.000 selama 12 bulan. Berapa biaya pinjamannya?
   pilihan: Rp600.000 * | Rp550.000 | Rp6.600.000
   penjelasan: Rp550.000 dikali 12 hasilnya Rp6.600.000. Dikurangi pokok Rp6.000.000, biaya pinjamannya Rp600.000.
2. tanya: Kenapa bunga flat dengan persen yang sama terasa lebih mahal daripada bunga efektif?
   pilihan: Karena dihitung dari pokok awal terus, walau sisa pokok sudah menurun * | Karena bunga flat selalu punya angka persen lebih besar | Karena bunga efektif tidak pernah ada
   penjelasan: Bunga flat tidak ikut mengecil saat pokokmu berkurang, jadi biaya totalnya lebih besar.
3. tanya: Pertanyaan mana yang paling berguna sebelum menyetujui pinjaman?
   pilihan: Total yang harus saya bayar sampai lunas berapa? * | Cicilan paling kecil berapa? | Apakah ada hadiah untuk peminjam baru?
   penjelasan: Total bayar menunjukkan biaya sebenarnya. Cicilan kecil dan hadiah bisa mengalihkan perhatian dari total itu.

misi: tipe lihat_hitungan
judul: Lihat biaya pinjamanmu
instruksi: Buka hitungan biaya pinjaman, baca isinya, lalu tekan Mengerti.
umpanBalik: biaya_pinjaman_tercatat

tindakLanjut:
Lengkapi data pokok awal, tenor, dan cicilan di menu Utang untuk tiap utangmu. Dengan begitu biaya pinjamannya bisa dihitung.

---------------------------------------------------------------------
PELAJARAN utang_cicilan_4_3
judul: Rasio Cicilan terhadap Pemasukan
durasiMenit: 5
aturanPraktis: true
catatanReviewer: TODO-VERIFIKASI. (1) Batas sekitar 30 persen untuk total cicilan terhadap pemasukan: aturan praktis yang umum disebut; periksa sumber resmi (mis. materi edukasi OJK atau ketentuan perbankan tentang rasio cicilan), termasuk apakah batasnya berbeda menurut jenis kredit. (2) Klaim bahwa penghasilan tidak tetap atau tanggungan menyempitkan ruang cicilan.
gerbang pelajaran: tidak ada (berlaku gerbang modul)

pemantik:
Semua cicilanmu masih terbayar. Tapi seberapa besar bagian pemasukanmu yang sudah terikat untuk cicilan?

kartu 1 | judul: Rasio cicilan, satu angka yang jujur
{{Rasio cicilan}} adalah bagian pemasukan bulanan yang dipakai untuk membayar cicilan. Caranya, bagi total cicilan per bulan dengan pemasukan per bulan, lalu kali 100 persen. Makin besar rasionya, makin kecil ruang untuk kebutuhan lain dan tabungan.

kartu 2 | judul: Pegangan dari aturan praktis
Sebagai {{aturan praktis}}, banyak panduan menyebut total cicilan sebaiknya tidak melewati sekitar 30 persen dari pemasukan. Ini titik awal untuk bertanya pada dirimu, bukan penilaian atas dirimu. Kalau penghasilanmu tidak tetap atau kamu punya tanggungan, ruangnya bisa lebih sempit.

kartu 3 | judul: Kalau rasionya terasa besar
Kamu punya tiga tuas: menambah pemasukan, menurunkan cicilan, atau menahan utang baru. Untuk menurunkan cicilan, tanyakan opsi yang sah ke pemberi pinjaman dan hitung total biayanya dulu, karena cicilan lebih kecil bisa berarti total lebih besar. Jangan menutup cicilan dengan utang baru.

contohAngka:
judul: Rasio cicilan untuk pemasukan Rp3.000.000
baris:
- Total cicilan per bulan | 900000
- Pemasukan per bulan | 3000000
- Pemasukan kalau turun 25 persen | 2250000
kesimpulan: Rasio sekarang 30 persen (Rp900.000 dibagi Rp3.000.000). Kalau pemasukan turun 25 persen menjadi Rp2.250.000, rasionya naik menjadi 40 persen, padahal cicilannya sama.

cekPaham:
1. tanya: Cicilan Rp600.000 dan pemasukan Rp2.400.000. Berapa rasio cicilannya?
   pilihan: 25 persen * | 20 persen | 40 persen
   penjelasan: Rp600.000 dibagi Rp2.400.000 hasilnya 0,25, atau 25 persen.
2. tanya: Rasio cicilan sebaiknya diperlakukan sebagai apa?
   pilihan: Bahan bertanya tentang kondisimu, bukan penilaian atas dirimu * | Hukum yang sama untuk semua orang | Tanda bahwa kamu harus berhenti membayar
   penjelasan: Rasio membantumu melihat gambaran. Kondisi tiap orang berbeda, jadi angkanya tidak menilai dirimu.
3. tanya: Pemasukan turun, cicilan tetap sama. Apa yang terjadi pada rasionya?
   pilihan: Naik * | Turun | Tetap
   penjelasan: Pembaginya mengecil sementara cicilan sama, sehingga rasionya naik.

misi: tipe lihat_hitungan
judul: Baca rasio cicilanmu
instruksi: Buka hitungan rasio cicilan, baca isinya, lalu tekan Mengerti.
umpanBalik: rasio_cicilan_bulan_ini

tindakLanjut:
Catat semua pemasukan bulan ini, termasuk yang kecil. Rasio cicilanmu hanya akurat kalau pemasukannya lengkap.

---------------------------------------------------------------------
PELAJARAN utang_cicilan_4_4
judul: Strategi Melunasi: Bola Salju dan Longsor
durasiMenit: 6
catatanReviewer: TODO-VERIFIKASI. (1) Klaim bahwa cara longsor biasanya menekan total biaya dan cara bola salju memberi semangat dari kemenangan kecil: periksa sumber. (2) Persen bunga pada contoh hanya ilustrasi.
gerbang pelajaran: tidak ada (berlaku gerbang modul)

pemantik:
Ada beberapa cicilan, dan uang ekstramu terbatas. Mana yang dilunasi lebih dulu?

kartu 1 | judul: Dua cara populer
Dengan cara {{bola salju}}, kamu melunasi utang dengan sisa terkecil lebih dulu. Satu utang tuntas lebih awal, dan itu memberi semangat. Dengan cara {{longsor}}, kamu mendahulukan utang dengan bunga tertinggi, yang biasanya menekan total biaya. Pada keduanya, cicilan minimum semua utang tetap dibayar. Uang ekstra diarahkan ke satu utang.

kartu 2 | judul: Memilih yang cocok untukmu
Kalau kamu butuh kemenangan kecil agar tetap semangat, bola salju bisa cocok. Kalau kamu ingin menekan total biaya, longsor bisa cocok. Tidak ada yang paling benar. Yang penting kamu konsisten menjalankannya.

kartu 3 | judul: Jangan hentikan alurnya
Setelah satu utang lunas, jangan lepas nominal cicilannya. Arahkan nominal itu ke utang berikutnya. Itu yang membuat laju melunasi makin cepat. Catat setiap pembayaran di Funda, supaya sisa utangmu selalu terbaru.

contohAngka:
judul: Tiga utang dengan bunga berbeda (contoh)
baris:
- Paylater: sisa, bunga 36 persen per tahun | 800000
- Pinjaman teman: sisa, tanpa bunga | 1500000
- Kredit HP: sisa, bunga 18 persen per tahun | 4000000
kesimpulan: Urutan bola salju: Paylater, Pinjaman teman, Kredit HP. Urutan longsor: Paylater, Kredit HP, Pinjaman teman. Pada contoh ini Paylater menjadi yang pertama di kedua cara, karena sisanya terkecil dan bunganya tertinggi.

cekPaham:
1. tanya: Tiga utang bersisa Rp2.000.000, Rp500.000, dan Rp1.200.000. Bola salju melunasi yang mana lebih dulu?
   pilihan: Yang bersisa Rp500.000 * | Yang bersisa Rp2.000.000 | Yang cicilannya paling kecil
   penjelasan: Bola salju mendahulukan sisa terkecil.
2. tanya: Longsor mengutamakan utang yang mana?
   pilihan: Yang bunganya paling tinggi * | Yang sisanya paling kecil | Yang paling lama
   penjelasan: Longsor mendahulukan bunga tertinggi karena itulah yang paling menambah biaya.
3. tanya: Setelah satu utang lunas, nominal cicilannya sebaiknya bagaimana?
   pilihan: Diarahkan ke utang berikutnya agar melunasi makin cepat * | Dipakai untuk belanja | Dihapus dari catatan
   penjelasan: Nominal yang sama terus bekerja, sehingga utang berikutnya lunas lebih cepat.

misi: tipe lihat_hitungan
judul: Lihat urutan pelunasanmu
instruksi: Buka urutan pelunasan, baca isinya, lalu tekan Mengerti.
umpanBalik: urutan_pelunasan

tindakLanjut:
Pilih satu cara dan tulis alasannya. Lalu tentukan satu nominal ekstra yang realistis tiap bulan.

---------------------------------------------------------------------
KUIS AKHIR MODUL 4 (jumlahSoal 5, bankSoal 10; ambang lulus 70%; pelajaranId tiap soal)

1. [utang_cicilan_4_1] tanya: Mana yang paling dekat dengan utang yang membantu?
   pilihan: Pinjaman untuk membeli alat kerja yang menambah penghasilan * | Cicilan barang baru hanya karena sedang diskon | Paylater untuk mentraktir teman
   penjelasan: Utang yang membantu biasanya menambah kemampuanmu menghasilkan atau memenuhi kebutuhan penting.
2. [utang_cicilan_4_1] tanya: Mana yang termasuk tanda utang mulai menjerat?
   pilihan: Menutup utang lama dengan utang baru * | Membayar cicilan tepat waktu | Mencatat semua utang
   penjelasan: Utang baru untuk menutup utang lama membuat beban terus berpindah dan membesar.
3. [utang_cicilan_4_1] tanya: Sebelum berutang, pertanyaan mana yang paling berguna?
   pilihan: Berapa total yang harus kukembalikan, termasuk biayanya? * | Apakah aplikasinya populer? | Apakah temanku juga berutang?
   penjelasan: Total yang harus dikembalikan menunjukkan beban sebenarnya, termasuk biayanya.
4. [utang_cicilan_4_2] tanya: Pokok Rp3.000.000, cicilan Rp280.000 selama 12 bulan. Berapa biaya pinjamannya?
   pilihan: Rp360.000 * | Rp280.000 | Rp3.360.000
   penjelasan: Rp280.000 dikali 12 hasilnya Rp3.360.000. Dikurangi pokok Rp3.000.000, biayanya Rp360.000.
5. [utang_cicilan_4_2] tanya: Mana yang termasuk biaya yang sering terlupa saat melihat cicilan bulanan?
   pilihan: Biaya admin, asuransi, dan denda keterlambatan * | Warna aplikasi pinjaman | Jumlah teman yang berutang
   penjelasan: Biaya tambahan bisa menambah total yang kamu bayar, walau tidak terlihat di cicilan bulanan.
6. [utang_cicilan_4_2] tanya: Bunga flat dihitung dari apa?
   pilihan: Pokok awal terus selama tenor * | Sisa pokok yang menurun | Penghasilan peminjam
   penjelasan: Bunga flat tidak ikut mengecil saat pokok berkurang, sedangkan bunga efektif dihitung dari sisa pokok.
7. [utang_cicilan_4_3] tanya: Cicilan Rp800.000 dan pemasukan Rp4.000.000. Berapa rasio cicilannya?
   pilihan: 20 persen * | 8 persen | 50 persen
   penjelasan: Rp800.000 dibagi Rp4.000.000 hasilnya 0,2, atau 20 persen.
8. [utang_cicilan_4_3] tanya: Pemasukan turun sementara cicilan tetap sama. Apa yang terjadi pada rasio cicilan?
   pilihan: Naik * | Turun | Tetap
   penjelasan: Pemasukan yang mengecil membuat bagian untuk cicilan makin besar.
9. [utang_cicilan_4_4] tanya: Tiga utang bersisa Rp3.000.000, Rp750.000, dan Rp1.500.000. Bola salju melunasi yang mana lebih dulu?
   pilihan: Yang bersisa Rp750.000 * | Yang bersisa Rp3.000.000 | Yang bersisa Rp1.500.000
   penjelasan: Bola salju mendahulukan utang dengan sisa terkecil.
10. [utang_cicilan_4_4] tanya: Cara longsor mengutamakan utang yang mana?
   pilihan: Yang bunganya paling tinggi * | Yang sisanya paling kecil | Yang paling baru
   penjelasan: Longsor mendahulukan bunga tertinggi karena itulah yang paling menambah biaya.
