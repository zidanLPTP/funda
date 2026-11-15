import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/repositori/dompet_repositori.dart';
import 'package:funda/data/repositori/kategori_repositori.dart';
import 'package:funda/data/repositori/transaksi_repositori.dart';

void main() {
  late BasisDataFunda db;
  late DompetRepositori repoDompet;
  late KategoriRepositori repoKategori;
  late TransaksiRepositori repoTransaksi;

  setUp(() {
    db = BasisDataFunda(NativeDatabase.memory());
    repoDompet = DompetRepositori(db);
    repoKategori = KategoriRepositori(db);
    repoTransaksi = TransaksiRepositori(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('DompetRepositori', () {
    test('tambah dompet baru dan ambil kembali', () async {
      await repoDompet.tambahDompet(
        const TabelDompetCompanion(
          id: Value('dompet_1'),
          nama: Value('Dompet Saku'),
          jenis: Value('tunai'),
          ikon: Value('wallet'),
          warna: Value('tintHijau'),
          saldoAwalRupiah: Value(150000),
          urutan: Value(0),
        ),
      );

      final dompet = await repoDompet.ambilDompetBerdasarkanId('dompet_1');
      expect(dompet, isNotNull);
      expect(dompet!.nama, equals('Dompet Saku'));
      expect(dompet.saldoAwalRupiah, equals(150000));
      expect(dompet.diarsipkan, isFalse);
    });

    test('arsipkan dan pulihkan dompet', () async {
      await repoDompet.tambahDompet(
        const TabelDompetCompanion(
          id: Value('dompet_arsip'),
          nama: Value('Dompet Arsip'),
          jenis: Value('lainnya'),
          ikon: Value('archive'),
          warna: Value('tintNetral'),
          saldoAwalRupiah: Value(0),
        ),
      );

      await repoDompet.arsipkanDompet('dompet_arsip', true);
      var dompet = await repoDompet.ambilDompetBerdasarkanId('dompet_arsip');
      expect(dompet!.diarsipkan, isTrue);

      await repoDompet.arsipkanDompet('dompet_arsip', false);
      dompet = await repoDompet.ambilDompetBerdasarkanId('dompet_arsip');
      expect(dompet!.diarsipkan, isFalse);
    });

    test(
      'menolak hapus permanen dompet jika memiliki transaksi terkait',
      () async {
        await repoDompet.tambahDompet(
          const TabelDompetCompanion(
            id: Value('dompet_aktif'),
            nama: Value('Dompet Aktif'),
            jenis: Value('rekening_bank'),
            ikon: Value('building2'),
            warna: Value('tintBiru'),
            saldoAwalRupiah: Value(500000),
          ),
        );

        // Tambahkan transaksi pada dompet ini
        await repoTransaksi.tambahTransaksi(
          TabelTransaksiCompanion(
            id: const Value('trans_1'),
            jenis: const Value('masuk'),
            jumlahRupiah: const Value(200000),
            dompetId: const Value('dompet_aktif'),
            kategoriId: const Value('kat_masuk_gaji'),
            waktuTransaksi: Value(DateTime.now()),
          ),
        );

        // Coba hapus permanen harus melempar StateError
        expect(
          () => repoDompet.hapusDompetPermanen('dompet_aktif'),
          throwsStateError,
        );

        // Dompet tetap ada
        expect(
          await repoDompet.ambilDompetBerdasarkanId('dompet_aktif'),
          isNotNull,
        );
      },
    );

    test('boleh hapus permanen dompet jika belum memiliki transaksi', () async {
      await repoDompet.tambahDompet(
        const TabelDompetCompanion(
          id: Value('dompet_kosong'),
          nama: Value('Dompet Kosong'),
          jenis: Value('tunai'),
          ikon: Value('wallet'),
          warna: Value('tintHijau'),
          saldoAwalRupiah: Value(0),
        ),
      );

      final barisTerhapus = await repoDompet.hapusDompetPermanen(
        'dompet_kosong',
      );
      expect(barisTerhapus, equals(1));
      expect(
        await repoDompet.ambilDompetBerdasarkanId('dompet_kosong'),
        isNull,
      );
    });
  });

  group('KategoriRepositori', () {
    test('menolak penghapusan kategori bawaan sistem', () async {
      expect(
        () => repoKategori.hapusKategoriKustom('kat_masuk_gaji'),
        throwsStateError,
      );
    });

    test('tambah kategori kustom dan ubah sifat', () async {
      await repoKategori.tambahKategoriKustom(
        const TabelKategoriCompanion(
          id: Value('kat_kustom_kopi'),
          nama: Value('Kopi Spesialti'),
          arus: Value('keluar'),
          sifat: Value('keinginan'),
          ikon: Value('coffee'),
          bawaan: Value(false),
          diarsipkan: Value(false),
        ),
      );

      var kat = await repoKategori.ambilKategoriBerdasarkanId(
        'kat_kustom_kopi',
      );
      expect(kat, isNotNull);
      expect(kat!.sifat, equals('keinginan'));

      // Ubah sifat ke kebutuhan
      await repoKategori.perbaruiKategori(
        const TabelKategoriCompanion(
          id: Value('kat_kustom_kopi'),
          nama: Value('Kopi Spesialti'),
          arus: Value('keluar'),
          sifat: Value('kebutuhan'),
          ikon: Value('coffee'),
          bawaan: Value(false),
          diarsipkan: Value(false),
        ),
      );

      kat = await repoKategori.ambilKategoriBerdasarkanId('kat_kustom_kopi');
      expect(kat!.sifat, equals('kebutuhan'));
    });

    test(
      'menolak hapus kategori kustom jika sudah dipakai dalam transaksi',
      () async {
        await repoDompet.tambahDompet(
          const TabelDompetCompanion(
            id: Value('d1'),
            nama: Value('Dompet'),
            jenis: Value('tunai'),
            ikon: Value('wallet'),
            warna: Value('tintHijau'),
          ),
        );
        await repoKategori.tambahKategoriKustom(
          const TabelKategoriCompanion(
            id: Value('kat_terpakai'),
            nama: Value('Kategori Terpakai'),
            arus: Value('keluar'),
            sifat: Value('keinginan'),
            ikon: Value('tag'),
            bawaan: Value(false),
          ),
        );

        await repoTransaksi.tambahTransaksi(
          TabelTransaksiCompanion(
            id: const Value('t1'),
            jenis: const Value('keluar'),
            jumlahRupiah: const Value(50000),
            dompetId: const Value('d1'),
            kategoriId: const Value('kat_terpakai'),
            waktuTransaksi: Value(DateTime.now()),
          ),
        );

        expect(
          () => repoKategori.hapusKategoriKustom('kat_terpakai'),
          throwsStateError,
        );
      },
    );
  });

  group('TransaksiRepositori', () {
    test('tambah, ambil, dan hapus transaksi', () async {
      await repoDompet.tambahDompet(
        const TabelDompetCompanion(
          id: Value('d1'),
          nama: Value('Dompet Kas'),
          jenis: Value('tunai'),
          ikon: Value('wallet'),
          warna: Value('tintHijau'),
        ),
      );

      final waktu = DateTime(2026, 11, 15, 14, 30);
      await repoTransaksi.tambahTransaksi(
        TabelTransaksiCompanion(
          id: const Value('t_test'),
          jenis: const Value('masuk'),
          jumlahRupiah: const Value(150000),
          dompetId: const Value('d1'),
          kategoriId: const Value('kat_masuk_gaji'),
          catatan: const Value('Gaji sampingan'),
          waktuTransaksi: Value(waktu),
        ),
      );

      final ambil = await repoTransaksi.ambilTransaksiBerdasarkanId('t_test');
      expect(ambil, isNotNull);
      expect(ambil!.jumlahRupiah, equals(150000));
      expect(ambil.catatan, equals('Gaji sampingan'));

      final terhapus = await repoTransaksi.hapusTransaksi('t_test');
      expect(terhapus, equals(1));
      expect(await repoTransaksi.ambilTransaksiBerdasarkanId('t_test'), isNull);
    });
  });
}
