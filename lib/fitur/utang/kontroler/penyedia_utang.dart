import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/basis_data.dart';
import '../../../data/penyedia_basis_data.dart';
import '../../../data/repositori/utang_repositori.dart';
import '../../../perhitungan/perhitungan_utang_dashboard.dart';
import '../../dompet/kontroler/penyedia_dompet.dart';
import '../../transaksi/kontroler/penyedia_transaksi.dart';

/// Stream provider daftar utang yang masih aktif.
final penyediaDaftarUtangAktif = StreamProvider<List<EntitasUtang>>((ref) {
  final repo = ref.watch(penyediaUtangRepositori);
  return repo.pantauDaftarUtangAktif();
});

/// Stream provider daftar utang yang sudah berstatus lunas.
final penyediaDaftarUtangLunas = StreamProvider<List<EntitasUtang>>((ref) {
  final repo = ref.watch(penyediaUtangRepositori);
  return repo.pantauDaftarUtangLunas();
});

/// Stream provider seluruh daftar utang.
final penyediaDaftarSemuaUtang = StreamProvider<List<EntitasUtang>>((ref) {
  final repo = ref.watch(penyediaUtangRepositori);
  return repo.pantauSemuaUtang();
});

/// Stream provider sisa utang tertentu via agregasi SQL.
final penyediaSisaUtang = StreamProvider.family<int, String>((ref, utangId) {
  final repo = ref.watch(penyediaUtangRepositori);
  return repo.pantauSisaUtangSQL(utangId);
});

/// Stream provider total sisa seluruh utang aktif via agregasi SQL.
final penyediaTotalSisaUtangAktif = StreamProvider<int>((ref) {
  final repo = ref.watch(penyediaUtangRepositori);
  return repo.pantauTotalSisaUtangAktifSQL();
});

/// Provider total cicilan bulanan yang wajib dibayar dari seluruh utang aktif.
final penyediaTotalCicilanBulananAktif = Provider<int>((ref) {
  final daftarUtang = ref.watch(penyediaDaftarUtangAktif).value ?? [];
  return hitungTotalCicilanBulanan(
    daftarUtang.map((u) => u.cicilanBulananRupiah).toList(),
  );
});

/// Provider pemasukan bulanan rata-rata pengguna (berdasarkan 3 bulan kalender terakhir atau bulan berjalan).
final penyediaPemasukanBulananRataRata = Provider<HasilPemasukanRataRata>((
  ref,
) {
  final daftarTransaksi = ref.watch(penyediaDaftarTransaksi).value ?? [];
  return hitungPemasukanBulananRataRata(
    daftarTransaksi: daftarTransaksi,
    waktuSekarang: DateTime.now(),
  );
});

/// Provider rasio cicilan terhadap pemasukan bulanan (dalam persentase integer).
final penyediaRasioCicilan = Provider<int?>((ref) {
  final totalCicilan = ref.watch(penyediaTotalCicilanBulananAktif);
  final pemasukanRataRata = ref
      .watch(penyediaPemasukanBulananRataRata)
      .nilaiRupiah;
  return hitungRasioCicilan(
    totalCicilanBulananRupiah: totalCicilan,
    pemasukanBulananRupiah: pemasukanRataRata,
  );
});

/// Provider kekayaan bersih pengguna: Total Saldo Dompet Aktif - Total Sisa Utang Aktif.
final penyediaKekayaanBersih = Provider<int>((ref) {
  final totalSaldo = ref.watch(penyediaTotalSaldoAktif);
  final totalUtang = ref.watch(penyediaTotalSisaUtangAktif).value ?? 0;
  return hitungKekayaanBersih(
    totalSaldoDompetAktifRupiah: totalSaldo,
    totalSisaUtangRupiah: totalUtang,
  );
});

/// Stream provider riwayat pembayaran untuk suatu utang.
final penyediaRiwayatPembayaranUtang =
    StreamProvider.family<List<ItemRiwayatPembayaranUtang>, String>((
      ref,
      utangId,
    ) {
      final repo = ref.watch(penyediaUtangRepositori);
      return repo.pantauRiwayatPembayaranUtang(utangId);
    });

/// Stream provider riwayat penyesuaian untuk suatu utang.
final penyediaRiwayatPenyesuaianUtang =
    StreamProvider.family<List<EntitasPenyesuaianUtang>, String>((
      ref,
      utangId,
    ) {
      final repo = ref.watch(penyediaUtangRepositori);
      return repo.pantauRiwayatPenyesuaianUtang(utangId);
    });
