import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/basis_data.dart';
import '../../../data/penyedia_basis_data.dart';
import '../../../perhitungan/perhitungan_anggaran_tujuan.dart';
import '../../../perhitungan/perhitungan_laporan_bulanan.dart';
import '../../belajar/model/pembaca_konten.dart';

/// Notifier untuk mengelola bulan laporan yang dipilih (default: awal bulan berjalan).
class BulanLaporanNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  void pilihBulan(DateTime bulan) {
    state = DateTime(bulan.year, bulan.month, 1);
  }
}

final penyediaBulanDipilih = NotifierProvider<BulanLaporanNotifier, DateTime>(
  BulanLaporanNotifier.new,
);

/// Notifier untuk saklar sembunyikan nominal (sensor). Pilihan disimpan di tabel_pengaturan.
class SensorNominalNotifier extends Notifier<bool> {
  @override
  bool build() {
    // Inisialisasi awal default false, lalu muat dari database
    _muatPengaturan();
    return false;
  }

  Future<void> _muatPengaturan() async {
    final db = ref.read(penyediaBasisData);
    final row = await (db.select(db.tabelPengaturan)
          ..where((t) => t.kunci.equals('sensor_nominal')))
        .getSingleOrNull();
    if (row != null) {
      state = row.nilai == 'true';
    }
  }

  Future<void> setelSensor(bool aktif) async {
    state = aktif;
    final db = ref.read(penyediaBasisData);
    await db.into(db.tabelPengaturan).insertOnConflictUpdate(
          TabelPengaturanCompanion.insert(
            kunci: 'sensor_nominal',
            nilai: aktif ? 'true' : 'false',
            diubahPada: Value(DateTime.now()),
          ),
        );
  }
}

final penyediaSensorNominal = NotifierProvider<SensorNominalNotifier, bool>(
  SensorNominalNotifier.new,
);

/// Provider konten template teks laporan dari aset/konten/laporan.json.
final penyediaKontenLaporan = FutureProvider<KontenLaporan>((ref) async {
  return PembacaKonten.muatLaporanDariAset(rootBundle);
});

/// Provider daftar bulan kalender yang tersedia (dari transaksi pertama sampai bulan berjalan).
final penyediaDaftarBulanTersedia = FutureProvider<List<DateTime>>((ref) async {
  final db = ref.watch(penyediaBasisData);
  final row = await (db.select(db.tabelTransaksi)
        ..orderBy([(t) => OrderingTerm(expression: t.waktuTransaksi, mode: OrderingMode.asc)])
        ..limit(1))
      .getSingleOrNull();

  final sekarang = DateTime.now();
  final bulanSekarang = DateTime(sekarang.year, sekarang.month, 1);

  if (row == null) {
    return [bulanSekarang];
  }

  final awal = DateTime(row.waktuTransaksi.year, row.waktuTransaksi.month, 1);
  final daftarBulan = <DateTime>[];

  var kursor = bulanSekarang;
  while (!kursor.isBefore(awal)) {
    daftarBulan.add(kursor);
    kursor = DateTime(kursor.year, kursor.month - 1, 1);
  }

  return daftarBulan;
});

/// Provider data laporan bulanan murni untuk bulan yang sedang dipilih.
final penyediaDataLaporanBulanan = FutureProvider<LaporanBulanan>((ref) async {
  final bulanDipilih = ref.watch(penyediaBulanDipilih);
  final konten = await ref.watch(penyediaKontenLaporan.future);

  final db = ref.watch(penyediaBasisData);
  final repoTransaksi = ref.watch(penyediaTransaksiRepositori);
  final repoAnggaran = ref.watch(penyediaAnggaranRepositori);

  final awalBulan = DateTime(bulanDipilih.year, bulanDipilih.month, 1);
  final akhirBulan = DateTime(bulanDipilih.year, bulanDipilih.month + 1, 0, 23, 59, 59, 999);

  // 1. Arus kas bulan terpilih
  final arusKas = await repoTransaksi.hitungArusKasSQL(mulai: awalBulan, selesai: akhirBulan);

  // 2. Komposisi pengeluaran per sifat dan kategori belum dilabeli via agregasi SQL
  const sqlKomposisi = '''
    SELECT 
      COALESCE(k.sifat, 'belum_dilabeli') AS sifat,
      COALESCE(k.nama, 'Tanpa Kategori') AS nama_kategori,
      COALESCE(SUM(t.jumlah_rupiah), 0) AS total
    FROM tabel_transaksi t
    LEFT JOIN tabel_kategori k ON t.kategori_id = k.id
    WHERE t.waktu_transaksi >= ? AND t.waktu_transaksi <= ? AND t.jenis = 'keluar'
    GROUP BY COALESCE(k.sifat, 'belum_dilabeli'), COALESCE(k.nama, 'Tanpa Kategori');
  ''';
  final rowsKomposisi = await db.customSelect(
    sqlKomposisi,
    variables: [
      Variable.withDateTime(awalBulan),
      Variable.withDateTime(akhirBulan),
    ],
  ).get();

  final perSifat = <String, int>{
    'kebutuhan': 0,
    'keinginan': 0,
    'tabungan': 0,
    'utang': 0,
    'belum_dilabeli': 0,
  };

  final pengeluaranPerKategoriBelumDilabeli = <String, int>{};

  for (final r in rowsKomposisi) {
    final sifat = r.read<String>('sifat');
    final total = r.read<int>('total');
    final sifatNormal = perSifat.containsKey(sifat) ? sifat : 'belum_dilabeli';
    perSifat[sifatNormal] = (perSifat[sifatNormal] ?? 0) + total;

    if (sifatNormal == 'belum_dilabeli') {
      final namaKat = r.read<String>('nama_kategori');
      pengeluaranPerKategoriBelumDilabeli[namaKat] =
          (pengeluaranPerKategoriBelumDilabeli[namaKat] ?? 0) + total;
    }
  }

  // 3. Realisasi Anggaran
  final daftarItemAnggaran = await repoAnggaran.ambilRealisasiAnggaranBulan(
    tahun: bulanDipilih.year,
    bulan: bulanDipilih.month,
  );
  final daftarPosAnggaran = daftarItemAnggaran.map(PosAnggaranLaporan.dariItem).toList();

  // 4. Tujuan Aktif (maksimal 3)
  final daftarTujuanAktif = await (db.select(db.tabelTujuan)
        ..where((t) => t.status.isNotValue('diarsipkan'))
        ..limit(3))
      .get();
  final daftarTujuanLaporan = <TujuanLaporan>[];
  for (final t in daftarTujuanAktif) {
    final rowAlokasi = await db.customSelect(
      'SELECT COALESCE(SUM(jumlah_rupiah), 0) as total FROM tabel_alokasi_dana WHERE tujuan_id = ?;',
      variables: [Variable.withString(t.id)],
    ).getSingle();
    final dana = rowAlokasi.read<int>('total');
    final persen = hitungProgresTujuan(danaRupiah: dana, targetRupiah: t.targetRupiah);
    daftarTujuanLaporan.add(
      TujuanLaporan(
        id: t.id,
        nama: t.nama,
        danaTerkumpulRupiah: dana,
        targetRupiah: t.targetRupiah,
        persenProgres: persen,
      ),
    );
  }

  // 5. Snapshot Saldo Dompet & Utang per saat ini via agregasi SQL (bebas N+1)
  final dompetAktif = await (db.select(db.tabelDompet)..where((t) => t.diarsipkan.equals(false))).get();
  var totalSaldoDompet = 0;
  for (final d in dompetAktif) {
    totalSaldoDompet += await repoTransaksi.hitungSaldoDompetSQL(
      dompetId: d.id,
      saldoAwalRupiah: d.saldoAwalRupiah,
    );
  }

  const sqlUtang = '''
    SELECT 
      COALESCE(SUM(
        u.sisa_awal_rupiah
        - COALESCE((
            SELECT SUM(t.jumlah_rupiah)
            FROM tabel_pembayaran_utang pu
            JOIN tabel_transaksi t ON pu.transaksi_id = t.id
            WHERE pu.utang_id = u.id
          ), 0)
        + COALESCE((
            SELECT SUM(CASE WHEN arah = 'tambah' THEN jumlah_rupiah ELSE -jumlah_rupiah END)
            FROM tabel_penyesuaian_utang
            WHERE utang_id = u.id
          ), 0)
      ), 0) AS total_sisa
    FROM tabel_utang u
    WHERE u.status = 'aktif';
  ''';
  final rowUtang = await db.customSelect(sqlUtang).getSingle();
  final totalSisaUtang = rowUtang.read<int>('total_sisa');

  final listBelumDilabeli = pengeluaranPerKategoriBelumDilabeli.entries
      .map((e) => (nama: e.key, pengeluaranRupiah: e.value))
      .toList();

  final masukan = MasukanLaporanBulanan(
    bulan: bulanDipilih,
    waktuDibuat: DateTime.now(),
    uangMasukRupiah: arusKas.totalMasuk,
    uangKeluarRupiah: arusKas.totalKeluar,
    pengeluaranPerSifat: perSifat,
    daftarPosAnggaran: daftarPosAnggaran,
    daftarTujuanAktif: daftarTujuanLaporan,
    saldoDompetAktifRupiah: totalSaldoDompet,
    sisaUtangAktifRupiah: totalSisaUtang,
    kategoriBelumDilabeliTerpakai: listBelumDilabeli,
  );

  return susunLaporanBulanan(masukan, konten: konten);
});
