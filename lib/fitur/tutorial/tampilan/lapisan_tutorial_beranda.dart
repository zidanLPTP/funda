import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../komponen/ilustrasi_funda.dart';
import '../../../komponen/indikator_memuat.dart';
import '../../../komponen/teks_funda.dart';
import '../../../komponen/tombol_funda.dart';
import '../../../tema/token.dart';
import '../../../util/haptic.dart';

/// Data satu langkah pada tutorial interaktif Beranda.
class ItemSorotanTutorial {
  const ItemSorotanTutorial({
    required this.judul,
    required this.deskripsi,
    required this.ikon,
    required this.warnaAksen,
    required this.warnaLatarIkon,
    this.pathSvg,
    this.kunciTarget,
  });

  final String judul;
  final String deskripsi;
  final IconData ikon;
  final Color warnaAksen;
  final Color warnaLatarIkon;
  final String? pathSvg;
  final GlobalKey? kunciTarget;
}

/// Lapisan coachmark / spotlight interaktif 4 langkah bergaya editorial bersih.
class LapisanTutorialBeranda extends ConsumerStatefulWidget {
  const LapisanTutorialBeranda({
    super.key,
    required this.daftarLangkah,
    required this.padaSelesai,
    required this.padaLewati,
  });

  final List<ItemSorotanTutorial> daftarLangkah;
  final VoidCallback padaSelesai;
  final VoidCallback padaLewati;

  @override
  ConsumerState<LapisanTutorialBeranda> createState() =>
      _LapisanTutorialBerandaState();
}

class _LapisanTutorialBerandaState
    extends ConsumerState<LapisanTutorialBeranda> {
  int _indeks = 0;
  Rect? _kotakSorotan;

  @override
  void initState() {
    super.initState();
    _jadwalUkurSorotan();
  }

  @override
  void didUpdateWidget(covariant LapisanTutorialBeranda oldWidget) {
    super.didUpdateWidget(oldWidget);
    _jadwalUkurSorotan();
  }

  void _jadwalUkurSorotan() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _ukurSorotanSekarang();
    });
  }

  void _ukurSorotanSekarang() {
    if (_indeks < 0 || _indeks >= widget.daftarLangkah.length) return;
    final targetKey = widget.daftarLangkah[_indeks].kunciTarget;
    final ctxTarget = targetKey?.currentContext;
    final renderLayar = context.findRenderObject() as RenderBox?;
    if (ctxTarget == null || renderLayar == null || !renderLayar.hasSize) {
      if (_kotakSorotan != null) {
        setState(() => _kotakSorotan = null);
      }
      return;
    }

    final renderTarget = ctxTarget.findRenderObject() as RenderBox?;
    if (renderTarget == null || !renderTarget.hasSize) return;

    final offsetGlobal = renderTarget.localToGlobal(
      Offset.zero,
      ancestor: renderLayar,
    );
    final rectBaru = offsetGlobal & renderTarget.size;

    if (_kotakSorotan != rectBaru) {
      setState(() {
        _kotakSorotan = rectBaru;
      });
    }
  }

  void _langkahBerikutnya() {
    UtilHaptic.pilih();
    if (_indeks < widget.daftarLangkah.length - 1) {
      setState(() {
        _indeks++;
      });
      _jadwalUkurSorotan();
    } else {
      UtilHaptic.sukses();
      widget.padaSelesai();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tanpaAnimasi =
        MediaQuery.disableAnimationsOf(context) ||
        ref.watch(penyediaTanpaAnimasi);
    final total = widget.daftarLangkah.length;
    final langkah = widget.daftarLangkah[_indeks];
    final ukuranLayar = MediaQuery.sizeOf(context);
    final teksBesar = MediaQuery.textScalerOf(context).scale(1.0) > 1.3;

    // Tentukan penempatan kartu agar tidak menutupi area sorotan
    final targetDiBawah =
        _kotakSorotan != null &&
        _kotakSorotan!.center.dy > ukuranLayar.height * 0.55;

    final durasi = tanpaAnimasi
        ? Duration.zero
        : const Duration(milliseconds: 220);

    return Positioned.fill(
      child: Material(
        type: MaterialType.transparency,
        child: Semantics(
          container: true,
          label: 'Tutorial penggunaan Funda langkah ${_indeks + 1} dari $total',
          child: Stack(
            children: [
              // Latar belakang gelap semi-transparan dengan lubang spotlight
              GestureDetector(
                onTap: () {},
                behavior: HitTestBehavior.opaque,
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _PelukisSorotan(
                    kotakSorotan: _kotakSorotan,
                    warnaAksen: langkah.warnaAksen,
                  ),
                ),
              ),

              // Kartu Penjelasan Tutorial Bergaya Editorial
              SafeArea(
                child: Align(
                  alignment: targetDiBawah
                      ? Alignment.bottomCenter
                      : Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      SpasiFunda.l,
                      SpasiFunda.l,
                      SpasiFunda.l,
                      targetDiBawah && _kotakSorotan != null
                          ? (ukuranLayar.height - _kotakSorotan!.top + 16)
                                .clamp(24.0, ukuranLayar.height * 0.45)
                          : SpasiFunda.xl,
                    ),
                    child: AnimatedSwitcher(
                      duration: durasi,
                      transitionBuilder: (child, anim) {
                        if (tanpaAnimasi) return child;
                        return FadeTransition(
                          opacity: anim,
                          child: ScaleTransition(
                            scale: Tween<double>(
                              begin: 0.96,
                              end: 1.0,
                            ).animate(anim),
                            child: child,
                          ),
                        );
                      },
                      child: ConstrainedBox(
                        key: ValueKey(_indeks),
                        constraints: BoxConstraints(
                          maxWidth: 420,
                          maxHeight:
                              ukuranLayar.height * (teksBesar ? 0.68 : 0.62),
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
                            boxShadow: const [
                              BoxShadow(
                                color: WarnaFunda.bayanganKartu,
                                blurRadius: 24,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Kanvas Atas Editorial (indikator langkah, Lewati, & ilustrasi)
                                Container(
                                  color: langkah.warnaLatarIkon,
                                  padding: const EdgeInsets.fromLTRB(
                                    SpasiFunda.l,
                                    SpasiFunda.m,
                                    SpasiFunda.l,
                                    SpasiFunda.l,
                                  ),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: double.infinity,
                                        child: Wrap(
                                          alignment: WrapAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          spacing: SpasiFunda.s,
                                          runSpacing: SpasiFunda.xs,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: SpasiFunda.m,
                                                    vertical: SpasiFunda.xs,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: WarnaFunda.permukaan,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      SudutFunda.pil,
                                                    ),
                                                border: Border.all(
                                                  color: WarnaFunda.garis,
                                                  width: 1.0,
                                                ),
                                              ),
                                              child: TeksFunda.catatan(
                                                '${_indeks + 1}/$total',
                                                warna: WarnaFunda.teks,
                                              ),
                                            ),
                                            TextButton(
                                              key: const Key(
                                                'tombol_lewati_tutorial',
                                              ),
                                              style: TextButton.styleFrom(
                                                backgroundColor:
                                                    WarnaFunda.permukaan,
                                                minimumSize: const Size(48, 48),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: SpasiFunda.m,
                                                      vertical: SpasiFunda.s,
                                                    ),
                                                shape: StadiumBorder(
                                                  side: BorderSide(
                                                    color: WarnaFunda.garis,
                                                    width: 1.0,
                                                  ),
                                                ),
                                              ),
                                              onPressed: () {
                                                UtilHaptic.pilih();
                                                widget.padaLewati();
                                              },
                                              child: const TeksFunda.label(
                                                'Lewati',
                                                warna: WarnaFunda.teks,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (!teksBesar) ...[
                                        const SizedBox(height: SpasiFunda.s),
                                        if (langkah.pathSvg != null)
                                          IlustrasiSvgFunda(
                                            pathAset: langkah.pathSvg!,
                                            tinggi: 84,
                                          )
                                        else
                                          Icon(
                                            langkah.ikon,
                                            color: langkah.warnaAksen,
                                            size: 40,
                                          ),
                                      ],
                                    ],
                                  ),
                                ),

                                // Isi Penjelasan & Tombol Pil Gelap
                                Padding(
                                  padding: const EdgeInsets.all(SpasiFunda.l),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (teksBesar) ...[
                                        Row(
                                          children: [
                                            Icon(
                                              langkah.ikon,
                                              color: langkah.warnaAksen,
                                              size: 22,
                                            ),
                                            const SizedBox(width: SpasiFunda.s),
                                            Expanded(
                                              child: TeksFunda.judulBagian(
                                                langkah.judul,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ] else
                                        TeksFunda.judulBagian(langkah.judul),
                                      const SizedBox(height: SpasiFunda.s),
                                      TeksFunda.isiKecil(
                                        langkah.deskripsi,
                                        warna: WarnaFunda.teksRedup,
                                        rataTeks: TextAlign.start,
                                      ),
                                      const SizedBox(height: SpasiFunda.l),

                                      // Indikator titik langkah
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: List.generate(total, (i) {
                                          final aktif = i == _indeks;
                                          return AnimatedContainer(
                                            duration: durasi,
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 4,
                                            ),
                                            width: aktif ? 22 : 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: aktif
                                                  ? WarnaFunda.tombolGelap
                                                  : WarnaFunda.garis,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    SudutFunda.pil,
                                                  ),
                                            ),
                                          );
                                        }),
                                      ),
                                      const SizedBox(height: SpasiFunda.m),

                                      // Tombol Lanjut / Mulai Pakai (Pil Gelap Editorial)
                                      TombolFunda.pilGelap(
                                        key: const Key(
                                          'tombol_lanjut_tutorial',
                                        ),
                                        lebarPenuh: true,
                                        teks: _indeks == total - 1
                                            ? 'Mulai Pakai'
                                            : 'Lanjut',
                                        padaTekan: _langkahBerikutnya,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PelukisSorotan extends CustomPainter {
  _PelukisSorotan({required this.kotakSorotan, required this.warnaAksen});

  final Rect? kotakSorotan;
  final Color warnaAksen;

  @override
  void paint(Canvas canvas, Size size) {
    final pathLayar = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final catGelap = Paint()
      ..color = WarnaFunda.hitam.withAlpha(180)
      ..style = PaintingStyle.fill;

    if (kotakSorotan == null) {
      canvas.drawPath(pathLayar, catGelap);
      return;
    }

    final rrectLubang = RRect.fromRectAndRadius(
      kotakSorotan!.inflate(6),
      const Radius.circular(SudutFunda.kartu),
    );
    final pathLubang = Path()..addRRect(rrectLubang);
    final pathGabungan = Path.combine(
      PathOperation.difference,
      pathLayar,
      pathLubang,
    );

    canvas.drawPath(pathGabungan, catGelap);

    final catBingkai = Paint()
      ..color = warnaAksen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawRRect(rrectLubang, catBingkai);
  }

  @override
  bool shouldRepaint(covariant _PelukisSorotan oldDelegate) {
    return oldDelegate.kotakSorotan != kotakSorotan ||
        oldDelegate.warnaAksen != warnaAksen;
  }
}
