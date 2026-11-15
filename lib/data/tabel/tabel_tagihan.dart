import 'package:drift/drift.dart';
import 'tabel_dompet.dart';
import 'tabel_kategori.dart';

/// Tabel penyimpanan master tagihan dan langganan berulang.
@DataClassName('EntitasTagihan')
class TabelTagihan extends Table {
  TextColumn get id => text().named('id')();
  TextColumn get nama => text().named('nama')();
  TextColumn get jenis => text().named('jenis')(); // tagihan | langganan
  IntColumn get jumlahPerkiraanRupiah =>
      integer().named('jumlah_perkiraan_rupiah').nullable()();
  TextColumn get kategoriId =>
      text().named('kategori_id').references(TabelKategori, #id)();
  TextColumn get dompetId =>
      text().named('dompet_id').nullable().references(TabelDompet, #id)();
  TextColumn get frekuensi =>
      text().named('frekuensi')(); // mingguan | bulanan | tahunan
  DateTimeColumn get jatuhTempoPertama =>
      dateTime().named('jatuh_tempo_pertama')();
  DateTimeColumn get berakhirPada =>
      dateTime().named('berakhir_pada').nullable()();
  TextColumn get pengingatHariSebelum => text()
      .named('pengingat_hari_sebelum')
      .withDefault(const Constant('[]'))();
  BoolColumn get aktif =>
      boolean().named('aktif').withDefault(const Constant(true))();
  BoolColumn get diarsipkan =>
      boolean().named('diarsipkan').withDefault(const Constant(false))();
  DateTimeColumn get dibuatPada => dateTime().named('dibuat_pada')();

  @override
  Set<Column> get primaryKey => {id};
}
