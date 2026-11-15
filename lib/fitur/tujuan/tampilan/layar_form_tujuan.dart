import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../data/basis_data.dart';
import '../../../data/model/jenis_tujuan.dart';
import '../../../data/penyedia_basis_data.dart';
import '../../../komponen/komponen_funda.dart';
import '../../../komponen/pembantu_ikon.dart';
import '../../../komponen/pembantu_tint.dart';
import '../../../tema/token.dart';
import '../../../util/format_rupiah.dart';
import '../kontroler/penyedia_tujuan.dart';

/// Form tambah atau ubah tujuan finansial pengguna.
class LayarFormTujuan extends ConsumerStatefulWidget {
  const LayarFormTujuan({super.key, this.tujuan});

  final EntitasTujuan? tujuan;

  @override
  ConsumerState<LayarFormTujuan> createState() => _LayarFormTujuanState();
}

class _LayarFormTujuanState extends ConsumerState<LayarFormTujuan> {
  final _formKey = GlobalKey<FormState>();
  final _pengontrolNama = TextEditingController();
  final _pengontrolTarget = TextEditingController();

  JenisTujuan _jenis = JenisTujuan.tabungan;
  String _ikon = 'piggyBank';
  String _warna = 'biru';
  DateTime? _tenggat;
  int _targetRupiah = 0;
  bool _sedangMemuat = false;
  String? _pesanGalat;

  final List<String> _pilihanIkon = [
    'piggyBank',
    'shield',
    'car',
    'home',
    'graduationCap',
    'plane',
    'gift',
    'laptop',
  ];

  final List<String> _pilihanWarna = [
    'biru',
    'hijau',
    'amber',
    'merah',
    'netral',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.tujuan != null) {
      final t = widget.tujuan!;
      _pengontrolNama.text = t.nama;
      _targetRupiah = t.targetRupiah;
      _pengontrolTarget.text = formatRupiah(_targetRupiah);
      _jenis = JenisTujuan.dariKode(t.jenis);
      _ikon = t.ikon;
      _warna = t.warna;
      _tenggat = t.tenggat;
    }
  }

  @override
  void dispose() {
    _pengontrolNama.dispose();
    _pengontrolTarget.dispose();
    super.dispose();
  }

  void _padaUbahTarget(String teks) {
    final digit = teks.replaceAll(RegExp(r'[^0-9]'), '');
    final nilai = int.tryParse(digit) ?? 0;
    setState(() {
      _targetRupiah = nilai;
    });
  }

  Future<void> _pilihTenggat() async {
    final sekarang = DateTime.now();
    final hasil = await showDatePicker(
      context: context,
      initialDate: _tenggat ?? sekarang.add(const Duration(days: 90)),
      firstDate: sekarang,
      lastDate: sekarang.add(const Duration(days: 365 * 10)),
    );
    if (hasil != null) {
      setState(() => _tenggat = hasil);
    }
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate() || _targetRupiah <= 0) return;

    setState(() {
      _sedangMemuat = true;
      _pesanGalat = null;
    });

    final repo = ref.read(penyediaTujuanRepositori);

    try {
      if (widget.tujuan == null) {
        await repo.buatTujuan(
          nama: _pengontrolNama.text.trim(),
          jenis: _jenis.kode,
          targetRupiah: _targetRupiah,
          ikon: _ikon,
          warna: _warna,
          tenggat: _tenggat,
        );
      } else {
        await repo.ubahTujuan(
          id: widget.tujuan!.id,
          nama: _pengontrolNama.text.trim(),
          targetRupiah: _targetRupiah,
          ikon: _ikon,
          warna: _warna,
          tenggat: _tenggat,
        );
      }

      ref.invalidate(penyediaDaftarTujuanAktif);
      ref.invalidate(penyediaTujuanTerdekat);

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
    final isUbah = widget.tujuan != null;

    return Scaffold(
      backgroundColor: WarnaFunda.latar,
      appBar: AppBar(
        title: TeksFunda.judulBagian(isUbah ? 'Ubah Tujuan' : 'Tambah Tujuan'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(SpasiFunda.m),
            children: [
              if (_pesanGalat != null) ...[
                Container(
                  padding: const EdgeInsets.all(SpasiFunda.m),
                  decoration: BoxDecoration(
                    color: WarnaFunda.pengeluaran.withAlpha(25),
                    borderRadius: BorderRadius.circular(SudutFunda.kartu),
                    border: Border.all(color: WarnaFunda.pengeluaran),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        LucideIcons.alertCircle,
                        color: WarnaFunda.pengeluaran,
                      ),
                      const SizedBox(width: SpasiFunda.s),
                      Expanded(
                        child: TeksFunda.catatan(
                          _pesanGalat!,
                          warna: WarnaFunda.pengeluaran,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: SpasiFunda.m),
              ],

              // Nama Tujuan
              const TeksFunda.label('Nama Tujuan'),
              const SizedBox(height: SpasiFunda.xs),
              TextFormField(
                controller: _pengontrolNama,
                decoration: InputDecoration(
                  hintText: 'Contoh: Dana Darurat 3 Bulan, Liburan Akhir Tahun',
                  filled: true,
                  fillColor: WarnaFunda.permukaan,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SudutFunda.kecil),
                    borderSide: const BorderSide(color: WarnaFunda.garis),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Nama tujuan wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: SpasiFunda.m),

              // Target Nominal Rupiah
              const TeksFunda.label('Target Dana (Rupiah)'),
              const SizedBox(height: SpasiFunda.xs),
              TextFormField(
                controller: _pengontrolTarget,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Rp 0',
                  filled: true,
                  fillColor: WarnaFunda.permukaan,
                  prefixIcon: const Icon(LucideIcons.target),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SudutFunda.kecil),
                    borderSide: const BorderSide(color: WarnaFunda.garis),
                  ),
                ),
                onChanged: _padaUbahTarget,
                validator: (_) {
                  if (_targetRupiah <= 0) {
                    return 'Target dana harus lebih dari 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: SpasiFunda.m),

              // Jenis Tujuan (hanya saat buat baru)
              if (!isUbah) ...[
                const TeksFunda.label('Jenis Tujuan'),
                const SizedBox(height: SpasiFunda.xs),
                DropdownButtonFormField<JenisTujuan>(
                  initialValue: _jenis,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: WarnaFunda.permukaan,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(SudutFunda.kecil),
                      borderSide: const BorderSide(color: WarnaFunda.garis),
                    ),
                  ),
                  items: JenisTujuan.values.map((j) {
                    return DropdownMenuItem(value: j, child: Text(j.label));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _jenis = val);
                  },
                ),
                const SizedBox(height: SpasiFunda.m),
              ],

              // Tenggat Target (Opsional)
              const TeksFunda.label('Tenggat Target (Opsional)'),
              const SizedBox(height: SpasiFunda.xs),
              InkWell(
                onTap: _pilihTenggat,
                borderRadius: BorderRadius.circular(SudutFunda.kecil),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpasiFunda.m,
                    vertical: SpasiFunda.m,
                  ),
                  decoration: BoxDecoration(
                    color: WarnaFunda.permukaan,
                    borderRadius: BorderRadius.circular(SudutFunda.kecil),
                    border: Border.all(color: WarnaFunda.garis),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(LucideIcons.calendar, size: 20),
                          const SizedBox(width: SpasiFunda.s),
                          TeksFunda.isi(
                            _tenggat != null
                                ? DateFormat(
                                    'd MMMM yyyy',
                                    'id_ID',
                                  ).format(_tenggat!)
                                : 'Tanpa tenggat waktu',
                          ),
                        ],
                      ),
                      if (_tenggat != null)
                        IconButton(
                          icon: const Icon(LucideIcons.x, size: 16),
                          onPressed: () => setState(() => _tenggat = null),
                        )
                      else
                        const Icon(LucideIcons.chevronRight, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: SpasiFunda.m),

              // Pemilih Ikon
              const TeksFunda.label('Pilih Ikon'),
              const SizedBox(height: SpasiFunda.xs),
              Wrap(
                spacing: SpasiFunda.s,
                runSpacing: SpasiFunda.s,
                children: _pilihanIkon.map((kunciIkon) {
                  final terpilih = _ikon == kunciIkon;
                  return ChoiceChip(
                    avatar: Icon(ambilIkonLucide(kunciIkon), size: 18),
                    label: Text(kunciIkon),
                    selected: terpilih,
                    onSelected: (_) => setState(() => _ikon = kunciIkon),
                  );
                }).toList(),
              ),
              const SizedBox(height: SpasiFunda.m),

              // Pemilih Warna Tint
              const TeksFunda.label('Pilih Warna Kartu'),
              const SizedBox(height: SpasiFunda.xs),
              Wrap(
                spacing: SpasiFunda.s,
                children: _pilihanWarna.map((kunciWarna) {
                  final terpilih = _warna == kunciWarna;
                  final warnaBg = ambilWarnaTint(kunciWarna);
                  return ChoiceChip(
                    avatar: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: warnaBg,
                        shape: BoxShape.circle,
                        border: Border.all(color: WarnaFunda.garis),
                      ),
                    ),
                    label: Text(kunciWarna),
                    selected: terpilih,
                    onSelected: (_) => setState(() => _warna = kunciWarna),
                  );
                }).toList(),
              ),
              const SizedBox(height: SpasiFunda.xl),

              // Tombol Simpan
              TombolFunda.primer(
                teks: isUbah ? 'Simpan Perubahan' : 'Buat Tujuan',
                memuat: _sedangMemuat,
                padaTekan: _simpan,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
