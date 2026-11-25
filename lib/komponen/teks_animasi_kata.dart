import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../fitur/belajar/kontroler/penyedia_belajar.dart';
import '../fitur/belajar/model/pembaca_konten.dart';
import '../fitur/belajar/tampilan/komponen_teks_istilah.dart';
import '../tema/token.dart';
import 'indikator_memuat.dart';

/// Token kata hasil pemecahan paragraf untuk animasi kata demi kata.
class _TokenKataAnimasi {
  final String teks;
  final bool tebal;
  final String? kunciIstilah;

  const _TokenKataAnimasi({
    required this.teks,
    required this.tebal,
    this.kunciIstilah,
  });
}

/// Menampilkan teks materi muncul kata per kata dari bawah ke atas secara halus.
///
/// Mendukung markah `{{istilah}}` dan `**tebal**`, ketuk kapan saja untuk
/// menyelesaikan animasi seketika, serta langsung menampilkan hasil akhir tanpa ticker
/// apabila `penyediaTanpaAnimasi` atau `MediaQuery.disableAnimationsOf(context)` aktif.
class TeksAnimasiKata extends ConsumerStatefulWidget {
  final String teks;
  final TextStyle? gaya;
  final TextAlign rataTeks;
  final bool dukungIstilah;
  final VoidCallback? padaSelesai;

  const TeksAnimasiKata({
    super.key,
    required this.teks,
    this.gaya,
    this.rataTeks = TextAlign.start,
    this.dukungIstilah = true,
    this.padaSelesai,
  });

  @override
  ConsumerState<TeksAnimasiKata> createState() => _TeksAnimasiKataState();
}

class _TeksAnimasiKataState extends ConsumerState<TeksAnimasiKata>
    with SingleTickerProviderStateMixin {
  AnimationController? _pengontrol;
  bool _sudahSelesai = false;
  late List<_TokenKataAnimasi> _daftarToken;
  late Duration _durasiTotal;

  @override
  void initState() {
    super.initState();
    _daftarToken = _pecahJadiKata(widget.teks);
    _durasiTotal = _hitungDurasiTotal(_daftarToken.length);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sinkronkanStatusAnimasi();
  }

  @override
  void didUpdateWidget(covariant TeksAnimasiKata oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.teks != widget.teks) {
      _daftarToken = _pecahJadiKata(widget.teks);
      _durasiTotal = _hitungDurasiTotal(_daftarToken.length);
      _sudahSelesai = false;
      _pengontrol?.dispose();
      _pengontrol = null;
      _sinkronkanStatusAnimasi();
    }
  }

  Duration _hitungDurasiTotal(int jumlahKata) {
    if (jumlahKata <= 1) return const Duration(milliseconds: 220);
    // Jeda target 30-40ms per kata namun total animasi dibatasi maksimal ~1.200 ms.
    final estimasiMs = math.min(1200, jumlahKata * 36 + 180);
    return Duration(milliseconds: estimasiMs);
  }

  bool _apakahTanpaAnimasi() {
    final nonaktifAksesibilitas = MediaQuery.disableAnimationsOf(context);
    final nonaktifPengujian = ref.read(penyediaTanpaAnimasi);
    return nonaktifAksesibilitas || nonaktifPengujian;
  }

  void _sinkronkanStatusAnimasi() {
    if (_apakahTanpaAnimasi() || _daftarToken.isEmpty) {
      _pengontrol?.stop();
      _pengontrol?.dispose();
      _pengontrol = null;
      _sudahSelesai = true;
      return;
    }

    if (_sudahSelesai || _pengontrol != null) return;

    final ctrl = AnimationController(vsync: this, duration: _durasiTotal);
    ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() {
          _sudahSelesai = true;
        });
        widget.padaSelesai?.call();
      }
    });
    _pengontrol = ctrl;
    ctrl.forward();
  }

  void _selesaikanSeketika() {
    if (_sudahSelesai) return;
    _pengontrol?.stop();
    setState(() {
      _sudahSelesai = true;
    });
    widget.padaSelesai?.call();
  }

  List<_TokenKataAnimasi> _pecahJadiKata(String sumber) {
    final segmenList = widget.dukungIstilah
        ? uraiSegmenTeksIstilah(sumber)
        : [SegmenTeksIstilah(teks: sumber)];

    final hasil = <_TokenKataAnimasi>[];
    final polaSpasiKata = RegExp(r'\S+\s*|\s+');

    for (final seg in segmenList) {
      if (seg.kunciIstilah != null) {
        // Satu istilah dipecah per kata agar tetap bisa membungkus antar baris,
        // namun seluruh kata istilah membawa kunciIstilah yang sama saat diketuk.
        final cocok = polaSpasiKata.allMatches(seg.teks);
        if (cocok.isEmpty && seg.teks.isNotEmpty) {
          hasil.add(
            _TokenKataAnimasi(
              teks: seg.teks,
              tebal: true,
              kunciIstilah: seg.kunciIstilah,
            ),
          );
        } else {
          for (final m in cocok) {
            hasil.add(
              _TokenKataAnimasi(
                teks: m.group(0)!,
                tebal: true,
                kunciIstilah: seg.kunciIstilah,
              ),
            );
          }
        }
        continue;
      }

      for (final m in polaSpasiKata.allMatches(seg.teks)) {
        final potongan = m.group(0)!;
        if (potongan.trim().isEmpty) continue;
        hasil.add(_TokenKataAnimasi(teks: potongan, tebal: seg.tebal));
      }
    }

    return hasil;
  }

  @override
  void dispose() {
    _pengontrol?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tanpaAnimasi =
        MediaQuery.disableAnimationsOf(context) ||
        ref.watch(penyediaTanpaAnimasi);
    final gayaDasar =
        widget.gaya ??
        TipografiFunda.isi.copyWith(
          fontSize: 16,
          height: 1.6,
          color: WarnaFunda.teks,
        );

    if (tanpaAnimasi || _sudahSelesai || _pengontrol == null) {
      if (widget.dukungIstilah) {
        return TeksDenganIstilah(
          teks: widget.teks,
          gaya: gayaDasar,
          rataTeks: widget.rataTeks,
        );
      }
      return Text(widget.teks, style: gayaDasar, textAlign: widget.rataTeks);
    }

    final mapKamus =
        ref.watch(penyediaKamus).value ?? const <String, IstilahKamus>{};
    final jumlah = _daftarToken.length;
    final durasiTotalMs = _durasiTotal.inMilliseconds.toDouble();
    final durasiKataFrac = math.min(0.45, 220.0 / math.max(1.0, durasiTotalMs));
    final rentangMulai = math.max(0.0, 1.0 - durasiKataFrac);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _selesaikanSeketika,
      child: Semantics(
        label: bersihkanMarkahIstilah(widget.teks),
        child: ExcludeSemantics(
          child: AnimatedBuilder(
            animation: _pengontrol!,
            builder: (context, _) {
              final progress = _pengontrol!.value;
              return Text.rich(
                TextSpan(
                  children: List<InlineSpan>.generate(jumlah, (indeks) {
                    final token = _daftarToken[indeks];
                    final awal = jumlah <= 1
                        ? 0.0
                        : (indeks / (jumlah - 1)) * rentangMulai;
                    final lokal = ((progress - awal) / durasiKataFrac).clamp(
                      0.0,
                      1.0,
                    );
                    final kurva = Curves.easeOutCubic.transform(lokal);

                    TextStyle gayaKata = gayaDasar;
                    if (token.kunciIstilah != null) {
                      gayaKata = gayaDasar.copyWith(
                        fontWeight: FontWeight.w600,
                        color: WarnaFunda.utama,
                        decoration: TextDecoration.underline,
                        decorationStyle: TextDecorationStyle.dashed,
                      );
                    } else if (token.tebal) {
                      gayaKata = gayaDasar.copyWith(
                        fontWeight: FontWeight.w700,
                      );
                    }

                    Widget teksWidget = Text(token.teks, style: gayaKata);
                    if (token.kunciIstilah != null) {
                      final kunci = token.kunciIstilah!;
                      teksWidget = GestureDetector(
                        onTap: () => tampilkanDialogKamusIstilah(
                          context,
                          kunci,
                          mapKamus,
                        ),
                        child: teksWidget,
                      );
                    }

                    return WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: Opacity(
                        opacity: kurva,
                        child: Transform.translate(
                          offset: Offset(0, 10 * (1 - kurva)),
                          child: teksWidget,
                        ),
                      ),
                    );
                  }),
                ),
                textAlign: widget.rataTeks,
                style: gayaDasar,
              );
            },
          ),
        ),
      ),
    );
  }
}
