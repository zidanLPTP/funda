import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/repositori/transaksi_repositori.dart';

void main() {
  late BasisDataFunda db;
  late TransaksiRepositori repo;

  setUp(() async {
    db = BasisDataFunda(NativeDatabase.memory());
    repo = TransaksiRepositori(db);

    // Siapkan dompet & kategori uji
    await db
        .into(db.tabelDompet)
        .insert(
          TabelDompetCompanion.insert(
            id: 'd1',
            nama: 'Dompet Utama',
            jenis: 'tunai',
            ikon: 'wallet',
            warna: 'tintHijau',
            urutan: const drift.Value(0),
          ),
        );

    await db
        .into(db.tabelKategori)
        .insert(
          TabelKategoriCompanion.insert(
            id: 'k1',
            nama: 'Makan',
            arus: 'keluar',
            sifat: 'kebutuhan',
            ikon: 'utensils',
            bawaan: const drift.Value(true),
          ),
        );
  });

  tearDown(() async => await db.close());

  test(
    'Paginasi kursor mencegah baris duplikat saat transaksi baru ditambah di atas',
    () async {
      final sekarang = DateTime.now();

      // Buat 10 transaksi dengan waktu berurutan (t9 paling baru, t0 paling lama)
      for (var i = 0; i < 10; i++) {
        final waktu = sekarang.subtract(Duration(minutes: 10 - i));
        await repo.tambahTransaksi(
          TabelTransaksiCompanion.insert(
            id: 'trx_${i.toString().padLeft(2, '0')}',
            jenis: 'keluar',
            jumlahRupiah: (i + 1) * 10000,
            dompetId: 'd1',
            kategoriId: const drift.Value('k1'),
            waktuTransaksi: waktu,
          ),
        );
      }

      // 1. Muat Halaman 1 (limit 5 transaksi pertama paling baru)
      final halaman1 = await repo.ambilTransaksiKursor(limit: 5);
      expect(halaman1.length, 5);
      final idHalaman1 = halaman1.map((t) => t.id).toList();
      expect(idHalaman1, ['trx_09', 'trx_08', 'trx_07', 'trx_06', 'trx_05']);

      // 2. Tambah transaksi baru (trx_baru) yang terjadi PALING BARU (di atas trx_09)
      await repo.tambahTransaksi(
        TabelTransaksiCompanion.insert(
          id: 'trx_baru',
          jenis: 'keluar',
          jumlahRupiah: 50000,
          dompetId: 'd1',
          kategoriId: const drift.Value('k1'),
          waktuTransaksi: sekarang.add(const Duration(minutes: 5)),
        ),
      );

      // KETIKA MENGGUNAKAN OFFSET (offset: 5):
      // Data bergeser 1 baris ke bawah, sehingga item ke-5 ('trx_05') akan muncul lagi di halaman 2!
      final halaman2Offset = await repo.ambilTransaksiBerhalaman(
        limit: 5,
        offset: 5,
      );
      final idOffset = halaman2Offset.map((t) => t.id).toList();
      expect(
        idOffset.contains('trx_05'),
        isTrue,
        reason: 'Paginasi OFFSET mengalami anomali duplikasi baris',
      );

      // KETIKA MENGGUNAKAN KURSOR:
      // Kursor diambil dari item terakhir di halaman 1 ('trx_05')
      final itemTerakhirH1 = halaman1.last;
      final halaman2Kursor = await repo.ambilTransaksiKursor(
        limit: 5,
        kursorWaktu: itemTerakhirH1.waktuTransaksi,
        kursorId: itemTerakhirH1.id,
      );

      final idKursor = halaman2Kursor.map((t) => t.id).toList();
      expect(idKursor, ['trx_04', 'trx_03', 'trx_02', 'trx_01', 'trx_00']);
      // Buktikan tidak ada irisan antara Halaman 1 dan Halaman 2 (0 duplikasi)
      final irisan = idHalaman1.toSet().intersection(idKursor.toSet());
      expect(
        irisan,
        isEmpty,
        reason: 'Paginasi kursor bersih tanpa baris ganda',
      );
    },
  );

  test(
    'Paginasi kursor tidak melewatkan baris saat transaksi dihapus di atas',
    () async {
      final sekarang = DateTime.now();

      // Buat 10 transaksi
      for (var i = 0; i < 10; i++) {
        final waktu = sekarang.subtract(Duration(minutes: 10 - i));
        await repo.tambahTransaksi(
          TabelTransaksiCompanion.insert(
            id: 'trx_${i.toString().padLeft(2, '0')}',
            jenis: 'keluar',
            jumlahRupiah: (i + 1) * 10000,
            dompetId: 'd1',
            kategoriId: const drift.Value('k1'),
            waktuTransaksi: waktu,
          ),
        );
      }

      // 1. Muat Halaman 1 (limit 5)
      final halaman1 = await repo.ambilTransaksiKursor(limit: 5);
      final itemTerakhirH1 = halaman1.last; // trx_05

      // 2. Pengguna menghapus salah satu transaksi di halaman 1 ('trx_09')
      await repo.hapusTransaksi('trx_09');

      // KETIKA MENGGUNAKAN OFFSET (offset: 5):
      // Baris bergeser 1 ke atas, sehingga 'trx_04' terlewat karena sekarang berada di indeks 4!
      final halaman2Offset = await repo.ambilTransaksiBerhalaman(
        limit: 5,
        offset: 5,
      );
      final idOffset = halaman2Offset.map((t) => t.id).toList();
      expect(
        idOffset.contains('trx_04'),
        isFalse,
        reason: 'Paginasi OFFSET melewatkan trx_04',
      );

      // KETIKA MENGGUNAKAN KURSOR:
      // Menggunakan kursor dari item terakhir Halaman 1 ('trx_05')
      final halaman2Kursor = await repo.ambilTransaksiKursor(
        limit: 5,
        kursorWaktu: itemTerakhirH1.waktuTransaksi,
        kursorId: itemTerakhirH1.id,
      );

      final idKursor = halaman2Kursor.map((t) => t.id).toList();
      expect(
        idKursor.first,
        'trx_04',
        reason: 'Paginasi kursor tidak melewatkan trx_04',
      );
      expect(idKursor, ['trx_04', 'trx_03', 'trx_02', 'trx_01', 'trx_00']);
    },
  );
}
