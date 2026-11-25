import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../data/basis_data.dart';
import '../../../data/model/jenis_bunga.dart';
import '../../../data/model/jenis_utang.dart';
import '../../../data/penyedia_basis_data.dart';
import '../../../komponen/komponen_funda.dart';
import '../../../perhitungan/perhitungan_utang_dashboard.dart';
import '../../../tema/token.dart';
import '../../../util/format_rupiah.dart';

/// Layar formulir untuk mencatat atau mengubah utang / cicilan bergaya editorial bersih:
/// header kanvas kuning tenang, isian kartu putih 1px, dan tombol simpan sticky pilGelap.
class LayarFormUtang extends ConsumerStatefulWidget {
  const LayarFormUtang({super.key, this.utang});

  final EntitasUtang? utang;

  @override
  ConsumerState<LayarFormUtang> createState() => _LayarFormUtangState();
}

class _LayarFormUtangState extends ConsumerState<LayarFormUtang> {
  final _kunciForm = GlobalKey<FormState>();

  late TextEditingController _pengontrolNama;
  late TextEditingController _pengontrolPemberi;
  late TextEditingController _pengontrolSisaAwal;
  late TextEditingController _pengontrolPokokAwal;
  late TextEditingController _pengontrolBunga;
  late TextEditingController _pengontrolTenor;
  late TextEditingController _pengontrolCicilan;
  late TextEditingController _pengontrolJatuhTempo;

  JenisUtang _jenisTerpilih = JenisUtang.cicilan;
  JenisBunga _jenisBungaTerpilih = JenisBunga.tanpaBunga;
  DateTime? _tanggalMulai;
  bool _sedangMemuat = false;

  bool get _sedangUbah => widget.utang != null;

  @override
  void initState() {
    super.initState();
    final u = widget.utang;

    _pengontrolNama = TextEditingController(text: u?.nama ?? '');
    _pengontrolPemberi = TextEditingController(text: u?.pemberi ?? '');
    _pengontrolSisaAwal = TextEditingController(
      text: u != null ? formatRupiah(u.sisaAwalRupiah) : '',
    );
    _pengontrolPokokAwal = TextEditingController(
      text: (u?.pokokAwalRupiah != null && u!.pokokAwalRupiah! > 0)
          ? formatRupiah(u.pokokAwalRupiah!)
          : '',
    );
    _pengontrolBunga = TextEditingController(
      text: (u != null && u.bungaBasisPoinPerTahun > 0)
          ? formatBasisPoinKePersen(
              u.bungaBasisPoinPerTahun,
            ).replaceAll('%', '')
          : '',
    );
    _pengontrolTenor = TextEditingController(
      text: u?.tenorBulan != null ? u!.tenorBulan.toString() : '',
    );
    _pengontrolCicilan = TextEditingController(
      text: (u != null && u.cicilanBulananRupiah > 0)
          ? formatRupiah(u.cicilanBulananRupiah)
          : '',
    );
    _pengontrolJatuhTempo = TextEditingController(
      text: u?.tanggalJatuhTempoBulanan != null
          ? u!.tanggalJatuhTempoBulanan.toString()
          : '',
    );

    if (u != null) {
      _jenisTerpilih = JenisUtang.dariKode(u.jenis);
      _jenisBungaTerpilih = JenisBunga.dariKode(u.jenisBunga);
      _tanggalMulai = u.tanggalMulai;
    }
  }

  @override
  void dispose() {
    _pengontrolNama.dispose();
    _pengontrolPemberi.dispose();
    _pengontrolSisaAwal.dispose();
    _pengontrolPokokAwal.dispose();
    _pengontrolBunga.dispose();
    _pengontrolTenor.dispose();
    _pengontrolCicilan.dispose();
    _pengontrolJatuhTempo.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggalMulai() async {
    final tanggal = await showDatePicker(
      context: context,
      initialDate: _tanggalMulai ?? DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime(2040),
    );
    if (tanggal != null) {
      setState(() => _tanggalMulai = tanggal);
    }
  }

  Future<void> _simpan() async {
    if (!_kunciForm.currentState!.validate()) return;

    final nama = _pengontrolNama.text.trim();
    int sisaAwal = 0;
    try {
      sisaAwal = ambilAngkaRupiah(_pengontrolSisaAwal.text);
    } catch (_) {}

    int? pokokAwal;
    if (_pengontrolPokokAwal.text.trim().isNotEmpty) {
      try {
        pokokAwal = ambilAngkaRupiah(_pengontrolPokokAwal.text);
      } catch (_) {}
    }

    int cicilanBulanan = 0;
    if (_pengontrolCicilan.text.trim().isNotEmpty) {
      try {
        cicilanBulanan = ambilAngkaRupiah(_pengontrolCicilan.text);
      } catch (_) {}
    }

    final bungaBasisPoin = konversiTeksKeBasisPoin(_pengontrolBunga.text);
    final tenor = int.tryParse(_pengontrolTenor.text.trim());
    final jatuhTempo = int.tryParse(_pengontrolJatuhTempo.text.trim());

    final validasi = validasiUtang(
      nama: nama,
      sisaAwalRupiah: sisaAwal,
      cicilanBulananRupiah: cicilanBulanan,
      bungaBasisPoinPerTahun: bungaBasisPoin,
    );

    if (!validasi.sukses) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validasi.pesanGalat ?? 'Periksa masukan.')),
      );
      return;
    }

    setState(() => _sedangMemuat = true);
    final repo = ref.read(penyediaUtangRepositori);

    if (_sedangUbah) {
      await repo.perbaruiUtang(
        widget.utang!
            .toCompanion(true)
            .copyWith(
              nama: drift.Value(nama),
              jenis: drift.Value(_jenisTerpilih.kode),
              pemberi: drift.Value(
                _pengontrolPemberi.text.trim().isEmpty
                    ? null
                    : _pengontrolPemberi.text.trim(),
              ),
              sisaAwalRupiah: drift.Value(sisaAwal),
              pokokAwalRupiah: drift.Value(pokokAwal),
              jenisBunga: drift.Value(_jenisBungaTerpilih.kode),
              bungaBasisPoinPerTahun: drift.Value(bungaBasisPoin),
              tenorBulan: drift.Value(tenor),
              cicilanBulananRupiah: drift.Value(cicilanBulanan),
              tanggalJatuhTempoBulanan: drift.Value(jatuhTempo),
              tanggalMulai: drift.Value(_tanggalMulai),
            ),
      );
    } else {
      await repo.buatUtang(
        nama: nama,
        jenis: _jenisTerpilih.kode,
        pemberi: _pengontrolPemberi.text.trim().isEmpty
            ? null
            : _pengontrolPemberi.text.trim(),
        sisaAwalRupiah: sisaAwal,
        pokokAwalRupiah: pokokAwal,
        jenisBunga: _jenisBungaTerpilih.kode,
        bungaBasisPoinPerTahun: bungaBasisPoin,
        tenorBulan: tenor,
        cicilanBulananRupiah: cicilanBulanan,
        tanggalJatuhTempoBulanan: jatuhTempo,
        tanggalMulai: _tanggalMulai,
      );
    }

    if (mounted) {
      setState(() => _sedangMemuat = false);
      final router = GoRouter.maybeOf(context);
      if (router != null) {
        router.pop();
      } else {
        Navigator.maybePop(context);
      }
    }
  }

  InputDecoration _dekorasiInput({String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: WarnaFunda.latar,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SudutFunda.kartu),
        borderSide: const BorderSide(color: WarnaFunda.garis),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SudutFunda.kartu),
        borderSide: const BorderSide(color: WarnaFunda.garis),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTeksBesar = MediaQuery.textScalerOf(context).scale(1) > 1.3;

    return Scaffold(
      backgroundColor: WarnaFunda.latar,
      body: SafeArea(
        child: Form(
          key: _kunciForm,
          child: Column(
            children: [
              // Header Kanvas Kuning Tenang
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: WarnaFunda.kanvasKuning,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(SudutFunda.petak),
                  ),
                ),
                padding: const EdgeInsets.all(SpasiFunda.marginLayar),
                child: HeaderSubLayarEditorial(
                  judul: _sedangUbah
                      ? 'Ubah Catatan Utang'
                      : 'Catat Utang / Cicilan',
                  subjudul: 'Kelola sisa kewajibanmu dengan jernih & terukur.',
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(SpasiFunda.marginLayar),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(SpasiFunda.l),
                      decoration: BoxDecoration(
                        color: WarnaFunda.permukaan,
                        borderRadius: BorderRadius.circular(SudutFunda.petak),
                        border: Border.all(color: WarnaFunda.garis, width: 1.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Nama Utang
                          const TeksFunda.label('Nama Utang / Cicilan *'),
                          const SizedBox(height: SpasiFunda.xs),
                          TextFormField(
                            key: const Key('bidang_nama_utang'),
                            controller: _pengontrolNama,
                            decoration: _dekorasiInput(
                              hintText:
                                  'Misal: Cicilan Laptop, Paylater Belanja',
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Nama utang belum diisi.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: SpasiFunda.m),

                          // 2. Jenis Utang
                          const TeksFunda.label('Jenis Utang'),
                          const SizedBox(height: SpasiFunda.xs),
                          DropdownButtonFormField<JenisUtang>(
                            initialValue: _jenisTerpilih,
                            isExpanded: true,
                            decoration: _dekorasiInput(),
                            items: JenisUtang.values.map((j) {
                              return DropdownMenuItem(
                                value: j,
                                child: Text(j.label),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _jenisTerpilih = val);
                              }
                            },
                          ),
                          const SizedBox(height: SpasiFunda.m),

                          // 3. Pemberi Pinjaman / Lembaga
                          const TeksFunda.label(
                            'Pemberi Pinjaman / Lembaga (Opsional)',
                          ),
                          const SizedBox(height: SpasiFunda.xs),
                          TextFormField(
                            key: const Key('bidang_pemberi_pinjaman'),
                            controller: _pengontrolPemberi,
                            decoration: _dekorasiInput(
                              hintText:
                                  'Misal: Bank Mandiri, Teman, Tokopedia Paylater',
                            ),
                          ),
                          const SizedBox(height: SpasiFunda.m),

                          // 4. Sisa Utang Saat Ini (Wajib)
                          const TeksFunda.label('Sisa Utang Saat Ini *'),
                          const SizedBox(height: SpasiFunda.xs),
                          TextFormField(
                            key: const Key('bidang_sisa_utang'),
                            controller: _pengontrolSisaAwal,
                            keyboardType: TextInputType.number,
                            decoration: _dekorasiInput(hintText: 'Rp 0'),
                            onChanged: (teks) {
                              final angka = ambilAngkaRupiah(teks);
                              final format = formatRupiah(angka);
                              _pengontrolSisaAwal.value = TextEditingValue(
                                text: format,
                                selection: TextSelection.collapsed(
                                  offset: format.length,
                                ),
                              );
                            },
                            validator: (val) {
                              final angka = ambilAngkaRupiah(val ?? '');
                              if (angka <= 0) {
                                return 'Sisa utang harus lebih besar dari Rp 0.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: SpasiFunda.m),

                          // 5. Pokok Awal Pinjaman (Opsional)
                          const TeksFunda.label(
                            'Pokok Awal Pinjaman (Opsional)',
                          ),
                          const SizedBox(height: SpasiFunda.xs),
                          TextFormField(
                            key: const Key('bidang_pokok_awal'),
                            controller: _pengontrolPokokAwal,
                            keyboardType: TextInputType.number,
                            decoration: _dekorasiInput(hintText: 'Rp 0'),
                            onChanged: (teks) {
                              final angka = ambilAngkaRupiah(teks);
                              final format = formatRupiah(angka);
                              _pengontrolPokokAwal.value = TextEditingValue(
                                text: format,
                                selection: TextSelection.collapsed(
                                  offset: format.length,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: SpasiFunda.m),

                          // 6. Cicilan Bulanan
                          const TeksFunda.label('Cicilan per Bulan (Opsional)'),
                          const SizedBox(height: SpasiFunda.xs),
                          TextFormField(
                            key: const Key('bidang_cicilan_bulanan'),
                            controller: _pengontrolCicilan,
                            keyboardType: TextInputType.number,
                            decoration: _dekorasiInput(hintText: 'Rp 0'),
                            onChanged: (teks) {
                              final angka = ambilAngkaRupiah(teks);
                              final format = formatRupiah(angka);
                              _pengontrolCicilan.value = TextEditingValue(
                                text: format,
                                selection: TextSelection.collapsed(
                                  offset: format.length,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: SpasiFunda.m),

                          // 7. Jenis Bunga & Bunga per Tahun (responsif skala teks)
                          _susunDuaKolom(
                            isTeksBesar: isTeksBesar,
                            flexKiri: 3,
                            flexKanan: 2,
                            kiri: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const TeksFunda.label('Jenis Bunga'),
                                const SizedBox(height: SpasiFunda.xs),
                                DropdownButtonFormField<JenisBunga>(
                                  initialValue: _jenisBungaTerpilih,
                                  isExpanded: true,
                                  decoration: _dekorasiInput(),
                                  items: JenisBunga.values.map((b) {
                                    return DropdownMenuItem(
                                      value: b,
                                      child: Text(
                                        b.label,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => _jenisBungaTerpilih = val);
                                    }
                                  },
                                ),
                              ],
                            ),
                            kanan: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const TeksFunda.label('Bunga / Thn (%)'),
                                const SizedBox(height: SpasiFunda.xs),
                                TextFormField(
                                  key: const Key('bidang_bunga_per_tahun'),
                                  controller: _pengontrolBunga,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  decoration: _dekorasiInput(
                                    hintText: 'Misal: 8.5',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: SpasiFunda.m),

                          // 8. Tenor & Tanggal Jatuh Tempo (responsif skala teks)
                          _susunDuaKolom(
                            isTeksBesar: isTeksBesar,
                            flexKiri: 1,
                            flexKanan: 1,
                            kiri: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const TeksFunda.label('Tenor (Bulan)'),
                                const SizedBox(height: SpasiFunda.xs),
                                TextFormField(
                                  key: const Key('bidang_tenor_bulan'),
                                  controller: _pengontrolTenor,
                                  keyboardType: TextInputType.number,
                                  decoration: _dekorasiInput(
                                    hintText: 'Misal: 12',
                                  ),
                                ),
                              ],
                            ),
                            kanan: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const TeksFunda.label('Jatuh Tempo (Tgl 1-31)'),
                                const SizedBox(height: SpasiFunda.xs),
                                TextFormField(
                                  key: const Key('bidang_jatuh_tempo'),
                                  controller: _pengontrolJatuhTempo,
                                  keyboardType: TextInputType.number,
                                  decoration: _dekorasiInput(
                                    hintText: 'Tgl 1-31',
                                  ),
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) {
                                      return null;
                                    }
                                    final n = int.tryParse(val.trim());
                                    if (n == null || n < 1 || n > 31) {
                                      return 'Tanggal harus 1-31';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: SpasiFunda.m),

                          // 9. Tanggal Mulai Pinjaman
                          const TeksFunda.label('Tanggal Mulai (Opsional)'),
                          const SizedBox(height: SpasiFunda.xs),
                          InkWell(
                            onTap: _pilihTanggalMulai,
                            borderRadius: BorderRadius.circular(
                              SudutFunda.kartu,
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: SpasiFunda.m,
                                vertical: SpasiFunda.m,
                              ),
                              decoration: BoxDecoration(
                                color: WarnaFunda.latar,
                                borderRadius: BorderRadius.circular(
                                  SudutFunda.kartu,
                                ),
                                border: Border.all(color: WarnaFunda.garis),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TeksFunda.isi(
                                      _tanggalMulai != null
                                          ? DateFormat(
                                              'd MMMM yyyy',
                                              'id_ID',
                                            ).format(_tanggalMulai!)
                                          : 'Pilih Tanggal Mulai',
                                      warna: _tanggalMulai != null
                                          ? WarnaFunda.teks
                                          : WarnaFunda.teksRedup,
                                    ),
                                  ),
                                  const SizedBox(width: SpasiFunda.s),
                                  const Icon(
                                    LucideIcons.calendar,
                                    size: 18,
                                    color: WarnaFunda.teksRedup,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Tombol Simpan Sticky Bawah
              Container(
                padding: const EdgeInsets.fromLTRB(
                  SpasiFunda.marginLayar,
                  SpasiFunda.s,
                  SpasiFunda.marginLayar,
                  SpasiFunda.m,
                ),
                decoration: const BoxDecoration(
                  color: WarnaFunda.permukaan,
                  border: Border(top: BorderSide(color: WarnaFunda.garis)),
                ),
                child: TombolFunda.pilGelap(
                  key: const Key('tombol_simpan_utang'),
                  teks: _sedangUbah ? 'Simpan Perubahan' : 'Catat Utang',
                  lebarPenuh: true,
                  memuat: _sedangMemuat,
                  padaTekan: _sedangMemuat ? null : _simpan,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _susunDuaKolom({
    required bool isTeksBesar,
    required int flexKiri,
    required int flexKanan,
    required Widget kiri,
    required Widget kanan,
  }) {
    if (isTeksBesar) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          kiri,
          const SizedBox(height: SpasiFunda.m),
          kanan,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: flexKiri, child: kiri),
        const SizedBox(width: SpasiFunda.s),
        Expanded(flex: flexKanan, child: kanan),
      ],
    );
  }
}
