MODUL: pajak_dasar | tingkat: menengah | tersedia: true | urutan: 9
gerbang modul: ada_data pemasukan min 1
pesan gerbang modul: "Catat minimal 1 pemasukan dulu supaya kamu punya gambaran nyata saat belajar pajak dasar."

---------------------------------------------------------------------
PELAJARAN pajak_dasar_9_1
judul: Mengenal Pajak Penghasilan dan NPWP
durasiMenit: 5
gerbang pelajaran: tidak ada (berlaku gerbang modul)
catatanReviewer: TODO-VERIFIKASI. Penjelasan umum konsep pajak penghasilan dan NPWP di Indonesia (termasuk integrasi NIK sebagai NPWP terkini); periksa redaksi terhadap aturan resmi terbaru.

pemantik:
Baru terima gaji pertama, lalu bagian personalia menanyakan nomor pajakmu. Rasanya bikin bingung, padahal konsep dasarnya sederhana.

kartu 1 | judul: Apa itu pajak penghasilan?
{{Pajak penghasilan}} adalah kontribusi wajib warga negara atas penghasilan yang diterima, sesuai aturan yang berlaku. Tidak semua orang yang punya penghasilan langsung membayar pajak, karena ada batas penghasilan tertentu yang ditetapkan pemerintah.

kartu 2 | judul: Apa fungsi NPWP?
{{NPWP}} adalah nomor identitas yang dipakai untuk urusan administrasi perpajakan. Memiliki identitas pajak yang rapi memudahkanmu saat melamar kerja, mengurus dokumen perbankan, hingga melaporkan penghasilan tahunan.

kartu 3 | judul: Pahami aturan resminya
Aturan perpajakan bisa berubah dari waktu ke waktu. Karena itu, Funda hanya membahas konsep dasarnya agar kamu tidak bingung dengan istilahnya. Untuk angka batas, tarif, dan prosedur terbaru, selalu periksa lewat saluran resmi lembaga pajak.

contohAngka:
judul: Ilustrasi slip gaji sederhana (angka fiktif)
baris:
- Gaji kotor bulanan | 5000000
- Potongan iuran dan pajak (ilustrasi) | -250000
- Gaji bersih yang diterima di rekening | 4750000 | ringkasan
kesimpulan: Memahami bedanya gaji kotor dan gaji bersih membantumu menyusun anggaran dari uang yang benar-benar masuk ke dompetmu.

cekPaham:
1. tanya: Apakah setiap orang yang menerima penghasilan pasti langsung membayar pajak penghasilan?
   pilihan: Tidak selalu, bergantung pada batas dan ketentuan resmi yang berlaku * | Ya, semua orang termasuk anak kecil langsung bayar | Tidak ada seorang pun yang membayar pajak
   penjelasan: Ada ketentuan batas penghasilan tidak kena pajak yang diatur secara resmi oleh pemerintah.
2. tanya: Apa fungsi utama NPWP?
   pilihan: Identitas administrasi untuk urusan perpajakan * | Kartu diskon belanja | Nomor rekening tabungan
   penjelasan: NPWP digunakan untuk mengenali wajib pajak dalam administrasi dan pelaporan.
3. tanya: Di mana tempat terbaik mengecek tarif dan aturan pajak terbaru?
   pilihan: Saluran resmi lembaga pajak * | Rumor di grup obrolan | Tebakan pribadi
   penjelasan: Aturan pajak dapat diperbarui, sehingga sumber resmi adalah rujukan paling akurat.

misi: tipe keputusan
judul: Menanggapi slip gaji pertama
instruksi: Pilih langkah yang paling tepat saat menerima gaji pertama.
skenario pemantik: Kamu baru bekerja dan menerima gaji pertamamu. Di slip gaji tertulis gaji kotor Rp5.000.000 dan gaji bersih Rp4.750.000 setelah potongan.
opsi:
- a | Susun anggaran bulanan berdasarkan gaji bersih Rp4.750.000 dan simpan slip gajinya * | aman: true | umpanBalik: Tepat. Anggaran mengikuti uang yang benar-benar kamu terima, dan slip gaji berguna sebagai arsip pajak.
- b | Susun anggaran dari Rp5.000.000 lalu bingung kenapa uang selalu kurang | aman: false | umpanBalik: Memakai angka kotor membuat anggaranmu meleset Rp250.000 setiap bulan. Coba pilihan lain.
- c | Langsung buang slip gaji karena tidak penting | aman: false | umpanBalik: Slip gaji dan bukti potong sangat berguna saat waktunya pelaporan pajak tahunan. Coba pilihan lain.

tindakLanjut:
Biasakan menyimpan slip gaji bulanan dalam satu folder rapi di HP atau komputermu.

---------------------------------------------------------------------
PELAJARAN pajak_dasar_9_2
judul: Penghasilan Kena Pajak dan Catatan Tahunan
durasiMenit: 5
gerbang pelajaran: tidak ada (berlaku gerbang modul)
catatanReviewer: TODO-VERIFIKASI. Konsep umum PTKP (Penghasilan Tidak Kena Pajak) dan perbedaan karyawan vs pekerja lepas tanpa menyebut nominal tarif/PTKP spesifik.

pemantik:
Banyak pekerja pemula mengira kalau pajak sudah dipotong kantor, urusannya selesai begitu saja. Padahal masih ada pelaporan tahunan.

kartu 1 | judul: Mengenal batas tidak kena pajak
Pemerintah menetapkan batas {{PTKP}}, yaitu jumlah penghasilan tahunan yang tidak dikenai pajak. Besarannya mempertimbangkan status, seperti lajang, menikah, dan jumlah tanggungan. Bagian di atas batas itulah yang umumnya menjadi dasar hitungan pajak.

kartu 2 | judul: Karyawan vs pekerja lepas
Untuk karyawan, pemberi kerja biasanya membantu memotong pajak dan memberikan bukti potong di akhir tahun. Untuk pekerja lepas atau pemilik usaha kecil, kamu perlu merekap penghasilanmu sendiri secara rapi sepanjang tahun.

kartu 3 | judul: Catatan rapi menghemat waktu
Mencatat setiap pemasukan di Funda sepanjang tahun bukan hanya membantu anggaran bulanan. Di akhir tahun, kamu langsung punya gambaran total penghasilanmu tanpa harus membongkar mutasi satu per satu dengan panik.

contohAngka:
judul: Ilustrasi rekap pemasukan 12 bulan (angka fiktif)
baris:
- Gaji bersih 12 bulan | 48000000
- Proyek sampingan setahun | 6000000
- Total pemasukan tercatat setahun | 54000000 | ringkasan
kesimpulan: Rekap yang tercatat sejak Januari membuatmu tenang saat menyiapkan laporan tahunan.

cekPaham:
1. tanya: Apa yang dimaksud dengan PTKP?
   pilihan: Batas penghasilan tahunan yang tidak dikenai pajak sesuai ketentuan resmi * | Biaya admin bank tahunan | Denda keterlambatan tagihan
   penjelasan: PTKP adalah batas dasar sebelum penghasilan dihitung pajaknya.
2. tanya: Apa perbedaan utama urusan pajak karyawan dan pekerja lepas?
   pilihan: Karyawan umumnya mendapat bukti potong dari kantor, pekerja lepas merekap sendiri * | Karyawan tidak pernah punya catatan | Pekerja lepas tidak perlu mencatat pemasukan
   penjelasan: Karena tidak ada pemotong tunggal, pekerja lepas perlu disiplin mencatat pemasukannya sendiri.
3. tanya: Mengapa mencatat pemasukan sejak awal tahun membantu urusan pajak?
   pilihan: Memudahkan rekap total penghasilan saat waktunya melapor * | Membuat pajak otomatis nol | Menggantikan dokumen resmi pemerintah
   penjelasan: Data yang rapi menghemat waktu dan mengurangi risiko lupa mencatat sumber penghasilan.

misi: tipe lihat_hitungan
judul: Lihat rekap pemasukanmu tahun ini
instruksi: Buka ringkasan total pemasukanmu yang tercatat tahun ini, baca isinya, lalu tekan Mengerti.
umpanBalik: ringkasan_penghasilan_tahunan

tindakLanjut:
Jika kamu karyawan, tanyakan ke bagian personalia kapan biasanya bukti potong tahunan dibagikan.

---------------------------------------------------------------------
PELAJARAN pajak_dasar_9_3
judul: Mengenal SPT Tahunan dan Kapan Melapor
durasiMenit: 5
gerbang pelajaran: tidak ada (berlaku gerbang modul)
catatanReviewer: TODO-VERIFIKASI. Gambaran umum SPT Tahunan orang pribadi dan persiapan dokumennya; tidak menyebut batas tanggal atau alamat situs spesifik agar tetap aman bila aturan berubah.

pemantik:
Setiap awal tahun, ramai orang membicarakan lapor SPT. Sebenarnya apa yang dilaporkan dan dokumen apa yang perlu disiapkan?

kartu 1 | judul: Apa itu SPT Tahunan?
{{SPT Tahunan}} adalah laporan yang disampaikan wajib pajak sekali setahun mengenai penghasilan, pajak yang sudah dipotong atau dibayar, serta daftar harta dan utang. Melapor tepat waktu menghindarkanmu dari denda administrasi.

kartu 2 | judul: Siapkan dokumen sebelum melapor
Sebelum mengisi laporan tahunan lewat layanan resmi, siapkan beberapa hal: bukti potong dari pemberi kerja (jika karyawan), rekap penghasilan tambahan, serta ringkasan saldo tabungan dan sisa utang di akhir tahun.

kartu 3 | judul: Funda membantu merapikan datamu
Ringkasan kekayaan bersih di Funda bisa membantumu mengingat daftar saldo dompet dan sisa utangmu. Namun ingat, pelaporan pajak tetap dilakukan langsung lewat kanal resmi lembaga pajak, dan bila kondisimu rumit, konsultasikan ke pihak resmi atau konsultan pajak berizin.

contohAngka:
judul: Tiga hal yang biasa disiapkan untuk rekap tahunan
baris:
- Jumlah bukti potong atau rekap penghasilan | 1
- Jumlah daftar saldo dompet dan tabungan | 1
- Jumlah daftar sisa utang akhir tahun | 1
kesimpulan: Menyiapkan tiga kelompok data ini lebih awal membuat proses pelaporan jauh lebih singkat dan tenang.

cekPaham:
1. tanya: Apa isi utama dari SPT Tahunan orang pribadi?
   pilihan: Laporan penghasilan, pajak yang sudah dipotong atau dibayar, serta ringkasan harta dan utang * | Daftar belanja harian di warung | Daftar film yang ditonton setahun
   penjelasan: SPT Tahunan merangkum posisi penghasilan, pajak, harta, dan kewajibanmu dalam setahun.
2. tanya: Mengapa melapor SPT Tahunan tepat waktu itu penting?
   pilihan: Memenuhi kewajiban administrasi dan menghindari denda keterlambatan * | Supaya gaji langsung naik | Supaya utang bank lunas otomatis
   penjelasan: Keterlambatan melapor dapat dikenai sanksi administrasi sesuai ketentuan yang berlaku.
3. tanya: Bagaimana peran Funda dalam pelaporan pajak?
   pilihan: Membantu merapikan catatan pemasukan, saldo, dan utang, bukan tempat melapor pajak * | Melaporkan pajak otomatis ke pemerintah | Memberi nasihat pajak berlisensi
   penjelasan: Pelaporan resmi selalu dilakukan langsung melalui layanan resmi lembaga pajak.

misi: tipe daftar_periksa | disclaimer: true | minimalDicentang: 3
judul: Daftar siap lapor tahunan
instruksi: Baca catatan di atas, lalu centang langkah persiapan pajak dasar yang sudah kamu pahami atau siapkan. Minimal tiga langkah.
langkah:
- l1 | Aku tahu status identitas perpajakanku (NPWP) dan menyimpannya dengan aman.
- l2 | Aku menyimpan slip gaji atau catatan pemasukan lepas sepanjang tahun.
- l3 | Aku tahu bahwa pelaporan SPT Tahunan dilakukan lewat saluran resmi lembaga pajak.
- l4 | Aku mengecek ringkasan saldo dan sisa utangku di akhir tahun sebagai bahan rekap.
- l5 | Aku tahu bahwa untuk kasus pajak yang rumit, aku perlu bertanya ke layanan resmi atau konsultan berizin.

tindakLanjut:
Buat satu folder khusus di HP atau komputermu bernama "Arsip Pajak" untuk menyimpan slip gaji dan bukti potong tahun ini.

---------------------------------------------------------------------
KUIS AKHIR MODUL 9 (jumlahSoal 5, bankSoal 10; ambang lulus 70% global; pelajaranId tiap soal)

1. [pajak_dasar_9_1] tanya: Apa itu pajak penghasilan?
   pilihan: Kontribusi wajib atas penghasilan yang diterima sesuai aturan berlaku * | Biaya langganan aplikasi | Bunga pinjaman bank
   penjelasan: Pajak penghasilan diatur oleh pemerintah berdasarkan ketentuan yang berlaku.
2. [pajak_dasar_9_1] tanya: Apa fungsi NPWP?
   pilihan: Nomor identitas untuk urusan administrasi perpajakan * | Nomor rekening dompet digital | Kode promo belanja
   penjelasan: NPWP dipakai sebagai identitas resmi wajib pajak.
3. [pajak_dasar_9_1] tanya: Anggaran bulanan karyawan sebaiknya disusun berdasarkan angka yang mana?
   pilihan: Gaji bersih yang benar-benar diterima * | Gaji kotor sebelum potongan | Angka perkiraan tanpa melihat slip
   penjelasan: Gaji bersih adalah uang nyata yang masuk ke tanganmu untuk dikelola.
4. [pajak_dasar_9_1] tanya: Di mana kamu harus mengecek tarif dan aturan pajak terbaru?
   pilihan: Saluran resmi lembaga pajak * | Komentar media sosial | Tebakan teman
   penjelasan: Sumber resmi memastikan kamu mengikuti peraturan terkini.
5. [pajak_dasar_9_2] tanya: Apa arti PTKP?
   pilihan: Batas penghasilan tahunan yang tidak dikenai pajak * | Potongan tunjangan karyawan bulanan | Pajak transaksi kartu kredit
   penjelasan: Penghasilan di bawah batas PTKP umumnya tidak dikenai pajak penghasilan.
6. [pajak_dasar_9_2] tanya: Bagaimana cara pekerja lepas menyiapkan data penghasilan untuk pajak?
   pilihan: Merekap pemasukan dan bukti bayaran sendiri secara rutin * | Menunggu potongan dari kantor yang tidak ada | Tidak perlu mencatat apa pun
   penjelasan: Pencatatan rutin sepanjang tahun memudahkan rekap di akhir tahun.
7. [pajak_dasar_9_2] tanya: Apa manfaat mencatat semua pemasukan di Funda sejak Januari?
   pilihan: Rekap penghasilan tahunan sudah siap saat dibutuhkan * | Pajak otomatis dibayarkan aplikasi | Saldo otomatis bertambah
   penjelasan: Catatan rapi menghemat waktu saat menyiapkan pelaporan.
8. [pajak_dasar_9_3] tanya: Apa itu SPT Tahunan?
   pilihan: Laporan tahunan wajib pajak tentang penghasilan, pajak, harta, dan utang * | Surat perjanjian sewa kos | Bukti transfer belanja online
   penjelasan: SPT Tahunan disampaikan sekali setahun melalui saluran resmi.
9. [pajak_dasar_9_3] tanya: Dokumen apa yang biasanya disiapkan karyawan sebelum melapor SPT Tahunan?
   pilihan: Bukti potong dari pemberi kerja serta ringkasan saldo dan utang * | Daftar lagu favorit | Riwayat pencarian internet
   penjelasan: Bukti potong dan ringkasan posisi keuangan memudahkan pengisian laporan.
10. [pajak_dasar_9_3] tanya: Jika kamu punya pertanyaan pajak yang rumit, langkah terbaik adalah?
    pilihan: Bertanya ke layanan resmi lembaga pajak atau konsultan pajak berizin * | Mengabaikan pelaporan | Menebak sendiri tanpa memeriksa
    penjelasan: Sumber resmi atau konsultan berizin memberi panduan yang tepat sesuai aturan.
