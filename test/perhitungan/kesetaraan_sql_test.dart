import 'dart:math';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/model/jenis_dompet.dart';
import 'package:funda/data/model/jenis_transaksi.dart';
import 'package:funda/data/repositori/dompet_repositori.dart';
import 'package:funda/data/repositori/transaksi_repositori.dart';
import 'package:funda/perhitungan/perhitungan_keuangan.dart';

void main() {
  late BasisDataFunda db;
  late DompetRepositori repoDompet;
  late TransaksiRepositori repoTransaksi;

  setUp(() {
    db = BasisDataFunda(NativeDatabase.memory());
    repoDompet = DompetRepositori(db);
    repoTransaksi = TransaksiRepositori(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('Uji Kesetaraan: Agregasi SQL vs Fungsi Murni Dart pada Data Acak', () async {
    // 1. Buat 2 dompet dengan saldo awal acak
    const dompet1Id = 'dompet_acak_1';
    const dompet2Id = 'dompet_acak_2';
    const saldoAwal1 = 5000000;
    const saldoAwal2 = 10000000;

    await repoDompet.tambahDompet(
      TabelDompetCompanion(
        id: const Value(dompet1Id),
        nama: const Value('Dompet Acak 1'),
        jenis: Value(JenisDompet.tunai.name),
        ikon: const Value('wallet'),
        warna: const Value('tintHijau'),
        saldoAwalRupiah: const Value(saldoAwal1),
      ),
    );

    await repoDompet.tambahDompet(
      TabelDompetCompanion(
        id: const Value(dompet2Id),
        nama: const Value('Dompet Acak 2'),
        jenis: Value(JenisDompet.rekeningBank.name),
        ikon: const Value('building2'),
        warna: const Value('tintBiru'),
        saldoAwalRupiah: const Value(saldoAwal2),
      ),
    );

    final kategoriList = await db.select(db.tabelKategori).get();
    final katId = kategoriList.first.id;

    // 2. Generate 100 transaksi acak
    final random = Random(42);
    final sekarang = DateTime.now();
    final daftarTransaksiCompanion = <TabelTransaksiCompanion>[];

    for (var i = 0; i < 100; i++) {
      final tipeIndex = random.nextInt(5);
      final jenis = switch (tipeIndex) {
        0 => JenisTransaksi.masuk.kode,
        1 => JenisTransaksi.keluar.kode,
        2 => JenisTransaksi.transfer.kode,
        3 => JenisTransaksi.penyesuaianMasuk.kode,
        _ => JenisTransaksi.penyesuaianKeluar.kode,
      };

      final nominal = (random.nextInt(50) + 1) * 10000;
      final biayaAdmin = jenis == JenisTransaksi.transfer.kode ? 2500 : 0;
      final hariOffset = random.nextInt(25);
      final waktu = sekarang.subtract(
        Duration(days: hariOffset, hours: random.nextInt(23)),
      );

      daftarTransaksiCompanion.add(
        TabelTransaksiCompanion(
          id: Value('tx_acak_$i'),
          jenis: Value(jenis),
          jumlahRupiah: Value(nominal),
          dompetId: const Value(dompet1Id),
          dompetTujuanId: jenis == JenisTransaksi.transfer.kode
              ? const Value(dompet2Id)
              : const Value(null),
          kategoriId:
              (jenis == JenisTransaksi.masuk.kode ||
                  jenis == JenisTransaksi.keluar.kode)
              ? Value(katId)
              : const Value(null),
          biayaAdminRupiah: Value(biayaAdmin),
          catatan: Value('Catatan transaksi $i'),
          waktuTransaksi: Value(waktu),
          dibuatPada: Value(waktu),
          diubahPada: Value(waktu),
        ),
      );
    }

    await db.batch((b) {
      b.insertAll(db.tabelTransaksi, daftarTransaksiCompanion);
    });

    // Ambil seluruh data dari basis data untuk dihitung oleh fungsi murni Dart
    final semuaTransaksi = await repoTransaksi.ambilSemuaTransaksi();

    // 3. Verifikasi Kesetaraan Saldo Dompet 1
    final saldoMurniDompet1 = hitungSaldoDompet(
      saldoAwalRupiah: saldoAwal1,
      dompetId: dompet1Id,
      daftarTransaksi: semuaTransaksi,
    );
    final saldoSQLDompet1 = await repoTransaksi.hitungSaldoDompetSQL(
      dompetId: dompet1Id,
      saldoAwalRupiah: saldoAwal1,
    );
    expect(
      saldoSQLDompet1,
      equals(saldoMurniDompet1),
      reason:
          'Hasil agregasi SQL saldo dompet 1 harus sama persis dengan fungsi murni Dart',
    );

    // 4. Verifikasi Kesetaraan Saldo Dompet 2
    final saldoMurniDompet2 = hitungSaldoDompet(
      saldoAwalRupiah: saldoAwal2,
      dompetId: dompet2Id,
      daftarTransaksi: semuaTransaksi,
    );
    final saldoSQLDompet2 = await repoTransaksi.hitungSaldoDompetSQL(
      dompetId: dompet2Id,
      saldoAwalRupiah: saldoAwal2,
    );
    expect(
      saldoSQLDompet2,
      equals(saldoMurniDompet2),
      reason:
          'Hasil agregasi SQL saldo dompet 2 harus sama persis dengan fungsi murni Dart',
    );

    // 5. Verifikasi Kesetaraan Arus Kas Bulan Ini
    final awalBulan = DateTime(sekarang.year, sekarang.month, 1);
    final akhirBulan = DateTime(
      sekarang.year,
      sekarang.month + 1,
      0,
      23,
      59,
      59,
    );

    final arusKasMurni = hitungArusKas(
      daftarTransaksi: semuaTransaksi,
      mulai: awalBulan,
      selesai: akhirBulan,
    );
    final arusKasSQL = await repoTransaksi.hitungArusKasSQL(
      mulai: awalBulan,
      selesai: akhirBulan,
    );

    expect(
      arusKasSQL.totalMasuk,
      equals(arusKasMurni.totalMasuk),
      reason: 'Total pemasukan SQL harus sama persis dengan fungsi murni Dart',
    );
    expect(
      arusKasSQL.totalKeluar,
      equals(arusKasMurni.totalKeluar),
      reason:
          'Total pengeluaran SQL harus sama persis dengan fungsi murni Dart',
    );
    expect(
      arusKasSQL.selisih,
      equals(arusKasMurni.selisih),
      reason: 'Selisih arus kas SQL harus sama persis dengan fungsi murni Dart',
    );
  });
}
