import '../../perhitungan/perhitungan_tagihan.dart';

/// Antarmuka abstrak layanan pengingat lokal Funda.
abstract class LayananPengingat {
  /// Menginisialisasi plugin notifikasi dan callback ketuk.
  Future<void> inisialisasi({void Function(String? rute)? padaKetukNotifikasi});

  /// Meminta izin notifikasi kepada pengguna (hanya dipanggil saat pengguna menyalakan saklar).
  Future<bool> mintaIzin();

  /// Memeriksa status izin notifikasi saat ini.
  Future<bool> cekStatusIzin();

  /// Menjadwalkan satu pengingat lokal.
  Future<void> jadwalkanPengingat(RencanaPengingat rencana);

  /// Membatalkan seluruh pengingat yang pernah dijadwalkan oleh aplikasi.
  Future<void> batalkanSemuaPengingat();

  /// Mengganti seluruh jadwal pengingat lama dengan daftar rencana baru.
  Future<void> jadwalkanDaftarRencana(List<RencanaPengingat> daftarRencana);
}

/// Fungsi murni mengurai payload rute dari aksi ketuk notifikasi.
String uraiPayloadNotifikasi(String? payload) {
  if (payload == null || payload.trim().isEmpty) return '/tagihan';
  return payload;
}
