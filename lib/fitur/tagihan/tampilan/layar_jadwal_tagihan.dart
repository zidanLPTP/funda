import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../data/basis_data.dart';
import '../../../data/penyedia_data.dart';
import '../../../data/repositori/tagihan_repositori.dart';
import '../../../komponen/komponen_funda.dart';
import '../../../komponen/pembantu_ikon.dart';
import '../../../perhitungan/perhitungan_tagihan.dart';
import '../../../tema/token.dart';
import '../../../util/format_rupiah.dart';
import '../../transaksi/tampilan/layar_form_transaksi.dart';
import '../kontroler/penyedia_tagihan.dart';

/// Layar utama Jadwal Tagihan & Langganan Berulang dengan navigasi per bulan.
class LayarJadwalTagihan extends ConsumerStatefulWidget {
  const LayarJadwalTagihan({super.key});

  @override
  ConsumerState<LayarJadwalTagihan> createState() => _LayarJadwalTagihanState();
}

class _LayarJadwalTagihanState extends ConsumerState<LayarJadwalTagihan> {
  Future<void> _lewatiPeriode(ItemJadwalTampilan item) async {
    final messenger = ScaffoldMessenger.of(context);
    final setuju = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const TeksFunda.judulBagian('Lewati Periode Ini?'),
        content: TeksFunda.isi(
          'Tandai periode tagihan "${item.nama}" tanggal ${DateFormat('d MMMM yyyy', 'id_ID').format(item.tanggalJatuhTempo)} sebagai dilewati tanpa mencatat pengeluaran?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: WarnaFunda.utama),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Lewati'),
          ),
        ],
      ),
    );

    if (setuju == true) {
      await ref
          .read(penyediaTagihanRepositori)
          .tandaiTagihanDilewati(
            tagihanId: item.idTagihan,
            jatuhTempo: item.tanggalJatuhTempo,
          );
      await sinkronkanPengingatLokal(ref);
      ref.invalidate(penyediaJadwalBulanTerpilih);

      messenger.showSnackBar(
        SnackBar(content: Text('Tagihan "${item.nama}" ditandai dilewati.')),
      );
    }
  }

  Future<void> _batalkanPenandaan(ItemJadwalTampilan item) async {
    final messenger = ScaffoldMessenger.of(context);
    final setuju = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const TeksFunda.judulBagian('Batalkan Penandaan?'),
        content: TeksFunda.isi(
          'Batalkan status selesai/lewati untuk "${item.nama}"? Catatan transaksi yang tertaut (jika ada) akan tetap ada di riwayat.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Kembali'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: WarnaFunda.pengeluaran,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Batalkan'),
          ),
        ],
      ),
    );

    if (setuju == true) {
      await ref
          .read(penyediaTagihanRepositori)
          .batalkanPenandaanPeriode(
            tagihanId: item.idTagihan,
            jatuhTempo: item.tanggalJatuhTempo,
          );
      await sinkronkanPengingatLokal(ref);
      ref.invalidate(penyediaJadwalBulanTerpilih);

      messenger.showSnackBar(
        SnackBar(content: Text('Status "${item.nama}" telah dikembalikan.')),
      );
    }
  }

  void _bukaFormPembayaran(ItemJadwalTampilan item) {
    if (item.isCicilanUtang && item.idUtang != null) {
      context.push('/utang/detail/${item.idUtang}').then((_) {
        ref.invalidate(penyediaJadwalBulanTerpilih);
      });
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LayarFormTransaksi(
          idTagihan: item.idTagihan,
          tanggalJatuhTempoTagihan: item.tanggalJatuhTempo,
          nominalAwalRupiah: item.jumlahPerkiraanRupiah,
          kategoriIdAwal: item.kategoriId,
          dompetIdAwal: item.dompetBawaanId,
          catatanAwal: 'Pembayaran ${item.nama}',
        ),
      ),
    ).then((_) {
      ref.invalidate(penyediaJadwalBulanTerpilih);
    });
  }

  Widget _bangunKartuJadwal(
    ItemJadwalTampilan item,
    List<EntitasKategori> daftarKategori,
  ) {
    final kategori = daftarKategori
        .where((k) => k.id == item.kategoriId)
        .firstOrNull;

    Color warnaStatus;
    Color latarStatus;
    String labelStatus;

    switch (item.status) {
      case StatusKemunculan.lewat:
      case StatusKemunculan.lewatKedaluwarsa:
        warnaStatus = WarnaFunda.pengeluaran;
        latarStatus = WarnaFunda.tintMawar;
        labelStatus = 'Lewat ${-item.selisihHari} hari';
        break;
      case StatusKemunculan.hariIni:
        warnaStatus = WarnaFunda.teks;
        latarStatus = WarnaFunda.tintAmber;
        labelStatus = 'Jatuh tempo hari ini';
        break;
      case StatusKemunculan.akanDatang:
        warnaStatus = WarnaFunda.utama;
        latarStatus = WarnaFunda.tintHijau;
        labelStatus = item.selisihHari == 1
            ? 'Besok'
            : '${item.selisihHari} hari lagi';
        break;
      case StatusKemunculan.dibayar:
        warnaStatus = WarnaFunda.pemasukan;
        latarStatus = WarnaFunda.tintHijau;
        labelStatus = 'Sudah dibayar';
        break;
      case StatusKemunculan.dilewati:
        warnaStatus = WarnaFunda.teksRedup;
        latarStatus = WarnaFunda.latar;
        labelStatus = 'Dilewati';
        break;
    }

    final sudahSelesai =
        item.status == StatusKemunculan.dibayar ||
        item.status == StatusKemunculan.dilewati;

    return PetakBento(
      anak: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: latarStatus,
                  borderRadius: BorderRadius.circular(SudutFunda.kartu),
                ),
                child: Icon(
                  item.isCicilanUtang
                      ? LucideIcons.creditCard
                      : (kategori != null
                            ? ambilIkonLucide(kategori.ikon)
                            : LucideIcons.receipt),
                  color: warnaStatus,
                  size: 20,
                ),
              ),
              const SizedBox(width: SpasiFunda.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: SpasiFunda.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        TeksFunda.label(item.nama),
                        if (item.isCicilanUtang)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: WarnaFunda.tintAmber,
                              borderRadius: BorderRadius.circular(
                                SudutFunda.pil,
                              ),
                            ),
                            child: const Text(
                              'Cicilan Utang',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: WarnaFunda.sifatUtang,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: SpasiFunda.xs),
                    TeksFunda.catatan(
                      DateFormat(
                        'EEEE, d MMMM yyyy',
                        'id_ID',
                      ).format(item.tanggalJatuhTempo),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: latarStatus,
                  borderRadius: BorderRadius.circular(SudutFunda.kecil),
                ),
                child: TeksFunda.catatan(labelStatus, warna: warnaStatus),
              ),
            ],
          ),
          const SizedBox(height: SpasiFunda.m),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: SpasiFunda.m,
            runSpacing: SpasiFunda.s,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TeksFunda.catatan(
                    sudahSelesai && item.jumlahAktualRupiah != null
                        ? 'Jumlah Dibayar'
                        : 'Perkiraan Nominal',
                  ),
                  const SizedBox(height: SpasiFunda.xs),
                  TeksFunda.label(
                    item.jumlahAktualRupiah != null
                        ? formatRupiah(item.jumlahAktualRupiah!)
                        : (item.jumlahPerkiraanRupiah != null &&
                                  item.jumlahPerkiraanRupiah! > 0
                              ? formatRupiah(item.jumlahPerkiraanRupiah!)
                              : 'Fluktuatif (-)'),
                  ),
                ],
              ),
              if (!sudahSelesai) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!item.isCicilanUtang) ...[
                      IconButton(
                        icon: const Icon(
                          LucideIcons.skipForward,
                          size: 20,
                          color: WarnaFunda.teksRedup,
                        ),
                        tooltip: 'Lewati periode ini',
                        onPressed: () => _lewatiPeriode(item),
                      ),
                      const SizedBox(width: SpasiFunda.xs),
                    ],
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: WarnaFunda.utama,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      icon: const Icon(LucideIcons.check, size: 16),
                      label: Text(
                        item.isCicilanUtang ? 'Bayar Cicilan' : 'Bayar',
                      ),
                      onPressed: () => _bukaFormPembayaran(item),
                    ),
                  ],
                ),
              ] else ...[
                TextButton.icon(
                  icon: const Icon(
                    LucideIcons.rotateCcw,
                    size: 16,
                    color: WarnaFunda.teksRedup,
                  ),
                  label: const Text(
                    'Batalkan',
                    style: TextStyle(color: WarnaFunda.teksRedup),
                  ),
                  onPressed: () => _batalkanPenandaan(item),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bulanTerpilih = ref.watch(penyediaBulanJadwalTerpilih);
    final jadwalBulanAsync = ref.watch(penyediaJadwalBulanTerpilih);
    final ringkasan = ref.watch(penyediaRingkasanBulanTerpilih);
    final daftarKategori = ref.watch(penyediaDaftarKategori).value ?? [];

    final namaBulanTahun = DateFormat(
      'MMMM yyyy',
      'id_ID',
    ).format(bulanTerpilih);

    return Scaffold(
      backgroundColor: WarnaFunda.latar,
      appBar: AppBar(
        title: const TeksFunda.judulBagian('Tagihan & Pengingat'),
        backgroundColor: WarnaFunda.latar,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.listFilter, color: WarnaFunda.teks),
            tooltip: 'Master Tagihan',
            onPressed: () => context.push('/tagihan/semua'),
          ),
          IconButton(
            icon: const Icon(LucideIcons.settings, color: WarnaFunda.teks),
            tooltip: 'Pengaturan Pengingat',
            onPressed: () => context.push('/pengaturan'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: WarnaFunda.utama,
        foregroundColor: WarnaFunda.permukaan,
        onPressed: () => context.push('/tagihan/tambah'),
        icon: const Icon(LucideIcons.plus),
        label: const Text('Tagihan Baru'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(SpasiFunda.m),
          children: [
            // Navigasi Pemilih Bulan
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(LucideIcons.chevronLeft),
                  tooltip: 'Bulan Sebelumnya',
                  onPressed: () => ref
                      .read(penyediaBulanJadwalTerpilih.notifier)
                      .gantiBulan(-1),
                ),
                TeksFunda.judulBagian(namaBulanTahun),
                IconButton(
                  icon: const Icon(LucideIcons.chevronRight),
                  tooltip: 'Bulan Berikutnya',
                  onPressed: () => ref
                      .read(penyediaBulanJadwalTerpilih.notifier)
                      .gantiBulan(1),
                ),
              ],
            ),
            const SizedBox(height: SpasiFunda.s),

            // Hero Ringkasan Bulan Terpilih
            PetakBento.ukuran2x1(
              warnaKustom: WarnaFunda.tintBiru,
              labelAkses:
                  'Sudah dibayar ${formatRupiah(ringkasan.sudahDibayarRupiah)}, perkiraan sisa ${formatRupiah(ringkasan.sisaPerkiraanRupiah)}',
              anak: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TeksFunda.label('Ringkasan $namaBulanTahun'),
                  const SizedBox(height: SpasiFunda.s),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const TeksFunda.catatan('Sudah Dibayar'),
                            const SizedBox(height: SpasiFunda.xs),
                            TeksFunda.judulBagian(
                              formatRupiah(ringkasan.sudahDibayarRupiah),
                              warna: WarnaFunda.pemasukan,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const TeksFunda.catatan('Perkiraan Sisa'),
                            const SizedBox(height: SpasiFunda.xs),
                            TeksFunda.judulBagian(
                              formatRupiah(ringkasan.sisaPerkiraanRupiah),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: SpasiFunda.s),
                  TeksFunda.catatan(
                    '${ringkasan.jumlahBelumDitandai} tagihan belum ditandai (${jadwalBulanAsync.value?.length ?? 0} total periode)',
                  ),
                  if (ringkasan.jumlahTanpaNominal > 0) ...[
                    const SizedBox(height: SpasiFunda.xs),
                    TeksFunda.catatan(
                      '${ringkasan.jumlahTanpaNominal} tagihan belum ada perkiraan',
                      warna: WarnaFunda.peringatan,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: SpasiFunda.m),

            jadwalBulanAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(SpasiFunda.xl),
                child: Center(child: IndikatorMemuat()),
              ),
              error: (err, _) => Center(child: Text('Terjadi kesalahan: $err')),
              data: (daftarItem) {
                final perluPerhatian = daftarItem
                    .where(
                      (i) =>
                          i.status == StatusKemunculan.hariIni ||
                          i.status == StatusKemunculan.lewat ||
                          i.status == StatusKemunculan.lewatKedaluwarsa,
                    )
                    .toList();
                final akanDatang = daftarItem
                    .where((i) => i.status == StatusKemunculan.akanDatang)
                    .toList();
                final sudahDitandai = daftarItem
                    .where(
                      (i) =>
                          i.status == StatusKemunculan.dibayar ||
                          i.status == StatusKemunculan.dilewati,
                    )
                    .toList();

                if (daftarItem.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: SpasiFunda.xl,
                      ),
                      child: Column(
                        children: const [
                          Icon(
                            LucideIcons.calendarCheck,
                            size: 48,
                            color: WarnaFunda.teksRedup,
                          ),
                          SizedBox(height: SpasiFunda.m),
                          TeksFunda.judulBagian('Tidak Ada Tagihan Bulan Ini'),
                          SizedBox(height: SpasiFunda.xs),
                          TeksFunda.catatan(
                            'Semua jadwal tagihan pada bulan ini tenang.',
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kelompok 1: Perlu Perhatian (Hari Ini + Lewat)
                    if (perluPerhatian.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(
                            LucideIcons.circleAlert,
                            color: WarnaFunda.pengeluaran,
                            size: 20,
                          ),
                          const SizedBox(width: SpasiFunda.xs),
                          TeksFunda.label(
                            'Perlu Perhatian (${perluPerhatian.length})',
                            warna: WarnaFunda.pengeluaran,
                          ),
                        ],
                      ),
                      const SizedBox(height: SpasiFunda.s),
                      ...perluPerhatian.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: SpasiFunda.jarakPetak,
                          ),
                          child: _bangunKartuJadwal(item, daftarKategori),
                        ),
                      ),
                      const SizedBox(height: SpasiFunda.s),
                    ],

                    // Kelompok 2: Akan Datang
                    if (akanDatang.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(
                            LucideIcons.calendar,
                            color: WarnaFunda.utama,
                            size: 20,
                          ),
                          const SizedBox(width: SpasiFunda.xs),
                          TeksFunda.label('Akan Datang (${akanDatang.length})'),
                        ],
                      ),
                      const SizedBox(height: SpasiFunda.s),
                      ...akanDatang.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: SpasiFunda.jarakPetak,
                          ),
                          child: _bangunKartuJadwal(item, daftarKategori),
                        ),
                      ),
                      const SizedBox(height: SpasiFunda.s),
                    ],

                    // Kelompok 3: Sudah Ditandai (Dibayar / Dilewati)
                    if (sudahDitandai.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(
                            LucideIcons.circleCheck,
                            color: WarnaFunda.teksRedup,
                            size: 20,
                          ),
                          const SizedBox(width: SpasiFunda.xs),
                          TeksFunda.label(
                            'Sudah Ditandai (${sudahDitandai.length})',
                            warna: WarnaFunda.teksRedup,
                          ),
                        ],
                      ),
                      const SizedBox(height: SpasiFunda.s),
                      ...sudahDitandai.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: SpasiFunda.jarakPetak,
                          ),
                          child: _bangunKartuJadwal(item, daftarKategori),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
