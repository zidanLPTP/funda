import 'package:flutter_test/flutter_test.dart';
import 'package:funda/perhitungan/perhitungan_sandbox.dart';

void main() {
  group('Perhitungan Sandbox - Validasi Alokasi', () {
    test('alokasi valid total 100% diterima', () {
      expect(
        validasiAlokasiSandbox(
          persenPasarUang: 40,
          persenObligasi: 30,
          persenSaham: 30,
        ),
        isTrue,
      );
      expect(
        validasiAlokasiSandbox(
          persenPasarUang: 100,
          persenObligasi: 0,
          persenSaham: 0,
        ),
        isTrue,
      );
      expect(
        validasiAlokasiSandbox(
          persenPasarUang: 0,
          persenObligasi: 0,
          persenSaham: 100,
        ),
        isTrue,
      );
    });

    test('alokasi tidak 100% atau bernilai negatif / melebihi 100 ditolak', () {
      expect(
        validasiAlokasiSandbox(
          persenPasarUang: 50,
          persenObligasi: 30,
          persenSaham: 10,
        ),
        isFalse,
      );
      expect(
        validasiAlokasiSandbox(
          persenPasarUang: 50,
          persenObligasi: 30,
          persenSaham: 30,
        ),
        isFalse,
      );
      expect(
        validasiAlokasiSandbox(
          persenPasarUang: -10,
          persenObligasi: 60,
          persenSaham: 50,
        ),
        isFalse,
      );
      expect(
        validasiAlokasiSandbox(
          persenPasarUang: 110,
          persenObligasi: 0,
          persenSaham: -10,
        ),
        isFalse,
      );
    });

    test(
      'hitungSimulasiSandbox melempar ArgumentError jika alokasi tidak 100%',
      () {
        expect(
          () => hitungSimulasiSandbox(
            saldoAwal: 10000000,
            persenPasarUang: 50,
            persenObligasi: 20,
            persenSaham: 20,
            jumlahTahun: 1,
            skenario: 'normal',
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      'hitungSimulasiSandbox melempar ArgumentError jika skenario tidak valid',
      () {
        expect(
          () => hitungSimulasiSandbox(
            saldoAwal: 10000000,
            persenPasarUang: 50,
            persenObligasi: 30,
            persenSaham: 20,
            jumlahTahun: 1,
            skenario: 'tidak_dikenal',
          ),
          throwsArgumentError,
        );
      },
    );
  });

  group('Perhitungan Sandbox - Skenario Majemuk Integer', () {
    const int saldoAwal = 10000000;

    test('skenario normal 1 tahun (40% PU, 30% OB, 30% SH)', () {
      // PU: 4.000.000 + (4.000.000 * 400 ~/ 10000) = 4.000.000 + 160.000 = 4.160.000
      // OB: 3.000.000 + (3.000.000 * 600 ~/ 10000) = 3.000.000 + 180.000 = 3.180.000
      // SH: 3.000.000 + (3.000.000 * 1000 ~/ 10000) = 3.000.000 + 300.000 = 3.300.000
      // Total = 10.640.000, Selisih = +640.000
      final hasil = hitungSimulasiSandbox(
        saldoAwal: saldoAwal,
        persenPasarUang: 40,
        persenObligasi: 30,
        persenSaham: 30,
        jumlahTahun: 1,
        skenario: 'normal',
      );

      expect(hasil.nilaiPasarUang, 4160000);
      expect(hasil.nilaiObligasi, 3180000);
      expect(hasil.nilaiSaham, 3300000);
      expect(hasil.nilaiAkhirTotal, 10640000);
      expect(hasil.selisihRupiah, 640000);
    });

    test('skenario turun 1 tahun (40% PU, 30% OB, 30% SH)', () {
      // PU (+300 bp): 4.000.000 + 120.000 = 4.120.000
      // OB (-200 bp): 3.000.000 - 60.000 = 2.940.000
      // SH (-2000 bp): 3.000.000 - 600.000 = 2.400.000
      // Total = 9.460.000, Selisih = -540.000
      final hasil = hitungSimulasiSandbox(
        saldoAwal: saldoAwal,
        persenPasarUang: 40,
        persenObligasi: 30,
        persenSaham: 30,
        jumlahTahun: 1,
        skenario: 'turun',
      );

      expect(hasil.nilaiPasarUang, 4120000);
      expect(hasil.nilaiObligasi, 2940000);
      expect(hasil.nilaiSaham, 2400000);
      expect(hasil.nilaiAkhirTotal, 9460000);
      expect(hasil.selisihRupiah, -540000);
    });

    test('skenario naik 1 tahun (40% PU, 30% OB, 30% SH)', () {
      // PU (+500 bp): 4.000.000 + 200.000 = 4.200.000
      // OB (+800 bp): 3.000.000 + 240.000 = 3.240.000
      // SH (+1800 bp): 3.000.000 + 540.000 = 3.540.000
      // Total = 10.980.000, Selisih = +980.000
      final hasil = hitungSimulasiSandbox(
        saldoAwal: saldoAwal,
        persenPasarUang: 40,
        persenObligasi: 30,
        persenSaham: 30,
        jumlahTahun: 1,
        skenario: 'naik',
      );

      expect(hasil.nilaiPasarUang, 4200000);
      expect(hasil.nilaiObligasi, 3240000);
      expect(hasil.nilaiSaham, 3540000);
      expect(hasil.nilaiAkhirTotal, 10980000);
      expect(hasil.selisihRupiah, 980000);
    });

    test('skenario normal 5 tahun (pemajemukan integer bertahap)', () {
      final hasil = hitungSimulasiSandbox(
        saldoAwal: saldoAwal,
        persenPasarUang: 40,
        persenObligasi: 30,
        persenSaham: 30,
        jumlahTahun: 5,
        skenario: 'normal',
      );

      // Verifikasi manual tahun demi tahun untuk 5 tahun
      // PU: 4000000 -> 4160000 -> 4326400 -> 4499456 -> 4679434 -> 4866611
      // OB: 3000000 -> 3180000 -> 3370800 -> 3573048 -> 3787430 -> 4014675
      // SH: 3000000 -> 3300000 -> 3630000 -> 3993000 -> 4392300 -> 4831530
      expect(hasil.nilaiPasarUang, 4866611);
      expect(hasil.nilaiObligasi, 4014675);
      expect(hasil.nilaiSaham, 4831530);
      expect(hasil.nilaiAkhirTotal, 13712816);
      expect(hasil.selisihRupiah, 3712816);
    });

    test(
      'diversifikasi meredam penurunan: 100% pasar uang vs 100% saham di skenario turun',
      () {
        // 100% Saham pada skenario turun 1 tahun:
        // Saldo 10jt -> Saham rugi 20% (-2000 bp) = 8.000.000 (turun 2jt)
        final hasilSemuaSaham = hitungSimulasiSandbox(
          saldoAwal: saldoAwal,
          persenPasarUang: 0,
          persenObligasi: 0,
          persenSaham: 100,
          jumlahTahun: 1,
          skenario: 'turun',
        );
        expect(hasilSemuaSaham.nilaiAkhirTotal, 8000000);
        expect(hasilSemuaSaham.selisihRupiah, -2000000);

        // Portofolio Campuran (50% Pasar Uang, 50% Saham):
        // PU (+300 bp): 5.000.000 + 150.000 = 5.150.000
        // SH (-2000 bp): 5.000.000 - 1.000.000 = 4.000.000
        // Total = 9.150.000 (penurunan hanya -850.000, jauh lebih tenang daripada -2.000.000)
        final hasilCampuran = hitungSimulasiSandbox(
          saldoAwal: saldoAwal,
          persenPasarUang: 50,
          persenObligasi: 0,
          persenSaham: 50,
          jumlahTahun: 1,
          skenario: 'turun',
        );
        expect(hasilCampuran.nilaiAkhirTotal, 9150000);
        expect(hasilCampuran.selisihRupiah, -850000);

        expect(
          hasilCampuran.nilaiAkhirTotal > hasilSemuaSaham.nilaiAkhirTotal,
          isTrue,
        );
      },
    );

    test(
      'sisa pembagian integer alokasi: angka tidak habis dibagi 100 (1000001, 33/33/34)',
      () {
        const nilaiAwal = 1000001;
        const persenPU = 33;
        const persenOB = 33;
        const persenSH = 34;

        final nominalPU = (nilaiAwal * persenPU) ~/ 100;
        final nominalOB = (nilaiAwal * persenOB) ~/ 100;
        final nominalSH = nilaiAwal - nominalPU - nominalOB;

        // Buktikan nominalPasarUang + nominalObligasi + nominalSaham == nilaiAwalRupiah
        expect(nominalPU + nominalOB + nominalSH, equals(nilaiAwal));

        // Jalankan 0 tahun untuk memverifikasi porsi awal hasil simulasi
        final hasil0Tahun = hitungSimulasiSandbox(
          saldoAwal: nilaiAwal,
          persenPasarUang: persenPU,
          persenObligasi: persenOB,
          persenSaham: persenSH,
          jumlahTahun: 0,
          skenario: 'normal',
        );

        expect(hasil0Tahun.nilaiPasarUang, equals(nominalPU));
        expect(hasil0Tahun.nilaiObligasi, equals(nominalOB));
        expect(hasil0Tahun.nilaiSaham, equals(nominalSH));
        expect(
          hasil0Tahun.nilaiPasarUang +
              hasil0Tahun.nilaiObligasi +
              hasil0Tahun.nilaiSaham,
          equals(nilaiAwal),
        );
        expect(hasil0Tahun.nilaiAkhirTotal, equals(nilaiAwal));
        expect(hasil0Tahun.selisihRupiah, equals(0));
      },
    );
  });

  group('Perhitungan Sandbox - Daya Beli Inflasi', () {
    test(
      'daya beli inflasi 400 bp (4%) selama 5 tahun dengan nilai awal 10.000.000',
      () {
        // Tiap tahun: nilai = nilai * 10000 ~/ (10000 + inflasiBpPerTahun)
        // Thn 1: 10.000.000 * 10.000 ~/ 10.400 = 9.615.384
        // Thn 2: 9.615.384 * 10.000 ~/ 10.400 = 9.245.561
        // Thn 3: 9.245.561 * 10.000 ~/ 10.400 = 8.889.962
        // Thn 4: 8.889.962 * 10.000 ~/ 10.400 = 8.548.040
        // Thn 5: 8.548.040 * 10.000 ~/ 10.400 = 8.219.271
        final dayaBeli = hitungDayaBeliInflasi(
          nilaiAwal: 10000000,
          inflasiBpPerTahun: 400,
          jumlahTahun: 5,
        );

        expect(dayaBeli, 8219271);
        final selisih = dayaBeli - 10000000;
        expect(selisih, -1780729);
      },
    );

    test('daya beli inflasi 0 tahun mengembalikan nilai awal', () {
      expect(
        hitungDayaBeliInflasi(
          nilaiAwal: 5000000,
          inflasiBpPerTahun: 400,
          jumlahTahun: 0,
        ),
        5000000,
      );
    });
  });
}
