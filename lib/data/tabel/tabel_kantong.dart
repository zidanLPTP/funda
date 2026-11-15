import 'package:drift/drift.dart';
import 'tabel_dompet.dart';
import 'tabel_tujuan.dart';

/// Tabel kantong alokasi saldo dompet untuk pos tertentu atau tertaut ke tujuan.
@DataClassName('EntitasKantong')
class TabelKantong extends Table {
  TextColumn get id => text()();
  TextColumn get dompetId => text().references(TabelDompet, #id)();
  TextColumn get tujuanId => text().nullable().references(TabelTujuan, #id)();
  TextColumn get nama => text()();
  TextColumn get ikon => text()();
  TextColumn get warna => text()();
  BoolColumn get diarsipkan => boolean().withDefault(const Constant(false))();
  DateTimeColumn get dibuatPada => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
