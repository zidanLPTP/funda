import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/basis_data.dart';
import '../../../data/penyedia_basis_data.dart';

/// Stream provider seluruh tujuan yang aktif (sedang berjalan / tercapai).
final penyediaDaftarTujuanAktif = StreamProvider<List<EntitasTujuan>>((ref) {
  final repo = ref.watch(penyediaTujuanRepositori);
  return repo.pantauTujuanAktif();
});

/// Stream provider seluruh tujuan termasuk yang diarsipkan.
final penyediaDaftarSemuaTujuan = StreamProvider<List<EntitasTujuan>>((ref) {
  final repo = ref.watch(penyediaTujuanRepositori);
  return repo.pantauSemuaTujuan();
});

/// Stream provider total dana terkumpul untuk suatu tujuan ID (lintas dompet via kantong).
final penyediaDanaTujuan = StreamProvider.family<int, String>((ref, tujuanId) {
  final repoKantong = ref.watch(penyediaKantongRepositori);
  return repoKantong.pantauDanaTujuanSQL(tujuanId);
});

/// Stream provider satu detail tujuan berdasarkan ID.
final penyediaDetailTujuan = StreamProvider.family<EntitasTujuan?, String>((
  ref,
  tujuanId,
) {
  final repo = ref.watch(penyediaTujuanRepositori);
  return repo.pantauSemuaTujuan().map((daftar) {
    for (final t in daftar) {
      if (t.id == tujuanId) return t;
    }
    return null;
  });
});

/// Provider tujuan terdekat / prioritas untuk ditampilkan pada Beranda (data NYATA).
final penyediaTujuanTerdekat = Provider<EntitasTujuan?>((ref) {
  final daftarTujuanAsync = ref.watch(penyediaDaftarTujuanAktif);
  final daftarTujuan = daftarTujuanAsync.value ?? [];
  if (daftarTujuan.isEmpty) return null;

  // Prioritaskan tujuan yang belum tercapai
  final belumTercapai = daftarTujuan.where((t) => t.status == 'aktif').toList();
  if (belumTercapai.isNotEmpty) {
    // Cari yang memiliki tenggat paling dekat
    belumTercapai.sort((a, b) {
      if (a.tenggat == null && b.tenggat == null) return 0;
      if (a.tenggat == null) return 1;
      if (b.tenggat == null) return -1;
      return a.tenggat!.compareTo(b.tenggat!);
    });
    return belumTercapai.first;
  }
  return daftarTujuan.first;
});
