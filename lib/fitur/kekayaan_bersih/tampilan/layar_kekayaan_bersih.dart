import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../komponen/komponen_funda.dart';
import '../../../komponen/pembantu_ikon.dart';
import '../../../komponen/pembantu_tint.dart';
import '../../../tema/token.dart';
import '../../../util/format_rupiah.dart';
import '../../dompet/kontroler/penyedia_dompet.dart';
import '../../dompet/tampilan/layar_detail_dompet.dart';
import '../../utang/kontroler/penyedia_utang.dart';
import '../../utang/tampilan/layar_detail_utang.dart';

/// Layar ringkasan kekayaan bersih bergaya editorial bersih:
/// header tombol kembali >= 48dp, hero kanvas selisih aset & utang,
/// dan rincian dompet/utang menyatu dalam kartu putih border 1px.
class LayarKekayaanBersih extends ConsumerWidget {
  const LayarKekayaanBersih({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kekayaanBersih = ref.watch(penyediaKekayaanBersih);
    final totalSaldo = ref.watch(penyediaTotalSaldoAktif);
    final totalUtang = ref.watch(penyediaTotalSisaUtangAktif).value ?? 0;
    final daftarDompet = ref.watch(penyediaDaftarDompetAktif).value ?? [];
    final daftarUtang = ref.watch(penyediaDaftarUtangAktif).value ?? [];
    final isTeksBesar = MediaQuery.textScalerOf(context).scale(1) > 1.3;

    final isNegatif = kekayaanBersih < 0;

    return Scaffold(
      backgroundColor: WarnaFunda.latar,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(
                SpasiFunda.marginLayar,
                SpasiFunda.marginLayar,
                SpasiFunda.marginLayar,
                SpasiFunda.s,
              ),
              child: HeaderSubLayarEditorial(judul: 'Kekayaan Bersih'),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(penyediaDaftarDompetAktif);
                  ref.invalidate(penyediaDaftarUtangAktif);
                  ref.invalidate(penyediaTotalSisaUtangAktif);
                },
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    SpasiFunda.marginLayar,
                    SpasiFunda.s,
                    SpasiFunda.marginLayar,
                    SpasiFunda.xxl,
                  ),
                  children: [
                    // 1. Hero Kanvas: Total Kekayaan Bersih
                    Container(
                      key: const Key('hero_kanvas_kekayaan_bersih'),
                      padding: const EdgeInsets.all(SpasiFunda.l),
                      decoration: BoxDecoration(
                        color: isNegatif
                            ? WarnaFunda.kanvasKoral
                            : WarnaFunda.kanvasMint,
                        borderRadius: BorderRadius.circular(SudutFunda.petak),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const TeksFunda.label(
                                      'Total Kekayaan Bersih',
                                    ),
                                    const SizedBox(height: SpasiFunda.s),
                                    TeksFunda.angkaBesar(
                                      formatRupiah(kekayaanBersih),
                                      angkaTabular: true,
                                      warna: isNegatif
                                          ? WarnaFunda.pengeluaran
                                          : WarnaFunda.pemasukan,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: SpasiFunda.s),
                              const IlustrasiSvgFunda(
                                pathAset: AsetIlustrasiFunda.kekayaanBersih,
                                tinggi: 64,
                              ),
                            ],
                          ),
                          const SizedBox(height: SpasiFunda.m),
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            spacing: SpasiFunda.m,
                            runSpacing: SpasiFunda.s,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const TeksFunda.catatan('Total Aset (Saldo)'),
                                  TeksFunda.label(
                                    formatRupiah(totalSaldo),
                                    angkaTabular: true,
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const TeksFunda.catatan(
                                    'Total Kewajiban (Utang)',
                                  ),
                                  TeksFunda.label(
                                    formatRupiah(totalUtang),
                                    angkaTabular: true,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: SpasiFunda.m),
                          // Pesan nada menguatkan sesuai styleguide
                          Container(
                            padding: const EdgeInsets.all(SpasiFunda.m),
                            decoration: BoxDecoration(
                              color: WarnaFunda.permukaan,
                              borderRadius: BorderRadius.circular(
                                SudutFunda.kartu,
                              ),
                            ),
                            child: Row(
                              children: [
                                if (isNegatif)
                                  const Icon(
                                    LucideIcons.info,
                                    color: WarnaFunda.peringatan,
                                    size: 18,
                                  )
                                else
                                  const IkonSvgFunda(
                                    pathAset: AsetIkonFunda.trenNaik,
                                    ukuran: 20,
                                  ),
                                const SizedBox(width: SpasiFunda.s),
                                Expanded(
                                  child: TeksFunda.catatan(
                                    isNegatif
                                        ? 'Saat ini utangmu lebih besar dari saldo. Ini umum terjadi di awal, dan bisa dirapikan langkah demi langkah.'
                                        : 'Kekayaan bersihmu mencerminkan selisih saldo seluruh dompet aktif dengan sisa kewajiban utang.',
                                    warna: WarnaFunda.teks,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: SpasiFunda.xl),

                    // 2. Rincian Aset (Dompet Aktif)
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: SpasiFunda.m,
                      runSpacing: SpasiFunda.xs,
                      children: [
                        const TeksFunda.judulBagian('Aset (Dompet Aktif)'),
                        TeksFunda.label(
                          formatRupiah(totalSaldo),
                          warna: WarnaFunda.pemasukan,
                          angkaTabular: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: SpasiFunda.s),
                    if (daftarDompet.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(SpasiFunda.l),
                        decoration: BoxDecoration(
                          color: WarnaFunda.permukaan,
                          borderRadius: BorderRadius.circular(SudutFunda.petak),
                          border: Border.all(
                            color: WarnaFunda.garis,
                            width: 1.0,
                          ),
                        ),
                        child: const Center(
                          child: TeksFunda.catatan('Belum ada dompet aktif.'),
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          color: WarnaFunda.permukaan,
                          borderRadius: BorderRadius.circular(SudutFunda.petak),
                          border: Border.all(
                            color: WarnaFunda.garis,
                            width: 1.0,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            for (var i = 0; i < daftarDompet.length; i++) ...[
                              () {
                                final dompet = daftarDompet[i];
                                final petaSaldo = ref.watch(
                                  penyediaPetaSaldoDompet,
                                );
                                final saldo =
                                    petaSaldo[dompet.id] ??
                                    dompet.saldoAwalRupiah;
                                final warnaAksen = ambilWarnaAksenTint(
                                  dompet.warna,
                                );

                                return Material(
                                  color: WarnaFunda.transparan,
                                  child: InkWell(
                                    onTap: () {
                                      final router = GoRouter.maybeOf(context);
                                      if (router != null) {
                                        router.push('/dompet/${dompet.id}');
                                      } else {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute<void>(
                                            builder: (_) => LayarDetailDompet(
                                              dompetId: dompet.id,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: SpasiFunda.l,
                                        vertical: SpasiFunda.m,
                                      ),
                                      child: Row(
                                        children: [
                                          IkonDompetFunda(
                                            kodeJenis: dompet.jenis,
                                            kunciIkonFallback: dompet.ikon,
                                            ukuran: 24,
                                            warnaFallback: warnaAksen,
                                          ),
                                          const SizedBox(width: SpasiFunda.m),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                TeksFunda.label(dompet.nama),
                                                if (isTeksBesar) ...[
                                                  const SizedBox(height: 2),
                                                  TeksFunda.label(
                                                    formatRupiah(saldo),
                                                    angkaTabular: true,
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                          if (!isTeksBesar) ...[
                                            const SizedBox(width: SpasiFunda.s),
                                            TeksFunda.label(
                                              formatRupiah(saldo),
                                              angkaTabular: true,
                                            ),
                                          ],
                                          const SizedBox(width: SpasiFunda.xs),
                                          const Icon(
                                            LucideIcons.chevronRight,
                                            size: 18,
                                            color: WarnaFunda.teksRedup,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }(),
                              if (i < daftarDompet.length - 1)
                                const Divider(
                                  height: 1,
                                  indent: SpasiFunda.l,
                                  endIndent: SpasiFunda.l,
                                  color: WarnaFunda.garis,
                                ),
                            ],
                          ],
                        ),
                      ),
                    const SizedBox(height: SpasiFunda.xl),

                    // 3. Rincian Kewajiban (Utang Aktif)
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: SpasiFunda.m,
                      runSpacing: SpasiFunda.xs,
                      children: [
                        const TeksFunda.judulBagian('Kewajiban (Utang Aktif)'),
                        TeksFunda.label(
                          formatRupiah(totalUtang),
                          warna: WarnaFunda.pengeluaran,
                          angkaTabular: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: SpasiFunda.s),
                    if (daftarUtang.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(SpasiFunda.l),
                        decoration: BoxDecoration(
                          color: WarnaFunda.permukaan,
                          borderRadius: BorderRadius.circular(SudutFunda.petak),
                          border: Border.all(
                            color: WarnaFunda.garis,
                            width: 1.0,
                          ),
                        ),
                        child: const Center(
                          child: TeksFunda.catatan(
                            'Tidak ada kewajiban utang aktif saat ini.',
                          ),
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          color: WarnaFunda.permukaan,
                          borderRadius: BorderRadius.circular(SudutFunda.petak),
                          border: Border.all(
                            color: WarnaFunda.garis,
                            width: 1.0,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            for (var i = 0; i < daftarUtang.length; i++) ...[
                              () {
                                final utang = daftarUtang[i];
                                final sisaAsync = ref.watch(
                                  penyediaSisaUtang(utang.id),
                                );
                                final sisa =
                                    sisaAsync.value ?? utang.sisaAwalRupiah;

                                return Material(
                                  color: WarnaFunda.transparan,
                                  child: InkWell(
                                    onTap: () {
                                      final router = GoRouter.maybeOf(context);
                                      if (router != null) {
                                        router.push('/utang/${utang.id}');
                                      } else {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute<void>(
                                            builder: (_) => LayarDetailUtang(
                                              utangId: utang.id,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: SpasiFunda.l,
                                        vertical: SpasiFunda.m,
                                      ),
                                      child: Row(
                                        children: [
                                          const IkonSvgFunda(
                                            pathAset: AsetIkonFunda.menuUtang,
                                            ukuran: 22,
                                          ),
                                          const SizedBox(width: SpasiFunda.m),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                TeksFunda.label(utang.nama),
                                                if (isTeksBesar) ...[
                                                  const SizedBox(height: 2),
                                                  TeksFunda.label(
                                                    formatRupiah(sisa),
                                                    warna:
                                                        WarnaFunda.pengeluaran,
                                                    angkaTabular: true,
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                          if (!isTeksBesar) ...[
                                            const SizedBox(width: SpasiFunda.s),
                                            TeksFunda.label(
                                              formatRupiah(sisa),
                                              warna: WarnaFunda.pengeluaran,
                                              angkaTabular: true,
                                            ),
                                          ],
                                          const SizedBox(width: SpasiFunda.xs),
                                          const Icon(
                                            LucideIcons.chevronRight,
                                            size: 18,
                                            color: WarnaFunda.teksRedup,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }(),
                              if (i < daftarUtang.length - 1)
                                const Divider(
                                  height: 1,
                                  indent: SpasiFunda.l,
                                  endIndent: SpasiFunda.l,
                                  color: WarnaFunda.garis,
                                ),
                            ],
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
