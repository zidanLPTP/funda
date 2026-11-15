import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../perhitungan/perhitungan_keuangan.dart';
import 'basis_data.dart';
import 'repositori/dompet_repositori.dart';
import 'repositori/kategori_repositori.dart';
import 'repositori/transaksi_repositori.dart';

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

/// Stream provider seluruh dompet (termasuk arsip).
final penyediaDaftarDompet = StreamProvider<List<EntitasDompet>>((ref) {
  final repo = ref.watch(penyediaDompetRepositori);
  return repo.pantauSemuaDompet();
});

/// Stream provider dompet yang aktif saja (tidak diarsipkan).
final penyediaDaftarDompetAktif = StreamProvider<List<EntitasDompet>>((ref) {
  final repo = ref.watch(penyediaDompetRepositori);
  return repo.pantauDompetAktif();
});

/// Stream provider seluruh kategori.
final penyediaDaftarKategori = StreamProvider<List<EntitasKategori>>((ref) {
  final repo = ref.watch(penyediaKategoriRepositori);
  return repo.pantauSemuaKategori();
});

/// Stream provider seluruh riwayat transaksi.
final penyediaDaftarTransaksi = StreamProvider<List<EntitasTransaksi>>((ref) {
  final repo = ref.watch(penyediaTransaksiRepositori);
  return repo.pantauSemuaTransaksi();
});

/// Provider peta saldo untuk seluruh dompet (dihitung secara reaktif dari baris transaksi).
final penyediaPetaSaldoDompet = Provider<Map<String, int>>((ref) {
  final daftarDompetAsync = ref.watch(penyediaDaftarDompet);
  final daftarTransaksiAsync = ref.watch(penyediaDaftarTransaksi);

  final daftarDompet = daftarDompetAsync.value ?? [];
  final daftarTransaksi = daftarTransaksiAsync.value ?? [];

  final petaSaldo = <String, int>{};
  for (final dompet in daftarDompet) {
    petaSaldo[dompet.id] = hitungSaldoDompet(
      dompetId: dompet.id,
      saldoAwalRupiah: dompet.saldoAwalRupiah,
      daftarTransaksi: daftarTransaksi,
    );
  }

  return petaSaldo;
});

/// Provider total saldo gabungan seluruh dompet aktif.
final penyediaTotalSaldoAktif = Provider<int>((ref) {
  final daftarDompetAsync = ref.watch(penyediaDaftarDompetAktif);
  final petaSaldo = ref.watch(penyediaPetaSaldoDompet);

  final daftarDompetAktif = daftarDompetAsync.value ?? [];
  return hitungTotalSaldo(
    daftarDompet: daftarDompetAktif,
    ambilSaldoDompet: (id) => petaSaldo[id] ?? 0,
  );
});

/// Provider hasil perhitungan arus kas bulan berjalan (dari data nyata).
final penyediaArusKasBulanIni = Provider<HasilArusKas>((ref) {
  final daftarTransaksiAsync = ref.watch(penyediaDaftarTransaksi);
  final daftarTransaksi = daftarTransaksiAsync.value ?? [];

  final sekarang = DateTime.now();
  final awalBulan = DateTime(sekarang.year, sekarang.month, 1);
  final akhirBulan = DateTime(sekarang.year, sekarang.month + 1, 0, 23, 59, 59);

  return hitungArusKas(
    daftarTransaksi: daftarTransaksi,
    mulai: awalBulan,
    selesai: akhirBulan,
  );
});
