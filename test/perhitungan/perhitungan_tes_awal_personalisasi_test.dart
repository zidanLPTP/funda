import 'package:flutter_test/flutter_test.dart';
import 'package:funda/fitur/belajar/model/pembaca_konten.dart';
import 'package:funda/perhitungan/perhitungan_belajar.dart';
import 'package:funda/perhitungan/perhitungan_tes_awal_personalisasi.dart';

void main() {
  group('1. Pengujian Fungsi Murni hitungSkorTesAwal', () {
    final daftar12Soal = [
      const SoalTesAwalKonten(
        id: 's1',
        modulId: 'anggaran_arus_kas',
        tanya: 'T1',
        pilihan: ['A', 'B', 'C', 'Belum tahu, nggak apa-apa'],
        benar: 1,
        penjelasan: 'P',
      ),
      const SoalTesAwalKonten(
        id: 's2',
        modulId: 'anggaran_arus_kas',
        tanya: 'T2',
        pilihan: ['A', 'B', 'C', 'Belum tahu, nggak apa-apa'],
        benar: 0,
        penjelasan: 'P',
      ),
      const SoalTesAwalKonten(
        id: 's3',
        modulId: 'tabungan',
        tanya: 'T3',
        pilihan: ['A', 'B', 'C', 'Belum tahu, nggak apa-apa'],
        benar: 1,
        penjelasan: 'P',
      ),
      const SoalTesAwalKonten(
        id: 's4',
        modulId: 'tabungan',
        tanya: 'T4',
        pilihan: ['A', 'B', 'C', 'Belum tahu, nggak apa-apa'],
        benar: 0,
        penjelasan: 'P',
      ),
      const SoalTesAwalKonten(
        id: 's5',
        modulId: 'dana_darurat',
        tanya: 'T5',
        pilihan: ['A', 'B', 'C', 'Belum tahu, nggak apa-apa'],
        benar: 1,
        penjelasan: 'P',
      ),
      const SoalTesAwalKonten(
        id: 's6',
        modulId: 'dana_darurat',
        tanya: 'T6',
        pilihan: ['A', 'B', 'C', 'Belum tahu, nggak apa-apa'],
        benar: 1,
        penjelasan: 'P',
      ),
      const SoalTesAwalKonten(
        id: 's7',
        modulId: 'utang_cicilan',
        tanya: 'T7',
        pilihan: ['A', 'B', 'C', 'Belum tahu, nggak apa-apa'],
        benar: 0,
        penjelasan: 'P',
      ),
      const SoalTesAwalKonten(
        id: 's8',
        modulId: 'utang_cicilan',
        tanya: 'T8',
        pilihan: ['A', 'B', 'C', 'Belum tahu, nggak apa-apa'],
        benar: 1,
        penjelasan: 'P',
      ),
      const SoalTesAwalKonten(
        id: 's9',
        modulId: 'waspada_penipuan',
        tanya: 'T9',
        pilihan: ['A', 'B', 'C', 'Belum tahu, nggak apa-apa'],
        benar: 0,
        penjelasan: 'P',
      ),
      const SoalTesAwalKonten(
        id: 's10',
        modulId: 'waspada_penipuan',
        tanya: 'T10',
        pilihan: ['A', 'B', 'C', 'Belum tahu, nggak apa-apa'],
        benar: 1,
        penjelasan: 'P',
      ),
      const SoalTesAwalKonten(
        id: 's11',
        modulId: 'psikologi_uang',
        tanya: 'T11',
        pilihan: ['A', 'B', 'C', 'Belum tahu, nggak apa-apa'],
        benar: 1,
        penjelasan: 'P',
      ),
      const SoalTesAwalKonten(
        id: 's12',
        modulId: 'psikologi_uang',
        tanya: 'T12',
        pilihan: ['A', 'B', 'C', 'Belum tahu, nggak apa-apa'],
        benar: 0,
        penjelasan: 'P',
      ),
    ];

    test(
      'Semua jawaban benar menghasilkan skor 100% di semua modul dan skor total 100%',
      () {
        final jawaban = {
          's1': 1,
          's2': 0,
          's3': 1,
          's4': 0,
          's5': 1,
          's6': 1,
          's7': 0,
          's8': 1,
          's9': 0,
          's10': 1,
          's11': 1,
          's12': 0,
        };

        final hasil = hitungSkorTesAwal(
          jawabanPengguna: jawaban,
          daftarSoal: daftar12Soal,
        );
        expect(hasil.totalBenar, equals(12));
        expect(hasil.totalSoal, equals(12));
        expect(hasil.skorTotalPersen, equals(100));
        for (final m in [
          'anggaran_arus_kas',
          'tabungan',
          'dana_darurat',
          'utang_cicilan',
          'waspada_penipuan',
          'psikologi_uang',
        ]) {
          expect(hasil.skorPerModul[m], equals(100));
        }
      },
    );

    test(
      'Semua memilih "Belum tahu, nggak apa-apa" (indeks 3) menghasilkan skor 0%',
      () {
        final jawaban = {for (var i = 1; i <= 12; i++) 's$i': 3};

        final hasil = hitungSkorTesAwal(
          jawabanPengguna: jawaban,
          daftarSoal: daftar12Soal,
        );
        expect(hasil.totalBenar, equals(0));
        expect(hasil.totalSoal, equals(12));
        expect(hasil.skorTotalPersen, equals(0));
        for (final m in [
          'anggaran_arus_kas',
          'tabungan',
          'dana_darurat',
          'utang_cicilan',
          'waspada_penipuan',
          'psikologi_uang',
        ]) {
          expect(hasil.skorPerModul[m], equals(0));
        }
      },
    );

    test('Benar 1 dari 2 soal menghasilkan skor 50% untuk modul tersebut', () {
      final jawaban = {
        's1': 1,
        's2': 3,
        's3': 1,
        's4': 0,
        's5': 3,
        's6': 3,
        's7': 0,
        's8': 3,
        's9': 3,
        's10': 3,
        's11': 1,
        's12': 0,
      };
      final hasil = hitungSkorTesAwal(
        jawabanPengguna: jawaban,
        daftarSoal: daftar12Soal,
      );
      expect(hasil.totalBenar, equals(6));
      expect(hasil.skorTotalPersen, equals(50));
      expect(hasil.skorPerModul['anggaran_arus_kas'], equals(50));
      expect(hasil.skorPerModul['tabungan'], equals(100));
      expect(hasil.skorPerModul['dana_darurat'], equals(0));
    });
  });

  group('2. Pengujian Fungsi Murni bangunProfil', () {
    test('Validasi profil berhasil dengan input enum yang sah', () {
      final profil = bangunProfil(
        jawabanProfil: {
          'punya_penghasilan': 'rutin',
          'punya_utang': 'ya',
          'dana_darurat': 'sedikit',
          'menabung': 'kadang',
          'investasi': 'belum',
          'mencatat_keuangan': 'rutin',
        },
        tujuanUtama: 'Mempersiapkan dana pensiun dan beli rumah',
      );

      expect(profil.punyaPenghasilan, equals('rutin'));
      expect(profil.punyaUtang, equals('ya'));
      expect(profil.danaDarurat, equals('sedikit'));
      expect(profil.menabung, equals('kadang'));
      expect(profil.investasi, equals('belum'));
      expect(profil.mencatatKeuangan, equals('rutin'));
      expect(
        profil.tujuanUtama,
        equals('Mempersiapkan dana pensiun dan beli rumah'),
      );
    });

    test('Input tidak sah difallback ke nilai default yang aman', () {
      final profil = bangunProfil(
        jawabanProfil: {
          'punya_penghasilan': 'nilai_ngawur',
          'punya_utang': 'ngawur',
          'dana_darurat': 'ngawur',
          'menabung': 'ngawur',
          'investasi': 'ngawur',
          'mencatat_keuangan': 'ngawur',
        },
      );

      expect(profil.punyaPenghasilan, equals('belum'));
      expect(profil.punyaUtang, equals('tidak_yakin'));
      expect(profil.danaDarurat, equals('belum'));
    });
  });

  group('3. Pengujian Fungsi Murni rekomendasiModul Sesuai Butir B.2', () {
    final daftarModulContoh = [
      const ModulKonten(
        id: 'anggaran_arus_kas',
        judul: 'Anggaran & Arus Kas',
        tingkat: 'pemula',
        urutan: 1,
        deskripsiSingkat: '',
        tersedia: true,
        gerbang: [],
        daftarPelajaran: [],
        kuis: KuisKonten(jumlahSoal: 0, bankSoal: []),
      ),
      const ModulKonten(
        id: 'tabungan',
        judul: 'Tabungan',
        tingkat: 'pemula',
        urutan: 2,
        deskripsiSingkat: '',
        tersedia: true,
        gerbang: [],
        daftarPelajaran: [],
        kuis: KuisKonten(jumlahSoal: 0, bankSoal: []),
      ),
      const ModulKonten(
        id: 'dana_darurat',
        judul: 'Dana Darurat',
        tingkat: 'pemula',
        urutan: 3,
        deskripsiSingkat: '',
        tersedia: true,
        gerbang: [],
        daftarPelajaran: [],
        kuis: KuisKonten(jumlahSoal: 0, bankSoal: []),
      ),
      const ModulKonten(
        id: 'utang_cicilan',
        judul: 'Utang & Cicilan',
        tingkat: 'pemula',
        urutan: 4,
        deskripsiSingkat: '',
        tersedia: false, // Segera hadir
        gerbang: [],
        daftarPelajaran: [],
        kuis: KuisKonten(jumlahSoal: 0, bankSoal: []),
      ),
      const ModulKonten(
        id: 'waspada_penipuan',
        judul: 'Waspada Penipuan',
        tingkat: 'pemula',
        urutan: 5,
        deskripsiSingkat: '',
        tersedia: false,
        gerbang: [],
        daftarPelajaran: [],
        kuis: KuisKonten(jumlahSoal: 0, bankSoal: []),
      ),
      const ModulKonten(
        id: 'psikologi_uang',
        judul: 'Psikologi Uang',
        tingkat: 'pemula',
        urutan: 6,
        deskripsiSingkat: '',
        tersedia: false,
        gerbang: [],
        daftarPelajaran: [],
        kuis: KuisKonten(jumlahSoal: 0, bankSoal: []),
      ),
    ];

    final statusModulStandar = {
      for (final m in daftarModulContoh)
        m.id: const HasilStatusBelajar(
          status: StatusBelajar.terbuka,
          apaYangKurang: [],
        ),
    };

    test(
      'Aturan 1: skor modul < 70 vs tepat 70 (69 memicu, 70 tidak memicu)',
      () {
        final hasilTes = const HasilSkorTesAwal(
          skorPerModul: {
            'anggaran_arus_kas': 69, // < 70 -> memicu
            'tabungan': 70, // tepat 70 -> TIDAK memicu skor_tes_rendah
          },
          skorTotalPersen: 70,
          totalBenar: 8,
          totalSoal: 12,
        );

        final hasil = rekomendasiModul(
          profil: null,
          hasilTes: hasilTes,
          fotoData: const FotoDataPengguna(
            jumlahDompetAktif: 1,
            jumlahPemasukan: 1,
            jumlahPengeluaran: 1,
            jumlahAnggaran: 1,
            jumlahTujuanAktif: 1,
            jumlahUtangAktif: 0,
            kategoriKeluarTerpakai: {},
            hariTransaksiBerbeda: 1,
            bulanTransaksiBerbeda: 1,
            pernyataan: {},
            progresPelajaran: {},
            hasilKuisTerbaik: {},
            tujuanDanaDaruratAktif: true,
            saldoTerkumpulDanaDarurat: 1000000,
            sisaUtangAktif: 0,
          ),
          daftarModul: daftarModulContoh,
          statusModul: {
            ...statusModulStandar,
            // Anggap ada 1 modul selesai agar Aturan 5 tidak campur tangan
            'waspada_penipuan': const HasilStatusBelajar(
              status: StatusBelajar.selesai,
              apaYangKurang: [],
            ),
          },
        );

        final rekAnggaran = hasil
            .where((r) => r.modulId == 'anggaran_arus_kas')
            .toList();
        final rekTabungan = hasil
            .where((r) => r.modulId == 'tabungan')
            .toList();

        expect(rekAnggaran.isNotEmpty, isTrue);
        expect(
          rekAnggaran.first.kodeAlasan.contains(alasanSkorTesRendah),
          isTrue,
        );

        // Tabungan dengan skor 70 tidak boleh memuat alasan skor_tes_rendah
        if (rekTabungan.isNotEmpty) {
          expect(
            rekTabungan.first.kodeAlasan.contains(alasanSkorTesRendah),
            isFalse,
          );
        }
      },
    );

    test(
      'Aturan 2: ada utang aktif dengan sisa > 0 memicu modul utang_cicilan dengan alasan punya_utang_tercatat',
      () {
        final hasil = rekomendasiModul(
          profil: null,
          hasilTes: null,
          fotoData: const FotoDataPengguna(
            jumlahDompetAktif: 1,
            jumlahPemasukan: 1,
            jumlahPengeluaran: 1,
            jumlahAnggaran: 1,
            jumlahTujuanAktif: 1,
            jumlahUtangAktif: 1,
            kategoriKeluarTerpakai: {},
            hariTransaksiBerbeda: 1,
            bulanTransaksiBerbeda: 1,
            pernyataan: {},
            progresPelajaran: {},
            hasilKuisTerbaik: {},
            sisaUtangAktif: 5000000, // Ada utang aktif sisa > 0
            tujuanDanaDaruratAktif: true,
            saldoTerkumpulDanaDarurat: 1000000,
          ),
          daftarModul: daftarModulContoh,
          statusModul: {
            ...statusModulStandar,
            'waspada_penipuan': const HasilStatusBelajar(
              status: StatusBelajar.selesai,
              apaYangKurang: [],
            ),
          },
        );

        final rekUtang = hasil
            .where((r) => r.modulId == 'utang_cicilan')
            .toList();
        expect(rekUtang.isNotEmpty, isTrue);
        expect(
          rekUtang.first.kodeAlasan.contains(alasanPunyaUtangTercatat),
          isTrue,
        );
      },
    );

    test(
      'Aturan 3: dana darurat kosong memicu modul dana_darurat dengan alasan dana_darurat_kosong',
      () {
        final hasil = rekomendasiModul(
          profil: null,
          hasilTes: null,
          fotoData: const FotoDataPengguna(
            jumlahDompetAktif: 1,
            jumlahPemasukan: 1,
            jumlahPengeluaran: 1,
            jumlahAnggaran: 1,
            jumlahTujuanAktif: 0,
            jumlahUtangAktif: 0,
            kategoriKeluarTerpakai: {},
            hariTransaksiBerbeda: 1,
            bulanTransaksiBerbeda: 1,
            pernyataan: {},
            progresPelajaran: {},
            hasilKuisTerbaik: {},
            tujuanDanaDaruratAktif: false, // Tidak ada tujuan darurat aktif
            saldoTerkumpulDanaDarurat: 0,
            sisaUtangAktif: 0,
          ),
          daftarModul: daftarModulContoh,
          statusModul: {
            ...statusModulStandar,
            'waspada_penipuan': const HasilStatusBelajar(
              status: StatusBelajar.selesai,
              apaYangKurang: [],
            ),
          },
        );

        final rekDarurat = hasil
            .where((r) => r.modulId == 'dana_darurat')
            .toList();
        expect(rekDarurat.isNotEmpty, isTrue);
        expect(
          rekDarurat.first.kodeAlasan.contains(alasanDanaDaruratKosong),
          isTrue,
        );
      },
    );

    test(
      'Aturan 4: keinginan terbesar secara STRIK memicu modul psikologi_uang, sedangkan seri dengan kebutuhan tidak memicu',
      () {
        // Kasus A: STRIK terbesar (keinginan 500k, kebutuhan 300k, tabungan 100k) -> Terpicu
        final hasilStrik = rekomendasiModul(
          profil: null,
          hasilTes: null,
          fotoData: const FotoDataPengguna(
            jumlahDompetAktif: 1,
            jumlahPemasukan: 1,
            jumlahPengeluaran: 1,
            jumlahAnggaran: 1,
            jumlahTujuanAktif: 1,
            jumlahUtangAktif: 0,
            kategoriKeluarTerpakai: {},
            hariTransaksiBerbeda: 1,
            bulanTransaksiBerbeda: 1,
            pernyataan: {},
            progresPelajaran: {},
            hasilKuisTerbaik: {},
            tujuanDanaDaruratAktif: true,
            saldoTerkumpulDanaDarurat: 1000000,
            sisaUtangAktif: 0,
            komposisiSifatBulanIni: {
              'keinginan': 500000,
              'kebutuhan': 300000,
              'tabungan': 100000,
            },
          ),
          daftarModul: daftarModulContoh,
          statusModul: {
            ...statusModulStandar,
            'waspada_penipuan': const HasilStatusBelajar(
              status: StatusBelajar.selesai,
              apaYangKurang: [],
            ),
          },
        );

        final rekPsikologiStrik = hasilStrik
            .where((r) => r.modulId == 'psikologi_uang')
            .toList();
        expect(rekPsikologiStrik.isNotEmpty, isTrue);
        expect(
          rekPsikologiStrik.first.kodeAlasan.contains(alasanKeinginanTerbesar),
          isTrue,
        );

        // Kasus B: Seri (keinginan 500k == kebutuhan 500k) -> TIDAK terpicu
        final hasilSeri = rekomendasiModul(
          profil: null,
          hasilTes: null,
          fotoData: const FotoDataPengguna(
            jumlahDompetAktif: 1,
            jumlahPemasukan: 1,
            jumlahPengeluaran: 1,
            jumlahAnggaran: 1,
            jumlahTujuanAktif: 1,
            jumlahUtangAktif: 0,
            kategoriKeluarTerpakai: {},
            hariTransaksiBerbeda: 1,
            bulanTransaksiBerbeda: 1,
            pernyataan: {},
            progresPelajaran: {},
            hasilKuisTerbaik: {},
            tujuanDanaDaruratAktif: true,
            saldoTerkumpulDanaDarurat: 1000000,
            sisaUtangAktif: 0,
            komposisiSifatBulanIni: {
              'keinginan': 500000,
              'kebutuhan': 500000, // Seri dengan keinginan
            },
          ),
          daftarModul: daftarModulContoh,
          statusModul: {
            ...statusModulStandar,
            'waspada_penipuan': const HasilStatusBelajar(
              status: StatusBelajar.selesai,
              apaYangKurang: [],
            ),
          },
        );

        final rekPsikologiSeri = hasilSeri
            .where((r) => r.modulId == 'psikologi_uang')
            .toList();
        expect(
          rekPsikologiSeri.isEmpty ||
              !rekPsikologiSeri.first.kodeAlasan.contains(
                alasanKeinginanTerbesar,
              ),
          isTrue,
          reason:
              'Keinginan seri dengan kebutuhan tidak boleh memicu aturan STRIK terbesar',
        );
      },
    );

    test(
      'Aturan 5: belum ada modul selesai merekomendasikan modul terbuka pertama dengan alasan belum_ada_modul_selesai',
      () {
        final hasil = rekomendasiModul(
          profil: null,
          hasilTes: null,
          fotoData: const FotoDataPengguna(
            jumlahDompetAktif: 1,
            jumlahPemasukan: 1,
            jumlahPengeluaran: 1,
            jumlahAnggaran: 1,
            jumlahTujuanAktif: 1,
            jumlahUtangAktif: 0,
            kategoriKeluarTerpakai: {},
            hariTransaksiBerbeda: 1,
            bulanTransaksiBerbeda: 1,
            pernyataan: {},
            progresPelajaran: {},
            hasilKuisTerbaik: {},
            tujuanDanaDaruratAktif: true,
            saldoTerkumpulDanaDarurat: 1000000,
            sisaUtangAktif: 0,
          ),
          daftarModul: daftarModulContoh,
          statusModul:
              statusModulStandar, // Tidak ada modul selesai sama sekali
        );

        expect(hasil.isNotEmpty, isTrue);
        final pertama = hasil.first;
        expect(pertama.modulId, equals('anggaran_arus_kas'));
        expect(pertama.kodeAlasan.contains(alasanBelumAdaModulSelesai), isTrue);
      },
    );

    test(
      'Penggabungan alasan per modul (misal skor rendah dan dana darurat kosong pada satu modul)',
      () {
        final hasilTes = const HasilSkorTesAwal(
          skorPerModul: {
            'dana_darurat': 50, // < 70 -> memicu skor_tes_rendah
          },
          skorTotalPersen: 50,
          totalBenar: 6,
          totalSoal: 12,
        );

        final hasil = rekomendasiModul(
          profil: null,
          hasilTes: hasilTes,
          fotoData: const FotoDataPengguna(
            jumlahDompetAktif: 1,
            jumlahPemasukan: 1,
            jumlahPengeluaran: 1,
            jumlahAnggaran: 1,
            jumlahTujuanAktif: 0,
            jumlahUtangAktif: 0,
            kategoriKeluarTerpakai: {},
            hariTransaksiBerbeda: 1,
            bulanTransaksiBerbeda: 1,
            pernyataan: {},
            progresPelajaran: {},
            hasilKuisTerbaik: {},
            tujuanDanaDaruratAktif: false, // memicu dana_darurat_kosong
            saldoTerkumpulDanaDarurat: 0,
            sisaUtangAktif: 0,
          ),
          daftarModul: daftarModulContoh,
          statusModul: {
            ...statusModulStandar,
            'waspada_penipuan': const HasilStatusBelajar(
              status: StatusBelajar.selesai,
              apaYangKurang: [],
            ),
          },
        );

        final rekDarurat = hasil.firstWhere((r) => r.modulId == 'dana_darurat');
        // Memuat kedua alasan secara sekaligus dalam satu list alasan
        expect(rekDarurat.kodeAlasan.contains(alasanSkorTesRendah), isTrue);
        expect(rekDarurat.kodeAlasan.contains(alasanDanaDaruratKosong), isTrue);
      },
    );

    test('Maksimum 3 modul rekomendasi teratas sesuai urutan modul', () {
      final hasilTesSemuaNol = const HasilSkorTesAwal(
        skorPerModul: {
          'anggaran_arus_kas': 0,
          'tabungan': 0,
          'dana_darurat': 0,
          'utang_cicilan': 0,
          'waspada_penipuan': 0,
          'psikologi_uang': 0,
        },
        skorTotalPersen: 0,
        totalBenar: 0,
        totalSoal: 12,
      );

      final hasil = rekomendasiModul(
        profil: null,
        hasilTes: hasilTesSemuaNol,
        fotoData: FotoDataPengguna.kosong(),
        daftarModul: daftarModulContoh,
        statusModul: statusModulStandar,
      );

      expect(
        hasil.length,
        equals(3),
        reason: 'Maksimum rekomendasi adalah tepat 3',
      );
      expect(hasil[0].modulId, equals('anggaran_arus_kas'));
      expect(hasil[1].modulId, equals('tabungan'));
      expect(hasil[2].modulId, equals('dana_darurat'));
    });

    test(
      'Modul tersedia:false tetap muncul dalam rekomendasi sebagai segera hadir',
      () {
        final hasil = rekomendasiModul(
          profil: null,
          hasilTes: null,
          fotoData: const FotoDataPengguna(
            jumlahDompetAktif: 1,
            jumlahPemasukan: 1,
            jumlahPengeluaran: 1,
            jumlahAnggaran: 1,
            jumlahTujuanAktif: 1,
            jumlahUtangAktif: 1,
            kategoriKeluarTerpakai: {},
            hariTransaksiBerbeda: 1,
            bulanTransaksiBerbeda: 1,
            pernyataan: {},
            progresPelajaran: {},
            hasilKuisTerbaik: {},
            sisaUtangAktif: 10000000, // Utang aktif
            tujuanDanaDaruratAktif: true,
            saldoTerkumpulDanaDarurat: 1000000,
          ),
          daftarModul: daftarModulContoh,
          statusModul: {
            ...statusModulStandar,
            'anggaran_arus_kas': const HasilStatusBelajar(
              status: StatusBelajar.selesai,
              apaYangKurang: [],
            ),
            'tabungan': const HasilStatusBelajar(
              status: StatusBelajar.selesai,
              apaYangKurang: [],
            ),
            'dana_darurat': const HasilStatusBelajar(
              status: StatusBelajar.selesai,
              apaYangKurang: [],
            ),
          },
        );

        final rekUtang = hasil.firstWhere((r) => r.modulId == 'utang_cicilan');
        expect(
          rekUtang.tersedia,
          isFalse,
          reason: 'Modul 4 belum tersedia dan ditandai tersedia: false',
        );
        expect(rekUtang.kodeAlasan.contains(alasanPunyaUtangTercatat), isTrue);
      },
    );

    test(
      'Pengguna baru tanpa profil dan tanpa tes tetap mendapatkan rekomendasi deterministik',
      () {
        final hasil = rekomendasiModul(
          profil: null,
          hasilTes: null,
          fotoData: FotoDataPengguna.kosong(),
          daftarModul: daftarModulContoh,
          statusModul: statusModulStandar,
        );

        expect(hasil.isNotEmpty, isTrue);
        expect(hasil.length, lessThanOrEqualTo(3));
        // Dana darurat kosong dan belum ada modul selesai akan terpicu
        final ids = hasil.map((r) => r.modulId).toList();
        expect(ids.contains('anggaran_arus_kas'), isTrue);
        expect(ids.contains('dana_darurat'), isTrue);
      },
    );

    test('Semua modul selesai menghasilkan daftar rekomendasi kosong', () {
      final statusSemuaSelesai = {
        for (final m in daftarModulContoh)
          m.id: const HasilStatusBelajar(
            status: StatusBelajar.selesai,
            apaYangKurang: [],
          ),
      };

      final hasil = rekomendasiModul(
        profil: null,
        hasilTes: null,
        fotoData: FotoDataPengguna.kosong(),
        daftarModul: daftarModulContoh,
        statusModul: statusSemuaSelesai,
      );

      expect(
        hasil.isEmpty,
        isTrue,
        reason:
            'Bila semua modul telah diselesaikan, daftar rekomendasi kosong',
      );
    });
  });

  group('4. Pengujian Fungsi Murni Prioritas Lanjut Belajar di Beranda', () {
    test('Pelajaran yang berstatus sedang memiliki prioritas tertinggi', () {
      final target = tentukanTargetLanjutBelajar(
        pelajaranSedang: 'anggaran_arus_kas_1_2',
        modulSedang: 'anggaran_arus_kas',
        rekomendasiTerbuka: [
          const RekomendasiTargetBelajar(
            modulId: 'dana_darurat',
            pelajaranId: 'dana_darurat_1_1',
          ),
        ],
        modulTerbukaPertama: 'tabungan',
        pelajaranTerbukaPertama: 'tabungan_1_1',
      );

      expect(target.modulId, equals('anggaran_arus_kas'));
      expect(target.pelajaranId, equals('anggaran_arus_kas_1_2'));
      expect(target.alasan, equals(AlasanTargetBelajar.sedangBerjalan));
    });

    test(
      'Jika tidak ada yang sedang berjalan, ambil pelajaran dari rekomendasi pertama yang terbuka',
      () {
        final target = tentukanTargetLanjutBelajar(
          pelajaranSedang: null,
          modulSedang: null,
          rekomendasiTerbuka: [
            const RekomendasiTargetBelajar(
              modulId: 'dana_darurat',
              pelajaranId: 'dana_darurat_1_1',
            ),
          ],
          modulTerbukaPertama: 'anggaran_arus_kas',
          pelajaranTerbukaPertama: 'anggaran_arus_kas_1_2',
        );

        expect(target.modulId, equals('dana_darurat'));
        expect(target.pelajaranId, equals('dana_darurat_1_1'));
        expect(target.alasan, equals(AlasanTargetBelajar.rekomendasi));
      },
    );

    test(
      'Jika tidak ada rekomendasi terbuka, fallback ke modul dan pelajaran terbuka pertama',
      () {
        final target = tentukanTargetLanjutBelajar(
          pelajaranSedang: null,
          modulSedang: null,
          rekomendasiTerbuka: [],
          modulTerbukaPertama: 'anggaran_arus_kas',
          pelajaranTerbukaPertama: 'anggaran_arus_kas_1_2',
        );

        expect(target.modulId, equals('anggaran_arus_kas'));
        expect(target.pelajaranId, equals('anggaran_arus_kas_1_2'));
        expect(target.alasan, equals(AlasanTargetBelajar.terbukaPertama));
      },
    );
  });
}
