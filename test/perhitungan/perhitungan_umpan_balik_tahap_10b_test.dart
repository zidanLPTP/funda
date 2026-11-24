import 'package:flutter_test/flutter_test.dart';
import 'package:funda/fitur/belajar/model/registri_misi.dart';
import 'package:funda/perhitungan/perhitungan_umpan_balik_belajar.dart';

void main() {
  group('Perhitungan Umpan Balik Tahap 10B - ringkasan_tujuan_besar', () {
    test('V1: Belum ada tujuan non-dana-darurat (null)', () {
      final hasil = formatRingkasanTujuanBesar(tujuan: null);

      const ekspetasi =
          'Belum ada tujuan aktif selain dana darurat. '
          'Buat satu tujuan di menu Tujuan agar proyeksinya bisa dihitung.';

      expect(hasil, equals(ekspetasi));

      // Verifikasi delegasi RegistriMisi
      final hasilMisi =
          RegistriMisi.formatRingkasanTujuanBesarMisi(tujuan: null);
      expect(hasilMisi, equals(ekspetasi));
    });

    test('V2: Target sudah tercapai (dana >= target)', () {
      final tujuan = DataTujuanBesarUmpanBalik(
        nama: 'Dana Pendidikan',
        targetRupiah: 20000000,
        danaTerkumpulRupiah: 20000000,
        bulanTersisa: 12,
        jenis: 'tujuan_besar',
        dibuatPada: DateTime(2026, 1, 1),
      );

      final hasil = formatRingkasanTujuanBesar(tujuan: tujuan);

      const ekspetasi =
          'Tujuan besarmu: Dana Pendidikan (target Rp20.000.000, terkumpul Rp20.000.000). '
          'Targetmu sudah tercapai. '
          'Fokus pada satu atau dua tujuan utama lebih mudah dijalankan daripada mengejar semuanya sekaligus.';

      expect(hasil, equals(ekspetasi));

      // Verifikasi saat dana melebihi target
      final tujuanLebih = DataTujuanBesarUmpanBalik(
        nama: 'Dana Pendidikan',
        targetRupiah: 20000000,
        danaTerkumpulRupiah: 25000000,
        bulanTersisa: 6,
        jenis: 'tujuan_besar',
        dibuatPada: DateTime(2026, 1, 1),
      );
      final hasilLebih = formatRingkasanTujuanBesar(tujuan: tujuanLebih);
      expect(
        hasilLebih,
        equals(
          'Tujuan besarmu: Dana Pendidikan (target Rp20.000.000, terkumpul Rp25.000.000). '
          'Targetmu sudah tercapai. '
          'Fokus pada satu atau dua tujuan utama lebih mudah dijalankan daripada mengejar semuanya sekaligus.',
        ),
      );
    });

    test('V3: Target belum tercapai dan ada tenggat waktu (pembagian bulat ke atas)', () {
      // Kasus A: Pembagian habis
      final tujuanA = DataTujuanBesarUmpanBalik(
        nama: 'Biaya Kuliah',
        targetRupiah: 36000000,
        danaTerkumpulRupiah: 0,
        bulanTersisa: 24,
        jenis: 'tujuan_besar',
        dibuatPada: DateTime(2026, 1, 1),
      );

      final hasilA = formatRingkasanTujuanBesar(tujuan: tujuanA);
      const ekspetasiA =
          'Tujuan besarmu: Biaya Kuliah (target Rp36.000.000, terkumpul Rp0). '
          'Sisa Rp36.000.000 dalam 24 bulan berarti kamu perlu menyisihkan sekitar Rp1.500.000 per bulan. '
          'Fokus pada satu atau dua tujuan utama lebih mudah dijalankan daripada mengejar semuanya sekaligus.';
      expect(hasilA, equals(ekspetasiA));

      // Kasus B: Pembagian dengan sisa (harus bulat ke atas)
      // Sisa: 48.000.000 - 10.000.000 = 38.000.000
      // 38.000.000 / 36 = 1.055.555,55... -> bulat ke atas: 1.055.556
      final tujuanB = DataTujuanBesarUmpanBalik(
        nama: 'Dana Nikah',
        targetRupiah: 48000000,
        danaTerkumpulRupiah: 10000000,
        bulanTersisa: 36,
        jenis: 'tujuan_besar',
        dibuatPada: DateTime(2026, 1, 1),
      );

      final hasilB = formatRingkasanTujuanBesar(tujuan: tujuanB);
      const ekspetasiB =
          'Tujuan besarmu: Dana Nikah (target Rp48.000.000, terkumpul Rp10.000.000). '
          'Sisa Rp38.000.000 dalam 36 bulan berarti kamu perlu menyisihkan sekitar Rp1.055.556 per bulan. '
          'Fokus pada satu atau dua tujuan utama lebih mudah dijalankan daripada mengejar semuanya sekaligus.';
      expect(hasilB, equals(ekspetasiB));
    });

    test('V4: Target belum tercapai tapi tanpa tenggat', () {
      final tujuan = DataTujuanBesarUmpanBalik(
        nama: 'Renovasi Rumah',
        targetRupiah: 60000000,
        danaTerkumpulRupiah: 15000000,
        bulanTersisa: null,
        jenis: 'tujuan_besar',
        dibuatPada: DateTime(2026, 1, 1),
      );

      final hasil = formatRingkasanTujuanBesar(tujuan: tujuan);
      const ekspetasi =
          'Tujuan besarmu: Renovasi Rumah (target Rp60.000.000, terkumpul Rp15.000.000). '
          'Sisa Rp45.000.000. Tambahkan tenggat agar setoran bulanannya bisa dihitung. '
          'Fokus pada satu atau dua tujuan utama lebih mudah dijalankan daripada mengejar semuanya sekaligus.';

      expect(hasil, equals(ekspetasi));
    });

    test('Seleksi Tujuan: Filter dana_darurat dan prioritas jenis tujuan_besar', () {
      final tDarurat = DataTujuanBesarUmpanBalik(
        nama: 'Dana Darurat Utama',
        targetRupiah: 100000000,
        danaTerkumpulRupiah: 10000000,
        bulanTersisa: 6,
        jenis: 'dana_darurat',
        dibuatPada: DateTime(2026, 1, 1),
      );

      final tBesar1 = DataTujuanBesarUmpanBalik(
        nama: 'Uang Muka Rumah',
        targetRupiah: 50000000,
        danaTerkumpulRupiah: 5000000,
        bulanTersisa: 20,
        jenis: 'tujuan_besar',
        dibuatPada: DateTime(2026, 1, 1),
      );

      final tBesar2 = DataTujuanBesarUmpanBalik(
        nama: 'Pendidikan Anak',
        targetRupiah: 30000000,
        danaTerkumpulRupiah: 2000000,
        bulanTersisa: 10, // tenggat lebih dekat
        jenis: 'tujuan_besar',
        dibuatPada: DateTime(2026, 2, 1),
      );

      final tTabungan = DataTujuanBesarUmpanBalik(
        nama: 'Beli Laptop',
        targetRupiah: 80000000, // target lebih besar dari tujuan_besar
        danaTerkumpulRupiah: 1000000,
        bulanTersisa: 5,
        jenis: 'tabungan',
        dibuatPada: DateTime(2026, 3, 1),
      );

      // Memilih tujuan_besar dengan tenggat paling dekat (Pendidikan Anak)
      final terpilih1 = pilihTujuanBesarUmpanBalik([
        tDarurat,
        tBesar1,
        tBesar2,
        tTabungan,
      ]);
      expect(terpilih1?.nama, equals('Pendidikan Anak'));

      // Jika hanya ada tujuan tabungan / non-tujuan_besar, pilih target terbesar
      final terpilih2 = pilihTujuanBesarUmpanBalik([
        tDarurat,
        tTabungan,
        DataTujuanBesarUmpanBalik(
          nama: 'Liburan',
          targetRupiah: 15000000,
          danaTerkumpulRupiah: 500000,
          bulanTersisa: 4,
          jenis: 'tabungan',
          dibuatPada: DateTime(2026, 4, 1),
        ),
      ]);
      expect(terpilih2?.nama, equals('Beli Laptop'));

      // Jika hanya ada dana_darurat, kembalikan null
      final terpilihNull = pilihTujuanBesarUmpanBalik([tDarurat]);
      expect(terpilihNull, isNull);
    });

    test('Hitung bulan tersisa minimal 1', () {
      final sekarang = DateTime(2026, 11, 24);

      // 1 tahun ke depan -> 12 bulan
      final tenggat1Tahun = DateTime(2027, 11, 24);
      expect(hitungBulanTersisa(tenggat1Tahun, sekarang), equals(12));

      // Bulan yang sama -> 1 bulan (minimal 1)
      final tenggatBulanIni = DateTime(2026, 11, 30);
      expect(hitungBulanTersisa(tenggatBulanIni, sekarang), equals(1));

      // Sudah lewat -> 1 bulan
      final tenggatLewat = DateTime(2026, 10, 15);
      expect(hitungBulanTersisa(tenggatLewat, sekarang), equals(1));
    });
  });
}
