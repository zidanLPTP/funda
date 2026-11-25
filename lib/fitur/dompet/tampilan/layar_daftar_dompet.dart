import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../data/basis_data.dart';
import '../../../data/model/jenis_dompet.dart';
import '../../../data/penyedia_data.dart';
import '../../../komponen/komponen_funda.dart';
import '../../../komponen/pembantu_ikon.dart';
import '../../../komponen/pembantu_tint.dart';
import '../../../tema/token.dart';
import '../../../util/format_rupiah.dart';
import 'layar_detail_dompet.dart';
import 'layar_form_dompet.dart';

/// Layar Daftar Dompet bergaya editorial bersih:
/// header tombol kembali >= 48dp + pil Tambah, hero kanvas mint total saldo,
/// dan daftar dompet menyatu dalam kartu putih border 1px berpemisah tipis.
class LayarDaftarDompet extends ConsumerWidget {
  const LayarDaftarDompet({super.key});

  void _bukaFormTambah(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const LayarFormDompet()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daftarDompetAsync = ref.watch(penyediaDaftarDompet);
    final petaSaldo = ref.watch(penyediaPetaSaldoDompet);
    final totalSaldo = ref.watch(penyediaTotalSaldoAktif);
    final isTeksBesar = MediaQuery.textScalerOf(context).scale(1) > 1.3;

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
                judul: 'Daftar Dompet',
                aksiKanan: [
                  TombolPilHeaderEditorial(
                    key: const Key('tombol_tambah_dompet_header'),
                    teks: 'Tambah',
                    ikon: LucideIcons.plus,
                    padaTekan: () => _bukaFormTambah(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: daftarDompetAsync.when(
                loading: () => const Center(child: IndikatorMemuat()),
                error: (e, _) => Center(child: Text('Terjadi kesalahan: $e')),
                data: (daftar) {
                  if (daftar.isEmpty) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(SpasiFunda.marginLayar),
                      child: Container(
                        padding: const EdgeInsets.all(SpasiFunda.l),
                        decoration: BoxDecoration(
                          color: WarnaFunda.permukaan,
                          borderRadius: BorderRadius.circular(SudutFunda.petak),
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
                                vertical: SpasiFunda.l,
                              ),
                              decoration: BoxDecoration(
                                color: WarnaFunda.kanvasMint,
                                borderRadius: BorderRadius.circular(
                                  SudutFunda.kartu,
                                ),
                              ),
                              child: const Center(
                                child: IlustrasiGeometrisFunda(
                                  jenis: JenisIlustrasiFunda.celengan,
                                  warnaAksen: WarnaFunda.utama,
                                  ukuran: 64,
                                ),
                              ),
                            ),
                            const SizedBox(height: SpasiFunda.m),
                            const TeksFunda.judulBagian(
                              'Belum Ada Dompet',
                              rataTeks: TextAlign.center,
                            ),
                            const SizedBox(height: SpasiFunda.xs),
                            const TeksFunda.catatan(
                              'Kamu belum memiliki akun dompet. Buat dompet pertamamu untuk mulai mencatat keuangan.',
                              rataTeks: TextAlign.center,
                              warna: WarnaFunda.teksRedup,
                            ),
                            const SizedBox(height: SpasiFunda.l),
                            TombolFunda.pilGelap(
                              lebarPenuh: true,
                              teks: 'Buat Dompet Pertama',
                              padaTekan: () => _bukaFormTambah(context),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final dompetAktif = daftar
                      .where((d) => !d.diarsipkan)
                      .toList();
                  final dompetArsip = daftar
                      .where((d) => d.diarsipkan)
                      .toList();

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      SpasiFunda.marginLayar,
                      SpasiFunda.s,
                      SpasiFunda.marginLayar,
                      SpasiFunda.xl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hero Kanvas Mint: Ringkasan Total Saldo
                        Container(
                          key: const Key('hero_kanvas_dompet'),
                          width: double.infinity,
                          padding: const EdgeInsets.all(SpasiFunda.l),
                          decoration: BoxDecoration(
                            color: WarnaFunda.kanvasMint,
                            borderRadius: BorderRadius.circular(
                              SudutFunda.petak,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const TeksFunda.catatan(
                                'Total Saldo Seluruh Dompet Aktif',
                                warna: WarnaFunda.teksRedup,
                              ),
                              const SizedBox(height: SpasiFunda.xs),
                              TeksFunda.angkaBesar(
                                formatRupiah(totalSaldo),
                                angkaTabular: true,
                                warna: totalSaldo < 0
                                    ? WarnaFunda.pengeluaran
                                    : WarnaFunda.teks,
                              ),
                              const SizedBox(height: SpasiFunda.xs),
                              TeksFunda.catatan(
                                '${dompetAktif.length} dompet aktif terdaftar',
                                warna: WarnaFunda.teksRedup,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: SpasiFunda.xl),

                        // Daftar Dompet Aktif Menyatu dalam 1 Kartu Putih Border 1px
                        if (dompetAktif.isNotEmpty) ...[
                          const TeksFunda.judulBagian('Dompet Aktif'),
                          const SizedBox(height: SpasiFunda.m),
                          _KartuDaftarDompetPutih(
                            key: const Key('kartu_daftar_dompet_aktif'),
                            daftarDompet: dompetAktif,
                            petaSaldo: petaSaldo,
                            isTeksBesar: isTeksBesar,
                          ),
                        ],

                        // Daftar Dompet Diarsipkan jika ada
                        if (dompetArsip.isNotEmpty) ...[
                          const SizedBox(height: SpasiFunda.xl),
                          const TeksFunda.judulBagian('Diarsipkan'),
                          const SizedBox(height: SpasiFunda.m),
                          _KartuDaftarDompetPutih(
                            key: const Key('kartu_daftar_dompet_arsip'),
                            daftarDompet: dompetArsip,
                            petaSaldo: petaSaldo,
                            isTeksBesar: isTeksBesar,
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KartuDaftarDompetPutih extends StatelessWidget {
  const _KartuDaftarDompetPutih({
    super.key,
    required this.daftarDompet,
    required this.petaSaldo,
    required this.isTeksBesar,
  });

  final List<EntitasDompet> daftarDompet;
  final Map<String, int> petaSaldo;
  final bool isTeksBesar;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: WarnaFunda.permukaan,
        borderRadius: BorderRadius.circular(SudutFunda.petak),
        border: Border.all(color: WarnaFunda.garis, width: 1.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < daftarDompet.length; i++) ...[
            () {
              final dompet = daftarDompet[i];
              final saldo = petaSaldo[dompet.id] ?? dompet.saldoAwalRupiah;
              final jenis = JenisDompet.dariKode(dompet.jenis);
              final warnaAksen = ambilWarnaAksenTint(dompet.warna);

              final infoNominal = Column(
                crossAxisAlignment: isTeksBesar
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.end,
                children: [
                  TeksFunda.label(
                    formatRupiah(saldo),
                    warna: saldo < 0 ? WarnaFunda.pengeluaran : WarnaFunda.teks,
                    angkaTabular: true,
                  ),
                  if (dompet.diarsipkan) ...[
                    const SizedBox(height: 2),
                    const TeksFunda.catatan(
                      'Diarsipkan',
                      warna: WarnaFunda.peringatan,
                    ),
                  ],
                ],
              );

              return Semantics(
                button: true,
                label: 'Dompet ${dompet.nama}, saldo ${formatRupiah(saldo)}',
                child: Material(
                  color: WarnaFunda.transparan,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              LayarDetailDompet(dompetId: dompet.id),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SpasiFunda.l,
                        vertical: SpasiFunda.m,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            ambilIkonLucide(dompet.ikon),
                            size: 22,
                            color: warnaAksen,
                          ),
                          const SizedBox(width: SpasiFunda.m),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TeksFunda.label(dompet.nama),
                                const SizedBox(height: 2),
                                TeksFunda.catatan(
                                  jenis.label,
                                  warna: WarnaFunda.teksRedup,
                                ),
                                if (isTeksBesar) ...[
                                  const SizedBox(height: SpasiFunda.xs),
                                  infoNominal,
                                ],
                              ],
                            ),
                          ),
                          if (!isTeksBesar) ...[
                            const SizedBox(width: SpasiFunda.s),
                            infoNominal,
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
    );
  }
}
