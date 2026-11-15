import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/penyedia_basis_data.dart';
import '../../../layanan/pengingat/penyedia_layanan_pengingat.dart';

/// Notifier reaktif status saklar pengingat lokal (aktif / mati).
class PengaturanPengingatAktifNotifier extends Notifier<bool> {
  @override
  bool build() {
    _muatAwal();
    return false;
  }

  Future<void> _muatAwal() async {
    final db = ref.read(penyediaBasisData);
    final val = await db.bacaPengaturan('pengingat_aktif');
    state = val == 'true';
  }

  Future<void> setelAktif(bool aktif) async {
    state = aktif;
    final db = ref.read(penyediaBasisData);
    await db.simpanPengaturan('pengingat_aktif', aktif ? 'true' : 'false');
    await _pemicuSinkronisasi();
  }

  Future<void> _pemicuSinkronisasi() async {
    final repo = ref.read(penyediaTagihanRepositori);
    final layanan = ref.read(penyediaLayananPengingat);
    await repo.sinkronkanPengingat(layanan);
  }
}

final penyediaPengingatAktif =
    NotifierProvider<PengaturanPengingatAktifNotifier, bool>(
      PengaturanPengingatAktifNotifier.new,
    );

/// Notifier reaktif jam tayang pengingat (format "HH:mm").
class JamPengingatNotifier extends Notifier<String> {
  @override
  String build() {
    _muatAwal();
    return '09:00';
  }

  Future<void> _muatAwal() async {
    final db = ref.read(penyediaBasisData);
    final val = await db.bacaPengaturan('pengingat_jam');
    if (val != null && val.contains(':')) {
      state = val;
    }
  }

  Future<void> setelJam(int jam, int menit) async {
    final teks =
        '${jam.toString().padLeft(2, '0')}:${menit.toString().padLeft(2, '0')}';
    state = teks;
    final db = ref.read(penyediaBasisData);
    await db.simpanPengaturan('pengingat_jam', teks);
    await _pemicuSinkronisasi();
  }

  Future<void> _pemicuSinkronisasi() async {
    final repo = ref.read(penyediaTagihanRepositori);
    final layanan = ref.read(penyediaLayananPengingat);
    await repo.sinkronkanPengingat(layanan);
  }
}

final penyediaJamPengingat = NotifierProvider<JamPengingatNotifier, String>(
  JamPengingatNotifier.new,
);

/// Notifier opsi privasi: apakah menampilkan nominal rupiah di badan notifikasi.
class TampilkanNominalNotifikasiNotifier extends Notifier<bool> {
  @override
  bool build() {
    _muatAwal();
    return false;
  }

  Future<void> _muatAwal() async {
    final db = ref.read(penyediaBasisData);
    final val = await db.bacaPengaturan('pengingat_tampilkan_nominal');
    state = val == 'true';
  }

  Future<void> setelTampilkanNominal(bool tampilkan) async {
    state = tampilkan;
    final db = ref.read(penyediaBasisData);
    await db.simpanPengaturan(
      'pengingat_tampilkan_nominal',
      tampilkan ? 'true' : 'false',
    );
    final repo = ref.read(penyediaTagihanRepositori);
    final layanan = ref.read(penyediaLayananPengingat);
    await repo.sinkronkanPengingat(layanan);
  }
}

final penyediaTampilkanNominalNotifikasi =
    NotifierProvider<TampilkanNominalNotifikasiNotifier, bool>(
      TampilkanNominalNotifikasiNotifier.new,
    );
