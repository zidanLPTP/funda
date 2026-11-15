import 'dart:convert';
import 'dart:math' as math;
import '../util/format_rupiah.dart';

/// Pilihan frekuensi pengulangan jatuh tempo.
enum FrekuensiKalkulasi { mingguan, bulanan, tahunan }

/// Status kemunculan jadwal tagihan berdasarkan tanggal dan penandaan.
enum StatusKemunculan {
  hariIni('Hari ini'),
  akanDatang('Akan datang'),
  lewat('Lewat jatuh tempo'),
  lewatKedaluwarsa('Lewat lebih dari 60 hari'),
  dibayar('Sudah dibayar'),
  dilewati('Dilewati');

  const StatusKemunculan(this.label);
  final String label;
}

/// Aturan penentuan tanggal jatuh tempo tagihan atau langganan.
class AturanJatuhTempo {
  const AturanJatuhTempo({
    required this.frekuensi,
    required this.jatuhTempoPertama,
    this.berakhirPada,
  });

  final FrekuensiKalkulasi frekuensi;
  final DateTime jatuhTempoPertama;
  final DateTime? berakhirPada;
}

/// Hasil evaluasi status kemunculan jatuh tempo beserta selisih hari.
class HasilStatusJatuhTempo {
  const HasilStatusJatuhTempo({
    required this.status,
    required this.selisihHari,
  });

  final StatusKemunculan status;
  final int selisihHari;
}

/// Representasi satu item dalam jadwal kemunculan tagihan / cicilan utang.
class ItemKalkulasiJadwal {
  const ItemKalkulasiJadwal({
    required this.idTagihan,
    required this.nama,
    this.tanggal,
    this.jumlahPerkiraanRupiah,
    this.status = StatusKemunculan.akanDatang,
    this.jumlahAktualBayarRupiah,
    this.hariSebelumPengingat = const [],
    this.isCicilanUtang = false,
    this.idUtang,
  });

  final String idTagihan;
  final String nama;
  final DateTime? tanggal;
  final int? jumlahPerkiraanRupiah;
  final StatusKemunculan status;
  final int? jumlahAktualBayarRupiah;
  final List<int> hariSebelumPengingat;
  final bool isCicilanUtang;
  final String? idUtang;
}

/// Ringkasan keuangan tagihan untuk periode satu bulan kalender.
class RingkasanBulanTagihan {
  const RingkasanBulanTagihan({
    required this.totalPerkiraanRupiah,
    required this.sudahDibayarRupiah,
    required this.sisaPerkiraanRupiah,
    required this.jumlahBelumDitandai,
    required this.jumlahTanpaNominal,
  });

  final int totalPerkiraanRupiah;
  final int sudahDibayarRupiah;
  final int sisaPerkiraanRupiah;
  final int jumlahBelumDitandai;
  final int jumlahTanpaNominal;
}

/// Konfigurasi preferensi pengingat lokal pengguna.
class PengaturanPengingatTagihan {
  const PengaturanPengingatTagihan({
    required this.aktif,
    required this.jam,
    required this.menit,
    required this.tampilkanNominal,
  });

  final bool aktif;
  final int jam;
  final int menit;
  final bool tampilkanNominal;
}

/// Struktur rencana jadwal pengingat lokal yang akan didaftarkan ke sistem notifikasi.
class RencanaPengingat {
  const RencanaPengingat({
    required this.idStabil,
    required this.waktuTayang,
    required this.judul,
    required this.isi,
    required this.tujuanPayload,
  });

  final int idStabil;
  final DateTime waktuTayang;
  final String judul;
  final String isi;
  final String tujuanPayload;
}

/// Serialisasi daftar hari pengingat {0, 1, 3, 7} ke format string JSON.
String serialisasiHariPengingat(List<int> daftar) {
  final terurut = List<int>.from(daftar)..sort();
  return jsonEncode(terurut);
}

/// Deserialisasi string JSON daftar hari pengingat kembali ke daftar bilangan bulat hari.
List<int> uraiHariPengingat(String? jsonStr) {
  if (jsonStr == null || jsonStr.trim().isEmpty) return const [];
  try {
    final list = jsonDecode(jsonStr);
    if (list is List) {
      return list.map((e) => int.parse(e.toString())).toList()..sort();
    }
  } catch (_) {}
  return const [];
}

/// Menghitung seluruh tanggal jatuh tempo dalam rentang waktu kalender lokal.
List<DateTime> hitungJatuhTempoDalamRentang({
  required AturanJatuhTempo aturan,
  required DateTime mulai,
  required DateTime selesai,
}) {
  final hasil = <DateTime>[];

  // Normalisasi tanggal murni (tanpa jam/menit/detik)
  final tMulai = DateTime(mulai.year, mulai.month, mulai.day);
  final tSelesai = DateTime(selesai.year, selesai.month, selesai.day);
  final tPertama = DateTime(
    aturan.jatuhTempoPertama.year,
    aturan.jatuhTempoPertama.month,
    aturan.jatuhTempoPertama.day,
  );
  final tAkhir = aturan.berakhirPada != null
      ? DateTime(
          aturan.berakhirPada!.year,
          aturan.berakhirPada!.month,
          aturan.berakhirPada!.day,
        )
      : null;

  switch (aturan.frekuensi) {
    case FrekuensiKalkulasi.mingguan:
      // Mulai dari tPertama, lompat per 7 hari
      var kursor = tPertama;
      // Jika kursor jauh sebelum tMulai, lompat langsung mendekati tMulai
      if (kursor.isBefore(tMulai)) {
        final selisihHari = tMulai.difference(kursor).inDays;
        final lompatanPekan = selisihHari ~/ 7;
        kursor = kursor.add(Duration(days: lompatanPekan * 7));
        while (kursor.isBefore(tMulai)) {
          kursor = kursor.add(const Duration(days: 7));
        }
      }

      while (!kursor.isAfter(tSelesai)) {
        if (tAkhir != null && kursor.isAfter(tAkhir)) break;
        if (!kursor.isBefore(tMulai)) {
          hasil.add(kursor);
        }
        kursor = kursor.add(const Duration(days: 7));
      }
      break;

    case FrekuensiKalkulasi.bulanan:
      final targetHari = tPertama.day;
      var tahun = tPertama.year;
      var bulan = tPertama.month;

      // Cari bulan awal yang relevan
      if (tahun < tMulai.year ||
          (tahun == tMulai.year && bulan < tMulai.month)) {
        tahun = tMulai.year;
        bulan = tMulai.month;
      }

      while (true) {
        final hariMaksimalBulan = DateTime(tahun, bulan + 1, 0).day;
        final hariAktif = math.min(targetHari, hariMaksimalBulan);
        final tanggalJatuh = DateTime(tahun, bulan, hariAktif);

        if (tanggalJatuh.isAfter(tSelesai)) break;
        if (tAkhir != null && tanggalJatuh.isAfter(tAkhir)) break;

        if (!tanggalJatuh.isBefore(tPertama) &&
            !tanggalJatuh.isBefore(tMulai)) {
          hasil.add(tanggalJatuh);
        }

        bulan++;
        if (bulan > 12) {
          bulan = 1;
          tahun++;
        }
      }
      break;

    case FrekuensiKalkulasi.tahunan:
      final targetBulan = tPertama.month;
      final targetHari = tPertama.day;
      var tahun = tPertama.year;

      if (tahun < tMulai.year) {
        tahun = tMulai.year;
      }

      while (true) {
        final hariMaksimalBulan = DateTime(tahun, targetBulan + 1, 0).day;
        final hariAktif = math.min(targetHari, hariMaksimalBulan);
        final tanggalJatuh = DateTime(tahun, targetBulan, hariAktif);

        if (tanggalJatuh.isAfter(tSelesai)) break;
        if (tAkhir != null && tanggalJatuh.isAfter(tAkhir)) break;

        if (!tanggalJatuh.isBefore(tPertama) &&
            !tanggalJatuh.isBefore(tMulai)) {
          hasil.add(tanggalJatuh);
        }

        tahun++;
      }
      break;
  }

  return hasil;
}

/// Menentukan status kemunculan tagihan berdasarkan perbandingan tanggal dan catatan pembayaran.
HasilStatusJatuhTempo tentukanStatusJatuhTempo({
  required DateTime tanggalJatuhTempo,
  required DateTime hariIni,
  String? statusTersimpan,
}) {
  if (statusTersimpan == 'dibayar') {
    return const HasilStatusJatuhTempo(
      status: StatusKemunculan.dibayar,
      selisihHari: 0,
    );
  }
  if (statusTersimpan == 'dilewati') {
    return const HasilStatusJatuhTempo(
      status: StatusKemunculan.dilewati,
      selisihHari: 0,
    );
  }

  final tJatuh = DateTime(
    tanggalJatuhTempo.year,
    tanggalJatuhTempo.month,
    tanggalJatuhTempo.day,
  );
  final tHariIni = DateTime(hariIni.year, hariIni.month, hariIni.day);
  final selisihHari = tJatuh.difference(tHariIni).inDays;

  if (selisihHari == 0) {
    return const HasilStatusJatuhTempo(
      status: StatusKemunculan.hariIni,
      selisihHari: 0,
    );
  } else if (selisihHari > 0) {
    return HasilStatusJatuhTempo(
      status: StatusKemunculan.akanDatang,
      selisihHari: selisihHari,
    );
  } else {
    // Lewat
    if (selisihHari < -60) {
      return HasilStatusJatuhTempo(
        status: StatusKemunculan.lewatKedaluwarsa,
        selisihHari: selisihHari,
      );
    }
    return HasilStatusJatuhTempo(
      status: StatusKemunculan.lewat,
      selisihHari: selisihHari,
    );
  }
}

/// Menghitung ringkasan tagihan untuk satu bulan kalender.
RingkasanBulanTagihan hitungRingkasanBulanTagihan(
  List<ItemKalkulasiJadwal> daftarItem,
) {
  var totalPerkiraan = 0;
  var sudahDibayar = 0;
  var sisaPerkiraan = 0;
  var jumlahBelumDitandai = 0;
  var jumlahTanpaNominal = 0;

  for (final item in daftarItem) {
    if (item.jumlahPerkiraanRupiah != null) {
      totalPerkiraan += item.jumlahPerkiraanRupiah!;
    } else {
      jumlahTanpaNominal++;
    }

    if (item.status == StatusKemunculan.dibayar) {
      sudahDibayar +=
          item.jumlahAktualBayarRupiah ?? (item.jumlahPerkiraanRupiah ?? 0);
    } else if (item.status != StatusKemunculan.dilewati) {
      jumlahBelumDitandai++;
      if (item.jumlahPerkiraanRupiah != null) {
        sisaPerkiraan += item.jumlahPerkiraanRupiah!;
      }
    }
  }

  return RingkasanBulanTagihan(
    totalPerkiraanRupiah: totalPerkiraan,
    sudahDibayarRupiah: sudahDibayar,
    sisaPerkiraanRupiah: sisaPerkiraan,
    jumlahBelumDitandai: jumlahBelumDitandai,
    jumlahTanpaNominal: jumlahTanpaNominal,
  );
}

/// Menghasilkan rencana pengingat lokal yang stabil dan unik untuk didaftarkan ke sistem notifikasi.
List<RencanaPengingat> rencanakanPengingat({
  required List<ItemKalkulasiJadwal> daftarJadwal,
  required PengaturanPengingatTagihan pengaturan,
  required DateTime sekarang,
  int batasMaksimal = 50,
}) {
  if (!pengaturan.aktif) return const [];

  final hasil = <RencanaPengingat>[];
  final batasJendela = sekarang.add(const Duration(days: 45));

  for (final item in daftarJadwal) {
    // Lewati item yang sudah ditandai selesai/dilewati atau kedaluwarsa
    if (item.status == StatusKemunculan.dibayar ||
        item.status == StatusKemunculan.dilewati ||
        item.status == StatusKemunculan.lewatKedaluwarsa ||
        item.tanggal == null) {
      continue;
    }

    final jatuhTempo = item.tanggal!;

    for (final hariSebelum in item.hariSebelumPengingat) {
      final waktuTayang = DateTime(
        jatuhTempo.year,
        jatuhTempo.month,
        jatuhTempo.day - hariSebelum,
        pengaturan.jam,
        pengaturan.menit,
      );

      // Abaikan pengingat yang waktunya sudah lampau atau di luar batas 45 hari
      if (waktuTayang.isBefore(sekarang) || waktuTayang.isAfter(batasJendela)) {
        continue;
      }

      // ID deterministik stabil integer 32-bit:
      // Kombinasi hash idTagihan + tanggalJatuhTempo + hariSebelum
      final kunci =
          '${item.idTagihan}_${jatuhTempo.year}${jatuhTempo.month.toString().padLeft(2, '0')}${jatuhTempo.day.toString().padLeft(2, '0')}_$hariSebelum';
      final idStabil = (kunci.hashCode & 0x7FFFFFFF);

      // Judul ramah
      String judul;
      if (hariSebelum == 0) {
        judul = '${item.nama} jatuh tempo hari ini';
      } else if (hariSebelum == 1) {
        judul = '${item.nama} jatuh tempo besok';
      } else {
        judul = '${item.nama} jatuh tempo dalam $hariSebelum hari';
      }

      // Isi notifikasi
      String isi;
      if (pengaturan.tampilkanNominal && item.jumlahPerkiraanRupiah != null) {
        isi =
            'Nominal perkiraan: ${formatRupiah(item.jumlahPerkiraanRupiah!)}. Buka Funda untuk menandai kalau sudah dibayar.';
      } else {
        isi = 'Buka Funda untuk menandai kalau sudah dibayar.';
      }

      hasil.add(
        RencanaPengingat(
          idStabil: idStabil,
          waktuTayang: waktuTayang,
          judul: judul,
          isi: isi,
          tujuanPayload: '/tagihan',
        ),
      );
    }
  }

  // Urutkan menurut waktu tayang terdekat
  hasil.sort((a, b) => a.waktuTayang.compareTo(b.waktuTayang));

  if (hasil.length > batasMaksimal) {
    return hasil.sublist(0, batasMaksimal);
  }
  return hasil;
}
