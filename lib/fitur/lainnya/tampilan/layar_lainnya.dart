import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../komponen/komponen_funda.dart';
import '../../../tema/token.dart';

/// Layar Lainnya (Pengaturan, Cadangan, Informasi).
class LayarLainnya extends StatelessWidget {
  const LayarLainnya({super.key});

  @override
  Widget build(BuildContext context) {
    return PembungkusLayar(
      appBar: AppBar(title: const TeksFunda.judulBagian('Lainnya')),
      bisaGulir: true,
      anak: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kartu Info Pengembang
          PetakBento.ukuran2x1(
            tint: TintPetakBento.biru,
            padaKetuk: () => context.push('/galeri'),
            anak: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(SpasiFunda.m),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(SudutFunda.kartu),
                  ),
                  child: const Icon(
                    LucideIcons.palette,
                    color: WarnaFunda.utama,
                    size: 24,
                  ),
                ),
                const SizedBox(width: SpasiFunda.l),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TeksFunda.label('Galeri Komponen UI'),
                      SizedBox(height: SpasiFunda.xs),
                      TeksFunda.catatan(
                        'Lihat semua varian tombol, bento, warna, dan tipografi',
                      ),
                    ],
                  ),
                ),
                const Icon(
                  LucideIcons.chevronRight,
                  color: WarnaFunda.teksRedup,
                ),
              ],
            ),
          ),
          const SizedBox(height: SpasiFunda.l),

          // Menu Placeholder
          _ItemMenu(
            ikon: LucideIcons.settings,
            judul: 'Pengaturan Aplikasi',
            keterangan: 'Format, mata uang, dan preferensi tampilan',
            padaKetuk: () => _tampilkanPesan(context, 'Pengaturan'),
          ),
          const SizedBox(height: SpasiFunda.s),
          _ItemMenu(
            ikon: LucideIcons.database,
            judul: 'Cadangan & Pemulihan Data',
            keterangan: 'Data keuanganmu aman dan tersimpan di perangkat ini',
            padaKetuk: () => _tampilkanPesan(context, 'Cadangan Data'),
          ),
          const SizedBox(height: SpasiFunda.s),
          _ItemMenu(
            ikon: LucideIcons.shieldAlert,
            judul: 'Privasi & Keamanan',
            keterangan:
                'Funda tidak mengirimkan data keuanganmu ke server luar',
            padaKetuk: () => _tampilkanPesan(context, 'Privasi'),
          ),
          const SizedBox(height: SpasiFunda.s),
          _ItemMenu(
            ikon: LucideIcons.info,
            judul: 'Tentang Funda',
            keterangan: 'Versi 0.1.0 (Tahap 1 - Fondasi)',
            padaKetuk: () => _tampilkanPesan(context, 'Tentang Funda'),
          ),
        ],
      ),
    );
  }

  void _tampilkanPesan(BuildContext context, String namaMenu) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Menu $namaMenu akan tersedia di tahap selanjutnya.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _ItemMenu extends StatelessWidget {
  const _ItemMenu({
    required this.ikon,
    required this.judul,
    required this.keterangan,
    required this.padaKetuk,
  });

  final IconData ikon;
  final String judul;
  final String keterangan;
  final VoidCallback padaKetuk;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: WarnaFunda.permukaan,
        borderRadius: BorderRadius.circular(SudutFunda.kartu),
        border: Border.all(color: WarnaFunda.garis),
      ),
      child: ListTile(
        onTap: padaKetuk,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: SpasiFunda.l,
          vertical: SpasiFunda.xs,
        ),
        leading: Icon(ikon, color: WarnaFunda.utama, size: 22),
        title: TeksFunda.label(judul),
        subtitle: TeksFunda.catatan(keterangan),
        trailing: const Icon(
          LucideIcons.chevronRight,
          size: 18,
          color: WarnaFunda.teksRedup,
        ),
      ),
    );
  }
}
