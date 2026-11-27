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
import '../../kamus/tampilan/layar_kamus.dart';
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
      pathSvg: AsetIlustrasiFunda.laporanBulanan,
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
      pathSvg: AsetIlustrasiFunda.modeSandbox,
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
                      pathSvg: AsetIkonFunda.katHiburan,
                      warnaIkon: WarnaFunda.utama,
                      judul: 'Galeri Komponen UI',
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
                    pathSvg: AsetIkonFunda.metrikAnggaran,
                    warnaIkon: WarnaFunda.sifatKebutuhan,
                    judul: 'Anggaran Bulanan',
                    padaKetuk: () => _bukaRuteAtauHalaman(
                      context,
                      ref,
                      '/anggaran',
                      (_) => const LayarAnggaran(),
                    ),
                  ),
                  _BarisMenuEditorial(
                    ikon: LucideIcons.target,
                    pathSvg: AsetIkonFunda.metrikTujuan,
                    warnaIkon: WarnaFunda.utama,
                    judul: 'Tujuan Keuangan',
                    padaKetuk: () => _bukaRuteAtauHalaman(
                      context,
                      ref,
                      '/tujuan',
                      (_) => const LayarDaftarTujuan(),
                    ),
                  ),
                  _BarisMenuEditorial(
                    ikon: LucideIcons.calendarClock,
                    pathSvg: AsetIkonFunda.menuTagihan,
                    warnaIkon: WarnaFunda.pengeluaran,
                    judul: 'Tagihan & Langganan',
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
                    pathSvg: AsetIkonFunda.menuDompet,
                    warnaIkon: WarnaFunda.utama,
                    judul: 'Kelola Dompet',
                    padaKetuk: () => _bukaRuteAtauHalaman(
                      context,
                      ref,
                      '/dompet',
                      (_) => const LayarDaftarDompet(),
                    ),
                  ),
                  _BarisMenuEditorial(
                    ikon: LucideIcons.layers,
                    pathSvg: AsetIkonFunda.menuKantong,
                    warnaIkon: WarnaFunda.sifatKeinginan,
                    judul: 'Kantong Dompet',
                    padaKetuk: () => _bukaRuteAtauHalaman(
                      context,
                      ref,
                      '/kantong',
                      (_) => const LayarDaftarKantong(),
                    ),
                  ),
                  _BarisMenuEditorial(
                    ikon: LucideIcons.creditCard,
                    pathSvg: AsetIkonFunda.menuUtang,
                    warnaIkon: WarnaFunda.sifatUtang,
                    judul: 'Utang & Cicilan',
                    padaKetuk: () => _bukaRuteAtauHalaman(
                      context,
                      ref,
                      '/utang',
                      (_) => const LayarDaftarUtang(),
                    ),
                  ),
                  _BarisMenuEditorial(
                    ikon: LucideIcons.trendingUp,
                    pathSvg: AsetIkonFunda.menuKekayaan,
                    warnaIkon: WarnaFunda.pemasukan,
                    judul: 'Kekayaan Bersih',
                    padaKetuk: () => _bukaRuteAtauHalaman(
                      context,
                      ref,
                      '/kekayaan-bersih',
                      (_) => const LayarKekayaanBersih(),
                    ),
                  ),
                  _BarisMenuEditorial(
                    ikon: LucideIcons.tags,
                    pathSvg: AsetIkonFunda.menuKategori,
                    warnaIkon: WarnaFunda.aksenIkonUngu,
                    judul: 'Kelola Kategori',
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
                    pathSvg: AsetIkonFunda.menuCadangan,
                    warnaIkon: WarnaFunda.info,
                    judul: 'Cadangan & Pemulihan Data',
                    padaKetuk: () => _bukaRuteAtauHalaman(
                      context,
                      ref,
                      '/cadangan',
                      (_) => const LayarCadangan(),
                    ),
                  ),
                  _BarisMenuEditorial(
                    ikon: LucideIcons.shieldCheck,
                    pathSvg: AsetIkonFunda.menuPrivasi,
                    warnaIkon: WarnaFunda.pemasukan,
                    judul: 'Privasi & Keamanan',
                    padaKetuk: () => _tampilkanPrivasiKeamanan(context, ref),
                  ),
                  _BarisMenuEditorial(
                    ikon: LucideIcons.bookOpen,
                    pathSvg: AsetIkonFunda.menuKamus,
                    warnaIkon: WarnaFunda.utama,
                    judul: 'Kamus Keuangan',
                    padaKetuk: () => _bukaRuteAtauHalaman(
                      context,
                      ref,
                      '/kamus',
                      (_) => const LayarKamus(),
                    ),
                  ),
                  _BarisMenuEditorial(
                    ikon: LucideIcons.compass,
                    pathSvg: AsetIkonFunda.menuPanduan,
                    warnaIkon: WarnaFunda.sifatKeinginan,
                    judul: 'Panduan Nilai Funda',
                    padaKetuk: () => _bukaRuteAtauHalaman(
                      context,
                      ref,
                      '/onboarding',
                      (_) => const LayarOnboarding(),
                    ),
                  ),
                  _BarisMenuEditorial(
                    ikon: LucideIcons.info,
                    pathSvg: AsetIkonFunda.menuTentang,
                    warnaIkon: WarnaFunda.info,
                    judul: 'Tentang Funda',
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

                  // Kartu Header Kanvas Privasi
                  Container(
                    padding: const EdgeInsets.all(SpasiFunda.l),
                    decoration: BoxDecoration(
                      color: WarnaFunda.kanvasMint,
                      borderRadius: BorderRadius.circular(SudutFunda.petak),
                    ),
                    child: const Row(
                      children: [
                        IlustrasiSvgFunda(
                          pathAset: AsetIlustrasiFunda.privasiLokal,
                          tinggi: 60,
                        ),
                        SizedBox(width: SpasiFunda.m),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TeksFunda.judulBagian('Privasi & Keamanan'),
                              SizedBox(height: SpasiFunda.xs),
                              TeksFunda.catatan(
                                'Data keuanganmu 100% milikmu dan tetap di perangkat ini.',
                                warna: WarnaFunda.teksRedup,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: SpasiFunda.m),

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
                          pathSvg: AsetIkonFunda.penyimpananLokal,
                          warnaIkon: WarnaFunda.utama,
                          judul: 'Tersimpan Lokal di HP',
                          keterangan:
                              'Seluruh transaksi, dompet, anggaran, dan catatan pribadimu disimpan langsung di penyimpanan perangkat.',
                        ),
                        Divider(
                          height: SpasiFunda.l * 2,
                          color: WarnaFunda.garis,
                        ),
                        _PoinInfoSheet(
                          ikon: LucideIcons.shieldCheck,
                          pathSvg: AsetIkonFunda.menuPrivasi,
                          warnaIkon: WarnaFunda.pemasukan,
                          judul: 'Tanpa Akun, Server, & Pelacak',
                          keterangan:
                              'Funda berjalan luring sepenuhnya tanpa login paksa, server luar, iklan, atau pelacak aktivitas.',
                        ),
                        Divider(
                          height: SpasiFunda.l * 2,
                          color: WarnaFunda.garis,
                        ),
                        _PoinInfoSheet(
                          ikon: LucideIcons.database,
                          pathSvg: AsetIkonFunda.menuCadangan,
                          warnaIkon: WarnaFunda.info,
                          judul: 'Kendali Penuh Lewat Cadangan',
                          keterangan:
                              'Karena tidak disinkronkan ke awan, simpan berkas cadangan secara berkala agar data tetap aman saat ganti HP.',
                        ),
                      ],
                    ),
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
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

                  // Hero Kanvas Identitas Funda
                  Container(
                    padding: const EdgeInsets.all(SpasiFunda.l),
                    decoration: BoxDecoration(
                      color: WarnaFunda.kanvasMint,
                      borderRadius: BorderRadius.circular(SudutFunda.petak),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              SudutFunda.kartu,
                            ),
                            border: Border.all(
                              color: WarnaFunda.garis,
                              width: 1.0,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              SudutFunda.kartu,
                            ),
                            child: Image.asset(
                              'aset/gambar/app_icon_512.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: SpasiFunda.m),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  TeksFunda.judulLayar('Funda'),
                                  SizedBox(width: SpasiFunda.s),
                                  TeksFunda.catatan(
                                    'v1.2.0',
                                    warna: WarnaFunda.utama,
                                  ),
                                ],
                              ),
                              SizedBox(height: SpasiFunda.xs),
                              TeksFunda.catatan(
                                'Teman mengelola uang yang nyaman, sadar, dan aman.',
                                warna: WarnaFunda.teksRedup,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: SpasiFunda.m),

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
                          pathSvg: AsetIkonFunda.menuPrivasi,
                          warnaIkon: WarnaFunda.utama,
                          judul: '100% Offline & Privat',
                          keterangan:
                              'Data tersimpan aman di perangkatmu tanpa pelacakan, server luar, maupun iklan.',
                        ),
                        Divider(
                          height: SpasiFunda.l * 2,
                          color: WarnaFunda.garis,
                        ),
                        _PoinInfoSheet(
                          ikon: LucideIcons.heartHandshake,
                          pathSvg: AsetIkonFunda.katDonasi,
                          warnaIkon: WarnaFunda.sifatKeinginan,
                          judul: 'Ruang Tenang',
                          keterangan:
                              'Membantumu memahami arah arus kas dengan jelas.',
                        ),
                        Divider(
                          height: SpasiFunda.l * 2,
                          color: WarnaFunda.garis,
                        ),
                        _PoinInfoSheet(
                          ikon: LucideIcons.graduationCap,
                          pathSvg: AsetIkonFunda.katPendidikan,
                          warnaIkon: WarnaFunda.info,
                          judul: '18 Modul Belajar Nyata',
                          keterangan:
                              'Pelajaran singkat yang langsung dipraktikkan memakai data pribadimu dari arus kas hingga proteksi.',
                        ),
                      ],
                    ),
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
              IkonUiFunda(
                pathAset: AsetIkonUiFunda.settings,
                ukuran: 16,
                warna: WarnaFunda.teks,
              ),
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
    required this.pathSvg,
    required this.padaKetuk,
  });

  final String judul;
  final String keterangan;
  final Color kanvas;
  final String pathSvg;
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
                      IlustrasiSvgFunda(pathAset: pathSvg, tinggi: 58),
                      const IkonUiFunda(
                        pathAset: AsetIkonUiFunda.arrowUpRight,
                        ukuran: 18,
                        warna: WarnaFunda.teks,
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
    this.pathSvg,
    required this.warnaIkon,
    required this.judul,
    required this.padaKetuk,
  });

  final IconData ikon;
  final String? pathSvg;
  final Color warnaIkon;
  final String judul;
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
            vertical: SpasiFunda.l,
          ),
          child: Row(
            children: [
              if (pathSvg != null)
                IkonSvgFunda(pathAset: pathSvg!, ukuran: 24)
              else
                ikonUiDariLucide(ikon, ukuran: 22, warna: warnaIkon),
              const SizedBox(width: SpasiFunda.m),
              Expanded(child: TeksFunda.label(judul)),
              const SizedBox(width: SpasiFunda.s),
              const IkonUiFunda(
                pathAset: AsetIkonUiFunda.chevronRight,
                ukuran: 18,
                warna: WarnaFunda.teksRedup,
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
    this.pathSvg,
    required this.warnaIkon,
    required this.judul,
    required this.keterangan,
  });

  final IconData ikon;
  final String? pathSvg;
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
            if (pathSvg != null)
              IkonSvgFunda(pathAset: pathSvg!, ukuran: 20)
            else
              ikonUiDariLucide(ikon, ukuran: 18, warna: warnaIkon),
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
