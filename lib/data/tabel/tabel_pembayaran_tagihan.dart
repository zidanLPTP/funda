import 'package:drift/drift.dart';
import 'tabel_tagihan.dart';
import 'tabel_transaksi.dart';

/// Tabel pencatatan periode tagihan yang sudah ditandai (dibayar atau dilewati).
@DataClassName('EntitasPembayaranTagihan')
class TabelPembayaranTagihan extends Table {
  TextColumn get id => text().named('id')();
  TextColumn get tagihanId => text()
      .named('tagihan_id')
      .references(TabelTagihan, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get jatuhTempo => dateTime().named('jatuh_tempo')();
  TextColumn get status => text().named('status')(); // dibayar | dilewati
  TextColumn get transaksiId => text()
      .named('transaksi_id')
      .nullable()
      .unique()
      .references(TabelTransaksi, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get dibuatPada => dateTime().named('dibuat_pada')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {tagihanId, jatuhTempo},
  ];
}
