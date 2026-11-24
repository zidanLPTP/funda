import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../komponen/komponen_funda.dart';
import '../../../layanan/laporan/layanan_bagikan.dart';
import '../../../layanan/laporan/pembuat_gambar_laporan.dart';
import '../../../layanan/laporan/pembuat_pdf_laporan.dart';
import '../../../perhitungan/perhitungan_laporan_bulanan.dart';
import '../../../tema/token.dart';
import '../kontroler/penyedia_laporan.dart';
import 'tampilan_kartu_laporan.dart';

/// Layar Laporan Bulanan: Menyajikan pratinjau bento, saklar sensor privasi, serta ekspor PNG dan PDF.
class LayarLaporanBulanan extends ConsumerStatefulWidget {
  const LayarLaporanBulanan({super.key});

  @override
  ConsumerState<LayarLaporanBulanan> createState() =>
      _LayarLaporanBulananState();
}

class _LayarLaporanBulananState extends ConsumerState<LayarLaporanBulanan> {
  final GlobalKey _kunciKartuLaporan = GlobalKey();
  bool _sedangMengekspor = false;

  Future<void> _bagikanGambar(LaporanBulanan laporan, bool sensor) async {
    if (kDebugMode) {
      debugPrint('--> _bagikanGambar MULAI DIPANGGIL');
    }
    setState(() => _sedangMengekspor = true);
    try {
      final pngBytes = await PembuatGambarLaporan.tangkapDariKunci(
        _kunciKartuLaporan,
        pixelRatio: 3.0,
      );
      final namaBerkas =
          'funda_laporan_${laporan.bulan.year}-${laporan.bulan.month.toString().padLeft(2, '0')}.png';

      final layanan = ref.read(penyediaLayananBagikan);
      final berkas = await layanan.simpanBerkas(
        namaBerkas: namaBerkas,
        bytes: pngBytes,
      );

      await layanan.bagikanBerkas(
        pathBerkas: berkas.path,
        judul:
            'Laporan Bulanan Funda - ${formatBulanTahunIndonesia(laporan.bulan)}',
        teks: 'Berikut laporan edukasi keuangan pribadi dari aplikasi Funda.',
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('GALAT DI _BAGIKANGAMBAR: $e');
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengekspor gambar laporan: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _sedangMengekspor = false);
    }
  }

  Future<void> _bagikanPdf(LaporanBulanan laporan, bool sensor) async {
    setState(() => _sedangMengekspor = true);
    try {
      final pembuatPdf = await PembuatPdfLaporan.muatDariAset();
      final konten = await ref.read(penyediaKontenLaporan.future);

      final pdfBytes = await pembuatPdf.buatPdf(
        laporan: laporan,
        konten: konten,
        sensor: sensor,
      );

      final namaBerkas =
          'funda_laporan_${laporan.bulan.year}-${laporan.bulan.month.toString().padLeft(2, '0')}.pdf';
      final layanan = ref.read(penyediaLayananBagikan);
      final berkas = await layanan.simpanBerkas(
        namaBerkas: namaBerkas,
        bytes: pdfBytes,
      );

      await layanan.bagikanBerkas(
        pathBerkas: berkas.path,
        judul:
            'Laporan Bulanan Funda - ${formatBulanTahunIndonesia(laporan.bulan)}',
        teks:
            'Berikut laporan edukasi keuangan pribadi (format PDF) dari aplikasi Funda.',
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('GALAT DI _BAGIKANGAMBAR: $e');
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengekspor PDF laporan: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _sedangMengekspor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bulanDipilih = ref.watch(penyediaBulanDipilih);
    final sensorAktif = ref.watch(penyediaSensorNominal);
    final asyncLaporan = ref.watch(penyediaDataLaporanBulanan);
    final asyncDaftarBulan = ref.watch(penyediaDaftarBulanTersedia);
    final asyncKonten = ref.watch(penyediaKontenLaporan);

    return Scaffold(
      backgroundColor: WarnaFunda.latar,
      appBar: AppBar(
        title: const Text(
          'Laporan Bulanan',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: WarnaFunda.latar,
        elevation: 0,
        foregroundColor: WarnaFunda.teks,
      ),
      body: asyncLaporan.when(
        loading: () => const Center(child: IndikatorMemuat()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  LucideIcons.alertTriangle,
                  color: WarnaFunda.bahaya,
                  size: 40,
                ),
                const SizedBox(height: 12),
                Text(
                  'Terjadi kendala saat menyusun laporan: $err',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: WarnaFunda.teks),
                ),
              ],
            ),
          ),
        ),
        data: (laporan) {
          final konten = asyncKonten.asData?.value;
          if (konten == null) {
            return const Center(child: IndikatorMemuat());
          }

          final teks = terapkanSensor(laporan, konten, sensor: sensorAktif);

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Baris Kontrol: Pemilih Bulan & Saklar Sensor
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: WarnaFunda.permukaan,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: WarnaFunda.garis),
                  ),
                  child: Column(
                    children: [
                      // Pemilih Bulan
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                LucideIcons.calendar,
                                size: 18,
                                color: WarnaFunda.utama,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Pilih Bulan',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: WarnaFunda.teks,
                                ),
                              ),
                            ],
                          ),
                          asyncDaftarBulan.when(
                            data: (daftarBulan) => DropdownButton<DateTime>(
                              value: bulanDipilih,
                              underline: const SizedBox(),
                              icon: const Icon(
                                LucideIcons.chevronDown,
                                size: 16,
                              ),
                              items: daftarBulan.map((b) {
                                return DropdownMenuItem<DateTime>(
                                  value: b,
                                  child: Text(
                                    formatBulanTahunIndonesia(b),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (baru) {
                                if (baru != null) {
                                  ref
                                      .read(penyediaBulanDipilih.notifier)
                                      .pilihBulan(baru);
                                }
                              },
                            ),
                            loading: () =>
                                const IndikatorMemuat(ukuran: 16, ketebalan: 2),
                            error: (e, s) => const SizedBox(),
                          ),
                        ],
                      ),
                      const Divider(height: 16, color: WarnaFunda.garis),
                      // Saklar Sembunyikan Nominal (Sensor)
                      Semantics(
                        label:
                            'Saklar sembunyikan nominal angka Rupiah pada laporan',
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  LucideIcons.eyeOff,
                                  size: 18,
                                  color: WarnaFunda.teksRedup,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Sembunyikan nominal',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: WarnaFunda.teks,
                                  ),
                                ),
                              ],
                            ),
                            Switch(
                              value: sensorAktif,
                              activeThumbColor: WarnaFunda.utama,
                              onChanged: (val) {
                                ref
                                    .read(penyediaSensorNominal.notifier)
                                    .setelSensor(val);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 2. Tombol Aksi Ekspor (Bagikan PNG & PDF)
                Builder(
                  builder: (context) {
                    final teksBesar =
                        MediaQuery.textScalerOf(context).scale(14) > 18;
                    if (teksBesar) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TombolFunda.sekunder(
                            teks: 'Bagikan Gambar',
                            ikon: const Icon(LucideIcons.image, size: 18),
                            memuat: _sedangMengekspor,
                            padaTekan: () =>
                                _bagikanGambar(laporan, sensorAktif),
                            lebarPenuh: true,
                          ),
                          const SizedBox(height: 10),
                          TombolFunda.primer(
                            teks: 'Bagikan PDF',
                            ikon: const Icon(LucideIcons.fileText, size: 18),
                            memuat: _sedangMengekspor,
                            padaTekan: () => _bagikanPdf(laporan, sensorAktif),
                            lebarPenuh: true,
                          ),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(
                          child: TombolFunda.sekunder(
                            teks: 'Bagikan Gambar',
                            ikon: const Icon(LucideIcons.image, size: 18),
                            memuat: _sedangMengekspor,
                            padaTekan: () =>
                                _bagikanGambar(laporan, sensorAktif),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TombolFunda.primer(
                            teks: 'Bagikan PDF',
                            ikon: const Icon(LucideIcons.fileText, size: 18),
                            memuat: _sedangMengekspor,
                            padaTekan: () => _bagikanPdf(laporan, sensorAktif),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),

                // 3. Pratinjau Kartu Bento Laporan Bulanan
                Center(
                  child: RepaintBoundary(
                    key: _kunciKartuLaporan,
                    child: Container(
                      decoration: BoxDecoration(
                        color: WarnaFunda.latar,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: WarnaFunda.garis),
                        boxShadow: const [
                          BoxShadow(
                            color: WarnaFunda.bayangan,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: TampilanKartuLaporan(
                        teks: teks,
                        untukEkspor: false,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
