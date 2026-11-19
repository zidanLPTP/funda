import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../komponen/komponen_funda.dart';
import '../../../perhitungan/perhitungan_belajar.dart';
import '../../../tema/token.dart';
import '../kontroler/penyedia_belajar.dart';

/// Layar pengerjaan kuis akhir modul (satu soal per layar + hasil kelulusan).
class LayarKuisModul extends ConsumerStatefulWidget {
  final String modulId;
  final int? benih;

  const LayarKuisModul({
    super.key,
    required this.modulId,
    this.benih,
  });

  @override
  ConsumerState<LayarKuisModul> createState() => _LayarKuisModulState();
}

class _LayarKuisModulState extends ConsumerState<LayarKuisModul> {
  ModulKonten? _modul;
  List<SoalKuis> _soalKuis = [];
  bool _memuat = true;
  String? _galat;

  int _indeksSoal = 0;
  final Map<int, int> _jawabanDipilih = {}; // indeksSoal -> indeksPilihan
  bool _selesai = false;
  int _skorAkhir = 0;
  bool _lulus = false;

  @override
  void initState() {
    super.initState();
    _muatDanPersiapkanKuis();
  }

  Future<void> _muatDanPersiapkanKuis() async {
    try {
      final daftarModul = await ref.read(penyediaDaftarSemuaModul.future);
      final m = daftarModul.firstWhere(
        (mod) => mod.id == widget.modulId,
        orElse: () => throw Exception('Modul tidak ditemukan'),
      );

      final bank = m.kuis.bankSoal;
      final jumlah = m.kuis.jumlahSoal > 0 ? m.kuis.jumlahSoal : bank.length;
      final soalAcak = pilihDanAcakSoalKuis(
        bankSoal: bank,
        jumlahSoal: jumlah,
        benih: widget.benih,
      );

      if (mounted) {
        setState(() {
          _modul = m;
          _soalKuis = soalAcak;
          _indeksSoal = 0;
          _jawabanDipilih.clear();
          _selesai = false;
          _memuat = false;
        });
      }
    } catch (e, s) {
      debugPrint('GALAT KUIS: $e\n$s');
      if (mounted) {
        setState(() {
          _galat = e.toString();
          _memuat = false;
        });
      }
    }
  }

  Future<void> _selesaikanKuis() async {
    var benar = 0;
    for (var i = 0; i < _soalKuis.length; i++) {
      if (_jawabanDipilih[i] == _soalKuis[i].benar) {
        benar++;
      }
    }

    final total = _soalKuis.length;
    final skor = hitungSkorKuis(benar: benar, total: total);
    final lulus = tentukanLulusKuis(benar: benar, total: total);

    // Simpan ke database
    await ref.read(penyediaKuisRepositori).simpanHasilKuis(
          modulId: widget.modulId,
          benar: benar,
          total: total,
          skorPersen: skor,
          lulus: lulus,
        );

    ref.invalidate(penyediaFotoData);

    if (mounted) {
      setState(() {
        _skorAkhir = skor;
        _lulus = lulus;
        _selesai = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_memuat) {
      return const Scaffold(
        backgroundColor: WarnaFunda.latar,
        body: Center(child: IndikatorMemuat(warna: WarnaFunda.utama)),
      );
    }

    if (_galat != null || _modul == null || _soalKuis.isEmpty) {
      return Scaffold(
        backgroundColor: WarnaFunda.latar,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft, color: WarnaFunda.teks),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(SpasiFunda.m),
            child: KeadaanKosong(
              ikon: LucideIcons.circleAlert,
              judul: 'Kuis Belum Siap',
              pesan: _galat ?? 'Bank soal kuis modul ini belum tersedia.',
              teksTombol: 'Kembali',
              padaAksi: () => Navigator.pop(context),
            ),
          ),
        ),
      );
    }

    if (_selesai) {
      return _bangunLayarHasilKuis();
    }

    final soal = _soalKuis[_indeksSoal];
    final totalSoal = _soalKuis.length;
    final pilihanTerpilih = _jawabanDipilih[_indeksSoal];
    final sudahDijawab = pilihanTerpilih != null;

    return Scaffold(
      backgroundColor: WarnaFunda.latar,
      body: SafeArea(
        child: Column(
          children: [
            // Header Progress Kuis
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SpasiFunda.m,
                vertical: SpasiFunda.s,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(LucideIcons.arrowLeft, color: WarnaFunda.teks),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: SpasiFunda.xs),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(SudutFunda.pil),
                      child: IndikatorMemuat.garis(
                        nilai: (_indeksSoal + 1) / totalSoal,
                        warnaLatar: WarnaFunda.garis,
                        warna: WarnaFunda.utama,
                        tinggi: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: SpasiFunda.m),
                  TeksFunda.catatan('Soal ${_indeksSoal + 1}/$totalSoal', warna: WarnaFunda.teksRedup),
                ],
              ),
            ),

            // Konten Soal
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(SpasiFunda.marginLayar),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: SpasiFunda.s, vertical: SpasiFunda.xs),
                      decoration: BoxDecoration(
                        color: WarnaFunda.utamaTipis,
                        borderRadius: BorderRadius.circular(SudutFunda.pil),
                      ),
                      child: TeksFunda.catatan('Kuis: ${_modul!.judul}', warna: WarnaFunda.utama),
                    ),
                    const SizedBox(height: SpasiFunda.l),
                    TeksFunda.judulBagian(
                      soal.tanya,
                      key: const Key('teks_soal_kuis'),
                    ),
                    const SizedBox(height: SpasiFunda.l),

                    // Opsi Pilihan
                    ...soal.pilihan.asMap().entries.map((entry) {
                      final pIdx = entry.key;
                      final teks = entry.value;
                      final isSelected = pilihanTerpilih == pIdx;

                      Color latar = WarnaFunda.permukaan;
                      Color border = WarnaFunda.garis;

                      if (sudahDijawab) {
                        if (pIdx == soal.benar) {
                          latar = WarnaFunda.tintHijau;
                          border = WarnaFunda.pemasukan;
                        } else if (isSelected) {
                          latar = WarnaFunda.tintMawar;
                          border = WarnaFunda.pengeluaran;
                        }
                      }

                      return GestureDetector(
                        onTap: sudahDijawab
                            ? null
                            : () {
                                setState(() {
                                  _jawabanDipilih[_indeksSoal] = pIdx;
                                });
                              },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: SpasiFunda.m),
                          padding: const EdgeInsets.all(SpasiFunda.m),
                          decoration: BoxDecoration(
                            color: latar,
                            borderRadius: BorderRadius.circular(SudutFunda.kartu),
                            border: Border.all(color: border, width: isSelected ? 1.5 : 1.0),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected ? LucideIcons.checkCircle2 : LucideIcons.circle,
                                size: 20,
                                color: isSelected ? WarnaFunda.utama : WarnaFunda.teksRedup,
                              ),
                              const SizedBox(width: SpasiFunda.m),
                              Expanded(
                                child: TeksFunda.isi(teks),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    // Penjelasan Langsung
                    if (sudahDijawab) ...[
                      const SizedBox(height: SpasiFunda.s),
                      Container(
                        padding: const EdgeInsets.all(SpasiFunda.m),
                        decoration: BoxDecoration(
                          color: pilihanTerpilih == soal.benar ? WarnaFunda.tintHijau : WarnaFunda.tintAmber,
                          borderRadius: BorderRadius.circular(SudutFunda.kartu),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              pilihanTerpilih == soal.benar ? LucideIcons.check : LucideIcons.info,
                              color: pilihanTerpilih == soal.benar ? WarnaFunda.pemasukan : WarnaFunda.peringatan,
                              size: 20,
                            ),
                            const SizedBox(width: SpasiFunda.s),
                            Expanded(child: TeksFunda.isiKecil(soal.penjelasan)),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Tombol Lanjut ke Soal Berikutnya / Selesai
            Padding(
              padding: const EdgeInsets.all(SpasiFunda.m),
              child: SizedBox(
                width: double.infinity,
                child: TombolFunda(
                  teks: _indeksSoal == totalSoal - 1 ? 'Lihat Hasil Kuis' : 'Soal Berikutnya',
                  lebarPenuh: true,
                  padaTekan: sudahDijawab
                      ? () {
                          if (_indeksSoal < totalSoal - 1) {
                            setState(() {
                              _indeksSoal++;
                            });
                          } else {
                            _selesaikanKuis();
                          }
                        }
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bangunLayarHasilKuis() {
    return Scaffold(
      backgroundColor: WarnaFunda.latar,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(SpasiFunda.marginLayar),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: _lulus ? WarnaFunda.tintHijau : WarnaFunda.tintAmber,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _lulus ? LucideIcons.award : LucideIcons.bookOpen,
                  size: 48,
                  color: _lulus ? WarnaFunda.pemasukan : WarnaFunda.peringatan,
                ),
              ),
              const SizedBox(height: SpasiFunda.l),
              TeksFunda.judulLayar(_lulus ? 'Selamat, Kamu Lulus!' : 'Mari Coba Lagi'),
              const SizedBox(height: SpasiFunda.s),
              TeksFunda.isi(
                _lulus
                    ? 'Kamu berhasil menguasai materi modul ${_modul!.judul} dengan sangat baik.'
                    : 'Jangan khawatir, belajar keuangan butuh pengulangan. Kamu bisa mengulang kuis ini kapan saja.',
                rataTeks: TextAlign.center,
                warna: WarnaFunda.teksRedup,
              ),
              const SizedBox(height: SpasiFunda.xl),

              // Kartu Skor
              Container(
                padding: const EdgeInsets.symmetric(horizontal: SpasiFunda.xl, vertical: SpasiFunda.l),
                decoration: BoxDecoration(
                  color: WarnaFunda.permukaan,
                  borderRadius: BorderRadius.circular(SudutFunda.petak),
                  border: Border.all(color: WarnaFunda.garis),
                ),
                child: Column(
                  children: [
                    const TeksFunda.catatan('Skor Kuis Kamu', warna: WarnaFunda.teksRedup),
                    const SizedBox(height: SpasiFunda.xs),
                    TeksFunda.judulLayar('$_skorAkhir%'),
                    const SizedBox(height: SpasiFunda.xs),
                    TeksFunda.catatan(
                      'Syarat kelulusan: minimal 70%',
                      warna: _lulus ? WarnaFunda.pemasukan : WarnaFunda.peringatan,
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // Tombol Navigasi
              TombolFunda(
                teks: 'Ulangi Kuis',
                lebarPenuh: true,
                padaTekan: _muatDanPersiapkanKuis,
              ),
              const SizedBox(height: SpasiFunda.m),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    side: const BorderSide(color: WarnaFunda.garis),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SudutFunda.pil)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const TeksFunda.label('Kembali ke Peta Belajar'),
                ),
              ),
              const SizedBox(height: SpasiFunda.m),
            ],
          ),
        ),
      ),
    );
  }
}
