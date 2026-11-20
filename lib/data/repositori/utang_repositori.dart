import 'package:drift/drift.dart';
import '../basis_data.dart';
import '../model/arah_penyesuaian_utang.dart';
import '../../perhitungan/perhitungan_utang_dashboard.dart';
import '../../perhitungan/perhitungan_umpan_balik_belajar.dart';

/// Item gabungan riwayat transaksi pembayaran utang.
class ItemRiwayatPembayaranUtang {
  const ItemRiwayatPembayaranUtang({
    required this.pembayaranId,
    required this.transaksiId,
    required this.utangId,
    required this.jumlahRupiah,
    required this.waktuTransaksi,
    this.catatan,
    required this.namaDompet,
  });

  final String pembayaranId;
  final String transaksiId;
  final String utangId;
  final int jumlahRupiah;
  final DateTime waktuTransaksi;
  final String? catatan;
  final String namaDompet;
}

/// Repositori untuk mengelola utang, pembayaran, dan penyesuaian sisa utang.
class UtangRepositori {
  const UtangRepositori(this._db);

  final BasisDataFunda _db;
  static int _pencacahUnik = 0;

  /// Memantau seluruh utang aktif (status == 'aktif').
  Stream<List<EntitasUtang>> pantauDaftarUtangAktif() {
    final kueri = _db.select(_db.tabelUtang)
      ..where((u) => u.status.equals('aktif'))
      ..orderBy([
        (u) => OrderingTerm(expression: u.dibuatPada, mode: OrderingMode.desc),
      ]);
    return kueri.watch();
  }

  /// Memantau utang yang sudah lunas (status == 'lunas').
  Stream<List<EntitasUtang>> pantauDaftarUtangLunas() {
    final kueri = _db.select(_db.tabelUtang)
      ..where((u) => u.status.equals('lunas'))
      ..orderBy([
        (u) => OrderingTerm(expression: u.dibuatPada, mode: OrderingMode.desc),
      ]);
    return kueri.watch();
  }

  /// Memantau seluruh entitas utang.
  Stream<List<EntitasUtang>> pantauSemuaUtang() {
    final kueri = _db.select(_db.tabelUtang)
      ..orderBy([
        (u) => OrderingTerm(expression: u.dibuatPada, mode: OrderingMode.desc),
      ]);
    return kueri.watch();
  }

  /// Mengambil daftar utang aktif beserta sisa utang saat ini on-demand untuk umpan balik edukatif.
  Future<List<ItemUtangUmpanBalik>> ambilDaftarUtangUmpanBalik() async {
    final daftar = await (_db.select(_db.tabelUtang)
          ..where((u) => u.status.equals('aktif'))
          ..orderBy([
            (u) => OrderingTerm(expression: u.dibuatPada, mode: OrderingMode.desc),
          ]))
        .get();

    final hasil = <ItemUtangUmpanBalik>[];
    for (final u in daftar) {
      final sisa = await hitungSisaUtangSQL(u.id);
      hasil.add(ItemUtangUmpanBalik(
        nama: u.nama,
        sisaRupiah: sisa,
        pokokAwalRupiah: u.pokokAwalRupiah ?? 0,
        cicilanBulananRupiah: u.cicilanBulananRupiah,
        tenorBulan: u.tenorBulan,
        jenisBunga: u.jenisBunga,
        bungaBasisPoinPerTahun: u.bungaBasisPoinPerTahun,
        status: u.status,
      ));
    }
    return hasil;
  }

  /// Mengambil data satu utang berdasarkan ID.
  Future<EntitasUtang?> ambilUtangBerdasarkanId(String id) {
    return (_db.select(
      _db.tabelUtang,
    )..where((u) => u.id.equals(id))).getSingleOrNull();
  }

  /// Menambah utang baru ke database.
  Future<String> buatUtang({
    required String nama,
    required String jenis,
    String? pemberi,
    required int sisaAwalRupiah,
    int? pokokAwalRupiah,
    required String jenisBunga,
    int bungaBasisPoinPerTahun = 0,
    int? tenorBulan,
    int cicilanBulananRupiah = 0,
    int? tanggalJatuhTempoBulanan,
    DateTime? tanggalMulai,
  }) async {
    final id =
        'utg_${DateTime.now().microsecondsSinceEpoch}_${++_pencacahUnik}';
    final sekarang = DateTime.now();

    await _db
        .into(_db.tabelUtang)
        .insert(
          TabelUtangCompanion(
            id: Value(id),
            nama: Value(nama),
            jenis: Value(jenis),
            pemberi: Value(pemberi),
            sisaAwalRupiah: Value(sisaAwalRupiah),
            pokokAwalRupiah: Value(pokokAwalRupiah),
            jenisBunga: Value(jenisBunga),
            bungaBasisPoinPerTahun: Value(bungaBasisPoinPerTahun),
            tenorBulan: Value(tenorBulan),
            cicilanBulananRupiah: Value(cicilanBulananRupiah),
            tanggalJatuhTempoBulanan: Value(tanggalJatuhTempoBulanan),
            tanggalMulai: Value(tanggalMulai),
            status: const Value('aktif'),
            dibuatPada: Value(sekarang),
          ),
        );

    return id;
  }

  /// Memperbarui informasi utang.
  Future<bool> perbaruiUtang(TabelUtangCompanion utang) {
    return _db.update(_db.tabelUtang).replace(utang);
  }

  /// Mengarsipkan utang.
  Future<int> arsipkanUtang(String utangId) {
    return (_db.update(_db.tabelUtang)..where((u) => u.id.equals(utangId)))
        .write(const TabelUtangCompanion(status: Value('diarsipkan')));
  }

  /// Menghitung sisa utang saat ini menggunakan agregasi murni di level SQLite.
  Future<int> hitungSisaUtangSQL(String utangId) async {
    const sql = '''
      SELECT 
        u.sisa_awal_rupiah,
        COALESCE((
          SELECT SUM(t.jumlah_rupiah)
          FROM tabel_pembayaran_utang pu
          JOIN tabel_transaksi t ON pu.transaksi_id = t.id
          WHERE pu.utang_id = u.id
        ), 0) AS total_bayar,
        COALESCE((
          SELECT SUM(CASE WHEN arah = 'tambah' THEN jumlah_rupiah ELSE -jumlah_rupiah END)
          FROM tabel_penyesuaian_utang
          WHERE utang_id = u.id
        ), 0) AS total_penyesuaian
      FROM tabel_utang u
      WHERE u.id = ?;
    ''';

    final baris = await _db
        .customSelect(
          sql,
          variables: [Variable.withString(utangId)],
          readsFrom: {
            _db.tabelUtang,
            _db.tabelPembayaranUtang,
            _db.tabelTransaksi,
            _db.tabelPenyesuaianUtang,
          },
        )
        .getSingleOrNull();

    if (baris == null) return 0;

    final sisaAwal = baris.read<int>('sisa_awal_rupiah');
    final totalBayar = baris.read<int>('total_bayar');
    final totalPenyesuaian = baris.read<int>('total_penyesuaian');

    final sisa = sisaAwal - totalBayar + totalPenyesuaian;
    return sisa < 0 ? 0 : sisa;
  }

  /// Stream reaktif untuk sisa utang spesifik.
  Stream<int> pantauSisaUtangSQL(String utangId) {
    const sql = '''
      SELECT 
        u.sisa_awal_rupiah,
        COALESCE((
          SELECT SUM(t.jumlah_rupiah)
          FROM tabel_pembayaran_utang pu
          JOIN tabel_transaksi t ON pu.transaksi_id = t.id
          WHERE pu.utang_id = u.id
        ), 0) AS total_bayar,
        COALESCE((
          SELECT SUM(CASE WHEN arah = 'tambah' THEN jumlah_rupiah ELSE -jumlah_rupiah END)
          FROM tabel_penyesuaian_utang
          WHERE utang_id = u.id
        ), 0) AS total_penyesuaian
      FROM tabel_utang u
      WHERE u.id = ?;
    ''';

    return _db
        .customSelect(
          sql,
          variables: [Variable.withString(utangId)],
          readsFrom: {
            _db.tabelUtang,
            _db.tabelPembayaranUtang,
            _db.tabelTransaksi,
            _db.tabelPenyesuaianUtang,
          },
        )
        .watchSingleOrNull()
        .map((baris) {
          if (baris == null) return 0;
          final sisaAwal = baris.read<int>('sisa_awal_rupiah');
          final totalBayar = baris.read<int>('total_bayar');
          final totalPenyesuaian = baris.read<int>('total_penyesuaian');
          final sisa = sisaAwal - totalBayar + totalPenyesuaian;
          return sisa < 0 ? 0 : sisa;
        });
  }

  /// Menghitung total sisa seluruh utang yang aktif menggunakan agregasi SQL.
  Future<int> hitungTotalSisaUtangAktifSQL() async {
    const sql = '''
      SELECT 
        COALESCE(SUM(
          u.sisa_awal_rupiah
          - COALESCE((
              SELECT SUM(t.jumlah_rupiah)
              FROM tabel_pembayaran_utang pu
              JOIN tabel_transaksi t ON pu.transaksi_id = t.id
              WHERE pu.utang_id = u.id
            ), 0)
          + COALESCE((
              SELECT SUM(CASE WHEN arah = 'tambah' THEN jumlah_rupiah ELSE -jumlah_rupiah END)
              FROM tabel_penyesuaian_utang
              WHERE utang_id = u.id
            ), 0)
        ), 0) AS total_sisa
      FROM tabel_utang u
      WHERE u.status = 'aktif';
    ''';

    final baris = await _db
        .customSelect(
          sql,
          readsFrom: {
            _db.tabelUtang,
            _db.tabelPembayaranUtang,
            _db.tabelTransaksi,
            _db.tabelPenyesuaianUtang,
          },
        )
        .getSingle();

    return baris.read<int>('total_sisa');
  }

  /// Stream reaktif total sisa utang aktif.
  Stream<int> pantauTotalSisaUtangAktifSQL() {
    const sql = '''
      SELECT 
        COALESCE(SUM(
          u.sisa_awal_rupiah
          - COALESCE((
              SELECT SUM(t.jumlah_rupiah)
              FROM tabel_pembayaran_utang pu
              JOIN tabel_transaksi t ON pu.transaksi_id = t.id
              WHERE pu.utang_id = u.id
            ), 0)
          + COALESCE((
              SELECT SUM(CASE WHEN arah = 'tambah' THEN jumlah_rupiah ELSE -jumlah_rupiah END)
              FROM tabel_penyesuaian_utang
              WHERE utang_id = u.id
            ), 0)
        ), 0) AS total_sisa
      FROM tabel_utang u
      WHERE u.status = 'aktif';
    ''';

    return _db
        .customSelect(
          sql,
          readsFrom: {
            _db.tabelUtang,
            _db.tabelPembayaranUtang,
            _db.tabelTransaksi,
            _db.tabelPenyesuaianUtang,
          },
        )
        .watchSingle()
        .map((b) => b.read<int>('total_sisa'));
  }

  /// Mencatat pembayaran utang:
  /// Dijalankan dalam SATU transaksi database yang atomik.
  /// 1. Membuat transaksi keluar di dompet.
  /// 2. Membuat keterkaitan pembayaran di tabel_pembayaran_utang.
  /// 3. Jika sisa utang menjadi 0, status utang diubah menjadi 'lunas'.
  Future<String> catatPembayaranUtang({
    required String utangId,
    required String dompetId,
    required int jumlahRupiah,
    required DateTime waktu,
    required String kategoriId,
    String? catatan,
  }) async {
    return _db.transaction(() async {
      // 1. Cek sisa utang saat ini
      final sisaSaatIni = await hitungSisaUtangSQL(utangId);
      final validasi = validasiPembayaranUtang(
        jumlahRupiah: jumlahRupiah,
        sisaUtangSaatIni: sisaSaatIni,
      );
      if (!validasi.sukses) {
        throw ArgumentError(validasi.pesanGalat);
      }

      final sekarang = DateTime.now();
      final transaksiId =
          'trx_${sekarang.microsecondsSinceEpoch}_${++_pencacahUnik}';

      // 2. Buat transaksi keluar
      await _db
          .into(_db.tabelTransaksi)
          .insert(
            TabelTransaksiCompanion(
              id: Value(transaksiId),
              jenis: const Value('keluar'),
              jumlahRupiah: Value(jumlahRupiah),
              dompetId: Value(dompetId),
              kategoriId: Value(kategoriId),
              catatan: Value(catatan),
              waktuTransaksi: Value(waktu),
              dibuatPada: Value(sekarang),
              diubahPada: Value(sekarang),
            ),
          );

      // 3. Buat relasi pembayaran
      final pembayaranId =
          'pmb_${sekarang.microsecondsSinceEpoch}_${++_pencacahUnik}';
      await _db
          .into(_db.tabelPembayaranUtang)
          .insert(
            TabelPembayaranUtangCompanion(
              id: Value(pembayaranId),
              utangId: Value(utangId),
              transaksiId: Value(transaksiId),
            ),
          );

      // 4. Periksa apakah sudah lunas
      final sisaBaru = await hitungSisaUtangSQL(utangId);
      if (sisaBaru == 0) {
        await (_db.update(_db.tabelUtang)..where((u) => u.id.equals(utangId)))
            .write(const TabelUtangCompanion(status: Value('lunas')));
      }

      return transaksiId;
    });
  }

  /// Menautkan transaksi yang sudah ada sebagai pembayaran utang (dari form catat transaksi).
  Future<void> tautkanTransaksiKeUtang({
    required String utangId,
    required String transaksiId,
  }) async {
    final sekarang = DateTime.now();
    final pembayaranId =
        'pmb_${sekarang.microsecondsSinceEpoch}_${++_pencacahUnik}';
    await _db
        .into(_db.tabelPembayaranUtang)
        .insert(
          TabelPembayaranUtangCompanion(
            id: Value(pembayaranId),
            utangId: Value(utangId),
            transaksiId: Value(transaksiId),
          ),
        );

    final sisaBaru = await hitungSisaUtangSQL(utangId);
    if (sisaBaru == 0) {
      await (_db.update(_db.tabelUtang)..where((u) => u.id.equals(utangId)))
          .write(const TabelUtangCompanion(status: Value('lunas')));
    }
  }

  /// Mencatat penyesuaian sisa utang (tambah bunga/denda atau kurang koreksi/diskon).
  Future<String> sesuaikanSisaUtang({
    required String utangId,
    required ArahPenyesuaianUtang arah,
    required int jumlahRupiah,
    String? catatan,
    required DateTime tanggal,
  }) async {
    if (jumlahRupiah <= 0) {
      throw ArgumentError('Jumlah penyesuaian harus lebih besar dari Rp 0.');
    }

    final id =
        'adj_${DateTime.now().microsecondsSinceEpoch}_${++_pencacahUnik}';
    final sekarang = DateTime.now();

    await _db
        .into(_db.tabelPenyesuaianUtang)
        .insert(
          TabelPenyesuaianUtangCompanion(
            id: Value(id),
            utangId: Value(utangId),
            arah: Value(arah.kode),
            jumlahRupiah: Value(jumlahRupiah),
            catatan: Value(catatan),
            tanggal: Value(tanggal),
            dibuatPada: Value(sekarang),
          ),
        );

    // Update status lunas jika sisa menjadi 0, atau aktifkan kembali jika bertambah
    final sisaBaru = await hitungSisaUtangSQL(utangId);
    if (sisaBaru == 0) {
      await (_db.update(_db.tabelUtang)..where((u) => u.id.equals(utangId)))
          .write(const TabelUtangCompanion(status: Value('lunas')));
    } else {
      final utang = await ambilUtangBerdasarkanId(utangId);
      if (utang != null && utang.status == 'lunas') {
        await (_db.update(_db.tabelUtang)..where((u) => u.id.equals(utangId)))
            .write(const TabelUtangCompanion(status: Value('aktif')));
      }
    }

    return id;
  }

  /// Memantau riwayat pembayaran untuk satu utang tertentu.
  Stream<List<ItemRiwayatPembayaranUtang>> pantauRiwayatPembayaranUtang(
    String utangId,
  ) {
    final kueri =
        _db.select(_db.tabelPembayaranUtang).join([
            innerJoin(
              _db.tabelTransaksi,
              _db.tabelTransaksi.id.equalsExp(
                _db.tabelPembayaranUtang.transaksiId,
              ),
            ),
            innerJoin(
              _db.tabelDompet,
              _db.tabelDompet.id.equalsExp(_db.tabelTransaksi.dompetId),
            ),
          ])
          ..where(_db.tabelPembayaranUtang.utangId.equals(utangId))
          ..orderBy([
            OrderingTerm(
              expression: _db.tabelTransaksi.waktuTransaksi,
              mode: OrderingMode.desc,
            ),
          ]);

    return kueri.watch().map((baris) {
      return baris.map((b) {
        final pmb = b.readTable(_db.tabelPembayaranUtang);
        final trx = b.readTable(_db.tabelTransaksi);
        final dmp = b.readTable(_db.tabelDompet);
        return ItemRiwayatPembayaranUtang(
          pembayaranId: pmb.id,
          transaksiId: trx.id,
          utangId: pmb.utangId,
          jumlahRupiah: trx.jumlahRupiah,
          waktuTransaksi: trx.waktuTransaksi,
          catatan: trx.catatan,
          namaDompet: dmp.nama,
        );
      }).toList();
    });
  }

  /// Memantau riwayat penyesuaian untuk satu utang tertentu.
  Stream<List<EntitasPenyesuaianUtang>> pantauRiwayatPenyesuaianUtang(
    String utangId,
  ) {
    final kueri = _db.select(_db.tabelPenyesuaianUtang)
      ..where((p) => p.utangId.equals(utangId))
      ..orderBy([
        (p) => OrderingTerm(expression: p.tanggal, mode: OrderingMode.desc),
      ]);
    return kueri.watch();
  }

  /// Menemukan relasi pembayaran utang berdasarkan transaksiId (jika transaksi terkait utang).
  Future<EntitasPembayaranUtang?> cariPembayaranBerdasarkanTransaksiId(
    String transaksiId,
  ) {
    return (_db.select(
      _db.tabelPembayaranUtang,
    )..where((p) => p.transaksiId.equals(transaksiId))).getSingleOrNull();
  }
}
