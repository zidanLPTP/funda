import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../data/basis_data.dart';
import '../../../data/model/jenis_utang.dart';
import '../../../komponen/komponen_funda.dart';
import '../../../perhitungan/perhitungan_utang_dashboard.dart';
import '../../../tema/token.dart';
import '../../../util/format_rupiah.dart';
import '../kontroler/penyedia_utang.dart';
import 'layar_detail_utang.dart';
import 'layar_form_utang.dart';

/// Layar daftar seluruh catatan utang dan cicilan pengguna bergaya editorial bersih:
/// header tombol kembali >= 48dp + pil Catat, hero kanvas amber/kuning tenang,
/// dan daftar menyatu dalam kartu putih border 1px.
class LayarDaftarUtang extends ConsumerWidget {
  const LayarDaftarUtang({super.key});

  void _bukaFormTambah(BuildContext context) {
    final router = GoRouter.maybeOf(context);
    if (router != null) {
      router.push('/utang/tambah');
    } else {
      Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (_) => const LayarFormUtang()),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daftarUtangAktifAsync = ref.watch(penyediaDaftarUtangAktif);
    final daftarUtangLunasAsync = ref.watch(penyediaDaftarUtangLunas);
    final totalSisaUtang = ref.watch(penyediaTotalSisaUtangAktif).value ?? 0;
    final totalCicilan = ref.watch(penyediaTotalCicilanBulananAktif);
    final rasioCicilan = ref.watch(penyediaRasioCicilan);
    final dasarPemasukan = ref.watch(penyediaPemasukanBulananRataRata);

    return Scaffold(
      backgroundColor: WarnaFunda.latar,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                SpasiFunda.marginLayar,
                SpasiFunda.marginLayar,
                SpasiFunda.marginLayar,
                SpasiFunda.s,
              ),
              child: HeaderSubLayarEditorial(
                judul: 'Utang & Cicilan',
                aksiKanan: [
                  TombolPilHeaderEditorial(
                    key: const Key('tombol_catat_utang_header'),
                    teks: 'Catat',
                    ikon: LucideIcons.plus,
                    padaTekan: () => _bukaFormTambah(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(penyediaDaftarUtangAktif);
                  ref.invalidate(penyediaDaftarUtangLunas);
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
                    // 1. Hero Kanvas Kuning: Ringkasan Utang & Rasio Cicilan
                    Semantics(
                      container: true,
                      label:
                          'Total sisa utang ${formatRupiah(totalSisaUtang)}, cicilan bulanan ${formatRupiah(totalCicilan)}',
                      child: Container(
                        key: const Key('hero_kanvas_daftar_utang'),
                        padding: const EdgeInsets.all(SpasiFunda.l),
                        decoration: BoxDecoration(
                          color: WarnaFunda.kanvasKuning,
                          borderRadius: BorderRadius.circular(SudutFunda.petak),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const TeksFunda.catatan(
                              'Total Sisa Utang Aktif',
                              warna: WarnaFunda.teksRedup,
                            ),
                            const SizedBox(height: SpasiFunda.xs),
                            TeksFunda.angkaBesar(
                              formatRupiah(totalSisaUtang),
                              angkaTabular: true,
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
                                    const TeksFunda.catatan(
                                      'Kewajiban Cicilan / Bulan',
                                    ),
                                    TeksFunda.label(
                                      formatRupiah(totalCicilan),
                                      angkaTabular: true,
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const TeksFunda.catatan('Rasio Cicilan'),
                                    TeksFunda.label(
                                      rasioCicilan != null
                                          ? '$rasioCicilan%'
                                          : '-',
                                      angkaTabular: true,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: SpasiFunda.xs),
                            TeksFunda.catatan(
                              rasioCicilan != null
                                  ? 'Bagian dari pemasukanmu (${dasarPemasukan.dasar.keterangan})'
                                  : dasarPemasukan.dasar.keterangan,
                              warna: WarnaFunda.teksRedup,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: SpasiFunda.xl),

                    // 2. Daftar Utang Aktif
                    const TeksFunda.judulBagian('Utang yang Sedang Berjalan'),
                    const SizedBox(height: SpasiFunda.s),

                    daftarUtangAktifAsync.when(
                      data: (daftarAktif) {
                        if (daftarAktif.isEmpty) {
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
                                      pathAset:
                                          AsetIlustrasiFunda.utangLunasKosong,
                                      tinggi: 92,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: SpasiFunda.m),
                                const TeksFunda.catatan(
                                  'Tidak ada utang aktif saat ini. Semua kewajibanmu terkontrol dengan baik!',
                                  rataTeks: TextAlign.center,
                                  warna: WarnaFunda.teksRedup,
                                ),
                                const SizedBox(height: SpasiFunda.l),
                                TombolFunda.pilGelap(
                                  lebarPenuh: true,
                                  teks: 'Catat Utang Baru',
                                  padaTekan: () => _bukaFormTambah(context),
                                ),
                              ],
                            ),
                          );
                        }

                        return Container(
                          key: const Key('kartu_daftar_utang_aktif'),
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
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            children: [
                              for (var i = 0; i < daftarAktif.length; i++) ...[
                                _BarisItemUtang(utang: daftarAktif[i]),
                                if (i < daftarAktif.length - 1)
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
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(SpasiFunda.m),
                          child: IndikatorMemuat(),
                        ),
                      ),
                      error: (err, _) =>
                          Center(child: Text('Gagal memuat: $err')),
                    ),
                    const SizedBox(height: SpasiFunda.xl),

                    // 3. Daftar Utang Lunas
                    daftarUtangLunasAsync.when(
                      data: (daftarLunas) {
                        if (daftarLunas.isEmpty) return const SizedBox.shrink();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const TeksFunda.judulBagian('Sudah Lunas'),
                                const SizedBox(width: SpasiFunda.s),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: SpasiFunda.s,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: WarnaFunda.tintHijau,
                                    borderRadius: BorderRadius.circular(
                                      SudutFunda.pil,
                                    ),
                                  ),
                                  child: TeksFunda.catatan(
                                    '${daftarLunas.length}',
                                    warna: WarnaFunda.pemasukan,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: SpasiFunda.s),
                            Container(
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
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                children: [
                                  for (
                                    var i = 0;
                                    i < daftarLunas.length;
                                    i++
                                  ) ...[
                                    _BarisItemUtang(
                                      utang: daftarLunas[i],
                                      isLunas: true,
                                    ),
                                    if (i < daftarLunas.length - 1)
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
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, _) => const SizedBox.shrink(),
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

class _BarisItemUtang extends ConsumerWidget {
  const _BarisItemUtang({required this.utang, this.isLunas = false});

  final EntitasUtang utang;
  final bool isLunas;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sisaUtangAsync = ref.watch(penyediaSisaUtang(utang.id));
    final sisaUtang = isLunas
        ? 0
        : (sisaUtangAsync.value ?? utang.sisaAwalRupiah);
    final estimasiBulan = hitungEstimasiSisaBulan(
      sisaRupiah: sisaUtang,
      cicilanBulananRupiah: utang.cicilanBulananRupiah,
    );

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
                builder: (_) => LayarDetailUtang(utangId: utang.id),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(SpasiFunda.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isLunas ? LucideIcons.circleCheck : LucideIcons.creditCard,
                    size: 22,
                    color: isLunas
                        ? WarnaFunda.pemasukan
                        : WarnaFunda.sifatUtang,
                  ),
                  const SizedBox(width: SpasiFunda.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TeksFunda.label(utang.nama),
                        TeksFunda.catatan(
                          utang.pemberi != null && utang.pemberi!.isNotEmpty
                              ? '${JenisUtang.dariKode(utang.jenis).label} • ${utang.pemberi}'
                              : JenisUtang.dariKode(utang.jenis).label,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: SpasiFunda.s),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpasiFunda.s,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isLunas
                          ? WarnaFunda.tintHijau
                          : WarnaFunda.tintAmber,
                      borderRadius: BorderRadius.circular(SudutFunda.pil),
                    ),
                    child: TeksFunda.catatan(
                      isLunas ? 'Lunas' : 'Aktif',
                      warna: isLunas
                          ? WarnaFunda.pemasukan
                          : WarnaFunda.peringatan,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SpasiFunda.m),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.end,
                spacing: SpasiFunda.m,
                runSpacing: SpasiFunda.s,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const TeksFunda.catatan('Sisa Utang'),
                      TeksFunda.label(
                        formatRupiah(sisaUtang),
                        warna: isLunas ? WarnaFunda.pemasukan : WarnaFunda.teks,
                        angkaTabular: true,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (utang.cicilanBulananRupiah > 0) ...[
                        TeksFunda.catatan(
                          '${formatRupiah(utang.cicilanBulananRupiah)} / bln',
                          angkaTabular: true,
                        ),
                        if (estimasiBulan != null)
                          TeksFunda.catatan('$estimasiBulan bulan lagi')
                        else if (utang.tanggalJatuhTempoBulanan != null)
                          TeksFunda.catatan(
                            'Jatuh tempo tgl ${utang.tanggalJatuhTempoBulanan}',
                          ),
                      ] else ...[
                        const TeksFunda.catatan('Tanpa cicilan rutin'),
                      ],
                    ],
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
