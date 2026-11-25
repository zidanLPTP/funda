import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../komponen/komponen_funda.dart';
import '../../../perhitungan/perhitungan_belajar.dart';
import '../../../tema/token.dart';
import '../kontroler/penyedia_belajar.dart';

/// Halaman detail modul penuh bergaya editorial micro-learning:
/// kanvas ilustrasi pastel di atas, daftar materi timeline bersih, dan 1 tombol pil gelap di bawah.
class LayarDetailModul extends ConsumerWidget {
  final String modulId;

  const LayarDetailModul({super.key, required this.modulId});

  void _navigasiRute(BuildContext context, String rute) {
    final router = GoRouter.maybeOf(context);
    if (router != null) {
      router.push(rute);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petaAsync = ref.watch(penyediaPetaBelajar);
    final profilSudahAda =
        ref.watch(penyediaStreamProfilKeuangan).asData?.value != null;
    final teksBesar = MediaQuery.textScalerOf(context).scale(1) >= 1.5;

    return Scaffold(
      backgroundColor: WarnaFunda.permukaan,
      body: petaAsync.when(
        loading: () =>
            const Center(child: IndikatorMemuat(warna: WarnaFunda.utama)),
        error: (err, _) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(SpasiFunda.l),
            child: KeadaanKosong(
              ikon: LucideIcons.circleAlert,
              judul: 'Gagal Memuat Modul',
              pesan: 'Terjadi kendala saat membuka detail modul: $err',
              teksTombol: 'Kembali',
              padaAksi: () => Navigator.pop(context),
            ),
          ),
        ),
        data: (daftarItem) {
          final item = daftarItem
              .where((m) => m.modul.id == modulId)
              .firstOrNull;
          if (item == null) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(SpasiFunda.l),
                child: KeadaanKosong(
                  ikon: LucideIcons.bookOpen,
                  judul: 'Modul Tidak Ditemukan',
                  pesan: 'Materi untuk modul ini tidak tersedia.',
                  teksTombol: 'Kembali',
                  padaAksi: () => Navigator.pop(context),
                ),
              ),
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
          final jumlahSelesai = item.daftarPelajaran
              .where((p) => p.$2.status == StatusBelajar.selesai)
              .length;
          final totalPelajaran = item.daftarPelajaran.length;

          final String labelProgres;
          if (modul.id == 'mulai_tes_awal') {
            labelProgres = profilSudahAda ? 'Profil tersimpan' : 'Belum diisi';
          } else if (!modul.tersedia) {
            labelProgres = 'Segera Hadir';
          } else {
            labelProgres = '$jumlahSelesai dari $totalPelajaran selesai';
          }

          final aksiBawah = _tentukanAksiUtama(
            context,
            item: item,
            profilSudahAda: profilSudahAda,
            statusModul: statusModul,
          );

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kanvas Header Ilustrasi Pastel Cerah + Tombol Kembali Bulat
                      Container(
                        key: const Key('header_kanvas_detail_modul'),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: tema.kanvas,
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(SudutFunda.petak),
                          ),
                        ),
                        child: SafeArea(
                          bottom: false,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                              SpasiFunda.l,
                              SpasiFunda.s,
                              SpasiFunda.l,
                              SpasiFunda.l,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Semantics(
                                      button: true,
                                      label: 'Kembali',
                                      child: InkWell(
                                        key: const Key(
                                          'tombol_kembali_detail_modul',
                                        ),
                                        onTap: () => Navigator.pop(context),
                                        borderRadius: BorderRadius.circular(
                                          SudutFunda.pil,
                                        ),
                                        child: Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: WarnaFunda.permukaan,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: WarnaFunda.garis,
                                            ),
                                          ),
                                          child: const Icon(
                                            LucideIcons.arrowLeft,
                                            size: 20,
                                            color: WarnaFunda.teks,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: SpasiFunda.m,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: WarnaFunda.permukaan,
                                        borderRadius: BorderRadius.circular(
                                          SudutFunda.pil,
                                        ),
                                      ),
                                      child: TeksFunda.catatan(
                                        'Modul ${modul.urutan}',
                                        warna: tema.aksen,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: SpasiFunda.s),
                                IlustrasiSvgFunda(
                                  pathAset: tema.pathSvg,
                                  tinggi: teksBesar ? 92 : 124,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Area Ringkasan & Daftar Materi Timeline Editorial
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          SpasiFunda.xl,
                          SpasiFunda.l,
                          SpasiFunda.xl,
                          SpasiFunda.xxl,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: SpasiFunda.s,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: WarnaFunda.tintNetral,
                                borderRadius: BorderRadius.circular(
                                  SudutFunda.pil,
                                ),
                              ),
                              child: TeksFunda.catatan(
                                labelProgres,
                                warna: WarnaFunda.teksRedup,
                              ),
                            ),
                            const SizedBox(height: SpasiFunda.s),
                            TeksFunda.judulLayar(modul.judul),
                            const SizedBox(height: SpasiFunda.s),
                            Text(
                              modul.deskripsiSingkat,
                              style: TipografiFunda.isiKecil.copyWith(
                                height: 1.5,
                                color: WarnaFunda.teksRedup,
                              ),
                            ),

                            // Status pernyataan relevan per modul (Utang, Tambahan, Usaha)
                            _BangunBannerPernyataanModul(modulId: modul.id),

                            if (modul.id == 'mulai_tes_awal') ...[
                              const SizedBox(height: SpasiFunda.l),
                              if (profilSudahAda)
                                Container(
                                  padding: const EdgeInsets.all(SpasiFunda.l),
                                  decoration: BoxDecoration(
                                    color: WarnaFunda.tintHijau,
                                    borderRadius: BorderRadius.circular(
                                      SudutFunda.kartu,
                                    ),
                                    border: Border.all(
                                      color: WarnaFunda.batasHijau,
                                    ),
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                ),
                            ] else if (!modul.tersedia) ...[
                              const SizedBox(height: SpasiFunda.l),
                              Container(
                                padding: const EdgeInsets.all(SpasiFunda.l),
                                decoration: BoxDecoration(
                                  color: WarnaFunda.tintNetral,
                                  borderRadius: BorderRadius.circular(
                                    SudutFunda.kartu,
                                  ),
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
                                const SizedBox(height: SpasiFunda.l),
                                KotakSyaratBelajar(
                                  daftarPesan: statusModul.apaYangKurang,
                                  ruteAksi: statusModul.ruteAksi,
                                  daftarAtauPernyataan:
                                      statusModul.daftarAtauPernyataan,
                                ),
                              ],
                              const SizedBox(height: SpasiFunda.xl),
                              const TeksFunda.catatan(
                                'Rangkaian Materi',
                                warna: WarnaFunda.teksRedup,
                              ),
                              const SizedBox(height: SpasiFunda.m),
                              ...item.daftarPelajaran.asMap().entries.map((
                                entry,
                              ) {
                                final idx = entry.key;
                                final (pel, statusPel) = entry.value;
                                final adaKuisSetelahnya =
                                    modul.kuis.jumlahSoal > 0;
                                final itemTerakhir =
                                    idx == item.daftarPelajaran.length - 1 &&
                                    !adaKuisSetelahnya;

                                return _BarisTimelinePelajaran(
                                  pel: pel,
                                  statusPel: statusPel,
                                  nomorUrut: idx + 1,
                                  modulTerkunci: modulTerkunci,
                                  warnaAksen: tema.aksen,
                                  warnaKanvas: tema.kanvas,
                                  terhubungKeBawah: !itemTerakhir,
                                  padaBuka: () => _navigasiRute(
                                    context,
                                    '/belajar/pelajaran/${pel.modulId}/${pel.id}',
                                  ),
                                );
                              }),
                              if (modul.kuis.jumlahSoal > 0)
                                _BarisTimelineKuis(
                                  item: item,
                                  warnaAksen: tema.aksen,
                                  padaBukaKuis: () => _navigasiRute(
                                    context,
                                    '/belajar/kuis/${modul.id}',
                                  ),
                                ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Sticky Bottom CTA Pil Gelap Utama
              if (aksiBawah != null)
                Container(
                  padding: const EdgeInsets.fromLTRB(
                    SpasiFunda.xl,
                    SpasiFunda.m,
                    SpasiFunda.xl,
                    SpasiFunda.m,
                  ),
                  decoration: const BoxDecoration(
                    color: WarnaFunda.permukaan,
                    border: Border(top: BorderSide(color: WarnaFunda.garis)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: TombolFunda.pilGelap(
                      key: aksiBawah.kunci,
                      teks: aksiBawah.teks,
                      padaTekan: aksiBawah.padaTekan,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  _InfoAksiUtamaModul? _tentukanAksiUtama(
    BuildContext context, {
    required ItemPetaModul item,
    required bool profilSudahAda,
    required HasilStatusBelajar statusModul,
  }) {
    final modul = item.modul;
    if (modul.id == 'mulai_tes_awal') {
      if (profilSudahAda) return null;
      return _InfoAksiUtamaModul(
        kunci: const Key('tombol_buka_tes_awal'),
        teks: 'Buka Tes Awal',
        padaTekan: () => _navigasiRute(context, '/belajar/tes-awal'),
      );
    }

    if (!modul.tersedia) {
      return const _InfoAksiUtamaModul(
        kunci: Key('tombol_aksi_detail_modul'),
        teks: 'Segera Hadir',
        padaTekan: null,
      );
    }

    final pelSedang = item.daftarPelajaran
        .where((p) => p.$2.status == StatusBelajar.sedang)
        .map((p) => p.$1)
        .firstOrNull;
    if (pelSedang != null) {
      return _InfoAksiUtamaModul(
        kunci: const Key('tombol_aksi_detail_modul'),
        teks: 'Lanjut Belajar',
        padaTekan: () => _navigasiRute(
          context,
          '/belajar/pelajaran/${modul.id}/${pelSedang.id}',
        ),
      );
    }

    final pelTerbuka = item.daftarPelajaran
        .where((p) => p.$2.status == StatusBelajar.terbuka)
        .map((p) => p.$1)
        .firstOrNull;
    if (pelTerbuka != null) {
      return _InfoAksiUtamaModul(
        kunci: const Key('tombol_aksi_detail_modul'),
        teks: 'Mulai Belajar',
        padaTekan: () => _navigasiRute(
          context,
          '/belajar/pelajaran/${modul.id}/${pelTerbuka.id}',
        ),
      );
    }

    final semuaSelesai =
        item.daftarPelajaran.isNotEmpty &&
        item.daftarPelajaran.every((p) => p.$2.status == StatusBelajar.selesai);
    if (semuaSelesai && modul.kuis.jumlahSoal > 0) {
      return _InfoAksiUtamaModul(
        kunci: const Key('tombol_aksi_detail_modul'),
        teks: 'Mulai Kuis Akhir',
        padaTekan: () => _navigasiRute(context, '/belajar/kuis/${modul.id}'),
      );
    }

    if (semuaSelesai && item.daftarPelajaran.isNotEmpty) {
      final pelAwal = item.daftarPelajaran.first.$1;
      return _InfoAksiUtamaModul(
        kunci: const Key('tombol_aksi_detail_modul'),
        teks: 'Baca Ulang Materi',
        padaTekan: () => _navigasiRute(
          context,
          '/belajar/pelajaran/${modul.id}/${pelAwal.id}',
        ),
      );
    }

    if (statusModul.ruteAksi != null) {
      return _InfoAksiUtamaModul(
        kunci: const Key('tombol_aksi_detail_modul'),
        teks: 'Lengkapi Data Sekarang',
        padaTekan: () => _navigasiRute(context, statusModul.ruteAksi!),
      );
    }

    return null;
  }
}

class _InfoAksiUtamaModul {
  final Key kunci;
  final String teks;
  final VoidCallback? padaTekan;

  const _InfoAksiUtamaModul({
    required this.kunci,
    required this.teks,
    required this.padaTekan,
  });
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
                  final router = GoRouter.maybeOf(context);
                  if (router != null) {
                    router.push(ruteAksi!);
                  }
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
          margin: const EdgeInsets.only(top: SpasiFunda.m),
          padding: const EdgeInsets.symmetric(
            horizontal: SpasiFunda.m,
            vertical: SpasiFunda.s,
          ),
          decoration: BoxDecoration(
            color: WarnaFunda.tintBiru,
            borderRadius: BorderRadius.circular(SudutFunda.kartu),
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

class _BarisTimelinePelajaran extends StatelessWidget {
  final PelajaranKonten pel;
  final HasilStatusBelajar statusPel;
  final int nomorUrut;
  final bool modulTerkunci;
  final Color warnaAksen;
  final Color warnaKanvas;
  final bool terhubungKeBawah;
  final VoidCallback padaBuka;

  const _BarisTimelinePelajaran({
    required this.pel,
    required this.statusPel,
    required this.nomorUrut,
    required this.modulTerkunci,
    required this.warnaAksen,
    required this.warnaKanvas,
    required this.terhubungKeBawah,
    required this.padaBuka,
  });

  @override
  Widget build(BuildContext context) {
    final status = statusPel.status;
    final isTerkunci = status == StatusBelajar.terkunci;
    final tampilkanSyarat =
        isTerkunci && !modulTerkunci && statusPel.apaYangKurang.isNotEmpty;
    final nomorLabel = nomorUrut.toString().padLeft(2, '0');

    final String subteks = switch (status) {
      StatusBelajar.selesai => 'Selesai • ${pel.durasiMenit} menit',
      StatusBelajar.sedang => 'Lanjutkan • ${pel.durasiMenit} menit',
      StatusBelajar.terbuka => 'Siap dipelajari • ${pel.durasiMenit} menit',
      StatusBelajar.terkunci => '${pel.durasiMenit} menit',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: isTerkunci ? null : padaBuka,
          borderRadius: BorderRadius.circular(SudutFunda.kartu),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: SpasiFunda.xs),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 36,
                    child: Column(
                      children: [
                        _bangunNodeStatus(status, nomorLabel),
                        if (terhubungKeBawah)
                          Expanded(
                            child: Container(
                              width: 1.5,
                              margin: const EdgeInsets.only(top: 4),
                              color: status == StatusBelajar.selesai
                                  ? WarnaFunda.pemasukan.withAlpha(90)
                                  : WarnaFunda.garis,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: SpasiFunda.m),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: 2,
                        bottom: terhubungKeBawah ? SpasiFunda.l : SpasiFunda.s,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pel.judul,
                            style: TipografiFunda.label.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isTerkunci
                                  ? WarnaFunda.teksRedup
                                  : WarnaFunda.teks,
                            ),
                          ),
                          const SizedBox(height: 3),
                          TeksFunda.catatan(
                            subteks,
                            warna: status == StatusBelajar.sedang
                                ? warnaAksen
                                : WarnaFunda.teksRedup,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!isTerkunci)
                    const Padding(
                      padding: EdgeInsets.only(left: SpasiFunda.s, top: 6),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Icon(
                          LucideIcons.chevronRight,
                          size: 18,
                          color: WarnaFunda.teksRedup,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (tampilkanSyarat) ...[
          Padding(
            padding: const EdgeInsets.only(left: 48, bottom: SpasiFunda.m),
            child: KotakSyaratBelajar(
              daftarPesan: statusPel.apaYangKurang,
              ruteAksi: statusPel.ruteAksi,
              daftarAtauPernyataan: statusPel.daftarAtauPernyataan,
            ),
          ),
        ],
      ],
    );
  }

  Widget _bangunNodeStatus(StatusBelajar status, String nomorLabel) {
    return switch (status) {
      StatusBelajar.selesai => Container(
        width: 32,
        height: 32,
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
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: warnaKanvas,
          shape: BoxShape.circle,
          border: Border.all(color: warnaAksen, width: 1.5),
        ),
        child: Icon(LucideIcons.play, size: 15, color: warnaAksen),
      ),
      StatusBelajar.terbuka => Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: WarnaFunda.permukaan,
          shape: BoxShape.circle,
          border: Border.all(color: warnaAksen, width: 1.5),
        ),
        child: TeksFunda.catatan(nomorLabel, warna: warnaAksen),
      ),
      StatusBelajar.terkunci => Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: WarnaFunda.tintNetral,
          shape: BoxShape.circle,
          border: Border.all(color: WarnaFunda.garis),
        ),
        child: TeksFunda.catatan(nomorLabel, warna: WarnaFunda.teksRedup),
      ),
    };
  }
}

class _BarisTimelineKuis extends StatelessWidget {
  final ItemPetaModul item;
  final Color warnaAksen;
  final VoidCallback padaBukaKuis;

  const _BarisTimelineKuis({
    required this.item,
    required this.warnaAksen,
    required this.padaBukaKuis,
  });

  @override
  Widget build(BuildContext context) {
    final kuis = item.modul.kuis;
    final semuaSelesai = item.daftarPelajaran.every(
      (p) => p.$2.status == StatusBelajar.selesai,
    );

    return InkWell(
      onTap: semuaSelesai ? padaBukaKuis : null,
      borderRadius: BorderRadius.circular(SudutFunda.kartu),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: SpasiFunda.xs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: semuaSelesai
                    ? WarnaFunda.utamaTipis
                    : WarnaFunda.tintNetral,
                shape: BoxShape.circle,
                border: Border.all(
                  color: semuaSelesai ? WarnaFunda.utama : WarnaFunda.garis,
                ),
              ),
              child: Icon(
                LucideIcons.helpCircle,
                size: 16,
                color: semuaSelesai ? WarnaFunda.utama : WarnaFunda.teksRedup,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kuis Akhir Modul (${kuis.jumlahSoal} Soal)',
                    style: TipografiFunda.label.copyWith(
                      fontWeight: FontWeight.w600,
                      color: semuaSelesai
                          ? WarnaFunda.teks
                          : WarnaFunda.teksRedup,
                    ),
                  ),
                  const SizedBox(height: 3),
                  TeksFunda.catatan(
                    semuaSelesai
                        ? 'Minimal 70% untuk menuntaskan modul ini.'
                        : 'Selesaikan seluruh pelajaran untuk membuka kuis.',
                    warna: semuaSelesai
                        ? WarnaFunda.utama
                        : WarnaFunda.teksRedup,
                  ),
                ],
              ),
            ),
            if (semuaSelesai)
              const Padding(
                padding: EdgeInsets.only(left: SpasiFunda.s, top: 6),
                child: Icon(
                  LucideIcons.chevronRight,
                  size: 18,
                  color: WarnaFunda.utama,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
