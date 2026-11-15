import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../komponen/komponen_funda.dart';
import '../../../tema/token.dart';

/// Layar Belajar kurikulum Funda.
/// Menggunakan KeadaanKosong sebagai placeholder tahap 1.
class LayarBelajar extends StatelessWidget {
  const LayarBelajar({super.key});

  @override
  Widget build(BuildContext context) {
    return PembungkusLayar(
      appBar: AppBar(title: const TeksFunda.judulBagian('Belajar Keuangan')),
      anak: KeadaanKosong(
        ikon: LucideIcons.bookOpen,
        warnaTint: WarnaFunda.tintUngu,
        warnaIkon: WarnaFunda.sifatKeinginan,
        judul: 'Pondasi Uangmu Dimulai Di Sini',
        pesan:
            'Pelajaran singkat 3-5 menit yang langsung dipraktikkan dengan data keuanganmu sendiri. Siap belajar sambil praktik?',
        teksTombol: 'Lihat Gambaran Kurikulum',
        padaAksi: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Mesin belajar dan kurikulum akan hadir pada Tahap 4.',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }
}
