import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../aplikasi/konfigurasi_debug.dart';
import '../../../komponen/komponen_funda.dart';
import '../../../tema/token.dart';
import '../../anggaran/tampilan/layar_anggaran.dart';
import '../../cadangan/tampilan/layar_cadangan.dart';
import '../../dompet/tampilan/layar_daftar_dompet.dart';
import '../../kantong/tampilan/layar_daftar_kantong.dart';
import '../../kategori/tampilan/layar_daftar_kategori.dart';
import '../../kekayaan_bersih/tampilan/layar_kekayaan_bersih.dart';
import '../../laporan/tampilan/layar_laporan_bulanan.dart';
import '../../onboarding/tampilan/layar_onboarding.dart';
import '../../pengaturan/tampilan/layar_pengaturan.dart';
import '../../sandbox/tampilan/layar_sandbox.dart';
import '../../tagihan/tampilan/layar_jadwal_tagihan.dart';
import '../../tujuan/tampilan/layar_daftar_tujuan.dart';
import '../../utang/tampilan/layar_daftar_utang.dart';

/// Layar Lainnya bergaya editorial bersih:
/// header dengan pil Pengaturan, dua kartu kanvas sorotan, dan 3 grup kartu putih berpemisah tipis.
class LayarLainnya extends ConsumerWidget {
  const LayarLainnya({super.key});

  void _bukaRuteAtauHalaman(
    BuildContext context,
    WidgetRef ref,
    String rute,
    WidgetBuilder pembangunFallback,
  ) {
    final router = GoRouter.maybeOf(context);
    if (router != null) {
      router.push(rute);
      return;
    }

    final tanpaAnimasi =
        MediaQuery.disableAnimationsOf(context) ||
        ref.read(penyediaTanpaAnimasi);
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: tanpaAnimasi
            ? Duration.zero
            : const Duration(milliseconds: 250),
        reverseTransitionDuration: tanpaAnimasi
            ? Duration.zero
            : const Duration(milliseconds: 200),
        pageBuilder: (ctx, _, _) => pembangunFallback(ctx),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTeksBesar = MediaQuery.textScalerOf(context).scale(1) > 1.3;

    final kartuLaporan = _KartuKanvasSorotan(
      key: const Key('kartu_sorotan_laporan'),
      judul: 'Laporan Bulanan',
      keterangan: 'Arus kas & saran per bulan',
      kanvas: WarnaFunda.kanvasBiru,
      warnaAksen: WarnaFunda.sifatKebutuhan,
      jenisIlustrasi: JenisIlustrasiFunda.neraca,
      padaKetuk: () => _bukaRuteAtauHalaman(
        context,
        ref,
        '/laporan',
        (_) => const LayarLaporanBulanan(),
      ),
    );

    final kartuSandbox = _KartuKanvasSorotan(
      key: const Key('kartu_sorotan_sandbox'),
      judul: 'Mode Sandbox',
      keterangan: 'Simulasi portofolio investasi',
      kanvas: WarnaFunda.kanvasUngu,
      warnaAksen: WarnaFunda.sifatKeinginan,
      jenisIlustrasi: JenisIlustrasiFunda.tunas,
      padaKetuk: () => _bukaRuteAtauHalaman(
        context,
        ref,
        '/sandbox',
        (_) => const LayarSandbox(),
      ),
    );

    return Scaffold(
      backgroundColor: WarnaFunda.latar,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(SpasiFunda.marginLayar),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Editorial: "Lainnya" di kiri + Pil "Pengaturan" di kanan
              _HeaderLainnyaEditorial(
                isTeksBesar: isTeksBesar,
                padaTekanPengaturan: () => _bukaRuteAtauHalaman(
                  context,
                  ref,
                  '/pengaturan',
                  (_) => const LayarPengaturan(),
                ),
              ),
              const SizedBox(height: SpasiFunda.l),

              // Kartu Info Pengembang (hanya bila flag debug UI aktif)
              if (kDebugMode && aktifkanFiturDebugUi) ...[
                _KartuGrupMenu(
                  anak: [
                    _BarisMenuEditorial(
                      ikon: LucideIcons.palette,
                      warnaIkon: WarnaFunda.utama,
                      judul: 'Galeri Komponen UI',
                      keterangan:
                          'Lihat semua varian tombol, kartu, warna, dan tipografi',
                      padaKetuk: () => context.push('/galeri'),
                    ),
                  ],
                ),
                const SizedBox(height: SpasiFunda.l),
              ],

              // 2 Kartu Kanvas Bersebelahan (otomatis menumpuk jika textScale > 1.3)
              if (isTeksBesar)
                Column(
                  children: [
                    kartuLaporan,
                    const SizedBox(height: SpasiFunda.jarakPetak),
                    kartuSandbox,
                  ],
                )
              else
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: kartuLaporan),
                      const SizedBox(width: SpasiFunda.jarakPetak),
                      Expanded(child: kartuSandbox),
                    ],
                  ),
                ),
              const SizedBox(height: SpasiFunda.xl),

              // Grup 1: Perencanaan & Tagihan
              const TeksFunda.judulBagian('Perencanaan & Tagihan'),
              const SizedBox(height: SpasiFunda.m),
              _KartuGrupMenu(
                key: const Key('kartu_grup_perencanaan'),
                anak: [
                  _BarisMenuEditorial(
                    ikon: LucideIcons.pieChart,
                    warnaIkon: WarnaFunda.sifatKebutuhan,
                    judul: 'Anggaran Bulanan',
                    keterangan:
                        'Rencanakan batas pengeluaran per kategori per bulan',
                    padaKetuk: () => _bukaRuteAtauHalaman(
                      context,
                      ref,
                      '/anggaran',
                      (_) => const LayarAnggaran(),
                    ),
                  ),
                  _BarisMenuEditorial(
                    ikon: LucideIcons.target,
                    warnaIkon: WarnaFunda.utama,
                    judul: 'Tujuan Keuangan',
                    keterangan: 'Pantau impian, pos tabungan, dan dana darurat',
                    padaKetuk: () => _bukaRuteAtauHalaman(
                      context,
                      ref,
                      '/tujuan',
                      (_) => const LayarDaftarTujuan(),
                    ),
                  ),
                  _BarisMenuEditorial(
                    ikon: LucideIcons.calendarClock,
                    warnaIkon: WarnaFunda.pengeluaran,
                    judul: 'Tagihan & Langganan',
                    keterangan:
                        'Jadwal jatuh tempo rutin dan pengingat lokal ramah baterai',
                    padaKetuk: () => _bukaRuteAtauHalaman(
                      context,
                      ref,
                      '/tagihan',
                      (_) => const LayarJadwalTagihan(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SpasiFunda.xl),

              // Grup 2: Dompet & Kekayaan
              const TeksFunda.judulBagian('Dompet & Kekayaan'),
              const SizedBox(height: SpasiFunda.m),
              _KartuGrupMenu(
                key: const Key('kartu_grup_dompet_kekayaan'),
                anak: [
                  _BarisMenuEditorial(
                    ikon: LucideIcons.wallet,
                    warnaIkon: WarnaFunda.utama,
                    judul: 'Kelola Dompet',
                    keterangan:
                        'Tambah akun, ubah, arsipkan, atau sesuaikan saldo',
                    padaKetuk: () => _bukaRuteAtauHalaman(
                      context,
                      ref,
                      '/dompet',
                      (_) => const LayarDaftarDompet(),
                    ),
                  ),
                  _BarisMenuEditorial(
                    ikon: LucideIcons.layers,
                    warnaIkon: WarnaFunda.sifatKeinginan,
                    judul: 'Kantong Dompet',
                    keterangan:
                        'Pisahkan pos uang dalam dompet tanpa pindah rekening',
                    padaKetuk: () => _bukaRuteAtauHalaman(
                      context,
                      ref,
                      '/kantong',
                      (_) => const LayarDaftarKantong(),
                    ),
                  ),
                  _BarisMenuEditorial(
                    ikon: LucideIcons.creditCard,
                    warnaIkon: WarnaFunda.sifatUtang,
                    judul: 'Utang & Cicilan',
                    keterangan:
                        'Pantau sisa pinjaman, cicilan per bulan, dan rasio cicilan',
                    padaKetuk: () => _bukaRuteAtauHalaman(
                      context,
                      ref,
                      '/utang',
                      (_) => const LayarDaftarUtang(),
                    ),
                  ),
                  _BarisMenuEditorial(
                    ikon: LucideIcons.trendingUp,
                    warnaIkon: WarnaFunda.pemasukan,
                    judul: 'Kekayaan Bersih',
                    keterangan:
                        'Selisih total saldo dompet dan sisa seluruh pinjaman',
                    padaKetuk: () => _bukaRuteAtauHalaman(
                      context,
                      ref,
                      '/kekayaan-bersih',
                      (_) => const LayarKekayaanBersih(),
                    ),
                  ),
                  _BarisMenuEditorial(
                    ikon: LucideIcons.tags,
                    warnaIkon: WarnaFunda.aksenIkonUngu,
                    judul: 'Kelola Kategori',
                    keterangan:
                        'Kelompok kebutuhan, keinginan, tabungan, dan utang',
                    padaKetuk: () => _bukaRuteAtauHalaman(
                      context,
                      ref,
                      '/kategori',
                      (_) => const LayarDaftarKategori(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SpasiFunda.xl),

              // Grup 3: Aplikasi & Data
              const TeksFunda.judulBagian('Aplikasi & Data'),
              const SizedBox(height: SpasiFunda.m),
              _KartuGrupMenu(
                key: const Key('kartu_grup_aplikasi_data'),
                anak: [
                  _BarisMenuEditorial(
                    ikon: LucideIcons.database,
                    warnaIkon: WarnaFunda.info,
                    judul: 'Cadangan & Pemulihan Data',
                    keterangan:
                        'Ekspor dan pulihkan seluruh data keuangan secara lokal',
                    padaKetuk: () => _bukaRuteAtauHalaman(
                      context,
                      ref,
                      '/cadangan',
                      (_) => const LayarCadangan(),
                    ),
                  ),
                  _BarisMenuEditorial(
                    ikon: LucideIcons.shieldCheck,
                    warnaIkon: WarnaFunda.pemasukan,
                    judul: 'Privasi & Keamanan',
                    keterangan:
                        'Funda tidak mengirimkan data keuanganmu ke server luar',
                    padaKetuk: () => _tampilkanPrivasiKeamanan(context, ref),
                  ),
                  _BarisMenuEditorial(
                    ikon: LucideIcons.compass,
                    warnaIkon: WarnaFunda.sifatKeinginan,
                    judul: 'Panduan Nilai Funda',
                    keterangan:
                        'Tiga pilar cara Funda memandang uang: Tenang, Kendali, dan Bertumbuh',
                    padaKetuk: () => _bukaRuteAtauHalaman(
                      context,
                      ref,
                      '/onboarding',
                      (_) => const LayarOnboarding(),
                    ),
                  ),
                  _BarisMenuEditorial(
                    ikon: LucideIcons.info,
                    warnaIkon: WarnaFunda.info,
                    judul: 'Tentang Funda',
                    keterangan:
                        'Versi 1.1.0 (Teman Mengelola Uang yang Nyaman & Aman)',
                    padaKetuk: () => _tampilkanTentangFunda(context, ref),
                  ),
                ],
              ),
              const SizedBox(height: SpasiFunda.xl),
            ],
          ),
        ),
      ),
    );
  }

  void _tampilkanPrivasiKeamanan(BuildContext context, WidgetRef ref) {
    final tanpaAnimasi =
        MediaQuery.disableAnimationsOf(context) ||
        ref.read(penyediaTanpaAnimasi);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      sheetAnimationStyle: tanpaAnimasi ? AnimationStyle.noAnimation : null,
      backgroundColor: WarnaFunda.transparan,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gagang Modal
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: SpasiFunda.m),
                      decoration: BoxDecoration(
                        color: WarnaFunda.garis,
                        borderRadius: BorderRadius.circular(SudutFunda.pil),
                      ),
                    ),
                  ),

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(SpasiFunda.m),
                        decoration: BoxDecoration(
                          color: WarnaFunda.kanvasMint,
                          borderRadius: BorderRadius.circular(SudutFunda.kartu),
                        ),
                        child: const Icon(
                          LucideIcons.shieldCheck,
                          size: 24,
                          color: WarnaFunda.pemasukan,
                        ),
                      ),
                      const SizedBox(width: SpasiFunda.m),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TeksFunda.judulBagian('Privasi & Keamanan'),
                            SizedBox(height: 2),
                            TeksFunda.catatan(
                              'Data keuanganmu sepenuhnya milikmu sendiri.',
                              warna: WarnaFunda.teksRedup,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: SpasiFunda.l),

                  // 3 Poin Privasi Funda dalam Kartu Putih Border 1px
                  Container(
                    decoration: BoxDecoration(
                      color: WarnaFunda.permukaan,
                      borderRadius: BorderRadius.circular(SudutFunda.petak),
                      border: Border.all(color: WarnaFunda.garis, width: 1.0),
                    ),
                    padding: const EdgeInsets.all(SpasiFunda.l),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PoinInfoSheet(
                          ikon: LucideIcons.smartphone,
                          warnaIkon: WarnaFunda.utama,
                          judul: '100% Tersimpan Lokal di HP',
                          keterangan:
                              'Seluruh transaksi, dompet, anggaran, dan catatan pribadimu tersimpan langsung di penyimpanan perangkat ini.',
                        ),
                        Divider(
                          height: SpasiFunda.l * 2,
                          color: WarnaFunda.garis,
                        ),
                        _PoinInfoSheet(
                          ikon: LucideIcons.shieldCheck,
                          warnaIkon: WarnaFunda.pemasukan,
                          judul: 'Tanpa Akun, Server, & Pelacak',
                          keterangan:
                              'Funda berjalan sepenuhnya secara luring (offline). Tidak ada login paksa, server luar, iklan, atau pelacak aktivitas.',
                        ),
                        Divider(
                          height: SpasiFunda.l * 2,
                          color: WarnaFunda.garis,
                        ),
                        _PoinInfoSheet(
                          ikon: LucideIcons.database,
                          warnaIkon: WarnaFunda.info,
                          judul: 'Kendali Penuh Lewat Cadangan',
                          keterangan:
                              'Karena tidak disinkronkan ke awan, biasakan menyimpan berkas cadangan secara berkala agar datamu aman jika ganti HP.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: SpasiFunda.l),

                  TombolFunda.pilGelap(
                    key: const Key('tombol_privasi_ke_cadangan'),
                    lebarPenuh: true,
                    teks: 'Cadangan & Pemulihan Data',
                    padaTekan: () {
                      Navigator.pop(ctx);
                      _bukaRuteAtauHalaman(
                        context,
                        ref,
                        '/cadangan',
                        (_) => const LayarCadangan(),
                      );
                    },
                  ),
                  const SizedBox(height: SpasiFunda.s),
                  TombolFunda.sekunder(
                    lebarPenuh: true,
                    teks: 'Mengerti',
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

  void _tampilkanTentangFunda(BuildContext context, WidgetRef ref) {
    final tanpaAnimasi =
        MediaQuery.disableAnimationsOf(context) ||
        ref.read(penyediaTanpaAnimasi);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      sheetAnimationStyle: tanpaAnimasi ? AnimationStyle.noAnimation : null,
      backgroundColor: WarnaFunda.transparan,
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
                      border: Border.all(color: WarnaFunda.garis, width: 1.0),
                      boxShadow: const [
                        BoxShadow(
                          color: WarnaFunda.bayanganKartu,
                          blurRadius: 12,
                          offset: Offset(0, 4),
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
                  const TeksFunda.label('Versi 1.1.0', warna: WarnaFunda.utama),
                  const SizedBox(height: SpasiFunda.xs),
                  const TeksFunda.catatan(
                    'Teman Mengelola Uang yang Nyaman, Sadar, dan Aman',
                    rataTeks: TextAlign.center,
                    warna: WarnaFunda.teksRedup,
                  ),
                  const SizedBox(height: SpasiFunda.l),

                  // 3 Pilar Funda dalam Kartu Putih Border 1px
                  Container(
                    decoration: BoxDecoration(
                      color: WarnaFunda.permukaan,
                      borderRadius: BorderRadius.circular(SudutFunda.petak),
                      border: Border.all(color: WarnaFunda.garis, width: 1.0),
                    ),
                    padding: const EdgeInsets.all(SpasiFunda.l),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PoinInfoSheet(
                          ikon: LucideIcons.shieldCheck,
                          warnaIkon: WarnaFunda.utama,
                          judul: '100% Offline & Privat',
                          keterangan:
                              'Data keuanganmu tersimpan aman di perangkatmu sendiri. Tidak ada pelacakan, tidak ada server backend luar, dan bebas iklan selamanya.',
                        ),
                        Divider(
                          height: SpasiFunda.l * 2,
                          color: WarnaFunda.garis,
                        ),
                        _PoinInfoSheet(
                          ikon: LucideIcons.heartHandshake,
                          warnaIkon: WarnaFunda.sifatKeinginan,
                          judul: 'Ruang Tenang Tanpa Penghakiman',
                          keterangan:
                              'Membantumu memahami ke mana uangmu mengalir dengan jernih, tanpa rasa bersalah atau label negatif.',
                        ),
                        Divider(
                          height: SpasiFunda.l * 2,
                          color: WarnaFunda.garis,
                        ),
                        _PoinInfoSheet(
                          ikon: LucideIcons.graduationCap,
                          warnaIkon: WarnaFunda.info,
                          judul: '18 Modul Belajar Nyata',
                          keterangan:
                              'Pelajaran micro-learning yang melatih data pribadimu sendiri: dari arus kas dasar hingga pensiun dan proteksi.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: SpasiFunda.l),

                  // Tombol Aksi
                  TombolFunda.pilGelap(
                    key: const Key('tombol_tentang_ke_panduan'),
                    lebarPenuh: true,
                    teks: 'Buka Panduan Nilai Funda',
                    padaTekan: () {
                      Navigator.pop(ctx);
                      _bukaRuteAtauHalaman(
                        context,
                        ref,
                        '/onboarding',
                        (_) => const LayarOnboarding(),
                      );
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
}

class _HeaderLainnyaEditorial extends StatelessWidget {
  const _HeaderLainnyaEditorial({
    required this.isTeksBesar,
    required this.padaTekanPengaturan,
  });

  final bool isTeksBesar;
  final VoidCallback padaTekanPengaturan;

  @override
  Widget build(BuildContext context) {
    final tombolPengaturan = Semantics(
      button: true,
      label: 'Pengaturan',
      child: InkWell(
        key: const Key('tombol_pengaturan_header_lainnya'),
        onTap: padaTekanPengaturan,
        borderRadius: BorderRadius.circular(SudutFunda.pil),
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: EdgeInsets.symmetric(
            horizontal: isTeksBesar ? SpasiFunda.s : SpasiFunda.m,
            vertical: SpasiFunda.s,
          ),
          decoration: BoxDecoration(
            color: WarnaFunda.permukaan,
            borderRadius: BorderRadius.circular(SudutFunda.pil),
            border: Border.all(color: WarnaFunda.garis, width: 1.0),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.settings, size: 16, color: WarnaFunda.teks),
              SizedBox(width: SpasiFunda.xs),
              Flexible(
                child: Text(
                  'Pengaturan',
                  style: TextStyle(
                    fontFamily: TipografiFunda.namaKeluargaFont,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: WarnaFunda.teks,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (isTeksBesar) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TeksFunda.judulLayar('Lainnya'),
          const SizedBox(height: SpasiFunda.s),
          tombolPengaturan,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(child: TeksFunda.judulLayar('Lainnya')),
        const SizedBox(width: SpasiFunda.s),
        tombolPengaturan,
      ],
    );
  }
}

class _KartuKanvasSorotan extends StatelessWidget {
  const _KartuKanvasSorotan({
    super.key,
    required this.judul,
    required this.keterangan,
    required this.kanvas,
    required this.warnaAksen,
    required this.jenisIlustrasi,
    required this.padaKetuk,
  });

  final String judul;
  final String keterangan;
  final Color kanvas;
  final Color warnaAksen;
  final JenisIlustrasiFunda jenisIlustrasi;
  final VoidCallback padaKetuk;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$judul. $keterangan',
      child: Container(
        decoration: BoxDecoration(
          color: kanvas,
          borderRadius: BorderRadius.circular(SudutFunda.petak),
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: WarnaFunda.transparan,
          child: InkWell(
            onTap: padaKetuk,
            borderRadius: BorderRadius.circular(SudutFunda.petak),
            child: Padding(
              padding: const EdgeInsets.all(SpasiFunda.l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IlustrasiGeometrisFunda(
                        jenis: jenisIlustrasi,
                        warnaAksen: warnaAksen,
                        ukuran: 48,
                      ),
                      const Icon(
                        LucideIcons.arrowUpRight,
                        size: 18,
                        color: WarnaFunda.teks,
                      ),
                    ],
                  ),
                  const SizedBox(height: SpasiFunda.m),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TeksFunda.label(judul),
                      const SizedBox(height: SpasiFunda.xs),
                      TeksFunda.catatan(
                        keterangan,
                        warna: WarnaFunda.teksRedup,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _KartuGrupMenu extends StatelessWidget {
  const _KartuGrupMenu({super.key, required this.anak});

  final List<Widget> anak;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: WarnaFunda.permukaan,
        borderRadius: BorderRadius.circular(SudutFunda.petak),
        border: Border.all(color: WarnaFunda.garis, width: 1.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < anak.length; i++) ...[
            anak[i],
            if (i < anak.length - 1)
              const Divider(
                height: 1,
                indent: SpasiFunda.l,
                endIndent: SpasiFunda.l,
                color: WarnaFunda.garis,
              ),
          ],
        ],
      ),
    );
  }
}

class _BarisMenuEditorial extends StatelessWidget {
  const _BarisMenuEditorial({
    required this.ikon,
    required this.warnaIkon,
    required this.judul,
    required this.keterangan,
    required this.padaKetuk,
  });

  final IconData ikon;
  final Color warnaIkon;
  final String judul;
  final String keterangan;
  final VoidCallback padaKetuk;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: WarnaFunda.transparan,
      child: InkWell(
        onTap: padaKetuk,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SpasiFunda.l,
            vertical: SpasiFunda.m,
          ),
          child: Row(
            children: [
              Icon(ikon, color: warnaIkon, size: 22),
              const SizedBox(width: SpasiFunda.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TeksFunda.label(judul),
                    const SizedBox(height: 2),
                    TeksFunda.catatan(keterangan, warna: WarnaFunda.teksRedup),
                  ],
                ),
              ),
              const SizedBox(width: SpasiFunda.s),
              const Icon(
                LucideIcons.chevronRight,
                size: 18,
                color: WarnaFunda.teksRedup,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PoinInfoSheet extends StatelessWidget {
  const _PoinInfoSheet({
    required this.ikon,
    required this.warnaIkon,
    required this.judul,
    required this.keterangan,
  });

  final IconData ikon;
  final Color warnaIkon;
  final String judul;
  final String keterangan;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(ikon, size: 18, color: warnaIkon),
            const SizedBox(width: SpasiFunda.s),
            Expanded(child: TeksFunda.label(judul)),
          ],
        ),
        const SizedBox(height: SpasiFunda.xs),
        TeksFunda.catatan(keterangan, warna: WarnaFunda.teksRedup),
      ],
    );
  }
}
