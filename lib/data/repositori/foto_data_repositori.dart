import '../basis_data.dart';
import '../../perhitungan/perhitungan_belajar.dart';

/// Repositori untuk mengambil foto data snapshot pengguna secara efisien via agregasi SQL.
/// Menjamin seluruh gerbang data dievaluasi dari SATU foto data terpadu (bebas N+1).
class FotoDataRepositori {
  final BasisDataFunda _db;

  const FotoDataRepositori(this._db);

  /// Mengambil snapshot lengkap data pengguna untuk evaluasi gerbang data.
  Future<FotoDataPengguna> ambilFotoData() async {
    final offsetDetik = DateTime.now().timeZoneOffset.inSeconds;

    // 1. Agregasi jumlah objek dasar (O(1) kueri agregasi)
    final barisRingkasan = await _db.customSelect(
      '''
      SELECT 
        (SELECT COUNT(*) FROM tabel_dompet WHERE diarsipkan = 0) as jml_dompet,
        (SELECT COUNT(*) FROM tabel_transaksi WHERE jenis = 'masuk') as jml_masuk,
        (SELECT COUNT(*) FROM tabel_transaksi WHERE jenis = 'keluar') as jml_keluar,
        (SELECT COUNT(*) FROM tabel_anggaran) as jml_anggaran,
        (SELECT COUNT(*) FROM tabel_tujuan WHERE status = 'aktif') as jml_tujuan,
        (SELECT COUNT(*) FROM tabel_utang WHERE status = 'aktif') as jml_utang,
        (SELECT COUNT(DISTINCT date(waktu_transaksi + $offsetDetik, 'unixepoch')) FROM tabel_transaksi) as hari_berbeda,
        (SELECT COUNT(DISTINCT strftime('%Y-%m', datetime(waktu_transaksi + $offsetDetik, 'unixepoch'))) FROM tabel_transaksi) as bulan_berbeda
      ''',
    ).getSingle();

    final jmlDompet = barisRingkasan.read<int>('jml_dompet');
    final jmlMasuk = barisRingkasan.read<int>('jml_masuk');
    final jmlKeluar = barisRingkasan.read<int>('jml_keluar');
    final jmlAnggaran = barisRingkasan.read<int>('jml_anggaran');
    final jmlTujuan = barisRingkasan.read<int>('jml_tujuan');
    final jmlUtang = barisRingkasan.read<int>('jml_utang');
    final hariBerbeda = barisRingkasan.read<int>('hari_berbeda');
    final bulanBerbeda = barisRingkasan.read<int>('bulan_berbeda');

    // 2. Kategori keluar aktif yang pernah dipakai transaksi beserta sifatnya
    final barisKategori = await _db.customSelect(
      '''
      SELECT DISTINCT k.id, k.sifat 
      FROM tabel_transaksi t 
      JOIN tabel_kategori k ON t.kategori_id = k.id 
      WHERE t.jenis = 'keluar'
      ''',
    ).get();

    final mapKategoriKeluar = <String, String>{};
    for (final b in barisKategori) {
      final id = b.read<String>('id');
      final sifat = b.read<String>('sifat');
      mapKategoriKeluar[id] = sifat;
    }

    // 3. Pernyataan pengguna
    final daftarPernyataan = await _db.select(_db.tabelPernyataan).get();
    final mapPernyataan = {for (final p in daftarPernyataan) p.kunci: p.nilai};

    // 4. Progres pelajaran
    final daftarProgres = await _db.select(_db.tabelProgresPelajaran).get();
    final mapProgres = {for (final p in daftarProgres) p.pelajaranId: p.status};

    // 5. Hasil kuis terbaik per modul
    final barisKuis = await _db.customSelect(
      '''
      SELECT modul_id, MAX(skor_persen) as skor, MAX(lulus) as lls
      FROM tabel_hasil_kuis
      GROUP BY modul_id
      ''',
    ).get();

    final mapKuis = <String, HasilKuisSnapshot>{};
    for (final b in barisKuis) {
      final mId = b.read<String>('modul_id');
      final skor = b.read<int>('skor');
      final llsNum = b.read<int>('lls');
      mapKuis[mId] = HasilKuisSnapshot(skorPersen: skor, lulus: llsNum > 0);
    }

    return FotoDataPengguna(
      jumlahDompetAktif: jmlDompet,
      jumlahPemasukan: jmlMasuk,
      jumlahPengeluaran: jmlKeluar,
      jumlahAnggaran: jmlAnggaran,
      jumlahTujuanAktif: jmlTujuan,
      jumlahUtangAktif: jmlUtang,
      kategoriKeluarTerpakai: mapKategoriKeluar,
      hariTransaksiBerbeda: hariBerbeda,
      bulanTransaksiBerbeda: bulanBerbeda,
      pernyataan: mapPernyataan,
      progresPelajaran: mapProgres,
      hasilKuisTerbaik: mapKuis,
    );
  }
}
