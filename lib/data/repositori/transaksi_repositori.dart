import 'package:drift/drift.dart';
import '../../perhitungan/perhitungan_keuangan.dart';
import '../basis_data.dart';

/// Repositori untuk mengelola baris catatan transaksi keuangan.
class TransaksiRepositori {
  const TransaksiRepositori(this._db);

  final BasisDataFunda _db;

  /// Memantau seluruh transaksi, diurutkan dari yang terbaru (waktuTransaksi descending).
  Stream<List<EntitasTransaksi>> pantauSemuaTransaksi() {
    final kueri = _db.select(_db.tabelTransaksi)
      ..orderBy([
        (t) =>
            OrderingTerm(expression: t.waktuTransaksi, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.dibuatPada, mode: OrderingMode.desc),
      ]);
    return kueri.watch();
  }

  /// Memantau riwayat transaksi dengan paginasi dan filter di tingkat SQL.
  Stream<List<EntitasTransaksi>> pantauTransaksiBerhalaman({
    int limit = 50,
    int offset = 0,
    String? kataKunci,
    String? dompetId,
    String? kategoriId,
    String? sifat,
    String? jenis,
    DateTime? mulai,
    DateTime? selesai,
  }) {
    final kueri = _susunKueriTransaksi(
      limit: limit,
      offset: offset,
      kataKunci: kataKunci,
      dompetId: dompetId,
      kategoriId: kategoriId,
      sifat: sifat,
      jenis: jenis,
      mulai: mulai,
      selesai: selesai,
    );
    return kueri.watch();
  }

  /// Mengambil riwayat transaksi berhalaman sekali panggil.
  Future<List<EntitasTransaksi>> ambilTransaksiBerhalaman({
    int limit = 50,
    int offset = 0,
    String? kataKunci,
    String? dompetId,
    String? kategoriId,
    String? sifat,
    String? jenis,
    DateTime? mulai,
    DateTime? selesai,
  }) {
    final kueri = _susunKueriTransaksi(
      limit: limit,
      offset: offset,
      kataKunci: kataKunci,
      dompetId: dompetId,
      kategoriId: kategoriId,
      sifat: sifat,
      jenis: jenis,
      mulai: mulai,
      selesai: selesai,
    );
    return kueri.get();
  }

  SimpleSelectStatement<$TabelTransaksiTable, EntitasTransaksi>
  _susunKueriTransaksi({
    required int limit,
    required int offset,
    String? kataKunci,
    String? dompetId,
    String? kategoriId,
    String? sifat,
    String? jenis,
    DateTime? mulai,
    DateTime? selesai,
  }) {
    final kueri = _db.select(_db.tabelTransaksi);

    kueri.where((t) {
      Expression<bool> kondisi = const Constant(true);

      if (dompetId != null) {
        kondisi =
            kondisi &
            (t.dompetId.equals(dompetId) | t.dompetTujuanId.equals(dompetId));
      }

      if (kategoriId != null) {
        kondisi = kondisi & t.kategoriId.equals(kategoriId);
      }

      if (sifat != null) {
        final kueriIdKategoriSifat = _db.selectOnly(_db.tabelKategori)
          ..addColumns([_db.tabelKategori.id])
          ..where(_db.tabelKategori.sifat.equals(sifat));
        kondisi = kondisi & t.kategoriId.isInQuery(kueriIdKategoriSifat);
      }

      if (jenis != null) {
        kondisi = kondisi & t.jenis.equals(jenis);
      }

      if (mulai != null) {
        kondisi = kondisi & t.waktuTransaksi.isBiggerOrEqualValue(mulai);
      }

      if (selesai != null) {
        kondisi = kondisi & t.waktuTransaksi.isSmallerOrEqualValue(selesai);
      }

      if (kataKunci != null && kataKunci.trim().isNotEmpty) {
        final pola = '%${kataKunci.trim().toLowerCase()}%';
        // Cocokkan catatan atau nama kategori
        final kueriIdKategori = _db.selectOnly(_db.tabelKategori)
          ..addColumns([_db.tabelKategori.id])
          ..where(_db.tabelKategori.nama.lower().like(pola));

        kondisi =
            kondisi &
            (t.catatan.lower().like(pola) |
                t.kategoriId.isInQuery(kueriIdKategori));
      }

      return kondisi;
    });

    kueri.orderBy([
      (t) =>
          OrderingTerm(expression: t.waktuTransaksi, mode: OrderingMode.desc),
      (t) => OrderingTerm(expression: t.dibuatPada, mode: OrderingMode.desc),
    ]);

    kueri.limit(limit, offset: offset);
    return kueri;
  }

  /// Memantau transaksi yang terkait dengan suatu dompet (sebagai asal maupun tujuan).
  Stream<List<EntitasTransaksi>> pantauTransaksiDompet(
    String dompetId, {
    int limit = 50,
    int offset = 0,
  }) {
    final kueri = _db.select(_db.tabelTransaksi)
      ..where(
        (t) => t.dompetId.equals(dompetId) | t.dompetTujuanId.equals(dompetId),
      )
      ..orderBy([
        (t) =>
            OrderingTerm(expression: t.waktuTransaksi, mode: OrderingMode.desc),
      ])
      ..limit(limit, offset: offset);
    return kueri.watch();
  }

  /// Mengambil semua transaksi sekali panggil.
  Future<List<EntitasTransaksi>> ambilSemuaTransaksi() {
    final kueri = _db.select(_db.tabelTransaksi)
      ..orderBy([
        (t) =>
            OrderingTerm(expression: t.waktuTransaksi, mode: OrderingMode.desc),
      ]);
    return kueri.get();
  }

  /// Mengambil transaksi berdasarkan ID.
  Future<EntitasTransaksi?> ambilTransaksiBerdasarkanId(String id) {
    return (_db.select(
      _db.tabelTransaksi,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Menambah transaksi baru ke database.
  Future<int> tambahTransaksi(TabelTransaksiCompanion transaksi) {
    return _db.into(_db.tabelTransaksi).insert(transaksi);
  }

  /// Memperbarui baris transaksi yang sudah ada.
  Future<bool> perbaruiTransaksi(TabelTransaksiCompanion transaksi) {
    return _db.update(_db.tabelTransaksi).replace(transaksi);
  }

  /// Menghapus transaksi berdasarkan ID.
  Future<int> hapusTransaksi(String id) {
    return (_db.delete(_db.tabelTransaksi)..where((t) => t.id.equals(id))).go();
  }

  // =========================================================================
  // METODE AGREGASI SQL (OPTIMASI PERFORMA SKALA BESAR)
  // =========================================================================

  /// Menghitung saldo dompet menggunakan agregasi murni di level SQL (SUM/GROUP BY).
  /// Saldo = Saldo Awal + Masuk - Keluar + Penyesuaian Masuk - Penyesuaian Keluar
  ///         + Transfer Masuk - Transfer Keluar - Biaya Admin.
  Future<int> hitungSaldoDompetSQL({
    required String dompetId,
    required int saldoAwalRupiah,
  }) async {
    const sql = '''
      SELECT COALESCE(SUM(
        CASE
          WHEN jenis = 'masuk' AND dompet_id = ? THEN jumlah_rupiah
          WHEN jenis = 'penyesuaian_masuk' AND dompet_id = ? THEN jumlah_rupiah
          WHEN jenis = 'transfer' AND dompet_tujuan_id = ? THEN jumlah_rupiah
          WHEN jenis = 'keluar' AND dompet_id = ? THEN -jumlah_rupiah
          WHEN jenis = 'penyesuaian_keluar' AND dompet_id = ? THEN -jumlah_rupiah
          WHEN jenis = 'transfer' AND dompet_id = ? THEN -(jumlah_rupiah + biaya_admin_rupiah)
          ELSE 0
        END
      ), 0) AS mutasi
      FROM tabel_transaksi
      WHERE dompet_id = ? OR dompet_tujuan_id = ?;
    ''';

    final baris = await _db
        .customSelect(
          sql,
          variables: [
            Variable.withString(dompetId),
            Variable.withString(dompetId),
            Variable.withString(dompetId),
            Variable.withString(dompetId),
            Variable.withString(dompetId),
            Variable.withString(dompetId),
            Variable.withString(dompetId),
            Variable.withString(dompetId),
          ],
          readsFrom: {_db.tabelTransaksi},
        )
        .getSingle();

    final mutasi = baris.read<int>('mutasi');
    return saldoAwalRupiah + mutasi;
  }

  /// Stream reaktif untuk menghitung saldo dompet lewat agregasi SQL.
  Stream<int> pantauSaldoDompetSQL({
    required String dompetId,
    required int saldoAwalRupiah,
  }) {
    const sql = '''
      SELECT COALESCE(SUM(
        CASE
          WHEN jenis = 'masuk' AND dompet_id = ? THEN jumlah_rupiah
          WHEN jenis = 'penyesuaian_masuk' AND dompet_id = ? THEN jumlah_rupiah
          WHEN jenis = 'transfer' AND dompet_tujuan_id = ? THEN jumlah_rupiah
          WHEN jenis = 'keluar' AND dompet_id = ? THEN -jumlah_rupiah
          WHEN jenis = 'penyesuaian_keluar' AND dompet_id = ? THEN -jumlah_rupiah
          WHEN jenis = 'transfer' AND dompet_id = ? THEN -(jumlah_rupiah + biaya_admin_rupiah)
          ELSE 0
        END
      ), 0) AS mutasi
      FROM tabel_transaksi
      WHERE dompet_id = ? OR dompet_tujuan_id = ?;
    ''';

    return _db
        .customSelect(
          sql,
          variables: [
            Variable.withString(dompetId),
            Variable.withString(dompetId),
            Variable.withString(dompetId),
            Variable.withString(dompetId),
            Variable.withString(dompetId),
            Variable.withString(dompetId),
            Variable.withString(dompetId),
            Variable.withString(dompetId),
          ],
          readsFrom: {_db.tabelTransaksi},
        )
        .watchSingle()
        .map((baris) {
          final mutasi = baris.read<int>('mutasi');
          return saldoAwalRupiah + mutasi;
        });
  }

  /// Menghitung arus kas untuk rentang waktu tertentu lewat agregasi SQL.
  Future<HasilArusKas> hitungArusKasSQL({
    required DateTime mulai,
    required DateTime selesai,
  }) async {
    const sql = '''
      SELECT
        COALESCE(SUM(CASE WHEN jenis = 'masuk' THEN jumlah_rupiah ELSE 0 END), 0) AS total_masuk,
        COALESCE(SUM(
          CASE
            WHEN jenis = 'keluar' THEN jumlah_rupiah
            WHEN jenis = 'transfer' THEN biaya_admin_rupiah
            ELSE 0
          END
        ), 0) AS total_keluar
      FROM tabel_transaksi
      WHERE waktu_transaksi >= ? AND waktu_transaksi <= ?;
    ''';

    final mulaiUnix = mulai.toUtc().millisecondsSinceEpoch ~/ 1000;
    final selesaiUnix = selesai.toUtc().millisecondsSinceEpoch ~/ 1000;

    final baris = await _db
        .customSelect(
          sql,
          variables: [
            Variable.withInt(mulaiUnix),
            Variable.withInt(selesaiUnix),
          ],
          readsFrom: {_db.tabelTransaksi},
        )
        .getSingle();

    final masuk = baris.read<int>('total_masuk');
    final keluar = baris.read<int>('total_keluar');
    return HasilArusKas(
      totalMasuk: masuk,
      totalKeluar: keluar,
      selisih: masuk - keluar,
    );
  }

  /// Stream reaktif arus kas agregasi SQL.
  Stream<HasilArusKas> pantauArusKasSQL({
    required DateTime mulai,
    required DateTime selesai,
  }) {
    const sql = '''
      SELECT
        COALESCE(SUM(CASE WHEN jenis = 'masuk' THEN jumlah_rupiah ELSE 0 END), 0) AS total_masuk,
        COALESCE(SUM(
          CASE
            WHEN jenis = 'keluar' THEN jumlah_rupiah
            WHEN jenis = 'transfer' THEN biaya_admin_rupiah
            ELSE 0
          END
        ), 0) AS total_keluar
      FROM tabel_transaksi
      WHERE waktu_transaksi >= ? AND waktu_transaksi <= ?;
    ''';

    final mulaiUnix = mulai.toUtc().millisecondsSinceEpoch ~/ 1000;
    final selesaiUnix = selesai.toUtc().millisecondsSinceEpoch ~/ 1000;

    return _db
        .customSelect(
          sql,
          variables: [
            Variable.withInt(mulaiUnix),
            Variable.withInt(selesaiUnix),
          ],
          readsFrom: {_db.tabelTransaksi},
        )
        .watchSingle()
        .map((baris) {
          final masuk = baris.read<int>('total_masuk');
          final keluar = baris.read<int>('total_keluar');
          return HasilArusKas(
            totalMasuk: masuk,
            totalKeluar: keluar,
            selisih: masuk - keluar,
          );
        });
  }

  /// Menghitung subjumlah harian (masuk - keluar hari itu) untuk rentang waktu hari tertentu via agregasi SQL.
  Future<int> hitungSubjumlahHarianSQL({
    required DateTime awalHari,
    required DateTime akhirHari,
  }) async {
    const sql = '''
      SELECT
        COALESCE(SUM(CASE WHEN jenis = 'masuk' THEN jumlah_rupiah ELSE 0 END), 0) -
        COALESCE(SUM(
          CASE
            WHEN jenis = 'keluar' THEN jumlah_rupiah
            WHEN jenis = 'transfer' THEN biaya_admin_rupiah
            ELSE 0
          END
        ), 0) AS selisih_hari
      FROM tabel_transaksi
      WHERE waktu_transaksi >= ? AND waktu_transaksi <= ?;
    ''';

    final mulaiUnix = awalHari.toUtc().millisecondsSinceEpoch ~/ 1000;
    final selesaiUnix = akhirHari.toUtc().millisecondsSinceEpoch ~/ 1000;

    final baris = await _db
        .customSelect(
          sql,
          variables: [
            Variable.withInt(mulaiUnix),
            Variable.withInt(selesaiUnix),
          ],
          readsFrom: {_db.tabelTransaksi},
        )
        .getSingle();

    return baris.read<int>('selisih_hari');
  }

  /// Menghitung total pengeluaran per kategori dalam satu rentang bulan kalender (untuk realisasi anggaran).
  Future<Map<String, int>> hitungPengeluaranPerKategoriBulanSQL({
    required DateTime awalBulan,
    required DateTime akhirBulan,
  }) async {
    const sql = '''
      SELECT
        kategori_id,
        COALESCE(SUM(jumlah_rupiah), 0) AS total_pengeluaran
      FROM tabel_transaksi
      WHERE jenis = 'keluar'
        AND kategori_id IS NOT NULL
        AND waktu_transaksi >= ?
        AND waktu_transaksi <= ?
      GROUP BY kategori_id;
    ''';

    final mulaiUnix = awalBulan.toUtc().millisecondsSinceEpoch ~/ 1000;
    final selesaiUnix = akhirBulan.toUtc().millisecondsSinceEpoch ~/ 1000;

    final baris = await _db
        .customSelect(
          sql,
          variables: [
            Variable.withInt(mulaiUnix),
            Variable.withInt(selesaiUnix),
          ],
          readsFrom: {_db.tabelTransaksi},
        )
        .get();

    final peta = <String, int>{};
    for (final b in baris) {
      final katId = b.read<String>('kategori_id');
      final total = b.read<int>('total_pengeluaran');
      peta[katId] = total;
    }
    return peta;
  }
}
