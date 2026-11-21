import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../tema/token.dart';
import 'teks_funda.dart';

/// Komponen resmi untuk menampilkan disclaimer "Langkah Dunia Nyata"
/// yang dimuat dari `aset/konten/disclaimer.json` (kunci `langkahDuniaNyata`).
class DisclaimerLangkahDuniaNyata extends StatefulWidget {
  final VoidCallback? padaMengerti;
  final bool sudahMengerti;

  const DisclaimerLangkahDuniaNyata({
    super.key,
    this.padaMengerti,
    this.sudahMengerti = false,
  });

  /// Helper untuk memuat teks disclaimer langsung dari rootBundle atau string default.
  static Future<String> muatTeksDisclaimer() async {
    try {
      final jsonStr = await rootBundle.loadString('aset/konten/disclaimer.json');
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      return data['langkahDuniaNyata'] as String? ?? _teksBawaan;
    } catch (_) {
      return _teksBawaan;
    }
  }

  static const String _teksBawaan =
      'Funda hanya memberi edukasi umum. Ini bukan ajakan membeli produk keuangan atau '
      'nasihat keuangan, hukum, maupun pajak. Keputusan dan risikonya ada padamu. '
      'Funda tidak bertanggung jawab atas kerugian dari tindakan di luar aplikasi. '
      'Pastikan penyedia berizin sebelum memakai uangmu.';

  @override
  State<DisclaimerLangkahDuniaNyata> createState() => _DisclaimerLangkahDuniaNyataState();
}

class _DisclaimerLangkahDuniaNyataState extends State<DisclaimerLangkahDuniaNyata> {
  String _teks = DisclaimerLangkahDuniaNyata._teksBawaan;
  bool _terbuka = true;

  @override
  void initState() {
    super.initState();
    _muatTeks();
    if (widget.sudahMengerti) {
      _terbuka = false;
    }
  }

  Future<void> _muatTeks() async {
    final t = await DisclaimerLangkahDuniaNyata.muatTeksDisclaimer();
    if (mounted) {
      setState(() {
        _teks = t;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_terbuka && widget.sudahMengerti) {
      return Container(
        margin: const EdgeInsets.only(bottom: SpasiFunda.m),
        padding: const EdgeInsets.symmetric(horizontal: SpasiFunda.m, vertical: SpasiFunda.s),
        decoration: BoxDecoration(
          color: WarnaFunda.permukaan,
          borderRadius: BorderRadius.circular(SudutFunda.kartu),
          border: Border.all(color: WarnaFunda.garis),
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.shieldAlert, size: 18, color: WarnaFunda.peringatan),
            const SizedBox(width: SpasiFunda.s),
            const Expanded(
              child: TeksFunda.catatan('Catatan: Langkah Dunia Nyata', warna: WarnaFunda.teks),
            ),
            TextButton(
              style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
              onPressed: () => setState(() => _terbuka = true),
              child: const TeksFunda.catatan('Baca Ulang', warna: WarnaFunda.utama),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: SpasiFunda.l),
      padding: const EdgeInsets.all(SpasiFunda.m),
      decoration: BoxDecoration(
        color: WarnaFunda.tintAmber,
        borderRadius: BorderRadius.circular(SudutFunda.kartu),
        border: Border.all(color: WarnaFunda.garis),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.shieldAlert, color: WarnaFunda.peringatan, size: 20),
              SizedBox(width: SpasiFunda.s),
              Expanded(
                child: TeksFunda.label(
                  'Langkah Dunia Nyata',
                  warna: WarnaFunda.peringatan,
                ),
              ),
            ],
          ),
          const SizedBox(height: SpasiFunda.s),
          TeksFunda.isi(_teks),
          const SizedBox(height: SpasiFunda.m),
          if (widget.padaMengerti != null)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  side: const BorderSide(color: WarnaFunda.garis),
                  backgroundColor: WarnaFunda.permukaan,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SudutFunda.pil),
                  ),
                ),
                onPressed: () {
                  setState(() => _terbuka = false);
                  widget.padaMengerti?.call();
                },
                child: const TeksFunda.label('Mengerti', warna: WarnaFunda.teks),
              ),
            ),
        ],
      ),
    );
  }
}
