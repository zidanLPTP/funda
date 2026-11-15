import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/basis_data.dart';
import '../../../data/model/jenis_dompet.dart';
import '../../../data/penyedia_data.dart';
import '../../../komponen/komponen_funda.dart';
import '../../../komponen/pembantu_ikon.dart';
import '../../../komponen/pembantu_tint.dart';
import '../../../tema/token.dart';
import '../../../util/format_rupiah.dart';

/// Layar untuk menambah atau mengubah data dompet.
class LayarFormDompet extends ConsumerStatefulWidget {
  const LayarFormDompet({super.key, this.dompet});

  final EntitasDompet? dompet;

  @override
  ConsumerState<LayarFormDompet> createState() => _LayarFormDompetState();
}

class _LayarFormDompetState extends ConsumerState<LayarFormDompet> {
  late final TextEditingController _pengontrolNama;
  late final TextEditingController _pengontrolSaldoAwal;
  late JenisDompet _jenisTerpilih;
  late String _ikonTerpilih;
  late String _warnaTerpilih;
  bool _memuat = false;
  bool _adaTransaksi = false;

  bool get _sedangUbah => widget.dompet != null;

  @override
  void initState() {
    super.initState();
    final d = widget.dompet;
    _pengontrolNama = TextEditingController(text: d?.nama ?? '');
    _pengontrolSaldoAwal = TextEditingController(
      text: d != null ? formatRupiah(d.saldoAwalRupiah) : 'Rp 0',
    );
    _jenisTerpilih = d != null
        ? JenisDompet.dariKode(d.jenis)
        : JenisDompet.rekeningBank;
    _ikonTerpilih = d?.ikon ?? 'building2';
    _warnaTerpilih = d?.warna ?? 'tintBiru';

    if (_sedangUbah) {
      _periksaTransaksiTerkait();
    }
  }

  Future<void> _periksaTransaksiTerkait() async {
    final repo = ref.read(penyediaDompetRepositori);
    final ada = await repo.cekApakahDompetMemilikiTransaksi(widget.dompet!.id);
    if (mounted) {
      setState(() => _adaTransaksi = ada);
    }
  }

  @override
  void dispose() {
    _pengontrolNama.dispose();
    _pengontrolSaldoAwal.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    final nama = _pengontrolNama.text.trim();
    if (nama.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dompet tidak boleh kosong.')),
      );
      return;
    }

    int saldoAwal = 0;
    try {
      saldoAwal = ambilAngkaRupiah(_pengontrolSaldoAwal.text);
      if (saldoAwal < 0) {
        throw const FormatException();
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saldo awal harus berupa bilangan bulat positif.'),
        ),
      );
      return;
    }

    if (_sedangUbah &&
        _adaTransaksi &&
        saldoAwal != widget.dompet!.saldoAwalRupiah) {
      final setuju = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const TeksFunda.judulBagian('Ubah Saldo Awal?'),
          content: const TeksFunda.isi(
            'Dompet ini sudah memiliki transaksi tercatat. Mengubah saldo awal akan mengubah saldo berjalan saat ini. Yakin ingin melanjutkan?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal'),
            ),
            TombolFunda.primer(
              teks: 'Ya, Ubah',
              padaTekan: () => Navigator.pop(ctx, true),
            ),
          ],
        ),
      );

      if (setuju != true) return;
    }

    setState(() => _memuat = true);
    final repo = ref.read(penyediaDompetRepositori);

    if (_sedangUbah) {
      await repo.perbaruiDompet(
        TabelDompetCompanion(
          id: drift.Value(widget.dompet!.id),
          nama: drift.Value(nama),
          jenis: drift.Value(_jenisTerpilih.kode),
          ikon: drift.Value(_ikonTerpilih),
          warna: drift.Value(_warnaTerpilih),
          saldoAwalRupiah: drift.Value(saldoAwal),
          urutan: drift.Value(widget.dompet!.urutan),
          diarsipkan: drift.Value(widget.dompet!.diarsipkan),
        ),
      );
    } else {
      final idBaru = 'dompet_${DateTime.now().millisecondsSinceEpoch}';
      await repo.tambahDompet(
        TabelDompetCompanion(
          id: drift.Value(idBaru),
          nama: drift.Value(nama),
          jenis: drift.Value(_jenisTerpilih.kode),
          ikon: drift.Value(_ikonTerpilih),
          warna: drift.Value(_warnaTerpilih),
          saldoAwalRupiah: drift.Value(saldoAwal),
        ),
      );
    }

    if (mounted) {
      setState(() => _memuat = false);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PembungkusLayar(
      appBar: AppBar(
        title: TeksFunda.judulBagian(
          _sedangUbah ? 'Ubah Dompet' : 'Tambah Dompet Baru',
        ),
      ),
      bisaGulir: true,
      anak: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nama Dompet
          const TeksFunda.label('Nama Dompet'),
          const SizedBox(height: SpasiFunda.s),
          TextField(
            controller: _pengontrolNama,
            decoration: InputDecoration(
              hintText: 'Contoh: Rekening BCA, Dompet Tunai, GoPay',
              filled: true,
              fillColor: WarnaFunda.permukaan,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SudutFunda.kartu),
                borderSide: const BorderSide(color: WarnaFunda.garis),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SudutFunda.kartu),
                borderSide: const BorderSide(color: WarnaFunda.garis),
              ),
            ),
          ),
          const SizedBox(height: SpasiFunda.l),

          // Jenis Dompet
          const TeksFunda.label('Jenis Dompet'),
          const SizedBox(height: SpasiFunda.s),
          Wrap(
            spacing: SpasiFunda.s,
            runSpacing: SpasiFunda.s,
            children: JenisDompet.values.map((jenis) {
              final terpilih = _jenisTerpilih == jenis;
              return ChoiceChip(
                label: Text(jenis.label),
                selected: terpilih,
                selectedColor: WarnaFunda.utamaTipis,
                backgroundColor: WarnaFunda.permukaan,
                labelStyle: TipografiFunda.label.copyWith(
                  color: terpilih ? WarnaFunda.utamaGelap : WarnaFunda.teks,
                  fontSize: 13,
                ),
                onSelected: (val) {
                  if (val) setState(() => _jenisTerpilih = jenis);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: SpasiFunda.l),

          // Saldo Awal
          const TeksFunda.label('Saldo Awal Saat Dibuat'),
          const SizedBox(height: SpasiFunda.s),
          TextField(
            controller: _pengontrolSaldoAwal,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              filled: true,
              fillColor: WarnaFunda.permukaan,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SudutFunda.kartu),
                borderSide: const BorderSide(color: WarnaFunda.garis),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SudutFunda.kartu),
                borderSide: const BorderSide(color: WarnaFunda.garis),
              ),
            ),
            onChanged: (teks) {
              try {
                final nominal = ambilAngkaRupiah(teks);
                final format = formatRupiah(nominal);
                if (format != teks) {
                  _pengontrolSaldoAwal.value = TextEditingValue(
                    text: format,
                    selection: TextSelection.collapsed(offset: format.length),
                  );
                }
              } catch (_) {}
            },
          ),
          const SizedBox(height: SpasiFunda.l),

          // Pilihan Warna Tint Bento
          const TeksFunda.label('Warna Kartu Dompet'),
          const SizedBox(height: SpasiFunda.s),
          Wrap(
            spacing: SpasiFunda.m,
            children: daftarPilihanTint.map((item) {
              final kunci = item['kunci'] as String;
              final warna = item['warna'] as Color;
              final terpilih = _warnaTerpilih == kunci;
              return GestureDetector(
                onTap: () => setState(() => _warnaTerpilih = kunci),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: warna,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: terpilih ? WarnaFunda.utama : WarnaFunda.garis,
                      width: terpilih ? 2.5 : 1.0,
                    ),
                  ),
                  child: terpilih
                      ? const Icon(
                          Icons.check,
                          size: 20,
                          color: WarnaFunda.utama,
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: SpasiFunda.l),

          // Pilihan Ikon Dompet
          const TeksFunda.label('Ikon Dompet'),
          const SizedBox(height: SpasiFunda.s),
          Wrap(
            spacing: SpasiFunda.s,
            runSpacing: SpasiFunda.s,
            children: daftarPilihanIkon.map((item) {
              final kunci = item['kunci'] as String;
              final ikon = item['ikon'] as IconData;
              final terpilih = _ikonTerpilih == kunci;
              return InkWell(
                onTap: () => setState(() => _ikonTerpilih = kunci),
                borderRadius: BorderRadius.circular(SudutFunda.kecil),
                child: Container(
                  padding: const EdgeInsets.all(SpasiFunda.m),
                  decoration: BoxDecoration(
                    color: terpilih
                        ? WarnaFunda.utamaTipis
                        : WarnaFunda.permukaan,
                    borderRadius: BorderRadius.circular(SudutFunda.kecil),
                    border: Border.all(
                      color: terpilih ? WarnaFunda.utama : WarnaFunda.garis,
                      width: terpilih ? 2 : 1,
                    ),
                  ),
                  child: Icon(
                    ikon,
                    color: terpilih ? WarnaFunda.utama : WarnaFunda.teksRedup,
                    size: 24,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: SpasiFunda.xxxl),

          // Tombol Simpan
          TombolFunda.primer(
            teks: _sedangUbah ? 'Perbarui Dompet' : 'Simpan Dompet',
            memuat: _memuat,
            lebarPenuh: true,
            padaTekan: _simpan,
          ),
        ],
      ),
    );
  }
}
