import 'package:drift/drift.dart';
import '../../perhitungan/perhitungan_keuangan.dart';
import '../../perhitungan/perhitungan_utang_dashboard.dart';
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
      (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
      (t) => OrderingTerm(expression: t.dibuatPada, mode: OrderingMode.desc),
    ]);

    kueri.limit(limit, offset: offset);
    return kueri;
  }

  /// Mengambil transaksi menggunakan paginasi berbasis kursor (waktuTransaksi + id).
  /// Mencegah anomali baris duplikat atau terlewat saat data baru ditambah/dihapus di halaman atas.
  Future<List<EntitasTransaksi>> ambilTransaksiKursor({
    int limit = 50,
    DateTime? kursorWaktu,
    String? kursorId,
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

      // Filter Kursor (waktuTransaksi < kursorWaktu ATAU (waktuTransaksi == kursorWaktu DAN id < kursorId))
      if (kursorWaktu != null && kursorId != null) {
        kondisi =
            kondisi &
            (t.waktuTransaksi.isSmallerThanValue(kursorWaktu) |
                (t.waktuTransaksi.equals(kursorWaktu) &
                    t.id.isSmallerThanValue(kursorId)));
      } else if (kursorWaktu != null) {
        kondisi = kondisi & t.waktuTransaksi.isSmallerThanValue(kursorWaktu);
      }

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
      (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
    ]);

    kueri.limit(limit);
    return kueri.get();
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

  /// Menghitung pemasukan bulanan rata-rata via kueri agregasi SQL efisien:
  /// - Mengagregasikan pemasukan per bulan untuk 3 bulan kalender terakhir yang sudah selesai.
  /// - Jika 3 bulan kosong, agregasikan bulan berjalan.
  /// - Mengembalikan HasilPemasukanRataRata (identik dengan fungsi murni, O(1) baris ditarik ke Dart).
  Future<HasilPemasukanRataRata> hitungPemasukanRataRataSQL({
    required DateTime waktuSekarang,
  }) async {
    final waktuLokal = waktuSekarang.toLocal();
    final offsetDetik = waktuLokal.timeZoneOffset.inSeconds;

    final bulanTigaLalu = <({int tahun, int bulan})>[];
    var kursorTahun = waktuLokal.year;
    var kursorBulan = waktuLokal.month;

    for (var i = 0; i < 3; i++) {
      kursorBulan--;
      if (kursorBulan == 0) {
        kursorBulan = 12;
        kursorTahun--;
      }
      bulanTigaLalu.add((tahun: kursorTahun, bulan: kursorBulan));
    }

    final awalRentangLokal = DateTime(bulanTigaLalu.last.tahun, bulanTigaLalu.last.bulan, 1);
    final akhirRentangLokal = DateTime(waktuLokal.year, waktuLokal.month + 1, 0, 23, 59, 59);

    final mulaiUnix = awalRentangLokal.toUtc().millisecondsSinceEpoch ~/ 1000;
    final selesaiUnix = akhirRentangLokal.toUtc().millisecondsSinceEpoch ~/ 1000;

    const sql = '''
      SELECT 
        strftime('%Y_%m', datetime(waktu_transaksi + ?, 'unixepoch')) AS periode,
        SUM(jumlah_rupiah) AS total
      FROM tabel_transaksi
      WHERE jenis = 'masuk' AND waktu_transaksi >= ? AND waktu_transaksi <= ?
      GROUP BY strftime('%Y_%m', datetime(waktu_transaksi + ?, 'unixepoch'));
    ''';

    final baris = await _db.customSelect(
      sql,
      variables: [
        Variable.withInt(offsetDetik),
        Variable.withInt(mulaiUnix),
        Variable.withInt(selesaiUnix),
        Variable.withInt(offsetDetik),
      ],
      readsFrom: {_db.tabelTransaksi},
    ).get();

    final petaPemasukan = <String, int>{};
    for (final b in baris) {
      final p = b.read<String>('periode');
      final tot = b.read<int>('total');
      petaPemasukan[p] = tot;
    }

    var total3Bulan = 0;
    var adaData3Bulan = false;

    for (final periode in bulanTigaLalu) {
      final bulanStr = periode.bulan.toString().padLeft(2, '0');
      final kunci = '${periode.tahun}_$bulanStr';
      final nominal = petaPemasukan[kunci] ?? 0;
      if (nominal > 0) {
        adaData3Bulan = true;
      }
      total3Bulan += nominal;
    }

    if (adaData3Bulan) {
      return HasilPemasukanRataRata(
        nilaiRupiah: total3Bulan ~/ 3,
        dasar: DasarPemasukanRataRata.rataRata3Bulan,
      );
    }

    final bulanBerjalanStr = waktuLokal.month.toString().padLeft(2, '0');
    final kunciBerjalan = '${waktuLokal.year}_$bulanBerjalanStr';
    final pemasukanBulanBerjalan = petaPemasukan[kunciBerjalan] ?? 0;

    if (pemasukanBulanBerjalan > 0) {
      return HasilPemasukanRataRata(
        nilaiRupiah: pemasukanBulanBerjalan,
        dasar: DasarPemasukanRataRata.bulanBerjalan,
      );
    }

    return const HasilPemasukanRataRata(
      nilaiRupiah: 0,
      dasar: DasarPemasukanRataRata.belumAda,
    );
  }

  /// Stream reaktif pemasukan bulanan rata-rata agregasi SQL.
  Stream<HasilPemasukanRataRata> pantauPemasukanRataRataSQL({
    required DateTime waktuSekarang,
  }) {
    final waktuLokal = waktuSekarang.toLocal();
    final offsetDetik = waktuLokal.timeZoneOffset.inSeconds;

    final bulanTigaLalu = <({int tahun, int bulan})>[];
    var kursorTahun = waktuLokal.year;
    var kursorBulan = waktuLokal.month;

    for (var i = 0; i < 3; i++) {
      kursorBulan--;
      if (kursorBulan == 0) {
        kursorBulan = 12;
        kursorTahun--;
      }
      bulanTigaLalu.add((tahun: kursorTahun, bulan: kursorBulan));
    }

    final awalRentangLokal = DateTime(bulanTigaLalu.last.tahun, bulanTigaLalu.last.bulan, 1);
    final akhirRentangLokal = DateTime(waktuLokal.year, waktuLokal.month + 1, 0, 23, 59, 59);

    final mulaiUnix = awalRentangLokal.toUtc().millisecondsSinceEpoch ~/ 1000;
    final selesaiUnix = akhirRentangLokal.toUtc().millisecondsSinceEpoch ~/ 1000;

    const sql = '''
      SELECT 
        strftime('%Y_%m', datetime(waktu_transaksi + ?, 'unixepoch')) AS periode,
        SUM(jumlah_rupiah) AS total
      FROM tabel_transaksi
      WHERE jenis = 'masuk' AND waktu_transaksi >= ? AND waktu_transaksi <= ?
      GROUP BY strftime('%Y_%m', datetime(waktu_transaksi + ?, 'unixepoch'));
    ''';

    return _db.customSelect(
      sql,
      variables: [
        Variable.withInt(offsetDetik),
        Variable.withInt(mulaiUnix),
        Variable.withInt(selesaiUnix),
        Variable.withInt(offsetDetik),
      ],
      readsFrom: {_db.tabelTransaksi},
    ).watch().map((baris) {
      final petaPemasukan = <String, int>{};
      for (final b in baris) {
        final p = b.read<String>('periode');
        final tot = b.read<int>('total');
        petaPemasukan[p] = tot;
      }

      var total3Bulan = 0;
      var adaData3Bulan = false;

      for (final periode in bulanTigaLalu) {
        final bulanStr = periode.bulan.toString().padLeft(2, '0');
        final kunci = '${periode.tahun}_$bulanStr';
        final nominal = petaPemasukan[kunci] ?? 0;
        if (nominal > 0) {
          adaData3Bulan = true;
        }
        total3Bulan += nominal;
      }

      if (adaData3Bulan) {
        return HasilPemasukanRataRata(
          nilaiRupiah: total3Bulan ~/ 3,
          dasar: DasarPemasukanRataRata.rataRata3Bulan,
        );
      }

      final bulanBerjalanStr = waktuLokal.month.toString().padLeft(2, '0');
      final kunciBerjalan = '${waktuLokal.year}_$bulanBerjalanStr';
      final pemasukanBulanBerjalan = petaPemasukan[kunciBerjalan] ?? 0;

      if (pemasukanBulanBerjalan > 0) {
        return HasilPemasukanRataRata(
          nilaiRupiah: pemasukanBulanBerjalan,
          dasar: DasarPemasukanRataRata.bulanBerjalan,
        );
      }

      return const HasilPemasukanRataRata(
        nilaiRupiah: 0,
        dasar: DasarPemasukanRataRata.belumAda,
      );
    });
  }

  /// Menghitung total pengeluaran per sifat kategori untuk bulan berjalan (agregasi SQL).
  Stream<Map<String, int>> pantauKomposisiSifatBulanIniSQL(DateTime awalBulan) {
    final mulaiUnix = awalBulan.toUtc().millisecondsSinceEpoch ~/ 1000;
    const sql = '''
      SELECT 
        COALESCE(k.sifat, 'belum_dilabeli') AS sifat, 
        COALESCE(SUM(t.jumlah_rupiah), 0) AS total
      FROM tabel_transaksi t
      LEFT JOIN tabel_kategori k ON t.kategori_id = k.id
      WHERE t.jenis = 'keluar' AND t.waktu_transaksi >= ?
      GROUP BY COALESCE(k.sifat, 'belum_dilabeli');
    ''';

    return _db.customSelect(
      sql,
      variables: [Variable.withInt(mulaiUnix)],
      readsFrom: {_db.tabelTransaksi, _db.tabelKategori},
    ).watch().map((baris) {
      final peta = <String, int>{
        'kebutuhan': 0,
        'keinginan': 0,
        'tabungan': 0,
        'utang': 0,
        'belum_dilabeli': 0,
      };
      for (final b in baris) {
        final s = b.read<String>('sifat');
        final tot = b.read<int>('total');
        peta[s] = tot;
      }
      return peta;
    });
  }

  /// Memantau jumlah transaksi secara reaktif dan ringan (O(1)) tanpa memuat baris ke memori Dart.
  Stream<int> pantauJumlahTransaksi() {
    final countExpr = countAll();
    final query = _db.selectOnly(_db.tabelTransaksi)..addColumns([countExpr]);
    return query.map((row) => row.read(countExpr) ?? 0).watchSingle();
  }
}
