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
import '../../pengaturan/tampilan/layar_pengaturan.dart';
import '../../transaksi/tampilan/layar_form_transaksi.dart';
import '../kontroler/penyedia_tagihan.dart';
import 'layar_form_tagihan.dart';
import 'layar_semua_tagihan.dart';

/// Layar utama Jadwal Tagihan & Langganan Berulang dengan gaya editorial bersih.
class LayarJadwalTagihan extends ConsumerStatefulWidget {
  const LayarJadwalTagihan({super.key});

  @override
  ConsumerState<LayarJadwalTagihan> createState() => _LayarJadwalTagihanState();
}

class _LayarJadwalTagihanState extends ConsumerState<LayarJadwalTagihan> {
  void _bukaRute(String rute, WidgetBuilder pembuatCadangan) {
    final router = GoRouter.maybeOf(context);
    if (router != null) {
      context.push(rute);
    } else {
      Navigator.push(context, MaterialPageRoute(builder: pembuatCadangan));
    }
  }

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
            style: FilledButton.styleFrom(
              backgroundColor: WarnaFunda.tombolGelap,
            ),
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
      final router = GoRouter.maybeOf(context);
      if (router != null) {
        context.push('/utang/detail/${item.idUtang}').then((_) {
          ref.invalidate(penyediaJadwalBulanTerpilih);
        });
      }
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

  Widget _bangunBarisJadwal(
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

    return Padding(
      padding: const EdgeInsets.all(SpasiFunda.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: !item.isCicilanUtang && kategori != null
                    ? IkonKategoriFunda(
                        kunciIkon: kategori.ikon,
                        ukuran: 22,
                        warnaFallback: warnaStatus,
                      )
                    : Icon(
                        item.isCicilanUtang
                            ? LucideIcons.creditCard
                            : LucideIcons.receipt,
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
                      runSpacing: SpasiFunda.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        TeksFunda.label(item.nama),
                        if (item.isCicilanUtang)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: SpasiFunda.s,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: WarnaFunda.tintAmber,
                              borderRadius: BorderRadius.circular(
                                SudutFunda.pil,
                              ),
                            ),
                            child: const TeksFunda.catatan(
                              'Cicilan Utang',
                              warna: WarnaFunda.teks,
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
                    const SizedBox(height: SpasiFunda.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SpasiFunda.s,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: latarStatus,
                        borderRadius: BorderRadius.circular(SudutFunda.pil),
                      ),
                      child: TeksFunda.catatan(labelStatus, warna: warnaStatus),
                    ),
                  ],
                ),
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
                Wrap(
                  spacing: SpasiFunda.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (!item.isCicilanUtang)
                      IconButton(
                        constraints: const BoxConstraints(
                          minWidth: 48,
                          minHeight: 48,
                        ),
                        icon: const Icon(
                          LucideIcons.skipForward,
                          size: 20,
                          color: WarnaFunda.teksRedup,
                        ),
                        tooltip: 'Lewati periode ini',
                        onPressed: () => _lewatiPeriode(item),
                      ),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: WarnaFunda.tombolGelap,
                        foregroundColor: WarnaFunda.teksPutih,
                        shape: const StadiumBorder(),
                        minimumSize: const Size(0, 44),
                        padding: const EdgeInsets.symmetric(
                          horizontal: SpasiFunda.m,
                          vertical: SpasiFunda.s,
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

  Widget _bangunKelompokKartu({
    required IconData ikon,
    required Color warnaJudul,
    required String judul,
    required List<ItemJadwalTampilan> daftarItem,
    required List<EntitasKategori> daftarKategori,
  }) {
    if (daftarItem.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(ikon, color: warnaJudul, size: 18),
            const SizedBox(width: SpasiFunda.xs),
            Expanded(
              child: TeksFunda.label(
                '$judul (${daftarItem.length})',
                warna: warnaJudul,
              ),
            ),
          ],
        ),
        const SizedBox(height: SpasiFunda.s),
        Container(
          decoration: BoxDecoration(
            color: WarnaFunda.permukaan,
            borderRadius: BorderRadius.circular(SudutFunda.kartu),
            border: Border.all(color: WarnaFunda.garis, width: 1.0),
          ),
          child: Column(
            children: [
              for (var i = 0; i < daftarItem.length; i++) ...[
                if (i > 0)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: WarnaFunda.garis,
                  ),
                _bangunBarisJadwal(daftarItem[i], daftarKategori),
              ],
            ],
          ),
        ),
        const SizedBox(height: SpasiFunda.l),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bulanTerpilih = ref.watch(penyediaBulanJadwalTerpilih);
    final jadwalBulanAsync = ref.watch(penyediaJadwalBulanTerpilih);
    final ringkasan = ref.watch(penyediaRingkasanBulanTerpilih);
    final daftarKategori = ref.watch(penyediaDaftarKategori).value ?? [];
    final isTeksBesar = MediaQuery.textScalerOf(context).scale(1) > 1.3;

    final namaBulanTahun = DateFormat(
      'MMMM yyyy',
      'id_ID',
    ).format(bulanTerpilih);

    return Scaffold(
      backgroundColor: WarnaFunda.latar,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                SpasiFunda.marginLayar,
                SpasiFunda.s,
                SpasiFunda.marginLayar,
                SpasiFunda.s,
              ),
              child: HeaderSubLayarEditorial(
                judul: 'Tagihan & Pengingat',
                aksiKanan: [
                  IconButton(
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                    icon: const Icon(
                      LucideIcons.listFilter,
                      color: WarnaFunda.teks,
                      size: 20,
                    ),
                    tooltip: 'Master Tagihan',
                    onPressed: () => _bukaRute(
                      '/tagihan/semua',
                      (_) => const LayarSemuaTagihan(),
                    ),
                  ),
                  IconButton(
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                    icon: const Icon(
                      LucideIcons.settings,
                      color: WarnaFunda.teks,
                      size: 20,
                    ),
                    tooltip: 'Pengaturan Pengingat',
                    onPressed: () => _bukaRute(
                      '/pengaturan',
                      (_) => const LayarPengaturan(),
                    ),
                  ),
                  TombolPilHeaderEditorial(
                    key: const Key('tombol_tambah_tagihan_jadwal'),
                    teks: 'Baru',
                    ikon: LucideIcons.plus,
                    warnaTeks: WarnaFunda.teksPutih,
                    warnaLatar: WarnaFunda.tombolGelap,
                    warnaBatas: WarnaFunda.tombolGelap,
                    padaTekan: () => _bukaRute(
                      '/tagihan/tambah',
                      (_) => const LayarFormTagihan(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  SpasiFunda.marginLayar,
                  SpasiFunda.xs,
                  SpasiFunda.marginLayar,
                  SpasiFunda.xl,
                ),
                children: [
                  // Navigasi Pemilih Bulan
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpasiFunda.xs,
                      vertical: SpasiFunda.xs,
                    ),
                    decoration: BoxDecoration(
                      color: WarnaFunda.permukaan,
                      borderRadius: BorderRadius.circular(SudutFunda.kartu),
                      border: Border.all(color: WarnaFunda.garis, width: 1.0),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          constraints: const BoxConstraints(
                            minWidth: 48,
                            minHeight: 48,
                          ),
                          icon: const Icon(LucideIcons.chevronLeft),
                          tooltip: 'Bulan Sebelumnya',
                          onPressed: () => ref
                              .read(penyediaBulanJadwalTerpilih.notifier)
                              .gantiBulan(-1),
                        ),
                        Expanded(
                          child: Center(
                            child: TeksFunda.judulBagian(
                              namaBulanTahun,
                              rataTeks: TextAlign.center,
                            ),
                          ),
                        ),
                        IconButton(
                          constraints: const BoxConstraints(
                            minWidth: 48,
                            minHeight: 48,
                          ),
                          icon: const Icon(LucideIcons.chevronRight),
                          tooltip: 'Bulan Berikutnya',
                          onPressed: () => ref
                              .read(penyediaBulanJadwalTerpilih.notifier)
                              .gantiBulan(1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: SpasiFunda.m),

                  // Hero Kanvas Biru Ringkasan Bulan Terpilih
                  Semantics(
                    label:
                        'Sudah dibayar ${formatRupiah(ringkasan.sudahDibayarRupiah)}, perkiraan sisa ${formatRupiah(ringkasan.sisaPerkiraanRupiah)}',
                    child: Container(
                      key: const Key('hero_kanvas_jadwal_tagihan'),
                      padding: const EdgeInsets.all(SpasiFunda.l),
                      decoration: BoxDecoration(
                        color: WarnaFunda.kanvasBiru,
                        borderRadius: BorderRadius.circular(SudutFunda.petak),
                        border: Border.all(
                          color: WarnaFunda.batasBiru,
                          width: 1.0,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TeksFunda.label('Ringkasan $namaBulanTahun'),
                          const SizedBox(height: SpasiFunda.m),
                          if (isTeksBesar) ...[
                            const TeksFunda.catatan('Sudah Dibayar'),
                            const SizedBox(height: SpasiFunda.xs),
                            TeksFunda.judulBagian(
                              formatRupiah(ringkasan.sudahDibayarRupiah),
                              warna: WarnaFunda.pemasukan,
                            ),
                            const SizedBox(height: SpasiFunda.m),
                            const TeksFunda.catatan('Perkiraan Sisa'),
                            const SizedBox(height: SpasiFunda.xs),
                            TeksFunda.judulBagian(
                              formatRupiah(ringkasan.sisaPerkiraanRupiah),
                            ),
                          ] else ...[
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const TeksFunda.catatan('Sudah Dibayar'),
                                      const SizedBox(height: SpasiFunda.xs),
                                      TeksFunda.judulBagian(
                                        formatRupiah(
                                          ringkasan.sudahDibayarRupiah,
                                        ),
                                        warna: WarnaFunda.pemasukan,
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const TeksFunda.catatan('Perkiraan Sisa'),
                                      const SizedBox(height: SpasiFunda.xs),
                                      TeksFunda.judulBagian(
                                        formatRupiah(
                                          ringkasan.sisaPerkiraanRupiah,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
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
                  ),
                  const SizedBox(height: SpasiFunda.l),

                  jadwalBulanAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(SpasiFunda.xl),
                      child: Center(child: IndikatorMemuat()),
                    ),
                    error: (err, _) =>
                        Center(child: Text('Terjadi kesalahan: $err')),
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
                        return Container(
                          padding: const EdgeInsets.all(SpasiFunda.l),
                          decoration: BoxDecoration(
                            color: WarnaFunda.permukaan,
                            borderRadius: BorderRadius.circular(
                              SudutFunda.petak,
                            ),
                            border: Border.all(
                              color: WarnaFunda.garis,
                              width: 1.0,
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: SpasiFunda.m,
                                ),
                                decoration: BoxDecoration(
                                  color: WarnaFunda.kanvasMint,
                                  borderRadius: BorderRadius.circular(
                                    SudutFunda.kartu,
                                  ),
                                ),
                                child: const Center(
                                  child: IlustrasiSvgFunda(
                                    pathAset: AsetIlustrasiFunda.tagihanTenang,
                                    tinggi: 96,
                                  ),
                                ),
                              ),
                              const SizedBox(height: SpasiFunda.m),
                              const TeksFunda.judulBagian(
                                'Tidak Ada Tagihan Bulan Ini',
                                rataTeks: TextAlign.center,
                              ),
                              const SizedBox(height: SpasiFunda.xs),
                              const TeksFunda.catatan(
                                'Semua jadwal tagihan pada bulan ini tenang.',
                                rataTeks: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _bangunKelompokKartu(
                            ikon: LucideIcons.circleAlert,
                            warnaJudul: WarnaFunda.pengeluaran,
                            judul: 'Perlu Perhatian',
                            daftarItem: perluPerhatian,
                            daftarKategori: daftarKategori,
                          ),
                          _bangunKelompokKartu(
                            ikon: LucideIcons.calendar,
                            warnaJudul: WarnaFunda.utama,
                            judul: 'Akan Datang',
                            daftarItem: akanDatang,
                            daftarKategori: daftarKategori,
                          ),
                          _bangunKelompokKartu(
                            ikon: LucideIcons.circleCheck,
                            warnaJudul: WarnaFunda.pemasukan,
                            judul: 'Sudah Ditandai',
                            daftarItem: sudahDitandai,
                            daftarKategori: daftarKategori,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
