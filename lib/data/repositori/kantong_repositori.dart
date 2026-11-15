import 'package:drift/drift.dart';
import '../../perhitungan/perhitungan_anggaran_tujuan.dart';
import '../basis_data.dart';
import '../model/jenis_alokasi.dart';

/// Repositori untuk mengelola pos alokasi kantong dan mutasi dananya.
class KantongRepositori {
  const KantongRepositori(this._db);

  final BasisDataFunda _db;

  /// Memantau seluruh kantong aktif milik dompet tertentu.
  Stream<List<EntitasKantong>> pantauKantongDompet(String dompetId) {
    final kueri = _db.select(_db.tabelKantong)
      ..where((k) => k.dompetId.equals(dompetId) & k.diarsipkan.equals(false))
      ..orderBy([(k) => OrderingTerm(expression: k.dibuatPada)]);
    return kueri.watch();
  }

  /// Memantau seluruh kantong yang tertaut pada tujuan tertentu (lintas dompet).
  Stream<List<EntitasKantong>> pantauKantongTujuan(String tujuanId) {
    final kueri = _db.select(_db.tabelKantong)
      ..where((k) => k.tujuanId.equals(tujuanId) & k.diarsipkan.equals(false))
      ..orderBy([(k) => OrderingTerm(expression: k.dibuatPada)]);
    return kueri.watch();
  }

  /// Mengambil semua kantong aktif sekali panggil.
  Future<List<EntitasKantong>> ambilSemuaKantongAktif() {
    final kueri = _db.select(_db.tabelKantong)
      ..where((k) => k.diarsipkan.equals(false));
    return kueri.get();
  }

  /// Mengambil kantong berdasarkan ID.
  Future<EntitasKantong?> ambilKantongBerdasarkanId(String id) {
    return (_db.select(
      _db.tabelKantong,
    )..where((k) => k.id.equals(id))).getSingleOrNull();
  }

  /// Mencari kantong yang menautkan dompet dan tujuan tertentu (jika sudah ada).
  Future<EntitasKantong?> cariKantongDompetTujuan({
    required String dompetId,
    required String tujuanId,
  }) {
    return (_db.select(_db.tabelKantong)..where(
          (k) => k.dompetId.equals(dompetId) & k.tujuanId.equals(tujuanId),
        ))
        .getSingleOrNull();
  }

  static int _pencacahUnik = 0;

  /// Mengambil kantong tujuan yang ada atau membuatnya secara otomatis jika belum ada di dompet tersebut.
  Future<EntitasKantong> ambilAtauBuatKantongTujuan({
    required String dompetId,
    required String tujuanId,
    required String namaKantong,
    required String ikon,
    required String warna,
  }) async {
    final ada = await cariKantongDompetTujuan(
      dompetId: dompetId,
      tujuanId: tujuanId,
    );
    if (ada != null) return ada;

    final id = 'ktg_${DateTime.now().microsecondsSinceEpoch}_${++_pencacahUnik}';
    final sekarang = DateTime.now();
    await tambahKantong(
      TabelKantongCompanion(
        id: Value(id),
        nama: Value(namaKantong),
        dompetId: Value(dompetId),
        tujuanId: Value(tujuanId),
        ikon: Value(ikon),
        warna: Value(warna),
        diarsipkan: const Value(false),
        dibuatPada: Value(sekarang),
      ),
    );
    return (await ambilKantongBerdasarkanId(id))!;
  }

  /// Helper untuk membuat kantong bebas tanpa tautan tujuan.
  Future<String> buatKantongBebas({
    required String nama,
    required String dompetId,
    required String ikon,
    required String warna,
  }) async {
    final id = 'ktg_${DateTime.now().microsecondsSinceEpoch}_${++_pencacahUnik}';
    final sekarang = DateTime.now();
    await tambahKantong(
      TabelKantongCompanion(
        id: Value(id),
        nama: Value(nama),
        dompetId: Value(dompetId),
        tujuanId: const Value(null),
        ikon: Value(ikon),
        warna: Value(warna),
        diarsipkan: const Value(false),
        dibuatPada: Value(sekarang),
      ),
    );
    return id;
  }

  /// Helper untuk alokasi dana kantong (isi atau ambil).
  Future<void> alokasikanDanaKantong({
    required String kantongId,
    required String jenis,
    required int jumlahRupiah,
    String? catatan,
  }) async {
    final id = 'alk_${DateTime.now().microsecondsSinceEpoch}_${++_pencacahUnik}';
    final sekarang = DateTime.now();
    await tambahAlokasiKantong(
      TabelAlokasiKantongCompanion(
        id: Value(id),
        kantongId: Value(kantongId),
        jenis: Value(jenis),
        jumlahRupiah: Value(jumlahRupiah),
        catatan: Value(catatan),
        dibuatPada: Value(sekarang),
      ),
    );
  }

  /// Menambah kantong baru ke dalam dompet.
  /// Memastikan unik pada (dompet_id, tujuan_id) bila tujuan_id terisi.
  Future<int> tambahKantong(TabelKantongCompanion kantong) async {
    final tujuanId = kantong.tujuanId.value;
    final dompetId = kantong.dompetId.value;

    if (tujuanId != null) {
      final sudahAda = await cariKantongDompetTujuan(
        dompetId: dompetId,
        tujuanId: tujuanId,
      );
      if (sudahAda != null) {
        throw StateError(
          'Kantong untuk tujuan ini sudah tersedia di dompet yang dipilih.',
        );
      }
    }

    return _db.into(_db.tabelKantong).insert(kantong);
  }

  /// Memperbarui informasi kantong.
  Future<bool> perbaruiKantong(TabelKantongCompanion kantong) {
    return _db.update(_db.tabelKantong).replace(kantong);
  }

  /// Mengarsipkan kantong.
  /// Aturan integritas: Kantong HANYA boleh diarsipkan jika saldo kantong saat ini bernilai 0.
  Future<bool> arsipkanKantong(String id) async {
    final saldo = await hitungSaldoKantongSQL(id);
    if (saldo > 0) {
      throw StateError(
        'Kantong hanya dapat diarsipkan jika saldonya Rp 0. '
        'Ambil atau alokasikan dananya terlebih dahulu ya.',
      );
    }

    final barisDiubah =
        await (_db.update(_db.tabelKantong)..where((k) => k.id.equals(id)))
            .write(const TabelKantongCompanion(diarsipkan: Value(true)));
    return barisDiubah > 0;
  }

  // =========================================================================
  // ALOKASI MUTASI KANTONG (ISI & AMBIL)
  // =========================================================================

  /// Menghitung saldo satu kantong menggunakan agregasi SQL.
  Future<int> hitungSaldoKantongSQL(String kantongId) async {
    const sql = '''
      SELECT COALESCE(SUM(
        CASE
          WHEN jenis = 'isi' THEN jumlah_rupiah
          WHEN jenis = 'ambil' THEN -jumlah_rupiah
          ELSE 0
        END
      ), 0) AS saldo
      FROM tabel_alokasi_kantong
      WHERE kantong_id = ?;
    ''';

    final baris = await _db
        .customSelect(
          sql,
          variables: [Variable.withString(kantongId)],
          readsFrom: {_db.tabelAlokasiKantong},
        )
        .getSingle();

    return baris.read<int>('saldo');
  }

  /// Stream saldo kantong reaktif.
  Stream<int> pantauSaldoKantongSQL(String kantongId) {
    const sql = '''
      SELECT COALESCE(SUM(
        CASE
          WHEN jenis = 'isi' THEN jumlah_rupiah
          WHEN jenis = 'ambil' THEN -jumlah_rupiah
          ELSE 0
        END
      ), 0) AS saldo
      FROM tabel_alokasi_kantong
      WHERE kantong_id = ?;
    ''';

    return _db
        .customSelect(
          sql,
          variables: [Variable.withString(kantongId)],
          readsFrom: {_db.tabelAlokasiKantong},
        )
        .watchSingle()
        .map((baris) => baris.read<int>('saldo'));
  }

  /// Menghitung total dana terkumpul pada suatu tujuan dari seluruh kantong tertaut via agregasi SQL.
  Future<int> hitungDanaTujuanSQL(String tujuanId) async {
    const sql = '''
      SELECT COALESCE(SUM(
        CASE
          WHEN a.jenis = 'isi' THEN a.jumlah_rupiah
          WHEN a.jenis = 'ambil' THEN -a.jumlah_rupiah
          ELSE 0
        END
      ), 0) AS total_dana
      FROM tabel_alokasi_kantong a
      INNER JOIN tabel_kantong k ON a.kantong_id = k.id
      WHERE k.tujuan_id = ? AND k.diarsipkan = 0;
    ''';

    final baris = await _db
        .customSelect(
          sql,
          variables: [Variable.withString(tujuanId)],
          readsFrom: {_db.tabelAlokasiKantong, _db.tabelKantong},
        )
        .getSingle();

    return baris.read<int>('total_dana');
  }

  /// Stream dana tujuan reaktif.
  Stream<int> pantauDanaTujuanSQL(String tujuanId) {
    const sql = '''
      SELECT COALESCE(SUM(
        CASE
          WHEN a.jenis = 'isi' THEN a.jumlah_rupiah
          WHEN a.jenis = 'ambil' THEN -a.jumlah_rupiah
          ELSE 0
        END
      ), 0) AS total_dana
      FROM tabel_alokasi_kantong a
      INNER JOIN tabel_kantong k ON a.kantong_id = k.id
      WHERE k.tujuan_id = ? AND k.diarsipkan = 0;
    ''';

    return _db
        .customSelect(
          sql,
          variables: [Variable.withString(tujuanId)],
          readsFrom: {_db.tabelAlokasiKantong, _db.tabelKantong},
        )
        .watchSingle()
        .map((baris) => baris.read<int>('total_dana'));
  }

  /// Menambah mutasi alokasi saldo kantong (isi atau ambil).
  /// Menolak pengambilan yang melebihi saldo kantong saat ini.
  Future<int> tambahAlokasiKantong(TabelAlokasiKantongCompanion alokasi) async {
    final jenis = alokasi.jenis.value;
    final jumlah = alokasi.jumlahRupiah.value;
    final kantongId = alokasi.kantongId.value;

    if (jenis == JenisAlokasi.ambil.kode) {
      final saldoSaatIni = await hitungSaldoKantongSQL(kantongId);
      validasiAmbilKantong(saldoKantong: saldoSaatIni, jumlahAmbil: jumlah);
    }

    return _db.into(_db.tabelAlokasiKantong).insert(alokasi);
  }

  /// Memantau riwayat alokasi kantong untuk suatu kantong, urut waktu terbaru.
  Stream<List<EntitasAlokasiKantong>> pantauRiwayatAlokasiKantong(
    String kantongId,
  ) {
    final kueri = _db.select(_db.tabelAlokasiKantong)
      ..where((a) => a.kantongId.equals(kantongId))
      ..orderBy([
        (a) => OrderingTerm(expression: a.waktu, mode: OrderingMode.desc),
      ]);
    return kueri.watch();
  }

  /// Memantau seluruh riwayat alokasi untuk suatu tujuan (dari seluruh kantong tertaut).
  Stream<List<EntitasAlokasiKantong>> pantauRiwayatAlokasiTujuan(
    String tujuanId,
  ) {
    final kueri =
        _db.select(_db.tabelAlokasiKantong).join([
            innerJoin(
              _db.tabelKantong,
              _db.tabelKantong.id.equalsExp(_db.tabelAlokasiKantong.kantongId),
            ),
          ])
          ..where(_db.tabelKantong.tujuanId.equals(tujuanId))
          ..orderBy([
            OrderingTerm(
              expression: _db.tabelAlokasiKantong.waktu,
              mode: OrderingMode.desc,
            ),
          ]);

    return kueri.watch().map(
      (barisList) =>
          barisList.map((b) => b.readTable(_db.tabelAlokasiKantong)).toList(),
    );
  }
}
