import 'package:flutter_test/flutter_test.dart';
import 'package:funda/perhitungan/perhitungan_belajar.dart';

void main() {
  group('Perhitungan Murni & Evaluasi Gerbang Data Belajar (TDD)', () {
    test('ambangLulusKuis adalah 70 dan perhitungan skor integer', () {
      expect(ambangLulusKuis, equals(70));

      // 3 dari 5 = 60% -> gagal
      expect(hitungSkorKuis(benar: 3, total: 5), equals(60));
      expect(tentukanLulusKuis(benar: 3, total: 5), isFalse);

      // 4 dari 5 = 80% -> lulus
      expect(hitungSkorKuis(benar: 4, total: 5), equals(80));
      expect(tentukanLulusKuis(benar: 4, total: 5), isTrue);

      // 7 dari 10 = 70% -> pas lulus
      expect(hitungSkorKuis(benar: 7, total: 10), equals(70));
      expect(tentukanLulusKuis(benar: 7, total: 10), isTrue);

      // Pembagian 0 aman
      expect(hitungSkorKuis(benar: 0, total: 0), equals(0));
      expect(tentukanLulusKuis(benar: 0, total: 0), isFalse);
    });

    test('Pengacak soal dan pilihan kuis deterministik dengan benih (seed)', () {
      final bank = [
        SoalKuis(
          id: 's1',
          pelajaranId: 'p1',
          tanya: 'Soal 1',
          pilihan: ['A1', 'B1', 'C1', 'D1'],
          benar: 0,
          penjelasan: 'Ket 1',
        ),
        SoalKuis(
          id: 's2',
          pelajaranId: 'p1',
          tanya: 'Soal 2',
          pilihan: ['A2', 'B2', 'C2', 'D2'],
          benar: 1,
          penjelasan: 'Ket 2',
        ),
        SoalKuis(
          id: 's3',
          pelajaranId: 'p1',
          tanya: 'Soal 3',
          pilihan: ['A3', 'B3', 'C3', 'D3'],
          benar: 2,
          penjelasan: 'Ket 3',
        ),
      ];

      final hasilAcak1 = pilihDanAcakSoalKuis(bankSoal: bank, jumlahSoal: 2, benih: 42);
      final hasilAcak2 = pilihDanAcakSoalKuis(bankSoal: bank, jumlahSoal: 2, benih: 42);

      expect(hasilAcak1.length, equals(2));
      expect(hasilAcak1.first.id, equals(hasilAcak2.first.id));
      expect(hasilAcak1.first.pilihan, equals(hasilAcak2.first.pilihan));
      expect(hasilAcak1.first.benar, equals(hasilAcak2.first.benar));
      // Jawaban benar tetap menunjuk teks yang benar meskipun pilihan diacak
      final teksAsliBenar = bank.firstWhere((s) => s.id == hasilAcak1.first.id).pilihan[bank.firstWhere((s) => s.id == hasilAcak1.first.id).benar];
      expect(hasilAcak1.first.pilihan[hasilAcak1.first.benar], equals(teksAsliBenar));
    });

    test('Metode sisa terbesar hitungKomposisiSifat selalu menghasilkan total tepat 100', () {
      // Kasus desimal berulang: 100 / 3
      final hasil1 = hitungKomposisiSifat({
        'kebutuhan': 100000,
        'keinginan': 100000,
        'tabungan': 100000,
      });
      final total1 = hasil1.values.fold<int>(0, (a, b) => a + b);
      expect(total1, equals(100));

      // Kasus angka nyata
      final hasil2 = hitungKomposisiSifat({
        'kebutuhan': 3540000,
        'keinginan': 1420000,
        'tabungan': 500000,
        'utang': 750000,
        'belum_dilabeli': 120000,
      });
      final total2 = hasil2.values.fold<int>(0, (a, b) => a + b);
      expect(total2, equals(100));

      // Kasus pengeluaran 0
      final hasilKosong = hitungKomposisiSifat({});
      expect(hasilKosong['kebutuhan'], equals(0));
      final totalKosong = hasilKosong.values.fold<int>(0, (a, b) => a + b);
      expect(totalKosong, equals(0));
    });

    test('Peta objek ke rute pengisian lengkap dan benar', () {
      expect(ambilRutePengisianObjek('dompet'), equals('/dompet'));
      expect(ambilRutePengisianObjek('pemasukan'), equals('/catatan'));
      expect(ambilRutePengisianObjek('pengeluaran'), equals('/catatan'));
      expect(ambilRutePengisianObjek('transaksi'), equals('/catatan'));
      expect(ambilRutePengisianObjek('anggaran'), equals('/anggaran'));
      expect(ambilRutePengisianObjek('tujuan'), equals('/tujuan'));
      expect(ambilRutePengisianObjek('utang'), equals('/utang'));
      expect(ambilRutePengisianObjek('kategori'), equals('/kategori'));
      expect(ambilRutePengisianObjek('lainnya'), isNull);
    });

    test('Evaluasi syarat: ada_data (terpenuhi, belum, batas tepi)', () {
      final fotoData = FotoDataPengguna(
        jumlahDompetAktif: 2,
        jumlahPemasukan: 1,
        jumlahPengeluaran: 5,
        jumlahAnggaran: 1,
        jumlahTujuanAktif: 1,
        jumlahUtangAktif: 0,
        kategoriKeluarTerpakai: const {'kat_makan': 'kebutuhan'},
        hariTransaksiBerbeda: 4,
        bulanTransaksiBerbeda: 2,
        pernyataan: const {},
        progresPelajaran: const {},
        hasilKuisTerbaik: const {},
      );

      final syaratDompet = SyaratGerbangData(
        tipe: 'ada_data',
        objek: 'dompet',
        min: 1,
        pesan: 'Buat dompet dulu',
      );
      final hasil1 = evaluasiSyarat(syaratDompet, fotoData);
      expect(hasil1.terpenuhi, isTrue);

      final syaratUtang = SyaratGerbangData(
        tipe: 'ada_data',
        objek: 'utang',
        min: 1,
        pesan: 'Catat utang dulu',
      );
      final hasil2 = evaluasiSyarat(syaratUtang, fotoData);
      expect(hasil2.terpenuhi, isFalse);
      expect(hasil2.rutePengisian, equals('/utang'));
    });

    test('Evaluasi syarat: aturan_data semua_kategori_berlabel', () {
      final fotoBelum = FotoDataPengguna.kosong().copyWith(
        kategoriKeluarTerpakai: {
          'k1': 'kebutuhan',
          'k2': 'belum_dilabeli',
        },
      );
      final syaratAturan = SyaratGerbangData(
        tipe: 'aturan_data',
        aturan: 'semua_kategori_berlabel',
        pesan: 'Beri label kategorimu',
      );
      expect(evaluasiSyarat(syaratAturan, fotoBelum).terpenuhi, isFalse);

      final fotoSudah = FotoDataPengguna.kosong().copyWith(
        kategoriKeluarTerpakai: {
          'k1': 'kebutuhan',
          'k2': 'keinginan',
        },
      );
      expect(evaluasiSyarat(syaratAturan, fotoSudah).terpenuhi, isTrue);
    });

    test('Evaluasi syarat: periode_data (hari_berbeda dan bulan_berbeda)', () {
      final fotoData = FotoDataPengguna.kosong().copyWith(
        hariTransaksiBerbeda: 7,
        bulanTransaksiBerbeda: 1,
      );

      final syaratHari = SyaratGerbangData(
        tipe: 'periode_data',
        satuan: 'hari_berbeda',
        min: 7,
        pesan: 'Catat transaksi selama 7 hari berbeda',
      );
      expect(evaluasiSyarat(syaratHari, fotoData).terpenuhi, isTrue);

      final syaratBulan = SyaratGerbangData(
        tipe: 'periode_data',
        satuan: 'bulan_berbeda',
        min: 3,
        pesan: 'Catat transaksi selama 3 bulan berbeda',
      );
      expect(evaluasiSyarat(syaratBulan, fotoData).terpenuhi, isFalse);
    });

    test('Evaluasi syarat: logika ATAU dengan pernyataan (dan dicabut)', () {
      final fotoAwal = FotoDataPengguna.kosong().copyWith(
        jumlahUtangAktif: 0,
      );

      final syaratUtang = SyaratGerbangData(
        tipe: 'ada_data',
        objek: 'utang',
        min: 1,
        pesan: 'Catat utang atau nyatakan tidak punya',
        atauPernyataan: 'tidak_punya_utang',
      );

      // 1. Belum ada utang dan belum menyatakan -> belum terpenuhi
      expect(evaluasiSyarat(syaratUtang, fotoAwal).terpenuhi, isFalse);

      // 2. Pengguna menyatakan "tidak punya utang" -> terpenuhi!
      final fotoNyatakan = fotoAwal.copyWith(
        pernyataan: {'tidak_punya_utang': 'true'},
      );
      expect(evaluasiSyarat(syaratUtang, fotoNyatakan).terpenuhi, isTrue);

      // 3. Pernyataan dicabut (nilai 'false' atau hilang) -> kembali belum terpenuhi
      final fotoCabut = fotoAwal.copyWith(
        pernyataan: {'tidak_punya_utang': 'false'},
      );
      expect(evaluasiSyarat(syaratUtang, fotoCabut).terpenuhi, isFalse);
    });

    test('Status Pelajaran: Pelajaran yang sudah selesai TIDAK PERNAH terkunci ulang', () {
      final fotoDataKosong = FotoDataPengguna.kosong().copyWith(
        progresPelajaran: {'anggaran_arus_kas_1_2': 'selesai'},
      );

      final pelajaran = PelajaranKonten(
        id: 'anggaran_arus_kas_1_2',
        modulId: 'anggaran_arus_kas',
        judul: 'Memetakan Arus Kas',
        durasiMenit: 4,
        status: 'draf',
        gerbang: [
          SyaratGerbangData(
            tipe: 'ada_data',
            objek: 'dompet',
            min: 5, // Syarat tinggi yang tidak terpenuhi oleh data kosong
            pesan: 'Butuh 5 dompet',
          ),
        ],
        pemantik: 'Pemantik',
        kartu: const [],
        contohAngka: 500000,
        cekPaham: const [],
        misi: MisiKonten(tipe: 'ada_data', objek: 'pemasukan', min: 1, judul: 'Misi', deskripsi: 'Desc', perkiraanMenit: 2),
      );

      final status = tentukanStatusPelajaran(
        pelajaran: pelajaran,
        posisiIndeks: 0,
        daftarPelajaranModul: [pelajaran],
        gerbangModul: const [],
        fotoData: fotoDataKosong,
      );

      expect(status.status, equals(StatusBelajar.selesai));
      expect(status.apaYangKurang, isEmpty);
    });

    test('Status Pelajaran: Pelajaran ke-2 baru terbuka bila pelajaran ke-1 selesai', () {
      final p1 = PelajaranKonten(
        id: 'p_1',
        modulId: 'm_1',
        judul: 'Pelajaran 1',
        durasiMenit: 4,
        status: 'draf',
        gerbang: const [],
        pemantik: '',
        kartu: const [],
        contohAngka: 0,
        cekPaham: const [],
        misi: MisiKonten(tipe: 'ada_data', objek: 'pemasukan', min: 1, judul: '', deskripsi: '', perkiraanMenit: 1),
      );
      final p2 = PelajaranKonten(
        id: 'p_2',
        modulId: 'm_1',
        judul: 'Pelajaran 2',
        durasiMenit: 4,
        status: 'draf',
        gerbang: const [],
        pemantik: '',
        kartu: const [],
        contohAngka: 0,
        cekPaham: const [],
        misi: MisiKonten(tipe: 'ada_data', objek: 'pengeluaran', min: 1, judul: '', deskripsi: '', perkiraanMenit: 1),
      );

      final daftar = [p1, p2];

      // Saat p1 belum selesai -> p2 terkunci
      final statusP2Awal = tentukanStatusPelajaran(
        pelajaran: p2,
        posisiIndeks: 1,
        daftarPelajaranModul: daftar,
        gerbangModul: const [],
        fotoData: FotoDataPengguna.kosong(),
      );
      expect(statusP2Awal.status, equals(StatusBelajar.terkunci));
      expect(statusP2Awal.apaYangKurang.first, contains('Selesaikan pelajaran sebelumnya'));

      // Saat p1 selesai -> p2 terbuka
      final fotoP1Selesai = FotoDataPengguna.kosong().copyWith(
        progresPelajaran: {'p_1': 'selesai'},
      );
      final statusP2Buka = tentukanStatusPelajaran(
        pelajaran: p2,
        posisiIndeks: 1,
        daftarPelajaranModul: daftar,
        gerbangModul: const [],
        fotoData: fotoP1Selesai,
      );
      expect(statusP2Buka.status, equals(StatusBelajar.terbuka));
    });

    test('Status Modul: Modul selesai hanya jika semua pelajaran selesai dan kuis lulus', () {
      final modul = ModulKonten(
        id: 'modul_uji',
        judul: 'Modul Uji',
        tingkat: 'pemula',
        urutan: 1,
        deskripsiSingkat: 'Desc',
        tersedia: true,
        gerbang: const [],
        daftarPelajaran: ['p1', 'p2'],
        kuis: KuisKonten(jumlahSoal: 2, bankSoal: const []),
      );

      // Pelajaran selesai tapi kuis belum lulus -> status sedang
      final fotoBelumKuis = FotoDataPengguna.kosong().copyWith(
        progresPelajaran: {'p1': 'selesai', 'p2': 'selesai'},
      );
      final status1 = tentukanStatusModul(modul: modul, fotoData: fotoBelumKuis);
      expect(status1.status, equals(StatusBelajar.sedang));
      expect(status1.apaYangKurang, contains('Lulus kuis akhir modul'));

      // Pelajaran selesai dan kuis lulus -> status selesai!
      final fotoLulusKuis = fotoBelumKuis.copyWith(
        hasilKuisTerbaik: {'modul_uji': const HasilKuisSnapshot(skorPersen: 80, lulus: true)},
      );
      final status2 = tentukanStatusModul(modul: modul, fotoData: fotoLulusKuis);
      expect(status2.status, equals(StatusBelajar.selesai));
    });
  });
}
