import '../../perhitungan/perhitungan_tagihan.dart';
import 'layanan_pengingat.dart';

/// Implementasi tiruan LayananPengingat untuk pengujian (mock/fake).
class LayananPengingatPalsu implements LayananPengingat {
  bool izinDiberikan = false;
  bool sudahInisialisasi = false;
  final List<RencanaPengingat> daftarTersimpan = [];
  void Function(String? rute)? padaKetuk;

  @override
  Future<void> inisialisasi({
    void Function(String? rute)? padaKetukNotifikasi,
  }) async {
    sudahInisialisasi = true;
    padaKetuk = padaKetukNotifikasi;
  }

  @override
  Future<bool> mintaIzin() async {
    izinDiberikan = true;
    return true;
  }

  @override
  Future<bool> cekStatusIzin() async {
    return izinDiberikan;
  }

  @override
  Future<void> jadwalkanPengingat(RencanaPengingat rencana) async {
    daftarTersimpan.add(rencana);
  }

  @override
  Future<void> batalkanSemuaPengingat() async {
    daftarTersimpan.clear();
  }

  @override
  Future<void> jadwalkanDaftarRencana(
    List<RencanaPengingat> daftarRencana,
  ) async {
    daftarTersimpan.clear();
    daftarTersimpan.addAll(daftarRencana);
  }

  /// Simulasi pengguna mengetuk notifikasi.
  void simulasikanKetukNotifikasi(String? payload) {
    final rute = uraiPayloadNotifikasi(payload);
    padaKetuk?.call(rute);
  }
}
