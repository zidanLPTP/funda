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
          loading: () => const Center(
            child: IndikatorMemuat(warna: WarnaFunda.utama),
          ),
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
            final modulPemula = daftarItemModul.where((m) => m.modul.tingkat == 'pemula').toList();
            final modulMenengah = daftarItemModul.where((m) => m.modul.tingkat == 'menengah').toList();
            final modulLanjutan = daftarItemModul.where((m) => m.modul.tingkat == 'lanjutan').toList();

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
                    keterangan: 'Fondasi penting arus kas, tabungan, dan dana darurat.',
                    daftarModul: modulPemula,
                  ),

                  const SizedBox(height: SpasiFunda.xl),

                  // Tingkat Menengah
                  _bangunBagianTingkat(
                    context,
                    ref,
                    judul: 'Tingkat Menengah',
                    keterangan: 'Perlindungan aset, manajemen kredit, dan investasi dasar.',
                    daftarModul: modulMenengah,
                  ),

                  const SizedBox(height: SpasiFunda.xl),

                  // Tingkat Lanjutan
                  _bangunBagianTingkat(
                    context,
                    ref,
                    judul: 'Tingkat Lanjutan',
                    keterangan: 'Perencanaan jangka panjang, KPR, dan kebebasan finansial.',
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
                color: WarnaFunda.utama,
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
        ...daftarModul.map((item) => _bangunKartuModul(context, ref, item)),
      ],
    );
  }

  Widget _bangunKartuModul(BuildContext context, WidgetRef ref, ItemPetaModul item) {
    final modul = item.modul;
    final statusModul = item.statusModul;
    final isTersedia = modul.tersedia;

    return Container(
      margin: const EdgeInsets.only(bottom: SpasiFunda.m),
      decoration: BoxDecoration(
        color: WarnaFunda.permukaan,
        borderRadius: BorderRadius.circular(SudutFunda.petak),
        border: Border.all(color: WarnaFunda.garis),
      ),
      padding: const EdgeInsets.all(SpasiFunda.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        TeksFunda.catatan(
                          'Modul ${modul.urutan}',
                          warna: WarnaFunda.utama,
                        ),
                        const SizedBox(width: SpasiFunda.s),
                        _bangunBadgeStatusModul(isTersedia, statusModul.status),
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
          TeksFunda.isiKecil(modul.deskripsiSingkat, warna: WarnaFunda.teksRedup),

          if (modul.id == 'mulai_tes_awal') ...[
            const SizedBox(height: SpasiFunda.m),
            TombolFunda(
              teks: 'Buka Tes Awal',
              lebarPenuh: true,
              padaTekan: () => context.push('/belajar/tes-awal'),
            ),
          ] else if (!isTersedia) ...[
            const SizedBox(height: SpasiFunda.m),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: SpasiFunda.m, vertical: SpasiFunda.s),
              decoration: BoxDecoration(
                color: WarnaFunda.tintNetral,
                borderRadius: BorderRadius.circular(SudutFunda.kecil),
              ),
              child: const Row(
                children: [
                  Icon(LucideIcons.clock, size: 16, color: WarnaFunda.teksRedup),
                  SizedBox(width: SpasiFunda.s),
                  Expanded(
                    child: TeksFunda.catatan('Segera hadir di kurikulum mendatang.', warna: WarnaFunda.teksRedup),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Daftar Pelajaran di dalam modul aktif
            const SizedBox(height: SpasiFunda.m),
            const Divider(color: WarnaFunda.garis),
            const SizedBox(height: SpasiFunda.s),
            ...item.daftarPelajaran.asMap().entries.map((entry) {
              final idx = entry.key;
              final (pel, statusPel) = entry.value;
              return _bangunBarisPelajaran(context, ref, pel, statusPel, idx + 1);
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
        padding: const EdgeInsets.symmetric(horizontal: SpasiFunda.s, vertical: 2),
        decoration: BoxDecoration(
          color: WarnaFunda.tintNetral,
          borderRadius: BorderRadius.circular(SudutFunda.pil),
        ),
        child: const TeksFunda.catatan('Segera Hadir', warna: WarnaFunda.teksRedup),
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
      padding: const EdgeInsets.symmetric(horizontal: SpasiFunda.s, vertical: 2),
      decoration: BoxDecoration(
        color: warnaLatar,
        borderRadius: BorderRadius.circular(SudutFunda.pil),
      ),
      child: TeksFunda.catatan(label, warna: warnaTeks),
    );
  }

  Widget _bangunBarisPelajaran(
    BuildContext context,
    WidgetRef ref,
    PelajaranKonten pel,
    HasilStatusBelajar statusPel,
    int nomorUrut,
  ) {
    final status = statusPel.status;
    final isTerkunci = status == StatusBelajar.terkunci;

    return Container(
      margin: const EdgeInsets.only(bottom: SpasiFunda.s),
      padding: const EdgeInsets.all(SpasiFunda.m),
      decoration: BoxDecoration(
        color: isTerkunci ? WarnaFunda.tintNetral : WarnaFunda.permukaan,
        borderRadius: BorderRadius.circular(SudutFunda.kartu),
        border: Border.all(
          color: status == StatusBelajar.sedang ? WarnaFunda.utama : WarnaFunda.garis,
          width: status == StatusBelajar.sedang ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _bangunIkonStatusPelajaran(status),
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
                    context.push('/belajar/pelajaran/${pel.modulId}/${pel.id}');
                  },
                ),
            ],
          ),

          // Tampilan apa yang kurang bila pelajaran terkunci
          if (isTerkunci) ...[
            const SizedBox(height: SpasiFunda.s),
            Container(
              padding: const EdgeInsets.all(SpasiFunda.s),
              decoration: BoxDecoration(
                color: WarnaFunda.tintAmber,
                borderRadius: BorderRadius.circular(SudutFunda.kecil),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(LucideIcons.lock, size: 16, color: WarnaFunda.peringatan),
                      const SizedBox(width: SpasiFunda.s),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...statusPel.apaYangKurang.map(
                              (pesan) => Padding(
                                padding: const EdgeInsets.only(bottom: 2),
                                child: TeksFunda.catatan(pesan, warna: WarnaFunda.teks),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (statusPel.ruteAksi != null) ...[
                    const SizedBox(height: SpasiFunda.s),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(48, 48),
                          side: const BorderSide(color: WarnaFunda.utama),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SudutFunda.pil)),
                        ),
                        onPressed: () => context.push(statusPel.ruteAksi!),
                        icon: const Icon(LucideIcons.arrowRight, size: 16, color: WarnaFunda.utama),
                        label: const TeksFunda.label('Lengkapi Data Sekarang', warna: WarnaFunda.utama),
                      ),
                    ),
                  ],
                  // Tombol pernyataan ATAU ("Aku tidak punya ini")
                  if (statusPel.daftarAtauPernyataan.isNotEmpty) ...[
                    const SizedBox(height: SpasiFunda.xs),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          minimumSize: const Size(48, 48),
                        ),
                        onPressed: () async {
                          final kunci = statusPel.daftarAtauPernyataan.first;
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
                        child: const TeksFunda.catatan('Aku tidak punya ini', warna: WarnaFunda.teksRedup),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _bangunIkonStatusPelajaran(StatusBelajar status) {
    switch (status) {
      case StatusBelajar.selesai:
        return Container(
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            color: WarnaFunda.tintHijau,
            shape: BoxShape.circle,
          ),
          child: const Icon(LucideIcons.check, size: 16, color: WarnaFunda.pemasukan),
        );
      case StatusBelajar.sedang:
        return Container(
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            color: WarnaFunda.tintBiru,
            shape: BoxShape.circle,
          ),
          child: const Icon(LucideIcons.play, size: 16, color: WarnaFunda.utama),
        );
      case StatusBelajar.terbuka:
        return Container(
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            color: WarnaFunda.tintBiru,
            shape: BoxShape.circle,
          ),
          child: const Icon(LucideIcons.bookOpen, size: 16, color: WarnaFunda.utama),
        );
      case StatusBelajar.terkunci:
        return Container(
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            color: WarnaFunda.tintNetral,
            shape: BoxShape.circle,
          ),
          child: const Icon(LucideIcons.lock, size: 16, color: WarnaFunda.teksRedup),
        );
    }
  }

  Widget _bangunTombolKuisModul(BuildContext context, ItemPetaModul item) {
    final modul = item.modul;
    final semuaPelajaranSelesai = item.daftarPelajaran.every((p) => p.$2.status == StatusBelajar.selesai);
    final kuis = modul.kuis;
    if (kuis.jumlahSoal <= 0) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SpasiFunda.m),
      decoration: BoxDecoration(
        color: semuaPelajaranSelesai ? WarnaFunda.utamaTipis : WarnaFunda.tintNetral,
        borderRadius: BorderRadius.circular(SudutFunda.kartu),
        border: Border.all(
          color: semuaPelajaranSelesai ? WarnaFunda.utama : WarnaFunda.garis,
        ),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.helpCircle,
            color: semuaPelajaranSelesai ? WarnaFunda.utama : WarnaFunda.teksRedup,
          ),
          const SizedBox(width: SpasiFunda.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TeksFunda.label(
                  'Kuis Akhir Modul (${kuis.jumlahSoal} Soal)',
                  warna: semuaPelajaranSelesai ? WarnaFunda.utama : WarnaFunda.teksRedup,
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

    final dilewati = pernyataanAsync.asData?.value['profil_dilewati'] == 'true';

    return profilAsync.when(
      data: (profil) {
        if (profil == null && !dilewati) {
          // Banner ajakan ramah jika belum ada profil dan belum pernah melewati
          return Container(
            margin: const EdgeInsets.only(bottom: SpasiFunda.l),
            padding: const EdgeInsets.all(SpasiFunda.m),
            decoration: BoxDecoration(
              color: WarnaFunda.utamaTipis,
              borderRadius: BorderRadius.circular(SudutFunda.petak),
              border: Border.all(
                  color: WarnaFunda.utama.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(LucideIcons.sparkles,
                        color: WarnaFunda.utama, size: 20),
                    SizedBox(width: SpasiFunda.s),
                    Text(
                      'Saran Belajar Sesuai Kondisimu',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: WarnaFunda.utama,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SpasiFunda.xs),
                const TeksFunda.isiKecil(
                  'Ikuti tes awal 3 menit untuk mengetahui topik mana yang paling pas buat kamu mulai duluan.',
                ),
                const SizedBox(height: SpasiFunda.m),
                TombolFunda(
                  teks: 'Mulai Tes Awal (Modul 0)',
                  padaTekan: () => context.push('/belajar/tes-awal'),
                ),
              ],
            ),
          );
        }

        // Tampilkan rekomendasi personalisasi jika profil sudah ada atau dilewati
        return rekomendasiAsync.when(
          data: (daftar) {
            if (daftar.isEmpty) return const SizedBox();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: daftar.map((rek) {
                final isTersedia = rek.modul.tersedia;

                return Container(
                  margin: const EdgeInsets.only(bottom: SpasiFunda.m),
                  padding: const EdgeInsets.all(SpasiFunda.m),
                  decoration: BoxDecoration(
                    color: WarnaFunda.permukaan,
                    borderRadius: BorderRadius.circular(SudutFunda.petak),
                    border: Border.all(
                        color: WarnaFunda.utama.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: SpasiFunda.s, vertical: 2),
                            decoration: BoxDecoration(
                              color: WarnaFunda.utamaTipis,
                              borderRadius: BorderRadius.circular(SudutFunda.pil),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(LucideIcons.sparkles,
                                    size: 14, color: WarnaFunda.utama),
                                const SizedBox(width: SpasiFunda.xs),
                                TeksFunda.catatan(
                                  isTersedia ? 'Saran untuk kamu' : 'Saran untuk kamu (segera hadir)',
                                  warna: WarnaFunda.utama,
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => context.push('/belajar/tes-awal'),
                            child: const Text('Profilku',
                                style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                      const SizedBox(height: SpasiFunda.s),
                      TeksFunda.judulBagian(rek.modul.judul),
                      const SizedBox(height: SpasiFunda.xs),
                      TeksFunda.isiKecil(rek.deskripsiAlasan,
                          warna: WarnaFunda.teksRedup),
                      const SizedBox(height: SpasiFunda.m),
                      TombolFunda(
                        teks: isTersedia ? 'Buka Modul Ini' : 'Segera Hadir',
                        lebarPenuh: true,
                        padaTekan: isTersedia
                            ? () {
                                context.push('/belajar/tes-awal');
                              }
                            : null,
                      ),
                    ],
                  ),
                );
              }).toList(),
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
