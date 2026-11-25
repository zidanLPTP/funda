import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../komponen/komponen_funda.dart';
import '../../../perhitungan/perhitungan_belajar.dart';
import '../../../tema/token.dart';
import '../kontroler/penyedia_belajar.dart';

/// Membuka lembar bawah detail modul berisi syarat gerbang, daftar pelajaran, dan kuis akhir.
Future<void> tampilkanLembarDetailModul(
  BuildContext context, {
  required String modulId,
}) {
  var tanpaAnimasi = MediaQuery.disableAnimationsOf(context);
  if (!tanpaAnimasi) {
    try {
      tanpaAnimasi = ProviderScope.containerOf(
        context,
        listen: false,
      ).read(penyediaTanpaAnimasi);
    } catch (_) {}
  }

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    sheetAnimationStyle: tanpaAnimasi ? AnimationStyle.noAnimation : null,
    backgroundColor: WarnaFunda.permukaan,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(SudutFunda.lembar),
      ),
    ),
    builder: (ctx) => _LembarDetailModul(modulId: modulId),
  );
}

class _LembarDetailModul extends ConsumerWidget {
  final String modulId;

  const _LembarDetailModul({required this.modulId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petaAsync = ref.watch(penyediaPetaBelajar);
    final profilSudahAda =
        ref.watch(penyediaStreamProfilKeuangan).asData?.value != null;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      child: petaAsync.when(
        loading: () => const SizedBox(
          height: 180,
          child: Center(child: IndikatorMemuat()),
        ),
        error: (err, _) => Padding(
          padding: const EdgeInsets.all(SpasiFunda.l),
          child: TeksFunda.isi('Gagal memuat modul: $err'),
        ),
        data: (daftarItem) {
          final item = daftarItem
              .where((m) => m.modul.id == modulId)
              .firstOrNull;
          if (item == null) {
            return const Padding(
              padding: EdgeInsets.all(SpasiFunda.l),
              child: TeksFunda.isi('Modul tidak ditemukan.'),
            );
          }

          final modul = item.modul;
          final tema = temaVisualUntukModul(modul.id);
          final statusModul = (modul.id == 'mulai_tes_awal' && profilSudahAda)
              ? const HasilStatusBelajar(
                  status: StatusBelajar.selesai,
                  apaYangKurang: [],
                )
              : item.statusModul;
          final modulTerkunci = statusModul.status == StatusBelajar.terkunci;

          return SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                SpasiFunda.l,
                SpasiFunda.s,
                SpasiFunda.l,
                SpasiFunda.xl,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: SpasiFunda.m),
                      decoration: BoxDecoration(
                        color: WarnaFunda.garis,
                        borderRadius: BorderRadius.circular(SudutFunda.pil),
                      ),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TeksFunda.catatan(
                              'Modul ${modul.urutan}',
                              warna: tema.aksen,
                            ),
                            const SizedBox(height: SpasiFunda.xs),
                            TeksFunda.judulBagian(modul.judul),
                          ],
                        ),
                      ),
                      const SizedBox(width: SpasiFunda.m),
                      Icon(tema.ikonGaris, size: 28, color: tema.warnaIkon),
                    ],
                  ),
                  const SizedBox(height: SpasiFunda.s),
                  TeksFunda.isiKecil(
                    modul.deskripsiSingkat,
                    warna: WarnaFunda.teksRedup,
                  ),

                  // Status pernyataan relevan per modul
                  _BangunBannerPernyataanModul(modulId: modul.id),

                  if (modul.id == 'mulai_tes_awal') ...[
                    const SizedBox(height: SpasiFunda.m),
                    if (profilSudahAda)
                      Container(
                        padding: const EdgeInsets.all(SpasiFunda.m),
                        decoration: BoxDecoration(
                          color: WarnaFunda.tintHijau,
                          borderRadius: BorderRadius.circular(SudutFunda.kartu),
                          border: Border.all(color: WarnaFunda.batasHijau),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              LucideIcons.checkCircle2,
                              size: 20,
                              color: WarnaFunda.pemasukan,
                            ),
                            SizedBox(width: SpasiFunda.s),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TeksFunda.label(
                                    'Profil keuanganmu sudah tersimpan',
                                    warna: WarnaFunda.pemasukan,
                                  ),
                                  SizedBox(height: 2),
                                  TeksFunda.catatan(
                                    'Kamu bisa memperbaruinya di Lainnya -> Pengaturan.',
                                    warna: WarnaFunda.teksRedup,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      TombolFunda.pilGelap(
                        key: const Key('tombol_buka_tes_awal'),
                        teks: 'Buka Tes Awal',
                        padaTekan: () {
                          Navigator.pop(context);
                          context.push('/belajar/tes-awal');
                        },
                      ),
                  ] else if (!modul.tersedia) ...[
                    const SizedBox(height: SpasiFunda.m),
                    Container(
                      padding: const EdgeInsets.all(SpasiFunda.m),
                      decoration: BoxDecoration(
                        color: WarnaFunda.tintNetral,
                        borderRadius: BorderRadius.circular(SudutFunda.kartu),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            LucideIcons.clock,
                            size: 18,
                            color: WarnaFunda.utama,
                          ),
                          SizedBox(width: SpasiFunda.s),
                          Expanded(
                            child: TeksFunda.catatan(
                              'Segera hadir di kurikulum mendatang.',
                              warna: WarnaFunda.teksRedup,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    if (modulTerkunci &&
                        statusModul.apaYangKurang.isNotEmpty) ...[
                      const SizedBox(height: SpasiFunda.m),
                      KotakSyaratBelajar(
                        daftarPesan: statusModul.apaYangKurang,
                        ruteAksi: statusModul.ruteAksi,
                        daftarAtauPernyataan: statusModul.daftarAtauPernyataan,
                      ),
                    ],
                    const SizedBox(height: SpasiFunda.m),
                    const Divider(color: WarnaFunda.garis),
                    const SizedBox(height: SpasiFunda.s),
                    ...item.daftarPelajaran.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final (pel, statusPel) = entry.value;
                      return _BarisPelajaranSheet(
                        pel: pel,
                        statusPel: statusPel,
                        nomorUrut: idx + 1,
                        modulTerkunci: modulTerkunci,
                        warnaAksen: tema.aksen,
                        padaBuka: () {
                          Navigator.pop(context);
                          context.push(
                            '/belajar/pelajaran/${pel.modulId}/${pel.id}',
                          );
                        },
                      );
                    }),
                    const SizedBox(height: SpasiFunda.s),
                    _KartuKuisAkhirSheet(item: item),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Kotak informasi syarat gerbang data + tombol lengkapi data & pernyataan kosong.
class KotakSyaratBelajar extends ConsumerWidget {
  final List<String> daftarPesan;
  final String? ruteAksi;
  final List<String> daftarAtauPernyataan;

  const KotakSyaratBelajar({
    super.key,
    required this.daftarPesan,
    this.ruteAksi,
    this.daftarAtauPernyataan = const [],
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(SpasiFunda.m),
      decoration: BoxDecoration(
        color: WarnaFunda.tintAmber,
        borderRadius: BorderRadius.circular(SudutFunda.kartu),
        border: Border.all(color: WarnaFunda.batasAmber),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                LucideIcons.info,
                size: 16,
                color: WarnaFunda.peringatan,
              ),
              const SizedBox(width: SpasiFunda.s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: daftarPesan
                      .map(
                        (pesan) => Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: TeksFunda.catatan(
                            pesan,
                            warna: WarnaFunda.teks,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
          if (ruteAksi != null) ...[
            const SizedBox(height: SpasiFunda.s),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  side: const BorderSide(color: WarnaFunda.utama),
                  backgroundColor: WarnaFunda.permukaan,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SudutFunda.pil),
                  ),
                ),
                onPressed: () {
                  Navigator.maybePop(context);
                  context.push(ruteAksi!);
                },
                icon: const Icon(
                  LucideIcons.arrowRight,
                  size: 16,
                  color: WarnaFunda.utama,
                ),
                label: const TeksFunda.label(
                  'Lengkapi Data Sekarang',
                  warna: WarnaFunda.utama,
                ),
              ),
            ),
          ],
          if (daftarAtauPernyataan.isNotEmpty) ...[
            const SizedBox(height: SpasiFunda.xs),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                onPressed: () async {
                  final kunci = daftarAtauPernyataan.first;
                  final repo = ref.read(penyediaPernyataanRepositori);
                  final pernyataanSaatIni =
                      ref.read(penyediaStreamPernyataan).asData?.value ??
                      const <String, String>{};
                  if (pernyataanSaatIni[kunci] == 'true') {
                    await repo.hapusPernyataan(kunci);
                  } else {
                    await repo.simpanPernyataan(kunci, 'true');
                  }
                  ref.invalidate(penyediaFotoData);
                },
                child: const TeksFunda.catatan(
                  'Aku tidak punya ini',
                  warna: WarnaFunda.teksRedup,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BangunBannerPernyataanModul extends ConsumerWidget {
  final String modulId;

  const _BangunBannerPernyataanModul({required this.modulId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = switch (modulId) {
      'utang_cicilan' => (
        'tidak_punya_utang',
        'Kamu menyatakan tidak punya utang.',
      ),
      'penghasilan_tambahan' => (
        'baru_satu_sumber',
        'Kamu menyatakan baru punya satu sumber penghasilan.',
      ),
      'keuangan_usaha_kecil' => (
        'belum_punya_usaha',
        'Kamu menyatakan belum punya usaha saat ini.',
      ),
      _ => null,
    };

    if (config == null) return const SizedBox.shrink();

    final pernyataanAsync = ref.watch(penyediaStreamPernyataan);
    return pernyataanAsync.when(
      data: (pernyataan) {
        if (pernyataan[config.$1] != 'true') return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.only(top: SpasiFunda.s),
          padding: const EdgeInsets.symmetric(
            horizontal: SpasiFunda.m,
            vertical: SpasiFunda.s,
          ),
          decoration: BoxDecoration(
            color: WarnaFunda.tintBiru,
            borderRadius: BorderRadius.circular(SudutFunda.kecil),
          ),
          child: Row(
            children: [
              const Icon(LucideIcons.info, size: 16, color: WarnaFunda.utama),
              const SizedBox(width: SpasiFunda.s),
              Expanded(
                child: TeksFunda.catatan(config.$2, warna: WarnaFunda.teks),
              ),
              TextButton(
                style: TextButton.styleFrom(minimumSize: const Size(48, 36)),
                onPressed: () async {
                  await ref
                      .read(penyediaPernyataanRepositori)
                      .hapusPernyataan(config.$1);
                  ref.invalidate(penyediaFotoData);
                },
                child: const TeksFunda.catatan(
                  'Cabut pernyataan',
                  warna: WarnaFunda.utama,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _BarisPelajaranSheet extends StatelessWidget {
  final PelajaranKonten pel;
  final HasilStatusBelajar statusPel;
  final int nomorUrut;
  final bool modulTerkunci;
  final Color warnaAksen;
  final VoidCallback padaBuka;

  const _BarisPelajaranSheet({
    required this.pel,
    required this.statusPel,
    required this.nomorUrut,
    required this.modulTerkunci,
    required this.warnaAksen,
    required this.padaBuka,
  });

  @override
  Widget build(BuildContext context) {
    final status = statusPel.status;
    final isTerkunci = status == StatusBelajar.terkunci;
    final tampilkanSyarat =
        isTerkunci && !modulTerkunci && statusPel.apaYangKurang.isNotEmpty;

    return Opacity(
      opacity: isTerkunci ? 0.72 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: SpasiFunda.s),
        padding: const EdgeInsets.all(SpasiFunda.m),
        decoration: BoxDecoration(
          color: isTerkunci ? WarnaFunda.tintNetral : WarnaFunda.permukaan,
          borderRadius: BorderRadius.circular(SudutFunda.kartu),
          border: Border.all(
            color: status == StatusBelajar.sedang
                ? warnaAksen
                : WarnaFunda.garis,
            width: status == StatusBelajar.sedang ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _ikonNomorStatus(status, nomorUrut, warnaAksen),
                const SizedBox(width: SpasiFunda.s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TeksFunda.label(pel.judul),
                      const SizedBox(height: 2),
                      TeksFunda.catatan(
                        '${pel.durasiMenit} menit',
                        warna: WarnaFunda.teksRedup,
                      ),
                    ],
                  ),
                ),
                if (!isTerkunci)
                  TombolFunda(
                    teks: status == StatusBelajar.selesai
                        ? 'Baca Ulang'
                        : (status == StatusBelajar.sedang ? 'Lanjut' : 'Mulai'),
                    padaTekan: padaBuka,
                  ),
              ],
            ),
            if (tampilkanSyarat) ...[
              const SizedBox(height: SpasiFunda.s),
              KotakSyaratBelajar(
                daftarPesan: statusPel.apaYangKurang,
                ruteAksi: statusPel.ruteAksi,
                daftarAtauPernyataan: statusPel.daftarAtauPernyataan,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _ikonNomorStatus(
    StatusBelajar status,
    int nomorUrut,
    Color warnaAksen,
  ) {
    return switch (status) {
      StatusBelajar.selesai => Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
          color: WarnaFunda.tintHijau,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          LucideIcons.check,
          size: 16,
          color: WarnaFunda.pemasukan,
        ),
      ),
      StatusBelajar.sedang => Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
          color: WarnaFunda.tintBiru,
          shape: BoxShape.circle,
        ),
        child: Icon(LucideIcons.play, size: 16, color: warnaAksen),
      ),
      StatusBelajar.terbuka => Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
          color: WarnaFunda.tintBiru,
          shape: BoxShape.circle,
        ),
        child: Icon(LucideIcons.bookOpen, size: 16, color: warnaAksen),
      ),
      StatusBelajar.terkunci => Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: WarnaFunda.permukaan,
          shape: BoxShape.circle,
          border: Border.all(color: WarnaFunda.garis),
        ),
        child: TeksFunda.catatan('$nomorUrut', warna: WarnaFunda.teksRedup),
      ),
    };
  }
}

class _KartuKuisAkhirSheet extends StatelessWidget {
  final ItemPetaModul item;

  const _KartuKuisAkhirSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    final modul = item.modul;
    final kuis = modul.kuis;
    if (kuis.jumlahSoal <= 0) return const SizedBox.shrink();

    final semuaSelesai = item.daftarPelajaran.every(
      (p) => p.$2.status == StatusBelajar.selesai,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SpasiFunda.m),
      decoration: BoxDecoration(
        color: semuaSelesai ? WarnaFunda.utamaTipis : WarnaFunda.tintNetral,
        borderRadius: BorderRadius.circular(SudutFunda.kartu),
        border: Border.all(
          color: semuaSelesai ? WarnaFunda.utama : WarnaFunda.garis,
        ),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.helpCircle,
            color: semuaSelesai ? WarnaFunda.utama : WarnaFunda.teksRedup,
          ),
          const SizedBox(width: SpasiFunda.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TeksFunda.label(
                  'Kuis Akhir Modul (${kuis.jumlahSoal} Soal)',
                  warna: semuaSelesai ? WarnaFunda.utama : WarnaFunda.teksRedup,
                ),
                const SizedBox(height: 2),
                TeksFunda.catatan(
                  semuaSelesai
                      ? 'Uji pemahamanmu untuk menuntaskan modul ini (minimal 70%).'
                      : 'Terbuka setelah seluruh pelajaran modul ini selesai.',
                  warna: WarnaFunda.teksRedup,
                ),
              ],
            ),
          ),
          const SizedBox(width: SpasiFunda.s),
          TombolFunda(
            teks: 'Mulai Kuis',
            padaTekan: semuaSelesai
                ? () {
                    Navigator.pop(context);
                    context.push('/belajar/kuis/${modul.id}');
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
