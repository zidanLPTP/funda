import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../komponen/komponen_funda.dart';
import '../../../perhitungan/perhitungan_belajar.dart';
import '../../../tema/token.dart';
import '../kontroler/penyedia_belajar.dart';
import 'lembar_detail_modul.dart';

/// Layar utama Tab Belajar bergaya editorial micro-learning:
/// kartu sorotan terbelah dua di atas, aksi utama pil gelap, dan kartu modul ramping.
class LayarBelajar extends ConsumerWidget {
  const LayarBelajar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petaAsync = ref.watch(penyediaPetaBelajar);

    return Scaffold(
      backgroundColor: WarnaFunda.latar,
      body: SafeArea(
        child: petaAsync.when(
          loading: () =>
              const Center(child: IndikatorMemuat(warna: WarnaFunda.utama)),
          error: (err, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(SpasiFunda.m),
              child: KeadaanKosong(
                ikon: LucideIcons.circleAlert,
                judul: 'Gagal Memuat Materi',
                pesan: 'Terjadi kendala saat membaca materi belajar: $err',
                teksTombol: 'Coba Lagi',
                padaAksi: () => ref.refresh(penyediaPetaBelajar),
              ),
            ),
          ),
          data: (daftarItemModul) {
            final modulPemula = daftarItemModul
                .where((m) => m.modul.tingkat == 'pemula')
                .toList();
            final modulMenengah = daftarItemModul
                .where((m) => m.modul.tingkat == 'menengah')
                .toList();
            final modulLanjutan = daftarItemModul
                .where((m) => m.modul.tingkat == 'lanjutan')
                .toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(SpasiFunda.marginLayar),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TeksFunda.judulLayar('Belajar Finansial'),
                  const SizedBox(height: SpasiFunda.xs),
                  const TeksFunda.isiKecil(
                    'Kuasai fondasi uangmu langkah demi langkah melalui praktik nyata.',
                    warna: WarnaFunda.teksRedup,
                  ),
                  const SizedBox(height: SpasiFunda.l),

                  // Kartu Sorotan Atas Terbelah Dua (Split Card) + Tombol Pil Gelap
                  _KartuSorotanAtas(daftarItemModul: daftarItemModul),

                  if (modulPemula.isNotEmpty) ...[
                    _BagianTingkatBelajar(
                      judul: 'Tingkat Pemula',
                      keterangan:
                          'Fondasi penting arus kas, tabungan, dan dana darurat.',
                      warnaAksen: WarnaFunda.utama,
                      daftarModul: modulPemula,
                    ),
                    const SizedBox(height: SpasiFunda.xl),
                  ],

                  if (modulMenengah.isNotEmpty) ...[
                    _BagianTingkatBelajar(
                      judul: 'Tingkat Menengah',
                      keterangan:
                          'Perlindungan aset, manajemen kredit, dan investasi dasar.',
                      warnaAksen: WarnaFunda.sifatKebutuhan,
                      daftarModul: modulMenengah,
                    ),
                    const SizedBox(height: SpasiFunda.xl),
                  ],

                  if (modulLanjutan.isNotEmpty) ...[
                    _BagianTingkatBelajar(
                      judul: 'Tingkat Lanjutan',
                      keterangan:
                          'Perencanaan jangka panjang, KPR, dan kebebasan finansial.',
                      warnaAksen: WarnaFunda.sifatKeinginan,
                      daftarModul: modulLanjutan,
                    ),
                    const SizedBox(height: SpasiFunda.xxl),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _KartuSorotanAtas extends ConsumerWidget {
  final List<ItemPetaModul> daftarItemModul;

  const _KartuSorotanAtas({required this.daftarItemModul});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profilAsync = ref.watch(penyediaStreamProfilKeuangan);
    final rekomendasiAsync = ref.watch(penyediaDaftarRekomendasiModul);
    final pernyataanAsync = ref.watch(penyediaStreamPernyataan);

    final dilewati = pernyataanAsync.asData?.value['profil_dilewati'] == 'true';

    return profilAsync.when(
      data: (profil) {
        if (profil == null && !dilewati) {
          return _bangunSplitCard(
            context,
            kunciKartu: const Key('kartu_sorotan_tes_awal'),
            jenisIlustrasi: JenisIlustrasiFunda.kompas,
            warnaAksenIlustrasi: WarnaFunda.tombolGelap,
            labelKecil: 'Mulai Dari Sini',
            judul: 'Tes Awal 3 Menit',
            deskripsi:
                'Kenali kondisi keuanganmu agar modul pertama yang paling relevan langsung terbuka.',
            teksTombol: 'Mulai Tes Awal',
            padaTekan: () => context.push('/belajar/tes-awal'),
          );
        }

        return rekomendasiAsync.when(
          data: (daftar) {
            if (daftar.isNotEmpty) {
              final rek = daftar.first;
              final itemPeta = daftarItemModul
                  .where((m) => m.modul.id == rek.modul.id)
                  .firstOrNull;
              final pelBerikutnya = itemPeta?.daftarPelajaran
                  .where((p) => p.$2.status != StatusBelajar.terkunci)
                  .map((p) => p.$1)
                  .firstOrNull;
              final tema = temaVisualUntukModul(rek.modul.id);
              final isTersedia = rek.modul.tersedia;

              return _bangunSplitCard(
                context,
                kunciKartu: const Key('kartu_sorotan_rekomendasi'),
                jenisIlustrasi: tema.ilustrasi,
                warnaAksenIlustrasi: tema.aksen,
                labelKecil: rek.judulAlasan,
                judul: rek.modul.judul,
                deskripsi: rek.deskripsiAlasan,
                teksTombol: isTersedia
                    ? (pelBerikutnya != null
                          ? 'Lanjut Belajar'
                          : 'Buka Modul Ini')
                    : 'Segera Hadir',
                padaTekan: isTersedia
                    ? () {
                        if (pelBerikutnya != null) {
                          context.push(
                            '/belajar/pelajaran/${rek.modul.id}/${pelBerikutnya.id}',
                          );
                        } else if (rek.statusModul.ruteAksi != null) {
                          context.push(rek.statusModul.ruteAksi!);
                        } else {
                          tampilkanLembarDetailModul(
                            context,
                            modulId: rek.modul.id,
                          );
                        }
                      }
                    : null,
              );
            }

            // Fallback bila daftar rekomendasi kosong tetapi ada pelajaran aktif
            final itemAktif = _cariPelajaranAktifPertama();
            if (itemAktif == null) return const SizedBox.shrink();
            final (modulAktif, pelAktif) = itemAktif;
            final tema = temaVisualUntukModul(modulAktif.id);

            return _bangunSplitCard(
              context,
              kunciKartu: const Key('kartu_sorotan_lanjut'),
              jenisIlustrasi: tema.ilustrasi,
              warnaAksenIlustrasi: tema.aksen,
              labelKecil: modulAktif.judul,
              judul: pelAktif.judul,
              deskripsi:
                  'Lanjutkan langkah belajar hari ini (${pelAktif.durasiMenit} menit).',
              teksTombol: 'Lanjut Belajar',
              padaTekan: () => context.push(
                '/belajar/pelajaran/${modulAktif.id}/${pelAktif.id}',
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  (dynamic, dynamic)? _cariPelajaranAktifPertama() {
    for (final item in daftarItemModul) {
      if (!item.modul.tersedia || item.modul.id == 'mulai_tes_awal') continue;
      for (final (pel, st) in item.daftarPelajaran) {
        if (st.status == StatusBelajar.sedang ||
            st.status == StatusBelajar.terbuka) {
          return (item.modul, pel);
        }
      }
    }
    return null;
  }

  Widget _bangunSplitCard(
    BuildContext context, {
    required Key kunciKartu,
    required JenisIlustrasiFunda jenisIlustrasi,
    required Color warnaAksenIlustrasi,
    required String labelKecil,
    required String judul,
    required String deskripsi,
    required String teksTombol,
    required VoidCallback? padaTekan,
  }) {
    final teksBesar = MediaQuery.textScalerOf(context).scale(1) >= 1.5;

    return Container(
      key: kunciKartu,
      margin: const EdgeInsets.only(bottom: SpasiFunda.xl),
      decoration: BoxDecoration(
        color: WarnaFunda.permukaan,
        borderRadius: BorderRadius.circular(SudutFunda.petak),
        border: Border.all(color: WarnaFunda.garis, width: 1.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!teksBesar)
                  Expanded(
                    flex: 38,
                    child: Container(
                      color: WarnaFunda.mintCerah,
                      padding: const EdgeInsets.all(SpasiFunda.m),
                      child: Center(
                        child: IlustrasiGeometrisFunda(
                          jenis: jenisIlustrasi,
                          warnaAksen: warnaAksenIlustrasi,
                          ukuran: 88,
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  flex: 62,
                  child: Padding(
                    padding: const EdgeInsets.all(SpasiFunda.l),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TeksFunda.catatan(labelKecil, warna: WarnaFunda.utama),
                        const SizedBox(height: SpasiFunda.xs),
                        TeksFunda.judulBagian(judul),
                        const SizedBox(height: SpasiFunda.xs),
                        TeksFunda.isiKecil(
                          deskripsi,
                          warna: WarnaFunda.teksRedup,
                          rataTeks: TextAlign.start,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              SpasiFunda.l,
              0,
              SpasiFunda.l,
              SpasiFunda.l,
            ),
            child: TombolFunda.pilGelap(teks: teksTombol, padaTekan: padaTekan),
          ),
        ],
      ),
    );
  }
}

class _BagianTingkatBelajar extends StatelessWidget {
  final String judul;
  final String keterangan;
  final Color warnaAksen;
  final List<ItemPetaModul> daftarModul;

  const _BagianTingkatBelajar({
    required this.judul,
    required this.keterangan,
    required this.warnaAksen,
    required this.daftarModul,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: warnaAksen,
                borderRadius: BorderRadius.circular(SudutFunda.pil),
              ),
            ),
            const SizedBox(width: SpasiFunda.s),
            Expanded(child: TeksFunda.judulBagian(judul)),
          ],
        ),
        const SizedBox(height: SpasiFunda.xs),
        TeksFunda.catatan(keterangan, warna: WarnaFunda.teksRedup),
        const SizedBox(height: SpasiFunda.m),
        ...daftarModul.map((item) => _KartuModulRamping(item: item)),
      ],
    );
  }
}

class _KartuModulRamping extends ConsumerWidget {
  final ItemPetaModul item;

  const _KartuModulRamping({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modul = item.modul;
    final profilSudahAda =
        ref.watch(penyediaStreamProfilKeuangan).asData?.value != null;
    final tema = temaVisualUntukModul(modul.id);
    final isTersedia = modul.tersedia;
    final statusModul = (modul.id == 'mulai_tes_awal' && profilSudahAda)
        ? const HasilStatusBelajar(
            status: StatusBelajar.selesai,
            apaYangKurang: [],
          )
        : item.statusModul;
    final modulTerkunci = statusModul.status == StatusBelajar.terkunci;

    final jumlahSelesai = item.daftarPelajaran
        .where((p) => p.$2.status == StatusBelajar.selesai)
        .length;
    final totalPelajaran = item.daftarPelajaran.length;

    final String teksProgres;
    if (modul.id == 'mulai_tes_awal') {
      teksProgres = profilSudahAda ? 'Profil tersimpan' : '0/1';
    } else if (!isTersedia) {
      teksProgres = 'Segera Hadir';
    } else {
      teksProgres = '$jumlahSelesai/$totalPelajaran';
    }

    final judulKartu = (modul.id == 'mulai_tes_awal' && profilSudahAda)
        ? 'Profil keuanganmu sudah tersimpan'
        : modul.judul;

    return Container(
      key: (modul.id == 'mulai_tes_awal' && profilSudahAda)
          ? const Key('kartu_modul_0_tersimpan')
          : Key('kartu_modul_${modul.id}'),
      margin: const EdgeInsets.only(bottom: SpasiFunda.m),
      decoration: BoxDecoration(
        color: WarnaFunda.permukaan,
        borderRadius: BorderRadius.circular(SudutFunda.petak),
        border: Border.all(color: WarnaFunda.garis, width: 1.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: WarnaFunda.transparan,
        child: InkWell(
          onTap: () => tampilkanLembarDetailModul(context, modulId: modul.id),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 80),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SpasiFunda.l,
                vertical: SpasiFunda.m,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          judulKartu,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TipografiFunda.label.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: WarnaFunda.teks,
                          ),
                        ),
                        const SizedBox(height: SpasiFunda.s),
                        Wrap(
                          spacing: SpasiFunda.s,
                          runSpacing: SpasiFunda.xs,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: SpasiFunda.s,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: WarnaFunda.tintNetral,
                                borderRadius: BorderRadius.circular(
                                  SudutFunda.pil,
                                ),
                              ),
                              child: TeksFunda.catatan(
                                teksProgres,
                                warna: WarnaFunda.teksRedup,
                              ),
                            ),
                            if (modulTerkunci && isTersedia)
                              const TeksFunda.catatan(
                                'Perlu data',
                                warna: WarnaFunda.peringatan,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: SpasiFunda.l),
                  // Satu ikon vektor garis berwarna cerah tanpa kotak latar belakang
                  Icon(tema.ikonGaris, size: 30, color: tema.warnaIkon),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
