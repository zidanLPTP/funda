import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../basis_data.dart';
import 'format_cadangan.dart';
import 'peningkat_cadangan.dart';

/// Eksepsi ramah untuk kesalahan validasi dan pemulihan berkas cadangan.
class GalatCadangan implements Exception {
  final String pesan;
  const GalatCadangan(this.pesan);

  @override
  String toString() => pesan;
}

/// Repositori untuk ekspor, validasi, dan pemulihan atomik basis data Funda.
class CadanganRepositori {
  final BasisDataFunda basisData;
  final Directory? direktoriPenyimpananUji;

  const CadanganRepositori(this.basisData, {this.direktoriPenyimpananUji});

  /// Daftar tabel yang sengaja dikecualikan dari ekspor/impor cadangan (tabel sesi sandbox fiktif).
  static const Set<String> tabelDikecualikan = {'tabel_sesi_sandbox'};

  Future<File> _dapatkanBerkasKeselamatan() async {
    Directory dir;
    if (direktoriPenyimpananUji != null) {
      dir = direktoriPenyimpananUji!;
    } else {
      try {
        dir = await getApplicationDocumentsDirectory();
      } catch (_) {
        dir = Directory.systemTemp;
      }
    }
    return File(p.join(dir.path, 'sebelum_pemulihan.json'));
  }

  /// Mendapatkan daftar seluruh nama tabel pengguna pada skema basis data.
  Future<List<String>> dapatkanDaftarTabelSkema() async {
    final rows = await basisData
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'android_%' ORDER BY name ASC;",
        )
        .get();
    final tabelDb = rows.map((r) => r.read<String>('name')).toSet();
    final tabelDrift = basisData.allTables
        .map((t) => t.actualTableName)
        .toSet();
    return (tabelDb.union(tabelDrift)).toList()..sort();
  }

  /// Menemukan kolom kunci utama dari tabel tertentu untuk pengurutan kanonikal deterministik.
  Future<List<String>> _dapatkanKolomKunciUtama(String namaTabel) async {
    final rows = await basisData
        .customSelect("PRAGMA table_info('$namaTabel');")
        .get();
    final pkCols = <({int pk, String col})>[];
    for (final r in rows) {
      final pk = r.read<int>('pk');
      final col = r.read<String>('name');
      if (pk > 0) {
        pkCols.add((pk: pk, col: col));
      }
    }
    pkCols.sort((a, b) => a.pk.compareTo(b.pk));
    return pkCols.map((e) => e.col).toList();
  }

  /// Mendapatkan daftar kolom yang sah untuk suatu tabel.
  Future<Set<String>> _dapatkanKolomSah(String namaTabel) async {
    final rows = await basisData
        .customSelect("PRAGMA table_info('$namaTabel');")
        .get();
    return rows.map((r) => r.read<String>('name')).toSet();
  }

  /// Mengekspor seluruh isi basis data ke model DokumenCadanganFunda.
  Future<DokumenCadanganFunda> eksporCadangan({
    DateTime? waktuDibuat,
    String versiAplikasi = '0.9.0',
  }) async {
    final semuaTabel = await dapatkanDaftarTabelSkema();
    final tabelDisimpan = <String, List<Map<String, dynamic>>>{};
    final jumlahBarisMap = <String, int>{};

    for (final namaTabel in semuaTabel) {
      if (tabelDikecualikan.contains(namaTabel)) continue;

      final pkCols = await _dapatkanKolomKunciUtama(namaTabel);
      final orderBy = pkCols.isNotEmpty
          ? 'ORDER BY ${pkCols.join(', ')}'
          : 'ORDER BY rowid';

      final rows = await basisData
          .customSelect('SELECT * FROM $namaTabel $orderBy;')
          .get();

      final listBaris = <Map<String, dynamic>>[];
      for (final r in rows) {
        listBaris.add(Map<String, dynamic>.from(r.data));
      }
      tabelDisimpan[namaTabel] = listBaris;
      jumlahBarisMap[namaTabel] = listBaris.length;
    }

    final tglDibuat = (waktuDibuat ?? DateTime.now()).toUtc();
    final checksum = hitungChecksumTabel(tabelDisimpan);

    return DokumenCadanganFunda(
      versiSkema: basisData.schemaVersion,
      versiAplikasi: versiAplikasi,
      dibuatPada: tglDibuat,
      jumlahBaris: jumlahBarisMap,
      checksum: checksum,
      tabel: tabelDisimpan,
    );
  }

  /// Mengekspor dokumen cadangan dalam bentuk string JSON.
  Future<String> eksporCadanganKeJson({
    DateTime? waktuDibuat,
    String versiAplikasi = '0.9.0',
  }) async {
    final doc = await eksporCadangan(
      waktuDibuat: waktuDibuat,
      versiAplikasi: versiAplikasi,
    );
    return jsonEncode(doc.toJson());
  }

  /// Memvalidasi string JSON berkas cadangan dan mengembalikan pratinjau data.
  Future<({DokumenCadanganFunda dokumen, PratinjauCadangan pratinjau})>
  validasiDanBuatPratinjau(String jsonString) async {
    // 1. Batas ukuran berkas maksimum 50 MB
    if (jsonString.length > 50 * 1024 * 1024) {
      throw const GalatCadangan(
        'Ukuran berkas cadangan melebihi batas maksimum 50 MB.',
      );
    }

    // 2. Penguraian JSON
    dynamic data;
    try {
      data = jsonDecode(jsonString);
    } catch (_) {
      throw const GalatCadangan(
        'Format berkas tidak valid atau bukan berkas JSON yang sah.',
      );
    }

    if (data is! Map<String, dynamic>) {
      throw const GalatCadangan('Struktur berkas cadangan tidak valid.');
    }

    // 3. Format dan versi format
    final format = data['format'] as String?;
    if (format != 'funda_cadangan') {
      throw const GalatCadangan(
        'Berkas ini bukan berkas cadangan resmi aplikasi Funda.',
      );
    }

    final versiFormat = (data['versiFormat'] as num?)?.toInt() ?? 0;
    if (versiFormat != 1) {
      throw GalatCadangan(
        'Versi format cadangan ($versiFormat) tidak didukung.',
      );
    }

    // 4. Versi skema basis data
    final versiSkema = (data['versiSkema'] as num?)?.toInt() ?? 0;
    if (versiSkema > basisData.schemaVersion) {
      throw GalatCadangan(
        'Berkas cadangan dibuat dengan versi Funda yang lebih baru (skema $versiSkema). '
        'Silakan perbarui aplikasi Funda terlebih dahulu.',
      );
    }

    // 5. Verifikasi Checksum SHA-256
    final doc = DokumenCadanganFunda.fromJson(data);
    final checksumAktual = hitungChecksumTabel(doc.tabel);
    if (checksumAktual != doc.checksum) {
      throw const GalatCadangan(
        'Integritas berkas cadangan rusak (checksum tidak cocok). Berkas mungkin terpotong atau telah diubah.',
      );
    }

    final pratinjau = PratinjauCadangan.dariDokumen(doc);
    return (dokumen: doc, pratinjau: pratinjau);
  }

  /// Menyimpan cadangan keselamatan otomatis sebelum pemulihan dilakukan.
  Future<File> simpanCadanganKeselamatan() async {
    final jsonStr = await eksporCadanganKeJson();
    final file = await _dapatkanBerkasKeselamatan();
    await file.writeAsString(jsonStr, flush: true);
    return file;
  }

  /// Memeriksa apakah terdapat berkas cadangan keselamatan dari pemulihan sebelumnya.
  Future<bool> adaCadanganKeselamatan() async {
    final file = await _dapatkanBerkasKeselamatan();
    return file.exists();
  }

  /// Memulihkan data dari berkas cadangan keselamatan 'sebelum_pemulihan.json'.
  Future<void> pulihkanDariCadanganKeselamatan() async {
    final file = await _dapatkanBerkasKeselamatan();
    if (!await file.exists()) {
      throw const GalatCadangan(
        'Tidak ada berkas cadangan keselamatan sebelum pemulihan terakhir.',
      );
    }
    final jsonStr = await file.readAsString();
    final validasi = await validasiDanBuatPratinjau(jsonStr);
    await pulihkanCadangan(validasi.dokumen, simpanKeselamatanOtomatis: false);
  }

  /// Memulihkan basis data dari DokumenCadanganFunda dalam satu transaksi atomik.
  Future<void> pulihkanCadangan(
    DokumenCadanganFunda doc, {
    bool simpanKeselamatanOtomatis = true,
    void Function()? kegagalanSuntikanUntukUji,
  }) async {
    // 1. Simpan cadangan keselamatan otomatis jika diminta
    if (simpanKeselamatanOtomatis) {
      await simpanCadanganKeselamatan();
    }

    // 2. Tingkatkan skema data jika cadangan berasal dari versi skema lama
    var tabelDipulihkan = doc.tabel;
    if (doc.versiSkema < basisData.schemaVersion) {
      tabelDipulihkan = RegistriPeningkatCadangan.tingkatkan(
        doc.tabel,
        dariVersi: doc.versiSkema,
        keVersi: basisData.schemaVersion,
      );
    }

    final semuaTabelSkema = await dapatkanDaftarTabelSkema();

    try {
      // 3. Eksekusi pemulihan dalam SATU transaksi database
      await basisData.transaction(() async {
        // Aktifkan defer foreign keys selama proses penggantian data
        await basisData.customStatement('PRAGMA defer_foreign_keys = ON;');

        // Hapus seluruh baris data di semua tabel_* yang ada di basis data
        for (final namaTabel in semuaTabelSkema) {
          await basisData.customStatement('DELETE FROM $namaTabel;');
        }

        // Suntikan kegagalan untuk pengujian rollback jika disediakan
        if (kegagalanSuntikanUntukUji != null) {
          kegagalanSuntikanUntukUji();
        }

        // Sisipkan baris-baris dari cadangan
        for (final entry in tabelDipulihkan.entries) {
          final namaTabel = entry.key;

          // Tabel asing diabaikan dengan aman
          if (!semuaTabelSkema.contains(namaTabel)) {
            continue;
          }

          final kolomSah = await _dapatkanKolomSah(namaTabel);
          final daftarBaris = entry.value;

          for (final row in daftarBaris) {
            // Abaikan kolom asing yang tidak dikenal oleh skema tabel
            final dataBersih = Map<String, dynamic>.from(row)
              ..removeWhere((k, v) => !kolomSah.contains(k));

            if (dataBersih.isEmpty) continue;

            final colNames = dataBersih.keys.toList();
            final placeholders = List.filled(colNames.length, '?').join(', ');
            final values = colNames.map((c) => dataBersih[c]).toList();

            final sql =
                'INSERT INTO $namaTabel (${colNames.join(', ')}) VALUES ($placeholders);';
            await basisData.customStatement(sql, values);
          }
        }

        // Periksa integritas Foreign Key sebelum transaksi selesai
        final pelanggaran = await basisData
            .customSelect('PRAGMA foreign_key_check;')
            .get();
        if (pelanggaran.isNotEmpty) {
          throw const GalatCadangan(
            'Ditemukan pelanggaran integritas data (foreign key check gagal). Pemulihan dibatalkan.',
          );
        }

        // Catat tanggal pemulihan di tabel_pengaturan menggunakan tipe DateTime Drift
        final waktuCadanganStr = doc.dibuatPada.toIso8601String();
        await basisData
            .into(basisData.tabelPengaturan)
            .insertOnConflictUpdate(
              TabelPengaturanCompanion.insert(
                kunci: 'terakhir_cadangan',
                nilai: waktuCadanganStr,
                diubahPada: Value(DateTime.now()),
              ),
            );
      });

      // Beri tahu seluruh stream Drift (watch) bahwa isi tabel telah diperbarui.
      basisData.markTablesUpdated(basisData.allTables);
    } on Exception catch (e) {
      if (e is GalatCadangan) rethrow;
      throw GalatCadangan('Gagal memulihkan basis data: $e');
    }
  }
}
