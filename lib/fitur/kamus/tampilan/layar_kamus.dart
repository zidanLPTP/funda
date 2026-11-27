import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../komponen/komponen_funda.dart';
import '../../../tema/token.dart';
import '../../belajar/kontroler/penyedia_belajar.dart';

/// Halaman Kamus Keuangan yang menampilkan istilah yang sudah dipelajari pengguna.
class LayarKamus extends ConsumerStatefulWidget {
  const LayarKamus({super.key});

  @override
  ConsumerState<LayarKamus> createState() => _LayarKamusState();
}

class _LayarKamusState extends ConsumerState<LayarKamus> {
  final TextEditingController _kontrolerCari = TextEditingController();
  String _kueri = '';

  @override
  void dispose() {
    _kontrolerCari.dispose();
    super.dispose();
  }

  String _kapitalisasiJudul(String teks) {
    if (teks.isEmpty) return teks;
    return teks[0].toUpperCase() + teks.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final kamusAsync = ref.watch(penyediaKamusTerbuka);

    return Scaffold(
      backgroundColor: WarnaFunda.latar,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(
                SpasiFunda.l,
                SpasiFunda.m,
                SpasiFunda.l,
                SpasiFunda.s,
              ),
              child: HeaderSubLayarEditorial(judul: 'Kamus Keuangan'),
            ),
            Expanded(
              child: kamusAsync.when(
                loading: () => const Center(child: IndikatorMemuat()),
                error: (err, _) => Padding(
                  padding: const EdgeInsets.all(SpasiFunda.l),
                  child: Center(
                    child: TeksFunda.isi(
                      'Kamus belum dapat dimuat saat ini.',
                      warna: WarnaFunda.teksRedup,
                      rataTeks: TextAlign.center,
                    ),
                  ),
                ),
                data: (ringkasan) {
                  if (ringkasan.daftarTerbuka.isEmpty) {
                    return ListView(
                      padding: const EdgeInsets.all(SpasiFunda.l),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(SpasiFunda.l),
                          decoration: BoxDecoration(
                            color: WarnaFunda.permukaan,
                            borderRadius: BorderRadius.circular(
                              SudutFunda.kartu,
                            ),
                            border: Border.all(
                              color: WarnaFunda.garis,
                              width: 1.0,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const TeksFunda.judulBagian(
                                'Kamusmu Masih Kosong',
                              ),
                              const SizedBox(height: SpasiFunda.s),
                              const TeksFunda.isi(
                                'Mulai buka pelajaran pertama di tab Belajar untuk mengumpulkan kosakata keuangan sesuai progresmu.',
                                warna: WarnaFunda.teksRedup,
                              ),
                              const SizedBox(height: SpasiFunda.l),
                              TombolFunda(
                                key: const Key('tombol_kamus_ke_belajar'),
                                teks: 'Buka Tab Belajar',
                                varian: VarianTombolFunda.pilGelap,
                                padaTekan: () => context.go('/belajar'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  final hasilFilter = filterKamusTerbuka(
                    ringkasan.daftarTerbuka,
                    _kueri,
                  );

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(
                      SpasiFunda.l,
                      SpasiFunda.s,
                      SpasiFunda.l,
                      SpasiFunda.xl,
                    ),
                    children: [
                      // Kolom Pencarian Istilah / Arti / Contoh
                      Container(
                        decoration: BoxDecoration(
                          color: WarnaFunda.permukaan,
                          borderRadius: BorderRadius.circular(SudutFunda.kartu),
                          border: Border.all(
                            color: WarnaFunda.garis,
                            width: 1.0,
                          ),
                        ),
                        child: TextField(
                          key: const Key('kolom_cari_kamus'),
                          controller: _kontrolerCari,
                          onChanged: (nilai) => setState(() => _kueri = nilai),
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            hintText: 'Cari istilah, arti, atau contoh...',
                            hintStyle: TipografiFunda.catatan.copyWith(
                              color: WarnaFunda.teksRedup,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: SpasiFunda.m,
                              vertical: SpasiFunda.m,
                            ),
                            prefixIcon: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: SpasiFunda.m,
                              ),
                              child: IkonUiFunda(
                                pathAset: AsetIkonUiFunda.search,
                                ukuran: 20,
                                warna: WarnaFunda.teksRedup,
                              ),
                            ),
                            prefixIconConstraints: const BoxConstraints(
                              minWidth: 44,
                              minHeight: 44,
                            ),
                            suffixIcon: _kueri.isNotEmpty
                                ? IconButton(
                                    key: const Key('tombol_hapus_cari_kamus'),
                                    tooltip: 'Hapus pencarian',
                                    onPressed: () {
                                      _kontrolerCari.clear();
                                      setState(() => _kueri = '');
                                    },
                                    icon: const IkonUiFunda(
                                      pathAset: AsetIkonUiFunda.x,
                                      ukuran: 18,
                                      warna: WarnaFunda.teksRedup,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: SpasiFunda.s),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: SpasiFunda.xs,
                        ),
                        child: TeksFunda.catatan(
                          '${ringkasan.daftarTerbuka.length} dari ${ringkasan.totalIstilah} istilah terbuka sesuai progres belajarmu',
                          warna: WarnaFunda.teksRedup,
                        ),
                      ),
                      const SizedBox(height: SpasiFunda.m),

                      if (hasilFilter.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(SpasiFunda.l),
                          decoration: BoxDecoration(
                            color: WarnaFunda.permukaan,
                            borderRadius: BorderRadius.circular(
                              SudutFunda.kartu,
                            ),
                            border: Border.all(
                              color: WarnaFunda.garis,
                              width: 1.0,
                            ),
                          ),
                          child: const TeksFunda.isi(
                            'Istilah belum ditemukan di kosakata yang sudah terbuka. Coba kata kunci lain.',
                            warna: WarnaFunda.teksRedup,
                          ),
                        )
                      else
                        for (final entri in hasilFilter) ...[
                          _KartuIstilahKamus(
                            judul: _kapitalisasiJudul(entri.istilah.istilah),
                            arti: entri.istilah.arti,
                            contohRupiah: entri.istilah.contohRupiah,
                            sumberModul: entri.sumberModul,
                          ),
                          const SizedBox(height: SpasiFunda.m),
                        ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KartuIstilahKamus extends StatelessWidget {
  final String judul;
  final String arti;
  final String contohRupiah;
  final String? sumberModul;

  const _KartuIstilahKamus({
    required this.judul,
    required this.arti,
    required this.contohRupiah,
    this.sumberModul,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SpasiFunda.l),
      decoration: BoxDecoration(
        color: WarnaFunda.permukaan,
        borderRadius: BorderRadius.circular(SudutFunda.kartu),
        border: Border.all(color: WarnaFunda.garis, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TeksFunda.judulBagian(judul),
          if (sumberModul != null) ...[
            const SizedBox(height: SpasiFunda.xs),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SpasiFunda.s,
                vertical: SpasiFunda.xs,
              ),
              decoration: BoxDecoration(
                color: WarnaFunda.kanvasMint,
                borderRadius: BorderRadius.circular(SudutFunda.pil),
              ),
              child: TeksFunda.catatan(sumberModul!, warna: WarnaFunda.utama),
            ),
          ],
          const SizedBox(height: SpasiFunda.s),
          TeksFunda.isi(arti),
          if (contohRupiah.isNotEmpty) ...[
            const SizedBox(height: SpasiFunda.m),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(SpasiFunda.m),
              decoration: BoxDecoration(
                color: WarnaFunda.latar,
                borderRadius: BorderRadius.circular(SudutFunda.kecil),
                border: Border.all(color: WarnaFunda.garis, width: 1.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TeksFunda.catatan(
                    'Contoh',
                    warna: WarnaFunda.teksRedup,
                  ),
                  const SizedBox(height: SpasiFunda.xs),
                  TeksFunda.catatan(contohRupiah),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
