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

/// Layar daftar seluruh catatan utang dan cicilan pengguna.
class LayarDaftarUtang extends ConsumerWidget {
  const LayarDaftarUtang({super.key});

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
      appBar: AppBar(
        title: const TeksFunda.judulBagian('Utang & Cicilan'),
        backgroundColor: WarnaFunda.latar,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: WarnaFunda.utama,
        foregroundColor: WarnaFunda.permukaan,
        icon: const Icon(LucideIcons.plus),
        label: const Text('Catat Utang'),
        onPressed: () => context.push('/utang/tambah'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(penyediaDaftarUtangAktif);
            ref.invalidate(penyediaDaftarUtangLunas);
            ref.invalidate(penyediaTotalSisaUtangAktif);
          },
          child: ListView(
            padding: const EdgeInsets.all(SpasiFunda.m),
            children: [
              // 1. Bento Hero: Ringkasan Utang & Rasio Cicilan
              PetakBento.ukuran2x1(
                warnaKustom: WarnaFunda.tintAmber,
                labelAkses:
                    'Total sisa utang ${formatRupiah(totalSisaUtang)}, cicilan bulanan ${formatRupiah(totalCicilan)}',
                anak: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TeksFunda.label('Total Sisa Utang Aktif'),
                    const SizedBox(height: SpasiFunda.s),
                    TeksFunda.angkaBesar(formatRupiah(totalSisaUtang)),
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
                            TeksFunda.label(formatRupiah(totalCicilan)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const TeksFunda.catatan('Rasio Cicilan'),
                            TeksFunda.label(
                              rasioCicilan != null ? '$rasioCicilan%' : '-',
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
              const SizedBox(height: SpasiFunda.l),

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
                        borderRadius: BorderRadius.circular(SudutFunda.kartu),
                        border: Border.all(color: WarnaFunda.garis),
                      ),
                      child: KeadaanKosong(
                        ikon: LucideIcons.checkCircle2,
                        pesan:
                            'Tidak ada utang aktif saat ini. Semua kewajibanmu terkontrol dengan baik!',
                        teksTombol: 'Catat Utang Baru',
                        padaAksi: () => context.push('/utang/tambah'),
                      ),
                    );
                  }

                  return Column(
                    children: daftarAktif.map((utang) {
                      return _KartuItemUtang(utang: utang);
                    }).toList(),
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(SpasiFunda.m),
                    child: IndikatorMemuat(),
                  ),
                ),
                error: (err, _) => Center(child: Text('Gagal memuat: $err')),
              ),
              const SizedBox(height: SpasiFunda.l),

              // 3. Daftar Utang Lunas (Bagian Terpisah)
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
                              color: WarnaFunda.sukses.withAlpha(25),
                              borderRadius: BorderRadius.circular(
                                SudutFunda.pil,
                              ),
                            ),
                            child: TeksFunda.catatan(
                              '${daftarLunas.length}',
                              warna: WarnaFunda.sukses,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: SpasiFunda.s),
                      ...daftarLunas.map((utang) {
                        return _KartuItemUtang(utang: utang, isLunas: true);
                      }),
                      const SizedBox(height: SpasiFunda.xl),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 64), // Ruang untuk FAB
            ],
          ),
        ),
      ),
    );
  }
}

class _KartuItemUtang extends ConsumerWidget {
  const _KartuItemUtang({required this.utang, this.isLunas = false});

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

    return Container(
      margin: const EdgeInsets.only(bottom: SpasiFunda.m),
      decoration: BoxDecoration(
        color: WarnaFunda.permukaan,
        borderRadius: BorderRadius.circular(SudutFunda.kartu),
        border: Border.all(color: WarnaFunda.garis),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(SudutFunda.kartu),
          onTap: () => context.push('/utang/${utang.id}'),
          child: Padding(
            padding: const EdgeInsets.all(SpasiFunda.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SpasiFunda.s,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color:
                            (isLunas
                                    ? WarnaFunda.sukses
                                    : WarnaFunda.peringatan)
                                .withAlpha(25),
                        borderRadius: BorderRadius.circular(SudutFunda.pil),
                      ),
                      child: TeksFunda.catatan(
                        isLunas ? 'Lunas' : 'Aktif',
                        warna: isLunas
                            ? WarnaFunda.sukses
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
                          warna: isLunas ? WarnaFunda.sukses : WarnaFunda.teks,
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
      ),
    );
  }
}
