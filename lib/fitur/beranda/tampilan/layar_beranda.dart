import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../komponen/komponen_funda.dart';
import '../../../tema/token.dart';
import '../../../util/format_rupiah.dart';

/// Layar Beranda utama aplikasi Funda.
/// Menampilkan contoh tata letak Soft Bento dengan data tiruan (placeholder).
class LayarBeranda extends StatelessWidget {
  const LayarBeranda({super.key});

  @override
  Widget build(BuildContext context) {
    return PembungkusLayar(
      bisaGulir: true,
      anak: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Pengembang (Akses ke Galeri Komponen)
          GestureDetector(
            onTap: () => context.push('/galeri'),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SpasiFunda.m,
                vertical: SpasiFunda.s,
              ),
              decoration: BoxDecoration(
                color: WarnaFunda.utamaTipis,
                borderRadius: BorderRadius.circular(SudutFunda.kecil),
                border: Border.all(color: WarnaFunda.utama),
              ),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.palette,
                    size: 16,
                    color: WarnaFunda.utamaGelap,
                  ),
                  const SizedBox(width: SpasiFunda.s),
                  Expanded(
                    child: TeksFunda.isiKecil(
                      'Mode Pengembang: Buka Galeri Komponen & Token',
                      warna: WarnaFunda.utamaGelap,
                    ),
                  ),
                  const Icon(
                    LucideIcons.chevronRight,
                    size: 16,
                    color: WarnaFunda.utamaGelap,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: SpasiFunda.l),

          // Sapaan Header
          const TeksFunda.judulLayar('Halo!'),
          const SizedBox(height: SpasiFunda.xs),
          const TeksFunda.isi(
            'Mari rapikan uangmu pelan-pelan.',
            warna: WarnaFunda.teksRedup,
          ),
          const SizedBox(height: SpasiFunda.l),

          // Tanda Placeholder
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: SpasiFunda.s,
              vertical: SpasiFunda.xs,
            ),
            decoration: BoxDecoration(
              color: WarnaFunda.tintAmber,
              borderRadius: BorderRadius.circular(SudutFunda.kecil),
            ),
            child: const TeksFunda.catatan(
              'Tata letak bento di bawah ini adalah data contoh (placeholder tahap 1)',
              warna: WarnaFunda.peringatan,
            ),
          ),
          const SizedBox(height: SpasiFunda.m),

          // Bento 2x1: Hero Arus Kas
          PetakBento.ukuran2x1(
            tint: TintPetakBento.hijau,
            padaKetuk: () {},
            labelAkses:
                'Arus kas bulan ini positif satu juta dua ratus lima puluh ribu rupiah',
            anak: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const TeksFunda.isiKecil('Arus Kas Bulan Ini'),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SpasiFunda.s,
                        vertical: SpasiFunda.xs,
                      ),
                      decoration: BoxDecoration(
                        color: WarnaFunda.pemasukan.withAlpha(30),
                        borderRadius: BorderRadius.circular(SudutFunda.pil),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.trendingUp,
                            size: 14,
                            color: WarnaFunda.pemasukan,
                          ),
                          SizedBox(width: SpasiFunda.xs),
                          TeksFunda.catatan(
                            '+12%',
                            warna: WarnaFunda.pemasukan,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SpasiFunda.s),
                TeksFunda.angkaBesar(
                  formatRupiah(1250000),
                  warna: WarnaFunda.teks,
                ),
                const SizedBox(height: SpasiFunda.xs),
                const TeksFunda.catatan(
                  'Uang masuk lebih besar dari uang keluar. Pertahankan!',
                  warna: WarnaFunda.teksRedup,
                ),
              ],
            ),
          ),
          const SizedBox(height: SpasiFunda.jarakPetak),

          // Baris Bento 1x1: Sisa Anggaran & Dana Darurat
          Row(
            children: [
              Expanded(
                child: PetakBento.ukuran1x1(
                  tint: TintPetakBento.biru,
                  padaKetuk: () {},
                  anak: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(SpasiFunda.xs),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(SudutFunda.kecil),
                        ),
                        child: const Icon(
                          LucideIcons.pieChart,
                          size: 18,
                          color: WarnaFunda.sifatKebutuhan,
                        ),
                      ),
                      const SizedBox(height: SpasiFunda.m),
                      const TeksFunda.isiKecil('Sisa Anggaran'),
                      const SizedBox(height: SpasiFunda.xs),
                      TeksFunda.judulBagian(
                        formatRupiah(850000),
                        angkaTabular: true,
                      ),
                      const SizedBox(height: SpasiFunda.xs),
                      const TeksFunda.catatan('Aman sampai akhir bulan'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: SpasiFunda.jarakPetak),
              Expanded(
                child: PetakBento.ukuran1x1(
                  tint: TintPetakBento.amber,
                  padaKetuk: () {},
                  anak: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(SpasiFunda.xs),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(SudutFunda.kecil),
                        ),
                        child: const Icon(
                          LucideIcons.shieldCheck,
                          size: 18,
                          color: WarnaFunda.sifatUtang,
                        ),
                      ),
                      const SizedBox(height: SpasiFunda.m),
                      const TeksFunda.isiKecil('Dana Darurat'),
                      const SizedBox(height: SpasiFunda.xs),
                      const TeksFunda.judulBagian('1.5 Bulan'),
                      const SizedBox(height: SpasiFunda.xs),
                      const TeksFunda.catatan('Target: 3 Bulan'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: SpasiFunda.jarakPetak),

          // Bento 2x1: Lanjut Belajar
          PetakBento.ukuran2x1(
            tint: TintPetakBento.ungu,
            padaKetuk: () => context.go('/belajar'),
            anak: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: SpasiFunda.s,
                          vertical: SpasiFunda.xs,
                        ),
                        decoration: BoxDecoration(
                          color: WarnaFunda.sifatKeinginan.withAlpha(25),
                          borderRadius: BorderRadius.circular(SudutFunda.pil),
                        ),
                        child: const TeksFunda.catatan(
                          'Pelajaran Berikutnya',
                          warna: WarnaFunda.sifatKeinginan,
                        ),
                      ),
                      const SizedBox(height: SpasiFunda.s),
                      const TeksFunda.judulBagian('Memetakan Arus Kas'),
                      const SizedBox(height: SpasiFunda.xs),
                      const TeksFunda.catatan('Modul 1 • 4 menit baca'),
                    ],
                  ),
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: WarnaFunda.sifatKeinginan,
                    borderRadius: BorderRadius.circular(SudutFunda.pil),
                  ),
                  child: const Icon(
                    LucideIcons.play,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
