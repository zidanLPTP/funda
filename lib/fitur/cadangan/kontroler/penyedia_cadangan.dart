import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/basis_data.dart';
import '../../../data/cadangan/cadangan_repositori.dart';
import '../../../data/penyedia_basis_data.dart';
import '../../../layanan/laporan/layanan_bagikan.dart';
import '../../../perhitungan/perhitungan_pengingat_cadangan.dart';

/// Provider repositori cadangan.
final penyediaCadanganRepositori = Provider<CadanganRepositori>((ref) {
  final db = ref.watch(penyediaBasisData);
  return CadanganRepositori(db);
});

/// Model data status ringkas fitur cadangan.
class StatusFiturCadangan {
  final DateTime? terakhirDicadangkan;
  final bool adaCadanganKeselamatan;
  final int jumlahTransaksi;
  final int hariSejakDataPertama;
  final DateTime? ditundaSampai;
  final bool perluPengingat;

  const StatusFiturCadangan({
    required this.terakhirDicadangkan,
    required this.adaCadanganKeselamatan,
    required this.jumlahTransaksi,
    required this.hariSejakDataPertama,
    required this.ditundaSampai,
    required this.perluPengingat,
  });
}

/// Provider status pencadangan dan kelayakan banner pengingat.
final penyediaStatusCadangan = FutureProvider<StatusFiturCadangan>((ref) async {
  final db = ref.watch(penyediaBasisData);
  final repo = ref.watch(penyediaCadanganRepositori);

  // 1. Ambil waktu terakhir cadangan dari tabel_pengaturan
  final rowCadangan = await (db.select(db.tabelPengaturan)
        ..where((t) => t.kunci.equals('terakhir_cadangan')))
      .getSingleOrNull();

  DateTime? terakhir;
  if (rowCadangan != null && rowCadangan.nilai.isNotEmpty) {
    try {
      terakhir = DateTime.parse(rowCadangan.nilai);
    } catch (_) {}
  }

  // 2. Ambil penundaan pengingat jika ada
  final rowTunda = await (db.select(db.tabelPengaturan)
        ..where((t) => t.kunci.equals('pengingat_cadangan_ditunda_sampai')))
      .getSingleOrNull();

  DateTime? ditundaSampai;
  if (rowTunda != null && rowTunda.nilai.isNotEmpty) {
    try {
      ditundaSampai = DateTime.parse(rowTunda.nilai);
    } catch (_) {}
  }

  // 3. Hitung jumlah transaksi dan hari sejak transaksi pertama
  final countRow = await db.customSelect('SELECT count(*) as total FROM tabel_transaksi;').getSingle();
  final jumlahTx = countRow.read<int>('total');

  var hariSejakDataPertama = 0;
  final firstRow = await (db.select(db.tabelTransaksi)
        ..orderBy([(t) => OrderingTerm(expression: t.waktuTransaksi, mode: OrderingMode.asc)])
        ..limit(1))
      .getSingleOrNull();

  final sekarang = DateTime.now();
  if (firstRow != null) {
    hariSejakDataPertama = sekarang.difference(firstRow.waktuTransaksi).inDays;
  }

  // 4. Periksa apakah ada transaksi baru sejak pencadangan terakhir
  var adaTransaksiBaru = true;
  if (terakhir != null) {
    final countBaruRow = await (db.select(db.tabelTransaksi)
          ..where((t) => t.waktuTransaksi.isBiggerThan(Variable.withDateTime(terakhir!))))
        .get();
    adaTransaksiBaru = countBaruRow.isNotEmpty;
  }

  // 5. Periksa keberadaan cadangan keselamatan
  final adaKeselamatan = await repo.adaCadanganKeselamatan();

  // 6. Evaluasi fungsi murni pengingat cadangan
  final perlu = perluIngatkanCadangan(
    sekarang: sekarang,
    terakhirCadangan: terakhir,
    jumlahTransaksi: jumlahTx,
    hariSejakDataPertama: hariSejakDataPertama,
    ditundaSampai: ditundaSampai,
    adaTransaksiBaruSejakCadangan: adaTransaksiBaru,
  );

  return StatusFiturCadangan(
    terakhirDicadangkan: terakhir,
    adaCadanganKeselamatan: adaKeselamatan,
    jumlahTransaksi: jumlahTx,
    hariSejakDataPertama: hariSejakDataPertama,
    ditundaSampai: ditundaSampai,
    perluPengingat: perlu,
  );
});

/// Aksi untuk menunda pengingat cadangan selama [durasiHari] (default: 14 hari).
Future<void> tundaPengingatCadangan(WidgetRef ref, {int durasiHari = 14}) async {
  final db = ref.read(penyediaBasisData);
  final tundaSampai = DateTime.now().add(Duration(days: durasiHari));

  await db.into(db.tabelPengaturan).insertOnConflictUpdate(
        TabelPengaturanCompanion.insert(
          kunci: 'pengingat_cadangan_ditunda_sampai',
          nilai: tundaSampai.toIso8601String(),
        ),
      );

  ref.invalidate(penyediaStatusCadangan);
}

/// Aksi untuk membuat berkas cadangan dan membagikannya ke sistem.
Future<void> buatDanBagikanCadangan(WidgetRef ref) async {
  final repo = ref.read(penyediaCadanganRepositori);
  final layanan = ref.read(penyediaLayananBagikan);

  final sekarang = DateTime.now();
  final jsonString = await repo.eksporCadanganKeJson(waktuDibuat: sekarang);

  final namaBerkas = 'funda_cadangan_${sekarang.year}-${sekarang.month.toString().padLeft(2, '0')}-${sekarang.day.toString().padLeft(2, '0')}.json';
  final berkas = await layanan.simpanBerkas(
    namaBerkas: namaBerkas,
    bytes: utf8.encode(jsonString),
  );

  // Catat tanggal cadangan di tabel_pengaturan
  final db = ref.read(penyediaBasisData);
  await db.into(db.tabelPengaturan).insertOnConflictUpdate(
        TabelPengaturanCompanion.insert(
          kunci: 'terakhir_cadangan',
          nilai: sekarang.toIso8601String(),
        ),
      );

  ref.invalidate(penyediaStatusCadangan);

  await layanan.bagikanBerkas(
    pathBerkas: berkas.path,
    judul: 'Cadangan Data Funda ($namaBerkas)',
    teks: 'Berkas cadangan data keuangan lokal dari aplikasi Funda.',
  );
}
