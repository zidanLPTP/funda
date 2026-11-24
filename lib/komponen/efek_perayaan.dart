import 'dart:math';
import 'package:flutter/material.dart';
import '../tema/token.dart';
import '../util/haptic.dart';

/// Memunculkan animasi konfeti perayaan mikro di atas layar saat ini selama 2 detik.
void tampilkanEfekPerayaan(BuildContext context) {
  UtilHaptic.suksesBesar();

  final overlay = Overlay.maybeOf(context);
  if (overlay == null) return;

  late final OverlayEntry entri;
  entri = OverlayEntry(
    builder: (ctx) => _WidgetPerayaan(
      onSelesai: () {
        entri.remove();
      },
    ),
  );

  overlay.insert(entri);
}

class _WidgetPerayaan extends StatefulWidget {
  final VoidCallback onSelesai;

  const _WidgetPerayaan({required this.onSelesai});

  @override
  State<_WidgetPerayaan> createState() => _WidgetPerayaanState();
}

class _WidgetPerayaanState extends State<_WidgetPerayaan>
    with SingleTickerProviderStateMixin {
  late final AnimationController _kontroler;
  late final List<_PartikelKonfeti> _daftarPartikel;

  @override
  void initState() {
    super.initState();
    _kontroler = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    final acak = Random();
    const daftarWarna = [
      WarnaFunda.utama,
      WarnaFunda.aksen,
      WarnaFunda.info,
      WarnaFunda.pemasukan,
      WarnaFunda.sifatKeinginan,
      WarnaFunda.tintAmber,
    ];

    _daftarPartikel = List.generate(40, (i) {
      return _PartikelKonfeti(
        x: 0.1 + acak.nextDouble() * 0.8,
        kecepatanX: (acak.nextDouble() - 0.5) * 0.6,
        kecepatanY: 0.8 + acak.nextDouble() * 0.8,
        warna: daftarWarna[acak.nextInt(daftarWarna.length)],
        ukuran: 6.0 + acak.nextDouble() * 6.0,
        kecepatanPutar: (acak.nextDouble() - 0.5) * 10,
      );
    });

    _kontroler.forward().then((_) {
      if (mounted) widget.onSelesai();
    });
  }

  @override
  void dispose() {
    _kontroler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _kontroler,
        builder: (context, _) {
          return CustomPaint(
            size: MediaQuery.sizeOf(context),
            painter: _PelukisKonfeti(
              kemajuan: _kontroler.value,
              partikel: _daftarPartikel,
            ),
          );
        },
      ),
    );
  }
}

class _PartikelKonfeti {
  final double x;
  final double kecepatanX;
  final double kecepatanY;
  final Color warna;
  final double ukuran;
  final double kecepatanPutar;

  _PartikelKonfeti({
    required this.x,
    required this.kecepatanX,
    required this.kecepatanY,
    required this.warna,
    required this.ukuran,
    required this.kecepatanPutar,
  });
}

class _PelukisKonfeti extends CustomPainter {
  final double kemajuan;
  final List<_PartikelKonfeti> partikel;

  _PelukisKonfeti({required this.kemajuan, required this.partikel});

  @override
  void paint(Canvas canvas, Size size) {
    final cat = Paint();

    for (final p in partikel) {
      final t = kemajuan;
      // Posisi X melayang horizontal
      final px = (p.x + p.kecepatanX * t) * size.width;
      // Posisi Y: meletup ke atas di awal, lalu jatuh karena gravitasi
      final py = (0.6 - (p.kecepatanY * t) + (1.2 * t * t)) * size.height;

      // Efek memudar di 30% durasi terakhir
      final alpha = ((1.0 - t).clamp(0.0, 1.0) * 255).toInt();
      cat.color = p.warna.withAlpha(alpha);

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(p.kecepatanPutar * t);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: p.ukuran,
          height: p.ukuran * 0.6,
        ),
        cat,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _PelukisKonfeti oldDelegate) => true;
}
