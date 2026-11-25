import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../aplikasi/konfigurasi_debug.dart';
import '../../../data/penyedia_data.dart';
import '../../../komponen/komponen_funda.dart';
import '../../../komponen/pembantu_ikon.dart';
import '../../../perhitungan/perhitungan_anggaran_tujuan.dart';
import '../../../perhitungan/perhitungan_beranda.dart';
import '../../../perhitungan/perhitungan_tagihan.dart';
import '../../../perhitungan/perhitungan_utang_dashboard.dart';
import '../../../tema/token.dart';
import '../../../util/format_rupiah.dart';
import '../../anggaran/kontroler/penyedia_anggaran.dart';
import '../../belajar/kontroler/penyedia_belajar.dart';
import '../../cadangan/kontroler/penyedia_cadangan.dart';
import '../../dompet/tampilan/layar_form_dompet.dart';
import '../../tagihan/kontroler/penyedia_tagihan.dart';
import '../../transaksi/tampilan/layar_form_transaksi.dart';
import '../../tujuan/kontroler/penyedia_tujuan.dart';
import '../../tutorial/kontroler/penyedia_tutorial.dart';
import '../../utang/kontroler/penyedia_utang.dart';

/// Layar Beranda utama Funda bergaya editorial bersih:
/// satu Hero Arus Kas + Saldo & Kekayaan Bersih di atas, 4 metrik putih 2x2,
/// split card Lanjut Belajar, Tagihan Terdekat, pengingat cadangan, dan 5 transaksi terakhir.
class LayarBeranda extends ConsumerWidget {
  const LayarBeranda({super.key});

  void _bukaRuteAtauModal(
    BuildContext context,
    String rute,
    WidgetBuilder pembangunFallback,
  ) {
    final router = GoRouter.maybeOf(context);
    if (router != null) {
      router.push(rute);
      return;
    }
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: pembangunFallback));
  }

  void _navigasiGoAtauPush(BuildContext context, String rute) {
    final router = GoRouter.maybeOf(context);
    if (router != null) {
      router.go(rute);
    }
  }

  void _navigasiPush(BuildContext context, String rute) {
    final router = GoRouter.maybeOf(context);
    if (router != null) {
      router.push(rute);
    }
  }

  Widget _susunPasanganMetrik({
    required bool isTeksBesar,
    required Widget kiri,
    required Widget kanan,
  }) {
    if (isTeksBesar) {
      return Column(
        children: [
          kiri,
          const SizedBox(height: SpasiFunda.jarakPetak),
          kanan,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: kiri),
        const SizedBox(width: SpasiFunda.jarakPetak),
        Expanded(child: kanan),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daftarDompetAktif = ref.watch(penyediaDaftarDompetAktif).value ?? [];
    final totalSaldo = ref.watch(penyediaTotalSaldoAktif);
    final arusKas = ref.watch(penyediaArusKasBulanIni);
    final sisaAnggaranAsync = ref.watch(penyediaSisaAnggaranBulanIni);
    final kekayaanBersih = ref.watch(penyediaKekayaanBersih);
    final rasioCicilan = ref.watch(penyediaRasioCicilan);
    final semuaTujuan = ref.watch(penyediaDaftarTujuanAktif).value ?? [];
    final limaTransaksiAsync = ref.watch(penyediaLimaTransaksiTerakhir);
    final daftarKategori = ref.watch(penyediaDaftarKategori).value ?? [];
    final kunciTutorial = ref.watch(penyediaKunciTutorialBeranda);

    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final isTeksBesar = textScale > 1.3;

    final tujuanDanaDarurat = semuaTujuan
        .where((t) => t.jenis == 'dana_darurat' && t.status == 'aktif')
        .firstOrNull;
    final tujuanTerdekatLain = pilihTujuanTerdekat(daftarTujuan: semuaTujuan);

    return PembungkusLayar(
      bisaGulir: true,
      anak: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Pengembang (hanya muncul bila flag debug UI aktif)
          if (kDebugMode && aktifkanFiturDebugUi) ...[
            GestureDetector(
              onTap: () => _navigasiPush(context, '/galeri'),
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
                child: const Row(
                  children: [
                    Icon(LucideIcons.code, size: 20, color: WarnaFunda.utama),
                    SizedBox(width: SpasiFunda.s),
                    Expanded(
                      child: TeksFunda.label(
                        'Mode Pengembang: Buka Galeri Komponen & Token',
                        warna: WarnaFunda.utama,
                      ),
                    ),
                    Icon(
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
            const SizedBox(height: SpasiFunda.m),
            _KartuKosongBerandaEditorial(
              kunciHero: kunciTutorial.ringkasanKeuangan,
              isTeksBesar: isTeksBesar,
              padaBuatDompet: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const LayarFormDompet(),
                ),
              ),
              padaPelajariDasar: () => _navigasiPush(context, '/onboarding'),
            ),
          ] else ...[
            // Sapaan Header Ramah & Kontekstual
            Builder(
              builder: (context) {
                final sapaan = hitungSapaanKontekstual(DateTime.now());
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TeksFunda.judulLayar(sapaan.sapaan),
                    const SizedBox(height: SpasiFunda.xs),
                    TeksFunda.isiKecil(
                      sapaan.pesanMotivasi,
                      warna: WarnaFunda.teksRedup,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: SpasiFunda.l),

            // 1. Kartu Hero Atas: Arus Kas + Total Saldo & Kekayaan Bersih + Tombol Catat Transaksi
            _HeroBerandaEditorial(
              kunciHero: kunciTutorial.ringkasanKeuangan,
              arusKas: arusKas,
              totalSaldo: totalSaldo,
              jumlahDompet: daftarDompetAktif.length,
              kekayaanBersih: kekayaanBersih,
              isTeksBesar: isTeksBesar,
              padaKetukArusKas: () => _navigasiGoAtauPush(context, '/catatan'),
              padaKetukSaldo: () => _navigasiPush(context, '/dompet'),
              padaKetukKekayaan: () =>
                  _navigasiPush(context, '/kekayaan-bersih'),
              padaCatatTransaksi: () => _bukaRuteAtauModal(
                context,
                '/transaksi/tambah',
                (_) => const LayarFormTransaksi(),
              ),
            ),
            const SizedBox(height: SpasiFunda.l),

            // 2. Grid 2x2 Kartu Metrik Putih Bersih: Sisa Anggaran & Dana Darurat
            _susunPasanganMetrik(
              isTeksBesar: isTeksBesar,
              kiri: _KartuMetrikPutih(
                key: const Key('kartu_metrik_anggaran'),
                ikon: LucideIcons.pieChart,
                pathSvg: AsetIkonFunda.metrikAnggaran,
                warnaIkon: WarnaFunda.aksenIkonKuning,
                judul: 'Sisa Anggaran',
                labelAkses: 'Sisa anggaran bulan ini',
                padaKetuk: () => _navigasiPush(context, '/anggaran'),
                isiNilai: sisaAnggaranAsync.when(
                  loading: () => const Align(
                    alignment: Alignment.centerLeft,
                    child: IndikatorMemuat(ukuran: 18, ketebalan: 2),
                  ),
                  error: (_, _) => const TeksFunda.judulBagian('-'),
                  data: (sisa) => TeksFunda.judulBagian(
                    formatRupiah(sisa),
                    angkaTabular: true,
                    warna: sisa < 0 ? WarnaFunda.pengeluaran : WarnaFunda.teks,
                  ),
                ),
                keterangan: 'Bulan berjalan',
              ),
              kanan: tujuanDanaDarurat == null
                  ? _KartuMetrikPutih(
                      key: const Key('kartu_metrik_dana_darurat'),
                      ikon: LucideIcons.shieldAlert,
                      pathSvg: AsetIkonFunda.metrikDanaDarurat,
                      warnaIkon: WarnaFunda.aksenIkonMint,
                      judul: 'Dana Darurat',
                      labelAkses: 'Dana darurat',
                      padaKetuk: () => _navigasiPush(context, '/tujuan'),
                      isiNilai: const TeksFunda.judulBagian('Belum Ada'),
                      keterangan: 'Siapkan jaring amanmu',
                    )
                  : Consumer(
                      builder: (context, ref, _) {
                        final danaTerkumpul =
                            ref
                                .watch(penyediaDanaTujuan(tujuanDanaDarurat.id))
                                .value ??
                            0;
                        final progres = hitungProgresTujuan(
                          danaRupiah: danaTerkumpul,
                          targetRupiah: tujuanDanaDarurat.targetRupiah,
                        );
                        return _KartuMetrikPutih(
                          key: const Key('kartu_metrik_dana_darurat'),
                          ikon: LucideIcons.shieldCheck,
                          pathSvg: AsetIkonFunda.metrikDanaDarurat,
                          warnaIkon: WarnaFunda.aksenIkonMint,
                          judul: 'Dana Darurat',
                          labelAkses: 'Dana darurat $progres persen',
                          padaKetuk: () => _navigasiPush(context, '/tujuan'),
                          isiNilai: TeksFunda.judulBagian(
                            '$progres%',
                            angkaTabular: true,
                          ),
                          keterangan: formatRupiah(danaTerkumpul),
                        );
                      },
                    ),
            ),
            const SizedBox(height: SpasiFunda.jarakPetak),

            // 3. Grid 2x2 Kartu Metrik Putih Bersih: Rasio Cicilan & Tujuan Terdekat
            _susunPasanganMetrik(
              isTeksBesar: isTeksBesar,
              kiri: _KartuMetrikPutih(
                key: const Key('kartu_metrik_rasio_cicilan'),
                ikon: LucideIcons.creditCard,
                pathSvg: AsetIkonFunda.metrikRasioCicilan,
                warnaIkon: WarnaFunda.aksenIkonKoral,
                judul: 'Rasio Cicilan',
                labelAkses: 'Rasio cicilan bulanan',
                padaKetuk: () => _navigasiPush(context, '/utang'),
                isiNilai: TeksFunda.judulBagian(
                  rasioCicilan != null ? '$rasioCicilan%' : '0%',
                  angkaTabular: true,
                ),
                keterangan: 'Beban cicilanmu',
              ),
              kanan: tujuanTerdekatLain == null
                  ? _KartuMetrikPutih(
                      key: const Key('kartu_metrik_tujuan'),
                      ikon: LucideIcons.target,
                      pathSvg: AsetIkonFunda.metrikTujuan,
                      warnaIkon: WarnaFunda.aksenIkonBiru,
                      judul: 'Tujuan Impian',
                      labelAkses: 'Tujuan terdekat',
                      padaKetuk: () => _navigasiPush(context, '/tujuan'),
                      isiNilai: const TeksFunda.judulBagian('Belum Ada'),
                      keterangan: 'Pasang target pertamamu',
                    )
                  : Consumer(
                      builder: (context, ref, _) {
                        final danaTerkumpul =
                            ref
                                .watch(
                                  penyediaDanaTujuan(tujuanTerdekatLain.id),
                                )
                                .value ??
                            0;
                        final progres = hitungProgresTujuan(
                          danaRupiah: danaTerkumpul,
                          targetRupiah: tujuanTerdekatLain.targetRupiah,
                        );
                        return _KartuMetrikPutih(
                          key: const Key('kartu_metrik_tujuan'),
                          ikon: LucideIcons.target,
                          pathSvg: AsetIkonFunda.metrikTujuan,
                          warnaIkon: WarnaFunda.aksenIkonBiru,
                          judul: tujuanTerdekatLain.nama,
                          labelAkses:
                              'Tujuan ${tujuanTerdekatLain.nama} $progres persen',
                          padaKetuk: () => _navigasiPush(context, '/tujuan'),
                          isiNilai: TeksFunda.judulBagian(
                            '$progres%',
                            angkaTabular: true,
                          ),
                          keterangan: formatRupiah(danaTerkumpul),
                        );
                      },
                    ),
            ),
            const SizedBox(height: SpasiFunda.l),

            // 4. Split Card Lanjut Belajar (ketuk langsung, tanpa tombol gelap ke-2)
            ref
                .watch(penyediaLanjutBelajarBeranda)
                .when(
                  data: (info) => Padding(
                    padding: const EdgeInsets.only(
                      bottom: SpasiFunda.jarakPetak,
                    ),
                    child: _SplitCardLanjutBelajar(
                      info: info,
                      isTeksBesar: isTeksBesar,
                      padaKetuk: () => _navigasiPush(context, info.rute),
                    ),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),

            // 5. Kartu Tagihan Terdekat Putih Ramping
            Consumer(
              builder: (context, ref, _) {
                final tagihanTerdekatAsync = ref.watch(
                  penyediaTagihanTerdekatBeranda,
                );
                return tagihanTerdekatAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                  data: (tagihan) => Padding(
                    padding: const EdgeInsets.only(
                      bottom: SpasiFunda.jarakPetak,
                    ),
                    child: _KartuTagihanBeranda(
                      tagihan: tagihan,
                      padaKetuk: () => _navigasiPush(context, '/tagihan'),
                    ),
                  ),
                );
              },
            ),

            // 6. Banner Pengingat Cadangan (kartu ramping putih beraksen amber sebelum transaksi)
            Consumer(
              builder: (context, ref, _) {
                final statusCadangan = ref
                    .watch(penyediaStatusCadangan)
                    .asData
                    ?.value;
                if (statusCadangan == null || !statusCadangan.perluPengingat) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: SpasiFunda.jarakPetak),
                  child: _BannerPengingatCadangan(
                    padaNanti: () =>
                        tundaPengingatCadangan(ref, durasiHari: 14),
                    padaCadangkan: () => _navigasiPush(context, '/cadangan'),
                  ),
                );
              },
            ),

            // 7. Kartu Putih 5 Transaksi Terakhir
            _KartuTransaksiTerakhir(
              limaTransaksiAsync: limaTransaksiAsync,
              daftarKategori: daftarKategori,
              padaLihatSemua: () => _navigasiGoAtauPush(context, '/catatan'),
            ),
            const SizedBox(height: SpasiFunda.xl),
          ],
        ],
      ),
    );
  }
}

class _KartuKosongBerandaEditorial extends StatelessWidget {
  final GlobalKey kunciHero;
  final bool isTeksBesar;
  final VoidCallback padaBuatDompet;
  final VoidCallback padaPelajariDasar;

  const _KartuKosongBerandaEditorial({
    required this.kunciHero,
    required this.isTeksBesar,
    required this.padaBuatDompet,
    required this.padaPelajariDasar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          key: kunciHero,
          decoration: BoxDecoration(
            color: WarnaFunda.permukaan,
            borderRadius: BorderRadius.circular(SudutFunda.petak),
            border: Border.all(color: WarnaFunda.garis),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                color: WarnaFunda.kanvasMint,
                padding: const EdgeInsets.symmetric(
                  vertical: SpasiFunda.xl,
                  horizontal: SpasiFunda.l,
                ),
                child: Center(
                  child: IlustrasiSvgFunda(
                    pathAset: AsetIlustrasiFunda.dompet,
                    tinggi: isTeksBesar ? 88 : 124,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(SpasiFunda.l),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TeksFunda.judulLayar('Selamat Datang di Funda'),
                    const SizedBox(height: SpasiFunda.s),
                    const TeksFunda.isiKecil(
                      'Mulai kelola uangmu dengan rapi. Buat dompet pertamamu untuk mencatat pemasukan dan pengeluaran.',
                      warna: WarnaFunda.teksRedup,
                    ),
                    const SizedBox(height: SpasiFunda.l),
                    TombolFunda.pilGelap(
                      teks: 'Buat Dompet Pertamamu',
                      padaTekan: padaBuatDompet,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: SpasiFunda.m),
        Center(
          child: TextButton.icon(
            onPressed: padaPelajariDasar,
            icon: const IkonSvgFunda(
              pathAset: AsetIkonFunda.menuPanduan,
              ukuran: 18,
            ),
            label: const Text('Pelajari Nilai Dasar Funda'),
          ),
        ),
      ],
    );
  }
}

class _HeroBerandaEditorial extends StatelessWidget {
  final GlobalKey kunciHero;
  final dynamic arusKas;
  final int totalSaldo;
  final int jumlahDompet;
  final int kekayaanBersih;
  final bool isTeksBesar;
  final VoidCallback padaKetukArusKas;
  final VoidCallback padaKetukSaldo;
  final VoidCallback padaKetukKekayaan;
  final VoidCallback padaCatatTransaksi;

  const _HeroBerandaEditorial({
    required this.kunciHero,
    required this.arusKas,
    required this.totalSaldo,
    required this.jumlahDompet,
    required this.kekayaanBersih,
    required this.isTeksBesar,
    required this.padaKetukArusKas,
    required this.padaKetukSaldo,
    required this.padaKetukKekayaan,
    required this.padaCatatTransaksi,
  });

  @override
  Widget build(BuildContext context) {
    final int selisih = arusKas.selisih as int;
    final int totalMasuk = arusKas.totalMasuk as int;
    final int totalKeluar = arusKas.totalKeluar as int;

    return Container(
      key: kunciHero,
      decoration: BoxDecoration(
        color: WarnaFunda.kanvasMint,
        borderRadius: BorderRadius.circular(SudutFunda.petak),
        border: Border.all(color: WarnaFunda.batasHijau),
      ),
      padding: const EdgeInsets.all(SpasiFunda.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bagian Arus Kas Bulan Ini (ketuk menuju Catatan)
          Semantics(
            button: true,
            label: 'Arus kas bulan ini selisih ${formatRupiah(selisih)}',
            child: InkWell(
              onTap: padaKetukArusKas,
              borderRadius: BorderRadius.circular(SudutFunda.kartu),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.activity,
                              size: 18,
                              color: WarnaFunda.utamaGelap,
                            ),
                            SizedBox(width: SpasiFunda.s),
                            Flexible(
                              child: TeksFunda.label(
                                'Arus Kas Bulan Ini',
                                warna: WarnaFunda.teks,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: SpasiFunda.s),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: SpasiFunda.s,
                          vertical: SpasiFunda.xs,
                        ),
                        decoration: BoxDecoration(
                          color: WarnaFunda.permukaan,
                          borderRadius: BorderRadius.circular(SudutFunda.pil),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              selisih >= 0
                                  ? LucideIcons.trendingUp
                                  : LucideIcons.trendingDown,
                              size: 14,
                              color: selisih >= 0
                                  ? WarnaFunda.pemasukan
                                  : WarnaFunda.pengeluaran,
                            ),
                            const SizedBox(width: SpasiFunda.xs),
                            TeksFunda.catatan(
                              selisih >= 0 ? 'Surplus' : 'Defisit',
                              warna: selisih >= 0
                                  ? WarnaFunda.pemasukan
                                  : WarnaFunda.pengeluaran,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: SpasiFunda.s),
                  TeksAngkaAnimasi(
                    nilai: selisih,
                    gaya: TipografiFunda.angkaBesar.copyWith(
                      color: selisih < 0
                          ? WarnaFunda.pengeluaran
                          : WarnaFunda.teks,
                    ),
                  ),
                  const SizedBox(height: SpasiFunda.xs),
                  TeksFunda.catatan(
                    'Masuk: ${formatRupiah(totalMasuk)} • Keluar: ${formatRupiah(totalKeluar)}',
                    warna: WarnaFunda.teksRedup,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: SpasiFunda.m),
          const Divider(height: 1, color: WarnaFunda.batasHijau),
          const SizedBox(height: SpasiFunda.m),

          // Baris Ringkas Total Saldo & Kekayaan Bersih (ketuk ke detail masing-masing)
          if (isTeksBesar)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ItemRingkasHero(
                  key: const Key('hero_total_saldo'),
                  label: 'Total Saldo ($jumlahDompet dompet)',
                  nilai: totalSaldo,
                  ikon: LucideIcons.wallet,
                  pathSvg: AsetIkonFunda.menuDompet,
                  warnaIkon: WarnaFunda.utamaGelap,
                  padaKetuk: padaKetukSaldo,
                ),
                const SizedBox(height: SpasiFunda.s),
                _ItemRingkasHero(
                  key: const Key('hero_kekayaan_bersih'),
                  label: 'Kekayaan Bersih',
                  nilai: kekayaanBersih,
                  ikon: LucideIcons.scale,
                  pathSvg: AsetIkonFunda.menuKekayaan,
                  warnaIkon: WarnaFunda.sifatKebutuhan,
                  padaKetuk: padaKetukKekayaan,
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: _ItemRingkasHero(
                    key: const Key('hero_total_saldo'),
                    label: 'Total Saldo',
                    nilai: totalSaldo,
                    ikon: LucideIcons.wallet,
                    pathSvg: AsetIkonFunda.menuDompet,
                    warnaIkon: WarnaFunda.utamaGelap,
                    padaKetuk: padaKetukSaldo,
                  ),
                ),
                Container(
                  width: 1,
                  height: 36,
                  margin: const EdgeInsets.symmetric(horizontal: SpasiFunda.m),
                  color: WarnaFunda.batasHijau,
                ),
                Expanded(
                  child: _ItemRingkasHero(
                    key: const Key('hero_kekayaan_bersih'),
                    label: 'Kekayaan Bersih',
                    nilai: kekayaanBersih,
                    ikon: LucideIcons.scale,
                    pathSvg: AsetIkonFunda.menuKekayaan,
                    warnaIkon: WarnaFunda.sifatKebutuhan,
                    padaKetuk: padaKetukKekayaan,
                  ),
                ),
              ],
            ),

          const SizedBox(height: SpasiFunda.l),
          TombolFunda.pilGelap(
            key: const Key('tombol_catat_transaksi_beranda'),
            teks: 'Catat Transaksi',
            ikon: const Icon(
              LucideIcons.plus,
              size: 18,
              color: WarnaFunda.teksPutih,
            ),
            padaTekan: padaCatatTransaksi,
          ),
        ],
      ),
    );
  }
}

class _ItemRingkasHero extends StatelessWidget {
  final String label;
  final int nilai;
  final IconData ikon;
  final String? pathSvg;
  final Color warnaIkon;
  final VoidCallback padaKetuk;

  const _ItemRingkasHero({
    super.key,
    required this.label,
    required this.nilai,
    required this.ikon,
    this.pathSvg,
    required this.warnaIkon,
    required this.padaKetuk,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$label ${formatRupiah(nilai)}',
      child: InkWell(
        onTap: padaKetuk,
        borderRadius: BorderRadius.circular(SudutFunda.kecil),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (pathSvg != null)
                    IkonSvgFunda(pathAset: pathSvg!, ukuran: 16)
                  else
                    Icon(ikon, size: 14, color: warnaIkon),
                  const SizedBox(width: SpasiFunda.xs),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TipografiFunda.catatan.copyWith(
                        color: WarnaFunda.teksRedup,
                      ),
                    ),
                  ),
                  const Icon(
                    LucideIcons.chevronRight,
                    size: 14,
                    color: WarnaFunda.teksRedup,
                  ),
                ],
              ),
              const SizedBox(height: 2),
              TeksAngkaAnimasi(
                nilai: nilai,
                gaya: TipografiFunda.label.copyWith(
                  color: nilai < 0 ? WarnaFunda.pengeluaran : WarnaFunda.teks,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KartuMetrikPutih extends StatelessWidget {
  final IconData ikon;
  final String? pathSvg;
  final Color warnaIkon;
  final String judul;
  final Widget isiNilai;
  final String keterangan;
  final String labelAkses;
  final VoidCallback padaKetuk;

  const _KartuMetrikPutih({
    super.key,
    required this.ikon,
    this.pathSvg,
    required this.warnaIkon,
    required this.judul,
    required this.isiNilai,
    required this.keterangan,
    required this.labelAkses,
    required this.padaKetuk,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: labelAkses,
      child: Container(
        decoration: BoxDecoration(
          color: WarnaFunda.permukaan,
          borderRadius: BorderRadius.circular(SudutFunda.petak),
          border: Border.all(color: WarnaFunda.garis, width: 1.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: WarnaFunda.transparan,
          child: InkWell(
            onTap: padaKetuk,
            child: Padding(
              padding: const EdgeInsets.all(SpasiFunda.l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (pathSvg != null)
                        IkonSvgFunda(pathAset: pathSvg!, ukuran: 24)
                      else
                        Icon(ikon, size: 22, color: warnaIkon),
                      const Icon(
                        LucideIcons.chevronRight,
                        size: 16,
                        color: WarnaFunda.teksRedup,
                      ),
                    ],
                  ),
                  const SizedBox(height: SpasiFunda.m),
                  Text(
                    judul,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TipografiFunda.isiKecil.copyWith(
                      color: WarnaFunda.teksRedup,
                    ),
                  ),
                  const SizedBox(height: SpasiFunda.xs),
                  isiNilai,
                  const SizedBox(height: SpasiFunda.xs),
                  Text(
                    keterangan,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TipografiFunda.catatan.copyWith(
                      color: WarnaFunda.teksRedup,
                    ),
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

class _SplitCardLanjutBelajar extends StatelessWidget {
  final InfoLanjutBelajar info;
  final bool isTeksBesar;
  final VoidCallback padaKetuk;

  const _SplitCardLanjutBelajar({
    required this.info,
    required this.isTeksBesar,
    required this.padaKetuk,
  });

  String _ambilPathSvgLanjutBelajar(String rute) {
    final segmen = Uri.tryParse(rute)?.pathSegments ?? const [];
    if (segmen.contains('tes-awal')) {
      return AsetIlustrasiFunda.mulaiTesAwal;
    }
    if (segmen.length >= 3 &&
        (segmen[1] == 'pelajaran' || segmen[1] == 'modul')) {
      return temaVisualUntukModul(segmen[2]).pathSvg;
    }
    return AsetIlustrasiFunda.mulaiTesAwal;
  }

  @override
  Widget build(BuildContext context) {
    final pathSvg = _ambilPathSvgLanjutBelajar(info.rute);
    return Semantics(
      button: true,
      label: 'Pelajaran keuangan: ${info.labelAksi} ${info.judul}',
      child: Container(
        key: const Key('kartu_lanjut_belajar_beranda'),
        decoration: BoxDecoration(
          color: WarnaFunda.permukaan,
          borderRadius: BorderRadius.circular(SudutFunda.petak),
          border: Border.all(color: WarnaFunda.garis, width: 1.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: WarnaFunda.transparan,
          child: InkWell(
            onTap: padaKetuk,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!isTeksBesar)
                    Expanded(
                      flex: 34,
                      child: Container(
                        color: WarnaFunda.kanvasUngu,
                        padding: const EdgeInsets.all(SpasiFunda.m),
                        child: Center(
                          child: IlustrasiSvgFunda(
                            pathAset: pathSvg,
                            tinggi: 76,
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    flex: 66,
                    child: Padding(
                      padding: const EdgeInsets.all(SpasiFunda.l),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TeksFunda.catatan(
                            info.labelAksi,
                            warna: WarnaFunda.sifatKeinginan,
                          ),
                          const SizedBox(height: SpasiFunda.xs),
                          TeksFunda.judulBagian(info.judul),
                          const SizedBox(height: SpasiFunda.xs),
                          TeksFunda.catatan(
                            info.keterangan,
                            warna: WarnaFunda.teksRedup,
                          ),
                          const SizedBox(height: SpasiFunda.m),
                          const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TeksFunda.label(
                                'Buka materi',
                                warna: WarnaFunda.utama,
                              ),
                              SizedBox(width: SpasiFunda.xs),
                              Icon(
                                LucideIcons.arrowRight,
                                size: 16,
                                color: WarnaFunda.utama,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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

class _KartuTagihanBeranda extends StatelessWidget {
  final dynamic tagihan;
  final VoidCallback padaKetuk;

  const _KartuTagihanBeranda({required this.tagihan, required this.padaKetuk});

  @override
  Widget build(BuildContext context) {
    if (tagihan == null) {
      return Semantics(
        button: true,
        label: 'Tagihan terdekat: Tidak ada tagihan dalam 7 hari ke depan',
        child: Container(
          decoration: BoxDecoration(
            color: WarnaFunda.permukaan,
            borderRadius: BorderRadius.circular(SudutFunda.petak),
            border: Border.all(color: WarnaFunda.garis, width: 1.0),
          ),
          clipBehavior: Clip.antiAlias,
          child: Material(
            color: WarnaFunda.transparan,
            child: InkWell(
              onTap: padaKetuk,
              child: const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: SpasiFunda.l,
                  vertical: SpasiFunda.m,
                ),
                child: Row(
                  children: [
                    IkonSvgFunda(
                      pathAset: AsetIkonFunda.menuTagihan,
                      ukuran: 24,
                    ),
                    SizedBox(width: SpasiFunda.m),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TeksFunda.label('Tagihan Terdekat'),
                          SizedBox(height: 2),
                          TeksFunda.catatan(
                            'Tidak ada tagihan dalam 7 hari ke depan. Aman!',
                            warna: WarnaFunda.teksRedup,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      LucideIcons.chevronRight,
                      size: 18,
                      color: WarnaFunda.teksRedup,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    final isLewat =
        tagihan.status == StatusKemunculan.lewat ||
        tagihan.status == StatusKemunculan.lewatKedaluwarsa;
    final isHariIni = tagihan.status == StatusKemunculan.hariIni;

    final String infoStatus;
    if (isLewat) {
      infoStatus = 'Lewat ${-(tagihan.selisihHari as int)} hari';
    } else if (isHariIni) {
      infoStatus = 'Hari ini';
    } else {
      infoStatus = tagihan.selisihHari == 1
          ? 'Besok'
          : '${tagihan.selisihHari} hari lagi';
    }

    final warnaIkon = isLewat
        ? WarnaFunda.pengeluaran
        : (isHariIni ? WarnaFunda.peringatan : WarnaFunda.aksenIkonBiru);
    final warnaPil = isLewat
        ? WarnaFunda.tintMawar
        : (isHariIni ? WarnaFunda.tintAmber : WarnaFunda.tintNetral);
    final warnaTeksPil = isLewat
        ? WarnaFunda.pengeluaran
        : (isHariIni ? WarnaFunda.peringatan : WarnaFunda.teksRedup);
    final int? perkiraan = tagihan.jumlahPerkiraanRupiah as int?;

    return Semantics(
      button: true,
      label:
          'Tagihan terdekat: ${tagihan.nama}, $infoStatus, perkiraan ${perkiraan != null ? formatRupiah(perkiraan) : "fluktuatif"}',
      child: Container(
        decoration: BoxDecoration(
          color: WarnaFunda.permukaan,
          borderRadius: BorderRadius.circular(SudutFunda.petak),
          border: Border.all(color: WarnaFunda.garis, width: 1.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
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
                  Icon(
                    isLewat
                        ? LucideIcons.circleAlert
                        : (isHariIni
                              ? LucideIcons.clock
                              : LucideIcons.calendarClock),
                    color: warnaIkon,
                    size: 24,
                  ),
                  const SizedBox(width: SpasiFunda.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: SpasiFunda.s,
                          runSpacing: SpasiFunda.xs,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              tagihan.nama as String,
                              style: TipografiFunda.label,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: SpasiFunda.s,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: warnaPil,
                                borderRadius: BorderRadius.circular(
                                  SudutFunda.pil,
                                ),
                              ),
                              child: TeksFunda.catatan(
                                infoStatus,
                                warna: warnaTeksPil,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        TeksFunda.catatan(
                          perkiraan != null && perkiraan > 0
                              ? 'Perkiraan: ${formatRupiah(perkiraan)}'
                              : 'Nominal fluktuatif',
                          warna: WarnaFunda.teksRedup,
                        ),
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
        ),
      ),
    );
  }
}

class _BannerPengingatCadangan extends StatelessWidget {
  final VoidCallback padaNanti;
  final VoidCallback padaCadangkan;

  const _BannerPengingatCadangan({
    required this.padaNanti,
    required this.padaCadangkan,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('banner_pengingat_cadangan_beranda'),
      decoration: BoxDecoration(
        color: WarnaFunda.permukaan,
        borderRadius: BorderRadius.circular(SudutFunda.petak),
        border: Border.all(color: WarnaFunda.batasAmber, width: 1.0),
      ),
      padding: const EdgeInsets.all(SpasiFunda.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              IlustrasiSvgFunda(
                pathAset: AsetIlustrasiFunda.cadanganData,
                tinggi: 34,
              ),
              SizedBox(width: SpasiFunda.s),
              Expanded(
                child: TeksFunda.label('Yuk, amankan catatan keuanganmu'),
              ),
            ],
          ),
          const SizedBox(height: SpasiFunda.xs),
          const TeksFunda.catatan(
            'Simpan salinan data keuanganmu agar tetap aman jika ganti perangkat.',
            warna: WarnaFunda.teksRedup,
          ),
          const SizedBox(height: SpasiFunda.m),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: SpasiFunda.s,
            runSpacing: SpasiFunda.xs,
            children: [
              TextButton(onPressed: padaNanti, child: const Text('Nanti')),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: WarnaFunda.utama,
                  side: const BorderSide(color: WarnaFunda.utama),
                  shape: const StadiumBorder(),
                ),
                onPressed: padaCadangkan,
                child: const Text('Cadangkan sekarang'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KartuTransaksiTerakhir extends StatelessWidget {
  final AsyncValue<List<dynamic>> limaTransaksiAsync;
  final List<dynamic> daftarKategori;
  final VoidCallback padaLihatSemua;

  const _KartuTransaksiTerakhir({
    required this.limaTransaksiAsync,
    required this.daftarKategori,
    required this.padaLihatSemua,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: WarnaFunda.permukaan,
        borderRadius: BorderRadius.circular(SudutFunda.petak),
        border: Border.all(color: WarnaFunda.garis, width: 1.0),
      ),
      padding: const EdgeInsets.all(SpasiFunda.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: SpasiFunda.m,
            runSpacing: SpasiFunda.xs,
            children: [
              const TeksFunda.judulBagian('5 Transaksi Terakhir'),
              Semantics(
                button: true,
                label: 'Buka riwayat lengkap catatan transaksi',
                child: InkWell(
                  onTap: padaLihatSemua,
                  borderRadius: BorderRadius.circular(SudutFunda.kecil),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TeksFunda.catatan(
                          'Lihat Semua',
                          warna: WarnaFunda.utama,
                        ),
                        SizedBox(width: SpasiFunda.xs),
                        Icon(
                          LucideIcons.chevronRight,
                          size: 14,
                          color: WarnaFunda.utama,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: SpasiFunda.m),
          limaTransaksiAsync.when(
            loading: () => const Center(child: IndikatorMemuat()),
            error: (_, _) => const TeksFunda.catatan('Gagal memuat transaksi.'),
            data: (daftar) {
              if (daftar.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: SpasiFunda.s),
                  child: TeksFunda.catatan(
                    'Belum ada transaksi tercatat. Mulai catat pemasukan atau pengeluaranmu!',
                    warna: WarnaFunda.teksRedup,
                  ),
                );
              }
              final potongan = daftar.take(5).toList();
              return Column(
                children: potongan.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final t = entry.value;
                  final kategori = daftarKategori
                      .where((k) => k.id == t.kategoriId)
                      .firstOrNull;
                  final jenis = t.jenis as String;
                  final isMasuk = jenis == 'masuk';
                  final isTransfer = jenis == 'transfer';
                  final warnaNominal = isMasuk
                      ? WarnaFunda.pemasukan
                      : (isTransfer
                            ? WarnaFunda.utama
                            : WarnaFunda.pengeluaran);

                  final judul =
                      (kategori?.nama as String?) ??
                      (isTransfer ? 'Transfer Dompet' : 'Transaksi');
                  final String? catatan = t.catatan as String?;

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: SpasiFunda.s,
                        ),
                        child: Row(
                          children: [
                            if (isTransfer)
                              const IkonSvgFunda(
                                pathAset: AsetIkonFunda.transaksiTransfer,
                                ukuran: 20,
                              )
                            else
                              IkonKategoriFunda(
                                kunciIkon:
                                    (kategori?.ikon as String?) ?? 'receipt',
                                ukuran: 20,
                                warnaFallback: warnaNominal,
                              ),
                            const SizedBox(width: SpasiFunda.m),
                            Expanded(
                              child: Text(
                                catatan != null && catatan.isNotEmpty
                                    ? '$judul • $catatan'
                                    : judul,
                                style: TipografiFunda.isiKecil.copyWith(
                                  color: WarnaFunda.teks,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: SpasiFunda.s),
                            Text(
                              '${isMasuk ? '+' : '-'} ${formatRupiah(t.jumlahRupiah as int)}',
                              style: TipografiFunda.catatan.copyWith(
                                color: warnaNominal,
                                fontWeight: FontWeight.w600,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (idx < potongan.length - 1)
                        const Divider(height: 1, color: WarnaFunda.garis),
                    ],
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
