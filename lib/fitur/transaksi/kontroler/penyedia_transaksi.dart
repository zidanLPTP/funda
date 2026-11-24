import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/basis_data.dart';
import '../../../data/penyedia_basis_data.dart';
import '../../../perhitungan/perhitungan_keuangan.dart';

/// Parameter konfigurasi kueri transaksi berhalaman di SQL.
class ParameterKueriTransaksi {
  const ParameterKueriTransaksi({
    this.limit = 50,
    this.offset = 0,
    this.kataKunci,
    this.dompetId,
    this.kategoriId,
    this.sifat,
    this.jenis,
    this.mulai,
    this.selesai,
  });

  final int limit;
  final int offset;
  final String? kataKunci;
  final String? dompetId;
  final String? kategoriId;
  final String? sifat;
  final String? jenis;
  final DateTime? mulai;
  final DateTime? selesai;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParameterKueriTransaksi &&
          runtimeType == other.runtimeType &&
          limit == other.limit &&
          offset == other.offset &&
          kataKunci == other.kataKunci &&
          dompetId == other.dompetId &&
          kategoriId == other.kategoriId &&
          sifat == other.sifat &&
          jenis == other.jenis &&
          mulai == other.mulai &&
          selesai == other.selesai;

  @override
  int get hashCode => Object.hash(
    limit,
    offset,
    kataKunci,
    dompetId,
    kategoriId,
    sifat,
    jenis,
    mulai,
    selesai,
  );
}

/// Stream provider riwayat transaksi berhalaman dengan filter WHERE di level SQL.
final penyediaTransaksiBerhalaman =
    StreamProvider.family<List<EntitasTransaksi>, ParameterKueriTransaksi>((
      ref,
      param,
    ) {
      final repo = ref.watch(penyediaTransaksiRepositori);
      return repo.pantauTransaksiBerhalaman(
        limit: param.limit,
        offset: param.offset,
        kataKunci: param.kataKunci,
        dompetId: param.dompetId,
        kategoriId: param.kategoriId,
        sifat: param.sifat,
        jenis: param.jenis,
        mulai: param.mulai,
        selesai: param.selesai,
      );
    });

/// Stream provider seluruh riwayat transaksi.
final penyediaDaftarTransaksi = StreamProvider<List<EntitasTransaksi>>((ref) {
  final repo = ref.watch(penyediaTransaksiRepositori);
  return repo.pantauSemuaTransaksi();
});

/// Stream provider 5 transaksi terbaru untuk petak dashboard Beranda.
final penyediaLimaTransaksiTerakhir = StreamProvider<List<EntitasTransaksi>>((
  ref,
) {
  final repo = ref.watch(penyediaTransaksiRepositori);
  return repo.pantauTransaksiBerhalaman(limit: 5);
});

/// Stream provider reaktif hasil agregasi arus kas via SQL.
final penyediaStreamArusKasBulanIni =
    StreamProvider.family<
      HasilArusKas,
      ({DateTime awalBulan, DateTime akhirBulan})
    >((ref, param) {
      final repo = ref.watch(penyediaTransaksiRepositori);
      return repo.pantauArusKasSQL(
        mulai: param.awalBulan,
        selesai: param.akhirBulan,
      );
    });

/// Stream provider agregasi pengeluaran per sifat kategori untuk bulan berjalan (bebas N+1, O(1) baris).
final penyediaKomposisiSifatBulanIni = StreamProvider<Map<String, int>>((ref) {
  final repo = ref.watch(penyediaTransaksiRepositori);
  final sekarang = DateTime.now();
  final awalBulan = DateTime(sekarang.year, sekarang.month, 1);
  return repo.pantauKomposisiSifatBulanIniSQL(awalBulan);
});
final penyediaArusKasBulanIni = Provider<HasilArusKas>((ref) {
  final sekarang = DateTime.now();
  final awalBulan = DateTime(sekarang.year, sekarang.month, 1);
  final akhirBulan = DateTime(sekarang.year, sekarang.month + 1, 0, 23, 59, 59);

  final arusKasAsync = ref.watch(
    penyediaStreamArusKasBulanIni((
      awalBulan: awalBulan,
      akhirBulan: akhirBulan,
    )),
  );
  return arusKasAsync.value ??
      const HasilArusKas(totalMasuk: 0, totalKeluar: 0, selisih: 0);
});
