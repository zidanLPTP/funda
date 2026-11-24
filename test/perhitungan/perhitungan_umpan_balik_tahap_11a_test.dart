import 'package:flutter_test/flutter_test.dart';
import 'package:funda/fitur/belajar/model/registri_misi.dart';
import 'package:funda/perhitungan/perhitungan_belajar.dart';
import 'package:funda/perhitungan/perhitungan_umpan_balik_belajar.dart';
import 'package:funda/perhitungan/perhitungan_utang_dashboard.dart';

void main() {
  group('Perhitungan Umpan Balik Tahap 11A - uji_kemampuan_kpr', () {
    test(
      'V1: Pemasukan 10.000.000 (rata-rata 3 bulan terakhir), cicilan aktif 1.000.000, saldo 25.000.000',
      () {
        const pemasukan = HasilPemasukanRataRata(
          nilaiRupiah: 10000000,
          dasar: DasarPemasukanRataRata.rataRata3Bulan,
        );

        final hasil = formatUjiKemampuanKpr(
          pemasukanRataRata: pemasukan,
          totalCicilanAktifRupiah: 1000000,
          totalSaldoDompetAktifRupiah: 25000000,
        );

        const ekspetasi =
            'Dengan pemasukan sekitar Rp10.000.000 per bulan (rata-rata 3 bulan terakhir) dan '
            'cicilan aktif saat ini Rp1.000.000, estimasi sisa ruang cicilan '
            '(memakai patokan umum 30 persen) adalah sekitar Rp2.000.000 per bulan. '
            'Total saldo dompet aktifmu saat ini tercatat Rp25.000.000 '
            '(belum dikurangi dana darurat dan kebutuhan harian). '
            'Ini simulasi edukatif, bukan persetujuan kredit.';

        expect(hasil, equals(ekspetasi));

        // Verifikasi delegasi RegistriMisi
        final hasilMisi = RegistriMisi.formatUjiKemampuanKprMisi(
          pemasukanRataRata: pemasukan,
          totalCicilanAktifRupiah: 1000000,
          totalSaldoDompetAktifRupiah: 25000000,
        );
        expect(hasilMisi, equals(ekspetasi));
      },
    );

    test(
      'V2: Pemasukan 5.000.000 (bulan ini), cicilan aktif 1.800.000, saldo 4.000.000 -> sisa ruang Rp0',
      () {
        const pemasukan = HasilPemasukanRataRata(
          nilaiRupiah: 5000000,
          dasar: DasarPemasukanRataRata.bulanBerjalan,
        );

        final hasil = formatUjiKemampuanKpr(
          pemasukanRataRata: pemasukan,
          totalCicilanAktifRupiah: 1800000,
          totalSaldoDompetAktifRupiah: 4000000,
        );

        const ekspetasi =
            'Dengan pemasukan sekitar Rp5.000.000 per bulan (bulan ini) dan '
            'cicilan aktif saat ini Rp1.800.000, estimasi sisa ruang cicilan '
            '(memakai patokan umum 30 persen) adalah sekitar Rp0 per bulan. '
            'Cicilan aktifmu saat ini sudah memenuhi atau melampaui patokan 30 persen, '
            'sehingga melunasi sebagian utang dulu biasanya jauh lebih tenang '
            'sebelum mengambil kredit besar. '
            'Total saldo dompet aktifmu saat ini tercatat Rp4.000.000 '
            '(belum dikurangi dana darurat dan kebutuhan harian). '
            'Ini simulasi edukatif, bukan persetujuan kredit.';

        expect(hasil, equals(ekspetasi));
      },
    );

    test('V3: Pemasukan belum ada (null, dasar belumAda, atau nilai 0)', () {
      // Kasus A: null
      final hasilNull = formatUjiKemampuanKpr(
        pemasukanRataRata: null,
        totalCicilanAktifRupiah: 500000,
        totalSaldoDompetAktifRupiah: 10000000,
      );

      const ekspetasi =
          'Belum ada catatan pemasukan untuk menguji ruang cicilanmu. '
          'Catat pemasukanmu secara rutin dulu agar gambarannya bisa dihitung. '
          'Ini simulasi edukatif, bukan persetujuan kredit.';

      expect(hasilNull, equals(ekspetasi));

      // Kasus B: dasar belumAda
      const pemasukanBelumAda = HasilPemasukanRataRata(
        nilaiRupiah: 0,
        dasar: DasarPemasukanRataRata.belumAda,
      );
      final hasilBelumAda = formatUjiKemampuanKpr(
        pemasukanRataRata: pemasukanBelumAda,
        totalCicilanAktifRupiah: 0,
        totalSaldoDompetAktifRupiah: 0,
      );
      expect(hasilBelumAda, equals(ekspetasi));

      // Kasus C: nilai <= 0
      const pemasukanNol = HasilPemasukanRataRata(
        nilaiRupiah: 0,
        dasar: DasarPemasukanRataRata.bulanBerjalan,
      );
      final hasilNol = formatUjiKemampuanKpr(
        pemasukanRataRata: pemasukanNol,
        totalCicilanAktifRupiah: 0,
        totalSaldoDompetAktifRupiah: 5000000,
      );
      expect(hasilNol, equals(ekspetasi));
    });

    test(
      'Evaluasi Gerbang: periode_data transaksi minimal 3 bulan_berbeda',
      () {
        final syarat = SyaratGerbangData(
          tipe: 'periode_data',
          objek: 'transaksi',
          satuan: 'bulan_berbeda',
          min: 3,
          pesan: 'Catat transaksi minimal di 3 bulan berbeda.',
        );

        // Kurang dari 3 bulan (misal 2 bulan)
        final foto2Bulan = FotoDataPengguna.kosong().copyWith(
          bulanTransaksiBerbeda: 2,
        );
        final hasil2Bulan = evaluasiSyarat(syarat, foto2Bulan);
        expect(hasil2Bulan.terpenuhi, isFalse);

        // Pas 3 bulan
        final foto3Bulan = FotoDataPengguna.kosong().copyWith(
          bulanTransaksiBerbeda: 3,
        );
        final hasil3Bulan = evaluasiSyarat(syarat, foto3Bulan);
        expect(hasil3Bulan.terpenuhi, isTrue);

        // Lebih dari 3 bulan (misal 5 bulan)
        final foto5Bulan = FotoDataPengguna.kosong().copyWith(
          bulanTransaksiBerbeda: 5,
        );
        final hasil5Bulan = evaluasiSyarat(syarat, foto5Bulan);
        expect(hasil5Bulan.terpenuhi, isTrue);
      },
    );
  });
}
