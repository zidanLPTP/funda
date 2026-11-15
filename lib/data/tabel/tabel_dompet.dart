import 'package:drift/drift.dart';

/// Skema tabel dompet Funda.
@DataClassName('EntitasDompet')
class TabelDompet extends Table {
  @override
  String get tableName => 'tabel_dompet';

  /// Pengenal unik dompet (UUID).
  TextColumn get id => text()();

  /// Nama dompet (misal: 'Kantong Utama', 'BCA', 'GoPay', 'Dompet Tunai').
  TextColumn get nama => text().withLength(min: 1, max: 100)();

  /// Jenis dompet ('tunai', 'rekening_bank', 'e_wallet', 'lainnya').
  TextColumn get jenis => text()();

  /// Kunci pengenal ikon dari pustaka Lucide.
  TextColumn get ikon => text()();

  /// Kunci token warna tint (misal: 'tintHijau', 'tintBiru', 'tintUngu', dll).
  TextColumn get warna => text()();

  /// Saldo awal saat dompet pertama kali dibuat (dalam Rupiah integer >= 0).
  IntColumn get saldoAwalRupiah => integer().withDefault(const Constant(0))();

  /// Urutan tampilan pada antarmuka.
  IntColumn get urutan => integer().withDefault(const Constant(0))();

  /// Penanda status arsip (dompet yang diarsipkan disembunyikan dari pemilihan).
  BoolColumn get diarsipkan => boolean().withDefault(const Constant(false))();

  /// Waktu pembuatan catatan dompet.
  DateTimeColumn get dibuatPada => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
