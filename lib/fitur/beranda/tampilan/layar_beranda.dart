import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../data/penyedia_data.dart';
import '../../../komponen/komponen_funda.dart';
import '../../../komponen/pembantu_ikon.dart';
import '../../../perhitungan/perhitungan_anggaran_tujuan.dart';
import '../../../perhitungan/perhitungan_utang_dashboard.dart';
import '../../../tema/token.dart';
import '../../../util/format_rupiah.dart';
import '../../anggaran/kontroler/penyedia_anggaran.dart';
import '../../belajar/kontroler/penyedia_belajar.dart';
import '../../dompet/tampilan/layar_form_dompet.dart';
import '../../tagihan/kontroler/penyedia_tagihan.dart';
import '../../../perhitungan/perhitungan_tagihan.dart';
import '../../tujuan/kontroler/penyedia_tujuan.dart';
import '../../utang/kontroler/penyedia_utang.dart';
import '../../cadangan/kontroler/penyedia_cadangan.dart';

/// Layar Beranda utama aplikasi Funda.
/// Dashboard penuh dengan ~8 petak bento (data nyata) dan modul pendukung.
class LayarBeranda extends ConsumerWidget {
  const LayarBeranda({super.key});

  Widget _susunPasanganBento({
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
                    const Expanded(
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

            // Banner Pengingat Cadangan 2x1 (bahasa santai, ajakan ramah)
            Consumer(
              builder: (context, ref, _) {
                final statusCadangan = ref.watch(penyediaStatusCadangan).asData?.value;
                if (statusCadangan == null || !statusCadangan.perluPengingat) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: SpasiFunda.l),
                  child: PetakBento.ukuran2x1(
                    tint: TintPetakBento.amber,
                    anak: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(LucideIcons.shieldCheck, size: 20, color: WarnaFunda.utama),
                            SizedBox(width: SpasiFunda.s),
                            Expanded(
                              child: TeksFunda.label('Yuk, amankan catatan keuanganmu'),
                            ),
                          ],
                        ),
                        const SizedBox(height: SpasiFunda.xs),
                        const TeksFunda.catatan(
                          'Simpan salinan data keuanganmu agar tetap aman jika ganti perangkat.',
                        ),
                        const SizedBox(height: SpasiFunda.m),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => tundaPengingatCadangan(ref, durasiHari: 14),
                              child: const Text('Nanti'),
                            ),
                            const SizedBox(width: SpasiFunda.s),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: WarnaFunda.utama,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () => context.push('/cadangan'),
                              child: const Text('Cadangkan sekarang'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // 1. Bento 2x1: Hero Arus Kas Bulan Ini (DATA NYATA) -> /catatan
            PetakBento.ukuran2x1(
              tint: TintPetakBento.hijau,
              padaKetuk: () => context.go('/catatan'),
              labelAkses:
                  'Arus kas bulan ini selisih ${formatRupiah(arusKas.selisih)}',
              anak: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: TeksFunda.isiKecil('Arus Kas Bulan Ini'),
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

            // Baris Bento 1x1: 2. Total Saldo & 3. Kekayaan Bersih
            _susunPasanganBento(
              isTeksBesar: isTeksBesar,
              kiri: PetakBento(
                ukuran: isTeksBesar
                    ? UkuranPetakBento.petak2x1
                    : UkuranPetakBento.petak1x1,
                tint: TintPetakBento.biru,
                padaKetuk: () => context.push('/dompet'),
                labelAkses: 'Total saldo ${formatRupiah(totalSaldo)}',
                anak: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(SpasiFunda.xs),
                      decoration: BoxDecoration(
                        color: WarnaFunda.permukaan,
                        borderRadius: BorderRadius.circular(SudutFunda.kecil),
                      ),
                      child: const Icon(
                        LucideIcons.wallet,
                        size: 18,
                        color: WarnaFunda.utama,
                      ),
                    ),
                    const SizedBox(height: SpasiFunda.m),
                    const TeksFunda.isiKecil('Total Saldo'),
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
              kanan: PetakBento(
                ukuran: isTeksBesar
                    ? UkuranPetakBento.petak2x1
                    : UkuranPetakBento.petak1x1,
                tint: TintPetakBento.ungu,
                padaKetuk: () => context.push('/kekayaan-bersih'),
                labelAkses: 'Kekayaan bersih ${formatRupiah(kekayaanBersih)}',
                anak: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(SpasiFunda.xs),
                      decoration: BoxDecoration(
                        color: WarnaFunda.permukaan,
                        borderRadius: BorderRadius.circular(SudutFunda.kecil),
                      ),
                      child: const Icon(
                        LucideIcons.scale,
                        size: 18,
                        color: WarnaFunda.sifatKeinginan,
                      ),
                    ),
                    const SizedBox(height: SpasiFunda.m),
                    const TeksFunda.isiKecil('Kekayaan Bersih'),
                    const SizedBox(height: SpasiFunda.xs),
                    TeksFunda.judulBagian(
                      formatRupiah(kekayaanBersih),
                      angkaTabular: true,
                      warna: kekayaanBersih < 0
                          ? WarnaFunda.pengeluaran
                          : WarnaFunda.teks,
                    ),
                    const SizedBox(height: SpasiFunda.xs),
                    const TeksFunda.catatan('Aset dikurangi utang'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: SpasiFunda.jarakPetak),

            // Baris Bento 1x1: 4. Sisa Anggaran & 5. Dana Darurat
            _susunPasanganBento(
              isTeksBesar: isTeksBesar,
              kiri: PetakBento(
                ukuran: isTeksBesar
                    ? UkuranPetakBento.petak2x1
                    : UkuranPetakBento.petak1x1,
                tint: TintPetakBento.amber,
                padaKetuk: () => context.push('/anggaran'),
                labelAkses: 'Sisa anggaran bulan ini',
                anak: sisaAnggaranAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) => const Center(child: Text('Gagal')),
                  data: (sisa) {
                    return Column(
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
                            LucideIcons.pieChart,
                            size: 18,
                            color: WarnaFunda.sifatKebutuhan,
                          ),
                        ),
                        const SizedBox(height: SpasiFunda.m),
                        const TeksFunda.isiKecil('Sisa Anggaran'),
                        const SizedBox(height: SpasiFunda.xs),
                        TeksFunda.judulBagian(
                          formatRupiah(sisa),
                          angkaTabular: true,
                          warna: sisa < 0
                              ? WarnaFunda.pengeluaran
                              : WarnaFunda.teks,
                        ),
                        const SizedBox(height: SpasiFunda.xs),
                        const TeksFunda.catatan('Bulan berjalan'),
                      ],
                    );
                  },
                ),
              ),
              kanan: PetakBento(
                ukuran: isTeksBesar
                    ? UkuranPetakBento.petak2x1
                    : UkuranPetakBento.petak1x1,
                tint: TintPetakBento.hijau,
                padaKetuk: () => context.push('/tujuan'),
                labelAkses: 'Dana darurat',
                anak: tujuanDanaDarurat == null
                    ? Column(
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
                              LucideIcons.shieldAlert,
                              size: 18,
                              color: WarnaFunda.teksRedup,
                            ),
                          ),
                          const SizedBox(height: SpasiFunda.m),
                          const TeksFunda.isiKecil('Dana Darurat'),
                          const SizedBox(height: SpasiFunda.xs),
                          const TeksFunda.judulBagian('Belum Ada'),
                          const SizedBox(height: SpasiFunda.xs),
                          const TeksFunda.catatan('Siapkan jaring amanmu'),
                        ],
                      )
                    : Consumer(
                        builder: (context, ref, _) {
                          final danaTerkumpul =
                              ref
                                  .watch(
                                    penyediaDanaTujuan(tujuanDanaDarurat.id),
                                  )
                                  .value ??
                              0;
                          final progres = hitungProgresTujuan(
                            danaRupiah: danaTerkumpul,
                            targetRupiah: tujuanDanaDarurat.targetRupiah,
                          );
                          return Column(
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
                                  color: WarnaFunda.sukses,
                                ),
                              ),
                              const SizedBox(height: SpasiFunda.m),
                              const TeksFunda.isiKecil('Dana Darurat'),
                              const SizedBox(height: SpasiFunda.xs),
                              TeksFunda.judulBagian('$progres%'),
                              const SizedBox(height: SpasiFunda.xs),
                              TeksFunda.catatan(formatRupiah(danaTerkumpul)),
                            ],
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(height: SpasiFunda.jarakPetak),

            // Baris Bento 1x1: 6. Rasio Cicilan & 7. Tujuan Terdekat
            _susunPasanganBento(
              isTeksBesar: isTeksBesar,
              kiri: PetakBento(
                ukuran: isTeksBesar
                    ? UkuranPetakBento.petak2x1
                    : UkuranPetakBento.petak1x1,
                tint: TintPetakBento.amber,
                padaKetuk: () => context.push('/utang'),
                labelAkses: 'Rasio cicilan bulanan',
                anak: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(SpasiFunda.xs),
                      decoration: BoxDecoration(
                        color: WarnaFunda.permukaan,
                        borderRadius: BorderRadius.circular(SudutFunda.kecil),
                      ),
                      child: const Icon(
                        LucideIcons.creditCard,
                        size: 18,
                        color: WarnaFunda.sifatUtang,
                      ),
                    ),
                    const SizedBox(height: SpasiFunda.m),
                    const TeksFunda.isiKecil('Rasio Cicilan'),
                    const SizedBox(height: SpasiFunda.xs),
                    TeksFunda.judulBagian(
                      rasioCicilan != null ? '$rasioCicilan%' : '0%',
                      angkaTabular: true,
                    ),
                    const SizedBox(height: SpasiFunda.xs),
                    const TeksFunda.catatan('Beban cicilanmu'),
                  ],
                ),
              ),
              kanan: PetakBento(
                ukuran: isTeksBesar
                    ? UkuranPetakBento.petak2x1
                    : UkuranPetakBento.petak1x1,
                tint: TintPetakBento.netral,
                padaKetuk: () => context.push('/tujuan'),
                labelAkses: 'Tujuan terdekat',
                anak: tujuanTerdekatLain == null
                    ? Column(
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
                              LucideIcons.target,
                              size: 18,
                              color: WarnaFunda.teksRedup,
                            ),
                          ),
                          const SizedBox(height: SpasiFunda.m),
                          const TeksFunda.isiKecil('Tujuan Impian'),
                          const SizedBox(height: SpasiFunda.xs),
                          const TeksFunda.judulBagian('Belum Ada'),
                          const SizedBox(height: SpasiFunda.xs),
                          const TeksFunda.catatan('Yuk pasang pos impian!'),
                        ],
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
                          return Column(
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
                                  LucideIcons.target,
                                  size: 18,
                                  color: WarnaFunda.utama,
                                ),
                              ),
                              const SizedBox(height: SpasiFunda.m),
                              Text(
                                tujuanTerdekatLain.nama,
                                style: TipografiFunda.isiKecil,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: SpasiFunda.xs),
                              TeksFunda.judulBagian('$progres%'),
                              const SizedBox(height: SpasiFunda.xs),
                              TeksFunda.catatan(formatRupiah(danaTerkumpul)),
                            ],
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(height: SpasiFunda.jarakPetak),

            // 8. Bento 2x1: Lanjut Belajar (Data Nyata dari Penyedia Belajar)
            ref.watch(penyediaLanjutBelajarBeranda).when(
                  data: (info) => PetakBento.ukuran2x1(
                    tint: TintPetakBento.ungu,
                    padaKetuk: () => context.push(info.rute),
                    labelAkses: 'Pelajaran keuangan: ${info.labelAksi} ${info.judul}',
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
                                child: TeksFunda.catatan(
                                  info.labelAksi,
                                  warna: WarnaFunda.sifatKeinginan,
                                ),
                              ),
                              const SizedBox(height: SpasiFunda.s),
                              TeksFunda.judulBagian(info.judul),
                              const SizedBox(height: SpasiFunda.xs),
                              TeksFunda.catatan(
                                info.keterangan,
                                warna: WarnaFunda.teksRedup,
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
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),
            const SizedBox(height: SpasiFunda.jarakPetak),

            // 9. Bento 2x1: Tagihan Terdekat (Data Nyata)
            Consumer(
              builder: (context, ref, _) {
                final tagihanTerdekatAsync = ref.watch(
                  penyediaTagihanTerdekatBeranda,
                );
                return tagihanTerdekatAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                  data: (tagihan) {
                    if (tagihan == null) {
                      return PetakBento.ukuran2x1(
                        tint: TintPetakBento.netral,
                        padaKetuk: () => context.push('/tagihan'),
                        labelAkses:
                            'Tagihan terdekat: Tidak ada tagihan dalam 7 hari ke depan',
                        anak: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(SpasiFunda.m),
                              decoration: BoxDecoration(
                                color: WarnaFunda.permukaan,
                                borderRadius: BorderRadius.circular(
                                  SudutFunda.kartu,
                                ),
                              ),
                              child: const Icon(
                                LucideIcons.calendarCheck,
                                color: WarnaFunda.utama,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: SpasiFunda.m),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TeksFunda.label('Tagihan Terdekat'),
                                  SizedBox(height: SpasiFunda.xs),
                                  TeksFunda.catatan(
                                    'Tidak ada tagihan dalam 7 hari ke depan. Aman!',
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
                      );
                    }

                    final isLewat =
                        tagihan.status == StatusKemunculan.lewat ||
                        tagihan.status == StatusKemunculan.lewatKedaluwarsa;
                    final isHariIni =
                        tagihan.status == StatusKemunculan.hariIni;

                    final warnaTint = isLewat
                        ? TintPetakBento.mawar
                        : (isHariIni
                              ? TintPetakBento.amber
                              : TintPetakBento.hijau);

                    String infoStatus;
                    if (isLewat) {
                      infoStatus = 'Lewat ${-tagihan.selisihHari} hari';
                    } else if (isHariIni) {
                      infoStatus = 'Jatuh tempo hari ini';
                    } else {
                      infoStatus = tagihan.selisihHari == 1
                          ? 'Besok'
                          : '${tagihan.selisihHari} hari lagi';
                    }

                    return PetakBento.ukuran2x1(
                      tint: warnaTint,
                      padaKetuk: () => context.push('/tagihan'),
                      labelAkses:
                          'Tagihan terdekat: ${tagihan.nama}, $infoStatus, perkiraan ${tagihan.jumlahPerkiraanRupiah != null ? formatRupiah(tagihan.jumlahPerkiraanRupiah!) : "fluktuatif"}',
                      anak: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(SpasiFunda.m),
                            decoration: BoxDecoration(
                              color: WarnaFunda.permukaan,
                              borderRadius: BorderRadius.circular(
                                SudutFunda.kartu,
                              ),
                            ),
                            child: Icon(
                              isLewat
                                  ? LucideIcons.circleAlert
                                  : (isHariIni
                                        ? LucideIcons.clock
                                        : LucideIcons.calendarClock),
                              color: isLewat
                                  ? WarnaFunda.pengeluaran
                                  : (isHariIni
                                        ? WarnaFunda.peringatan
                                        : WarnaFunda.utama),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: SpasiFunda.m),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: SpasiFunda.xs,
                                  runSpacing: SpasiFunda.xs,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      tagihan.nama,
                                      style: TipografiFunda.label,
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: WarnaFunda.permukaan,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        infoStatus,
                                        style: TipografiFunda.catatan.copyWith(
                                          color: isLewat
                                              ? WarnaFunda.pengeluaran
                                              : WarnaFunda.teks,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: SpasiFunda.xs),
                                TeksFunda.catatan(
                                  tagihan.jumlahPerkiraanRupiah != null &&
                                          tagihan.jumlahPerkiraanRupiah! > 0
                                      ? 'Perkiraan: ${formatRupiah(tagihan.jumlahPerkiraanRupiah!)}'
                                      : 'Nominal fluktuatif',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: SpasiFunda.s),
                          const Icon(
                            LucideIcons.chevronRight,
                            color: WarnaFunda.teksRedup,
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: SpasiFunda.jarakPetak),

            // 10. Bento 2x1: 5 Transaksi Terakhir (Data Nyata)
            PetakBento.ukuran2x1(
              tint: TintPetakBento.netral,
              padaKetuk: () => context.go('/catatan'),
              labelAkses: 'Lihat 5 transaksi terakhir',
              anak: Column(
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
                          onTap: () => context.go('/catatan'),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
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
                    ],
                  ),
                  const SizedBox(height: SpasiFunda.s),
                  limaTransaksiAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, _) =>
                        const TeksFunda.catatan('Gagal memuat transaksi.'),
                    data: (daftar) {
                      if (daftar.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: SpasiFunda.m),
                          child: TeksFunda.catatan(
                            'Belum ada transaksi tercatat. Mulai catat pemasukan atau pengeluaranmu!',
                          ),
                        );
                      }
                      return Column(
                        children: daftar.take(5).map((t) {
                          final kategori = daftarKategori
                              .where((k) => k.id == t.kategoriId)
                              .firstOrNull;
                          final jenis = t.jenis;
                          final isMasuk = jenis == 'masuk';
                          final isTransfer = jenis == 'transfer';
                          final warnaNominal = isMasuk
                              ? WarnaFunda.pemasukan
                              : (isTransfer
                                    ? WarnaFunda.utama
                                    : WarnaFunda.pengeluaran);

                          final judul =
                              kategori?.nama ??
                              (isTransfer ? 'Transfer Dompet' : 'Transaksi');

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: SpasiFunda.xs,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(SpasiFunda.xs),
                                  decoration: BoxDecoration(
                                    color: WarnaFunda.permukaan,
                                    borderRadius: BorderRadius.circular(
                                      SudutFunda.kecil,
                                    ),
                                  ),
                                  child: Icon(
                                    ambilIkonLucide(
                                      kategori?.ikon ?? 'receipt',
                                    ),
                                    size: 16,
                                    color: warnaNominal,
                                  ),
                                ),
                                const SizedBox(width: SpasiFunda.s),
                                Expanded(
                                  child: Text(
                                    t.catatan != null && t.catatan!.isNotEmpty
                                        ? '$judul • ${t.catatan}'
                                        : judul,
                                    style: TipografiFunda.catatan,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: SpasiFunda.s),
                                Text(
                                  '${isMasuk ? '+' : '-'} ${formatRupiah(t.jumlahRupiah)}',
                                  style: TipografiFunda.catatan.copyWith(
                                    color: warnaNominal,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
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
