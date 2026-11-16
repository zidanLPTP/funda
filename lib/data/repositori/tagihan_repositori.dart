import 'dart:math' as math;
import 'package:drift/drift.dart';
import '../../layanan/pengingat/layanan_pengingat.dart';
import '../../perhitungan/perhitungan_tagihan.dart';
import '../basis_data.dart';
import '../model/frekuensi_tagihan.dart';

/// Item gabungan jadwal tagihan dan cicilan utang untuk antarmuka dan pengingat.
class ItemJadwalTampilan {
  const ItemJadwalTampilan({
    required this.idTagihan,
    required this.nama,
    required this.tanggalJatuhTempo,
    this.jumlahPerkiraanRupiah,
    this.kategoriId,
    this.dompetBawaanId,
    required this.status,
    required this.selisihHari,
    this.idPembayaranTagihan,
    this.transaksiIdTertaut,
    this.jumlahAktualRupiah,
    this.hariSebelumPengingat = const [],
    this.isCicilanUtang = false,
    this.idUtang,
  });

  final String idTagihan;
  final String nama;
  final DateTime tanggalJatuhTempo;
  final int? jumlahPerkiraanRupiah;
  final String? kategoriId;
  final String? dompetBawaanId;
  final StatusKemunculan status;
  final int selisihHari;
  final String? idPembayaranTagihan;
  final String? transaksiIdTertaut;
  final int? jumlahAktualRupiah;
  final List<int> hariSebelumPengingat;
  final bool isCicilanUtang;
  final String? idUtang;
}

/// Repositori untuk mengelola tagihan berulang dan penandaan pembayaran.
class TagihanRepositori {
  const TagihanRepositori(this._db);

  final BasisDataFunda _db;
  static int _pencacahUnik = 0;

  /// Memantau seluruh master tagihan (aktif & diarsipkan).
  Stream<List<EntitasTagihan>> pantauSemuaTagihan() {
    final kueri = _db.select(_db.tabelTagihan)
      ..orderBy([
        (t) => OrderingTerm(expression: t.dibuatPada, mode: OrderingMode.desc),
      ]);
    return kueri.watch();
  }

  /// Memantau tagihan aktif yang belum diarsipkan.
  Stream<List<EntitasTagihan>> pantauTagihanAktif() {
    final kueri = _db.select(_db.tabelTagihan)
      ..where((t) => t.diarsipkan.equals(false) & t.aktif.equals(true))
      ..orderBy([
        (t) => OrderingTerm(expression: t.nama, mode: OrderingMode.asc),
      ]);
    return kueri.watch();
  }

  /// Mengambil satu tagihan berdasarkan ID.
  Future<EntitasTagihan?> ambilTagihanBerdasarkanId(String id) {
    return (_db.select(
      _db.tabelTagihan,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Menambah master tagihan baru.
  Future<String> buatTagihan({
    required String nama,
    required String jenis, // tagihan | langganan
    int? jumlahPerkiraanRupiah,
    required String kategoriId,
    String? dompetId,
    required String frekuensi, // mingguan | bulanan | tahunan
    required DateTime jatuhTempoPertama,
    DateTime? berakhirPada,
    List<int> pengingatHariSebelum = const [],
  }) async {
    final id =
        'tag_${DateTime.now().microsecondsSinceEpoch}_${++_pencacahUnik}';
    final sekarang = DateTime.now();

    await _db
        .into(_db.tabelTagihan)
        .insert(
          TabelTagihanCompanion(
            id: Value(id),
            nama: Value(nama),
            jenis: Value(jenis),
            jumlahPerkiraanRupiah: Value(jumlahPerkiraanRupiah),
            kategoriId: Value(kategoriId),
            dompetId: Value(dompetId),
            frekuensi: Value(frekuensi),
            jatuhTempoPertama: Value(
              DateTime(
                jatuhTempoPertama.year,
                jatuhTempoPertama.month,
                jatuhTempoPertama.day,
              ),
            ),
            berakhirPada: Value(
              berakhirPada != null
                  ? DateTime(
                      berakhirPada.year,
                      berakhirPada.month,
                      berakhirPada.day,
                    )
                  : null,
            ),
            pengingatHariSebelum: Value(
              serialisasiHariPengingat(pengingatHariSebelum),
            ),
            aktif: const Value(true),
            diarsipkan: const Value(false),
            dibuatPada: Value(sekarang),
          ),
        );

    return id;
  }

  /// Memperbarui informasi tagihan.
  Future<bool> perbaruiTagihan(TabelTagihanCompanion tagihan) {
    return _db.update(_db.tabelTagihan).replace(tagihan);
  }

  /// Mengubah status aktif/jeda tagihan.
  Future<int> ubahStatusAktifTagihan(String id, bool aktif) {
    return (_db.update(_db.tabelTagihan)..where((t) => t.id.equals(id))).write(
      TabelTagihanCompanion(aktif: Value(aktif)),
    );
  }

  /// Mengarsipkan tagihan.
  Future<int> arsipkanTagihan(String id) {
    return (_db.update(_db.tabelTagihan)..where((t) => t.id.equals(id))).write(
      const TabelTagihanCompanion(diarsipkan: Value(true), aktif: Value(false)),
    );
  }

  /// Menghapus tagihan secara permanen jika belum ada riwayat pembayaran.
  Future<int> hapusTagihanPermanen(String id) async {
    final riwayat = await (_db.select(
      _db.tabelPembayaranTagihan,
    )..where((p) => p.tagihanId.equals(id))).get();
    if (riwayat.isNotEmpty) {
      throw StateError(
        'Tagihan ini sudah memiliki riwayat pembayaran tercatat. Gunakan fitur arsip.',
      );
    }
    return (_db.delete(_db.tabelTagihan)..where((t) => t.id.equals(id))).go();
  }

  /// Menandai satu periode tagihan sebagai DIBAYAR.
  /// Dijalankan dalam SATU transaksi database atomik:
  /// 1. Membuat transaksi pengeluaran di tabel_transaksi.
  /// 2. Membuat baris di tabel_pembayaran_tagihan tertaut ke transaksi tersebut.
  Future<String> tandaiTagihanDibayar({
    required String tagihanId,
    required DateTime jatuhTempo,
    required String dompetId,
    required String kategoriId,
    required int jumlahRupiah,
    required DateTime waktuTransaksi,
    String? catatan,
  }) async {
    return _db.transaction(() async {
      final sekarang = DateTime.now();
      final transaksiId =
          'tx_tag_${sekarang.microsecondsSinceEpoch}_${++_pencacahUnik}';

      // 1. Catat transaksi keluar
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
              waktuTransaksi: Value(waktuTransaksi),
              dibuatPada: Value(sekarang),
              diubahPada: Value(sekarang),
            ),
          );

      // 2. Catat pembayaran tagihan
      final pembayaranId =
          'pmbt_${sekarang.microsecondsSinceEpoch}_${++_pencacahUnik}';
      final tJatuh = DateTime(
        jatuhTempo.year,
        jatuhTempo.month,
        jatuhTempo.day,
      );

      await _db
          .into(_db.tabelPembayaranTagihan)
          .insertOnConflictUpdate(
            TabelPembayaranTagihanCompanion(
              id: Value(pembayaranId),
              tagihanId: Value(tagihanId),
              jatuhTempo: Value(tJatuh),
              status: const Value('dibayar'),
              transaksiId: Value(transaksiId),
              dibuatPada: Value(sekarang),
            ),
          );

      return transaksiId;
    });
  }

  /// Menandai satu periode tagihan sebagai DILEWATI (tanpa membuat transaksi uang).
  Future<String> tandaiTagihanDilewati({
    required String tagihanId,
    required DateTime jatuhTempo,
  }) async {
    final sekarang = DateTime.now();
    final pembayaranId =
        'pmbt_${sekarang.microsecondsSinceEpoch}_${++_pencacahUnik}';
    final tJatuh = DateTime(jatuhTempo.year, jatuhTempo.month, jatuhTempo.day);

    await _db
        .into(_db.tabelPembayaranTagihan)
        .insertOnConflictUpdate(
          TabelPembayaranTagihanCompanion(
            id: Value(pembayaranId),
            tagihanId: Value(tagihanId),
            jatuhTempo: Value(tJatuh),
            status: const Value('dilewati'),
            transaksiId: const Value(null),
            dibuatPada: Value(sekarang),
          ),
        );

    return pembayaranId;
  }

  /// Membatalkan penandaan periode tagihan.
  /// Jika ada transaksi tertaut, transaksi dihapus (dan foreign key cascade menghapus pembayaran tagihan).
  Future<void> batalkanPenandaanPeriode({
    required String tagihanId,
    required DateTime jatuhTempo,
  }) async {
    final tJatuh = DateTime(jatuhTempo.year, jatuhTempo.month, jatuhTempo.day);
    final row =
        await (_db.select(_db.tabelPembayaranTagihan)..where(
              (p) =>
                  p.tagihanId.equals(tagihanId) & p.jatuhTempo.equals(tJatuh),
            ))
            .getSingleOrNull();

    if (row != null) {
      if (row.transaksiId != null) {
        // Hapus transaksi -> cascade SQLite otomatis menghapus baris pembayaran tagihan
        await (_db.delete(
          _db.tabelTransaksi,
        )..where((t) => t.id.equals(row.transaksiId!))).go();
      } else {
        await (_db.delete(
          _db.tabelPembayaranTagihan,
        )..where((p) => p.id.equals(row.id))).go();
      }
    }
  }

  /// Mengambil jadwal gabungan tagihan dan cicilan utang untuk rentang tanggal tertentu.
  Future<List<ItemJadwalTampilan>> ambilJadwalGabungan({
    required DateTime mulai,
    required DateTime selesai,
    DateTime? waktuSekarang,
  }) async {
    final sekarang = waktuSekarang ?? DateTime.now();
    final hariIni = DateTime(sekarang.year, sekarang.month, sekarang.day);
    final hasil = <ItemJadwalTampilan>[];

    // 1. Ambil seluruh tagihan aktif
    final daftarTagihan = await (_db.select(
      _db.tabelTagihan,
    )..where((t) => t.diarsipkan.equals(false))).get();

    // Ambil seluruh data penandaan pembayaran tagihan
    final daftarPembayaran = await _db.select(_db.tabelPembayaranTagihan).get();
    final petaPembayaran = <String, EntitasPembayaranTagihan>{};
    for (final p in daftarPembayaran) {
      final kunci =
          '${p.tagihanId}_${p.jatuhTempo.year}_${p.jatuhTempo.month}_${p.jatuhTempo.day}';
      petaPembayaran[kunci] = p;
    }

    // Ambil data transaksi terarah HANYA untuk transaksi yang tertaut di penandaan pembayaran
    final idTransaksiTerkait = daftarPembayaran
        .map((p) => p.transaksiId)
        .whereType<String>()
        .toSet()
        .toList();

    final Map<String, int> petaJumlahTransaksi;
    if (idTransaksiTerkait.isEmpty) {
      petaJumlahTransaksi = const {};
    } else {
      final barisTransaksi = await (_db.selectOnly(_db.tabelTransaksi)
            ..addColumns([_db.tabelTransaksi.id, _db.tabelTransaksi.jumlahRupiah])
            ..where(_db.tabelTransaksi.id.isIn(idTransaksiTerkait)))
          .get();
      petaJumlahTransaksi = {
        for (final b in barisTransaksi)
          b.read(_db.tabelTransaksi.id)!: b.read(_db.tabelTransaksi.jumlahRupiah)!
      };
    }

    for (final tagihan in daftarTagihan) {
      final frekuensi = FrekuensiTagihan.dariKode(tagihan.frekuensi);
      FrekuensiKalkulasi frekKalkulasi;
      switch (frekuensi) {
        case FrekuensiTagihan.mingguan:
          frekKalkulasi = FrekuensiKalkulasi.mingguan;
          break;
        case FrekuensiTagihan.bulanan:
          frekKalkulasi = FrekuensiKalkulasi.bulanan;
          break;
        case FrekuensiTagihan.tahunan:
          frekKalkulasi = FrekuensiKalkulasi.tahunan;
          break;
      }

      final aturan = AturanJatuhTempo(
        frekuensi: frekKalkulasi,
        jatuhTempoPertama: tagihan.jatuhTempoPertama,
        berakhirPada: tagihan.berakhirPada,
      );

      final tanggalJatuhList = hitungJatuhTempoDalamRentang(
        aturan: aturan,
        mulai: mulai,
        selesai: selesai,
      );

      final hariSebelumList = uraiHariPengingat(tagihan.pengingatHariSebelum);

      for (final tJatuh in tanggalJatuhList) {
        final kunci =
            '${tagihan.id}_${tJatuh.year}_${tJatuh.month}_${tJatuh.day}';
        final catatan = petaPembayaran[kunci];

        final statusEvaluasi = tentukanStatusJatuhTempo(
          tanggalJatuhTempo: tJatuh,
          hariIni: hariIni,
          statusTersimpan: catatan?.status,
        );

        int? jumlahAktual;
        if (catatan?.transaksiId != null) {
          jumlahAktual = petaJumlahTransaksi[catatan!.transaksiId!];
        }

        hasil.add(
          ItemJadwalTampilan(
            idTagihan: tagihan.id,
            nama: tagihan.nama,
            tanggalJatuhTempo: tJatuh,
            jumlahPerkiraanRupiah: tagihan.jumlahPerkiraanRupiah,
            kategoriId: tagihan.kategoriId,
            dompetBawaanId: tagihan.dompetId,
            status: statusEvaluasi.status,
            selisihHari: statusEvaluasi.selisihHari,
            idPembayaranTagihan: catatan?.id,
            transaksiIdTertaut: catatan?.transaksiId,
            jumlahAktualRupiah: jumlahAktual,
            hariSebelumPengingat: hariSebelumList,
            isCicilanUtang: false,
          ),
        );
      }
    }

    // 2. Ambil cicilan utang aktif (item baca-saja)
    final daftarUtang = await (_db.select(
      _db.tabelUtang,
    )..where((u) => u.status.equals('aktif'))).get();

    // Ambil pembayaran utang tertaut
    final kueriBayarUtang = await (_db.select(_db.tabelPembayaranUtang).join([
      innerJoin(
        _db.tabelTransaksi,
        _db.tabelTransaksi.id.equalsExp(_db.tabelPembayaranUtang.transaksiId),
      ),
    ])).get();

    for (final utang in daftarUtang) {
      if (utang.tanggalJatuhTempoBulanan == null) continue;
      final targetHari = utang.tanggalJatuhTempoBulanan!;

      // Hitung tanggal jatuh tempo bulanan utang dalam rentang
      var tahun = mulai.year;
      var bulan = mulai.month;

      while (true) {
        final hariMaksimal = DateTime(tahun, bulan + 1, 0).day;
        final tJatuh = DateTime(
          tahun,
          bulan,
          math.min(targetHari, hariMaksimal),
        );
        if (tJatuh.isAfter(selesai)) break;

        if (!tJatuh.isBefore(mulai)) {
          // Asumsi spec: periode dianggap sudah dibayar bila ada pembayaran utang tertaut
          // yang tanggal transaksinya jatuh di bulan kalender yang sama
          final sudahBayarBulanIni = kueriBayarUtang.any((b) {
            final pu = b.readTable(_db.tabelPembayaranUtang);
            final tx = b.readTable(_db.tabelTransaksi);
            return pu.utangId == utang.id &&
                tx.waktuTransaksi.year == tahun &&
                tx.waktuTransaksi.month == bulan;
          });

          final statusEvaluasi = tentukanStatusJatuhTempo(
            tanggalJatuhTempo: tJatuh,
            hariIni: hariIni,
            statusTersimpan: sudahBayarBulanIni ? 'dibayar' : null,
          );

          hasil.add(
            ItemJadwalTampilan(
              idTagihan: 'utang_${utang.id}',
              nama: 'Cicilan ${utang.nama}',
              tanggalJatuhTempo: tJatuh,
              jumlahPerkiraanRupiah: utang.cicilanBulananRupiah,
              status: statusEvaluasi.status,
              selisihHari: statusEvaluasi.selisihHari,
              isCicilanUtang: true,
              idUtang: utang.id,
              hariSebelumPengingat: const [
                0,
                1,
                3,
              ], // Default ramah pengingat cicilan
            ),
          );
        }

        bulan++;
        if (bulan > 12) {
          bulan = 1;
          tahun++;
        }
      }
    }

    // Urutkan menurut tanggal jatuh tempo menaik
    hasil.sort((a, b) => a.tanggalJatuhTempo.compareTo(b.tanggalJatuhTempo));
    return hasil;
  }

  /// Sinkronisasi jadwal pengingat ke LayananPengingat lokal.
  Future<void> sinkronkanPengingat(LayananPengingat layanan) async {
    final statusPengingatAktif =
        (await _db.bacaPengaturan('pengingat_aktif')) == 'true';

    if (!statusPengingatAktif) {
      await layanan.batalkanSemuaPengingat();
      return;
    }

    final jamStr = await _db.bacaPengaturan('jam_pengingat') ?? '09:00';
    final parts = jamStr.split(':');
    final jam = int.tryParse(parts[0]) ?? 9;
    final menit = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    final tampilkanNominal =
        (await _db.bacaPengaturan('tampilkan_nominal_di_pengingat')) == 'true';

    final pengaturan = PengaturanPengingatTagihan(
      aktif: true,
      jam: jam,
      menit: menit,
      tampilkanNominal: tampilkanNominal,
    );

    final sekarang = DateTime.now();
    final jadwal45Hari = await ambilJadwalGabungan(
      mulai: sekarang.subtract(const Duration(days: 1)),
      selesai: sekarang.add(const Duration(days: 45)),
      waktuSekarang: sekarang,
    );

    final itemKalkulasiList = jadwal45Hari.map((j) {
      return ItemKalkulasiJadwal(
        idTagihan: j.idTagihan,
        nama: j.nama,
        tanggal: j.tanggalJatuhTempo,
        jumlahPerkiraanRupiah: j.jumlahPerkiraanRupiah,
        status: j.status,
        hariSebelumPengingat: j.hariSebelumPengingat,
        isCicilanUtang: j.isCicilanUtang,
      );
    }).toList();

    final rencanaList = rencanakanPengingat(
      daftarJadwal: itemKalkulasiList,
      pengaturan: pengaturan,
      sekarang: sekarang,
    );

    await layanan.jadwalkanDaftarRencana(rencanaList);
  }
}
