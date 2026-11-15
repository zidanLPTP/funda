import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'basis_data.dart';
import 'repositori/anggaran_repositori.dart';
import 'repositori/dompet_repositori.dart';
import 'repositori/kantong_repositori.dart';
import 'repositori/kategori_repositori.dart';
import 'repositori/transaksi_repositori.dart';
import 'repositori/tujuan_repositori.dart';

/// Provider instans tunggal basis data Drift.
final penyediaBasisData = Provider<BasisDataFunda>((ref) {
  final db = BasisDataFunda();
  ref.onDispose(() => db.close());
  return db;
});

/// Provider repositori dompet.
final penyediaDompetRepositori = Provider<DompetRepositori>((ref) {
  final db = ref.watch(penyediaBasisData);
  return DompetRepositori(db);
});

/// Provider repositori kategori.
final penyediaKategoriRepositori = Provider<KategoriRepositori>((ref) {
  final db = ref.watch(penyediaBasisData);
  return KategoriRepositori(db);
});

/// Provider repositori transaksi.
final penyediaTransaksiRepositori = Provider<TransaksiRepositori>((ref) {
  final db = ref.watch(penyediaBasisData);
  return TransaksiRepositori(db);
});

/// Provider repositori anggaran bulanan.
final penyediaAnggaranRepositori = Provider<AnggaranRepositori>((ref) {
  final db = ref.watch(penyediaBasisData);
  final repoTransaksi = ref.watch(penyediaTransaksiRepositori);
  return AnggaranRepositori(db, repoTransaksi);
});

/// Provider repositori tujuan finansial.
final penyediaTujuanRepositori = Provider<TujuanRepositori>((ref) {
  final db = ref.watch(penyediaBasisData);
  return TujuanRepositori(db);
});

/// Provider repositori kantong dan alokasi saldo.
final penyediaKantongRepositori = Provider<KantongRepositori>((ref) {
  final db = ref.watch(penyediaBasisData);
  return KantongRepositori(db);
});
