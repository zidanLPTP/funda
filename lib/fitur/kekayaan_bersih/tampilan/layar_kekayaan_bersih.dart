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
import '../../utang/kontroler/penyedia_utang.dart';

/// Layar ringkasan kekayaan bersih (Total Aset Saldo vs Total Kewajiban Utang).
class LayarKekayaanBersih extends ConsumerWidget {
  const LayarKekayaanBersih({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kekayaanBersih = ref.watch(penyediaKekayaanBersih);
    final totalSaldo = ref.watch(penyediaTotalSaldoAktif);
    final totalUtang = ref.watch(penyediaTotalSisaUtangAktif).value ?? 0;
    final daftarDompet = ref.watch(penyediaDaftarDompetAktif).value ?? [];
    final daftarUtang = ref.watch(penyediaDaftarUtangAktif).value ?? [];

    final isNegatif = kekayaanBersih < 0;

    return Scaffold(
      backgroundColor: WarnaFunda.latar,
      appBar: AppBar(
        title: const TeksFunda.judulBagian('Kekayaan Bersih'),
        backgroundColor: WarnaFunda.latar,
        elevation: 0,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(penyediaDaftarDompetAktif);
            ref.invalidate(penyediaDaftarUtangAktif);
            ref.invalidate(penyediaTotalSisaUtangAktif);
          },
          child: ListView(
            padding: const EdgeInsets.all(SpasiFunda.m),
            children: [
              // 1. Bento Hero: Total Kekayaan Bersih
              PetakBento.ukuran2x1(
                warnaKustom: isNegatif
                    ? WarnaFunda.tintMawar
                    : WarnaFunda.tintHijau,
                labelAkses: 'Kekayaan bersih ${formatRupiah(kekayaanBersih)}',
                anak: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TeksFunda.label('Total Kekayaan Bersih'),
                    const SizedBox(height: SpasiFunda.s),
                    TeksFunda.angkaBesar(
                      formatRupiah(kekayaanBersih),
                      warna: isNegatif
                          ? WarnaFunda.pengeluaran
                          : WarnaFunda.sukses,
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
                            TeksFunda.label(formatRupiah(totalSaldo)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const TeksFunda.catatan('Total Kewajiban (Utang)'),
                            TeksFunda.label(formatRupiah(totalUtang)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: SpasiFunda.m),
                    // Pesan nada menguatkan sesuai styleguide
                    Container(
                      padding: const EdgeInsets.all(SpasiFunda.s),
                      decoration: BoxDecoration(
                        color: WarnaFunda.permukaan,
                        borderRadius: BorderRadius.circular(SudutFunda.kecil),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isNegatif
                                ? LucideIcons.info
                                : LucideIcons.trendingUp,
                            color: isNegatif
                                ? WarnaFunda.peringatan
                                : WarnaFunda.utama,
                            size: 16,
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
              const SizedBox(height: SpasiFunda.l),

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
                  padding: const EdgeInsets.all(SpasiFunda.m),
                  decoration: BoxDecoration(
                    color: WarnaFunda.permukaan,
                    borderRadius: BorderRadius.circular(SudutFunda.kartu),
                    border: Border.all(color: WarnaFunda.garis),
                  ),
                  child: const Center(
                    child: TeksFunda.catatan('Belum ada dompet aktif.'),
                  ),
                )
              else
                ...daftarDompet.map((dompet) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: SpasiFunda.s),
                    decoration: BoxDecoration(
                      color: WarnaFunda.permukaan,
                      borderRadius: BorderRadius.circular(SudutFunda.kartu),
                      border: Border.all(color: WarnaFunda.garis),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(SpasiFunda.s),
                        decoration: BoxDecoration(
                          color: ambilWarnaTint(dompet.warna),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          ambilIkonLucide(dompet.ikon),
                          color: WarnaFunda.utama,
                          size: 20,
                        ),
                      ),
                      title: TeksFunda.label(dompet.nama),
                      trailing: Consumer(
                        builder: (context, ref, _) {
                          final petaSaldo = ref.watch(penyediaPetaSaldoDompet);
                          final saldo =
                              petaSaldo[dompet.id] ?? dompet.saldoAwalRupiah;
                          return TeksFunda.label(
                            formatRupiah(saldo),
                            angkaTabular: true,
                          );
                        },
                      ),
                      onTap: () => context.push('/dompet/${dompet.id}'),
                    ),
                  );
                }),
              const SizedBox(height: SpasiFunda.l),

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
                  padding: const EdgeInsets.all(SpasiFunda.m),
                  decoration: BoxDecoration(
                    color: WarnaFunda.permukaan,
                    borderRadius: BorderRadius.circular(SudutFunda.kartu),
                    border: Border.all(color: WarnaFunda.garis),
                  ),
                  child: const Center(
                    child: TeksFunda.catatan(
                      'Tidak ada kewajiban utang aktif saat ini.',
                    ),
                  ),
                )
              else
                ...daftarUtang.map((utang) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: SpasiFunda.s),
                    decoration: BoxDecoration(
                      color: WarnaFunda.permukaan,
                      borderRadius: BorderRadius.circular(SudutFunda.kartu),
                      border: Border.all(color: WarnaFunda.garis),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(SpasiFunda.s),
                        decoration: BoxDecoration(
                          color: WarnaFunda.tintAmber,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          LucideIcons.fileText,
                          color: WarnaFunda.peringatan,
                          size: 20,
                        ),
                      ),
                      title: TeksFunda.label(utang.nama),
                      trailing: Consumer(
                        builder: (context, ref, _) {
                          final sisaAsync = ref.watch(
                            penyediaSisaUtang(utang.id),
                          );
                          final sisa = sisaAsync.value ?? utang.sisaAwalRupiah;
                          return TeksFunda.label(
                            formatRupiah(sisa),
                            warna: WarnaFunda.pengeluaran,
                            angkaTabular: true,
                          );
                        },
                      ),
                      onTap: () => context.push('/utang/${utang.id}'),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}
