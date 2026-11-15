import '../data/basis_data.dart';
import '../data/model/jenis_transaksi.dart';

/// Hasil perhitungan penyesuaian saldo.
class HasilPenyesuaianSaldo {
  const HasilPenyesuaianSaldo({
    required this.perluPenyesuaian,
    this.jenis,
    required this.jumlahRupiah,
  });

  final bool perluPenyesuaian;
  final JenisTransaksi? jenis;
  final int jumlahRupiah;
}

/// Hasil perhitungan arus kas dalam suatu periode waktu.
class HasilArusKas {
  const HasilArusKas({
    required this.totalMasuk,
    required this.totalKeluar,
    required this.selisih,
  });

  final int totalMasuk;
  final int totalKeluar;
  final int selisih;
}

/// Hasil validasi transaksi sebelum disimpan.
class HasilValidasiTransaksi {
  const HasilValidasiTransaksi({required this.isValid, this.pesanGalat});

  final bool isValid;
  final String? pesanGalat;
}

/// Batas nominal tertinggi yang dapat dicatat di Funda (999 miliar rupiah).
const int batasMaksimalNominalRupiah = 999999999999;

/// Menghitung saldo berjalan satu dompet secara murni dari baris transaksi.
/// Saldo tidak disimpan di tabel dompet agar integritas riwayat selalu terjaga.
/// Saldo boleh bernilai negatif jika pengeluaran melebihi saldo yang ada.
int hitungSaldoDompet({
  required String dompetId,
  required int saldoAwalRupiah,
  required List<EntitasTransaksi> daftarTransaksi,
}) {
  var saldo = saldoAwalRupiah;

  for (final t in daftarTransaksi) {
    if (t.dompetId == dompetId) {
      switch (t.jenis) {
        case 'masuk':
          saldo += t.jumlahRupiah;
          break;
        case 'keluar':
          saldo -= t.jumlahRupiah;
          break;
        case 'penyesuaian_masuk':
          saldo += t.jumlahRupiah;
          break;
        case 'penyesuaian_keluar':
          saldo -= t.jumlahRupiah;
          break;
        case 'transfer':
          saldo -= (t.jumlahRupiah + t.biayaAdminRupiah);
          break;
      }
    } else if (t.dompetTujuanId == dompetId) {
      if (t.jenis == 'transfer') {
        saldo += t.jumlahRupiah;
      }
    }
  }

  return saldo;
}

/// Menghitung jenis dan nominal transaksi penyesuaian yang perlu dibuat.
HasilPenyesuaianSaldo hitungPenyesuaianSaldo({
  required int saldoSekarang,
  required int saldoSebenarnya,
}) {
  final selisih = saldoSebenarnya - saldoSekarang;

  if (selisih == 0) {
    return const HasilPenyesuaianSaldo(
      perluPenyesuaian: false,
      jenis: null,
      jumlahRupiah: 0,
    );
  }

  if (selisih > 0) {
    return HasilPenyesuaianSaldo(
      perluPenyesuaian: true,
      jenis: JenisTransaksi.penyesuaianMasuk,
      jumlahRupiah: selisih,
    );
  }

  return HasilPenyesuaianSaldo(
    perluPenyesuaian: true,
    jenis: JenisTransaksi.penyesuaianKeluar,
    jumlahRupiah: selisih.abs(),
  );
}

/// Menghitung total pemasukan, total pengeluaran, dan selisih arus kas.
/// Transfer dan penyesuaian saldo TIDAK dihitung sebagai pemasukan/pengeluaran biasa.
/// Biaya administrasi transfer dihitung sebagai pengeluaran.
HasilArusKas hitungArusKas({
  required List<EntitasTransaksi> daftarTransaksi,
  DateTime? mulai,
  DateTime? selesai,
}) {
  var totalMasuk = 0;
  var totalKeluar = 0;

  for (final t in daftarTransaksi) {
    final waktu = t.waktuTransaksi;

    if (mulai != null && waktu.isBefore(mulai)) {
      continue;
    }
    if (selesai != null && waktu.isAfter(selesai)) {
      continue;
    }

    if (t.jenis == 'masuk') {
      totalMasuk += t.jumlahRupiah;
    } else if (t.jenis == 'keluar') {
      totalKeluar += t.jumlahRupiah;
    } else if (t.jenis == 'transfer') {
      // Biaya admin transfer dihitung sebagai pengeluaran pengguna
      totalKeluar += t.biayaAdminRupiah;
    }
  }

  return HasilArusKas(
    totalMasuk: totalMasuk,
    totalKeluar: totalKeluar,
    selisih: totalMasuk - totalKeluar,
  );
}

/// Menghitung total saldo seluruh dompet aktif (dompet yang diarsipkan diabaikan).
int hitungTotalSaldo({
  required List<EntitasDompet> daftarDompet,
  required int Function(String idDompet) ambilSaldoDompet,
}) {
  var total = 0;
  for (final dompet in daftarDompet) {
    if (!dompet.diarsipkan) {
      total += ambilSaldoDompet(dompet.id);
    }
  }
  return total;
}

/// Melakukan validasi transaksi sebelum disimpan ke basis data.
HasilValidasiTransaksi validasiTransaksi({
  required JenisTransaksi jenis,
  required int jumlahRupiah,
  required String dompetId,
  String? dompetTujuanId,
  String? kategoriId,
  int biayaAdminRupiah = 0,
}) {
  if (jumlahRupiah <= 0) {
    return const HasilValidasiTransaksi(
      isValid: false,
      pesanGalat: 'Jumlah transaksi harus lebih besar dari Rp 0.',
    );
  }

  if (jumlahRupiah > batasMaksimalNominalRupiah) {
    return const HasilValidasiTransaksi(
      isValid: false,
      pesanGalat: 'Maksimal nominal transaksi adalah Rp 999.999.999.999.',
    );
  }

  if (jenis == JenisTransaksi.transfer) {
    if (dompetTujuanId == null || dompetTujuanId.isEmpty) {
      return const HasilValidasiTransaksi(
        isValid: false,
        pesanGalat: 'Pilih dompet tujuan transfer terlebih dahulu.',
      );
    }
    if (dompetId == dompetTujuanId) {
      return const HasilValidasiTransaksi(
        isValid: false,
        pesanGalat: 'Dompet asal dan dompet tujuan transfer harus berbeda.',
      );
    }
    if (biayaAdminRupiah < 0) {
      return const HasilValidasiTransaksi(
        isValid: false,
        pesanGalat: 'Biaya admin transfer tidak boleh negatif.',
      );
    }
  }

  if (jenis == JenisTransaksi.masuk || jenis == JenisTransaksi.keluar) {
    if (kategoriId == null || kategoriId.trim().isEmpty) {
      return const HasilValidasiTransaksi(
        isValid: false,
        pesanGalat: 'Kategori transaksi wajib dipilih.',
      );
    }
  }

  return const HasilValidasiTransaksi(isValid: true);
}

/// Mengambil tanggal lokal perangkat (tanpa jam/menit/detik) dari [DateTime] UTC.
DateTime ambilTanggalLokalPerangkat(DateTime waktu) {
  final lokal = waktu.toLocal();
  return DateTime(lokal.year, lokal.month, lokal.day);
}
