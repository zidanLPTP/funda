import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Model representasi berkas cadangan Funda sesuai spesifikasi docs/format_cadangan.md.
class DokumenCadanganFunda {
  final String format;
  final int versiFormat;
  final int versiSkema;
  final String versiAplikasi;
  final DateTime dibuatPada;
  final Map<String, int> jumlahBaris;
  final String checksum;
  final Map<String, List<Map<String, dynamic>>> tabel;

  const DokumenCadanganFunda({
    this.format = 'funda_cadangan',
    this.versiFormat = 1,
    required this.versiSkema,
    required this.versiAplikasi,
    required this.dibuatPada,
    required this.jumlahBaris,
    required this.checksum,
    required this.tabel,
  });

  /// Mengonversi berkas cadangan ke Map JSON siap serialisasi.
  Map<String, dynamic> toJson() {
    return {
      'format': format,
      'versiFormat': versiFormat,
      'versiSkema': versiSkema,
      'versiAplikasi': versiAplikasi,
      'dibuatPada': dibuatPada.toUtc().toIso8601String(),
      'jumlahBaris': jumlahBaris,
      'checksum': checksum,
      'tabel': tabel,
    };
  }

  /// Membangun DokumenCadanganFunda dari JSON map.
  factory DokumenCadanganFunda.fromJson(Map<String, dynamic> json) {
    final rawTabel = json['tabel'] as Map<String, dynamic>? ?? {};
    final tabelMap = <String, List<Map<String, dynamic>>>{};

    for (final entry in rawTabel.entries) {
      if (entry.value is List) {
        final barisList = <Map<String, dynamic>>[];
        for (final row in entry.value as List) {
          if (row is Map<String, dynamic>) {
            barisList.add(Map<String, dynamic>.from(row));
          }
        }
        tabelMap[entry.key] = barisList;
      }
    }

    final rawJumlahBaris = json['jumlahBaris'] as Map<String, dynamic>? ?? {};
    final jumlahBarisMap = rawJumlahBaris.map(
      (k, v) => MapEntry(k, (v as num).toInt()),
    );

    return DokumenCadanganFunda(
      format: json['format'] as String? ?? 'funda_cadangan',
      versiFormat: (json['versiFormat'] as num?)?.toInt() ?? 1,
      versiSkema: (json['versiSkema'] as num?)?.toInt() ?? 1,
      versiAplikasi: json['versiAplikasi'] as String? ?? '0.9.0',
      dibuatPada: DateTime.parse(json['dibuatPada'] as String),
      jumlahBaris: jumlahBarisMap,
      checksum: json['checksum'] as String? ?? '',
      tabel: tabelMap,
    );
  }
}

/// Menghasilkan representasi string kanonik deterministik dari map tabel.
/// Aturan kanonik:
/// 1. Kunci tabel terurut alfabetis.
/// 2. Baris tabel tetap terurut (kunci utama).
/// 3. Kunci kolom pada setiap baris terurut alfabetis.
String bangunStringKanonikTabel(Map<String, List<Map<String, dynamic>>> tabel) {
  final tabelKeys = tabel.keys.toList()..sort();
  final kanonikTabel = <String, List<Map<String, dynamic>>>{};

  for (final tKey in tabelKeys) {
    final rows = tabel[tKey] ?? [];
    final kanonikRows = <Map<String, dynamic>>[];

    for (final row in rows) {
      final colKeys = row.keys.toList()..sort();
      final kanonikRow = <String, dynamic>{};
      for (final cKey in colKeys) {
        kanonikRow[cKey] = row[cKey];
      }
      kanonikRows.add(kanonikRow);
    }
    kanonikTabel[tKey] = kanonikRows;
  }

  return jsonEncode(kanonikTabel);
}

/// Menghitung checksum SHA-256 hex dari isi tabel dalam bentuk kanonik.
String hitungChecksumTabel(Map<String, List<Map<String, dynamic>>> tabel) {
  final stringKanonik = bangunStringKanonikTabel(tabel);
  final bytes = utf8.encode(stringKanonik);
  return sha256.convert(bytes).toString();
}

/// Model pratinjau cadangan sebelum pemulihan dieksekusi.
class PratinjauCadangan {
  final DateTime dibuatPada;
  final int versiSkema;
  final String versiAplikasi;
  final int jumlahDompet;
  final int jumlahTransaksi;
  final int jumlahAnggaran;
  final int jumlahTujuan;
  final int jumlahUtang;
  final int jumlahTagihan;

  const PratinjauCadangan({
    required this.dibuatPada,
    required this.versiSkema,
    required this.versiAplikasi,
    required this.jumlahDompet,
    required this.jumlahTransaksi,
    required this.jumlahAnggaran,
    required this.jumlahTujuan,
    required this.jumlahUtang,
    required this.jumlahTagihan,
  });

  factory PratinjauCadangan.dariDokumen(DokumenCadanganFunda doc) {
    return PratinjauCadangan(
      dibuatPada: doc.dibuatPada,
      versiSkema: doc.versiSkema,
      versiAplikasi: doc.versiAplikasi,
      jumlahDompet:
          doc.jumlahBaris['tabel_dompet'] ??
          doc.tabel['tabel_dompet']?.length ??
          0,
      jumlahTransaksi:
          doc.jumlahBaris['tabel_transaksi'] ??
          doc.tabel['tabel_transaksi']?.length ??
          0,
      jumlahAnggaran:
          doc.jumlahBaris['tabel_anggaran'] ??
          doc.tabel['tabel_anggaran']?.length ??
          0,
      jumlahTujuan:
          doc.jumlahBaris['tabel_tujuan'] ??
          doc.tabel['tabel_tujuan']?.length ??
          0,
      jumlahUtang:
          doc.jumlahBaris['tabel_utang'] ??
          doc.tabel['tabel_utang']?.length ??
          0,
      jumlahTagihan:
          doc.jumlahBaris['tabel_tagihan'] ??
          doc.tabel['tabel_tagihan']?.length ??
          0,
    );
  }
}
