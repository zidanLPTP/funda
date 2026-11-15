import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'layanan_pengingat.dart';
import 'layanan_pengingat_nyata.dart';

/// Provider global layanan pengingat (dapat dioverride dengan LayananPengingatPalsu pada pengujian).
final penyediaLayananPengingat = Provider<LayananPengingat>((ref) {
  return LayananPengingatNyata();
});
