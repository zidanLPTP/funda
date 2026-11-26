import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../data/basis_data.dart';
import '../../../data/model/jenis_alokasi.dart';
import '../../../data/model/jenis_tujuan.dart';
import '../../../data/penyedia_basis_data.dart';
import '../../../komponen/komponen_funda.dart';
import '../../../komponen/pembantu_ikon.dart';
import '../../../komponen/pembantu_tint.dart';
import '../../../perhitungan/perhitungan_anggaran_tujuan.dart';
import '../../../tema/token.dart';
import '../../../util/format_rupiah.dart';
import '../../dompet/kontroler/penyedia_dompet.dart';
import '../../kantong/kontroler/penyedia_kantong.dart';
import '../kontroler/penyedia_tujuan.dart';
import 'layar_form_tujuan.dart';

/// Layar rincian satu tujuan bergaya editorial bersih:
/// header tombol kembali >= 48dp, hero kanvas progres, aksi pilGelap, dan daftar menyatu 1px.
class LayarDetailTujuan extends ConsumerWidget {
  const LayarDetailTujuan({super.key, required this.tujuanId});

  final String tujuanId;

  static Color _kanvasTujuan(String kunci) {
    return switch (kunci) {
      'biru' => WarnaFunda.kanvasBiru,
      'hijau' => WarnaFunda.kanvasMint,
      'amber' => WarnaFunda.kanvasKuning,
      'merah' => WarnaFunda.kanvasKoral,
      _ => ambilWarnaTint(kunci),
    };
  }

  static Color _aksenTujuan(String kunci) {
    return switch (kunci) {
      'biru' => WarnaFunda.sifatKebutuhan,
      'hijau' => WarnaFunda.utama,
      'amber' => WarnaFunda.peringatan,
      'merah' => WarnaFunda.pengeluaran,
      _ => ambilWarnaAksenTint(kunci),
    };
  }

  void _bukaModalAlokasi(
    BuildContext context,
    WidgetRef ref, {
    required EntitasTujuan tujuan,
    required bool isIsi,
    required List<EntitasDompet> daftarDompet,
  }) {
    final tanpaAnimasi =
        MediaQuery.disableAnimationsOf(context) ||
        ref.read(penyediaTanpaAnimasi);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      sheetAnimationStyle: tanpaAnimasi ? AnimationStyle.noAnimation : null,
      backgroundColor: WarnaFunda.permukaan,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SudutFunda.lembar),
        ),
      ),
      builder: (ctx) => _LembarFormAlokasi(
        tujuan: tujuan,
        isIsi: isIsi,
        daftarDompet: daftarDompet,
        padaSelesai: () {
          ref.invalidate(penyediaDanaTujuan(tujuan.id));
          ref.invalidate(penyediaRiwayatAlokasiTujuan(tujuan.id));
          ref.invalidate(penyediaKantongTujuan(tujuan.id));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tujuanAsync = ref.watch(penyediaDetailTujuan(tujuanId));
    final danaTerkumpulAsync = ref.watch(penyediaDanaTujuan(tujuanId));
    final daftarKantongAsync = ref.watch(penyediaKantongTujuan(tujuanId));
    final riwayatAlokasiAsync = ref.watch(
      penyediaRiwayatAlokasiTujuan(tujuanId),
    );
    final daftarDompet = ref.watch(penyediaDaftarDompetAktif).value ?? [];
    final semuaDompet = ref.watch(penyediaDaftarDompet).value ?? [];
    final repoTujuan = ref.watch(penyediaTujuanRepositori);
    final isTeksBesar = MediaQuery.textScalerOf(context).scale(1) > 1.3;

    return tujuanAsync.when(
      loading: () => const Scaffold(
        backgroundColor: WarnaFunda.latar,
        body: Center(child: IndikatorMemuat()),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: WarnaFunda.latar,
        body: Center(child: Text('Terjadi kesalahan: $e')),
      ),
      data: (tujuan) {
        if (tujuan == null) {
          return const Scaffold(
            backgroundColor: WarnaFunda.latar,
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(SpasiFunda.marginLayar),
                    child: HeaderSubLayarEditorial(judul: 'Tujuan'),
                  ),
                  Expanded(
                    child: Center(child: Text('Tujuan tidak ditemukan')),
                  ),
                ],
              ),
            ),
          );
        }

        final danaTerkumpul = danaTerkumpulAsync.value ?? 0;
        final progres = hitungProgresTujuan(
          danaRupiah: danaTerkumpul,
          targetRupiah: tujuan.targetRupiah,
        );
        final jenis = JenisTujuan.dariKode(tujuan.jenis);
        final sisaDana = tujuan.targetRupiah - danaTerkumpul;
        final warnaKanvas = _kanvasTujuan(tujuan.warna);
        final warnaAksen = _aksenTujuan(tujuan.warna);

        int? setoranBulanan;
        if (tujuan.tenggat != null && sisaDana > 0) {
          setoranBulanan = hitungSetoranBulananDibutuhkan(
            targetRupiah: tujuan.targetRupiah,
            danaTerkumpulRupiah: danaTerkumpul,
            tenggat: tujuan.tenggat,
            waktuSekarang: DateTime.now(),
          );
        }

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
                    judul: tujuan.nama,
                    aksiKanan: [
                      TombolPilHeaderEditorial(
                        teks: 'Ubah',
                        ikon: LucideIcons.pencil,
                        padaTekan: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => LayarFormTujuan(tujuan: tujuan),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: SpasiFunda.xs),
                      TombolPilHeaderEditorial(
                        teks: 'Hapus',
                        ikon: LucideIcons.trash2,
                        warnaTeks: WarnaFunda.bahaya,
                        padaTekan: () =>
                            _konfirmasiHapus(context, repoTujuan, tujuan),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      SpasiFunda.marginLayar,
                      SpasiFunda.s,
                      SpasiFunda.marginLayar,
                      SpasiFunda.xxl,
                    ),
                    children: [
                      // Hero Kanvas Tujuan
                      Container(
                        key: const Key('hero_kanvas_detail_tujuan'),
                        padding: const EdgeInsets.all(SpasiFunda.l),
                        decoration: BoxDecoration(
                          color: warnaKanvas,
                          borderRadius: BorderRadius.circular(SudutFunda.petak),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                IkonKategoriFunda(
                                  kunciIkon: tujuan.ikon,
                                  ukuran: 24,
                                  warnaFallback: warnaAksen,
                                ),
                                const SizedBox(width: SpasiFunda.m),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TeksFunda.label(tujuan.nama),
                                      TeksFunda.catatan(
                                        jenis.label,
                                        warna: WarnaFunda.teksRedup,
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
                                    borderRadius: BorderRadius.circular(
                                      SudutFunda.pil,
                                    ),
                                  ),
                                  child: TeksFunda.catatan(
                                    '$progres%',
                                    angkaTabular: true,
                                    warna: WarnaFunda.utama,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: SpasiFunda.l),
                            const TeksFunda.catatan(
                              'Dana Terkumpul',
                              warna: WarnaFunda.teksRedup,
                            ),
                            const SizedBox(height: SpasiFunda.xs),
                            TeksFunda.angkaBesar(
                              formatRupiah(danaTerkumpul),
                              angkaTabular: true,
                            ),
                            const SizedBox(height: SpasiFunda.m),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                SudutFunda.pil,
                              ),
                              child: IndikatorMemuat.garis(
                                nilai: (progres / 100).clamp(0.0, 1.0),
                                tinggi: 8,
                                warnaLatar: WarnaFunda.permukaan,
                                warna: progres >= 100
                                    ? WarnaFunda.sukses
                                    : WarnaFunda.utama,
                              ),
                            ),
                            const SizedBox(height: SpasiFunda.s),
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              spacing: SpasiFunda.m,
                              runSpacing: SpasiFunda.xs,
                              children: [
                                TeksFunda.catatan(
                                  'Target: ${formatRupiah(tujuan.targetRupiah)}',
                                  angkaTabular: true,
                                ),
                                TeksFunda.catatan(
                                  sisaDana > 0
                                      ? 'Sisa: ${formatRupiah(sisaDana)}'
                                      : 'Target Tercapai!',
                                  angkaTabular: true,
                                  warna: sisaDana <= 0
                                      ? WarnaFunda.pemasukan
                                      : WarnaFunda.teksRedup,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: SpasiFunda.m),

                      // Pesan Hangat Bila Target Tercapai
                      if (progres >= 100) ...[
                        Container(
                          padding: const EdgeInsets.all(SpasiFunda.m),
                          decoration: BoxDecoration(
                            color: WarnaFunda.permukaan,
                            borderRadius: BorderRadius.circular(
                              SudutFunda.petak,
                            ),
                            border: Border.all(
                              color: WarnaFunda.batasHijau,
                              width: 1.0,
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                LucideIcons.checkCheck,
                                color: WarnaFunda.pemasukan,
                              ),
                              SizedBox(width: SpasiFunda.m),
                              Expanded(
                                child: TeksFunda.isiKecil(
                                  'Selamat! Target tujuanmu telah tercapai. Dana tersimpan rapi di kantong dompetmu.',
                                  warna: WarnaFunda.teks,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: SpasiFunda.m),
                      ],

                      // Kartu Info Tenggat & Setoran Bulanan yang Dibutuhkan
                      if (tujuan.tenggat != null) ...[
                        Container(
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    LucideIcons.calendar,
                                    size: 18,
                                    color: WarnaFunda.utama,
                                  ),
                                  const SizedBox(width: SpasiFunda.s),
                                  Expanded(
                                    child: TeksFunda.label(
                                      'Tenggat: ${DateFormat('d MMMM yyyy', 'id_ID').format(tujuan.tenggat!)}',
                                    ),
                                  ),
                                ],
                              ),
                              if (setoranBulanan != null &&
                                  setoranBulanan > 0) ...[
                                const SizedBox(height: SpasiFunda.xs),
                                TeksFunda.catatan(
                                  'Perkiraan setoran: ${formatRupiah(setoranBulanan)} / bulan agar tercapai tepat waktu.',
                                  angkaTabular: true,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: SpasiFunda.m),
                      ],

                      // Baris Tombol Aksi: Isi Tujuan (pilGelap) & Ambil Dana
                      if (isTeksBesar) ...[
                        TombolFunda.pilGelap(
                          teks: 'Isi Tujuan',
                          lebarPenuh: true,
                          ikon: const Icon(LucideIcons.circlePlus, size: 18),
                          padaTekan: () => _bukaModalAlokasi(
                            context,
                            ref,
                            tujuan: tujuan,
                            isIsi: true,
                            daftarDompet: daftarDompet,
                          ),
                        ),
                        const SizedBox(height: SpasiFunda.s),
                        TombolFunda.sekunder(
                          teks: 'Ambil Dana',
                          lebarPenuh: true,
                          ikon: const Icon(LucideIcons.circleMinus, size: 18),
                          padaTekan: danaTerkumpul > 0
                              ? () => _bukaModalAlokasi(
                                  context,
                                  ref,
                                  tujuan: tujuan,
                                  isIsi: false,
                                  daftarDompet: daftarDompet,
                                )
                              : null,
                        ),
                      ] else
                        Row(
                          children: [
                            Expanded(
                              child: TombolFunda.pilGelap(
                                teks: 'Isi Tujuan',
                                lebarPenuh: false,
                                ikon: const Icon(
                                  LucideIcons.circlePlus,
                                  size: 18,
                                ),
                                padaTekan: () => _bukaModalAlokasi(
                                  context,
                                  ref,
                                  tujuan: tujuan,
                                  isIsi: true,
                                  daftarDompet: daftarDompet,
                                ),
                              ),
                            ),
                            const SizedBox(width: SpasiFunda.m),
                            Expanded(
                              child: TombolFunda.sekunder(
                                teks: 'Ambil Dana',
                                ikon: const Icon(
                                  LucideIcons.circleMinus,
                                  size: 18,
                                ),
                                padaTekan: danaTerkumpul > 0
                                    ? () => _bukaModalAlokasi(
                                        context,
                                        ref,
                                        tujuan: tujuan,
                                        isIsi: false,
                                        daftarDompet: daftarDompet,
                                      )
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: SpasiFunda.l),

                      // Bagian Kantong Tertaut
                      const TeksFunda.judulBagian('Kantong Dompet Tertaut'),
                      const SizedBox(height: SpasiFunda.xs),
                      const TeksFunda.catatan(
                        'Uang tujuan ini disimpan secara terpisah di kantong dompet berikut:',
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
                                  'Belum ada alokasi dana ke kantong dompet manapun.',
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
                                    final dompet = semuaDompet.firstWhere(
                                      (d) => d.id == k.dompetId,
                                      orElse: () => EntitasDompet(
                                        id: '',
                                        nama: 'Dompet',
                                        jenis: 'lainnya',
                                        ikon: 'wallet',
                                        warna: 'netral',
                                        saldoAwalRupiah: 0,
                                        urutan: 0,
                                        diarsipkan: false,
                                        dibuatPada: DateTime.now(),
                                      ),
                                    );
                                    final saldoKantongAsync = ref.watch(
                                      penyediaSaldoKantong(k.id),
                                    );
                                    final saldoK = saldoKantongAsync.value ?? 0;

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: SpasiFunda.l,
                                        vertical: SpasiFunda.m,
                                      ),
                                      child: Row(
                                        children: [
                                          IkonDompetFunda(
                                            kodeJenis: dompet.jenis,
                                            kunciIkonFallback: dompet.ikon,
                                            ukuran: 20,
                                            warnaFallback: warnaAksen,
                                          ),
                                          const SizedBox(width: SpasiFunda.m),
                                          Expanded(
                                            child: TeksFunda.label(dompet.nama),
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
                      const SizedBox(height: SpasiFunda.l),

                      // Riwayat Alokasi Dana Tujuan
                      const TeksFunda.judulBagian('Riwayat Alokasi Tujuan'),
                      const SizedBox(height: SpasiFunda.s),
                      riwayatAlokasiAsync.when(
                        loading: () => const Center(child: IndikatorMemuat()),
                        error: (e, _) =>
                            Center(child: Text('Terjadi kesalahan: $e')),
                        data: (daftarAlokasi) {
                          if (daftarAlokasi.isEmpty) {
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
                                  'Belum ada riwayat pengisian atau penarikan dana.',
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
                                  i < daftarAlokasi.length;
                                  i++
                                ) ...[
                                  () {
                                    final alokasi = daftarAlokasi[i];
                                    final isIsi =
                                        alokasi.jenis == JenisAlokasi.isi.kode;
                                    final tanda = isIsi ? '+' : '-';
                                    final warnaNominal = isIsi
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
                                            isIsi
                                                ? LucideIcons.arrowDownLeft
                                                : LucideIcons.arrowUpRight,
                                            size: 20,
                                            color: warnaNominal,
                                          ),
                                          const SizedBox(width: SpasiFunda.m),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                TeksFunda.label(
                                                  isIsi
                                                      ? 'Isi Tujuan'
                                                      : 'Ambil Dana',
                                                ),
                                                TeksFunda.catatan(
                                                  DateFormat(
                                                    'd MMM yyyy, HH:mm',
                                                    'id_ID',
                                                  ).format(alokasi.dibuatPada),
                                                ),
                                                if (alokasi.catatan != null &&
                                                    alokasi
                                                        .catatan!
                                                        .isNotEmpty) ...[
                                                  const SizedBox(height: 2),
                                                  TeksFunda.catatan(
                                                    alokasi.catatan!,
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: SpasiFunda.s),
                                          TeksFunda.label(
                                            '$tanda${formatRupiah(alokasi.jumlahRupiah)}',
                                            warna: warnaNominal,
                                            angkaTabular: true,
                                          ),
                                        ],
                                      ),
                                    );
                                  }(),
                                  if (i < daftarAlokasi.length - 1)
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
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _konfirmasiHapus(
    BuildContext context,
    dynamic repoTujuan,
    EntitasTujuan tujuan,
  ) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const TeksFunda.judulBagian('Hapus Tujuan?'),
        content: const TeksFunda.isi(
          'Tujuan hanya dapat dihapus jika semua kantong tertaut sudah tidak memiliki saldo.',
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
      try {
        await repoTujuan.hapusTujuan(tujuan.id);
        if (context.mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceFirst('Exception: ', '')),
            ),
          );
        }
      }
    }
  }
}

class _LembarFormAlokasi extends ConsumerStatefulWidget {
  const _LembarFormAlokasi({
    required this.tujuan,
    required this.isIsi,
    required this.daftarDompet,
    required this.padaSelesai,
  });

  final EntitasTujuan tujuan;
  final bool isIsi;
  final List<EntitasDompet> daftarDompet;
  final VoidCallback padaSelesai;

  @override
  ConsumerState<_LembarFormAlokasi> createState() => _LembarFormAlokasiState();
}

class _LembarFormAlokasiState extends ConsumerState<_LembarFormAlokasi> {
  final _pengontrolNominal = TextEditingController();
  final _pengontrolCatatan = TextEditingController();
  String? _dompetTerpilihId;
  int _jumlahRupiah = 0;
  bool _sedangMemuat = false;
  String? _pesanGalat;

  @override
  void initState() {
    super.initState();
    if (widget.daftarDompet.isNotEmpty) {
      _dompetTerpilihId = widget.daftarDompet.first.id;
    }
  }

  @override
  void dispose() {
    _pengontrolNominal.dispose();
    _pengontrolCatatan.dispose();
    super.dispose();
  }

  void _padaUbahNominal(String teks) {
    final digit = teks.replaceAll(RegExp(r'[^0-9]'), '');
    final nilai = int.tryParse(digit) ?? 0;
    setState(() {
      _jumlahRupiah = nilai;
    });
  }

  Future<void> _kirim() async {
    if (_jumlahRupiah <= 0 || _dompetTerpilihId == null) return;

    setState(() {
      _sedangMemuat = true;
      _pesanGalat = null;
    });

    final repoKantong = ref.read(penyediaKantongRepositori);

    try {
      final kantong = await repoKantong.ambilAtauBuatKantongTujuan(
        dompetId: _dompetTerpilihId!,
        tujuanId: widget.tujuan.id,
        namaKantong: widget.tujuan.nama,
        ikon: widget.tujuan.ikon,
        warna: widget.tujuan.warna,
      );

      await repoKantong.alokasikanDanaKantong(
        kantongId: kantong.id,
        jenis: widget.isIsi ? JenisAlokasi.isi.kode : JenisAlokasi.ambil.kode,
        jumlahRupiah: _jumlahRupiah,
        catatan: _pengontrolCatatan.text.trim().isEmpty
            ? null
            : _pengontrolCatatan.text.trim(),
      );

      widget.padaSelesai();
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _pesanGalat = e.toString().replaceFirst('Exception: ', '');
        _sedangMemuat = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final judul = widget.isIsi ? 'Isi Dana Tujuan' : 'Ambil Dana Tujuan';

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: SpasiFunda.l,
          right: SpasiFunda.l,
          top: SpasiFunda.l,
          bottom: MediaQuery.of(context).viewInsets.bottom + SpasiFunda.l,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: TeksFunda.judulBagian(judul)),
                IconButton(
                  icon: const Icon(LucideIcons.x),
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: SpasiFunda.s),
            const TeksFunda.catatan(
              'Alokasi ini menandai uang di dalam dompetmu tanpa memindahkan rekening.',
            ),
            const SizedBox(height: SpasiFunda.m),
            if (_pesanGalat != null) ...[
              Container(
                padding: const EdgeInsets.all(SpasiFunda.s),
                decoration: BoxDecoration(
                  color: WarnaFunda.tintMawar,
                  borderRadius: BorderRadius.circular(SudutFunda.kartu),
                  border: Border.all(color: WarnaFunda.pengeluaran),
                ),
                child: Text(
                  _pesanGalat!,
                  style: const TextStyle(color: WarnaFunda.pengeluaran),
                ),
              ),
              const SizedBox(height: SpasiFunda.m),
            ],

            const TeksFunda.label('Pilih Dompet Sumber / Penyimpan'),
            const SizedBox(height: SpasiFunda.xs),
            DropdownButtonFormField<String>(
              initialValue: _dompetTerpilihId,
              isExpanded: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: WarnaFunda.latar,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SudutFunda.kartu),
                  borderSide: const BorderSide(color: WarnaFunda.garis),
                ),
              ),
              items: widget.daftarDompet.map((d) {
                return DropdownMenuItem(
                  value: d.id,
                  child: Row(
                    children: [
                      IkonDompetFunda(
                        kodeJenis: d.jenis,
                        kunciIkonFallback: d.ikon,
                        ukuran: 18,
                      ),
                      const SizedBox(width: SpasiFunda.s),
                      Expanded(
                        child: Text(d.nama, overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) => setState(() => _dompetTerpilihId = val),
            ),
            const SizedBox(height: SpasiFunda.m),

            const TeksFunda.label('Nominal Alokasi (Rupiah)'),
            const SizedBox(height: SpasiFunda.xs),
            TextField(
              controller: _pengontrolNominal,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Rp 0',
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(12),
                  child: IkonSvgFunda(
                    pathAset: AsetIkonFunda.kasKoin,
                    ukuran: 20,
                  ),
                ),
                filled: true,
                fillColor: WarnaFunda.latar,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SudutFunda.kartu),
                  borderSide: const BorderSide(color: WarnaFunda.garis),
                ),
              ),
              onChanged: _padaUbahNominal,
            ),
            const SizedBox(height: SpasiFunda.m),

            const TeksFunda.label('Catatan (Opsional)'),
            const SizedBox(height: SpasiFunda.xs),
            TextField(
              controller: _pengontrolCatatan,
              decoration: InputDecoration(
                hintText: 'Contoh: Tabungan gaji bulan ini',
                filled: true,
                fillColor: WarnaFunda.latar,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SudutFunda.kartu),
                  borderSide: const BorderSide(color: WarnaFunda.garis),
                ),
              ),
            ),
            const SizedBox(height: SpasiFunda.l),

            TombolFunda.pilGelap(
              teks: judul,
              lebarPenuh: true,
              memuat: _sedangMemuat,
              padaTekan: _jumlahRupiah > 0 && _dompetTerpilihId != null
                  ? _kirim
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
