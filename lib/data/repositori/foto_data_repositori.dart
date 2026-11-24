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
        (SELECT COUNT(DISTINCT strftime('%Y-%m', datetime(waktu_transaksi + $offsetDetik, 'unixepoch'))) FROM tabel_transaksi) as bulan_berbeda,
        (SELECT COUNT(*) FROM tabel_profil_keuangan) as jml_profil,
        (SELECT COUNT(*) FROM tabel_tujuan WHERE status = 'aktif' AND jenis = 'dana_darurat') as jml_tujuan_darurat,
        (SELECT COALESCE(SUM(
          CASE
            WHEN a.jenis = 'isi' THEN a.jumlah_rupiah
            WHEN a.jenis = 'ambil' THEN -a.jumlah_rupiah
            ELSE 0
          END
        ), 0) FROM tabel_alokasi_kantong a JOIN tabel_kantong k ON a.kantong_id = k.id JOIN tabel_tujuan t ON k.tujuan_id = t.id WHERE t.status = 'aktif' AND t.jenis = 'dana_darurat' AND k.diarsipkan = 0) as saldo_darurat,
        (SELECT COALESCE(SUM(
          u.sisa_awal_rupiah - 
          COALESCE((
            SELECT SUM(t.jumlah_rupiah)
            FROM tabel_pembayaran_utang pu
            JOIN tabel_transaksi t ON pu.transaksi_id = t.id
            WHERE pu.utang_id = u.id
          ), 0) +
          COALESCE((
            SELECT SUM(CASE WHEN py.arah = 'tambah' THEN py.jumlah_rupiah ELSE -py.jumlah_rupiah END)
            FROM tabel_penyesuaian_utang py
            WHERE py.utang_id = u.id
          ), 0)
        ), 0) FROM tabel_utang u WHERE u.status = 'aktif') as sisa_utang,
        (SELECT COUNT(*) FROM tabel_tujuan WHERE jenis = 'tabungan' AND status IN ('aktif', 'tercapai')) as jml_tujuan_tabungan,
        (SELECT COUNT(*) FROM tabel_alokasi_kantong a JOIN tabel_kantong k ON a.kantong_id = k.id JOIN tabel_tujuan t ON k.tujuan_id = t.id WHERE a.jenis = 'isi' AND t.jenis = 'tabungan') as jml_isi_tujuan_tabungan,
        (SELECT COUNT(*) FROM tabel_transaksi t JOIN tabel_kategori k ON t.kategori_id = k.id WHERE t.jenis = 'keluar' AND k.sifat = 'kebutuhan') as jml_pengeluaran_kebutuhan,
        (SELECT COUNT(*) FROM tabel_tujuan WHERE jenis = 'dana_darurat' AND status IN ('aktif', 'tercapai')) as jml_tujuan_dana_darurat,
        (SELECT COUNT(*) FROM tabel_alokasi_kantong a JOIN tabel_kantong k ON a.kantong_id = k.id JOIN tabel_tujuan t ON k.tujuan_id = t.id WHERE a.jenis = 'isi' AND t.jenis = 'dana_darurat') as jml_isi_dana_darurat,
        (SELECT COUNT(DISTINCT kategori_id) FROM tabel_transaksi WHERE jenis = 'masuk') as jml_sumber_pemasukan
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
    final jmlProfil = barisRingkasan.read<int>('jml_profil');
    final jmlTujuanDarurat = barisRingkasan.read<int>('jml_tujuan_darurat');
    final saldoDarurat = barisRingkasan.read<int>('saldo_darurat');
    final sisaUtang = barisRingkasan.read<int>('sisa_utang');
    final jmlTujuanTabungan = barisRingkasan.read<int>('jml_tujuan_tabungan');
    final jmlIsiTujuanTabungan = barisRingkasan.read<int>('jml_isi_tujuan_tabungan');
    final jmlPengeluaranKebutuhan = barisRingkasan.read<int>('jml_pengeluaran_kebutuhan');
    final jmlTujuanDanaDarurat = barisRingkasan.read<int>('jml_tujuan_dana_darurat');
    final jmlIsiDanaDarurat = barisRingkasan.read<int>('jml_isi_dana_darurat');
    final jmlSumberPemasukan = barisRingkasan.read<int>('jml_sumber_pemasukan');

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

    // 6. Komposisi sifat pengeluaran bulan berjalan
    final barisSifat = await _db.customSelect(
      '''
      SELECT k.sifat, COALESCE(SUM(t.jumlah_rupiah), 0) as total
      FROM tabel_transaksi t
      JOIN tabel_kategori k ON t.kategori_id = k.id
      WHERE t.jenis = 'keluar' 
        AND strftime('%Y-%m', datetime(t.waktu_transaksi + $offsetDetik, 'unixepoch')) = strftime('%Y-%m', datetime('now', '+$offsetDetik seconds'))
      GROUP BY k.sifat
      ''',
    ).get();

    final mapKomposisiSifat = <String, int>{};
    for (final b in barisSifat) {
      final sifat = b.read<String>('sifat');
      final total = b.read<int>('total');
      mapKomposisiSifat[sifat] = total;
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
      profilTerisi: jmlProfil > 0,
      tujuanDanaDaruratAktif: jmlTujuanDarurat > 0,
      saldoTerkumpulDanaDarurat: saldoDarurat,
      sisaUtangAktif: sisaUtang,
      komposisiSifatBulanIni: mapKomposisiSifat,
      jumlahTujuanTabungan: jmlTujuanTabungan,
      jumlahIsiTujuanTabungan: jmlIsiTujuanTabungan,
      jumlahPengeluaranKebutuhan: jmlPengeluaranKebutuhan,
      jumlahTujuanDanaDarurat: jmlTujuanDanaDarurat,
      jumlahIsiDanaDarurat: jmlIsiDanaDarurat,
      jumlahSumberPemasukan: jmlSumberPemasukan,
    );
  }
}
