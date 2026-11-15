import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/basis_data.dart';
import '../../../data/penyedia_basis_data.dart';
import '../../../data/repositori/tagihan_repositori.dart';
import '../../../layanan/pengingat/penyedia_layanan_pengingat.dart';
import '../../../perhitungan/perhitungan_tagihan.dart';

/// Stream provider seluruh master tagihan.
final penyediaDaftarTagihan = StreamProvider<List<EntitasTagihan>>((ref) {
  final repo = ref.watch(penyediaTagihanRepositori);
  return repo.pantauSemuaTagihan();
});

/// Stream provider tagihan aktif (tidak diarsipkan).
final penyediaDaftarTagihanAktif = StreamProvider<List<EntitasTagihan>>((ref) {
  final repo = ref.watch(penyediaTagihanRepositori);
  return repo.pantauTagihanAktif();
});

/// Notifier pengubah bulan pilihan di layar jadwal tagihan.
class BulanJadwalNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final sekarang = DateTime.now();
    return DateTime(sekarang.year, sekarang.month, 1);
  }

  void gantiBulan(int delta) {
    state = DateTime(state.year, state.month + delta, 1);
  }

  void setelBulan(DateTime waktu) {
    state = DateTime(waktu.year, waktu.month, 1);
  }
}

final penyediaBulanJadwalTerpilih =
    NotifierProvider<BulanJadwalNotifier, DateTime>(BulanJadwalNotifier.new);

/// Future provider jadwal tagihan & cicilan utang untuk bulan yang dipilih.
final penyediaJadwalBulanTerpilih = FutureProvider<List<ItemJadwalTampilan>>((
  ref,
) async {
  // Pemicu reaktivitas saat master tagihan berubah
  ref.watch(penyediaDaftarTagihan);

  final repo = ref.watch(penyediaTagihanRepositori);
  final bulan = ref.watch(penyediaBulanJadwalTerpilih);

  final awalBulan = DateTime(bulan.year, bulan.month, 1);
  final akhirBulan = DateTime(bulan.year, bulan.month + 1, 0, 23, 59, 59);

  return repo.ambilJadwalGabungan(mulai: awalBulan, selesai: akhirBulan);
});

/// Provider ringkasan keuangan tagihan untuk bulan yang dipilih.
final penyediaRingkasanBulanTerpilih = Provider<RingkasanBulanTagihan>((ref) {
  final jadwalAsync = ref.watch(penyediaJadwalBulanTerpilih);
  final jadwal = jadwalAsync.value ?? [];

  final itemKalkulasi = jadwal.map((j) {
    return ItemKalkulasiJadwal(
      idTagihan: j.idTagihan,
      nama: j.nama,
      tanggal: j.tanggalJatuhTempo,
      jumlahPerkiraanRupiah: j.jumlahPerkiraanRupiah,
      status: j.status,
      jumlahAktualBayarRupiah: j.jumlahAktualRupiah,
      hariSebelumPengingat: j.hariSebelumPengingat,
      isCicilanUtang: j.isCicilanUtang,
      idUtang: j.idUtang,
    );
  }).toList();

  return hitungRingkasanBulanTagihan(itemKalkulasi);
});

/// Provider tagihan terdekat dalam 7 hari ke depan atau lewat dan belum ditandai (untuk Beranda).
final penyediaTagihanTerdekatBeranda = FutureProvider<ItemJadwalTampilan?>((
  ref,
) async {
  ref.watch(penyediaDaftarTagihan);

  final repo = ref.watch(penyediaTagihanRepositori);
  final sekarang = DateTime.now();
  final hariIni = DateTime(sekarang.year, sekarang.month, sekarang.day);

  // Ambil rentang: 60 hari ke belakang (untuk yang lewat belum ditandai) s.d. 7 hari ke depan
  final mulai = hariIni.subtract(const Duration(days: 60));
  final selesai = hariIni.add(const Duration(days: 7));

  final jadwal = await repo.ambilJadwalGabungan(
    mulai: mulai,
    selesai: selesai,
    waktuSekarang: sekarang,
  );

  // Filter yang belum ditandai (bukan dibayar dan bukan dilewati)
  final belumDitandai = jadwal.where((j) {
    return j.status != StatusKemunculan.dibayar &&
        j.status != StatusKemunculan.dilewati &&
        j.status != StatusKemunculan.lewatKedaluwarsa;
  }).toList();

  if (belumDitandai.isEmpty) return null;

  // Prioritaskan yang hari ini atau lewat terlebih dahulu, lalu yang terdekat dalam 7 hari
  belumDitandai.sort((a, b) {
    // Lewat dan hari ini di depan
    final aPrioritas = a.selisihHari <= 0 ? 0 : 1;
    final bPrioritas = b.selisihHari <= 0 ? 0 : 1;
    if (aPrioritas != bPrioritas) return aPrioritas.compareTo(bPrioritas);
    return a.tanggalJatuhTempo.compareTo(b.tanggalJatuhTempo);
  });

  return belumDitandai.first;
});

/// Helper pemicu sinkronisasi notifikasi ke sistem lokal.
Future<void> sinkronkanPengingatLokal(WidgetRef ref) async {
  final repo = ref.read(penyediaTagihanRepositori);
  final layanan = ref.read(penyediaLayananPengingat);
  await repo.sinkronkanPengingat(layanan);
}
