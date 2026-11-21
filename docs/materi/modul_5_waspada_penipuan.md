# MODUL 5: WASPADA PENIPUAN & PINJOL ILEGAL

MODUL: waspada_penipuan | tingkat: pemula | tersedia: true | urutan: 5
gerbang modul: modul_selesai anggaran_arus_kas
pesan gerbang modul: "Selesaikan Modul 1 dulu, lalu modul ini terbuka."

---------------------------------------------------------------------
PELAJARAN waspada_penipuan_5_1
judul: Ciri Tawaran yang Mencurigakan
durasiMenit: 5
gerbang pelajaran: tidak ada (berlaku gerbang modul)
catatanReviewer: TODO-VERIFIKASI. (1) Lima tanda dan tiga rem adalah ringkasan umum dari materi edukasi penipuan; periksa kecocokannya dengan sumber resmi. (2) Contoh hadiah dan skenario telepon bank bersifat fiktif.

pemantik:
Pesan masuk: kamu menang hadiah Rp5.000.000. Transfer biaya admin Rp150.000 hari ini. Rasanya menggoda, dan waktunya terasa mepet.

kartu 1 | judul: Penipuan bermain di perasaan
Penipu jarang memakai cara rumit. Mereka bermain di perasaan: senang karena hadiah, takut karena ancaman, atau buru-buru karena batas waktu. Saat perasaan itu naik, kita lebih mudah mengambil keputusan cepat. Karena itu, jeda sebentar adalah pertahanan yang kuat.

kartu 2 | judul: Lima tanda yang sering muncul
Waspadai lima tanda. Pertama, kamu diminta mentransfer {{biaya di muka}} sebelum menerima apa pun. Kedua, ada tekanan waktu. Ketiga, kamu diminta kode {{OTP}}, PIN, atau kata sandi. Keempat, tautan atau nomornya tidak resmi, misalnya pesan {{phishing}} yang menyamar sebagai bank. Kelima, ada janji untung besar tanpa risiko. Satu tanda saja sudah cukup untuk berhenti dan memeriksa.

kartu 3 | judul: Tiga rem sebelum bertindak
Pakai tiga rem. Berhenti: jangan membalas atau mentransfer dulu. Periksa: cari kontak resmi lewat situs atau aplikasi resmi, bukan dari pesan tadi. Tanya: ceritakan pada orang yang kamu percaya. Ingat juga, kode {{OTP}} dan PIN tidak dibagikan ke siapa pun, termasuk yang mengaku petugas.

contohAngka:
judul: Hadiah yang tidak pernah datang
baris:
- Hadiah yang dijanjikan | 5000000
- Biaya admin yang diminta di muka | -150000
- Hadiah yang benar-benar diterima | 0
- Uang yang hilang | -150000 | ringkasan
kesimpulan: Hadiahnya tidak pernah datang, tetapi uangmu Rp150.000 sudah hilang. Biaya kecil di muka adalah umpan yang sering dipakai.

cekPaham:
1. tanya: Kamu diminta transfer Rp150.000 dulu supaya hadiah Rp5.000.000 bisa cair. Apa yang paling masuk akal?
   pilihan: Berhenti, lalu periksa lewat kontak resmi dan tanya orang yang kamu percaya * | Transfer cepat karena batasnya hari ini | Transfer sedikit dulu untuk mengetes
   penjelasan: Biaya di muka dengan batas waktu adalah tanda yang sering muncul. Berhenti dan memeriksa lebih aman daripada mentransfer.
2. tanya: Siapa yang boleh kamu beri kode OTP?
   pilihan: Tidak seorang pun, termasuk yang mengaku petugas bank * | Petugas yang menelepon dan tahu namamu | Siapa pun yang meminta dengan sopan
   penjelasan: Kode OTP hanya untukmu. Penelepon yang tahu namamu pun bisa saja penipu.
3. tanya: Mana yang BUKAN tanda yang perlu diwaspadai?
   pilihan: Penyedia menjelaskan total biaya dan syarat secara tertulis dan jelas * | Ada batas waktu yang sangat mepet | Kamu diminta transfer biaya di muka
   penjelasan: Penjelasan biaya dan syarat yang jelas adalah tanda yang baik. Batas waktu mepet dan biaya di muka termasuk tanda yang perlu diwaspadai.

misi: tipe keputusan
judul: Latih rem-mu
instruksi: Baca skenarionya, lalu pilih langkah yang menurutmu paling aman. Kamu boleh mencoba pilihan lain untuk melihat akibatnya.
skenario pemantik: Seseorang menelepon dan mengaku dari bank. Katanya akunmu bermasalah dan akan diblokir hari ini. Dia meminta kode OTP yang baru kamu terima supaya akunmu "diselamatkan".
opsi:
- a | Berikan kode OTP supaya akunku selamat | aman: false | umpanBalik: Kode OTP adalah kunci akunmu. Siapa pun yang memintanya, termasuk yang mengaku petugas, sebaiknya tidak diberi. Coba pilihan lain.
- b | Tutup telepon, lalu hubungi bank lewat nomor di aplikasi atau kartu resminya * | aman: true | umpanBalik: Tepat. Kamu berhenti dan memeriksa lewat jalur resmi. Pihak yang benar tidak akan memintamu terburu-buru membagikan kode.
- c | Tanya nama petugas dan minta dia menyebut saldoku dulu | aman: false | umpanBalik: Penipu bisa saja sudah punya sebagian datamu. Menyebut nama atau saldo belum membuktikan dia petugas sungguhan. Coba pilihan lain.
- d | Minta waktu lima menit, lalu transfer sedikit untuk "mengamankan" akun | aman: false | umpanBalik: Memindahkan uang atas permintaan penelepon justru membuka jalan bagi penipuan. Coba pilihan lain.

tindakLanjut:
Simpan nomor resmi bank atau dompet digitalmu di kontak HP dengan nama yang jelas, supaya mudah dihubungi saat kamu ragu.

---------------------------------------------------------------------
PELAJARAN waspada_penipuan_5_2
judul: Cek Legalitas Sebelum Percaya
durasiMenit: 6
gerbang pelajaran: tidak ada (berlaku gerbang modul)
catatanReviewer: TODO-VERIFIKASI. (1) Penyedia pinjaman online yang sah umumnya wajib berizin atau terdaftar pada lembaga pengawas keuangan di Indonesia: periksa kebenaran dan istilah resmi terkini. (2) Cara mengecek izin melalui situs atau layanan resmi lembaga itu: periksa langkah terkini; konten sengaja tidak menyebut alamat situs. (3) Tanda aplikasi pinjaman bermasalah (akses kontak dan foto, penagihan dengan ancaman, dana cair lebih kecil dari yang dijanjikan). (4) Angka pada contoh bersifat fiktif.

pemantik:
Aplikasi pinjaman muncul di iklan. Prosesnya cepat dan syaratnya hanya KTP. Sebelum mengunduh, ada satu pertanyaan penting: penyedianya berizin atau tidak?

kartu 1 | judul: Izin itu pintu pertama
Penyedia pinjaman yang sah umumnya berizin atau terdaftar di {{lembaga pengawas}} keuangan. Izin membuat ada pihak yang mengawasi cara mereka menagih dan menjaga datamu. {{Pinjol ilegal}} tidak punya pengawas itu, sehingga biaya dan cara penagihannya bisa tidak terkendali.

kartu 2 | judul: Tanda aplikasi pinjaman bermasalah
Waspadai beberapa tanda. Aplikasi meminta akses ke seluruh kontak, foto, dan pesan di HP-mu. Biaya dan bunganya tidak dijelaskan di depan. Dana yang cair jauh lebih kecil dari yang dijanjikan. Penagih mengancam atau mempermalukanmu lewat kontakmu. Kalau tanda ini muncul, jangan lanjutkan.

kartu 3 | judul: Cek sendiri lewat jalur resmi
Cek izin lewat situs atau layanan resmi lembaga pengawas, bukan lewat tautan di iklan atau pesan. Baca total yang harus dikembalikan, bukan hanya cicilan. Tanyakan: siapa penyedianya, di mana alamatnya, dan bagaimana cara mengadu? Kalau jawabannya tidak jelas, tunda dulu. Pinjaman bisa menunggu, dan keputusanmu tidak perlu terburu-buru.

contohAngka:
judul: Pinjaman cepat yang cairnya lebih kecil
baris:
- Pinjaman yang dijanjikan | 3000000
- Potongan biaya admin di muka | -900000
- Dana yang benar-benar cair | 2100000 | ringkasan
- Yang harus dikembalikan dalam 14 hari | 3000000
kesimpulan: Kamu menerima Rp2.100.000, tetapi harus mengembalikan Rp3.000.000 dalam dua minggu. Selisih Rp900.000 itu terasa sangat besar untuk waktu sesingkat itu.

cekPaham:
1. tanya: Aplikasi pinjaman meminta akses ke seluruh kontak dan foto di HP-mu. Apa artinya?
   pilihan: Tanda bahaya, lebih baik tidak dilanjutkan * | Tanda bahwa aplikasinya canggih | Biasa saja, semua aplikasi melakukannya
   penjelasan: Akses ke kontak dan foto bisa dipakai untuk menekan atau mempermalukanmu saat menagih. Itu tanda bahaya.
2. tanya: Di mana cara terbaik untuk mengecek izin sebuah penyedia pinjaman?
   pilihan: Lewat situs atau layanan resmi lembaga pengawas, dibuka sendiri * | Lewat tautan di iklan yang kamu lihat | Lewat ulasan pengguna di media sosial
   penjelasan: Tautan di iklan bisa palsu. Buka sendiri sumber resminya.
3. tanya: Kamu dijanjikan Rp2.000.000, tetapi yang cair Rp1.400.000, dan kamu tetap harus mengembalikan Rp2.000.000. Berapa selisihnya?
   pilihan: Rp600.000 yang tidak kamu terima tetapi tetap kamu kembalikan * | Rp1.400.000 | Tidak ada selisih
   penjelasan: Rp2.000.000 dikurangi Rp1.400.000 adalah Rp600.000. Itu biaya yang kamu tanggung walau uangnya tidak sampai ke tanganmu.

misi: tipe daftar_periksa | disclaimer: true | minimalDicentang: 3
judul: Siapkan cara cek penyedia
instruksi: Baca catatan di atas, lalu centang langkah yang sudah atau akan kamu lakukan. Minimal tiga langkah.
langkah:
- l1 | Aku tahu cara membuka situs resmi lembaga pengawas keuangan lewat pencarian sendiri, bukan lewat tautan iklan.
- l2 | Aku mencatat nama penyedia yang ingin kuperiksa dan alamat resminya.
- l3 | Aku memeriksa apakah penyedia itu tercatat berizin di sumber resmi.
- l4 | Aku membaca total yang harus dikembalikan, bukan hanya cicilannya.
- l5 | Aku memeriksa izin akses yang diminta aplikasinya sebelum mengunduh.
- l6 | Aku menyimpan kontak pengaduan resmi di HP-ku.

tindakLanjut:
Kalau ada tawaran pinjaman yang menarik minggu ini, jalankan daftar ini sebelum mengunduh aplikasinya. Kalau ragu, tunda dulu.

---------------------------------------------------------------------
PELAJARAN waspada_penipuan_5_3
judul: Kalau Sudah Terlanjur
durasiMenit: 5
gerbang pelajaran: tidak ada (berlaku gerbang modul)
catatanReviewer: TODO-VERIFIKASI. (1) Urutan langkah penanganan dan pilihan kanal pelaporan: periksa panduan resmi penyedia layanan, lembaga pengawas, dan pihak berwenang; konten sengaja tidak menyebut nama lembaga atau nomor. (2) Pelajaran ini tidak memberi nasihat hukum, termasuk soal kewajiban membayar tagihan: pastikan redaksinya tetap berupa anjuran memeriksa lewat jalur resmi. (3) Angka pada contoh bersifat fiktif.

pemantik:
Kamu terlanjur memberi kode, mentransfer uang, atau mengunduh aplikasi yang ternyata bermasalah. Perasaannya campur aduk, dan itu wajar. Yang penting sekarang adalah langkah berikutnya.

kartu 1 | judul: Tenang dulu, lalu bertindak
Siapa pun bisa tertipu, termasuk orang yang teliti. Rasa malu sering membuat orang diam, padahal waktu sangat berharga. Mulailah dari langkah kecil yang bisa kamu lakukan sekarang. Makin cepat kamu bertindak, makin besar peluang kerugian dibatasi.

kartu 2 | judul: Langkah pertama: amankan
Hentikan kontak dan jangan transfer lagi. Ubah kata sandi akun yang terkait, lalu aktifkan {{verifikasi dua langkah}}. Hubungi bank atau penyedia dompet digitalmu lewat kontak resmi untuk menanyakan cara mengamankan akun. Simpan bukti, seperti tangkapan layar pesan, nomor pengirim, dan bukti transfer.

kartu 3 | judul: Langkah berikutnya: lapor dan cerita
Laporkan lewat kanal resmi, misalnya penyedia layanan yang terkait dan pihak berwenang. Ceritakan pada orang yang kamu percaya, karena dukungan membuat keputusan lebih jernih. Jangan memutuskan membayar atau mentransfer dalam keadaan tertekan. Periksa dulu lewat jalur resmi, lalu putuskan dengan kepala dingin.

contohAngka:
judul: Satu kejadian, dua cara menanggapi
baris:
- Uang yang sudah ditransfer ke penipu | -500000
- Uang tambahan yang diminta "untuk pelunasan" | -500000
- Kerugian bila terus menuruti | -1000000 | ringkasan
kesimpulan: Kalau berhenti setelah transfer pertama, kerugiannya Rp500.000. Kalau menuruti permintaan berikutnya, kerugiannya bisa menjadi Rp1.000.000 atau lebih. Berhenti lebih awal membatasi kerugian.

cekPaham:
1. tanya: Setelah sadar tertipu, apa langkah yang paling masuk akal lebih dulu?
   pilihan: Hentikan kontak, amankan akun, dan simpan bukti * | Transfer lagi supaya urusannya selesai | Diam saja karena malu
   penjelasan: Menghentikan kontak dan mengamankan akun membatasi kerugian. Bukti membantu saat melapor.
2. tanya: Mengapa bukti seperti tangkapan layar dan bukti transfer perlu disimpan?
   pilihan: Membantu saat melapor ke penyedia layanan atau pihak berwenang * | Supaya bisa dipamerkan ke teman | Supaya bisa dihapus nanti
   penjelasan: Bukti membuat laporanmu lebih jelas dan lebih mudah ditindaklanjuti.
3. tanya: Penagih mengancam dan menyuruhmu transfer hari ini. Sikap yang paling masuk akal?
   pilihan: Tidak memutuskan dalam tekanan, periksa lewat jalur resmi, dan minta pendapat orang tepercaya * | Langsung transfer supaya tenang | Membalas dengan ancaman
   penjelasan: Keputusan di bawah tekanan sering merugikan. Jalur resmi dan orang tepercaya membantumu berpikir jernih.

misi: tipe daftar_periksa | disclaimer: true | minimalDicentang: 3
judul: Susun rencana daruratmu
instruksi: Baca catatan di atas, lalu centang langkah yang sudah kamu siapkan. Minimal tiga langkah.
langkah:
- l1 | Aku tahu kontak resmi bank atau dompet digitalku dan menyimpannya di HP.
- l2 | Aku tahu cara mengubah kata sandi dan mengaktifkan verifikasi dua langkah di akun pentingku.
- l3 | Aku sudah memilih satu orang yang kupercaya untuk diajak bicara bila ada masalah.
- l4 | Aku tahu cara mengambil dan menyimpan tangkapan layar sebagai bukti.
- l5 | Aku tahu bahwa aku tidak perlu memutuskan apa pun dalam keadaan tertekan.

tindakLanjut:
Minggu ini, aktifkan verifikasi dua langkah di satu akun pentingmu, misalnya e-mail atau dompet digital.

---------------------------------------------------------------------
DISCLAIMER (aset/konten/disclaimer.json, kunci langkahDuniaNyata; teks akhir perlu ditinjau pihak yang paham hukum)
"Funda hanya memberi edukasi umum. Ini bukan ajakan membeli produk keuangan atau nasihat keuangan, hukum, maupun pajak. Keputusan dan risikonya ada padamu. Funda tidak bertanggung jawab atas kerugian dari tindakan di luar aplikasi. Pastikan penyedia berizin sebelum memakai uangmu."

---------------------------------------------------------------------
KUIS AKHIR MODUL 5 (jumlahSoal 5, bankSoal 10; ambang lulus 70% global; pelajaranId tiap soal)

1. [waspada_penipuan_5_1] tanya: Mana yang termasuk tanda yang sering muncul pada penipuan?
   pilihan: Diminta transfer biaya di muka sebelum menerima apa pun * | Penyedia menjelaskan total biaya secara tertulis | Penyedia memberimu waktu untuk berpikir
   penjelasan: Biaya di muka adalah tanda yang sering muncul. Penjelasan tertulis dan waktu untuk berpikir justru tanda yang baik.
2. [waspada_penipuan_5_1] tanya: Kode OTP sebaiknya dibagikan kepada siapa?
   pilihan: Tidak kepada siapa pun * | Petugas bank yang menelepon | Teman dekat yang sedang butuh
   penjelasan: Kode OTP adalah kunci masuk akunmu dan hanya untukmu.
3. [waspada_penipuan_5_1] tanya: Apa tiga rem sebelum bertindak?
   pilihan: Berhenti, periksa, tanya * | Transfer, tunggu, lapor | Klik, isi, kirim
   penjelasan: Berhenti menahan keputusan cepat, periksa lewat jalur resmi, dan tanya orang yang kamu percaya.
4. [waspada_penipuan_5_1] tanya: Kenapa penipu sering menekan dengan batas waktu?
   pilihan: Agar kamu tidak sempat berpikir dan memeriksa * | Karena penawarannya memang hanya sebentar | Supaya kamu lebih tenang
   penjelasan: Tekanan waktu mengurangi kesempatanmu untuk memeriksa dan bertanya.
5. [waspada_penipuan_5_2] tanya: Di mana sebaiknya kamu mengecek izin sebuah penyedia pinjaman?
   pilihan: Lewat situs atau layanan resmi lembaga pengawas, dibuka sendiri * | Lewat tautan di iklan | Lewat ulasan di media sosial
   penjelasan: Tautan di iklan bisa palsu. Buka sendiri sumber resminya.
6. [waspada_penipuan_5_2] tanya: Pinjaman dijanjikan Rp2.000.000, cair Rp1.500.000, dan harus dikembalikan Rp2.000.000. Berapa potongan di muka?
   pilihan: Rp500.000 * | Rp1.500.000 | Rp2.000.000
   penjelasan: Rp2.000.000 dikurangi Rp1.500.000 adalah Rp500.000.
7. [waspada_penipuan_5_2] tanya: Aplikasi pinjaman meminta akses ke semua kontakmu. Sikap yang masuk akal?
   pilihan: Menganggapnya tanda bahaya dan tidak melanjutkan * | Memberi akses supaya pinjaman cepat cair | Memberi akses tetapi mematikan notifikasi
   penjelasan: Akses ke kontak bisa dipakai untuk menekanmu saat menagih.
8. [waspada_penipuan_5_3] tanya: Setelah menyadari kamu tertipu, apa yang sebaiknya dilakukan lebih dulu?
   pilihan: Menghentikan kontak, mengamankan akun, dan menyimpan bukti * | Mentransfer lagi | Menunggu sampai masalahnya hilang
   penjelasan: Langkah itu membatasi kerugian dan menyiapkan bukti untuk melapor.
9. [waspada_penipuan_5_3] tanya: Apa kegunaan verifikasi dua langkah?
   pilihan: Menambah lapisan pengaman selain kata sandi * | Membuat kata sandi tidak perlu diganti | Menghapus semua riwayat masuk
   penjelasan: Walau kata sandi bocor, orang lain masih membutuhkan langkah kedua untuk masuk.
10. [waspada_penipuan_5_3] tanya: Penagih mengancam dan meminta transfer hari ini. Sikap yang masuk akal?
   pilihan: Tidak memutuskan dalam tekanan, periksa lewat jalur resmi, dan minta pendapat orang tepercaya * | Langsung transfer | Membalas dengan ancaman
   penjelasan: Keputusan di bawah tekanan sering merugikan. Jalur resmi dan orang tepercaya membantumu.

