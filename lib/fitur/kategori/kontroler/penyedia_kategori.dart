import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/basis_data.dart';
import '../../../data/penyedia_basis_data.dart';

/// Stream provider seluruh kategori.
final penyediaDaftarKategori = StreamProvider<List<EntitasKategori>>((ref) {
  final repo = ref.watch(penyediaKategoriRepositori);
  return repo.pantauSemuaKategori();
});
