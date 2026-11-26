import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/penyedia_basis_data.dart';
import '../../../komponen/komponen_funda.dart';
import '../../../tema/token.dart';
import '../../../util/haptic.dart';

/// Model kartu edukatif pengantar nilai dasar dan sambutan Funda.
class ItemSlideOnboarding {
  final String judul;
  final String deskripsi;
  final Color kanvas;
  final String pathSvg;

  const ItemSlideOnboarding({
    required this.judul,
    required this.deskripsi,
    required this.kanvas,
    required this.pathSvg,
  });
}

/// Layar Nilai Dasar & Sambutan Pengguna Baru bergaya editorial bersih.
class LayarOnboarding extends ConsumerStatefulWidget {
  const LayarOnboarding({super.key});

  @override
  ConsumerState<LayarOnboarding> createState() => _LayarOnboardingState();
}

class _LayarOnboardingState extends ConsumerState<LayarOnboarding> {
  final PageController _pengontrolHalaman = PageController();
  int _indeksHalaman = 0;

  static const _daftarSlide = [
    ItemSlideOnboarding(
      judul: 'Data 100% Milikmu',
      deskripsi:
          'Semua catatan dan refleksimu tersimpan privat di HP ini, tanpa server atau pengiriman data keluar.',
      kanvas: WarnaFunda.kanvasMint,
      pathSvg: AsetIlustrasiFunda.privasiLokal,
    ),
    ItemSlideOnboarding(
      judul: 'Belajar dari Uang Nyatamu',
      deskripsi:
          '18 modul singkat yang langsung dipraktikkan memakai catatan keuanganmu sendiri.',
      kanvas: WarnaFunda.kanvasBiru,
      pathSvg: AsetIlustrasiFunda.mulaiTesAwal,
    ),
    ItemSlideOnboarding(
      judul: 'Ruang Tenang Menata Uang',
      deskripsi: 'Pahami arah arus kasmu dengan jelas.',
      kanvas: WarnaFunda.kanvasUngu,
      pathSvg: AsetIlustrasiFunda.ruangTenang,
    ),
  ];

  Future<void> _selesaikanOnboarding() async {
    UtilHaptic.sukses();
    final db = ref.read(penyediaBasisData);
    await db.simpanPengaturan('onboarding_selesai', 'true');
    if (!mounted) return;
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      return;
    }
    final router = GoRouter.maybeOf(context);
    if (router != null) {
      context.go('/');
    }
  }

  void _halamanBerikutnya() {
    UtilHaptic.pilih();
    if (_indeksHalaman < _daftarSlide.length - 1) {
      _pengontrolHalaman.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } else {
      _selesaikanOnboarding();
    }
  }

  @override
  void dispose() {
    _pengontrolHalaman.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTeksBesar = MediaQuery.textScalerOf(context).scale(1.0) > 1.3;
    final bisaKembali = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: WarnaFunda.latar,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SpasiFunda.marginLayar,
          ),
          child: Column(
            children: [
              if (bisaKembali)
                Padding(
                  padding: const EdgeInsets.only(top: SpasiFunda.m),
                  child: HeaderSubLayarEditorial(
                    judul: 'Panduan Nilai Funda',
                    padaKembali: () => Navigator.maybePop(context),
                  ),
                )
              else
                const SizedBox(height: SpasiFunda.l),

              // PageView Kartu Editorial
              Expanded(
                child: PageView.builder(
                  controller: _pengontrolHalaman,
                  onPageChanged: (indeks) {
                    setState(() => _indeksHalaman = indeks);
                  },
                  itemCount: _daftarSlide.length,
                  itemBuilder: (context, indeks) {
                    final slide = _daftarSlide[indeks];
                    return Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          vertical: SpasiFunda.xs,
                        ),
                        child: Container(
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
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (!isTeksBesar)
                                Container(
                                  color: slide.kanvas,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: SpasiFunda.l,
                                    vertical: SpasiFunda.xl,
                                  ),
                                  child: Center(
                                    child: IlustrasiSvgFunda(
                                      pathAset: slide.pathSvg,
                                      tinggi: 140,
                                    ),
                                  ),
                                ),

                              // Area Baca Putih Bersih
                              Padding(
                                padding: const EdgeInsets.all(SpasiFunda.xl),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TeksFunda.judulLayar(slide.judul),
                                    const SizedBox(height: SpasiFunda.m),
                                    TeksFunda.isi(
                                      slide.deskripsi,
                                      warna: WarnaFunda.teksRedup,
                                      rataTeks: TextAlign.start,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Baris Bawah: Indikator Titik & Tombol Pil Gelap
              Padding(
                padding: const EdgeInsets.symmetric(vertical: SpasiFunda.l),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_daftarSlide.length, (i) {
                        final aktif = i == _indeksHalaman;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: aktif ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: aktif
                                ? WarnaFunda.tombolGelap
                                : WarnaFunda.garis,
                            borderRadius: BorderRadius.circular(SudutFunda.pil),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: SpasiFunda.l),
                    TombolFunda.pilGelap(
                      key: const Key('tombol_aksi_onboarding'),
                      lebarPenuh: true,
                      teks: _indeksHalaman == _daftarSlide.length - 1
                          ? 'Mulai Jelajahi Funda'
                          : 'Lanjut',
                      padaTekan: _halamanBerikutnya,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
