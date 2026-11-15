import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../komponen/komponen_funda.dart';
import '../../../tema/token.dart';

/// Layar Catatan transaksi Funda.
/// Menggunakan KeadaanKosong sebagai placeholder tahap 1 sebelum fitur pencatatan dibangun.
class LayarCatatan extends StatelessWidget {
  const LayarCatatan({super.key});

  @override
  Widget build(BuildContext context) {
    return PembungkusLayar(
      appBar: AppBar(title: const TeksFunda.judulBagian('Catatan Keuangan')),
      anak: KeadaanKosong(
        ikon: LucideIcons.wallet,
        warnaTint: WarnaFunda.tintHijau,
        warnaIkon: WarnaFunda.utama,
        judul: 'Belum Ada Transaksi',
        pesan:
            'Setiap perjalanan keuangan dimulai dari satu catatan kecil. Yuk mulai catat pemasukan atau pengeluaran pertamamu nanti.',
        teksTombol: 'Pelajari Cara Mencatat',
        padaAksi: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Fitur pencatatan transaksi akan hadir pada Tahap 2.',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }
}
