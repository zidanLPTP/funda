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

/// Layar Laporan Bulanan bergaya editorial bersih:
/// header dengan tombol kembali >= 48dp, hero kanvas biru, kontrol bulan & saklar privasi,
/// serta pratinjau laporan yang siap diekspor ke PNG/PDF.
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
    final isTeksBesar = MediaQuery.textScalerOf(context).scale(1) > 1.3;

    return Scaffold(
      backgroundColor: WarnaFunda.latar,
      body: SafeArea(
        child: asyncLaporan.when(
          loading: () => const Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  SpasiFunda.marginLayar,
                  SpasiFunda.marginLayar,
                  SpasiFunda.marginLayar,
                  0,
                ),
                child: HeaderSubLayarEditorial(judul: 'Laporan Bulanan'),
              ),
              Expanded(child: Center(child: IndikatorMemuat())),
            ],
          ),
          error: (err, stack) => Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(
                  SpasiFunda.marginLayar,
                  SpasiFunda.marginLayar,
                  SpasiFunda.marginLayar,
                  0,
                ),
                child: HeaderSubLayarEditorial(judul: 'Laporan Bulanan'),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(SpasiFunda.xl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          LucideIcons.triangleAlert,
                          color: WarnaFunda.bahaya,
                          size: 40,
                        ),
                        const SizedBox(height: SpasiFunda.m),
                        TeksFunda.isiKecil(
                          'Terjadi kendala saat menyusun laporan: $err',
                          rataTeks: TextAlign.center,
                          warna: WarnaFunda.teks,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          data: (laporan) {
            final konten = asyncKonten.asData?.value;
            if (konten == null) {
              return const Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      SpasiFunda.marginLayar,
                      SpasiFunda.marginLayar,
                      SpasiFunda.marginLayar,
                      0,
                    ),
                    child: HeaderSubLayarEditorial(judul: 'Laporan Bulanan'),
                  ),
                  Expanded(child: Center(child: IndikatorMemuat())),
                ],
              );
            }

            final teks = terapkanSensor(laporan, konten, sensor: sensorAktif);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(SpasiFunda.marginLayar),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Sub-Layar Editorial
                  const HeaderSubLayarEditorial(judul: 'Laporan Bulanan'),
                  const SizedBox(height: SpasiFunda.m),

                  // Hero Kanvas Biru: Ringkasan Periode & Mode Privasi
                  Container(
                    key: const Key('hero_kanvas_laporan'),
                    padding: const EdgeInsets.all(SpasiFunda.l),
                    decoration: BoxDecoration(
                      color: WarnaFunda.kanvasBiru,
                      borderRadius: BorderRadius.circular(SudutFunda.petak),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const IlustrasiSvgFunda(
                          pathAset: AsetIlustrasiFunda.laporanBulanan,
                          tinggi: 60,
                        ),
                        const SizedBox(width: SpasiFunda.m),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TeksFunda.judulBagian(
                                formatBulanTahunIndonesia(laporan.bulan),
                              ),
                              const SizedBox(height: SpasiFunda.xs),
                              TeksFunda.catatan(
                                sensorAktif
                                    ? 'Mode privasi aktif: nominal angka disensor sebelum dibagikan.'
                                    : 'Siap diekspor ke gambar PNG atau dokumen PDF lokal.',
                                warna: WarnaFunda.teksRedup,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: SpasiFunda.m),

                  // 1. Kartu Putih Border 1px: Pemilih Bulan & Saklar Sensor
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpasiFunda.l,
                      vertical: SpasiFunda.s,
                    ),
                    decoration: BoxDecoration(
                      color: WarnaFunda.permukaan,
                      borderRadius: BorderRadius.circular(SudutFunda.petak),
                      border: Border.all(color: WarnaFunda.garis, width: 1.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Pemilih Bulan
                        if (isTeksBesar)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    LucideIcons.calendar,
                                    size: 18,
                                    color: WarnaFunda.utama,
                                  ),
                                  SizedBox(width: SpasiFunda.s),
                                  Expanded(
                                    child: TeksFunda.label('Pilih Bulan'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: SpasiFunda.xs),
                              _bangunDropdownBulan(
                                asyncDaftarBulan,
                                bulanDipilih,
                                ref,
                                lebarPenuh: true,
                              ),
                            ],
                          )
                        else
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
                                  SizedBox(width: SpasiFunda.s),
                                  TeksFunda.label('Pilih Bulan'),
                                ],
                              ),
                              _bangunDropdownBulan(
                                asyncDaftarBulan,
                                bulanDipilih,
                                ref,
                                lebarPenuh: false,
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
                              const Expanded(
                                child: Row(
                                  children: [
                                    Icon(
                                      LucideIcons.eyeOff,
                                      size: 18,
                                      color: WarnaFunda.sifatKeinginan,
                                    ),
                                    SizedBox(width: SpasiFunda.s),
                                    Expanded(
                                      child: TeksFunda.label(
                                        'Sembunyikan nominal',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: SpasiFunda.s),
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
                  const SizedBox(height: SpasiFunda.m),

                  // 2. Tombol Aksi Ekspor (Bagikan PNG & Bagikan PDF pilGelap)
                  if (isTeksBesar) ...[
                    TombolFunda.sekunder(
                      teks: 'Bagikan Gambar',
                      ikon: const Icon(LucideIcons.image, size: 18),
                      memuat: _sedangMengekspor,
                      padaTekan: () => _bagikanGambar(laporan, sensorAktif),
                      lebarPenuh: true,
                    ),
                    const SizedBox(height: SpasiFunda.s),
                    TombolFunda.pilGelap(
                      teks: 'Bagikan PDF',
                      ikon: const Icon(LucideIcons.fileText, size: 18),
                      memuat: _sedangMengekspor,
                      padaTekan: () => _bagikanPdf(laporan, sensorAktif),
                      lebarPenuh: true,
                    ),
                  ] else
                    Row(
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
                        const SizedBox(width: SpasiFunda.s),
                        Expanded(
                          child: TombolFunda.pilGelap(
                            teks: 'Bagikan PDF',
                            ikon: const Icon(LucideIcons.fileText, size: 18),
                            memuat: _sedangMengekspor,
                            padaTekan: () => _bagikanPdf(laporan, sensorAktif),
                            lebarPenuh: false,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: SpasiFunda.l),

                  // 3. Pratinjau Kartu Laporan Bulanan (utuh untuk ekspor PNG)
                  Center(
                    child: RepaintBoundary(
                      key: _kunciKartuLaporan,
                      child: Container(
                        decoration: BoxDecoration(
                          color: WarnaFunda.latar,
                          borderRadius: BorderRadius.circular(SudutFunda.petak),
                          border: Border.all(
                            color: WarnaFunda.garis,
                            width: 1.0,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: TampilanKartuLaporan(
                          teks: teks,
                          untukEkspor: false,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: SpasiFunda.xl),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _bangunDropdownBulan(
    AsyncValue<List<DateTime>> asyncDaftarBulan,
    DateTime bulanDipilih,
    WidgetRef ref, {
    required bool lebarPenuh,
  }) {
    return asyncDaftarBulan.when(
      data: (daftarBulan) => DropdownButton<DateTime>(
        value: bulanDipilih,
        isExpanded: lebarPenuh,
        underline: const SizedBox(),
        icon: const Icon(LucideIcons.chevronDown, size: 16),
        items: daftarBulan.map((b) {
          return DropdownMenuItem<DateTime>(
            value: b,
            child: Text(
              formatBulanTahunIndonesia(b),
              style: TipografiFunda.label.copyWith(fontSize: 13),
            ),
          );
        }).toList(),
        onChanged: (baru) {
          if (baru != null) {
            ref.read(penyediaBulanDipilih.notifier).pilihBulan(baru);
          }
        },
      ),
      loading: () => const IndikatorMemuat(ukuran: 16, ketebalan: 2),
      error: (_, _) => const SizedBox(),
    );
  }
}
