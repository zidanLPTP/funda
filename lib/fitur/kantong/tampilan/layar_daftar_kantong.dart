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

/// Layar manajemen seluruh kantong per dompet.
class LayarDaftarKantong extends ConsumerStatefulWidget {
  const LayarDaftarKantong({super.key});

  @override
  ConsumerState<LayarDaftarKantong> createState() => _LayarDaftarKantongState();
}

class _LayarDaftarKantongState extends ConsumerState<LayarDaftarKantong> {
  String? _dompetTerpilihId;

  void _bukaDialogTambahKantongBebas(BuildContext context, String dompetId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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

    if (daftarDompet.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const TeksFunda.judulBagian('Kantong Dompet')),
        body: const Center(
          child: Text(
            'Buat dompet terlebih dahulu sebelum menggunakan kantong.',
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

    return Scaffold(
      backgroundColor: WarnaFunda.latar,
      appBar: AppBar(
        title: const TeksFunda.judulBagian('Kantong Dompet'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus),
            tooltip: 'Buat Kantong Bebas',
            onPressed: () =>
                _bukaDialogTambahKantongBebas(context, dompetTerpilih.id),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(SpasiFunda.m),
          children: [
            // Teks Edukatif Bantuan
            Container(
              padding: const EdgeInsets.all(SpasiFunda.m),
              decoration: BoxDecoration(
                color: WarnaFunda.utamaTipis,
                borderRadius: BorderRadius.circular(SudutFunda.kartu),
                border: Border.all(color: WarnaFunda.utama.withAlpha(50)),
              ),
              child: const Row(
                children: [
                  Icon(LucideIcons.info, color: WarnaFunda.utama),
                  SizedBox(width: SpasiFunda.m),
                  Expanded(
                    child: TeksFunda.isiKecil(
                      'Ini hanya penandaan. Uangmu tidak berpindah antar rekening.',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SpasiFunda.m),

            // Pemilih Tab Dompet (Chips Horizontal)
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: daftarDompet.length,
                separatorBuilder: (_, _) => const SizedBox(width: SpasiFunda.s),
                itemBuilder: (context, index) {
                  final d = daftarDompet[index];
                  final terpilih = d.id == dompetTerpilih.id;
                  return ChoiceChip(
                    avatar: Icon(ambilIkonLucide(d.ikon), size: 16),
                    label: Text(d.nama),
                    selected: terpilih,
                    onSelected: (_) => setState(() => _dompetTerpilihId = d.id),
                  );
                },
              ),
            ),
            const SizedBox(height: SpasiFunda.m),

            // Kartu Bento Saldo Bebas Dompet Ini
            PetakBento.ukuran2x1(
              warnaKustom: ambilWarnaTint(dompetTerpilih.warna),
              anak: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(ambilIkonLucide(dompetTerpilih.ikon), size: 20),
                      const SizedBox(width: SpasiFunda.s),
                      TeksFunda.label(dompetTerpilih.nama),
                    ],
                  ),
                  const SizedBox(height: SpasiFunda.m),
                  const TeksFunda.catatan(
                    'Saldo Bebas (Uang Belum Terkunci Kantong)',
                  ),
                  const SizedBox(height: SpasiFunda.xs),
                  TeksFunda.angkaBesar(
                    formatRupiah(saldoBebas),
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
                  onPressed: () =>
                      _bukaDialogTambahKantongBebas(context, dompetTerpilih.id),
                  icon: const Icon(LucideIcons.plus, size: 16),
                  label: const Text('Kantong Bebas'),
                ),
              ],
            ),
            const SizedBox(height: SpasiFunda.s),

            daftarKantongAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(SpasiFunda.xl),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => Center(child: Text('Terjadi kesalahan: $e')),
              data: (daftarKantong) {
                if (daftarKantong.isEmpty) {
                  return KeadaanKosong(
                    ikon: LucideIcons.layers,
                    judul: 'Belum Ada Kantong',
                    pesan:
                        'Pisahkan pos uang di dalam dompet ini tanpa harus membuka rekening baru.',
                    teksTombol: 'Buat Kantong Sekarang',
                    padaAksi: () => _bukaDialogTambahKantongBebas(
                      context,
                      dompetTerpilih.id,
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: daftarKantong.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: SpasiFunda.s),
                  itemBuilder: (context, index) {
                    final k = daftarKantong[index];
                    final saldoKantongAsync = ref.watch(
                      penyediaSaldoKantong(k.id),
                    );
                    final saldoK = saldoKantongAsync.value ?? 0;

                    return Container(
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
                              Container(
                                padding: const EdgeInsets.all(SpasiFunda.s),
                                decoration: BoxDecoration(
                                  color: ambilWarnaTint(k.warna),
                                  borderRadius: BorderRadius.circular(
                                    SudutFunda.kecil,
                                  ),
                                ),
                                child: Icon(
                                  ambilIkonLucide(k.ikon),
                                  size: 18,
                                  color: WarnaFunda.utama,
                                ),
                              ),
                              const SizedBox(width: SpasiFunda.m),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TeksFunda.label(k.nama),
                                    TeksFunda.catatan(
                                      k.tujuanId != null
                                          ? 'Tertaut ke Tujuan'
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
                          const SizedBox(height: SpasiFunda.m),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (saldoK == 0)
                                TextButton(
                                  onPressed: () async {
                                    await repoKantong.arsipkanKantong(k.id);
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
                              const SizedBox(width: SpasiFunda.s),
                              OutlinedButton.icon(
                                onPressed: saldoK > 0
                                    ? () => _bukaModalAlokasiKantong(
                                        context,
                                        kantong: k,
                                        isIsi: false,
                                      )
                                    : null,
                                icon: const Icon(LucideIcons.minus, size: 14),
                                label: const Text('Ambil'),
                              ),
                              const SizedBox(width: SpasiFunda.s),
                              FilledButton.tonalIcon(
                                onPressed: () => _bukaModalAlokasiKantong(
                                  context,
                                  kantong: k,
                                  isIsi: true,
                                ),
                                icon: const Icon(LucideIcons.plus, size: 14),
                                label: const Text('Isi'),
                              ),
                            ],
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
              const TeksFunda.judulBagian('Buat Kantong Bebas'),
              IconButton(
                icon: const Icon(LucideIcons.x),
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
                borderRadius: BorderRadius.circular(SudutFunda.kecil),
                borderSide: const BorderSide(color: WarnaFunda.garis),
              ),
            ),
          ),
          const SizedBox(height: SpasiFunda.m),
          const TeksFunda.label('Pilih Ikon'),
          const SizedBox(height: SpasiFunda.xs),
          Wrap(
            spacing: SpasiFunda.s,
            children: _pilihanIkon.map((i) {
              return ChoiceChip(
                avatar: Icon(ambilIkonLucide(i), size: 16),
                label: Text(i),
                selected: _ikon == i,
                onSelected: (_) => setState(() => _ikon = i),
              );
            }).toList(),
          ),
          const SizedBox(height: SpasiFunda.l),
          TombolFunda.primer(
            teks: 'Simpan Kantong',
            lebarPenuh: true,
            memuat: _sedangMemuat,
            padaTekan: _simpan,
          ),
          const SizedBox(height: SpasiFunda.m),
        ],
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
              Expanded(child: TeksFunda.judulBagian(judul)),
              IconButton(
                icon: const Icon(LucideIcons.x),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: SpasiFunda.s),
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
          const TeksFunda.label('Nominal (Rupiah)'),
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
          const TeksFunda.label('Catatan (Opsional)'),
          const SizedBox(height: SpasiFunda.xs),
          TextField(
            controller: _pengontrolCatatan,
            decoration: InputDecoration(
              hintText: 'Keterangan alokasi',
              filled: true,
              fillColor: WarnaFunda.latar,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SudutFunda.kecil),
                borderSide: const BorderSide(color: WarnaFunda.garis),
              ),
            ),
          ),
          const SizedBox(height: SpasiFunda.l),
          TombolFunda.primer(
            teks: widget.isIsi ? 'Isi Kantong' : 'Ambil Dana',
            lebarPenuh: true,
            memuat: _sedangMemuat,
            padaTekan: _jumlahRupiah > 0 ? _kirim : null,
          ),
          const SizedBox(height: SpasiFunda.m),
        ],
      ),
    );
  }
}
