import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'seeder/kategori_bawaan.dart';
import 'tabel/tabel_alokasi_kantong.dart';
import 'tabel/tabel_anggaran.dart';
import 'tabel/tabel_dompet.dart';
import 'tabel/tabel_kantong.dart';
import 'tabel/tabel_kategori.dart';
import 'tabel/tabel_pembayaran_tagihan.dart';
import 'tabel/tabel_pembayaran_utang.dart';
import 'tabel/tabel_pengaturan.dart';
import 'tabel/tabel_penyesuaian_utang.dart';
import 'tabel/tabel_tagihan.dart';
import 'tabel/tabel_transaksi.dart';
import 'tabel/tabel_tujuan.dart';
import 'tabel/tabel_utang.dart';

part 'basis_data.g.dart';

/// Basis data lokal SQLite Funda yang dikelola menggunakan Drift.
/// Mendukung migrasi bertingkat bertipe aman yang tidak menghapus data pengguna.
@DriftDatabase(
  tables: [
    TabelPengaturan,
    TabelDompet,
    TabelKategori,
    TabelTransaksi,
    TabelAnggaran,
    TabelTujuan,
    TabelKantong,
    TabelAlokasiKantong,
    TabelUtang,
    TabelPembayaranUtang,
    TabelPenyesuaianUtang,
    TabelTagihan,
    TabelPembayaranTagihan,
  ],
)
class BasisDataFunda extends _$BasisDataFunda {
  BasisDataFunda([QueryExecutor? pelaksanaKueri])
    : super(pelaksanaKueri ?? _bukaKoneksi());

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _seedKategoriBawaan();
        await _seedPengaturanAwal();
        await customStatement(
          'CREATE UNIQUE INDEX IF NOT EXISTS idx_kantong_dompet_tujuan '
          'ON tabel_kantong (dompet_id, tujuan_id) WHERE tujuan_id IS NOT NULL;',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_alokasi_kantong_id '
          'ON tabel_alokasi_kantong (kantong_id);',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_anggaran_periode '
          'ON tabel_anggaran (tahun, bulan);',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_pembayaran_utang_utang_id '
          'ON tabel_pembayaran_utang (utang_id);',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_penyesuaian_utang_utang_id '
          'ON tabel_penyesuaian_utang (utang_id);',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_tagihan_aktif_diarsipkan '
          'ON tabel_tagihan (aktif, diarsipkan);',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_pembayaran_tagihan_jatuh_tempo '
          'ON tabel_pembayaran_tagihan (tagihan_id, jatuh_tempo);',
        );
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
      case 2:
        // Skema tahap 2: dompet, kategori, transaksi
        await m.createTable(tabelDompet);
        await m.createTable(tabelKategori);
        await m.createTable(tabelTransaksi);
        await _seedKategoriBawaan();
        break;
      case 3:
        // Skema tahap 3A: anggaran, tujuan, kantong, alokasi_kantong
        await m.createTable(tabelAnggaran);
        await m.createTable(tabelTujuan);
        await m.createTable(tabelKantong);
        await m.createTable(tabelAlokasiKantong);
        await customStatement(
          'CREATE UNIQUE INDEX IF NOT EXISTS idx_kantong_dompet_tujuan '
          'ON tabel_kantong (dompet_id, tujuan_id) WHERE tujuan_id IS NOT NULL;',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_alokasi_kantong_id '
          'ON tabel_alokasi_kantong (kantong_id);',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_anggaran_periode '
          'ON tabel_anggaran (tahun, bulan);',
        );
        break;
      case 4:
        // Skema tahap 3B: utang, pembayaran_utang, penyesuaian_utang
        await m.createTable(tabelUtang);
        await m.createTable(tabelPembayaranUtang);
        await m.createTable(tabelPenyesuaianUtang);
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_pembayaran_utang_utang_id '
          'ON tabel_pembayaran_utang (utang_id);',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_penyesuaian_utang_utang_id '
          'ON tabel_penyesuaian_utang (utang_id);',
        );
        break;
      case 5:
        // Skema tahap 3C: tagihan, pembayaran_tagihan
        await m.createTable(tabelTagihan);
        await m.createTable(tabelPembayaranTagihan);
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_tagihan_aktif_diarsipkan '
          'ON tabel_tagihan (aktif, diarsipkan);',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_pembayaran_tagihan_jatuh_tempo '
          'ON tabel_pembayaran_tagihan (tagihan_id, jatuh_tempo);',
        );
        await _seedPengaturanAwal();
        break;
      case 6:
        // Migrasi Skema Versi 6 (Tahap 3C-R):
        // Memastikan kolom jatuh_tempo_pertama dan berakhir_pada ada di tabel_tagihan.
        // Data lama diisi tanggal jatuh tempo pertama dari dibuat_pada.
        final kolomTagihan = await customSelect(
          "PRAGMA table_info('tabel_tagihan');",
        ).get();
        final namaKolom = kolomTagihan
            .map((k) => k.read<String>('name'))
            .toSet();

        if (!namaKolom.contains('jatuh_tempo_pertama')) {
          await customStatement(
            'ALTER TABLE tabel_tagihan ADD COLUMN jatuh_tempo_pertama INTEGER;',
          );
          await customStatement(
            'UPDATE tabel_tagihan SET jatuh_tempo_pertama = dibuat_pada WHERE jatuh_tempo_pertama IS NULL;',
          );
        }

        if (!namaKolom.contains('berakhir_pada')) {
          await customStatement(
            'ALTER TABLE tabel_tagihan ADD COLUMN berakhir_pada INTEGER;',
          );
        }
        break;
      default:
        break;
    }
  }

  /// Menyuntikkan nilai pengaturan awal secara idempoten.
  Future<void> _seedPengaturanAwal() async {
    await into(tabelPengaturan).insert(
      TabelPengaturanCompanion(
        kunci: const Value('pengingat_aktif'),
        nilai: const Value('false'),
        diubahPada: Value(DateTime.now()),
      ),
      mode: InsertMode.insertOrIgnore,
    );
    await into(tabelPengaturan).insert(
      TabelPengaturanCompanion(
        kunci: const Value('jam_pengingat'),
        nilai: const Value('09:00'),
        diubahPada: Value(DateTime.now()),
      ),
      mode: InsertMode.insertOrIgnore,
    );
    await into(tabelPengaturan).insert(
      TabelPengaturanCompanion(
        kunci: const Value('tampilkan_nominal_di_pengingat'),
        nilai: const Value('false'),
        diubahPada: Value(DateTime.now()),
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  /// Menyuntikkan kategori bawaan sistem secara idempoten (InsertMode.insertOrIgnore).
  /// Aman dijalankan ulang berkali-kali tanpa menimpa perubahan atau menduplikasi kategori.
  Future<void> _seedKategoriBawaan() async {
    await batch((b) {
      for (final kategori in daftarKategoriBawaan) {
        b.insert(tabelKategori, kategori, mode: InsertMode.insertOrIgnore);
      }
    });
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
