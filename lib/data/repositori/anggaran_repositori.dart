import 'package:drift/drift.dart';
import '../../perhitungan/perhitungan_anggaran_tujuan.dart';
import '../basis_data.dart';
import 'transaksi_repositori.dart';

/// Repositori untuk mengelola penetapan dan realisasi anggaran bulanan per kategori.
class AnggaranRepositori {
  const AnggaranRepositori(this._db, this._repoTransaksi);

  final BasisDataFunda _db;
  final TransaksiRepositori _repoTransaksi;

  /// Memantau daftar anggaran untuk tahun dan bulan tertentu.
  Stream<List<EntitasAnggaran>> pantauAnggaranBulan(int tahun, int bulan) {
    final kueri = _db.select(_db.tabelAnggaran)
      ..where((tbl) => tbl.tahun.equals(tahun) & tbl.bulan.equals(bulan))
      ..orderBy([
        (tbl) =>
            OrderingTerm(expression: tbl.batasRupiah, mode: OrderingMode.desc),
      ]);
    return kueri.watch();
  }

  /// Mengambil daftar anggaran untuk tahun dan bulan tertentu sekali panggil.
  Future<List<EntitasAnggaran>> ambilAnggaranBulan(int tahun, int bulan) {
    final kueri = _db.select(_db.tabelAnggaran)
      ..where((tbl) => tbl.tahun.equals(tahun) & tbl.bulan.equals(bulan));
    return kueri.get();
  }

  /// Menyimpan atau memperbarui anggaran per kategori untuk suatu periode bulan.
  Future<int> simpanAtauPerbaruiAnggaran(TabelAnggaranCompanion anggaran) {
    return _db.into(_db.tabelAnggaran).insertOnConflictUpdate(anggaran);
  }

  /// Helper untuk menyimpan atau memperbarui anggaran langsung dengan parameter dasar.
  Future<void> simpanAnggaran({
    required int tahun,
    required int bulan,
    required String kategoriId,
    required int batasRupiah,
  }) async {
    final id = 'ang_${tahun}_${bulan}_$kategoriId';
    final sekarang = DateTime.now();
    await simpanAtauPerbaruiAnggaran(
      TabelAnggaranCompanion(
        id: Value(id),
        tahun: Value(tahun),
        bulan: Value(bulan),
        kategoriId: Value(kategoriId),
        batasRupiah: Value(batasRupiah),
        dibuatPada: Value(sekarang),
        diubahPada: Value(sekarang),
      ),
    );
  }

  /// Menghapus batas anggaran berdasarkan ID.
  Future<int> hapusAnggaran(String id) {
    return (_db.delete(
      _db.tabelAnggaran,
    )..where((tbl) => tbl.id.equals(id))).go();
  }

  /// Menyalin seluruh pos anggaran dari bulan sebelumnya ke bulan tujuan.
  /// Melewati kategori yang sudah memiliki anggaran di bulan tujuan.
  Future<int> salinAnggaranDariBulanLalu({
    required int tahunTujuan,
    required int bulanTujuan,
  }) async {
    final tahunLalu = bulanTujuan == 1 ? tahunTujuan - 1 : tahunTujuan;
    final bulanLalu = bulanTujuan == 1 ? 12 : bulanTujuan - 1;

    final daftarBulanLalu = await ambilAnggaranBulan(tahunLalu, bulanLalu);
    if (daftarBulanLalu.isEmpty) return 0;

    final daftarSudahAda = await ambilAnggaranBulan(tahunTujuan, bulanTujuan);
    final kumpulanKategoriAda = daftarSudahAda.map((a) => a.kategoriId).toSet();

    var jumlahDisalin = 0;
    final sekarang = DateTime.now();

    for (final sumber in daftarBulanLalu) {
      if (!kumpulanKategoriAda.contains(sumber.kategoriId)) {
        final idBaru = 'ang_${tahunTujuan}_${bulanTujuan}_${sumber.kategoriId}';
        await simpanAtauPerbaruiAnggaran(
          TabelAnggaranCompanion(
            id: Value(idBaru),
            tahun: Value(tahunTujuan),
            bulan: Value(bulanTujuan),
            kategoriId: Value(sumber.kategoriId),
            batasRupiah: Value(sumber.batasRupiah),
            dibuatPada: Value(sekarang),
            diubahPada: Value(sekarang),
          ),
        );
        jumlahDisalin++;
      }
    }
    return jumlahDisalin;
  }

  /// Mengambil daftar realisasi anggaran bulanan lengkap dengan agregasi pengeluaran riil SQL.
  Future<List<ItemRealisasiAnggaran>> ambilRealisasiAnggaranBulan({
    required int tahun,
    required int bulan,
  }) async {
    final daftarAnggaran = await ambilAnggaranBulan(tahun, bulan);
    if (daftarAnggaran.isEmpty) return [];

    final rentang = ambilRentangBulanAnggaran(tahun: tahun, bulan: bulan);
    final petaPengeluaran = await _repoTransaksi
        .hitungPengeluaranPerKategoriBulanSQL(
          awalBulan: rentang.mulai,
          akhirBulan: rentang.selesai,
        );

    final semuaKategori = await _db.select(_db.tabelKategori).get();
    final petaKategori = {for (final k in semuaKategori) k.id: k};

    final hasil = <ItemRealisasiAnggaran>[];
    for (final ang in daftarAnggaran) {
      final kat = petaKategori[ang.kategoriId];
      final namaKat = kat?.nama ?? 'Kategori';
      final sifatKat = kat?.sifat ?? 'kebutuhan';
      final terpakai = petaPengeluaran[ang.kategoriId] ?? 0;

      hasil.add(
        ItemRealisasiAnggaran(
          anggaranId: ang.id,
          kategoriId: ang.kategoriId,
          namaKategori: namaKat,
          sifatKategori: sifatKat,
          ikonKategori: kat?.ikon ?? 'pieChart',
          batasRupiah: ang.batasRupiah,
          terpakaiRupiah: terpakai,
        ),
      );
    }
    return hasil;
  }
}
