import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../data/basis_data.dart';
import '../../../data/model/jenis_alokasi.dart';
import '../../../data/penyedia_basis_data.dart';
import '../../../komponen/komponen_funda.dart';
import '../../../komponen/pembantu_ikon.dart';
import '../../../komponen/pembantu_tint.dart';
import '../../../tema/token.dart';
import '../../../util/format_rupiah.dart';
import '../../dompet/kontroler/penyedia_dompet.dart';
import '../kontroler/penyedia_kantong.dart';

/// Layar manajemen seluruh kantong per dompet bergaya editorial bersih:
/// header tombol kembali >= 48dp, pesan edukasi tenang, hero kanvas saldo bebas,
/// dan daftar kantong menyatu dalam 1 kartu putih border 1px.
class LayarDaftarKantong extends ConsumerStatefulWidget {
  const LayarDaftarKantong({super.key});

  @override
  ConsumerState<LayarDaftarKantong> createState() => _LayarDaftarKantongState();
}

class _LayarDaftarKantongState extends ConsumerState<LayarDaftarKantong> {
  String? _dompetTerpilihId;

  void _bukaDialogTambahKantongBebas(BuildContext context, String dompetId) {
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
      builder: (ctx) => _LembarTambahKantongBebas(dompetId: dompetId),
    );
  }

  void _bukaModalAlokasiKantong(
    BuildContext context, {
    required EntitasKantong kantong,
    required bool isIsi,
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
      builder: (ctx) => _LembarAlokasiKantong(kantong: kantong, isIsi: isIsi),
    );
  }

  @override
  Widget build(BuildContext context) {
    final daftarDompet = ref.watch(penyediaDaftarDompetAktif).value ?? [];
    final isTeksBesar = MediaQuery.textScalerOf(context).scale(1) > 1.3;

    if (daftarDompet.isEmpty) {
      return Scaffold(
        backgroundColor: WarnaFunda.latar,
        body: const SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  SpasiFunda.marginLayar,
                  SpasiFunda.marginLayar,
                  SpasiFunda.marginLayar,
                  0,
                ),
                child: HeaderSubLayarEditorial(judul: 'Kantong Dompet'),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(SpasiFunda.l),
                    child: TeksFunda.isiKecil(
                      'Buat dompet terlebih dahulu sebelum menggunakan kantong.',
                      rataTeks: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    _dompetTerpilihId ??= daftarDompet.first.id;

    final dompetTerpilih = daftarDompet.firstWhere(
      (d) => d.id == _dompetTerpilihId,
      orElse: () => daftarDompet.first,
    );

    final saldoBebas = ref.watch(penyediaSaldoBebasDompet(dompetTerpilih.id));
    final daftarKantongAsync = ref.watch(
      penyediaKantongDompet(dompetTerpilih.id),
    );
    final repoKantong = ref.watch(penyediaKantongRepositori);
    final warnaKanvas = ambilWarnaTint(dompetTerpilih.warna);
    final warnaAksen = ambilWarnaAksenTint(dompetTerpilih.warna);

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
                judul: 'Kantong Dompet',
                aksiKanan: [
                  TombolPilHeaderEditorial(
                    key: const Key('tombol_tambah_kantong_header'),
                    teks: 'Tambah',
                    ikon: LucideIcons.plus,
                    padaTekan: () => _bukaDialogTambahKantongBebas(
                      context,
                      dompetTerpilih.id,
                    ),
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
                  // Teks Edukatif Bantuan Tenang (Kartu Putih Beraksen Hijau)
                  Container(
                    padding: const EdgeInsets.all(SpasiFunda.m),
                    decoration: BoxDecoration(
                      color: WarnaFunda.permukaan,
                      borderRadius: BorderRadius.circular(SudutFunda.kartu),
                      border: Border.all(
                        color: WarnaFunda.batasHijau,
                        width: 1.0,
                      ),
                    ),
                    child: const Row(
                      children: [
                        IkonUiFunda(
                          pathAset: AsetIkonUiFunda.info,
                          warna: WarnaFunda.utama,
                          ukuran: 20,
                        ),
                        SizedBox(width: SpasiFunda.m),
                        Expanded(
                          child: TeksFunda.isiKecil(
                            'Ini hanya penandaan. Uangmu tidak berpindah antar rekening.',
                            warna: WarnaFunda.teks,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: SpasiFunda.m),

                  // Pemilih Tab Dompet (Chips Horizontal)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: daftarDompet.map((d) {
                        final terpilih = d.id == dompetTerpilih.id;
                        return Padding(
                          padding: const EdgeInsets.only(right: SpasiFunda.s),
                          child: ChoiceChip(
                            avatar: IkonDompetFunda(
                              kodeJenis: d.jenis,
                              kunciIkonFallback: d.ikon,
                              ukuran: 18,
                              warnaFallback: terpilih
                                  ? WarnaFunda.utamaGelap
                                  : WarnaFunda.teksRedup,
                            ),
                            label: Text(d.nama),
                            selected: terpilih,
                            selectedColor: WarnaFunda.kanvasMint,
                            backgroundColor: WarnaFunda.permukaan,
                            onSelected: (_) =>
                                setState(() => _dompetTerpilihId = d.id),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: SpasiFunda.m),

                  // Hero Kanvas Saldo Bebas Dompet Ini
                  Container(
                    key: const Key('hero_kanvas_kantong'),
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
                            IkonDompetFunda(
                              kodeJenis: dompetTerpilih.jenis,
                              kunciIkonFallback: dompetTerpilih.ikon,
                              ukuran: 22,
                              warnaFallback: warnaAksen,
                            ),
                            const SizedBox(width: SpasiFunda.s),
                            Expanded(
                              child: TeksFunda.label(dompetTerpilih.nama),
                            ),
                          ],
                        ),
                        const SizedBox(height: SpasiFunda.m),
                        const TeksFunda.catatan(
                          'Saldo Bebas (Uang Belum Terkunci Kantong)',
                          warna: WarnaFunda.teksRedup,
                        ),
                        const SizedBox(height: SpasiFunda.xs),
                        TeksFunda.angkaBesar(
                          formatRupiah(saldoBebas),
                          angkaTabular: true,
                          warna: saldoBebas < 0
                              ? WarnaFunda.pengeluaran
                              : WarnaFunda.teks,
                        ),
                        if (saldoBebas < 0) ...[
                          const SizedBox(height: SpasiFunda.xs),
                          const TeksFunda.catatan(
                            'Perhatian: Alokasi kantong melebihi saldo dompet yang ada!',
                            warna: WarnaFunda.pengeluaran,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: SpasiFunda.l),

                  // Daftar Kantong di Dompet Tersebut
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: SpasiFunda.s,
                    children: [
                      const TeksFunda.judulBagian('Daftar Kantong'),
                      TextButton.icon(
                        onPressed: () => _bukaDialogTambahKantongBebas(
                          context,
                          dompetTerpilih.id,
                        ),
                        icon: const IkonUiFunda(
                          pathAset: AsetIkonUiFunda.plus,
                          ukuran: 16,
                        ),
                        label: const Text('Kantong Bebas'),
                      ),
                    ],
                  ),
                  const SizedBox(height: SpasiFunda.s),

                  daftarKantongAsync.when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(SpasiFunda.xl),
                        child: IndikatorMemuat(),
                      ),
                    ),
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
                          child: Column(
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: SpasiFunda.m,
                                ),
                                decoration: BoxDecoration(
                                  color: WarnaFunda.kanvasUngu,
                                  borderRadius: BorderRadius.circular(
                                    SudutFunda.kartu,
                                  ),
                                ),
                                child: const Center(
                                  child: IlustrasiSvgFunda(
                                    pathAset: AsetIlustrasiFunda.kantongKosong,
                                    tinggi: 92,
                                  ),
                                ),
                              ),
                              const SizedBox(height: SpasiFunda.m),
                              const TeksFunda.judulBagian(
                                'Belum Ada Kantong',
                                rataTeks: TextAlign.center,
                              ),
                              const SizedBox(height: SpasiFunda.xs),
                              const TeksFunda.catatan(
                                'Pisahkan pos uang di dalam dompet ini tanpa harus membuka rekening baru.',
                                rataTeks: TextAlign.center,
                                warna: WarnaFunda.teksRedup,
                              ),
                              const SizedBox(height: SpasiFunda.l),
                              TombolFunda.pilGelap(
                                lebarPenuh: true,
                                teks: 'Buat Kantong Sekarang',
                                padaTekan: () => _bukaDialogTambahKantongBebas(
                                  context,
                                  dompetTerpilih.id,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // Daftar Kantong Menyatu dalam 1 Kartu Putih Border 1px
                      return Container(
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
                            for (var i = 0; i < daftarKantong.length; i++) ...[
                              () {
                                final k = daftarKantong[i];
                                final saldoKantongAsync = ref.watch(
                                  penyediaSaldoKantong(k.id),
                                );
                                final saldoK = saldoKantongAsync.value ?? 0;
                                final aksenKantong = ambilWarnaAksenTint(
                                  k.warna,
                                );

                                return Padding(
                                  padding: const EdgeInsets.all(SpasiFunda.l),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          IkonKategoriFunda(
                                            kunciIkon: k.ikon,
                                            ukuran: 22,
                                            warnaFallback: aksenKantong,
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
                                                      ? 'Tertaut ke Tujuan'
                                                      : 'Kantong Bebas',
                                                ),
                                                if (isTeksBesar) ...[
                                                  const SizedBox(height: 2),
                                                  TeksFunda.label(
                                                    formatRupiah(saldoK),
                                                    angkaTabular: true,
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                          if (!isTeksBesar) ...[
                                            const SizedBox(width: SpasiFunda.s),
                                            TeksFunda.label(
                                              formatRupiah(saldoK),
                                              angkaTabular: true,
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: SpasiFunda.m),
                                      Wrap(
                                        alignment: WrapAlignment.end,
                                        spacing: SpasiFunda.s,
                                        runSpacing: SpasiFunda.xs,
                                        children: [
                                          if (saldoK == 0)
                                            TextButton(
                                              onPressed: () async {
                                                await repoKantong
                                                    .arsipkanKantong(k.id);
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Kantong berhasil diarsipkan.',
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                              child: const Text('Arsipkan'),
                                            ),
                                          OutlinedButton.icon(
                                            onPressed: saldoK > 0
                                                ? () =>
                                                      _bukaModalAlokasiKantong(
                                                        context,
                                                        kantong: k,
                                                        isIsi: false,
                                                      )
                                                : null,
                                            icon: const IkonUiFunda(
                                              pathAset: AsetIkonUiFunda.minus,
                                              ukuran: 14,
                                            ),
                                            label: const Text('Ambil'),
                                          ),
                                          FilledButton.tonalIcon(
                                            onPressed: () =>
                                                _bukaModalAlokasiKantong(
                                                  context,
                                                  kantong: k,
                                                  isIsi: true,
                                                ),
                                            icon: const IkonUiFunda(
                                              pathAset: AsetIkonUiFunda.plus,
                                              ukuran: 14,
                                            ),
                                            label: const Text('Isi'),
                                          ),
                                        ],
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LembarTambahKantongBebas extends ConsumerStatefulWidget {
  const _LembarTambahKantongBebas({required this.dompetId});

  final String dompetId;

  @override
  ConsumerState<_LembarTambahKantongBebas> createState() =>
      _LembarTambahKantongBebasState();
}

class _LembarTambahKantongBebasState
    extends ConsumerState<_LembarTambahKantongBebas> {
  final _pengontrolNama = TextEditingController();
  String _ikon = 'layers';
  final String _warna = 'biru';
  bool _sedangMemuat = false;

  final List<String> _pilihanIkon = [
    'layers',
    'shoppingBag',
    'coffee',
    'car',
    'heart',
    'shield',
  ];

  @override
  void dispose() {
    _pengontrolNama.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    final nama = _pengontrolNama.text.trim();
    if (nama.isEmpty) return;

    setState(() => _sedangMemuat = true);

    final repo = ref.read(penyediaKantongRepositori);
    await repo.buatKantongBebas(
      nama: nama,
      dompetId: widget.dompetId,
      ikon: _ikon,
      warna: _warna,
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
                  child: TeksFunda.judulBagian('Buat Kantong Bebas'),
                ),
                IconButton(
                  icon: const IkonUiFunda(
                    pathAset: AsetIkonUiFunda.x,
                    ukuran: 24,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: SpasiFunda.m),
            const TeksFunda.label('Nama Kantong'),
            const SizedBox(height: SpasiFunda.xs),
            TextField(
              controller: _pengontrolNama,
              decoration: InputDecoration(
                hintText: 'Contoh: Jajan Mingguan, Servis Kendaraan',
                filled: true,
                fillColor: WarnaFunda.latar,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SudutFunda.kartu),
                  borderSide: const BorderSide(color: WarnaFunda.garis),
                ),
              ),
            ),
            const SizedBox(height: SpasiFunda.m),
            const TeksFunda.label('Pilih Ikon'),
            const SizedBox(height: SpasiFunda.xs),
            Wrap(
              spacing: SpasiFunda.s,
              runSpacing: SpasiFunda.xs,
              children: _pilihanIkon.map((i) {
                return ChoiceChip(
                  avatar: IkonKategoriFunda(kunciIkon: i, ukuran: 18),
                  label: Text(i),
                  selected: _ikon == i,
                  onSelected: (_) => setState(() => _ikon = i),
                );
              }).toList(),
            ),
            const SizedBox(height: SpasiFunda.l),
            TombolFunda.pilGelap(
              teks: 'Simpan Kantong',
              lebarPenuh: true,
              memuat: _sedangMemuat,
              padaTekan: _simpan,
            ),
          ],
        ),
      ),
    );
  }
}

class _LembarAlokasiKantong extends ConsumerStatefulWidget {
  const _LembarAlokasiKantong({required this.kantong, required this.isIsi});

  final EntitasKantong kantong;
  final bool isIsi;

  @override
  ConsumerState<_LembarAlokasiKantong> createState() =>
      _LembarAlokasiKantongState();
}

class _LembarAlokasiKantongState extends ConsumerState<_LembarAlokasiKantong> {
  final _pengontrolNominal = TextEditingController();
  final _pengontrolCatatan = TextEditingController();
  int _jumlahRupiah = 0;
  bool _sedangMemuat = false;
  String? _pesanGalat;

  @override
  void dispose() {
    _pengontrolNominal.dispose();
    _pengontrolCatatan.dispose();
    super.dispose();
  }

  void _padaUbahNominal(String teks) {
    final digit = teks.replaceAll(RegExp(r'[^0-9]'), '');
    final nilai = int.tryParse(digit) ?? 0;
    final teksFormat = nilai > 0 ? formatRupiah(nilai) : '';
    _pengontrolNominal.value = TextEditingValue(
      text: teksFormat,
      selection: TextSelection.collapsed(offset: teksFormat.length),
    );
    setState(() => _jumlahRupiah = nilai);
  }

  Future<void> _kirim() async {
    if (_jumlahRupiah <= 0) return;

    setState(() {
      _sedangMemuat = true;
      _pesanGalat = null;
    });

    final repo = ref.read(penyediaKantongRepositori);

    try {
      await repo.alokasikanDanaKantong(
        kantongId: widget.kantong.id,
        jenis: widget.isIsi ? JenisAlokasi.isi.kode : JenisAlokasi.ambil.kode,
        jumlahRupiah: _jumlahRupiah,
        catatan: _pengontrolCatatan.text.trim().isEmpty
            ? null
            : _pengontrolCatatan.text.trim(),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() {
        _pesanGalat = e.toString().replaceFirst('Exception: ', '');
        _sedangMemuat = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final judul = widget.isIsi
        ? 'Isi Kantong: ${widget.kantong.nama}'
        : 'Ambil dari: ${widget.kantong.nama}';

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
                  icon: const IkonUiFunda(
                    pathAset: AsetIkonUiFunda.x,
                    ukuran: 24,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: SpasiFunda.s),
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
            const TeksFunda.label('Nominal (Rupiah)'),
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
                hintText: 'Keterangan alokasi',
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
              teks: widget.isIsi ? 'Isi Kantong' : 'Ambil Dana',
              lebarPenuh: true,
              memuat: _sedangMemuat,
              padaTekan: _jumlahRupiah > 0 ? _kirim : null,
            ),
          ],
        ),
      ),
    );
  }
}
