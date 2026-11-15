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

/// Layar rincian satu tujuan: memantau progres, kantong tertaut, alokasi isi/ambil dana, dan riwayat.
class LayarDetailTujuan extends ConsumerWidget {
  const LayarDetailTujuan({super.key, required this.tujuanId});

  final String tujuanId;

  void _bukaModalAlokasi(
    BuildContext context,
    WidgetRef ref, {
    required EntitasTujuan tujuan,
    required bool isIsi,
    required List<EntitasDompet> daftarDompet,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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

    return tujuanAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) =>
          Scaffold(body: Center(child: Text('Terjadi kesalahan: $e'))),
      data: (tujuan) {
        if (tujuan == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Tujuan tidak ditemukan')),
          );
        }

        final danaTerkumpul = danaTerkumpulAsync.value ?? 0;
        final progres = hitungProgresTujuan(
          danaRupiah: danaTerkumpul,
          targetRupiah: tujuan.targetRupiah,
        );
        final jenis = JenisTujuan.dariKode(tujuan.jenis);
        final sisaDana = tujuan.targetRupiah - danaTerkumpul;

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
          appBar: AppBar(
            title: TeksFunda.judulBagian(tujuan.nama),
            actions: [
              IconButton(
                icon: const Icon(LucideIcons.pencil),
                tooltip: 'Ubah Tujuan',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LayarFormTujuan(tujuan: tujuan),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(LucideIcons.trash2),
                tooltip: 'Hapus Tujuan',
                onPressed: () async {
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
                            content: Text(
                              e.toString().replaceFirst('Exception: ', ''),
                            ),
                          ),
                        );
                      }
                    }
                  }
                },
              ),
            ],
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(SpasiFunda.m),
              children: [
                // Kartu Bento Hero Tujuan
                PetakBento.ukuran2x1(
                  warnaKustom: ambilWarnaTint(tujuan.warna),
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
                              ambilIkonLucide(tujuan.ikon),
                              size: 20,
                              color: WarnaFunda.utama,
                            ),
                          ),
                          const SizedBox(width: SpasiFunda.m),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TeksFunda.label(tujuan.nama),
                                TeksFunda.catatan(jenis.label),
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
                              warna: WarnaFunda.utama,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: SpasiFunda.l),
                      const TeksFunda.isiKecil('Dana Terkumpul'),
                      const SizedBox(height: SpasiFunda.xs),
                      TeksFunda.angkaBesar(formatRupiah(danaTerkumpul)),
                      const SizedBox(height: SpasiFunda.m),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(SudutFunda.pil),
                        child: LinearProgressIndicator(
                          value: (progres / 100).clamp(0.0, 1.0),
                          minHeight: 8,
                          backgroundColor: WarnaFunda.garis,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progres >= 100
                                ? WarnaFunda.sukses
                                : WarnaFunda.utama,
                          ),
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
                          ),
                          TeksFunda.catatan(
                            sisaDana > 0
                                ? 'Sisa: ${formatRupiah(sisaDana)}'
                                : 'Target Tercapai!',
                            warna: sisaDana <= 0
                                ? WarnaFunda.sukses
                                : WarnaFunda.teksRedup,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: SpasiFunda.m),

                // Pesan Hangat Bila Target Tercapai (Tanpa Badge / Konfeti)
                if (progres >= 100) ...[
                  Container(
                    padding: const EdgeInsets.all(SpasiFunda.m),
                    decoration: BoxDecoration(
                      color: WarnaFunda.sukses.withAlpha(25),
                      borderRadius: BorderRadius.circular(SudutFunda.kartu),
                      border: Border.all(color: WarnaFunda.sukses),
                    ),
                    child: const Row(
                      children: [
                        Icon(LucideIcons.checkCheck, color: WarnaFunda.sukses),
                        SizedBox(width: SpasiFunda.m),
                        Expanded(
                          child: TeksFunda.isi(
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
                    padding: const EdgeInsets.all(SpasiFunda.m),
                    decoration: BoxDecoration(
                      color: WarnaFunda.permukaan,
                      borderRadius: BorderRadius.circular(SudutFunda.kartu),
                      border: Border.all(color: WarnaFunda.garis),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(LucideIcons.calendar, size: 18),
                            const SizedBox(width: SpasiFunda.s),
                            Expanded(
                              child: TeksFunda.label(
                                'Tenggat: ${DateFormat('d MMMM yyyy', 'id_ID').format(tujuan.tenggat!)}',
                              ),
                            ),
                          ],
                        ),
                        if (setoranBulanan != null && setoranBulanan > 0) ...[
                          const SizedBox(height: SpasiFunda.xs),
                          TeksFunda.catatan(
                            'Perkiraan setoran: ${formatRupiah(setoranBulanan)} / bulan agar tercapai tepat waktu.',
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: SpasiFunda.m),
                ],

                // Baris Tombol Aksi: Isi & Ambil
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isTeksBesar =
                        MediaQuery.textScalerOf(context).scale(1.0) > 1.3 ||
                        constraints.maxWidth < 340;
                    if (isTeksBesar) {
                      return Column(
                        children: [
                          TombolFunda.primer(
                            teks: 'Isi Tujuan',
                            ikon: const Icon(LucideIcons.plusCircle, size: 18),
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
                            ikon: const Icon(LucideIcons.minusCircle, size: 18),
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
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(
                          child: TombolFunda.primer(
                            teks: 'Isi Tujuan',
                            ikon: const Icon(LucideIcons.plusCircle, size: 18),
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
                            ikon: const Icon(LucideIcons.minusCircle, size: 18),
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
                    );
                  },
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
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
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
                            'Belum ada alokasi dana ke kantong dompet manapun.',
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: daftarKantong.map((k) {
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

                        return Container(
                          margin: const EdgeInsets.only(bottom: SpasiFunda.s),
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
                              Icon(ambilIkonLucide(dompet.ikon), size: 18),
                              const SizedBox(width: SpasiFunda.s),
                              Expanded(child: Text(dompet.nama)),
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
                const SizedBox(height: SpasiFunda.l),

                // Riwayat Alokasi Dana Tujuan
                const TeksFunda.judulBagian('Riwayat Alokasi Tujuan'),
                const SizedBox(height: SpasiFunda.s),
                riwayatAlokasiAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Terjadi kesalahan: $e')),
                  data: (daftarAlokasi) {
                    if (daftarAlokasi.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(SpasiFunda.m),
                        decoration: BoxDecoration(
                          color: WarnaFunda.permukaan,
                          borderRadius: BorderRadius.circular(SudutFunda.kartu),
                          border: Border.all(color: WarnaFunda.garis),
                        ),
                        child: const Center(
                          child: TeksFunda.catatan(
                            'Belum ada riwayat pengisian atau penarikan dana.',
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: daftarAlokasi.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: SpasiFunda.s),
                      itemBuilder: (context, index) {
                        final alokasi = daftarAlokasi[index];
                        final isIsi = alokasi.jenis == JenisAlokasi.isi.kode;
                        final tanda = isIsi ? '+' : '-';
                        final warnaNominal = isIsi
                            ? WarnaFunda.sukses
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
                                padding: const EdgeInsets.all(SpasiFunda.xs),
                                decoration: BoxDecoration(
                                  color: isIsi
                                      ? WarnaFunda.tintHijau
                                      : WarnaFunda.tintAmber,
                                  borderRadius: BorderRadius.circular(
                                    SudutFunda.kecil,
                                  ),
                                ),
                                child: Icon(
                                  isIsi
                                      ? LucideIcons.arrowDownLeft
                                      : LucideIcons.arrowUpRight,
                                  size: 16,
                                  color: warnaNominal,
                                ),
                              ),
                              const SizedBox(width: SpasiFunda.m),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TeksFunda.label(
                                      isIsi ? 'Isi Tujuan' : 'Ambil Dana',
                                    ),
                                    TeksFunda.catatan(
                                      DateFormat(
                                        'd MMM yyyy, HH:mm',
                                        'id_ID',
                                      ).format(alokasi.dibuatPada),
                                    ),
                                    if (alokasi.catatan != null &&
                                        alokasi.catatan!.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      TeksFunda.catatan(alokasi.catatan!),
                                    ],
                                  ],
                                ),
                              ),
                              TeksFunda.label(
                                '$tanda${formatRupiah(alokasi.jumlahRupiah)}',
                                warna: warnaNominal,
                                angkaTabular: true,
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: SpasiFunda.xxl),
              ],
            ),
          ),
        );
      },
    );
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
      // 1. Ambil atau buat kantong untuk dompet dan tujuan ini
      final kantong = await repoKantong.ambilAtauBuatKantongTujuan(
        dompetId: _dompetTerpilihId!,
        tujuanId: widget.tujuan.id,
        namaKantong: widget.tujuan.nama,
        ikon: widget.tujuan.ikon,
        warna: widget.tujuan.warna,
      );

      // 2. Alokasikan dana
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

    return Padding(
      padding: EdgeInsets.only(
        left: SpasiFunda.m,
        right: SpasiFunda.m,
        top: SpasiFunda.m,
        bottom: MediaQuery.of(context).viewInsets.bottom + SpasiFunda.m,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TeksFunda.judulBagian(judul),
              IconButton(
                icon: const Icon(LucideIcons.x),
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
                color: WarnaFunda.pengeluaran.withAlpha(25),
                borderRadius: BorderRadius.circular(SudutFunda.kecil),
                border: Border.all(color: WarnaFunda.pengeluaran),
              ),
              child: Text(
                _pesanGalat!,
                style: const TextStyle(color: WarnaFunda.pengeluaran),
              ),
            ),
            const SizedBox(height: SpasiFunda.m),
          ],

          // Pilih Dompet Sumber
          const TeksFunda.label('Pilih Dompet Sumber / Penyimpan'),
          const SizedBox(height: SpasiFunda.xs),
          DropdownButtonFormField<String>(
            initialValue: _dompetTerpilihId,
            decoration: InputDecoration(
              filled: true,
              fillColor: WarnaFunda.latar,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SudutFunda.kecil),
                borderSide: const BorderSide(color: WarnaFunda.garis),
              ),
            ),
            items: widget.daftarDompet.map((d) {
              return DropdownMenuItem(
                value: d.id,
                child: Row(
                  children: [
                    Icon(ambilIkonLucide(d.ikon), size: 18),
                    const SizedBox(width: SpasiFunda.s),
                    Text(d.nama),
                  ],
                ),
              );
            }).toList(),
            onChanged: (val) => setState(() => _dompetTerpilihId = val),
          ),
          const SizedBox(height: SpasiFunda.m),

          // Input Nominal
          const TeksFunda.label('Nominal Alokasi (Rupiah)'),
          const SizedBox(height: SpasiFunda.xs),
          TextField(
            controller: _pengontrolNominal,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Rp 0',
              prefixIcon: const Icon(LucideIcons.coins),
              filled: true,
              fillColor: WarnaFunda.latar,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SudutFunda.kecil),
                borderSide: const BorderSide(color: WarnaFunda.garis),
              ),
            ),
            onChanged: _padaUbahNominal,
          ),
          const SizedBox(height: SpasiFunda.m),

          // Catatan Opsional
          const TeksFunda.label('Catatan (Opsional)'),
          const SizedBox(height: SpasiFunda.xs),
          TextField(
            controller: _pengontrolCatatan,
            decoration: InputDecoration(
              hintText: 'Contoh: Tabungan gaji bulan ini',
              filled: true,
              fillColor: WarnaFunda.latar,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SudutFunda.kecil),
                borderSide: const BorderSide(color: WarnaFunda.garis),
              ),
            ),
          ),
          const SizedBox(height: SpasiFunda.l),

          // Tombol Kirim
          TombolFunda.primer(
            teks: judul,
            lebarPenuh: true,
            memuat: _sedangMemuat,
            padaTekan: _jumlahRupiah > 0 && _dompetTerpilihId != null
                ? _kirim
                : null,
          ),
          const SizedBox(height: SpasiFunda.m),
        ],
      ),
    );
  }
}
