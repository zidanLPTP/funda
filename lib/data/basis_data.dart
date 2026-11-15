import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'tabel/tabel_pengaturan.dart';

part 'basis_data.g.dart';

/// Basis data lokal SQLite Funda yang dikelola menggunakan Drift.
/// Mendukung migrasi bertingkat bertipe aman yang tidak menghapus data pengguna.
@DriftDatabase(tables: [TabelPengaturan])
class BasisDataFunda extends _$BasisDataFunda {
  BasisDataFunda([QueryExecutor? pelaksanaKueri])
    : super(pelaksanaKueri ?? _bukaKoneksi());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int dariVersi, int keVersi) async {
        // Mekanisme migrasi bertingkat berurutan (dariVersi -> keVersi)
        // Setiap kenaikan versi dieksekusi secara berurutan dan aman dijalankan ulang.
        for (var v = dariVersi; v < keVersi; v++) {
          await _eksekusiLangkahMigrasi(m, v + 1);
        }
      },
      beforeOpen: (details) async {
        // Aktifkan batasan foreign key di SQLite
        await customStatement('PRAGMA foreign_keys = ON;');
      },
    );
  }

  /// Mengeksekusi perubahan skema per versi tertentu.
  /// Menjamin migrasi bersifat idempotent dan tidak menghapus data yang sudah ada.
  Future<void> _eksekusiLangkahMigrasi(Migrator m, int targetVersi) async {
    switch (targetVersi) {
      case 1:
        // Skema awal: tabel_pengaturan
        await m.createTable(tabelPengaturan);
        break;
      // Versi skema berikutnya akan ditambahkan di sini secara bertahap:
      // case 2: ...
      default:
        break;
    }
  }

  // --- Operasi Tabel Pengaturan ---

  /// Menyimpan atau memperbarui pengaturan berdasarkan kunci.
  Future<int> simpanPengaturan(String kunci, String nilai) {
    return into(tabelPengaturan).insertOnConflictUpdate(
      TabelPengaturanCompanion(
        kunci: Value(kunci),
        nilai: Value(nilai),
        diubahPada: Value(DateTime.now()),
      ),
    );
  }

  /// Mengambil nilai pengaturan berdasarkan kunci. Mengembalikan null jika belum ada.
  Future<String?> bacaPengaturan(String kunci) async {
    final kueri = select(tabelPengaturan)
      ..where((tbl) => tbl.kunci.equals(kunci));
    final hasil = await kueri.getSingleOrNull();
    return hasil?.nilai;
  }

  /// Menghapus pengaturan berdasarkan kunci.
  Future<int> hapusPengaturan(String kunci) {
    return (delete(
      tabelPengaturan,
    )..where((tbl) => tbl.kunci.equals(kunci))).go();
  }

  /// Mengambil semua pengaturan yang tersimpan.
  Future<List<EntitasPengaturan>> ambilSemuaPengaturan() {
    return select(tabelPengaturan).get();
  }
}

/// Membuka berkas SQLite di folder dokumen aplikasi lokal.
LazyDatabase _bukaKoneksi() {
  return LazyDatabase(() async {
    final folderDokumen = await getApplicationDocumentsDirectory();
    final berkasDb = File(p.join(folderDokumen.path, 'funda.sqlite'));
    return NativeDatabase.createInBackground(berkasDb);
  });
}
