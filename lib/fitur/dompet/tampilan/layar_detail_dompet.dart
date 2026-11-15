import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../data/basis_data.dart';
import '../../../data/model/jenis_dompet.dart';
import '../../../data/model/jenis_transaksi.dart';
import '../../../data/penyedia_data.dart';
import '../../../komponen/komponen_funda.dart';
import '../../../komponen/pembantu_ikon.dart';
import '../../../komponen/pembantu_tint.dart';
import '../../../perhitungan/perhitungan_keuangan.dart';
import '../../../tema/token.dart';
import '../../../util/format_rupiah.dart';
import '../../kantong/kontroler/penyedia_kantong.dart';
import '../../kantong/tampilan/layar_daftar_kantong.dart';
import 'layar_form_dompet.dart';

/// Layar Detail satu dompet: melihat saldo, saldo bebas, kantong, riwayat transaksi berhalaman, sesuaikan saldo, arsip, dan hapus.
class LayarDetailDompet extends ConsumerStatefulWidget {
  const LayarDetailDompet({super.key, required this.dompetId});

  final String dompetId;

  @override
  ConsumerState<LayarDetailDompet> createState() => _LayarDetailDompetState();
}

class _LayarDetailDompetState extends ConsumerState<LayarDetailDompet> {
  int _limitTransaksi = 50;

  @override
  Widget build(BuildContext context) {
    final daftarDompetAsync = ref.watch(penyediaDaftarDompet);
    final petaSaldo = ref.watch(penyediaPetaSaldoDompet);
    final repoTransaksi = ref.watch(penyediaTransaksiRepositori);
    final repoDompet = ref.watch(penyediaDompetRepositori);
    final saldoBebas = ref.watch(penyediaSaldoBebasDompet(widget.dompetId));
    final daftarKantongAsync = ref.watch(
      penyediaKantongDompet(widget.dompetId),
    );

    return daftarDompetAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) =>
          Scaffold(body: Center(child: Text('Terjadi kesalahan: $e'))),
      data: (daftar) {
        final dompet = daftar.firstWhere(
          (d) => d.id == widget.dompetId,
          orElse: () => throw StateError('Dompet tidak ditemukan'),
        );
        final saldo = petaSaldo[dompet.id] ?? dompet.saldoAwalRupiah;
        final jenis = JenisDompet.dariKode(dompet.jenis);

        return PembungkusLayar(
          appBar: AppBar(
            title: TeksFunda.judulBagian(dompet.nama),
            actions: [
              IconButton(
                icon: const Icon(LucideIcons.pencil),
                tooltip: 'Ubah Dompet',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LayarFormDompet(dompet: dompet),
                    ),
                  );
                },
              ),
            ],
          ),
          bisaGulir: true,
          anak: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kartu Bento Saldo Dompet & Saldo Bebas
              PetakBento.ukuran2x1(
                warnaKustom: ambilWarnaTint(dompet.warna),
                anak: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(SpasiFunda.s),
                          decoration: BoxDecoration(
                            color: WarnaFunda.permukaan,
                            borderRadius: BorderRadius.circular(
                              SudutFunda.kecil,
                            ),
                          ),
                          child: Icon(
                            ambilIkonLucide(dompet.ikon),
                            size: 20,
                            color: WarnaFunda.utama,
                          ),
                        ),
                        const SizedBox(width: SpasiFunda.m),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TeksFunda.label(dompet.nama),
                            TeksFunda.catatan(jenis.label),
                          ],
                        ),
                        const Spacer(),
                        if (dompet.diarsipkan)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: SpasiFunda.s,
                              vertical: SpasiFunda.xs,
                            ),
                            decoration: BoxDecoration(
                              color: WarnaFunda.peringatan.withAlpha(25),
                              borderRadius: BorderRadius.circular(
                                SudutFunda.pil,
                              ),
                            ),
                            child: const TeksFunda.catatan(
                              'Diarsipkan',
                              warna: WarnaFunda.peringatan,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: SpasiFunda.l),
                    const TeksFunda.isiKecil('Saldo Berjalan Saat Ini'),
                    const SizedBox(height: SpasiFunda.xs),
                    TeksFunda.angkaBesar(
                      formatRupiah(saldo),
                      warna: saldo < 0
                          ? WarnaFunda.pengeluaran
                          : WarnaFunda.teks,
                    ),
                    if (saldo < 0) ...[
                      const SizedBox(height: SpasiFunda.xs),
                      const TeksFunda.catatan(
                        'Saldo dompet ini minus. Cek kembali catatan pengeluaranmu.',
                        warna: WarnaFunda.pengeluaran,
                      ),
                    ],
                    const SizedBox(height: SpasiFunda.m),
                    // Indikator Saldo Bebas
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SpasiFunda.m,
                        vertical: SpasiFunda.s,
                      ),
                      decoration: BoxDecoration(
                        color: WarnaFunda.permukaan,
                        borderRadius: BorderRadius.circular(SudutFunda.kecil),
                        border: Border.all(
                          color: saldoBebas < 0
                              ? WarnaFunda.pengeluaran
                              : WarnaFunda.garis,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const TeksFunda.catatan('Saldo Bebas:'),
                          TeksFunda.label(
                            formatRupiah(saldoBebas),
                            warna: saldoBebas < 0
                                ? WarnaFunda.pengeluaran
                                : WarnaFunda.teks,
                          ),
                        ],
                      ),
                    ),
                    if (saldoBebas < 0) ...[
                      const SizedBox(height: SpasiFunda.xs),
                      const TeksFunda.catatan(
                        'Alokasi kantong melebihi saldo dompet yang tersedia.',
                        warna: WarnaFunda.pengeluaran,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: SpasiFunda.l),

              // Baris Aksi: Sesuaikan Saldo & Arsipkan (Responsif Skala Teks Aksesibilitas)
              LayoutBuilder(
                builder: (context, constraints) {
                  final textScale = MediaQuery.textScalerOf(context).scale(1.0);
                  if (textScale > 1.3 || constraints.maxWidth < 360) {
                    return Column(
                      children: [
                        TombolFunda.primer(
                          teks: 'Sesuaikan Saldo',
                          lebarPenuh: true,
                          ikon: const Icon(
                            LucideIcons.slidersHorizontal,
                            size: 16,
                          ),
                          padaTekan: () => _tampilkanDialogSesuaikanSaldo(
                            context,
                            ref,
                            dompet,
                            saldo,
                          ),
                        ),
                        const SizedBox(height: SpasiFunda.s),
                        TombolFunda.sekunder(
                          teks: dompet.diarsipkan ? 'Pulihkan' : 'Arsipkan',
                          lebarPenuh: true,
                          ikon: Icon(
                            dompet.diarsipkan
                                ? LucideIcons.archiveRestore
                                : LucideIcons.archive,
                            size: 16,
                          ),
                          padaTekan: () async {
                            await repoDompet.arsipkanDompet(
                              dompet.id,
                              !dompet.diarsipkan,
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    dompet.diarsipkan
                                        ? 'Dompet berhasil dipulihkan.'
                                        : 'Dompet berhasil diarsipkan.',
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(
                        child: TombolFunda.primer(
                          teks: 'Sesuaikan Saldo',
                          ikon: const Icon(
                            LucideIcons.slidersHorizontal,
                            size: 16,
                          ),
                          padaTekan: () => _tampilkanDialogSesuaikanSaldo(
                            context,
                            ref,
                            dompet,
                            saldo,
                          ),
                        ),
                      ),
                      const SizedBox(width: SpasiFunda.m),
                      Expanded(
                        child: TombolFunda.sekunder(
                          teks: dompet.diarsipkan ? 'Pulihkan' : 'Arsipkan',
                          ikon: Icon(
                            dompet.diarsipkan
                                ? LucideIcons.archiveRestore
                                : LucideIcons.archive,
                            size: 16,
                          ),
                          padaTekan: () async {
                            await repoDompet.arsipkanDompet(
                              dompet.id,
                              !dompet.diarsipkan,
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    dompet.diarsipkan
                                        ? 'Dompet berhasil dipulihkan.'
                                        : 'Dompet berhasil diarsipkan.',
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: SpasiFunda.m),

              // Tombol Hapus Permanen (bila belum ada transaksi)
              FutureBuilder<bool>(
                future: repoDompet.cekApakahDompetMemilikiTransaksi(dompet.id),
                builder: (context, snapshot) {
                  final adaTransaksi = snapshot.data ?? true;
                  if (!adaTransaksi) {
                    return TombolFunda.teks(
                      teks: 'Hapus Dompet Ini Secara Permanen',
                      lebarPenuh: true,
                      padaTekan: () async {
                        final yakin = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const TeksFunda.judulBagian('Hapus Dompet?'),
                            content: const TeksFunda.isi(
                              'Dompet ini belum memiliki transaksi dan akan dihapus secara permanen.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Batal'),
                              ),
                              TombolFunda.primer(
                                teks: 'Hapus',
                                padaTekan: () => Navigator.pop(ctx, true),
                              ),
                            ],
                          ),
                        );
                        if (yakin == true) {
                          await repoDompet.hapusDompetPermanen(dompet.id);
                          if (context.mounted) {
                            context.pop();
                          }
                        }
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: SpasiFunda.l),

              // Bagian Kantong di Dompet Ini
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: SpasiFunda.xs,
                children: [
                  const TeksFunda.judulBagian('Kantong di Dompet Ini'),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LayarDaftarKantong(),
                        ),
                      );
                    },
                    icon: const Icon(LucideIcons.arrowRight, size: 16),
                    label: const Text('Kelola Kantong'),
                  ),
                ],
              ),
              const SizedBox(height: SpasiFunda.s),
              daftarKantongAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Terjadi kesalahan: $e')),
                data: (daftarKantong) {
                  if (daftarKantong.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(SpasiFunda.m),
                      decoration: BoxDecoration(
                        color: WarnaFunda.permukaan,
                        borderRadius: BorderRadius.circular(SudutFunda.kartu),
                        border: Border.all(color: WarnaFunda.garis),
                      ),
                      child: const Center(
                        child: TeksFunda.catatan(
                          'Belum ada kantong di dompet ini.',
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: daftarKantong.map((k) {
                      final saldoKantongAsync = ref.watch(
                        penyediaSaldoKantong(k.id),
                      );
                      final saldoK = saldoKantongAsync.value ?? 0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: SpasiFunda.s),
                        padding: const EdgeInsets.all(SpasiFunda.m),
                        decoration: BoxDecoration(
                          color: WarnaFunda.permukaan,
                          borderRadius: BorderRadius.circular(SudutFunda.kartu),
                          border: Border.all(color: WarnaFunda.garis),
                        ),
                        child: Row(
                          children: [
                            Icon(ambilIkonLucide(k.ikon), size: 18),
                            const SizedBox(width: SpasiFunda.s),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TeksFunda.label(k.nama),
                                  TeksFunda.catatan(
                                    k.tujuanId != null
                                        ? 'Tertaut Tujuan'
                                        : 'Kantong Bebas',
                                  ),
                                ],
                              ),
                            ),
                            TeksFunda.label(
                              formatRupiah(saldoK),
                              angkaTabular: true,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: SpasiFunda.xl),

              // Riwayat Transaksi Dompet (Berhalaman)
              const TeksFunda.judulBagian('Riwayat Transaksi Dompet Ini'),
              const SizedBox(height: SpasiFunda.m),
              StreamBuilder<List<EntitasTransaksi>>(
                stream: repoTransaksi.pantauTransaksiDompet(
                  dompet.id,
                  limit: _limitTransaksi,
                ),
                builder: (context, snapshot) {
                  final daftar = snapshot.data ?? [];
                  if (daftar.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(SpasiFunda.xl),
                      decoration: BoxDecoration(
                        color: WarnaFunda.permukaan,
                        borderRadius: BorderRadius.circular(SudutFunda.kartu),
                        border: Border.all(color: WarnaFunda.garis),
                      ),
                      child: const Center(
                        child: TeksFunda.isiKecil(
                          'Belum ada transaksi di dompet ini.',
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: daftar.length,
                        separatorBuilder: (_, index) =>
                            const SizedBox(height: SpasiFunda.s),
                        itemBuilder: (context, indeks) {
                          final t = daftar[indeks];
                          final jenis = JenisTransaksi.dariKode(t.jenis);
                          final isMasuk =
                              jenis == JenisTransaksi.masuk ||
                              jenis == JenisTransaksi.penyesuaianMasuk ||
                              (jenis == JenisTransaksi.transfer &&
                                  t.dompetTujuanId == dompet.id);

                          final tanda = isMasuk ? '+' : '-';
                          final warnaNominal = isMasuk
                              ? WarnaFunda.pemasukan
                              : WarnaFunda.pengeluaran;

                          return Container(
                            padding: const EdgeInsets.all(SpasiFunda.m),
                            decoration: BoxDecoration(
                              color: WarnaFunda.permukaan,
                              borderRadius: BorderRadius.circular(
                                SudutFunda.kartu,
                              ),
                              border: Border.all(color: WarnaFunda.garis),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(SpasiFunda.s),
                                  decoration: BoxDecoration(
                                    color: isMasuk
                                        ? WarnaFunda.tintHijau
                                        : WarnaFunda.tintAmber,
                                    borderRadius: BorderRadius.circular(
                                      SudutFunda.kecil,
                                    ),
                                  ),
                                  child: Icon(
                                    isMasuk
                                        ? LucideIcons.arrowDownLeft
                                        : LucideIcons.arrowUpRight,
                                    size: 18,
                                    color: warnaNominal,
                                  ),
                                ),
                                const SizedBox(width: SpasiFunda.m),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TeksFunda.label(jenis.label),
                                      if (t.catatan != null &&
                                          t.catatan!.isNotEmpty) ...[
                                        const SizedBox(height: SpasiFunda.xs),
                                        TeksFunda.catatan(t.catatan!),
                                      ],
                                    ],
                                  ),
                                ),
                                TeksFunda.label(
                                  '$tanda${formatRupiah(t.jumlahRupiah)}',
                                  warna: warnaNominal,
                                  angkaTabular: true,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      if (daftar.length >= _limitTransaksi) ...[
                        const SizedBox(height: SpasiFunda.m),
                        TombolFunda.sekunder(
                          teks: 'Muat Lebih Banyak',
                          lebarPenuh: true,
                          padaTekan: () {
                            setState(() {
                              _limitTransaksi += 50;
                            });
                          },
                        ),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: SpasiFunda.xxl),
            ],
          ),
        );
      },
    );
  }

  void _tampilkanDialogSesuaikanSaldo(
    BuildContext context,
    WidgetRef ref,
    EntitasDompet dompet,
    int saldoSekarang,
  ) {
    final pengontrol = TextEditingController(text: formatRupiah(saldoSekarang));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const TeksFunda.judulBagian('Sesuaikan Saldo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TeksFunda.catatan(
              'Saldo di aplikasi: ${formatRupiah(saldoSekarang)}',
            ),
            const SizedBox(height: SpasiFunda.m),
            const TeksFunda.label('Berapa saldo sebenarnya di akun ini?'),
            const SizedBox(height: SpasiFunda.s),
            TextField(
              controller: pengontrol,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: WarnaFunda.latar,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SudutFunda.kartu),
                  borderSide: const BorderSide(color: WarnaFunda.garis),
                ),
              ),
              onChanged: (teks) {
                try {
                  final nominal = ambilAngkaRupiah(teks);
                  final format = formatRupiah(nominal);
                  if (format != teks) {
                    pengontrol.value = TextEditingValue(
                      text: format,
                      selection: TextSelection.collapsed(offset: format.length),
                    );
                  }
                } catch (_) {}
              },
            ),
            const SizedBox(height: SpasiFunda.s),
            const TeksFunda.catatan(
              'Aplikasi akan mencatat transaksi penyesuaian otomatis untuk menyeimbangkan saldo tanpa mengubah riwayat transaksi lamamu.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TombolFunda.primer(
            teks: 'Simpan Penyesuaian',
            padaTekan: () async {
              int saldoSebenarnya = 0;
              try {
                saldoSebenarnya = ambilAngkaRupiah(pengontrol.text);
              } catch (_) {
                return;
              }

              final hasil = hitungPenyesuaianSaldo(
                saldoSekarang: saldoSekarang,
                saldoSebenarnya: saldoSebenarnya,
              );

              if (!hasil.perluPenyesuaian) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Saldo sudah sesuai. Tidak ada penyesuaian.'),
                  ),
                );
                return;
              }

              final repoTransaksi = ref.read(penyediaTransaksiRepositori);
              final idTransaksi =
                  'penyesuaian_${DateTime.now().millisecondsSinceEpoch}';
              final sekarang = DateTime.now().toUtc();

              await repoTransaksi.tambahTransaksi(
                TabelTransaksiCompanion(
                  id: drift.Value(idTransaksi),
                  jenis: drift.Value(hasil.jenis!.kode),
                  jumlahRupiah: drift.Value(hasil.jumlahRupiah),
                  dompetId: drift.Value(dompet.id),
                  catatan: const drift.Value('Penyesuaian saldo mandiri'),
                  waktuTransaksi: drift.Value(sekarang),
                ),
              );

              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Saldo berhasil disesuaikan (${hasil.jenis == JenisTransaksi.penyesuaianMasuk ? '+' : '-'}${formatRupiah(hasil.jumlahRupiah)}).',
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
