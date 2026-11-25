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

/// Layar untuk menambah atau mengubah data dompet bergaya editorial bersih:
/// pratinjau kanvas pastel sesuai pilihan warna + tombol simpan sticky pilGelap.
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
            TombolFunda.pilGelap(
              teks: 'Ya, Ubah',
              lebarPenuh: false,
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
      final router = GoRouter.maybeOf(context);
      if (router != null) {
        router.pop();
      } else {
        Navigator.maybePop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final warnaKanvas = ambilWarnaTint(_warnaTerpilih);
    final warnaAksen = ambilWarnaAksenTint(_warnaTerpilih);

    return Scaffold(
      backgroundColor: WarnaFunda.latar,
      body: SafeArea(
        child: Column(
          children: [
            // Header Kanvas Dinamis mengikuti warna kartu dompet terpilih
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: warnaKanvas,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(SudutFunda.petak),
                ),
              ),
              padding: const EdgeInsets.all(SpasiFunda.marginLayar),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeaderSubLayarEditorial(
                    judul: _sedangUbah ? 'Ubah Dompet' : 'Tambah Dompet Baru',
                  ),
                  const SizedBox(height: SpasiFunda.m),
                  Row(
                    children: [
                      IkonKategoriFunda(
                        kunciIkon: _ikonTerpilih,
                        ukuran: 28,
                        warnaFallback: warnaAksen,
                      ),
                      const SizedBox(width: SpasiFunda.m),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TeksFunda.label(
                              _pengontrolNama.text.trim().isEmpty
                                  ? 'Nama Dompet Baru'
                                  : _pengontrolNama.text.trim(),
                            ),
                            TeksFunda.catatan(
                              _jenisTerpilih.label,
                              warna: WarnaFunda.teksRedup,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Area Formulir Gulir
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(SpasiFunda.marginLayar),
                child: Container(
                  padding: const EdgeInsets.all(SpasiFunda.l),
                  decoration: BoxDecoration(
                    color: WarnaFunda.permukaan,
                    borderRadius: BorderRadius.circular(SudutFunda.petak),
                    border: Border.all(color: WarnaFunda.garis, width: 1.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama Dompet
                      const TeksFunda.label('Nama Dompet'),
                      const SizedBox(height: SpasiFunda.s),
                      TextField(
                        controller: _pengontrolNama,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Contoh: Rekening BCA, Dompet Tunai, GoPay',
                          filled: true,
                          fillColor: WarnaFunda.latar,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              SudutFunda.kartu,
                            ),
                            borderSide: const BorderSide(
                              color: WarnaFunda.garis,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              SudutFunda.kartu,
                            ),
                            borderSide: const BorderSide(
                              color: WarnaFunda.garis,
                            ),
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
                          final svgJenis = pathSvgUntukJenisDompet(jenis.kode);
                          return ChoiceChip(
                            avatar: svgJenis != null
                                ? IkonSvgFunda(pathAset: svgJenis, ukuran: 18)
                                : null,
                            label: Text(jenis.label),
                            selected: terpilih,
                            selectedColor: WarnaFunda.kanvasMint,
                            backgroundColor: WarnaFunda.latar,
                            labelStyle: TipografiFunda.label.copyWith(
                              color: terpilih
                                  ? WarnaFunda.utamaGelap
                                  : WarnaFunda.teks,
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
                          fillColor: WarnaFunda.latar,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              SudutFunda.kartu,
                            ),
                            borderSide: const BorderSide(
                              color: WarnaFunda.garis,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              SudutFunda.kartu,
                            ),
                            borderSide: const BorderSide(
                              color: WarnaFunda.garis,
                            ),
                          ),
                        ),
                        onChanged: (teks) {
                          try {
                            final nominal = ambilAngkaRupiah(teks);
                            final format = formatRupiah(nominal);
                            if (format != teks) {
                              _pengontrolSaldoAwal.value = TextEditingValue(
                                text: format,
                                selection: TextSelection.collapsed(
                                  offset: format.length,
                                ),
                              );
                            }
                          } catch (_) {}
                        },
                      ),
                      const SizedBox(height: SpasiFunda.l),

                      // Pilihan Warna Kanvas Dompet
                      const TeksFunda.label('Warna Kartu Dompet'),
                      const SizedBox(height: SpasiFunda.s),
                      Wrap(
                        spacing: SpasiFunda.m,
                        runSpacing: SpasiFunda.s,
                        children: daftarPilihanTint.map((item) {
                          final kunci = item['kunci'] as String;
                          final warna = item['warna'] as Color;
                          final terpilih = _warnaTerpilih == kunci;
                          return Semantics(
                            button: true,
                            selected: terpilih,
                            label: 'Warna ${item['label']}',
                            child: InkWell(
                              onTap: () =>
                                  setState(() => _warnaTerpilih = kunci),
                              borderRadius: BorderRadius.circular(
                                SudutFunda.pil,
                              ),
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: warna,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: terpilih
                                        ? WarnaFunda.utama
                                        : WarnaFunda.garis,
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
                            borderRadius: BorderRadius.circular(
                              SudutFunda.kartu,
                            ),
                            child: Container(
                              constraints: const BoxConstraints(
                                minWidth: 48,
                                minHeight: 48,
                              ),
                              padding: const EdgeInsets.all(SpasiFunda.m),
                              decoration: BoxDecoration(
                                color: terpilih
                                    ? WarnaFunda.kanvasMint
                                    : WarnaFunda.latar,
                                borderRadius: BorderRadius.circular(
                                  SudutFunda.kartu,
                                ),
                                border: Border.all(
                                  color: terpilih
                                      ? WarnaFunda.utama
                                      : WarnaFunda.garis,
                                  width: terpilih ? 2 : 1,
                                ),
                              ),
                              child: Icon(
                                ikon,
                                color: terpilih
                                    ? WarnaFunda.utama
                                    : WarnaFunda.teksRedup,
                                size: 22,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
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
                key: const Key('tombol_simpan_dompet'),
                teks: _sedangUbah ? 'Perbarui Dompet' : 'Simpan Dompet',
                memuat: _memuat,
                lebarPenuh: true,
                padaTekan: _simpan,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
