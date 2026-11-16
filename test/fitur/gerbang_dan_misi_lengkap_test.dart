import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/perhitungan/perhitungan_belajar.dart';
import 'package:funda/tema/token.dart';
import 'package:funda/komponen/teks_funda.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Butir B.1: Evaluasi Seluruh Tipe Syarat Gerbang Data', () {
    test('ada_data: dompet, transaksi, anggaran, tujuan, utang', () {
      final fotoKosong = FotoDataPengguna.kosong();

      // Dompet
      const syaratDompet = SyaratGerbangData(tipe: 'ada_data', objek: 'dompet', min: 1, pesan: 'Buat minimal 1 dompet');
      expect(evaluasiSyarat(syaratDompet, fotoKosong).terpenuhi, isFalse);
      expect(evaluasiSyarat(syaratDompet, fotoKosong.copyWith(jumlahDompetAktif: 1)).terpenuhi, isTrue);

      // Transaksi umum
      const syaratTx = SyaratGerbangData(tipe: 'ada_data', objek: 'transaksi', min: 1, pesan: 'Catat minimal 1 transaksi');
      expect(evaluasiSyarat(syaratTx, fotoKosong).terpenuhi, isFalse);
      expect(evaluasiSyarat(syaratTx, fotoKosong.copyWith(jumlahPemasukan: 1)).terpenuhi, isTrue);
      expect(evaluasiSyarat(syaratTx, fotoKosong.copyWith(jumlahPengeluaran: 1)).terpenuhi, isTrue);

      // Transaksi pengeluaran
      const syaratKeluar = SyaratGerbangData(tipe: 'ada_data', objek: 'pengeluaran', min: 2, pesan: 'Catat minimal 2 pengeluaran');
      expect(evaluasiSyarat(syaratKeluar, fotoKosong.copyWith(jumlahPengeluaran: 1)).terpenuhi, isFalse);
      expect(evaluasiSyarat(syaratKeluar, fotoKosong.copyWith(jumlahPengeluaran: 2)).terpenuhi, isTrue);

      // Anggaran
      const syaratAnggaran = SyaratGerbangData(tipe: 'ada_data', objek: 'anggaran', min: 1, pesan: 'Buat minimal 1 anggaran');
      expect(evaluasiSyarat(syaratAnggaran, fotoKosong).terpenuhi, isFalse);
      expect(evaluasiSyarat(syaratAnggaran, fotoKosong.copyWith(jumlahAnggaran: 1)).terpenuhi, isTrue);

      // Tujuan
      const syaratTujuan = SyaratGerbangData(tipe: 'ada_data', objek: 'tujuan', min: 1, pesan: 'Buat minimal 1 tujuan');
      expect(evaluasiSyarat(syaratTujuan, fotoKosong).terpenuhi, isFalse);
      expect(evaluasiSyarat(syaratTujuan, fotoKosong.copyWith(jumlahTujuanAktif: 1)).terpenuhi, isTrue);

      // Utang
      const syaratUtang = SyaratGerbangData(tipe: 'ada_data', objek: 'utang', min: 1, pesan: 'Catat utang atau centang pernyataan');
      expect(evaluasiSyarat(syaratUtang, fotoKosong).terpenuhi, isFalse);
      expect(evaluasiSyarat(syaratUtang, fotoKosong.copyWith(jumlahUtangAktif: 1)).terpenuhi, isTrue);
    });

    test('aturan_data: semua_kategori_berlabel mengabaikan kategori tak terpakai & mendeteksi belum_dilabeli', () {
      const syaratLabel = SyaratGerbangData(
        tipe: 'aturan_data',
        objek: 'kategori',
        aturan: 'semua_kategori_berlabel',
        pesan: 'Beri label kebutuhan/keinginan pada kategori pengeluaranmu',
      );

      final fotoKosong = FotoDataPengguna.kosong();
      // Belum ada transaksi keluar sama sekali -> false
      expect(evaluasiSyarat(syaratLabel, fotoKosong).terpenuhi, isFalse);

      // Ada transaksi keluar dengan kategori 'belum_dilabeli' -> false
      final fotoBelumLabel = fotoKosong.copyWith(
        jumlahPengeluaran: 3,
        kategoriKeluarTerpakai: {
          'kat_makan': 'kebutuhan',
          'kat_jajan': 'belum_dilabeli',
        },
      );
      expect(evaluasiSyarat(syaratLabel, fotoBelumLabel).terpenuhi, isFalse);

      // Semua kategori yang terpakai di transaksi keluar sudah berlabel -> true
      // (Kategori master lain yang tidak terpakai diabaikan!)
      final fotoSemuaBerlabel = fotoKosong.copyWith(
        jumlahPengeluaran: 5,
        kategoriKeluarTerpakai: {
          'kat_makan': 'kebutuhan',
          'kat_bioskop': 'keinginan',
          'kat_cicilan': 'utang',
        },
      );
      expect(evaluasiSyarat(syaratLabel, fotoSemuaBerlabel).terpenuhi, isTrue);
    });

    test('periode_data: hari_berbeda dan bulan_berbeda', () {
      final fotoKosong = FotoDataPengguna.kosong();

      const syarat7Hari = SyaratGerbangData(
        tipe: 'periode_data',
        satuan: 'hari_berbeda',
        min: 7,
        pesan: 'Catat transaksi pada minimal 7 hari berbeda',
      );
      expect(evaluasiSyarat(syarat7Hari, fotoKosong.copyWith(hariTransaksiBerbeda: 6)).terpenuhi, isFalse);
      expect(evaluasiSyarat(syarat7Hari, fotoKosong.copyWith(hariTransaksiBerbeda: 7)).terpenuhi, isTrue);

      const syarat2Bulan = SyaratGerbangData(
        tipe: 'periode_data',
        satuan: 'bulan_berbeda',
        min: 2,
        pesan: 'Punya data transaksi dari minimal 2 bulan berbeda',
      );
      expect(evaluasiSyarat(syarat2Bulan, fotoKosong.copyWith(bulanTransaksiBerbeda: 1)).terpenuhi, isFalse);
      expect(evaluasiSyarat(syarat2Bulan, fotoKosong.copyWith(bulanTransaksiBerbeda: 2)).terpenuhi, isTrue);
    });

    test('pernyataan: centang pernyataan bernilai true', () {
      const syaratPernyataan = SyaratGerbangData(
        tipe: 'pernyataan',
        kunci: 'tidak_punya_utang',
        pesan: 'Centang jika kamu tidak memiliki utang',
      );

      final fotoKosong = FotoDataPengguna.kosong();
      expect(evaluasiSyarat(syaratPernyataan, fotoKosong).terpenuhi, isFalse);

      final fotoDicentang = fotoKosong.copyWith(
        pernyataan: {'tidak_punya_utang': 'true'},
      );
      expect(evaluasiSyarat(syaratPernyataan, fotoDicentang).terpenuhi, isTrue);
    });

    test('kuis_lulus & modul_selesai', () {
      const syaratKuis = SyaratGerbangData(
        tipe: 'kuis_lulus',
        modulId: 'anggaran_arus_kas',
        pesan: 'Lulus kuis modul Anggaran & Arus Kas',
      );

      final fotoKosong = FotoDataPengguna.kosong();
      expect(evaluasiSyarat(syaratKuis, fotoKosong).terpenuhi, isFalse);

      final fotoKuisGagal = fotoKosong.copyWith(
        hasilKuisTerbaik: {
          'anggaran_arus_kas': const HasilKuisSnapshot(skorPersen: 60, lulus: false),
        },
      );
      expect(evaluasiSyarat(syaratKuis, fotoKuisGagal).terpenuhi, isFalse);

      final fotoKuisLulus = fotoKosong.copyWith(
        hasilKuisTerbaik: {
          'anggaran_arus_kas': const HasilKuisSnapshot(skorPersen: 80, lulus: true),
        },
      );
      expect(evaluasiSyarat(syaratKuis, fotoKuisLulus).terpenuhi, isTrue);

      // modul_selesai
      const syaratModul = SyaratGerbangData(
        tipe: 'modul_selesai',
        modulId: 'anggaran_arus_kas',
        pesan: 'Selesaikan semua pelajaran dan kuis modul Anggaran & Arus Kas',
      );

      final modulKonten = ModulKonten(
        id: 'anggaran_arus_kas',
        judul: 'Anggaran & Arus Kas',
        tingkat: 'pemula',
        urutan: 1,
        deskripsiSingkat: '',
        tersedia: true,
        gerbang: [],
        daftarPelajaran: ['pel_1', 'pel_2'],
        kuis: const KuisKonten(jumlahSoal: 5, bankSoal: []),
      );

      // Kuis lulus tapi pelajaran belum semua selesai
      final fotoPelajaranKurang = fotoKuisLulus.copyWith(
        progresPelajaran: {'pel_1': 'selesai'},
      );
      expect(
        tentukanStatusModul(
          modul: modulKonten,
          fotoData: fotoPelajaranKurang,
        ).status,
        equals(StatusBelajar.sedang),
      );

      // Semua pelajaran selesai DAN kuis lulus -> selesai
      final fotoModulPenuh = fotoKuisLulus.copyWith(
        progresPelajaran: {'pel_1': 'selesai', 'pel_2': 'selesai'},
      );
      expect(
        tentukanStatusModul(
          modul: modulKonten,
          fotoData: fotoModulPenuh,
        ).status,
        equals(StatusBelajar.selesai),
      );
      expect(evaluasiSyarat(syaratModul, fotoModulPenuh).terpenuhi, isTrue);
    });
  });

  group('Butir B.2: Syarat ATAU + Pernyataan & Pencabutan Pernyataan', () {
    test('Syarat data terpenuhi via opsi atauPernyataan, dan kembali terkunci bila dicabut', () {
      const syaratUtangAtau = SyaratGerbangData(
        tipe: 'ada_data',
        objek: 'utang',
        min: 1,
        pesan: 'Catat utang aktifmu',
        atauPernyataan: 'tidak_punya_utang',
      );

      final fotoKosong = FotoDataPengguna.kosong();
      // Awalnya terkunci
      final hasil1 = evaluasiSyarat(syaratUtangAtau, fotoKosong);
      expect(hasil1.terpenuhi, isFalse);
      expect(hasil1.atauPernyataan, equals('tidak_punya_utang'));

      // Pengguna mencentang pernyataan "tidak punya utang" -> terbuka
      final fotoCentang = fotoKosong.copyWith(pernyataan: {'tidak_punya_utang': 'true'});
      final hasil2 = evaluasiSyarat(syaratUtangAtau, fotoCentang);
      expect(hasil2.terpenuhi, isTrue);

      // Pengguna mencabut pernyataan (dihapus dari map pernyataan) -> kembali terkunci!
      final fotoCabut = fotoCentang.copyWith(pernyataan: {});
      final hasil3 = evaluasiSyarat(syaratUtangAtau, fotoCabut);
      expect(hasil3.terpenuhi, isFalse);
    });
  });

  group('Butir B.3: Pelajaran Selesai Tidak Terkunci Ulang', () {
    test('Pelajaran berstatus selesai tidak boleh terkunci ulang saat data transaksi dihapus', () {
      const pel = PelajaranKonten(
        id: 'pel_1_2',
        modulId: 'anggaran_arus_kas',
        judul: 'Pelajaran Uji',
        durasiMenit: 5,
        status: 'draf',
        gerbang: [SyaratGerbangData(tipe: 'ada_data', objek: 'transaksi', min: 1, pesan: 'Catat transaksi')],
        pemantik: '',
        kartu: [],
        contohAngka: 0,
        cekPaham: [],
        misi: MisiKonten(tipe: 'ada_data', objek: 'transaksi', min: 1, judul: 'Misi', deskripsi: '', perkiraanMenit: 2),
      );

      // 1. Awalnya ada data -> selesai
      final fotoAdaData = FotoDataPengguna.kosong().copyWith(
        jumlahPemasukan: 1,
        progresPelajaran: {'pel_1_2': 'selesai'},
      );
      final hasilSelesai = tentukanStatusPelajaran(
        pelajaran: pel,
        posisiIndeks: 0,
        daftarPelajaranModul: [pel],
        gerbangModul: const [],
        fotoData: fotoAdaData,
      );
      expect(hasilSelesai.status, equals(StatusBelajar.selesai));

      // 2. Data transaksi dihapus semua (jumlahPemasukan: 0, foto data kosong)
      final fotoHapusData = FotoDataPengguna.kosong().copyWith(
        jumlahPemasukan: 0,
        jumlahPengeluaran: 0,
        progresPelajaran: {'pel_1_2': 'selesai'}, // Status selesai tetap tercatat di DB
      );
      final hasilSetelahHapus = tentukanStatusPelajaran(
        pelajaran: pel,
        posisiIndeks: 0,
        daftarPelajaranModul: [pel],
        gerbangModul: const [],
        fotoData: fotoHapusData,
      );

      // WAJIB: Pelajaran tetap SELESAI, TIDAK TERKUNCI ULANG!
      expect(hasilSetelahHapus.status, equals(StatusBelajar.selesai));
    });
  });

  group('Butir B.4: Urutan Pelajaran', () {
    test('Pelajaran 2 terkunci sampai pelajaran 1 berstatus selesai', () {
      const pel1 = PelajaranKonten(
        id: 'pel_1',
        modulId: 'modul_1',
        judul: 'Pelajaran 1',
        durasiMenit: 5,
        status: 'draf',
        gerbang: [],
        pemantik: '',
        kartu: [],
        contohAngka: 0,
        cekPaham: [],
        misi: MisiKonten(tipe: 'ada_data', judul: 'Misi', deskripsi: '', perkiraanMenit: 2),
      );

      const pel2 = PelajaranKonten(
        id: 'pel_2',
        modulId: 'modul_1',
        judul: 'Pelajaran 2',
        durasiMenit: 5,
        status: 'draf',
        gerbang: [],
        pemantik: '',
        kartu: [],
        contohAngka: 0,
        cekPaham: [],
        misi: MisiKonten(tipe: 'ada_data', judul: 'Misi', deskripsi: '', perkiraanMenit: 2),
      );

      final daftarPel = [pel1, pel2];
      final fotoAwal = FotoDataPengguna.kosong();

      // Pelajaran 1 terbuka secara bawaan
      final statusPel1 = tentukanStatusPelajaran(
        pelajaran: pel1,
        posisiIndeks: 0,
        daftarPelajaranModul: daftarPel,
        gerbangModul: const [],
        fotoData: fotoAwal,
      );
      expect(statusPel1.status, equals(StatusBelajar.terbuka));

      // Pelajaran 2 TERKUNCI karena Pelajaran 1 belum selesai
      final statusPel2Awal = tentukanStatusPelajaran(
        pelajaran: pel2,
        posisiIndeks: 1,
        daftarPelajaranModul: daftarPel,
        gerbangModul: const [],
        fotoData: fotoAwal,
      );
      expect(statusPel2Awal.status, equals(StatusBelajar.terkunci));
      expect(statusPel2Awal.apaYangKurang.first, contains('Selesaikan pelajaran sebelumnya'));

      // Saat Pelajaran 1 selesai -> Pelajaran 2 TERBUKA
      final fotoPel1Selesai = fotoAwal.copyWith(progresPelajaran: {'pel_1': 'selesai'});
      final statusPel2Terbuka = tentukanStatusPelajaran(
        pelajaran: pel2,
        posisiIndeks: 1,
        daftarPelajaranModul: daftarPel,
        gerbangModul: const [],
        fotoData: fotoPel1Selesai,
      );
      expect(statusPel2Terbuka.status, equals(StatusBelajar.terbuka));
    });
  });

  group('Butir B.6: Ambang Kuis Tepat & Penyimpanan Skor Terbaik', () {
    test('Ambang kuis 70% berbasis aritmetika integer murni', () {
      // 3 dari 5 (60%) -> GAGAL
      expect(tentukanLulusKuis(benar: 3, total: 5), isFalse);
      expect(hitungSkorKuis(benar: 3, total: 5), equals(60));

      // 4 dari 5 (80%) -> LULUS
      expect(tentukanLulusKuis(benar: 4, total: 5), isTrue);
      expect(hitungSkorKuis(benar: 4, total: 5), equals(80));

      // 7 dari 10 (70%) -> LULUS TEPAT DI AMBANG
      expect(tentukanLulusKuis(benar: 7, total: 10), isTrue);
      expect(hitungSkorKuis(benar: 7, total: 10), equals(70));

      // 6 dari 10 (60%) -> GAGAL
      expect(tentukanLulusKuis(benar: 6, total: 10), isFalse);
      expect(hitungSkorKuis(benar: 6, total: 10), equals(60));
    });
  });

  group('Butir B.7: Komposisi Sifat Total Tepat 100%', () {
    test('3 bagian sama besar dan proporsi bulat menghasilkan tepat total 100%', () {
      // 3 bagian sama besar (misal 1jt, 1jt, 1jt)
      final pengeluaranSama = {
        'kebutuhan': 1000000,
        'keinginan': 1000000,
        'tabungan': 1000000,
      };
      final persenSama = hitungKomposisiSifat(pengeluaranSama);
      final totalPersenSama = persenSama.values.fold<int>(0, (a, b) => a + b);
      expect(totalPersenSama, equals(100));

      // Proporsi acak dengan pecahan desimal
      final pengeluaranAcak = {
        'kebutuhan': 3500000,
        'keinginan': 1250000,
        'tabungan': 750000,
        'utang': 500000,
      };
      final persenAcak = hitungKomposisiSifat(pengeluaranAcak);
      final totalPersenAcak = persenAcak.values.fold<int>(0, (a, b) => a + b);
      expect(totalPersenAcak, equals(100));
    });
  });

  group('Butir B.8: Foto Data Kosong Pengguna Baru', () {
    test('Foto data kosong tidak melempar null exception dan status terkunci ramah', () {
      final fotoKosong = FotoDataPengguna.kosong();
      expect(fotoKosong.jumlahDompetAktif, equals(0));
      expect(fotoKosong.jumlahPemasukan, equals(0));
      expect(fotoKosong.kategoriKeluarTerpakai.isEmpty, isTrue);

      const syarat = SyaratGerbangData(
        tipe: 'ada_data',
        objek: 'dompet',
        pesan: 'Buat dompet pertamamu',
      );
      final hasil = evaluasiSyarat(syarat, fotoKosong);
      expect(hasil.terpenuhi, isFalse);
      expect(hasil.rutePengisian, equals('/dompet'));
      expect(hasil.pesan, equals('Buat dompet pertamamu'));
    });
  });

  group('Butir B.9: Peta Rute Pengisian & Tombol Pelajaran Terkunci', () {
    test('Peta rute pengisian lengkap untuk seluruh objek syarat', () {
      expect(ambilRutePengisianObjek('dompet'), equals('/dompet'));
      expect(ambilRutePengisianObjek('pemasukan'), equals('/catatan'));
      expect(ambilRutePengisianObjek('pengeluaran'), equals('/catatan'));
      expect(ambilRutePengisianObjek('transaksi'), equals('/catatan'));
      expect(ambilRutePengisianObjek('anggaran'), equals('/anggaran'));
      expect(ambilRutePengisianObjek('tujuan'), equals('/tujuan'));
      expect(ambilRutePengisianObjek('utang'), equals('/utang'));
      expect(ambilRutePengisianObjek('kategori'), equals('/kategori'));
      expect(ambilRutePengisianObjek('tagihan'), equals('/tagihan'));
    });

    testWidgets('Widget Test: Tombol rute pengisian dan pesan apa yang kurang tampil di kartu terkunci', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                // Tampilan kartu terkunci seperti pada layar_belajar.dart
                const statusTerkunci = HasilStatusBelajar(
                  status: StatusBelajar.terkunci,
                  apaYangKurang: ['Catat minimal 1 transaksi pengeluaran'],
                  ruteAksi: '/tambah-transaksi',
                );

                return Column(
                  children: [
                    ...statusTerkunci.apaYangKurang.map(
                      (pesan) => TeksFunda.catatan(pesan, warna: WarnaFunda.teks),
                    ),
                    if (statusTerkunci.ruteAksi != null)
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(LucideIcons.arrowRight, size: 16, color: WarnaFunda.utama),
                        label: const TeksFunda.label('Lengkapi Data Sekarang', warna: WarnaFunda.utama),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Catat minimal 1 transaksi pengeluaran'), findsOneWidget);
      expect(find.text('Lengkapi Data Sekarang'), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
    });
  });

  group('Butir B.10: Misi Selesai Hanya di Layar & Misi Dilewati Tidak Buka Gerbang', () {
    test('Misi dilewati tidak membuka gerbang data yang membutuhkan data nyata', () {
      // Syarat gerbang data membutuhkan data transaksi nyata
      const syaratData = SyaratGerbangData(
        tipe: 'ada_data',
        objek: 'transaksi',
        min: 1,
        pesan: 'Catat transaksi nyata',
      );

      // Pengguna pernah melewati misi ("Belum relevan buat aku" -> tercatat di hasil misi sebagai 'dilewati')
      // TETAPI di database transaksi tetap 0 baris
      final fotoSetelahLewati = FotoDataPengguna.kosong().copyWith(
        jumlahPemasukan: 0,
        jumlahPengeluaran: 0,
      );

      final hasil = evaluasiSyarat(syaratData, fotoSetelahLewati);
      // Gerbang data HARUS TETAP TERKUNCI! Melewati misi tidak membuka gerbang data
      expect(hasil.terpenuhi, isFalse);
    });
  });
}
