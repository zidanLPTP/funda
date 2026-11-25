import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../data/basis_data.dart';
import '../../../data/model/jenis_tujuan.dart';
import '../../../komponen/komponen_funda.dart';
import '../../../komponen/pembantu_ikon.dart';
import '../../../komponen/pembantu_tint.dart';
import '../../../perhitungan/perhitungan_anggaran_tujuan.dart';
import '../../../tema/token.dart';
import '../../../util/format_rupiah.dart';
import '../kontroler/penyedia_tujuan.dart';
import 'layar_detail_tujuan.dart';
import 'layar_form_tujuan.dart';

/// Layar daftar seluruh tujuan finansial pengguna bergaya editorial bersih:
/// header tombol kembali >= 48dp + pil Tambah, hero kanvas mint, dan daftar kartu putih 1px.
class LayarDaftarTujuan extends ConsumerWidget {
  const LayarDaftarTujuan({super.key});

  void _bukaFormTambah(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const LayarFormTujuan()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daftarTujuanAsync = ref.watch(penyediaDaftarTujuanAktif);
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
                judul: 'Tujuan Keuangan',
                aksiKanan: [
                  TombolPilHeaderEditorial(
                    key: const Key('tombol_tambah_tujuan_header'),
                    teks: 'Tambah',
                    ikon: LucideIcons.plus,
                    padaTekan: () => _bukaFormTambah(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: daftarTujuanAsync.when(
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
                              child: Center(
                                child: IlustrasiSvgFunda(
                                  pathAset: AsetIlustrasiFunda.tujuanKosong,
                                  tinggi: isTeksBesar ? 80 : 104,
                                ),
                              ),
                            ),
                            const SizedBox(height: SpasiFunda.m),
                            const TeksFunda.judulBagian(
                              'Belum Ada Tujuan',
                              rataTeks: TextAlign.center,
                            ),
                            const SizedBox(height: SpasiFunda.xs),
                            const TeksFunda.catatan(
                              'Tetapkan impian keuanganmu, seperti Dana Darurat, Liburan, atau Tabungan Masa Depan.',
                              rataTeks: TextAlign.center,
                              warna: WarnaFunda.teksRedup,
                            ),
                            const SizedBox(height: SpasiFunda.l),
                            TombolFunda.pilGelap(
                              lebarPenuh: true,
                              teks: 'Buat Tujuan Pertamamu',
                              padaTekan: () => _bukaFormTambah(context),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final totalTarget = daftar.fold<int>(
                    0,
                    (sum, t) => sum + t.targetRupiah,
                  );

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      SpasiFunda.marginLayar,
                      SpasiFunda.s,
                      SpasiFunda.marginLayar,
                      SpasiFunda.xxl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hero Kanvas Mint Ringkasan Tujuan
                        Container(
                          key: const Key('hero_kanvas_daftar_tujuan'),
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
                                'Total Target Tujuan Aktif',
                                warna: WarnaFunda.teksRedup,
                              ),
                              const SizedBox(height: SpasiFunda.xs),
                              TeksFunda.angkaBesar(
                                formatRupiah(totalTarget),
                                angkaTabular: true,
                              ),
                              const SizedBox(height: SpasiFunda.xs),
                              TeksFunda.catatan(
                                '${daftar.length} tujuan aktif sedang berjalan',
                                warna: WarnaFunda.teksRedup,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: SpasiFunda.xl),

                        const TeksFunda.judulBagian('Daftar Tujuan'),
                        const SizedBox(height: SpasiFunda.m),
                        Container(
                          key: const Key('kartu_daftar_tujuan'),
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
                              for (var i = 0; i < daftar.length; i++) ...[
                                _BarisTujuanEditorial(
                                  tujuan: daftar[i],
                                  isTeksBesar: isTeksBesar,
                                  padaKetuk: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute<void>(
                                        builder: (_) => LayarDetailTujuan(
                                          tujuanId: daftar[i].id,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                if (i < daftar.length - 1)
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

class _BarisTujuanEditorial extends ConsumerWidget {
  const _BarisTujuanEditorial({
    required this.tujuan,
    required this.isTeksBesar,
    required this.padaKetuk,
  });

  final EntitasTujuan tujuan;
  final bool isTeksBesar;
  final VoidCallback padaKetuk;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final danaTerkumpulAsync = ref.watch(penyediaDanaTujuan(tujuan.id));
    final danaTerkumpul = danaTerkumpulAsync.value ?? 0;
    final progres = hitungProgresTujuan(
      danaRupiah: danaTerkumpul,
      targetRupiah: tujuan.targetRupiah,
    );
    final jenis = JenisTujuan.dariKode(tujuan.jenis);
    final sisa = tujuan.targetRupiah - danaTerkumpul;
    final warnaAksen = ambilWarnaAksenTint(tujuan.warna);

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
                children: [
                  Icon(
                    ambilIkonLucide(tujuan.ikon),
                    size: 22,
                    color: warnaAksen,
                  ),
                  const SizedBox(width: SpasiFunda.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TeksFunda.label(tujuan.nama),
                        TeksFunda.catatan(jenis.label),
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
                      color: progres >= 100
                          ? WarnaFunda.tintHijau
                          : WarnaFunda.tintNetral,
                      borderRadius: BorderRadius.circular(SudutFunda.pil),
                    ),
                    child: TeksFunda.catatan(
                      '$progres%',
                      angkaTabular: true,
                      warna: progres >= 100
                          ? WarnaFunda.pemasukan
                          : WarnaFunda.utama,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SpasiFunda.m),
              if (isTeksBesar) ...[
                const TeksFunda.catatan('Terkumpul'),
                TeksFunda.label(
                  formatRupiah(danaTerkumpul),
                  angkaTabular: true,
                ),
                const SizedBox(height: SpasiFunda.xs),
                const TeksFunda.catatan('Target'),
                TeksFunda.label(
                  formatRupiah(tujuan.targetRupiah),
                  angkaTabular: true,
                ),
              ] else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const TeksFunda.catatan('Terkumpul'),
                        TeksFunda.label(
                          formatRupiah(danaTerkumpul),
                          angkaTabular: true,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const TeksFunda.catatan('Target'),
                        TeksFunda.label(
                          formatRupiah(tujuan.targetRupiah),
                          angkaTabular: true,
                        ),
                      ],
                    ),
                  ],
                ),
              const SizedBox(height: SpasiFunda.s),
              ClipRRect(
                borderRadius: BorderRadius.circular(SudutFunda.pil),
                child: IndikatorMemuat.garis(
                  nilai: (progres / 100).clamp(0.0, 1.0),
                  tinggi: 6,
                  warnaLatar: WarnaFunda.garis,
                  warna: progres >= 100 ? WarnaFunda.sukses : WarnaFunda.utama,
                ),
              ),
              const SizedBox(height: SpasiFunda.xs),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: SpasiFunda.s,
                runSpacing: SpasiFunda.xs,
                children: [
                  if (tujuan.tenggat != null)
                    TeksFunda.catatan(
                      'Tenggat: ${DateFormat('d MMM yyyy', 'id_ID').format(tujuan.tenggat!)}',
                    )
                  else
                    const TeksFunda.catatan('Tanpa tenggat'),
                  TeksFunda.catatan(
                    sisa > 0 ? 'Sisa ${formatRupiah(sisa)}' : 'Tercapai',
                    angkaTabular: true,
                    warna: sisa <= 0
                        ? WarnaFunda.pemasukan
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
