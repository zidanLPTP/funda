import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../data/penyedia_basis_data.dart';
import '../../../komponen/komponen_funda.dart';
import '../../../tema/token.dart';
import '../../../util/haptic.dart';

/// Model kartu edukatif pengantar selamat datang Funda.
class ItemSlideOnboarding {
  final IconData ikon;
  final String tag;
  final String judul;
  final String deskripsi;
  final Color warnaTint;
  final Color warnaIkon;

  const ItemSlideOnboarding({
    required this.ikon,
    required this.tag,
    required this.judul,
    required this.deskripsi,
    required this.warnaTint,
    required this.warnaIkon,
  });
}

/// Layar Sambutan Pengguna Baru (Onboarding Soft Bento 3 Slide).
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
      ikon: LucideIcons.shieldCheck,
      tag: 'Privasi Penuh (Offline-First)',
      judul: 'Datamu 100% Milikmu, Tersimpan di HP-mu',
      deskripsi:
          'Funda tidak punya server backend dan tidak mengirimkan datamu ke mana pun. Seluruh catatan keuangan dan refleksi tersimpan privat di perangkatmu.',
      warnaTint: WarnaFunda.tintHijau,
      warnaIkon: WarnaFunda.pemasukan,
    ),
    ItemSlideOnboarding(
      ikon: LucideIcons.graduationCap,
      tag: 'Belajar Sambil Praktik',
      judul: '18 Modul Finansial Berbasis Uang Nyatamu',
      deskripsi:
          'Kuasai fondasi uang dari dasar sampai mahir. Pelajaran micro-learning berujung pada misi praktik yang langsung melatih datamu sendiri.',
      warnaTint: WarnaFunda.tintBiru,
      warnaIkon: WarnaFunda.info,
    ),
    ItemSlideOnboarding(
      ikon: LucideIcons.heartHandshake,
      tag: 'Tanpa Penghakiman',
      judul: 'Ruang Tenang Menata dan Memahami Arus Kas',
      deskripsi:
          'Tidak ada label pelit atau boros. Funda membantumu melihat ke mana uang mengalir dengan jernih, tenang, dan memberdayakan.',
      warnaTint: WarnaFunda.tintUngu,
      warnaIkon: WarnaFunda.sifatKeinginan,
    ),
  ];

  Future<void> _selesaikanOnboarding() async {
    UtilHaptic.sukses();
    final db = ref.read(penyediaBasisData);
    await db.simpanPengaturan('onboarding_selesai', 'true');
    if (!mounted) return;
    context.go('/');
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
    return Scaffold(
      backgroundColor: WarnaFunda.latar,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SpasiFunda.marginLayar,
          ),
          child: Column(
            children: [
              // Baris Header: Logo & Tombol Lewati
              Padding(
                padding: const EdgeInsets.symmetric(vertical: SpasiFunda.m),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(SpasiFunda.xs),
                          decoration: BoxDecoration(
                            color: WarnaFunda.utama,
                            borderRadius: BorderRadius.circular(
                              SudutFunda.kecil,
                            ),
                          ),
                          child: const Icon(
                            LucideIcons.wallet,
                            color: WarnaFunda.putih,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: SpasiFunda.s),
                        const TeksFunda.judulBagian('Funda'),
                      ],
                    ),
                    if (_indeksHalaman < _daftarSlide.length - 1)
                      TextButton(
                        onPressed: _selesaikanOnboarding,
                        child: const TeksFunda.label(
                          'Lewati',
                          warna: WarnaFunda.teksRedup,
                        ),
                      ),
                  ],
                ),
              ),

              // PageView Kartu Bento
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
                        child: Container(
                          padding: const EdgeInsets.all(SpasiFunda.xl),
                          decoration: BoxDecoration(
                            color: WarnaFunda.permukaan,
                            borderRadius: BorderRadius.circular(
                              SudutFunda.petak,
                            ),
                            border: Border.all(color: WarnaFunda.garis),
                            boxShadow: const [
                              BoxShadow(
                                color: WarnaFunda.bayangan,
                                blurRadius: 16,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Kotak Ikon Bertint
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: slide.warnaTint,
                                  borderRadius: BorderRadius.circular(
                                    SudutFunda.kartu,
                                  ),
                                ),
                                child: Icon(
                                  slide.ikon,
                                  size: 32,
                                  color: slide.warnaIkon,
                                ),
                              ),
                              const SizedBox(height: SpasiFunda.l),

                              // Tag Kecil
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: SpasiFunda.s,
                                  vertical: SpasiFunda.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: slide.warnaTint,
                                  borderRadius: BorderRadius.circular(
                                    SudutFunda.pil,
                                  ),
                                ),
                                child: TeksFunda.catatan(
                                  slide.tag,
                                  warna: slide.warnaIkon,
                                ),
                              ),
                              const SizedBox(height: SpasiFunda.m),

                              // Judul Slide
                              TeksFunda.judulLayar(slide.judul),
                              const SizedBox(height: SpasiFunda.m),

                              // Deskripsi
                              TeksFunda.isi(
                                slide.deskripsi,
                                warna: WarnaFunda.teksRedup,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Baris Bawah: Indikator Titik & Tombol Lanjut
              Padding(
                padding: const EdgeInsets.symmetric(vertical: SpasiFunda.l),
                child: Column(
                  children: [
                    // Indikator Titik
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
                            color: aktif ? WarnaFunda.utama : WarnaFunda.garis,
                            borderRadius: BorderRadius.circular(SudutFunda.pil),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: SpasiFunda.xl),

                    // Tombol Aksi Bawah
                    TombolFunda.primer(
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
