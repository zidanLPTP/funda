import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../data/basis_data.dart';
import '../../../data/model/jenis_bunga.dart';
import '../../../data/model/jenis_utang.dart';
import '../../../data/penyedia_basis_data.dart';
import '../../../komponen/komponen_funda.dart';
import '../../../perhitungan/perhitungan_utang_dashboard.dart';
import '../../../tema/token.dart';
import '../../../util/format_rupiah.dart';

/// Layar formulir untuk mencatat atau mengubah utang / cicilan.
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
      // Perbarui
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
      // Tambah baru
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
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WarnaFunda.latar,
      appBar: AppBar(
        title: TeksFunda.judulBagian(
          _sedangUbah ? 'Ubah Catatan Utang' : 'Catat Utang / Cicilan',
        ),
        backgroundColor: WarnaFunda.latar,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _kunciForm,
          child: ListView(
            padding: const EdgeInsets.all(SpasiFunda.m),
            children: [
              // 1. Nama Utang
              const TeksFunda.label('Nama Utang / Cicilan *'),
              const SizedBox(height: SpasiFunda.xs),
              TextFormField(
                controller: _pengontrolNama,
                decoration: InputDecoration(
                  hintText: 'Misal: Cicilan Laptop, Paylater Belanja',
                  filled: true,
                  fillColor: WarnaFunda.permukaan,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SudutFunda.kecil),
                    borderSide: const BorderSide(color: WarnaFunda.garis),
                  ),
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
                decoration: InputDecoration(
                  filled: true,
                  fillColor: WarnaFunda.permukaan,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SudutFunda.kecil),
                    borderSide: const BorderSide(color: WarnaFunda.garis),
                  ),
                ),
                items: JenisUtang.values.map((j) {
                  return DropdownMenuItem(value: j, child: Text(j.label));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _jenisTerpilih = val);
                },
              ),
              const SizedBox(height: SpasiFunda.m),

              // 3. Pemberi Pinjaman / Lembaga
              const TeksFunda.label('Pemberi Pinjaman / Lembaga (Opsional)'),
              const SizedBox(height: SpasiFunda.xs),
              TextFormField(
                controller: _pengontrolPemberi,
                decoration: InputDecoration(
                  hintText: 'Misal: Bank Mandiri, Teman, Tokopedia Paylater',
                  filled: true,
                  fillColor: WarnaFunda.permukaan,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SudutFunda.kecil),
                    borderSide: const BorderSide(color: WarnaFunda.garis),
                  ),
                ),
              ),
              const SizedBox(height: SpasiFunda.m),

              // 4. Sisa Utang Saat Ini (Wajib)
              const TeksFunda.label('Sisa Utang Saat Ini *'),
              const SizedBox(height: SpasiFunda.xs),
              TextFormField(
                controller: _pengontrolSisaAwal,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Rp 0',
                  filled: true,
                  fillColor: WarnaFunda.permukaan,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SudutFunda.kecil),
                    borderSide: const BorderSide(color: WarnaFunda.garis),
                  ),
                ),
                onChanged: (teks) {
                  final angka = ambilAngkaRupiah(teks);
                  final format = formatRupiah(angka);
                  _pengontrolSisaAwal.value = TextEditingValue(
                    text: format,
                    selection: TextSelection.collapsed(offset: format.length),
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
              const TeksFunda.label('Pokok Awal Pinjaman (Opsional)'),
              const SizedBox(height: SpasiFunda.xs),
              TextFormField(
                controller: _pengontrolPokokAwal,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Rp 0',
                  filled: true,
                  fillColor: WarnaFunda.permukaan,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SudutFunda.kecil),
                    borderSide: const BorderSide(color: WarnaFunda.garis),
                  ),
                ),
                onChanged: (teks) {
                  final angka = ambilAngkaRupiah(teks);
                  final format = formatRupiah(angka);
                  _pengontrolPokokAwal.value = TextEditingValue(
                    text: format,
                    selection: TextSelection.collapsed(offset: format.length),
                  );
                },
              ),
              const SizedBox(height: SpasiFunda.m),

              // 6. Cicilan Bulanan
              const TeksFunda.label('Cicilan per Bulan (Opsional)'),
              const SizedBox(height: SpasiFunda.xs),
              TextFormField(
                controller: _pengontrolCicilan,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Rp 0',
                  filled: true,
                  fillColor: WarnaFunda.permukaan,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SudutFunda.kecil),
                    borderSide: const BorderSide(color: WarnaFunda.garis),
                  ),
                ),
                onChanged: (teks) {
                  final angka = ambilAngkaRupiah(teks);
                  final format = formatRupiah(angka);
                  _pengontrolCicilan.value = TextEditingValue(
                    text: format,
                    selection: TextSelection.collapsed(offset: format.length),
                  );
                },
              ),
              const SizedBox(height: SpasiFunda.m),

              // 7. Jenis Bunga & Bunga per Tahun
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const TeksFunda.label('Jenis Bunga'),
                        const SizedBox(height: SpasiFunda.xs),
                        DropdownButtonFormField<JenisBunga>(
                          initialValue: _jenisBungaTerpilih,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: WarnaFunda.permukaan,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                SudutFunda.kecil,
                              ),
                              borderSide: const BorderSide(
                                color: WarnaFunda.garis,
                              ),
                            ),
                          ),
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
                  ),
                  const SizedBox(width: SpasiFunda.s),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const TeksFunda.label('Bunga / Thn (%)'),
                        const SizedBox(height: SpasiFunda.xs),
                        TextFormField(
                          controller: _pengontrolBunga,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Misal: 8.5',
                            filled: true,
                            fillColor: WarnaFunda.permukaan,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                SudutFunda.kecil,
                              ),
                              borderSide: const BorderSide(
                                color: WarnaFunda.garis,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SpasiFunda.m),

              // 8. Tenor & Tanggal Jatuh Tempo
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const TeksFunda.label('Tenor (Bulan)'),
                        const SizedBox(height: SpasiFunda.xs),
                        TextFormField(
                          controller: _pengontrolTenor,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Misal: 12',
                            filled: true,
                            fillColor: WarnaFunda.permukaan,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                SudutFunda.kecil,
                              ),
                              borderSide: const BorderSide(
                                color: WarnaFunda.garis,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: SpasiFunda.s),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const TeksFunda.label('Jatuh Tempo (Tgl 1-31)'),
                        const SizedBox(height: SpasiFunda.xs),
                        TextFormField(
                          controller: _pengontrolJatuhTempo,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Tgl 1-31',
                            filled: true,
                            fillColor: WarnaFunda.permukaan,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                SudutFunda.kecil,
                              ),
                              borderSide: const BorderSide(
                                color: WarnaFunda.garis,
                              ),
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return null;
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
                ],
              ),
              const SizedBox(height: SpasiFunda.m),

              // 9. Tanggal Mulai Pinjaman
              const TeksFunda.label('Tanggal Mulai (Opsional)'),
              const SizedBox(height: SpasiFunda.xs),
              InkWell(
                onTap: _pilihTanggalMulai,
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
                      TeksFunda.isi(
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
                      const Icon(
                        Icons.calendar_month,
                        color: WarnaFunda.teksRedup,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: SpasiFunda.xl),

              // Tombol Simpan
              TombolFunda.primer(
                teks: _sedangUbah ? 'Simpan Perubahan' : 'Catat Utang',
                memuat: _sedangMemuat,
                padaTekan: _sedangMemuat ? null : _simpan,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
