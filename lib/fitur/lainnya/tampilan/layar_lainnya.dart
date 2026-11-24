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
            ikon: LucideIcons.fileText,
            judul: 'Laporan Bulanan',
            keterangan: 'Arus kas, komposisi, anggaran, dan saran per bulan',
            padaKetuk: () => context.push('/laporan'),
          ),
          const SizedBox(height: SpasiFunda.s),
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
            ikon: LucideIcons.calendarClock,
            judul: 'Tagihan & Langganan',
            keterangan:
                'Jadwal jatuh tempo rutin dan pengingat lokal ramah baterai',
            padaKetuk: () => context.push('/tagihan'),
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
          const SizedBox(height: SpasiFunda.s),
          _ItemMenu(
            ikon: LucideIcons.flaskConical,
            judul: 'Mode Sandbox',
            keterangan:
                'Simulasi portofolio investasi fiktif terisolasi dari data riil',
            padaKetuk: () => context.push('/sandbox'),
          ),
          const SizedBox(height: SpasiFunda.l),

          // Menu Pendukung
          const TeksFunda.judulBagian('Aplikasi & Data'),
          const SizedBox(height: SpasiFunda.m),
          _ItemMenu(
            ikon: LucideIcons.database,
            judul: 'Cadangan & Pemulihan Data',
            keterangan:
                'Ekspor dan pulihkan seluruh data keuangan secara lokal',
            padaKetuk: () => context.push('/cadangan'),
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
            ikon: LucideIcons.settings,
            judul: 'Pengaturan',
            keterangan:
                'Kelola pengingat lokal, jam notifikasi, dan privasi nominal',
            padaKetuk: () => context.push('/pengaturan'),
          ),
          const SizedBox(height: SpasiFunda.s),
          _ItemMenu(
            ikon: LucideIcons.sparkles,
            judul: 'Panduan Nilai Funda',
            keterangan:
                'Tiga pilar cara Funda memandang uang: Tenang, Kendali, dan Bertumbuh',
            padaKetuk: () => context.push('/onboarding'),
          ),
          const SizedBox(height: SpasiFunda.s),
          _ItemMenu(
            ikon: LucideIcons.info,
            judul: 'Tentang Funda',
            keterangan: 'Versi 1.0.0 (Teman Mengelola Uang yang Nyaman & Aman)',
            padaKetuk: () => _tampilkanTentangFunda(context),
          ),
          const SizedBox(height: SpasiFunda.xl),
        ],
      ),
    );
  }

  void _tampilkanTentangFunda(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: WarnaFunda.latar,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(SudutFunda.lembar),
            ),
          ),
          padding: const EdgeInsets.all(SpasiFunda.l),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Gagang Modal
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: SpasiFunda.m),
                    decoration: BoxDecoration(
                      color: WarnaFunda.garis,
                      borderRadius: BorderRadius.circular(SudutFunda.pil),
                    ),
                  ),

                  // Lambang Ikon Resmi Funda
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(SudutFunda.kartu),
                      boxShadow: const [
                        BoxShadow(
                          color: WarnaFunda.bayangan,
                          blurRadius: 16,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(SudutFunda.kartu),
                      child: Image.asset(
                        'aset/gambar/app_icon_512.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: SpasiFunda.m),

                  const TeksFunda.judulLayar('Funda'),
                  const SizedBox(height: SpasiFunda.xs),
                  const TeksFunda.label('Versi 1.0.0', warna: WarnaFunda.utama),
                  const SizedBox(height: SpasiFunda.xs),
                  const TeksFunda.catatan(
                    'Teman Mengelola Uang yang Nyaman, Sadar, dan Aman',
                  ),
                  const SizedBox(height: SpasiFunda.l),

                  // 3 Pilar Bento
                  PetakBento(
                    anak: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Row(
                          children: [
                            Icon(
                              LucideIcons.shieldCheck,
                              size: 18,
                              color: WarnaFunda.utama,
                            ),
                            SizedBox(width: SpasiFunda.s),
                            TeksFunda.label('100% Offline & Privat'),
                          ],
                        ),
                        SizedBox(height: SpasiFunda.xs),
                        TeksFunda.catatan(
                          'Data keuanganmu tersimpan aman di perangkatmu sendiri. Tidak ada pelacakan, tidak ada server backend luar, dan bebas iklan selamanya.',
                        ),
                        SizedBox(height: SpasiFunda.m),
                        Row(
                          children: [
                            Icon(
                              LucideIcons.heartHandshake,
                              size: 18,
                              color: WarnaFunda.sifatKeinginan,
                            ),
                            SizedBox(width: SpasiFunda.s),
                            TeksFunda.label('Ruang Tenang Tanpa Penghakiman'),
                          ],
                        ),
                        SizedBox(height: SpasiFunda.xs),
                        TeksFunda.catatan(
                          'Membantumu memahami ke mana uangmu mengalir dengan jernih, tanpa rasa bersalah atau label negatif.',
                        ),
                        SizedBox(height: SpasiFunda.m),
                        Row(
                          children: [
                            Icon(
                              LucideIcons.graduationCap,
                              size: 18,
                              color: WarnaFunda.info,
                            ),
                            SizedBox(width: SpasiFunda.s),
                            TeksFunda.label('18 Modul Belajar Nyata'),
                          ],
                        ),
                        SizedBox(height: SpasiFunda.xs),
                        TeksFunda.catatan(
                          'Pelajaran micro-learning yang melatih data pribadimu sendiri: dari arus kas dasar hingga pensiun dan proteksi.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: SpasiFunda.l),

                  // Tombol Aksi
                  TombolFunda.primer(
                    lebarPenuh: true,
                    teks: 'Buka Panduan Nilai Funda',
                    padaTekan: () {
                      Navigator.pop(ctx);
                      context.push('/onboarding');
                    },
                  ),
                  const SizedBox(height: SpasiFunda.s),
                  TombolFunda.sekunder(
                    lebarPenuh: true,
                    teks: 'Tutup',
                    padaTekan: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
