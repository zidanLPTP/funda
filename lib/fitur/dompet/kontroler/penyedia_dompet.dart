import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/basis_data.dart';
import '../../../data/penyedia_basis_data.dart';
import '../../../perhitungan/perhitungan_keuangan.dart';
import '../../transaksi/kontroler/penyedia_transaksi.dart';

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
