import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../data/basis_data.dart';
import '../../../data/model/arah_penyesuaian_utang.dart';
import '../../../data/model/jenis_utang.dart';
import '../../../data/penyedia_basis_data.dart';
import '../../../data/repositori/utang_repositori.dart';
import '../../../komponen/komponen_funda.dart';
import '../../../perhitungan/perhitungan_utang_dashboard.dart';
import '../../../tema/token.dart';
import '../../../util/format_rupiah.dart';
import '../../dompet/kontroler/penyedia_dompet.dart';
import '../../kategori/kontroler/penyedia_kategori.dart';
import '../kontroler/penyedia_utang.dart';
import 'layar_form_utang.dart';

/// Layar detail catatan utang bergaya editorial bersih:
/// header tombol kembali >= 48dp, hero kanvas sisa utang, tombol Catat Bayar pilGelap,
/// serta informasi pinjaman & riwayat menyatu dalam kartu putih border 1px.
class LayarDetailUtang extends ConsumerStatefulWidget {
  const LayarDetailUtang({super.key, required this.utangId});

  final String utangId;

  @override
  ConsumerState<LayarDetailUtang> createState() => _LayarDetailUtangState();
}

class _LayarDetailUtangState extends ConsumerState<LayarDetailUtang> {
  void _bukaDialogBayar(EntitasUtang utang, int sisaUtangSaatIni) {
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
      builder: (ctx) => _LembarCatatPembayaranUtang(
        utang: utang,
        sisaUtangSaatIni: sisaUtangSaatIni,
      ),
    );
  }

  void _bukaDialogSesuaikan(EntitasUtang utang) {
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
      builder: (ctx) => _LembarSesuaikanSisaUtang(utang: utang),
    );
  }

  Future<void> _arsipkanUtang() async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const TeksFunda.judulBagian('Arsipkan Utang?'),
        content: const TeksFunda.isi(
          'Catatan utang ini akan dipindahkan ke arsip dan tidak ditampilkan di daftar aktif maupun dashboard.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const TeksFunda.isi('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const TeksFunda.isi(
              'Arsipkan',
              warna: WarnaFunda.pengeluaran,
            ),
          ),
        ],
      ),
    );

    if (yakin == true && mounted) {
      final repo = ref.read(penyediaUtangRepositori);
      await repo.arsipkanUtang(widget.utangId);
      if (mounted) {
        final router = GoRouter.maybeOf(context);
        if (router != null) {
          router.pop();
        } else {
          Navigator.maybePop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(penyediaUtangRepositori);
    final sisaUtangAsync = ref.watch(penyediaSisaUtang(widget.utangId));
    final riwayatBayarAsync = ref.watch(
      penyediaRiwayatPembayaranUtang(widget.utangId),
    );
    final riwayatPenyesuaianAsync = ref.watch(
      penyediaRiwayatPenyesuaianUtang(widget.utangId),
    );
    final isTeksBesar = MediaQuery.textScalerOf(context).scale(1) > 1.3;

    return FutureBuilder<EntitasUtang?>(
      future: repo.ambilUtangBerdasarkanId(widget.utangId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            backgroundColor: WarnaFunda.latar,
            body: Center(child: IndikatorMemuat()),
          );
        }

        final utang = snapshot.data!;
        final sisaUtang = sisaUtangAsync.value ?? utang.sisaAwalRupiah;
        final sudahLunas = utang.status == 'lunas' || sisaUtang == 0;
        final estimasiBulan = hitungEstimasiSisaBulan(
          sisaRupiah: sisaUtang,
          cicilanBulananRupiah: utang.cicilanBulananRupiah,
        );
        final totalTerbayar = (utang.sisaAwalRupiah - sisaUtang).clamp(
          0,
          utang.sisaAwalRupiah,
        );

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
                    judul: utang.nama,
                    aksiKanan: [
                      TombolPilHeaderEditorial(
                        teks: 'Ubah',
                        ikon: LucideIcons.pencil,
                        padaTekan: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => LayarFormUtang(utang: utang),
                            ),
                          ).then((_) => setState(() {}));
                        },
                      ),
                      const SizedBox(width: SpasiFunda.xs),
                      TombolPilHeaderEditorial(
                        teks: 'Arsipkan',
                        ikon: LucideIcons.archive,
                        warnaTeks: WarnaFunda.teksRedup,
                        padaTekan: _arsipkanUtang,
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
                      // 1. Pesan Hangat jika Sudah Lunas
                      if (sudahLunas) ...[
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
                                  'Utang ini sudah lunas. Selamat atas langkah baik dan komitmen finansialmu!',
                                  warna: WarnaFunda.teks,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: SpasiFunda.m),
                      ],

                      // 2. Hero Kanvas: Sisa Utang & Info Cicilan
                      Container(
                        key: const Key('hero_kanvas_detail_utang'),
                        padding: const EdgeInsets.all(SpasiFunda.l),
                        decoration: BoxDecoration(
                          color: sudahLunas
                              ? WarnaFunda.kanvasMint
                              : WarnaFunda.kanvasKuning,
                          borderRadius: BorderRadius.circular(SudutFunda.petak),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: SpasiFunda.s,
                              runSpacing: SpasiFunda.xs,
                              children: [
                                const TeksFunda.label('Sisa Utang Saat Ini'),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: SpasiFunda.s,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: WarnaFunda.permukaan,
                                    borderRadius: BorderRadius.circular(
                                      SudutFunda.pil,
                                    ),
                                  ),
                                  child: TeksFunda.catatan(
                                    sudahLunas ? 'Lunas' : 'Aktif',
                                    warna: sudahLunas
                                        ? WarnaFunda.pemasukan
                                        : WarnaFunda.peringatan,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: SpasiFunda.s),
                            TeksFunda.angkaBesar(
                              formatRupiah(sisaUtang),
                              angkaTabular: true,
                            ),
                            const SizedBox(height: SpasiFunda.m),
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              spacing: SpasiFunda.m,
                              runSpacing: SpasiFunda.s,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const TeksFunda.catatan('Cicilan Bulanan'),
                                    TeksFunda.label(
                                      utang.cicilanBulananRupiah > 0
                                          ? formatRupiah(
                                              utang.cicilanBulananRupiah,
                                            )
                                          : 'Tidak rutin',
                                      angkaTabular: true,
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const TeksFunda.catatan('Estimasi Sisa'),
                                    TeksFunda.label(
                                      estimasiBulan != null
                                          ? '$estimasiBulan bulan lagi'
                                          : (sudahLunas ? 'Tuntas' : '-'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: SpasiFunda.m),

                      // 3. Tombol Aksi: Catat Bayar (pilGelap) & Sesuaikan
                      if (isTeksBesar) ...[
                        TombolFunda.pilGelap(
                          teks: 'Catat Pembayaran',
                          lebarPenuh: true,
                          ikon: const Icon(
                            LucideIcons.circleDollarSign,
                            size: 18,
                          ),
                          padaTekan: sudahLunas
                              ? null
                              : () => _bukaDialogBayar(utang, sisaUtang),
                        ),
                        const SizedBox(height: SpasiFunda.s),
                        TombolFunda.sekunder(
                          teks: 'Sesuaikan Sisa Utang',
                          lebarPenuh: true,
                          ikon: const Icon(
                            LucideIcons.slidersHorizontal,
                            size: 18,
                          ),
                          padaTekan: () => _bukaDialogSesuaikan(utang),
                        ),
                      ] else
                        Row(
                          children: [
                            Expanded(
                              child: TombolFunda.pilGelap(
                                teks: 'Catat Bayar',
                                lebarPenuh: false,
                                ikon: const Icon(
                                  LucideIcons.circleDollarSign,
                                  size: 18,
                                ),
                                padaTekan: sudahLunas
                                    ? null
                                    : () => _bukaDialogBayar(utang, sisaUtang),
                              ),
                            ),
                            const SizedBox(width: SpasiFunda.s),
                            Expanded(
                              child: TombolFunda.sekunder(
                                teks: 'Sesuaikan',
                                ikon: const Icon(
                                  LucideIcons.slidersHorizontal,
                                  size: 18,
                                ),
                                padaTekan: () => _bukaDialogSesuaikan(utang),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: SpasiFunda.xl),

                      // 4. Informasi Detail Pinjaman
                      const TeksFunda.judulBagian('Informasi Pinjaman'),
                      const SizedBox(height: SpasiFunda.s),
                      Container(
                        padding: const EdgeInsets.all(SpasiFunda.l),
                        decoration: BoxDecoration(
                          color: WarnaFunda.permukaan,
                          borderRadius: BorderRadius.circular(SudutFunda.petak),
                          border: Border.all(
                            color: WarnaFunda.garis,
                            width: 1.0,
                          ),
                        ),
                        child: Column(
                          children: [
                            _barisInfo(
                              'Jenis Utang',
                              JenisUtang.dariKode(utang.jenis).label,
                            ),
                            const Divider(
                              color: WarnaFunda.garis,
                              height: SpasiFunda.l,
                            ),
                            if (utang.pemberi != null &&
                                utang.pemberi!.isNotEmpty) ...[
                              _barisInfo('Pemberi Pinjaman', utang.pemberi!),
                              const Divider(
                                color: WarnaFunda.garis,
                                height: SpasiFunda.l,
                              ),
                            ],
                            _barisInfo(
                              'Sisa Awal Saat Dicatat',
                              formatRupiah(utang.sisaAwalRupiah),
                            ),
                            const Divider(
                              color: WarnaFunda.garis,
                              height: SpasiFunda.l,
                            ),
                            _barisInfo(
                              'Total Terbayar Sejak Dicatat',
                              formatRupiah(totalTerbayar),
                            ),
                            if (utang.tanggalJatuhTempoBulanan != null) ...[
                              const Divider(
                                color: WarnaFunda.garis,
                                height: SpasiFunda.l,
                              ),
                              _barisInfo(
                                'Jatuh Tempo Bulanan',
                                'Tiap tanggal ${utang.tanggalJatuhTempoBulanan}',
                              ),
                            ],
                            if (utang.bungaBasisPoinPerTahun > 0) ...[
                              const Divider(
                                color: WarnaFunda.garis,
                                height: SpasiFunda.l,
                              ),
                              _barisInfo(
                                'Bunga per Tahun',
                                formatBasisPoinKePersen(
                                  utang.bungaBasisPoinPerTahun,
                                ),
                              ),
                            ],
                            if (utang.tanggalMulai != null) ...[
                              const Divider(
                                color: WarnaFunda.garis,
                                height: SpasiFunda.l,
                              ),
                              _barisInfo(
                                'Mulai Dicatat',
                                DateFormat(
                                  'd MMMM yyyy',
                                  'id_ID',
                                ).format(utang.tanggalMulai!),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: SpasiFunda.xl),

                      // 5. Riwayat Pembayaran & Penyesuaian Menyatu 1 Kartu Putih
                      const TeksFunda.judulBagian(
                        'Riwayat Pembayaran & Penyesuaian',
                      ),
                      const SizedBox(height: SpasiFunda.s),
                      Builder(
                        builder: (context) {
                          final daftarBayar = riwayatBayarAsync.value ?? [];
                          final daftarAdj = riwayatPenyesuaianAsync.value ?? [];

                          if (daftarBayar.isEmpty && daftarAdj.isEmpty) {
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
                                  'Belum ada riwayat pembayaran atau penyesuaian.',
                                ),
                              ),
                            );
                          }

                          final barisSemua = <Widget>[
                            ...daftarBayar.map(
                              (b) => _barisRiwayatBayar(b, isTeksBesar),
                            ),
                            ...daftarAdj.map(
                              (adj) =>
                                  _barisRiwayatPenyesuaian(adj, isTeksBesar),
                            ),
                          ];

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
                                for (var i = 0; i < barisSemua.length; i++) ...[
                                  barisSemua[i],
                                  if (i < barisSemua.length - 1)
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

  Widget _barisInfo(String label, String nilai) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      spacing: SpasiFunda.m,
      runSpacing: SpasiFunda.xs,
      children: [TeksFunda.catatan(label), TeksFunda.label(nilai)],
    );
  }

  Widget _barisRiwayatBayar(ItemRiwayatPembayaranUtang b, bool isTeksBesar) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SpasiFunda.l,
        vertical: SpasiFunda.m,
      ),
      child: Row(
        children: [
          const Icon(
            LucideIcons.arrowDownRight,
            color: WarnaFunda.pemasukan,
            size: 20,
          ),
          const SizedBox(width: SpasiFunda.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TeksFunda.label('Pembayaran Cicilan'),
                TeksFunda.catatan(
                  '${DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(b.waktuTransaksi)} • Dari ${b.namaDompet}',
                ),
                if (b.catatan != null && b.catatan!.isNotEmpty)
                  TeksFunda.catatan(b.catatan!),
                if (isTeksBesar) ...[
                  const SizedBox(height: 2),
                  TeksFunda.label(
                    formatRupiah(b.jumlahRupiah),
                    warna: WarnaFunda.pemasukan,
                    angkaTabular: true,
                  ),
                ],
              ],
            ),
          ),
          if (!isTeksBesar) ...[
            const SizedBox(width: SpasiFunda.s),
            TeksFunda.label(
              formatRupiah(b.jumlahRupiah),
              warna: WarnaFunda.pemasukan,
              angkaTabular: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _barisRiwayatPenyesuaian(
    EntitasPenyesuaianUtang adj,
    bool isTeksBesar,
  ) {
    final isTambah = adj.arah == 'tambah';
    final warna = isTambah ? WarnaFunda.pengeluaran : WarnaFunda.utama;
    final nominalTeks =
        '${isTambah ? "+" : "-"}${formatRupiah(adj.jumlahRupiah)}';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SpasiFunda.l,
        vertical: SpasiFunda.m,
      ),
      child: Row(
        children: [
          Icon(
            isTambah ? LucideIcons.plus : LucideIcons.minus,
            color: warna,
            size: 20,
          ),
          const SizedBox(width: SpasiFunda.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TeksFunda.label(
                  isTambah
                      ? 'Penambahan Sisa (Bunga/Denda)'
                      : 'Pengurangan Sisa (Koreksi)',
                ),
                TeksFunda.catatan(
                  DateFormat('d MMM yyyy', 'id_ID').format(adj.tanggal),
                ),
                if (adj.catatan != null && adj.catatan!.isNotEmpty)
                  TeksFunda.catatan(adj.catatan!),
                if (isTeksBesar) ...[
                  const SizedBox(height: 2),
                  TeksFunda.label(
                    nominalTeks,
                    warna: warna,
                    angkaTabular: true,
                  ),
                ],
              ],
            ),
          ),
          if (!isTeksBesar) ...[
            const SizedBox(width: SpasiFunda.s),
            TeksFunda.label(nominalTeks, warna: warna, angkaTabular: true),
          ],
        ],
      ),
    );
  }
}

/// Modal Lembar Bawah untuk mencatat pembayaran utang.
class _LembarCatatPembayaranUtang extends ConsumerStatefulWidget {
  const _LembarCatatPembayaranUtang({
    required this.utang,
    required this.sisaUtangSaatIni,
  });

  final EntitasUtang utang;
  final int sisaUtangSaatIni;

  @override
  ConsumerState<_LembarCatatPembayaranUtang> createState() =>
      _LembarCatatPembayaranUtangState();
}

class _LembarCatatPembayaranUtangState
    extends ConsumerState<_LembarCatatPembayaranUtang> {
  final _pengontrolJumlah = TextEditingController();
  final _pengontrolCatatan = TextEditingController();
  String? _dompetTerpilihId;
  String? _kategoriTerpilihId;
  final _tanggalPembayaran = DateTime.now();
  bool _sedangMemuat = false;

  @override
  void initState() {
    super.initState();
    final defaultNominal =
        (widget.utang.cicilanBulananRupiah > 0 &&
            widget.utang.cicilanBulananRupiah <= widget.sisaUtangSaatIni)
        ? widget.utang.cicilanBulananRupiah
        : widget.sisaUtangSaatIni;

    _pengontrolJumlah.text = formatRupiah(defaultNominal);
  }

  @override
  void dispose() {
    _pengontrolJumlah.dispose();
    _pengontrolCatatan.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    final jumlah = ambilAngkaRupiah(_pengontrolJumlah.text);
    final validasi = validasiPembayaranUtang(
      jumlahRupiah: jumlah,
      sisaUtangSaatIni: widget.sisaUtangSaatIni,
    );

    if (!validasi.sukses) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validasi.pesanGalat ?? 'Nominal belum valid.')),
      );
      return;
    }

    if (_dompetTerpilihId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih dompet sumber pembayaran.')),
      );
      return;
    }

    if (_kategoriTerpilihId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kategori pembayaran belum dipilih.')),
      );
      return;
    }

    setState(() => _sedangMemuat = true);

    try {
      final repo = ref.read(penyediaUtangRepositori);
      await repo.catatPembayaranUtang(
        utangId: widget.utang.id,
        dompetId: _dompetTerpilihId!,
        jumlahRupiah: jumlah,
        waktu: _tanggalPembayaran,
        kategoriId: _kategoriTerpilihId!,
        catatan: _pengontrolCatatan.text.trim().isEmpty
            ? null
            : _pengontrolCatatan.text.trim(),
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _sedangMemuat = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final daftarDompet = ref.watch(penyediaDaftarDompetAktif).value ?? [];
    final daftarKategori = ref.watch(penyediaDaftarKategori).value ?? [];

    if (_dompetTerpilihId == null && daftarDompet.isNotEmpty) {
      _dompetTerpilihId = daftarDompet.first.id;
    }

    if (_kategoriTerpilihId == null && daftarKategori.isNotEmpty) {
      String namaKategoriBawaan = 'Bayar Utang';
      if (widget.utang.jenis == 'cicilan') {
        namaKategoriBawaan = 'Cicilan';
      } else if (widget.utang.jenis == 'paylater') {
        namaKategoriBawaan = 'Tagihan Paylater';
      }

      final kat = daftarKategori.firstWhere(
        (k) => k.nama == namaKategoriBawaan,
        orElse: () => daftarKategori.firstWhere(
          (k) => k.sifat == 'utang',
          orElse: () => daftarKategori.first,
        ),
      );
      _kategoriTerpilihId = kat.id;
    }

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
                Expanded(
                  child: TeksFunda.judulBagian('Bayar ${widget.utang.nama}'),
                ),
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
            const SizedBox(height: SpasiFunda.m),

            const TeksFunda.label('Pilih Dompet Sumber'),
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
              items: daftarDompet.map((d) {
                return DropdownMenuItem(value: d.id, child: Text(d.nama));
              }).toList(),
              onChanged: (val) => setState(() => _dompetTerpilihId = val),
            ),
            const SizedBox(height: SpasiFunda.m),

            const TeksFunda.label('Jumlah Pembayaran'),
            const SizedBox(height: SpasiFunda.xs),
            TextFormField(
              controller: _pengontrolJumlah,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                filled: true,
                fillColor: WarnaFunda.latar,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SudutFunda.kartu),
                  borderSide: const BorderSide(color: WarnaFunda.garis),
                ),
              ),
              onChanged: (teks) {
                final angka = ambilAngkaRupiah(teks);
                final format = formatRupiah(angka);
                _pengontrolJumlah.value = TextEditingValue(
                  text: format,
                  selection: TextSelection.collapsed(offset: format.length),
                );
              },
            ),
            const SizedBox(height: SpasiFunda.m),

            const TeksFunda.label('Catatan (Opsional)'),
            const SizedBox(height: SpasiFunda.xs),
            TextFormField(
              controller: _pengontrolCatatan,
              decoration: InputDecoration(
                hintText: 'Misal: Pembayaran cicilan bulan Mei',
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
              teks: 'Konfirmasi Pembayaran',
              lebarPenuh: true,
              memuat: _sedangMemuat,
              padaTekan: _sedangMemuat ? null : _simpan,
            ),
          ],
        ),
      ),
    );
  }
}

/// Modal Lembar Bawah untuk menyesuaikan sisa utang.
class _LembarSesuaikanSisaUtang extends ConsumerStatefulWidget {
  const _LembarSesuaikanSisaUtang({required this.utang});

  final EntitasUtang utang;

  @override
  ConsumerState<_LembarSesuaikanSisaUtang> createState() =>
      _LembarSesuaikanSisaUtangState();
}

class _LembarSesuaikanSisaUtangState
    extends ConsumerState<_LembarSesuaikanSisaUtang> {
  final _pengontrolJumlah = TextEditingController();
  final _pengontrolCatatan = TextEditingController();
  ArahPenyesuaianUtang _arahTerpilih = ArahPenyesuaianUtang.tambah;
  bool _sedangMemuat = false;

  @override
  void dispose() {
    _pengontrolJumlah.dispose();
    _pengontrolCatatan.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    final jumlah = ambilAngkaRupiah(_pengontrolJumlah.text);
    if (jumlah <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nominal penyesuaian harus lebih besar dari Rp 0.'),
        ),
      );
      return;
    }

    setState(() => _sedangMemuat = true);
    final repo = ref.read(penyediaUtangRepositori);

    await repo.sesuaikanSisaUtang(
      utangId: widget.utang.id,
      arah: _arahTerpilih,
      jumlahRupiah: jumlah,
      catatan: _pengontrolCatatan.text.trim().isEmpty
          ? null
          : _pengontrolCatatan.text.trim(),
      tanggal: DateTime.now(),
    );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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
                const Expanded(
                  child: TeksFunda.judulBagian('Sesuaikan Sisa Utang'),
                ),
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
            const SizedBox(height: SpasiFunda.m),

            const TeksFunda.label('Arah Penyesuaian'),
            const SizedBox(height: SpasiFunda.xs),
            DropdownButtonFormField<ArahPenyesuaianUtang>(
              initialValue: _arahTerpilih,
              isExpanded: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: WarnaFunda.latar,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SudutFunda.kartu),
                  borderSide: const BorderSide(color: WarnaFunda.garis),
                ),
              ),
              items: ArahPenyesuaianUtang.values.map((a) {
                return DropdownMenuItem(value: a, child: Text(a.label));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _arahTerpilih = val);
              },
            ),
            const SizedBox(height: SpasiFunda.m),

            const TeksFunda.label('Jumlah Penyesuaian'),
            const SizedBox(height: SpasiFunda.xs),
            TextFormField(
              controller: _pengontrolJumlah,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Rp 0',
                filled: true,
                fillColor: WarnaFunda.latar,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SudutFunda.kartu),
                  borderSide: const BorderSide(color: WarnaFunda.garis),
                ),
              ),
              onChanged: (teks) {
                final angka = ambilAngkaRupiah(teks);
                final format = formatRupiah(angka);
                _pengontrolJumlah.value = TextEditingValue(
                  text: format,
                  selection: TextSelection.collapsed(offset: format.length),
                );
              },
            ),
            const SizedBox(height: SpasiFunda.m),

            const TeksFunda.label('Alasan Penyesuaian (Opsional)'),
            const SizedBox(height: SpasiFunda.xs),
            TextFormField(
              controller: _pengontrolCatatan,
              decoration: InputDecoration(
                hintText: 'Misal: Bunga berjalan, denda, atau diskon pelunasan',
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
              teks: 'Simpan Penyesuaian',
              lebarPenuh: true,
              memuat: _sedangMemuat,
              padaTekan: _sedangMemuat ? null : _simpan,
            ),
          ],
        ),
      ),
    );
  }
}
