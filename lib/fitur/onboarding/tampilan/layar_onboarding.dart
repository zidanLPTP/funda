import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/penyedia_basis_data.dart';
import '../../../komponen/komponen_funda.dart';
import '../../../tema/token.dart';
import '../../../util/haptic.dart';

/// Model kartu edukatif pengantar nilai dasar dan sambutan Funda.
class ItemSlideOnboarding {
  final String tag;
  final String judul;
  final String deskripsi;
  final Color kanvas;
  final Color warnaTag;
  final String pathSvg;

  const ItemSlideOnboarding({
    required this.tag,
    required this.judul,
    required this.deskripsi,
    required this.kanvas,
    required this.warnaTag,
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
      tag: 'Privasi Penuh (Offline-First)',
      judul: 'Datamu 100% Milikmu, Tersimpan di HP-mu',
      deskripsi:
          'Funda tidak punya server backend dan tidak mengirimkan datamu ke mana pun. Seluruh catatan keuangan dan refleksi tersimpan privat di perangkatmu.',
      kanvas: WarnaFunda.kanvasMint,
      warnaTag: WarnaFunda.pemasukan,
      pathSvg: AsetIlustrasiFunda.privasiLokal,
    ),
    ItemSlideOnboarding(
      tag: 'Belajar Sambil Praktik',
      judul: '18 Modul Finansial Berbasis Uang Nyatamu',
      deskripsi:
          'Kuasai fondasi uang dari dasar sampai mahir. Pelajaran micro-learning berujung pada misi praktik yang langsung melatih datamu sendiri.',
      kanvas: WarnaFunda.kanvasBiru,
      warnaTag: WarnaFunda.info,
      pathSvg: AsetIlustrasiFunda.mulaiTesAwal,
    ),
    ItemSlideOnboarding(
      tag: 'Tanpa Penghakiman',
      judul: 'Ruang Tenang Menata dan Memahami Arus Kas',
      deskripsi:
          'Tidak ada label pelit atau boros. Funda membantumu melihat ke mana uang mengalir dengan jernih, tenang, dan memberdayakan.',
      kanvas: WarnaFunda.kanvasUngu,
      warnaTag: WarnaFunda.sifatKeinginan,
      pathSvg: AsetIlustrasiFunda.psikologiUang,
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
              // Baris Header Editorial: Kembali (bila dibuka dari dalam app), Logo Funda, & Pil Lewati
              Padding(
                padding: const EdgeInsets.symmetric(vertical: SpasiFunda.m),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (bisaKembali) ...[
                            TombolKembaliEditorial(
                              padaTekan: () => Navigator.maybePop(context),
                            ),
                            const SizedBox(width: SpasiFunda.s),
                          ],
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              SudutFunda.kecil,
                            ),
                            child: Image.asset(
                              'aset/gambar/app_icon_512.png',
                              width: 30,
                              height: 30,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: SpasiFunda.s),
                          const Flexible(child: TeksFunda.judulBagian('Funda')),
                        ],
                      ),
                    ),
                    if (_indeksHalaman < _daftarSlide.length - 1) ...[
                      const SizedBox(width: SpasiFunda.s),
                      TombolPilHeaderEditorial(
                        teks: 'Lewati',
                        padaTekan: _selesaikanOnboarding,
                      ),
                    ],
                  ],
                ),
              ),

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
                              // Kanvas Atas Berwarna Cerah + Tag Pill + Ilustrasi SVG
                              Container(
                                color: slide.kanvas,
                                padding: const EdgeInsets.all(SpasiFunda.l),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: SpasiFunda.m,
                                        vertical: SpasiFunda.xs,
                                      ),
                                      decoration: BoxDecoration(
                                        color: WarnaFunda.permukaan,
                                        borderRadius: BorderRadius.circular(
                                          SudutFunda.pil,
                                        ),
                                        border: Border.all(
                                          color: WarnaFunda.garis,
                                          width: 1.0,
                                        ),
                                      ),
                                      child: TeksFunda.catatan(
                                        slide.tag,
                                        warna: slide.warnaTag,
                                      ),
                                    ),
                                    if (!isTeksBesar) ...[
                                      const SizedBox(height: SpasiFunda.m),
                                      Center(
                                        child: IlustrasiSvgFunda(
                                          pathAset: slide.pathSvg,
                                          tinggi: 132,
                                        ),
                                      ),
                                    ],
                                  ],
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
