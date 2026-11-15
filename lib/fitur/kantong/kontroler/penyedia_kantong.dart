import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/basis_data.dart';
import '../../../data/penyedia_basis_data.dart';
import '../../../perhitungan/perhitungan_anggaran_tujuan.dart';
import '../../dompet/kontroler/penyedia_dompet.dart';

/// Stream provider seluruh kantong aktif milik dompet tertentu.
final penyediaKantongDompet =
    StreamProvider.family<List<EntitasKantong>, String>((ref, dompetId) {
      final repo = ref.watch(penyediaKantongRepositori);
      return repo.pantauKantongDompet(dompetId);
    });

/// Stream provider seluruh kantong yang tertaut pada suatu tujuan ID.
final penyediaKantongTujuan =
    StreamProvider.family<List<EntitasKantong>, String>((ref, tujuanId) {
      final repo = ref.watch(penyediaKantongRepositori);
      return repo.pantauKantongTujuan(tujuanId);
    });

/// Stream provider saldo satu kantong.
final penyediaSaldoKantong = StreamProvider.family<int, String>((
  ref,
  kantongId,
) {
  final repo = ref.watch(penyediaKantongRepositori);
  return repo.pantauSaldoKantongSQL(kantongId);
});

/// Stream provider riwayat alokasi suatu kantong.
final penyediaRiwayatAlokasiKantong =
    StreamProvider.family<List<EntitasAlokasiKantong>, String>((
      ref,
      kantongId,
    ) {
      final repo = ref.watch(penyediaKantongRepositori);
      return repo.pantauRiwayatAlokasiKantong(kantongId);
    });

/// Stream provider riwayat alokasi seluruh kantong suatu tujuan.
final penyediaRiwayatAlokasiTujuan =
    StreamProvider.family<List<EntitasAlokasiKantong>, String>((ref, tujuanId) {
      final repo = ref.watch(penyediaKantongRepositori);
      return repo.pantauRiwayatAlokasiTujuan(tujuanId);
    });

/// Provider saldo bebas dompet: Saldo Dompet - Total Seluruh Saldo Kantong di Dompet Tersebut.
final penyediaSaldoBebasDompet = Provider.family<int, String>((ref, dompetId) {
  final petaSaldo = ref.watch(penyediaPetaSaldoDompet);
  final saldoDompet = petaSaldo[dompetId] ?? 0;

  final kantongDompetAsync = ref.watch(penyediaKantongDompet(dompetId));
  final daftarKantong = kantongDompetAsync.value ?? [];

  // Hitung saldo masing-masing kantong
  final daftarSaldoKantong = <int>[];
  for (final k in daftarKantong) {
    final saldoK = ref.watch(penyediaSaldoKantong(k.id)).value ?? 0;
    daftarSaldoKantong.add(saldoK);
  }

  return hitungSaldoBebasDompet(
    saldoDompetRupiah: saldoDompet,
    daftarSaldoKantongRupiah: daftarSaldoKantong,
  );
});
