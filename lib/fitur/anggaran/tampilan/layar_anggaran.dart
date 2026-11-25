import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../data/basis_data.dart';
import '../../../data/penyedia_basis_data.dart';
import '../../../komponen/komponen_funda.dart';
import '../../../komponen/pembantu_ikon.dart';
import '../../../perhitungan/perhitungan_anggaran_tujuan.dart';
import '../../../tema/token.dart';
import '../../../util/format_rupiah.dart';
import '../../kategori/kontroler/penyedia_kategori.dart';
import '../kontroler/penyedia_anggaran.dart';

/// Layar perencanaan dan pemantauan anggaran per kategori per bulan kalender
/// bergaya editorial bersih.
class LayarAnggaran extends ConsumerWidget {
  const LayarAnggaran({super.key});

  Future<void> _salinDariBulanLalu(
    BuildContext context,
    WidgetRef ref,
    dynamic repoAnggaran,
    ({int tahun, int bulan}) periode,
  ) async {
    final jumlahSalin = await repoAnggaran.salinAnggaranDariBulanLalu(
      tahunTujuan: periode.tahun,
      bulanTujuan: periode.bulan,
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            jumlahSalin > 0
                ? 'Berhasil menyalin $jumlahSalin pos anggaran dari bulan lalu (pos yang sudah ada tidak ditimpa).'
                : 'Semua pos anggaran sudah terisi atau tidak ada anggaran bulan lalu yang dapat disalin.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      ref.invalidate(penyediaRealisasiAnggaranBulan);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final periode = ref.watch(penyediaPeriodeAnggaran);
    final realisasiAsync = ref.watch(penyediaRealisasiAnggaranBulan);
    final ringkasan = ref.watch(penyediaRingkasanAnggaranBulan);
    final daftarKategori = ref.watch(penyediaDaftarKategori).value ?? [];
    final repoAnggaran = ref.watch(penyediaAnggaranRepositori);
    final isTeksBesar = MediaQuery.textScalerOf(context).scale(1) > 1.3;

    final namaBulan = DateFormat(
      'MMMM yyyy',
      'id_ID',
    ).format(DateTime(periode.tahun, periode.bulan));

    return Scaffold(
      backgroundColor: WarnaFunda.latar,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(SpasiFunda.marginLayar),
          children: [
            // Header Sub-Layar Editorial + Pil Atur Anggaran
            HeaderSubLayarEditorial(
              judul: 'Anggaran Bulanan',
              aksiKanan: [
                TombolPilHeaderEditorial(
                  key: const Key('tombol_atur_anggaran_header'),
                  teks: 'Atur',
                  ikon: LucideIcons.plus,
                  padaTekan: () => _bukaDialogAturAnggaran(
                    context,
                    ref,
                    daftarKategori,
                    periode.tahun,
                    periode.bulan,
                  ),
                ),
              ],
            ),
            const SizedBox(height: SpasiFunda.m),

            // Kartu Kontrol Periode Bulan + Akses Cepat Salin Bulan Lalu
            Container(
              decoration: BoxDecoration(
                color: WarnaFunda.permukaan,
                borderRadius: BorderRadius.circular(SudutFunda.petak),
                border: Border.all(color: WarnaFunda.garis, width: 1.0),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpasiFunda.s,
                      vertical: SpasiFunda.xs,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(LucideIcons.chevronLeft),
                          tooltip: 'Bulan Sebelumnya',
                          constraints: const BoxConstraints(
                            minWidth: 48,
                            minHeight: 48,
                          ),
                          onPressed: () => ref
                              .read(penyediaPeriodeAnggaran.notifier)
                              .bulanSebelumnya(),
                        ),
                        Expanded(
                          child: Center(
                            child: TeksFunda.judulBagian(
                              namaBulan,
                              rataTeks: TextAlign.center,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.chevronRight),
                          tooltip: 'Bulan Berikutnya',
                          constraints: const BoxConstraints(
                            minWidth: 48,
                            minHeight: 48,
                          ),
                          onPressed: () => ref
                              .read(penyediaPeriodeAnggaran.notifier)
                              .bulanBerikutnya(),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: WarnaFunda.garis),
                  Material(
                    color: WarnaFunda.transparan,
                    child: InkWell(
                      key: const Key('tombol_salin_anggaran_bulan_lalu'),
                      onTap: () => _salinDariBulanLalu(
                        context,
                        ref,
                        repoAnggaran,
                        periode,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: SpasiFunda.l,
                          vertical: SpasiFunda.m,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.copyPlus,
                              size: 18,
                              color: WarnaFunda.utama,
                            ),
                            SizedBox(width: SpasiFunda.s),
                            Expanded(
                              child: TeksFunda.label(
                                'Salin dari bulan lalu',
                                warna: WarnaFunda.utama,
                              ),
                            ),
                            Icon(
                              LucideIcons.chevronRight,
                              size: 16,
                              color: WarnaFunda.utama,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SpasiFunda.m),

            // Hero Kanvas Mint/Biru: Ringkasan Total Anggaran
            Container(
              key: const Key('hero_kanvas_anggaran'),
              padding: const EdgeInsets.all(SpasiFunda.l),
              decoration: BoxDecoration(
                color: WarnaFunda.kanvasMint,
                borderRadius: BorderRadius.circular(SudutFunda.petak),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: SpasiFunda.s,
                    runSpacing: SpasiFunda.xs,
                    children: [
                      const TeksFunda.label('Total Anggaran'),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: SpasiFunda.s,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: WarnaFunda.permukaan,
                          borderRadius: BorderRadius.circular(SudutFunda.pil),
                        ),
                        child: TeksFunda.catatan(
                          '${ringkasan.persentaseTerpakai}% terpakai',
                          warna: ringkasan.persentaseTerpakai > 100
                              ? WarnaFunda.pengeluaran
                              : WarnaFunda.teks,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: SpasiFunda.s),
                  TeksFunda.angkaBesar(
                    formatRupiah(ringkasan.totalBatasRupiah),
                    angkaTabular: true,
                  ),
                  const SizedBox(height: SpasiFunda.m),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(SudutFunda.pil),
                    child: IndikatorMemuat.garis(
                      nilai: (ringkasan.persentaseTerpakai / 100).clamp(
                        0.0,
                        1.0,
                      ),
                      tinggi: 8,
                      warnaLatar: WarnaFunda.permukaan,
                      warna: ringkasan.persentaseTerpakai > 100
                          ? WarnaFunda.pengeluaran
                          : ringkasan.persentaseTerpakai >= 80
                          ? WarnaFunda.peringatan
                          : WarnaFunda.utama,
                    ),
                  ),
                  const SizedBox(height: SpasiFunda.m),
                  if (isTeksBesar) ...[
                    const TeksFunda.catatan('Terpakai'),
                    TeksFunda.label(
                      formatRupiah(ringkasan.totalTerpakaiRupiah),
                      angkaTabular: true,
                    ),
                    const SizedBox(height: SpasiFunda.s),
                    const TeksFunda.catatan('Sisa Anggaran'),
                    TeksFunda.label(
                      formatRupiah(ringkasan.totalSisaRupiah),
                      angkaTabular: true,
                      warna: ringkasan.totalSisaRupiah < 0
                          ? WarnaFunda.pengeluaran
                          : WarnaFunda.pemasukan,
                    ),
                  ] else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const TeksFunda.catatan('Terpakai'),
                            TeksFunda.label(
                              formatRupiah(ringkasan.totalTerpakaiRupiah),
                              angkaTabular: true,
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const TeksFunda.catatan('Sisa Anggaran'),
                            TeksFunda.label(
                              formatRupiah(ringkasan.totalSisaRupiah),
                              angkaTabular: true,
                              warna: ringkasan.totalSisaRupiah < 0
                                  ? WarnaFunda.pengeluaran
                                  : WarnaFunda.pemasukan,
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: SpasiFunda.l),

            // Baris Ringkasan Per Sifat (2x2 Putih Border 1px; menumpuk saat skala teks > 1.3)
            if (ringkasan.totalBatasRupiah > 0) ...[
              const TeksFunda.judulBagian('Ringkasan Alokasi Sifat'),
              const SizedBox(height: SpasiFunda.s),
              _susunPasanganSifat(
                isTeksBesar: isTeksBesar,
                kiri: _KartuMiniSifat(
                  label: 'Kebutuhan',
                  batas: ringkasan.totalKebutuhanBatasRupiah,
                  terpakai: ringkasan.totalKebutuhanTerpakaiRupiah,
                  warnaDasar: WarnaFunda.sifatKebutuhan,
                ),
                kanan: _KartuMiniSifat(
                  label: 'Keinginan',
                  batas: ringkasan.totalKeinginanBatasRupiah,
                  terpakai: ringkasan.totalKeinginanTerpakaiRupiah,
                  warnaDasar: WarnaFunda.sifatKeinginan,
                ),
              ),
              const SizedBox(height: SpasiFunda.s),
              _susunPasanganSifat(
                isTeksBesar: isTeksBesar,
                kiri: _KartuMiniSifat(
                  label: 'Tabungan',
                  batas: ringkasan.totalTabunganBatasRupiah,
                  terpakai: ringkasan.totalTabunganTerpakaiRupiah,
                  warnaDasar: WarnaFunda.sifatTabungan,
                ),
                kanan: _KartuMiniSifat(
                  label: 'Utang',
                  batas: ringkasan.totalUtangBatasRupiah,
                  terpakai: ringkasan.totalUtangTerpakaiRupiah,
                  warnaDasar: WarnaFunda.sifatUtang,
                ),
              ),
              const SizedBox(height: SpasiFunda.l),
            ],

            // Daftar Rincian Kategori yang Dianggarkan
            const TeksFunda.judulBagian('Kategori yang Dianggarkan'),
            const SizedBox(height: SpasiFunda.s),
            realisasiAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(SpasiFunda.xl),
                  child: IndikatorMemuat(),
                ),
              ),
              error: (e, _) => Center(child: Text('Terjadi kesalahan: $e')),
              data: (daftarItem) {
                if (daftarItem.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(SpasiFunda.l),
                    decoration: BoxDecoration(
                      color: WarnaFunda.permukaan,
                      borderRadius: BorderRadius.circular(SudutFunda.petak),
                      border: Border.all(color: WarnaFunda.garis, width: 1.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: SpasiFunda.l,
                          ),
                          decoration: BoxDecoration(
                            color: WarnaFunda.kanvasBiru,
                            borderRadius: BorderRadius.circular(
                              SudutFunda.kartu,
                            ),
                          ),
                          child: Center(
                            child: IlustrasiSvgFunda(
                              pathAset: AsetIlustrasiFunda.anggaranKosong,
                              tinggi: isTeksBesar ? 80 : 104,
                            ),
                          ),
                        ),
                        const SizedBox(height: SpasiFunda.m),
                        const TeksFunda.judulBagian(
                          'Belum Ada Anggaran',
                          rataTeks: TextAlign.center,
                        ),
                        const SizedBox(height: SpasiFunda.xs),
                        TeksFunda.catatan(
                          'Rencanakan pengeluaran bulan $namaBulan agar keuanganmu tetap tenang dan terkendali.',
                          rataTeks: TextAlign.center,
                          warna: WarnaFunda.teksRedup,
                        ),
                        const SizedBox(height: SpasiFunda.l),
                        TombolFunda.pilGelap(
                          lebarPenuh: true,
                          teks: 'Atur Anggaran Sekarang',
                          padaTekan: () => _bukaDialogAturAnggaran(
                            context,
                            ref,
                            daftarKategori,
                            periode.tahun,
                            periode.bulan,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Daftar Pos Anggaran Menyatu dalam 1 Kartu Putih Border 1px
                return Container(
                  key: const Key('kartu_daftar_anggaran'),
                  decoration: BoxDecoration(
                    color: WarnaFunda.permukaan,
                    borderRadius: BorderRadius.circular(SudutFunda.petak),
                    border: Border.all(color: WarnaFunda.garis, width: 1.0),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      for (var i = 0; i < daftarItem.length; i++) ...[
                        _BarisItemAnggaran(
                          item: daftarItem[i],
                          isTeksBesar: isTeksBesar,
                          padaKetuk: () => _bukaDialogAturAnggaran(
                            context,
                            ref,
                            daftarKategori,
                            periode.tahun,
                            periode.bulan,
                            anggaranLama: daftarItem[i],
                          ),
                        ),
                        if (i < daftarItem.length - 1)
                          const Divider(
                            height: 1,
                            indent: SpasiFunda.l,
                            endIndent: SpasiFunda.l,
                            color: WarnaFunda.garis,
                          ),
                      ],
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: SpasiFunda.xxl),
          ],
        ),
      ),
    );
  }

  Widget _susunPasanganSifat({
    required bool isTeksBesar,
    required Widget kiri,
    required Widget kanan,
  }) {
    if (isTeksBesar) {
      return Column(
        children: [
          kiri,
          const SizedBox(height: SpasiFunda.s),
          kanan,
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: kiri),
        const SizedBox(width: SpasiFunda.s),
        Expanded(child: kanan),
      ],
    );
  }

  void _bukaDialogAturAnggaran(
    BuildContext context,
    WidgetRef ref,
    List<EntitasKategori> daftarKategori,
    int tahun,
    int bulan, {
    ItemRealisasiAnggaran? anggaranLama,
  }) {
    final tanpaAnimasi =
        MediaQuery.disableAnimationsOf(context) ||
        ref.read(penyediaTanpaAnimasi);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      sheetAnimationStyle: tanpaAnimasi ? AnimationStyle.noAnimation : null,
      backgroundColor: WarnaFunda.permukaan,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SudutFunda.lembar),
        ),
      ),
      builder: (ctx) => _LembarAturAnggaran(
        tahun: tahun,
        bulan: bulan,
        daftarKategori: daftarKategori,
        anggaranLama: anggaranLama,
        padaSelesai: () {
          ref.invalidate(penyediaRealisasiAnggaranBulan);
        },
      ),
    );
  }
}

class _KartuMiniSifat extends StatelessWidget {
  const _KartuMiniSifat({
    required this.label,
    required this.batas,
    required this.terpakai,
    required this.warnaDasar,
  });

  final String label;
  final int batas;
  final int terpakai;
  final Color warnaDasar;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SpasiFunda.m),
      decoration: BoxDecoration(
        color: WarnaFunda.permukaan,
        borderRadius: BorderRadius.circular(SudutFunda.kartu),
        border: Border.all(color: WarnaFunda.garis, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: warnaDasar,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: SpasiFunda.xs),
              Expanded(child: TeksFunda.label(label)),
            ],
          ),
          const SizedBox(height: SpasiFunda.xs),
          TeksFunda.catatan(
            'Batas: ${formatRupiah(batas)}',
            angkaTabular: true,
          ),
          TeksFunda.catatan(
            'Pakai: ${formatRupiah(terpakai)}',
            angkaTabular: true,
          ),
        ],
      ),
    );
  }
}

class _BarisItemAnggaran extends StatelessWidget {
  const _BarisItemAnggaran({
    required this.item,
    required this.isTeksBesar,
    required this.padaKetuk,
  });

  final ItemRealisasiAnggaran item;
  final bool isTeksBesar;
  final VoidCallback padaKetuk;

  @override
  Widget build(BuildContext context) {
    final (
      Color warnaStatus,
      Color tintStatus,
      IconData ikonStatus,
      String labelStatus,
    ) = switch (item.status) {
      StatusAnggaran.aman => (
        WarnaFunda.pemasukan,
        WarnaFunda.tintHijau,
        LucideIcons.circleCheck,
        'Aman',
      ),
      StatusAnggaran.mendekati => (
        WarnaFunda.peringatan,
        WarnaFunda.tintAmber,
        LucideIcons.triangleAlert,
        'Mendekati batas',
      ),
      StatusAnggaran.melewati => (
        WarnaFunda.pengeluaran,
        WarnaFunda.tintMawar,
        LucideIcons.circleAlert,
        'Melebihi batas',
      ),
    };

    final pilStatus = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpasiFunda.s,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: tintStatus,
        borderRadius: BorderRadius.circular(SudutFunda.pil),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ikonStatus, size: 12, color: warnaStatus),
          const SizedBox(width: SpasiFunda.xs),
          Flexible(child: TeksFunda.catatan(labelStatus, warna: warnaStatus)),
        ],
      ),
    );

    final nominalBlok = Column(
      crossAxisAlignment: isTeksBesar
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        TeksFunda.label(formatRupiah(item.terpakaiRupiah), angkaTabular: true),
        TeksFunda.catatan(
          'dari ${formatRupiah(item.batasRupiah)}',
          angkaTabular: true,
        ),
      ],
    );

    return Material(
      color: WarnaFunda.transparan,
      child: InkWell(
        onTap: padaKetuk,
        child: Padding(
          padding: const EdgeInsets.all(SpasiFunda.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      ambilIkonLucide(item.kategoriIkon),
                      size: 22,
                      color: warnaStatus,
                    ),
                  ),
                  const SizedBox(width: SpasiFunda.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TeksFunda.label(item.kategoriNama),
                        const SizedBox(height: SpasiFunda.xs),
                        pilStatus,
                        if (isTeksBesar) ...[
                          const SizedBox(height: SpasiFunda.s),
                          nominalBlok,
                        ],
                      ],
                    ),
                  ),
                  if (!isTeksBesar) ...[
                    const SizedBox(width: SpasiFunda.s),
                    nominalBlok,
                  ],
                ],
              ),
              const SizedBox(height: SpasiFunda.m),
              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(SudutFunda.pil),
                child: IndikatorMemuat.garis(
                  nilai: (item.persentase / 100).clamp(0.0, 1.0),
                  tinggi: 6,
                  warnaLatar: WarnaFunda.garis,
                  warna: warnaStatus,
                ),
              ),
              const SizedBox(height: SpasiFunda.xs),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: SpasiFunda.s,
                runSpacing: SpasiFunda.xs,
                children: [
                  TeksFunda.catatan('${item.persentase}%', angkaTabular: true),
                  TeksFunda.catatan(
                    item.sisaRupiah >= 0
                        ? 'Sisa ${formatRupiah(item.sisaRupiah)}'
                        : 'Lewat ${formatRupiah(item.sisaRupiah.abs())}',
                    angkaTabular: true,
                    warna: item.sisaRupiah < 0
                        ? WarnaFunda.pengeluaran
                        : WarnaFunda.teksRedup,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LembarAturAnggaran extends ConsumerStatefulWidget {
  const _LembarAturAnggaran({
    required this.tahun,
    required this.bulan,
    required this.daftarKategori,
    this.anggaranLama,
    required this.padaSelesai,
  });

  final int tahun;
  final int bulan;
  final List<EntitasKategori> daftarKategori;
  final ItemRealisasiAnggaran? anggaranLama;
  final VoidCallback padaSelesai;

  @override
  ConsumerState<_LembarAturAnggaran> createState() =>
      _LembarAturAnggaranState();
}

class _LembarAturAnggaranState extends ConsumerState<_LembarAturAnggaran> {
  late String? _kategoriTerpilihId;
  final _pengontrolNominal = TextEditingController();
  int _batasRupiah = 0;

  @override
  void initState() {
    super.initState();
    if (widget.anggaranLama != null) {
      _kategoriTerpilihId = widget.anggaranLama!.kategoriId;
      _batasRupiah = widget.anggaranLama!.batasRupiah;
      _pengontrolNominal.text = formatRupiah(_batasRupiah);
    } else {
      final kategoriKeluar = widget.daftarKategori
          .where((k) => k.arus == 'keluar' && !k.diarsipkan)
          .toList();
      _kategoriTerpilihId = kategoriKeluar.isNotEmpty
          ? kategoriKeluar.first.id
          : null;
    }
  }

  @override
  void dispose() {
    _pengontrolNominal.dispose();
    super.dispose();
  }

  void _padaUbahNominal(String teks) {
    final digit = teks.replaceAll(RegExp(r'[^0-9]'), '');
    final nilai = int.tryParse(digit) ?? 0;
    setState(() {
      _batasRupiah = nilai;
    });
  }

  @override
  Widget build(BuildContext context) {
    final repoAnggaran = ref.watch(penyediaAnggaranRepositori);
    final isTeksBesar = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    final kategoriKeluar = widget.daftarKategori
        .where((k) => k.arus == 'keluar' && !k.diarsipkan)
        .toList();

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: SpasiFunda.l,
          right: SpasiFunda.l,
          top: SpasiFunda.l,
          bottom: MediaQuery.of(context).viewInsets.bottom + SpasiFunda.l,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TeksFunda.judulBagian(
                    widget.anggaranLama != null
                        ? 'Ubah Batas Anggaran'
                        : 'Atur Anggaran Kategori',
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x),
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: SpasiFunda.m),
            if (widget.anggaranLama == null) ...[
              const TeksFunda.label('Pilih Kategori'),
              const SizedBox(height: SpasiFunda.xs),
              DropdownButtonFormField<String>(
                initialValue: _kategoriTerpilihId,
                isExpanded: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: WarnaFunda.latar,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SudutFunda.kartu),
                    borderSide: const BorderSide(color: WarnaFunda.garis),
                  ),
                ),
                items: kategoriKeluar.map((k) {
                  return DropdownMenuItem(
                    value: k.id,
                    child: Row(
                      children: [
                        Icon(ambilIkonLucide(k.ikon), size: 18),
                        const SizedBox(width: SpasiFunda.s),
                        Expanded(
                          child: Text(k.nama, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (id) => setState(() => _kategoriTerpilihId = id),
              ),
              const SizedBox(height: SpasiFunda.m),
            ],

            const TeksFunda.label('Batas Nominal Bulanan'),
            const SizedBox(height: SpasiFunda.xs),
            TextField(
              controller: _pengontrolNominal,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Rp 0',
                prefixIcon: const Icon(LucideIcons.walletCards),
                filled: true,
                fillColor: WarnaFunda.latar,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SudutFunda.kartu),
                  borderSide: const BorderSide(color: WarnaFunda.garis),
                ),
              ),
              onChanged: _padaUbahNominal,
            ),
            const SizedBox(height: SpasiFunda.l),

            if (isTeksBesar || widget.anggaranLama == null) ...[
              TombolFunda.pilGelap(
                lebarPenuh: true,
                teks: 'Simpan Anggaran',
                padaTekan: _batasRupiah > 0 && _kategoriTerpilihId != null
                    ? () async {
                        await repoAnggaran.simpanAnggaran(
                          tahun: widget.tahun,
                          bulan: widget.bulan,
                          kategoriId: _kategoriTerpilihId!,
                          batasRupiah: _batasRupiah,
                        );
                        widget.padaSelesai();
                        if (context.mounted) Navigator.pop(context);
                      }
                    : null,
              ),
              if (widget.anggaranLama != null) ...[
                const SizedBox(height: SpasiFunda.s),
                TombolFunda.sekunder(
                  lebarPenuh: true,
                  teks: 'Hapus Anggaran',
                  padaTekan: () async {
                    await repoAnggaran.hapusAnggaran(
                      widget.anggaranLama!.anggaranId,
                    );
                    widget.padaSelesai();
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
              ],
            ] else
              Row(
                children: [
                  Expanded(
                    child: TombolFunda.sekunder(
                      teks: 'Hapus Anggaran',
                      padaTekan: () async {
                        await repoAnggaran.hapusAnggaran(
                          widget.anggaranLama!.anggaranId,
                        );
                        widget.padaSelesai();
                        if (context.mounted) Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: SpasiFunda.m),
                  Expanded(
                    child: TombolFunda.pilGelap(
                      teks: 'Simpan Anggaran',
                      lebarPenuh: false,
                      padaTekan: _batasRupiah > 0 && _kategoriTerpilihId != null
                          ? () async {
                              await repoAnggaran.simpanAnggaran(
                                tahun: widget.tahun,
                                bulan: widget.bulan,
                                kategoriId: _kategoriTerpilihId!,
                                batasRupiah: _batasRupiah,
                              );
                              widget.padaSelesai();
                              if (context.mounted) Navigator.pop(context);
                            }
                          : null,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
