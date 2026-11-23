import 'package:drift/drift.dart';

/// Tabel penyimpan sesi simulasi Mode Sandbox investasi fiktif.
///
/// Data pada tabel ini TERISOLASI TOTAL dari data riil pengguna,
/// tidak boleh diikutsertakan dalam cadangan data asli, dan tidak
/// mempengaruhi ringkasan keuangan, beranda, laporan, atau profil pengguna.
@DataClassName('EntitasSesiSandbox')
class TabelSesiSandbox extends Table {
  /// ID sesi sandbox (primary key).
  IntColumn get id => integer().autoIncrement()();

  /// Saldo modal fiktif awal dalam satuan Rupiah penuh.
  IntColumn get saldoAwalRupiah =>
      integer().withDefault(const Constant(10000000))();

  /// Persentase alokasi ke instrumen pasar uang (0..100).
  IntColumn get alokasiPasarUangPersen => integer()();

  /// Persentase alokasi ke instrumen obligasi (0..100).
  IntColumn get alokasiObligasiPersen => integer()();

  /// Persentase alokasi ke instrumen saham (0..100).
  IntColumn get alokasiSahamPersen => integer()();

  /// Jumlah bulan simulasi yang sudah berjalan (tiap loncatan 1 tahun = 12 bulan).
  IntColumn get bulanBerjalan => integer().withDefault(const Constant(0))();

  /// Nilai portofolio fiktif saat ini dalam satuan Rupiah penuh.
  IntColumn get nilaiSaatIniRupiah => integer()();

  /// Skenario pasar yang aktif: 'normal' | 'turun' | 'naik'.
  TextColumn get skenarioAktif => text()();

  /// Rekaman JSON riwayat langkah simulasi tahun demi tahun.
  TextColumn get riwayatJson => text()();

  /// Waktu sesi terakhir kali disimpan atau dimodifikasi.
  DateTimeColumn get diperbaruiPada => dateTime()();
}
