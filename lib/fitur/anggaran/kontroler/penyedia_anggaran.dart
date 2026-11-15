import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/basis_data.dart';
import '../../../data/penyedia_basis_data.dart';
import '../../../perhitungan/perhitungan_anggaran_tujuan.dart';

/// Notifier untuk periode tahun & bulan anggaran yang sedang dipilih.
class PeriodeAnggaranNotifier extends Notifier<({int tahun, int bulan})> {
  @override
  ({int tahun, int bulan}) build() {
    final sekarang = DateTime.now();
    return (tahun: sekarang.year, bulan: sekarang.month);
  }

  void gantiBulan(int tahun, int bulan) {
    state = (tahun: tahun, bulan: bulan);
  }

  void bulanSebelumnya() {
    if (state.bulan == 1) {
      state = (tahun: state.tahun - 1, bulan: 12);
    } else {
      state = (tahun: state.tahun, bulan: state.bulan - 1);
    }
  }

  void bulanBerikutnya() {
    if (state.bulan == 12) {
      state = (tahun: state.tahun + 1, bulan: 1);
    } else {
      state = (tahun: state.tahun, bulan: state.bulan + 1);
    }
  }
}

/// Provider periode anggaran terpilih (tahun & bulan kalender).
final penyediaPeriodeAnggaran =
    NotifierProvider<PeriodeAnggaranNotifier, ({int tahun, int bulan})>(
      PeriodeAnggaranNotifier.new,
    );

/// Stream provider daftar anggaran untuk bulan yang sedang dipilih.
final penyediaDaftarAnggaranBulan = StreamProvider<List<EntitasAnggaran>>((
  ref,
) {
  final periode = ref.watch(penyediaPeriodeAnggaran);
  final repo = ref.watch(penyediaAnggaranRepositori);
  return repo.pantauAnggaranBulan(periode.tahun, periode.bulan);
});

/// Provider realisasi anggaran bulan terpilih (data batas + terpakai riil SQL).
final penyediaRealisasiAnggaranBulan =
    FutureProvider<List<ItemRealisasiAnggaran>>((ref) async {
      final periode = ref.watch(penyediaPeriodeAnggaran);
      final repo = ref.watch(penyediaAnggaranRepositori);
      // Re-trigger saat ada perubahan transaksi atau anggaran
      ref.watch(penyediaDaftarAnggaranBulan);
      return repo.ambilRealisasiAnggaranBulan(
        tahun: periode.tahun,
        bulan: periode.bulan,
      );
    });

/// Provider ringkasan total anggaran dan pengelompokan sifat kategori bulan terpilih.
final penyediaRingkasanAnggaranBulan = Provider<RingkasanAnggaran>((ref) {
  final realisasiAsync = ref.watch(penyediaRealisasiAnggaranBulan);
  final daftarItem = realisasiAsync.value ?? [];
  return hitungRingkasanAnggaran(daftarItem);
});

/// Provider sisa anggaran bulan berjalan (data NYATA untuk ditampilkan di Beranda).
final penyediaSisaAnggaranBulanIni = FutureProvider<int>((ref) async {
  final repo = ref.watch(penyediaAnggaranRepositori);
  final sekarang = DateTime.now();
  final items = await repo.ambilRealisasiAnggaranBulan(
    tahun: sekarang.year,
    bulan: sekarang.month,
  );
  if (items.isEmpty) return 0;
  final ringkasan = hitungRingkasanAnggaran(items);
  return ringkasan.totalSisaRupiah;
});
