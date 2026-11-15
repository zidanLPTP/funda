import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../komponen/komponen_funda.dart';
import '../../../tema/token.dart';
import '../../kategori/tampilan/layar_daftar_kategori.dart';

/// Layar Lainnya: Pusat navigasi untuk Dompet, Kategori, Pengaturan, dan Galeri Pengembang.
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
          // Kartu Info Pengembang (hanya di mode debug)
          if (kDebugMode) ...[
            PetakBento.ukuran2x1(
              tint: TintPetakBento.biru,
              padaKetuk: () => context.push('/galeri'),
              anak: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(SpasiFunda.m),
                    decoration: BoxDecoration(
                      color: WarnaFunda.permukaan,
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
          ],

          // Menu Manajemen Keuangan
          const TeksFunda.judulBagian('Pengelolaan Keuangan'),
          const SizedBox(height: SpasiFunda.m),
          _ItemMenu(
            ikon: LucideIcons.pieChart,
            judul: 'Anggaran Bulanan',
            keterangan: 'Rencanakan batas pengeluaran per kategori per bulan',
            padaKetuk: () => context.push('/anggaran'),
          ),
          const SizedBox(height: SpasiFunda.s),
          _ItemMenu(
            ikon: LucideIcons.target,
            judul: 'Tujuan Keuangan',
            keterangan: 'Pantau impian, pos tabungan, dan dana darurat',
            padaKetuk: () => context.push('/tujuan'),
          ),
          const SizedBox(height: SpasiFunda.s),
          _ItemMenu(
            ikon: LucideIcons.layers,
            judul: 'Kantong Dompet',
            keterangan: 'Pisahkan pos uang dalam dompet tanpa pindah rekening',
            padaKetuk: () => context.push('/kantong'),
          ),
          const SizedBox(height: SpasiFunda.s),
          _ItemMenu(
            ikon: LucideIcons.creditCard,
            judul: 'Utang & Cicilan',
            keterangan:
                'Pantau sisa pinjaman, cicilan per bulan, dan rasio cicilan',
            padaKetuk: () => context.push('/utang'),
          ),
          const SizedBox(height: SpasiFunda.s),
          _ItemMenu(
            ikon: LucideIcons.trendingUp,
            judul: 'Kekayaan Bersih',
            keterangan: 'Selisih total saldo aset dan sisa seluruh pinjaman',
            padaKetuk: () => context.push('/kekayaan-bersih'),
          ),
          const SizedBox(height: SpasiFunda.s),
          _ItemMenu(
            ikon: LucideIcons.wallet,
            judul: 'Kelola Dompet',
            keterangan: 'Tambah akun, ubah, arsipkan, atau sesuaikan saldo',
            padaKetuk: () => context.push('/dompet'),
          ),
          const SizedBox(height: SpasiFunda.s),
          _ItemMenu(
            ikon: LucideIcons.tags,
            judul: 'Kelola Kategori',
            keterangan: 'Kelompok kebutuhan, keinginan, tabungan, dan utang',
            padaKetuk: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LayarDaftarKategori()),
              );
            },
          ),
          const SizedBox(height: SpasiFunda.l),

          // Menu Pendukung
          const TeksFunda.judulBagian('Aplikasi & Data'),
          const SizedBox(height: SpasiFunda.m),
          _ItemMenu(
            ikon: LucideIcons.database,
            judul: 'Cadangan & Pemulihan Data',
            keterangan:
                'Data keuanganmu aman dan tersimpan lokal di perangkat ini',
            padaKetuk: () => _tampilkanPesan(context, 'Cadangan Data'),
          ),
          const SizedBox(height: SpasiFunda.s),
          _ItemMenu(
            ikon: LucideIcons.shieldCheck,
            judul: 'Privasi & Keamanan',
            keterangan:
                'Funda tidak mengirimkan data keuanganmu ke server luar (v1)',
            padaKetuk: () => _tampilkanPesan(context, 'Privasi'),
          ),
          const SizedBox(height: SpasiFunda.s),
          _ItemMenu(
            ikon: LucideIcons.info,
            judul: 'Tentang Funda',
            keterangan: 'Versi 0.2.0 (Tahap 2 - Dompet & Transaksi)',
            padaKetuk: () => _tampilkanPesan(context, 'Tentang Funda'),
          ),
          const SizedBox(height: SpasiFunda.xl),
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
