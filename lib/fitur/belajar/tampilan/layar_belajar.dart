import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../komponen/komponen_funda.dart';
import '../../../perhitungan/perhitungan_belajar.dart';
import '../../../tema/token.dart';
import '../kontroler/penyedia_belajar.dart';

/// Layar utama Tab Belajar (Peta Tingkat -> Modul -> Pelajaran).
class LayarBelajar extends ConsumerWidget {
  const LayarBelajar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petaAsync = ref.watch(penyediaPetaBelajar);

    return Scaffold(
      backgroundColor: WarnaFunda.latar,
      body: SafeArea(
        child: petaAsync.when(
          loading: () =>
              const Center(child: IndikatorMemuat(warna: WarnaFunda.utama)),
          error: (err, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(SpasiFunda.m),
              child: KeadaanKosong(
                ikon: LucideIcons.circleAlert,
                judul: 'Gagal Memuat Materi',
                pesan: 'Terjadi kendala saat membaca materi belajar: $err',
                teksTombol: 'Coba Lagi',
                padaAksi: () => ref.refresh(penyediaPetaBelajar),
              ),
            ),
          ),
          data: (daftarItemModul) {
            final modulPemula = daftarItemModul
                .where((m) => m.modul.tingkat == 'pemula')
                .toList();
            final modulMenengah = daftarItemModul
                .where((m) => m.modul.tingkat == 'menengah')
                .toList();
            final modulLanjutan = daftarItemModul
                .where((m) => m.modul.tingkat == 'lanjutan')
                .toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(SpasiFunda.marginLayar),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TeksFunda.judulLayar('Belajar Finansial'),
                  const SizedBox(height: SpasiFunda.xs),
                  const TeksFunda.isi(
                    'Kuasai fondasi uangmu langkah demi langkah melalui praktik nyata.',
                    warna: WarnaFunda.teksRedup,
                  ),
                  const SizedBox(height: SpasiFunda.l),

                  // Kartu Saran Personalisasi / Tes Awal
                  _bangunKartuSaranPersonalisasi(context, ref),

                  // Tingkat Pemula
                  _bangunBagianTingkat(
                    context,
                    ref,
                    judul: 'Tingkat Pemula',
                    keterangan:
                        'Fondasi penting arus kas, tabungan, dan dana darurat.',
                    warnaAksen: WarnaFunda.utama,
                    warnaTint: WarnaFunda.tintHijau,
                    daftarModul: modulPemula,
                  ),

                  const SizedBox(height: SpasiFunda.xl),

                  // Tingkat Menengah
                  _bangunBagianTingkat(
                    context,
                    ref,
                    judul: 'Tingkat Menengah',
                    keterangan:
                        'Perlindungan aset, manajemen kredit, dan investasi dasar.',
                    warnaAksen: WarnaFunda.sifatKebutuhan,
                    warnaTint: WarnaFunda.tintBiru,
                    daftarModul: modulMenengah,
                  ),

                  const SizedBox(height: SpasiFunda.xl),

                  // Tingkat Lanjutan
                  _bangunBagianTingkat(
                    context,
                    ref,
                    judul: 'Tingkat Lanjutan',
                    keterangan:
                        'Perencanaan jangka panjang, KPR, dan kebebasan finansial.',
                    warnaAksen: WarnaFunda.sifatKeinginan,
                    warnaTint: WarnaFunda.tintUngu,
                    daftarModul: modulLanjutan,
                  ),

                  const SizedBox(height: SpasiFunda.xxl),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _bangunBagianTingkat(
    BuildContext context,
    WidgetRef ref, {
    required String judul,
    required String keterangan,
    required Color warnaAksen,
    required Color warnaTint,
    required List<ItemPetaModul> daftarModul,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: warnaAksen,
                borderRadius: BorderRadius.circular(SudutFunda.pil),
              ),
            ),
            const SizedBox(width: SpasiFunda.s),
            TeksFunda.judulBagian(judul),
          ],
        ),
        const SizedBox(height: SpasiFunda.xs),
        TeksFunda.catatan(keterangan, warna: WarnaFunda.teksRedup),
        const SizedBox(height: SpasiFunda.m),
        ...daftarModul.map(
          (item) => _bangunKartuModul(
            context,
            ref,
            item,
            warnaAksenTingkat: warnaAksen,
            warnaTintTingkat: warnaTint,
          ),
        ),
      ],
    );
  }

  Widget _bangunKartuModul(
    BuildContext context,
    WidgetRef ref,
    ItemPetaModul item, {
    required Color warnaAksenTingkat,
    required Color warnaTintTingkat,
  }) {
    final modul = item.modul;
    final profilSudahAda =
        ref.watch(penyediaStreamProfilKeuangan).asData?.value != null;
    final statusModul = (modul.id == 'mulai_tes_awal' && profilSudahAda)
        ? const HasilStatusBelajar(
            status: StatusBelajar.selesai,
            apaYangKurang: [],
          )
        : item.statusModul;
    final isTersedia = modul.tersedia;
    final modulTerkunci = statusModul.status == StatusBelajar.terkunci;

    return Container(
      margin: const EdgeInsets.only(bottom: SpasiFunda.m),
      decoration: BoxDecoration(
        color: modulTerkunci ? WarnaFunda.tintNetral : WarnaFunda.permukaan,
        borderRadius: BorderRadius.circular(SudutFunda.petak),
        border: Border.all(color: WarnaFunda.garis),
        boxShadow: const [
          BoxShadow(
            color: WarnaFunda.bayanganKartu,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(SpasiFunda.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(SpasiFunda.s),
                decoration: BoxDecoration(
                  color: warnaTintTingkat,
                  borderRadius: BorderRadius.circular(SudutFunda.kartu),
                ),
                child: Icon(
                  modul.id == 'mulai_tes_awal'
                      ? LucideIcons.compass
                      : (statusModul.status == StatusBelajar.selesai
                            ? LucideIcons.checkCircle2
                            : LucideIcons.bookOpen),
                  size: 20,
                  color: warnaAksenTingkat,
                ),
              ),
              const SizedBox(width: SpasiFunda.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        TeksFunda.catatan(
                          'Modul ${modul.urutan}',
                          warna: warnaAksenTingkat,
                        ),
                        const SizedBox(width: SpasiFunda.s),
                        if (!isTersedia ||
                            statusModul.status == StatusBelajar.selesai)
                          _bangunBadgeStatusModul(
                            isTersedia,
                            statusModul.status,
                          ),
                      ],
                    ),
                    const SizedBox(height: SpasiFunda.xs),
                    TeksFunda.judulBagian(modul.judul),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: SpasiFunda.s),
          TeksFunda.isiKecil(
            modul.deskripsiSingkat,
            warna: WarnaFunda.teksRedup,
          ),

          if (modul.id == 'utang_cicilan') ...[
            ref
                .watch(penyediaStreamPernyataan)
                .when(
                  data: (pernyataan) {
                    if (pernyataan['tidak_punya_utang'] == 'true') {
                      return Container(
                        margin: const EdgeInsets.only(top: SpasiFunda.s),
                        padding: const EdgeInsets.symmetric(
                          horizontal: SpasiFunda.m,
                          vertical: SpasiFunda.s,
                        ),
                        decoration: BoxDecoration(
                          color: WarnaFunda.tintBiru,
                          borderRadius: BorderRadius.circular(SudutFunda.kecil),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              LucideIcons.info,
                              size: 16,
                              color: WarnaFunda.utama,
                            ),
                            const SizedBox(width: SpasiFunda.s),
                            const Expanded(
                              child: TeksFunda.catatan(
                                'Kamu menyatakan tidak punya utang.',
                                warna: WarnaFunda.teks,
                              ),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                minimumSize: const Size(48, 36),
                              ),
                              onPressed: () async {
                                final repo = ref.read(
                                  penyediaPernyataanRepositori,
                                );
                                await repo.hapusPernyataan('tidak_punya_utang');
                                ref.invalidate(penyediaFotoData);
                              },
                              child: const TeksFunda.catatan(
                                'Cabut pernyataan',
                                warna: WarnaFunda.utama,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (err, stack) => const SizedBox.shrink(),
                ),
          ],

          if (modul.id == 'penghasilan_tambahan') ...[
            ref
                .watch(penyediaStreamPernyataan)
                .when(
                  data: (pernyataan) {
                    if (pernyataan['baru_satu_sumber'] == 'true') {
                      return Container(
                        margin: const EdgeInsets.only(top: SpasiFunda.s),
                        padding: const EdgeInsets.symmetric(
                          horizontal: SpasiFunda.m,
                          vertical: SpasiFunda.s,
                        ),
                        decoration: BoxDecoration(
                          color: WarnaFunda.tintBiru,
                          borderRadius: BorderRadius.circular(SudutFunda.kecil),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              LucideIcons.info,
                              size: 16,
                              color: WarnaFunda.utama,
                            ),
                            const SizedBox(width: SpasiFunda.s),
                            const Expanded(
                              child: TeksFunda.catatan(
                                'Kamu menyatakan baru punya satu sumber penghasilan.',
                                warna: WarnaFunda.teks,
                              ),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                minimumSize: const Size(48, 36),
                              ),
                              onPressed: () async {
                                final repo = ref.read(
                                  penyediaPernyataanRepositori,
                                );
                                await repo.hapusPernyataan('baru_satu_sumber');
                                ref.invalidate(penyediaFotoData);
                              },
                              child: const TeksFunda.catatan(
                                'Cabut pernyataan',
                                warna: WarnaFunda.utama,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (err, stack) => const SizedBox.shrink(),
                ),
          ],

          if (modul.id == 'keuangan_usaha_kecil') ...[
            ref
                .watch(penyediaStreamPernyataan)
                .when(
                  data: (pernyataan) {
                    if (pernyataan['belum_punya_usaha'] == 'true') {
                      return Container(
                        margin: const EdgeInsets.only(top: SpasiFunda.s),
                        padding: const EdgeInsets.symmetric(
                          horizontal: SpasiFunda.m,
                          vertical: SpasiFunda.s,
                        ),
                        decoration: BoxDecoration(
                          color: WarnaFunda.tintBiru,
                          borderRadius: BorderRadius.circular(SudutFunda.kecil),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              LucideIcons.info,
                              size: 16,
                              color: WarnaFunda.utama,
                            ),
                            const SizedBox(width: SpasiFunda.s),
                            const Expanded(
                              child: TeksFunda.catatan(
                                'Kamu menyatakan belum punya usaha saat ini.',
                                warna: WarnaFunda.teks,
                              ),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                minimumSize: const Size(48, 36),
                              ),
                              onPressed: () async {
                                final repo = ref.read(
                                  penyediaPernyataanRepositori,
                                );
                                await repo.hapusPernyataan('belum_punya_usaha');
                                ref.invalidate(penyediaFotoData);
                              },
                              child: const TeksFunda.catatan(
                                'Cabut pernyataan',
                                warna: WarnaFunda.utama,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (err, stack) => const SizedBox.shrink(),
                ),
          ],

          if (modul.id == 'mulai_tes_awal') ...[
            const SizedBox(height: SpasiFunda.m),
            if (profilSudahAda)
              Container(
                key: const Key('kartu_modul_0_tersimpan'),
                padding: const EdgeInsets.all(SpasiFunda.m),
                decoration: BoxDecoration(
                  color: WarnaFunda.tintHijau,
                  borderRadius: BorderRadius.circular(SudutFunda.kartu),
                  border: Border.all(color: WarnaFunda.batasHijau),
                ),
                child: const Row(
                  children: [
                    Icon(
                      LucideIcons.checkCircle2,
                      size: 20,
                      color: WarnaFunda.pemasukan,
                    ),
                    SizedBox(width: SpasiFunda.s),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TeksFunda.label(
                            'Profil keuanganmu sudah tersimpan',
                            warna: WarnaFunda.pemasukan,
                          ),
                          SizedBox(height: 2),
                          TeksFunda.catatan(
                            'Kamu bisa memperbaruinya di Lainnya -> Pengaturan.',
                            warna: WarnaFunda.teksRedup,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              TombolFunda(
                key: const Key('tombol_buka_tes_awal'),
                teks: 'Buka Tes Awal',
                lebarPenuh: true,
                padaTekan: () => context.push('/belajar/tes-awal'),
              ),
          ] else if (!isTersedia) ...[
            const SizedBox(height: SpasiFunda.m),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SpasiFunda.m,
                vertical: SpasiFunda.s,
              ),
              decoration: BoxDecoration(
                color: WarnaFunda.tintNetral,
                borderRadius: BorderRadius.circular(SudutFunda.kecil),
              ),
              child: const Row(
                children: [
                  Icon(LucideIcons.clock, size: 16, color: WarnaFunda.utama),
                  SizedBox(width: SpasiFunda.s),
                  Expanded(
                    child: TeksFunda.catatan(
                      'Segera hadir di kurikulum mendatang.',
                      warna: WarnaFunda.teksRedup,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Pesan singkat penjelas syarat di level modul bila seluruh modul terkunci
            if (modulTerkunci && statusModul.apaYangKurang.isNotEmpty) ...[
              const SizedBox(height: SpasiFunda.m),
              _bangunKotakSyarat(
                context,
                ref,
                daftarPesan: statusModul.apaYangKurang,
                ruteAksi: statusModul.ruteAksi,
                daftarAtauPernyataan: statusModul.daftarAtauPernyataan,
              ),
            ],
            // Daftar Pelajaran di dalam modul aktif
            const SizedBox(height: SpasiFunda.m),
            const Divider(color: WarnaFunda.garis),
            const SizedBox(height: SpasiFunda.s),
            ...item.daftarPelajaran.asMap().entries.map((entry) {
              final idx = entry.key;
              final (pel, statusPel) = entry.value;
              return _bangunBarisPelajaran(
                context,
                ref,
                pel,
                statusPel,
                idx + 1,
                modulTerkunci: modulTerkunci,
                warnaAksenTingkat: warnaAksenTingkat,
              );
            }),

            // Tombol Kuis Akhir Modul
            const SizedBox(height: SpasiFunda.m),
            _bangunTombolKuisModul(context, item),
          ],
        ],
      ),
    );
  }

  Widget _bangunBadgeStatusModul(bool tersedia, StatusBelajar status) {
    if (!tersedia) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SpasiFunda.s,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          color: WarnaFunda.tintNetral,
          borderRadius: BorderRadius.circular(SudutFunda.pil),
        ),
        child: const TeksFunda.catatan(
          'Segera Hadir',
          warna: WarnaFunda.teksRedup,
        ),
      );
    }

    Color warnaLatar;
    Color warnaTeks;
    String label;

    switch (status) {
      case StatusBelajar.selesai:
        warnaLatar = WarnaFunda.tintHijau;
        warnaTeks = WarnaFunda.pemasukan;
        label = 'Selesai';
        break;
      case StatusBelajar.sedang:
        warnaLatar = WarnaFunda.tintBiru;
        warnaTeks = WarnaFunda.utama;
        label = 'Sedang Berjalan';
        break;
      case StatusBelajar.terbuka:
        warnaLatar = WarnaFunda.tintBiru;
        warnaTeks = WarnaFunda.utama;
        label = 'Terbuka';
        break;
      case StatusBelajar.terkunci:
        warnaLatar = WarnaFunda.tintAmber;
        warnaTeks = WarnaFunda.peringatan;
        label = 'Terkunci';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpasiFunda.s,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: warnaLatar,
        borderRadius: BorderRadius.circular(SudutFunda.pil),
      ),
      child: TeksFunda.catatan(label, warna: warnaTeks),
    );
  }

  Widget _bangunKotakSyarat(
    BuildContext context,
    WidgetRef ref, {
    required List<String> daftarPesan,
    String? ruteAksi,
    List<String> daftarAtauPernyataan = const [],
  }) {
    return Container(
      padding: const EdgeInsets.all(SpasiFunda.m),
      decoration: BoxDecoration(
        color: WarnaFunda.tintAmber,
        borderRadius: BorderRadius.circular(SudutFunda.kartu),
        border: Border.all(color: WarnaFunda.batasAmber),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                LucideIcons.info,
                size: 16,
                color: WarnaFunda.peringatan,
              ),
              const SizedBox(width: SpasiFunda.s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: daftarPesan
                      .map(
                        (pesan) => Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: TeksFunda.catatan(
                            pesan,
                            warna: WarnaFunda.teks,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
          if (ruteAksi != null) ...[
            const SizedBox(height: SpasiFunda.s),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  side: const BorderSide(color: WarnaFunda.utama),
                  backgroundColor: WarnaFunda.permukaan,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SudutFunda.pil),
                  ),
                ),
                onPressed: () => context.push(ruteAksi),
                icon: const Icon(
                  LucideIcons.arrowRight,
                  size: 16,
                  color: WarnaFunda.utama,
                ),
                label: const TeksFunda.label(
                  'Lengkapi Data Sekarang',
                  warna: WarnaFunda.utama,
                ),
              ),
            ),
          ],
          if (daftarAtauPernyataan.isNotEmpty) ...[
            const SizedBox(height: SpasiFunda.xs),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                onPressed: () async {
                  final kunci = daftarAtauPernyataan.first;
                  final repo = ref.read(penyediaPernyataanRepositori);
                  final map = await repo.ambilSemuaPernyataan();
                  final nilaiLama = map[kunci];
                  if (nilaiLama == 'true') {
                    await repo.hapusPernyataan(kunci);
                  } else {
                    await repo.simpanPernyataan(kunci, 'true');
                  }
                  ref.invalidate(penyediaFotoData);
                },
                child: const TeksFunda.catatan(
                  'Aku tidak punya ini',
                  warna: WarnaFunda.teksRedup,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _bangunBarisPelajaran(
    BuildContext context,
    WidgetRef ref,
    PelajaranKonten pel,
    HasilStatusBelajar statusPel,
    int nomorUrut, {
    required bool modulTerkunci,
    required Color warnaAksenTingkat,
  }) {
    final status = statusPel.status;
    final isTerkunci = status == StatusBelajar.terkunci;
    final tampilkanSyaratBaris =
        isTerkunci && !modulTerkunci && statusPel.apaYangKurang.isNotEmpty;

    return Opacity(
      opacity: isTerkunci ? 0.72 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: SpasiFunda.s),
        padding: const EdgeInsets.all(SpasiFunda.m),
        decoration: BoxDecoration(
          color: isTerkunci ? WarnaFunda.tintNetral : WarnaFunda.permukaan,
          borderRadius: BorderRadius.circular(SudutFunda.kartu),
          border: Border.all(
            color: status == StatusBelajar.sedang
                ? warnaAksenTingkat
                : WarnaFunda.garis,
            width: status == StatusBelajar.sedang ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _bangunIkonStatusPelajaran(
                  status,
                  nomorUrut,
                  warnaAksenTingkat: warnaAksenTingkat,
                ),
                const SizedBox(width: SpasiFunda.s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TeksFunda.label(pel.judul),
                      const SizedBox(height: 2),
                      TeksFunda.catatan(
                        '${pel.durasiMenit} menit',
                        warna: WarnaFunda.teksRedup,
                      ),
                    ],
                  ),
                ),
                if (!isTerkunci)
                  TombolFunda(
                    teks: status == StatusBelajar.selesai
                        ? 'Baca Ulang'
                        : (status == StatusBelajar.sedang ? 'Lanjut' : 'Mulai'),
                    padaTekan: () {
                      context.push(
                        '/belajar/pelajaran/${pel.modulId}/${pel.id}',
                      );
                    },
                  ),
              ],
            ),

            // Tampilan pesan penjelas syarat hanya bila modul sudah terbuka
            if (tampilkanSyaratBaris) ...[
              const SizedBox(height: SpasiFunda.s),
              _bangunKotakSyarat(
                context,
                ref,
                daftarPesan: statusPel.apaYangKurang,
                ruteAksi: statusPel.ruteAksi,
                daftarAtauPernyataan: statusPel.daftarAtauPernyataan,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _bangunIkonStatusPelajaran(
    StatusBelajar status,
    int nomorUrut, {
    required Color warnaAksenTingkat,
  }) {
    switch (status) {
      case StatusBelajar.selesai:
        return Container(
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            color: WarnaFunda.tintHijau,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            LucideIcons.check,
            size: 16,
            color: WarnaFunda.pemasukan,
          ),
        );
      case StatusBelajar.sedang:
        return Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: WarnaFunda.tintBiru,
            shape: BoxShape.circle,
          ),
          child: Icon(LucideIcons.play, size: 16, color: warnaAksenTingkat),
        );
      case StatusBelajar.terbuka:
        return Container(
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            color: WarnaFunda.tintBiru,
            shape: BoxShape.circle,
          ),
          child: Icon(LucideIcons.bookOpen, size: 16, color: warnaAksenTingkat),
        );
      case StatusBelajar.terkunci:
        return Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: WarnaFunda.permukaan,
            shape: BoxShape.circle,
            border: Border.all(color: WarnaFunda.garis),
          ),
          child: TeksFunda.catatan('$nomorUrut', warna: WarnaFunda.teksRedup),
        );
    }
  }

  Widget _bangunTombolKuisModul(BuildContext context, ItemPetaModul item) {
    final modul = item.modul;
    final semuaPelajaranSelesai = item.daftarPelajaran.every(
      (p) => p.$2.status == StatusBelajar.selesai,
    );
    final kuis = modul.kuis;
    if (kuis.jumlahSoal <= 0) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SpasiFunda.m),
      decoration: BoxDecoration(
        color: semuaPelajaranSelesai
            ? WarnaFunda.utamaTipis
            : WarnaFunda.tintNetral,
        borderRadius: BorderRadius.circular(SudutFunda.kartu),
        border: Border.all(
          color: semuaPelajaranSelesai ? WarnaFunda.utama : WarnaFunda.garis,
        ),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.helpCircle,
            color: semuaPelajaranSelesai
                ? WarnaFunda.utama
                : WarnaFunda.teksRedup,
          ),
          const SizedBox(width: SpasiFunda.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TeksFunda.label(
                  'Kuis Akhir Modul (${kuis.jumlahSoal} Soal)',
                  warna: semuaPelajaranSelesai
                      ? WarnaFunda.utama
                      : WarnaFunda.teksRedup,
                ),
                const SizedBox(height: 2),
                TeksFunda.catatan(
                  semuaPelajaranSelesai
                      ? 'Uji pemahamanmu untuk menuntaskan modul ini (minimal 70%).'
                      : 'Terbuka setelah seluruh pelajaran modul ini selesai.',
                  warna: WarnaFunda.teksRedup,
                ),
              ],
            ),
          ),
          const SizedBox(width: SpasiFunda.s),
          TombolFunda(
            teks: 'Mulai Kuis',
            padaTekan: semuaPelajaranSelesai
                ? () {
                    context.push('/belajar/kuis/${modul.id}');
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _bangunKartuSaranPersonalisasi(BuildContext context, WidgetRef ref) {
    final profilAsync = ref.watch(penyediaStreamProfilKeuangan);
    final rekomendasiAsync = ref.watch(penyediaDaftarRekomendasiModul);
    final pernyataanAsync = ref.watch(penyediaStreamPernyataan);
    final petaAsync = ref.watch(penyediaPetaBelajar);

    final dilewati = pernyataanAsync.asData?.value['profil_dilewati'] == 'true';

    return profilAsync.when(
      data: (profil) {
        if (profil == null && !dilewati) {
          // Banner ajakan ramah jika belum ada profil dan belum pernah melewati
          return Container(
            margin: const EdgeInsets.only(bottom: SpasiFunda.l),
            padding: const EdgeInsets.all(SpasiFunda.l),
            decoration: BoxDecoration(
              color: WarnaFunda.tintHijau,
              borderRadius: BorderRadius.circular(SudutFunda.petak),
              border: Border.all(color: WarnaFunda.batasHijau, width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: WarnaFunda.bayanganKartu,
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(SpasiFunda.s),
                      decoration: BoxDecoration(
                        color: WarnaFunda.permukaan,
                        borderRadius: BorderRadius.circular(SudutFunda.kartu),
                      ),
                      child: const Icon(
                        LucideIcons.compass,
                        color: WarnaFunda.utama,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: SpasiFunda.s),
                    const Expanded(
                      child: TeksFunda.label(
                        'Saran Belajar Sesuai Kondisimu',
                        warna: WarnaFunda.utama,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SpasiFunda.s),
                const TeksFunda.isiKecil(
                  'Ikuti tes awal 3 menit untuk mengetahui topik mana yang paling pas buat kamu mulai duluan.',
                ),
                const SizedBox(height: SpasiFunda.m),
                TombolFunda(
                  teks: 'Mulai Tes Awal (Modul 0)',
                  lebarPenuh: true,
                  padaTekan: () => context.push('/belajar/tes-awal'),
                ),
              ],
            ),
          );
        }

        // Tampilkan maksimal 1 kartu sorotan rekomendasi ringkas di atas (tanpa badge bertumpuk)
        return rekomendasiAsync.when(
          data: (daftar) {
            if (daftar.isEmpty) return const SizedBox();

            final rek = daftar.first;
            final isTersedia = rek.modul.tersedia;
            final itemPeta = petaAsync.asData?.value
                .where((m) => m.modul.id == rek.modul.id)
                .firstOrNull;
            final pelBerikutnya = itemPeta?.daftarPelajaran
                .where((p) => p.$2.status != StatusBelajar.terkunci)
                .map((p) => p.$1)
                .firstOrNull;

            return Container(
              key: const Key('kartu_sorotan_rekomendasi'),
              margin: const EdgeInsets.only(bottom: SpasiFunda.l),
              padding: const EdgeInsets.all(SpasiFunda.l),
              decoration: BoxDecoration(
                color: WarnaFunda.tintBiru,
                borderRadius: BorderRadius.circular(SudutFunda.petak),
                border: Border.all(color: WarnaFunda.batasBiru, width: 1.2),
                boxShadow: const [
                  BoxShadow(
                    color: WarnaFunda.bayanganKartu,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(SpasiFunda.s),
                        decoration: BoxDecoration(
                          color: WarnaFunda.permukaan,
                          borderRadius: BorderRadius.circular(SudutFunda.kartu),
                        ),
                        child: const Icon(
                          LucideIcons.compass,
                          size: 20,
                          color: WarnaFunda.sifatKebutuhan,
                        ),
                      ),
                      const SizedBox(width: SpasiFunda.s),
                      Expanded(
                        child: TeksFunda.catatan(
                          'Rekomendasi Utama • ${rek.judulAlasan}',
                          warna: WarnaFunda.sifatKebutuhan,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: SpasiFunda.s),
                  TeksFunda.judulBagian(rek.modul.judul),
                  const SizedBox(height: SpasiFunda.xs),
                  TeksFunda.isiKecil(
                    rek.deskripsiAlasan,
                    warna: WarnaFunda.teksRedup,
                  ),
                  const SizedBox(height: SpasiFunda.m),
                  TombolFunda(
                    teks: isTersedia ? 'Buka Modul Ini' : 'Segera Hadir',
                    lebarPenuh: true,
                    padaTekan: isTersedia
                        ? () {
                            if (pelBerikutnya != null) {
                              context.push(
                                '/belajar/pelajaran/${rek.modul.id}/${pelBerikutnya.id}',
                              );
                            } else if (rek.statusModul.ruteAksi != null) {
                              context.push(rek.statusModul.ruteAksi!);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Lengkapi syarat di modul ${rek.modul.judul} pada daftar di bawah.',
                                  ),
                                ),
                              );
                            }
                          }
                        : null,
                  ),
                ],
              ),
            );
          },
          loading: () => const SizedBox(),
          error: (err, stack) => const SizedBox(),
        );
      },
      loading: () => const SizedBox(),
      error: (err, stack) => const SizedBox(),
    );
  }
}
