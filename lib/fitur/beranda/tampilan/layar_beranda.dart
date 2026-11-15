import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../data/penyedia_data.dart';
import '../../../komponen/komponen_funda.dart';
import '../../../tema/token.dart';
import '../../../util/format_rupiah.dart';
import '../../dompet/tampilan/layar_form_dompet.dart';

/// Layar Beranda utama aplikasi Funda.
/// Menampilkan data NYATA untuk Arus Kas dan Total Saldo,
/// serta modul pendukung bertanda placeholder.
class LayarBeranda extends ConsumerWidget {
  const LayarBeranda({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daftarDompetAktif = ref.watch(penyediaDaftarDompetAktif).value ?? [];
    final totalSaldo = ref.watch(penyediaTotalSaldoAktif);
    final arusKas = ref.watch(penyediaArusKasBulanIni);

    return PembungkusLayar(
      bisaGulir: true,
      anak: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Pengembang (Akses ke Galeri Komponen, hanya muncul di mode debug)
          if (kDebugMode) ...[
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
                      LucideIcons.code,
                      size: 20,
                      color: WarnaFunda.utama,
                    ),
                    const SizedBox(width: SpasiFunda.s),
                    Expanded(
                      child: TeksFunda.label(
                        'Mode Pengembang: Buka Galeri Komponen & Token',
                        warna: WarnaFunda.utama,
                      ),
                    ),
                    const Icon(
                      LucideIcons.chevronRight,
                      size: 16,
                      color: WarnaFunda.utama,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: SpasiFunda.m),
          ],

          if (daftarDompetAktif.isEmpty) ...[
            const SizedBox(height: SpasiFunda.xl),
            KeadaanKosong(
              ikon: LucideIcons.wallet,
              judul: 'Selamat Datang di Funda',
              pesan:
                  'Mulai kelola uangmu dengan rapi. Buat dompet pertamamu untuk mencatat pemasukan dan pengeluaran.',
              teksTombol: 'Buat Dompet Pertamamu',
              padaAksi: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LayarFormDompet()),
                );
              },
            ),
          ] else ...[
            // Sapaan Header
            const TeksFunda.judulLayar('Halo!'),
            const SizedBox(height: SpasiFunda.xs),
            const TeksFunda.isi(
              'Mari rapikan uangmu pelan-pelan.',
              warna: WarnaFunda.teksRedup,
            ),
            const SizedBox(height: SpasiFunda.l),

            // Bento 2x1: Hero Arus Kas Bulan Ini (DATA NYATA)
            PetakBento.ukuran2x1(
              tint: TintPetakBento.hijau,
              padaKetuk: () => context.go('/catatan'),
              labelAkses: 'Arus kas bulan ini ${formatRupiah(arusKas.selisih)}',
              anak: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const TeksFunda.isiKecil(
                        'Arus Kas Bulan Ini (Data Nyata)',
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: SpasiFunda.s,
                          vertical: SpasiFunda.xs,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (arusKas.selisih >= 0
                                      ? WarnaFunda.pemasukan
                                      : WarnaFunda.pengeluaran)
                                  .withAlpha(25),
                          borderRadius: BorderRadius.circular(SudutFunda.pil),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              arusKas.selisih >= 0
                                  ? LucideIcons.trendingUp
                                  : LucideIcons.trendingDown,
                              size: 14,
                              color: arusKas.selisih >= 0
                                  ? WarnaFunda.pemasukan
                                  : WarnaFunda.pengeluaran,
                            ),
                            const SizedBox(width: SpasiFunda.xs),
                            TeksFunda.catatan(
                              arusKas.selisih >= 0 ? 'Surplus' : 'Defisit',
                              warna: arusKas.selisih >= 0
                                  ? WarnaFunda.pemasukan
                                  : WarnaFunda.pengeluaran,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: SpasiFunda.s),
                  TeksFunda.angkaBesar(
                    formatRupiah(arusKas.selisih),
                    warna: arusKas.selisih < 0
                        ? WarnaFunda.pengeluaran
                        : WarnaFunda.teks,
                  ),
                  const SizedBox(height: SpasiFunda.xs),
                  TeksFunda.catatan(
                    'Masuk: ${formatRupiah(arusKas.totalMasuk)} • Keluar: ${formatRupiah(arusKas.totalKeluar)}',
                    warna: WarnaFunda.teksRedup,
                  ),
                ],
              ),
            ),
            const SizedBox(height: SpasiFunda.jarakPetak),

            // Baris Bento 1x1: Total Saldo Nyata & Placeholder Dana Darurat
            Row(
              children: [
                Expanded(
                  child: PetakBento.ukuran1x1(
                    tint: TintPetakBento.biru,
                    padaKetuk: () => context.go('/lainnya'),
                    anak: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(SpasiFunda.xs),
                          decoration: BoxDecoration(
                            color: WarnaFunda.permukaan,
                            borderRadius: BorderRadius.circular(
                              SudutFunda.kecil,
                            ),
                          ),
                          child: const Icon(
                            LucideIcons.wallet,
                            size: 18,
                            color: WarnaFunda.utama,
                          ),
                        ),
                        const SizedBox(height: SpasiFunda.m),
                        const TeksFunda.isiKecil('Total Saldo (Nyata)'),
                        const SizedBox(height: SpasiFunda.xs),
                        TeksFunda.judulBagian(
                          formatRupiah(totalSaldo),
                          angkaTabular: true,
                          warna: totalSaldo < 0
                              ? WarnaFunda.pengeluaran
                              : WarnaFunda.teks,
                        ),
                        const SizedBox(height: SpasiFunda.xs),
                        TeksFunda.catatan(
                          '${daftarDompetAktif.length} dompet aktif',
                        ),
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
                            color: WarnaFunda.permukaan,
                            borderRadius: BorderRadius.circular(
                              SudutFunda.kecil,
                            ),
                          ),
                          child: const Icon(
                            LucideIcons.shieldCheck,
                            size: 18,
                            color: WarnaFunda.sifatUtang,
                          ),
                        ),
                        const SizedBox(height: SpasiFunda.m),
                        const TeksFunda.isiKecil('Dana Darurat [Contoh]'),
                        const SizedBox(height: SpasiFunda.xs),
                        const TeksFunda.judulBagian('1.5 Bulan'),
                        const SizedBox(height: SpasiFunda.xs),
                        const TeksFunda.catatan(
                          'Target 3 bulan (Placeholder)',
                          warna: WarnaFunda.peringatan,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: SpasiFunda.jarakPetak),

            // Bento 2x1: Lanjut Belajar (Placeholder)
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
                            'Pelajaran Berikutnya [Contoh]',
                            warna: WarnaFunda.sifatKeinginan,
                          ),
                        ),
                        const SizedBox(height: SpasiFunda.s),
                        const TeksFunda.judulBagian('Memetakan Arus Kas'),
                        const SizedBox(height: SpasiFunda.xs),
                        const TeksFunda.catatan(
                          'Modul 1 • 4 menit baca (Tahap 4)',
                        ),
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
                      color: WarnaFunda.putih,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SpasiFunda.xl),
          ],
        ],
      ),
    );
  }
}
