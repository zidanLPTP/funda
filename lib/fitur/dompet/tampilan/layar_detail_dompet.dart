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

/// Layar Detail satu dompet bergaya editorial bersih:
/// header tombol kembali >= 48dp + pil Ubah, hero kanvas saldo & saldo bebas,
/// tombol sesuaikan saldo pilGelap, kantong, dan riwayat berpemisah tipis.
class LayarDetailDompet extends ConsumerStatefulWidget {
  const LayarDetailDompet({super.key, required this.dompetId});

  final String dompetId;

  @override
  ConsumerState<LayarDetailDompet> createState() => _LayarDetailDompetState();
}

class _LayarDetailDompetState extends ConsumerState<LayarDetailDompet> {
  int _limitTransaksi = 50;

  void _tutupLayar() {
    final router = GoRouter.maybeOf(context);
    if (router != null) {
      router.pop();
    } else {
      Navigator.maybePop(context);
    }
  }

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
    final isTeksBesar = MediaQuery.textScalerOf(context).scale(1) > 1.3;

    return daftarDompetAsync.when(
      loading: () => const Scaffold(
        backgroundColor: WarnaFunda.latar,
        body: Center(child: IndikatorMemuat()),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: WarnaFunda.latar,
        body: Center(child: Text('Terjadi kesalahan: $e')),
      ),
      data: (daftar) {
        final dompet = daftar.firstWhere(
          (d) => d.id == widget.dompetId,
          orElse: () => throw StateError('Dompet tidak ditemukan'),
        );
        final saldo = petaSaldo[dompet.id] ?? dompet.saldoAwalRupiah;
        final jenis = JenisDompet.dariKode(dompet.jenis);
        final warnaKanvas = ambilWarnaTint(dompet.warna);
        final warnaAksen = ambilWarnaAksenTint(dompet.warna);

        return Scaffold(
          backgroundColor: WarnaFunda.latar,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    SpasiFunda.marginLayar,
                    SpasiFunda.marginLayar,
                    SpasiFunda.marginLayar,
                    SpasiFunda.s,
                  ),
                  child: HeaderSubLayarEditorial(
                    judul: dompet.nama,
                    aksiKanan: [
                      TombolPilHeaderEditorial(
                        key: const Key('tombol_ubah_dompet_header'),
                        teks: 'Ubah',
                        ikon: LucideIcons.pencil,
                        padaTekan: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => LayarFormDompet(dompet: dompet),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      SpasiFunda.marginLayar,
                      SpasiFunda.s,
                      SpasiFunda.marginLayar,
                      SpasiFunda.xxl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hero Kanvas Saldo Dompet & Saldo Bebas
                        Container(
                          key: const Key('hero_kanvas_detail_dompet'),
                          width: double.infinity,
                          padding: const EdgeInsets.all(SpasiFunda.l),
                          decoration: BoxDecoration(
                            color: warnaKanvas,
                            borderRadius: BorderRadius.circular(
                              SudutFunda.petak,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  IkonDompetFunda(
                                    kodeJenis: dompet.jenis,
                                    kunciIkonFallback: dompet.ikon,
                                    ukuran: 28,
                                    warnaFallback: warnaAksen,
                                  ),
                                  const SizedBox(width: SpasiFunda.m),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TeksFunda.label(dompet.nama),
                                        TeksFunda.catatan(
                                          jenis.label,
                                          warna: WarnaFunda.teksRedup,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (dompet.diarsipkan)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: SpasiFunda.s,
                                        vertical: SpasiFunda.xs,
                                      ),
                                      decoration: BoxDecoration(
                                        color: WarnaFunda.permukaan,
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
                              const TeksFunda.catatan(
                                'Saldo Berjalan Saat Ini',
                                warna: WarnaFunda.teksRedup,
                              ),
                              const SizedBox(height: SpasiFunda.xs),
                              TeksFunda.angkaBesar(
                                formatRupiah(saldo),
                                angkaTabular: true,
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
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: SpasiFunda.m,
                                  vertical: SpasiFunda.s,
                                ),
                                decoration: BoxDecoration(
                                  color: WarnaFunda.permukaan,
                                  borderRadius: BorderRadius.circular(
                                    SudutFunda.kartu,
                                  ),
                                  border: Border.all(
                                    color: saldoBebas < 0
                                        ? WarnaFunda.pengeluaran
                                        : WarnaFunda.garis,
                                  ),
                                ),
                                child: Wrap(
                                  alignment: WrapAlignment.spaceBetween,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: SpasiFunda.s,
                                  runSpacing: SpasiFunda.xs,
                                  children: [
                                    const TeksFunda.catatan('Saldo Bebas:'),
                                    TeksFunda.label(
                                      formatRupiah(saldoBebas),
                                      angkaTabular: true,
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

                        // Baris Aksi: Sesuaikan Saldo (pilGelap) & Arsipkan
                        if (isTeksBesar) ...[
                          TombolFunda.pilGelap(
                            teks: 'Sesuaikan Saldo',
                            lebarPenuh: true,
                            ikon: const IkonUiFunda(
                              pathAset: AsetIkonUiFunda.slidersHorizontal,
                              ukuran: 16,
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
                            ikon: IkonUiFunda(
                              pathAset: dompet.diarsipkan
                                  ? AsetIkonUiFunda.archiveRestore
                                  : AsetIkonUiFunda.archive,
                              ukuran: 16,
                            ),
                            padaTekan: () => _arsipDompet(repoDompet, dompet),
                          ),
                        ] else
                          Row(
                            children: [
                              Expanded(
                                child: TombolFunda.pilGelap(
                                  teks: 'Sesuaikan Saldo',
                                  lebarPenuh: false,
                                  ikon: const IkonUiFunda(
                                    pathAset: AsetIkonUiFunda.slidersHorizontal,
                                    ukuran: 16,
                                  ),
                                  padaTekan: () =>
                                      _tampilkanDialogSesuaikanSaldo(
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
                                  teks: dompet.diarsipkan
                                      ? 'Pulihkan'
                                      : 'Arsipkan',
                                  ikon: IkonUiFunda(
                                    pathAset: dompet.diarsipkan
                                        ? AsetIkonUiFunda.archiveRestore
                                        : AsetIkonUiFunda.archive,
                                    ukuran: 16,
                                  ),
                                  padaTekan: () =>
                                      _arsipDompet(repoDompet, dompet),
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: SpasiFunda.s),

                        // Tombol Hapus Permanen (bila belum ada transaksi)
                        FutureBuilder<bool>(
                          future: repoDompet.cekApakahDompetMemilikiTransaksi(
                            dompet.id,
                          ),
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
                                      title: const TeksFunda.judulBagian(
                                        'Hapus Dompet?',
                                      ),
                                      content: const TeksFunda.isi(
                                        'Dompet ini belum memiliki transaksi dan akan dihapus secara permanen.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, false),
                                          child: const Text('Batal'),
                                        ),
                                        TombolFunda.primer(
                                          teks: 'Hapus',
                                          padaTekan: () =>
                                              Navigator.pop(ctx, true),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (yakin == true) {
                                    await repoDompet.hapusDompetPermanen(
                                      dompet.id,
                                    );
                                    if (mounted) _tutupLayar();
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
                          spacing: SpasiFunda.s,
                          runSpacing: SpasiFunda.xs,
                          children: [
                            const TeksFunda.judulBagian(
                              'Kantong di Dompet Ini',
                            ),
                            TextButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (_) => const LayarDaftarKantong(),
                                  ),
                                );
                              },
                              icon: const IkonUiFunda(
                                pathAset: AsetIkonUiFunda.arrowRight,
                                ukuran: 16,
                              ),
                              label: const Text('Kelola Kantong'),
                            ),
                          ],
                        ),
                        const SizedBox(height: SpasiFunda.s),
                        daftarKantongAsync.when(
                          loading: () => const Center(child: IndikatorMemuat()),
                          error: (e, _) =>
                              Center(child: Text('Terjadi kesalahan: $e')),
                          data: (daftarKantong) {
                            if (daftarKantong.isEmpty) {
                              return Container(
                                padding: const EdgeInsets.all(SpasiFunda.l),
                                decoration: BoxDecoration(
                                  color: WarnaFunda.permukaan,
                                  borderRadius: BorderRadius.circular(
                                    SudutFunda.petak,
                                  ),
                                  border: Border.all(
                                    color: WarnaFunda.garis,
                                    width: 1.0,
                                  ),
                                ),
                                child: const Center(
                                  child: TeksFunda.catatan(
                                    'Belum ada kantong di dompet ini.',
                                  ),
                                ),
                              );
                            }

                            return Container(
                              decoration: BoxDecoration(
                                color: WarnaFunda.permukaan,
                                borderRadius: BorderRadius.circular(
                                  SudutFunda.petak,
                                ),
                                border: Border.all(
                                  color: WarnaFunda.garis,
                                  width: 1.0,
                                ),
                              ),
                              child: Column(
                                children: [
                                  for (
                                    var i = 0;
                                    i < daftarKantong.length;
                                    i++
                                  ) ...[
                                    () {
                                      final k = daftarKantong[i];
                                      final saldoKantongAsync = ref.watch(
                                        penyediaSaldoKantong(k.id),
                                      );
                                      final saldoK =
                                          saldoKantongAsync.value ?? 0;

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: SpasiFunda.l,
                                          vertical: SpasiFunda.m,
                                        ),
                                        child: Row(
                                          children: [
                                            IkonKategoriFunda(
                                              kunciIkon: k.ikon,
                                              ukuran: 20,
                                              warnaFallback: warnaAksen,
                                            ),
                                            const SizedBox(width: SpasiFunda.m),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
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
                                            const SizedBox(width: SpasiFunda.s),
                                            TeksFunda.label(
                                              formatRupiah(saldoK),
                                              angkaTabular: true,
                                            ),
                                          ],
                                        ),
                                      );
                                    }(),
                                    if (i < daftarKantong.length - 1)
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
                          },
                        ),
                        const SizedBox(height: SpasiFunda.xl),

                        // Riwayat Transaksi Dompet (Menyatu dalam 1 Kartu Putih Border 1px)
                        const TeksFunda.judulBagian(
                          'Riwayat Transaksi Dompet Ini',
                        ),
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
                                  borderRadius: BorderRadius.circular(
                                    SudutFunda.petak,
                                  ),
                                  border: Border.all(
                                    color: WarnaFunda.garis,
                                    width: 1.0,
                                  ),
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
                                Container(
                                  decoration: BoxDecoration(
                                    color: WarnaFunda.permukaan,
                                    borderRadius: BorderRadius.circular(
                                      SudutFunda.petak,
                                    ),
                                    border: Border.all(
                                      color: WarnaFunda.garis,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      for (
                                        var i = 0;
                                        i < daftar.length;
                                        i++
                                      ) ...[
                                        () {
                                          final t = daftar[i];
                                          final jenisTx =
                                              JenisTransaksi.dariKode(t.jenis);
                                          final isMasuk =
                                              jenisTx == JenisTransaksi.masuk ||
                                              jenisTx ==
                                                  JenisTransaksi
                                                      .penyesuaianMasuk ||
                                              (jenisTx ==
                                                      JenisTransaksi.transfer &&
                                                  t.dompetTujuanId ==
                                                      dompet.id);

                                          final tanda = isMasuk ? '+' : '-';
                                          final warnaNominal = isMasuk
                                              ? WarnaFunda.pemasukan
                                              : WarnaFunda.pengeluaran;

                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: SpasiFunda.l,
                                              vertical: SpasiFunda.m,
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  isMasuk
                                                      ? LucideIcons
                                                            .arrowDownLeft
                                                      : LucideIcons
                                                            .arrowUpRight,
                                                  size: 20,
                                                  color: warnaNominal,
                                                ),
                                                const SizedBox(
                                                  width: SpasiFunda.m,
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      TeksFunda.label(
                                                        jenisTx.label,
                                                      ),
                                                      if (t.catatan != null &&
                                                          t
                                                              .catatan!
                                                              .isNotEmpty) ...[
                                                        const SizedBox(
                                                          height: 2,
                                                        ),
                                                        TeksFunda.catatan(
                                                          t.catatan!,
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: SpasiFunda.s,
                                                ),
                                                TeksFunda.label(
                                                  '$tanda${formatRupiah(t.jumlahRupiah)}',
                                                  warna: warnaNominal,
                                                  angkaTabular: true,
                                                ),
                                              ],
                                            ),
                                          );
                                        }(),
                                        if (i < daftar.length - 1)
                                          const Divider(
                                            height: 1,
                                            indent: SpasiFunda.l,
                                            endIndent: SpasiFunda.l,
                                            color: WarnaFunda.garis,
                                          ),
                                      ],
                                    ],
                                  ),
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _arsipDompet(dynamic repoDompet, EntitasDompet dompet) async {
    await repoDompet.arsipkanDompet(dompet.id, !dompet.diarsipkan);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            dompet.diarsipkan
                ? 'Dompet berhasil dipulihkan.'
                : 'Dompet berhasil diarsipkan.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _tampilkanDialogSesuaikanSaldo(
    BuildContext context,
    WidgetRef ref,
    EntitasDompet dompet,
    int saldoSekarang,
  ) {
    final pengontrol = TextEditingController(text: formatRupiah(saldoSekarang));

    showDialog<void>(
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
          TombolFunda.pilGelap(
            teks: 'Simpan Penyesuaian',
            lebarPenuh: false,
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
