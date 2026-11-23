import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/cadangan/cadangan_repositori.dart';
import 'package:funda/data/repositori/sandbox_repositori.dart';

void main() {
  late BasisDataFunda db;
  late SandboxRepositori repo;

  setUp(() {
    db = BasisDataFunda(NativeDatabase.memory());
    repo = SandboxRepositori(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('SandboxRepositori', () {
    test('ambilSesiTerakhir mengembalikan null jika belum ada sesi', () async {
      final sesi = await repo.ambilSesiTerakhir();
      expect(sesi, isNull);
    });

    test('simpanSesi memasukkan data baru dan dapat diambil kembali', () async {
      final id = await repo.simpanSesi(
        saldoAwalRupiah: 10000000,
        alokasiPasarUangPersen: 40,
        alokasiObligasiPersen: 30,
        alokasiSahamPersen: 30,
        bulanBerjalan: 0,
        nilaiSaatIniRupiah: 10000000,
        skenarioAktif: 'normal',
        riwayatJson: '[]',
      );

      expect(id, isPositive);

      final sesi = await repo.ambilSesiTerakhir();
      expect(sesi, isNotNull);
      expect(sesi!.saldoAwalRupiah, 10000000);
      expect(sesi.alokasiPasarUangPersen, 40);
      expect(sesi.alokasiObligasiPersen, 30);
      expect(sesi.alokasiSahamPersen, 30);
      expect(sesi.bulanBerjalan, 0);
      expect(sesi.nilaiSaatIniRupiah, 10000000);
      expect(sesi.skenarioAktif, 'normal');
      expect(sesi.riwayatJson, '[]');
    });

    test('simpanSesi memperbarui baris sesi yang sama tanpa menambah baris baru', () async {
      await repo.simpanSesi(
        saldoAwalRupiah: 10000000,
        alokasiPasarUangPersen: 40,
        alokasiObligasiPersen: 30,
        alokasiSahamPersen: 30,
        bulanBerjalan: 0,
        nilaiSaatIniRupiah: 10000000,
        skenarioAktif: 'normal',
        riwayatJson: '[]',
      );

      // Majukan 1 tahun (12 bulan)
      await repo.simpanSesi(
        saldoAwalRupiah: 10000000,
        alokasiPasarUangPersen: 50,
        alokasiObligasiPersen: 30,
        alokasiSahamPersen: 20,
        bulanBerjalan: 12,
        nilaiSaatIniRupiah: 10500000,
        skenarioAktif: 'turun',
        riwayatJson: '[{"tahun": 1, "nilai": 10500000}]',
      );

      final semuaSesi = await db.select(db.tabelSesiSandbox).get();
      expect(semuaSesi.length, equals(1));

      final sesi = semuaSesi.first;
      expect(sesi.bulanBerjalan, 12);
      expect(sesi.alokasiPasarUangPersen, 50);
      expect(sesi.nilaiSaatIniRupiah, 10500000);
      expect(sesi.skenarioAktif, 'turun');
    });

    test('resetSesi menghapus seluruh baris sesi sandbox', () async {
      await repo.simpanSesi(
        saldoAwalRupiah: 10000000,
        alokasiPasarUangPersen: 40,
        alokasiObligasiPersen: 30,
        alokasiSahamPersen: 30,
        bulanBerjalan: 24,
        nilaiSaatIniRupiah: 12000000,
        skenarioAktif: 'naik',
        riwayatJson: '[{"tahun": 1}]',
      );

      await repo.resetSesi();

      final sesi = await repo.ambilSesiTerakhir();
      expect(sesi, isNull);
    });

    test('ISOLASI TOTAL: operasi sandbox tidak menyentuh tabel keuangan asli pengguna', () async {
      // 1. Pastikan tabel keuangan pengguna bersih
      final txAwal = await db.select(db.tabelTransaksi).get();
      final dompetAwal = await db.select(db.tabelDompet).get();
      final utangAwal = await db.select(db.tabelUtang).get();
      final tagihanAwal = await db.select(db.tabelTagihan).get();

      // 2. Simpan dan ubah-ubah sesi sandbox
      await repo.simpanSesi(
        saldoAwalRupiah: 10000000,
        alokasiPasarUangPersen: 100,
        alokasiObligasiPersen: 0,
        alokasiSahamPersen: 0,
        bulanBerjalan: 36,
        nilaiSaatIniRupiah: 15000000,
        skenarioAktif: 'naik',
        riwayatJson: '[]',
      );

      // 3. Verifikasi seluruh tabel keuangan pengguna tetap tidak berubah
      final txAkhir = await db.select(db.tabelTransaksi).get();
      final dompetAkhir = await db.select(db.tabelDompet).get();
      final utangAkhir = await db.select(db.tabelUtang).get();
      final tagihanAkhir = await db.select(db.tabelTagihan).get();

      expect(txAkhir.length, equals(txAwal.length));
      expect(dompetAkhir.length, equals(dompetAwal.length));
      expect(utangAkhir.length, equals(utangAwal.length));
      expect(tagihanAkhir.length, equals(tagihanAwal.length));

      // 4. Verifikasi cadangan mengecualikan tabel sesi sandbox
      final cadanganRepo = CadanganRepositori(db);
      final jsonCadangan = await cadanganRepo.eksporCadanganKeJson();
      expect(jsonCadangan.contains('tabel_sesi_sandbox'), isFalse);
      expect(jsonCadangan.contains('15000000'), isFalse);
    });
  });
}
