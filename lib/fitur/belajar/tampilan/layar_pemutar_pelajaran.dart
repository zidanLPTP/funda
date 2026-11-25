import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../komponen/komponen_funda.dart';
import '../../../data/penyedia_basis_data.dart';
import '../../../perhitungan/perhitungan_belajar.dart';
import '../../../perhitungan/perhitungan_umpan_balik_belajar.dart';
import '../../../tema/token.dart';
import '../kontroler/penyedia_belajar.dart';
import '../model/pembaca_konten.dart';
import '../model/registri_misi.dart';
import '../../transaksi/tampilan/layar_form_transaksi.dart';

/// Layar pemutar pelajaran kartu geser berurutan (Micro-learning Funda).
class LayarPemutarPelajaran extends ConsumerStatefulWidget {
  final String modulId;
  final String pelajaranId;
  final PelajaranKonten? pelajaranOverride;

  const LayarPemutarPelajaran({
    super.key,
    required this.modulId,
    required this.pelajaranId,
    this.pelajaranOverride,
  });

  @override
  ConsumerState<LayarPemutarPelajaran> createState() =>
      _LayarPemutarPelajaranState();
}

class _LayarPemutarPelajaranState extends ConsumerState<LayarPemutarPelajaran> {
  PelajaranKonten? _pelajaran;
  bool _memuat = true;
  String? _galat;

  int _indeksLangkah = 0;
  PageController _pageController = PageController();

  // State kuis Cek Paham per soal: indeksSoal -> jawabanDipilih
  final Map<int, int> _jawabanCekPaham = {};

  // State misi
  bool _misiDilewati = false;
  bool _misiTerverifikasi = false;

  // State misi keputusan
  final List<String> _riwayatOpsiDipilih = [];
  String? _opsiKeputusanTerpilih;
  bool _tampilkanUmpanBalikKeputusan = false;

  // State misi daftar periksa
  bool _disclaimerSudahMengerti = false;
  final Set<String> _langkahDicentang = {};

  // State misi refleksi
  late TextEditingController _pengontrolRefleksi;
  String _teksRefleksi = '';

  // State misi sandbox
  String _ringkasanSandbox = '';

  @override
  void initState() {
    super.initState();
    _pengontrolRefleksi = TextEditingController();
    _pengontrolRefleksi.addListener(() {
      if (mounted) {
        setState(() {
          _teksRefleksi = _pengontrolRefleksi.text;
        });
      }
    });
    _muatKontenPelajaran();
  }

  Future<void> _muatKontenPelajaran() async {
    if (widget.pelajaranOverride != null) {
      if (mounted) {
        setState(() {
          _pelajaran = widget.pelajaranOverride;
          _memuat = false;
        });
      }
      return;
    }
    try {
      final kamus = (await ref.read(penyediaKamus.future)).keys.toSet();
      // Cari tingkat modul
      final daftarModul = await ref.read(penyediaDaftarSemuaModul.future);
      final modul = daftarModul.firstWhere(
        (m) => m.id == widget.modulId,
        orElse: () => ModulKonten(
          id: widget.modulId,
          judul: '',
          tingkat: 'pemula',
          urutan: 1,
          deskripsiSingkat: '',
          tersedia: true,
          gerbang: const [],
          daftarPelajaran: const [],
          kuis: const KuisKonten(jumlahSoal: 0, bankSoal: []),
        ),
      );

      final pel = await PembacaKonten.muatPelajaranDariAset(
        rootBundle,
        tingkat: modul.tingkat,
        modulId: widget.modulId,
        pelajaranId: widget.pelajaranId,
        daftarIstilahKamus: kamus,
      );

      ref.invalidate(penyediaTeksUmpanBalikMisi);

      // Ambil hasil misi tersimpan bila ada
      final hasilMisiRepo = ref.read(penyediaHasilMisiRepositori);
      final hasilMisiLama = await hasilMisiRepo.ambilHasilMisi(
        widget.pelajaranId,
      );
      if (hasilMisiLama != null) {
        if (hasilMisiLama.status == 'dilewati') {
          _misiDilewati = true;
        } else if (hasilMisiLama.status == 'selesai') {
          _misiTerverifikasi = true;
          if (hasilMisiLama.muatanJson != null &&
              hasilMisiLama.muatanJson!.isNotEmpty) {
            try {
              final muatan =
                  jsonDecode(hasilMisiLama.muatanJson!) as Map<String, dynamic>;
              if (muatan.containsKey('opsiDipilih')) {
                final list = muatan['opsiDipilih'] as List<dynamic>;
                _riwayatOpsiDipilih.clear();
                _riwayatOpsiDipilih.addAll(list.map((e) => e.toString()));
                if (_riwayatOpsiDipilih.isNotEmpty) {
                  _opsiKeputusanTerpilih = _riwayatOpsiDipilih.last;
                  _tampilkanUmpanBalikKeputusan = true;
                }
              }
              if (muatan.containsKey('dicentang')) {
                final list = muatan['dicentang'] as List<dynamic>;
                _langkahDicentang.clear();
                _langkahDicentang.addAll(list.map((e) => e.toString()));
                _disclaimerSudahMengerti = true;
              }
              if (muatan.containsKey('jawaban')) {
                _teksRefleksi = muatan['jawaban'] as String? ?? '';
                _pengontrolRefleksi.text = _teksRefleksi;
              }
              if (muatan.containsKey('ringkasanSandbox')) {
                _ringkasanSandbox = muatan['ringkasanSandbox'] as String? ?? '';
                _disclaimerSudahMengerti = true;
              }
            } catch (_) {}
          }
        }
      }

      // Ambil progres langkah terakhir yang tersimpan
      final progresRepo = ref.read(penyediaProgresRepositori);
      final progresLama = await progresRepo.ambilProgresPelajaran(
        widget.pelajaranId,
      );

      var langkahAwal = 0;
      if (progresLama != null && progresLama.status != 'selesai') {
        langkahAwal = progresLama.indeksLangkah;
      }

      var controllerBaru = _pageController;
      if (langkahAwal > 0) {
        _pageController.dispose();
        controllerBaru = PageController(initialPage: langkahAwal);
      }

      if (mounted) {
        setState(() {
          _pelajaran = pel;
          _indeksLangkah = langkahAwal;
          _pageController = controllerBaru;
          _memuat = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _galat = e.toString();
          _memuat = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _pengontrolRefleksi.dispose();
    _pageController.dispose();
    super.dispose();
  }

  bool _punyaContohAngka(PelajaranKonten pel) {
    final contoh = pel.contohAngka;
    return contoh != null &&
        (contoh.baris.isNotEmpty || contoh.judul.isNotEmpty);
  }

  int _indeksMulaiCekPaham(PelajaranKonten pel) {
    return 1 + pel.kartu.length + (_punyaContohAngka(pel) ? 1 : 0);
  }

  int _indeksMisi(PelajaranKonten pel) {
    return _indeksMulaiCekPaham(pel) + pel.cekPaham.length;
  }

  // Menghitung total kartu/langkah dalam pelajaran ini:
  // 1 (Pemantik) + N (Kartu Konsep) + (Contoh Angka ? 1 : 0) + M (Cek Paham, 1 soal/halaman) + 1 (Misi) + 1 (Umpan Balik) + (Tindak Lanjut ? 1 : 0)
  int _hitungTotalLangkah() {
    final pel = _pelajaran;
    if (pel == null) return 1;
    var total = _indeksMisi(pel);
    total += 1; // Misi
    total += 1; // Umpan Balik
    if (pel.tindakLanjut != null && pel.tindakLanjut!.isNotEmpty) {
      total += 1; // Tindak Lanjut
    }
    return total;
  }

  Future<void> _lanjutkanKeLangkahBerikutnya() async {
    final total = _hitungTotalLangkah();

    // Bila sedang berada di langkah misi dan misi selesai (bukan dilewati),
    // pastikan hasil tercatat ke tabel_hasil_misi untuk semua tipe misi.
    if (_pelajaran != null) {
      final indeksMisi = _indeksMisi(_pelajaran!);
      if (_indeksLangkah == indeksMisi && !_misiDilewati) {
        final pel = _pelajaran!;
        if (pel.misi.tipe == 'ada_data' ||
            pel.misi.tipe == 'aturan_data' ||
            pel.misi.tipe == 'lihat_hitungan') {
          final fotoData =
              ref.read(penyediaFotoData).value ?? FotoDataPengguna.kosong();
          final eval = RegistriMisi.evaluasi(
            misi: pel.misi,
            fotoData: fotoData,
          );
          if (eval.selesai || _misiTerverifikasi) {
            await ref
                .read(penyediaHasilMisiRepositori)
                .simpanHasilMisi(
                  misiId: widget.pelajaranId,
                  pelajaranId: widget.pelajaranId,
                  tipe: pel.misi.tipe,
                  status: 'selesai',
                  muatanJson: null,
                );
          }
        }
      }
    }

    final langkahBerikutnya = _indeksLangkah + 1;

    if (!mounted) return;
    if (langkahBerikutnya < total) {
      final kurangiGerakan =
          MediaQuery.of(context).disableAnimations ||
          WidgetsBinding.instance.runtimeType.toString().contains('Test') ||
          (!kIsWeb && Platform.environment.containsKey('FLUTTER_TEST'));
      if (kurangiGerakan) {
        _pageController.jumpToPage(langkahBerikutnya);
      } else {
        _pageController.animateToPage(
          langkahBerikutnya,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
      setState(() {
        _indeksLangkah = langkahBerikutnya;
      });

      // Simpan progres langkah
      await ref
          .read(penyediaProgresRepositori)
          .simpanProgresLangkah(
            pelajaranId: widget.pelajaranId,
            modulId: widget.modulId,
            indeksLangkah: langkahBerikutnya,
          );
      ref.invalidate(penyediaFotoData);
    } else {
      // Pelajaran Selesai!
      await ref
          .read(penyediaProgresRepositori)
          .tandaiPelajaranSelesai(
            pelajaranId: widget.pelajaranId,
            modulId: widget.modulId,
          );
      ref.invalidate(penyediaFotoData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: Duration(milliseconds: 1500),
            backgroundColor: WarnaFunda.pemasukan,
            content: TeksFunda.label(
              'Pelajaran selesai! Kamu selangkah lebih dekat menguasai uangmu.',
              warna: WarnaFunda.putih,
            ),
          ),
        );
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          try {
            context.go('/belajar');
          } catch (_) {}
        }
      }
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

    if (_galat != null || _pelajaran == null) {
      return Scaffold(
        backgroundColor: WarnaFunda.latar,
        appBar: AppBar(
          backgroundColor: WarnaFunda.transparan,
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
              judul: 'Gagal Membuka Pelajaran',
              pesan: _galat ?? 'Materi pelajaran tidak ditemukan.',
              teksTombol: 'Kembali',
              padaAksi: () => Navigator.pop(context),
            ),
          ),
        ),
      );
    }

    final pel = _pelajaran!;
    final totalLangkah = _hitungTotalLangkah();
    final fotoData =
        ref.watch(penyediaFotoData).value ?? FotoDataPengguna.kosong();
    final temaVisual = temaVisualUntukModul(pel.modulId);

    return Scaffold(
      backgroundColor: WarnaFunda.permukaan,
      body: SafeArea(
        child: Column(
          children: [
            // Bilah Atas Editorial: Tombol Tutup Bulat (X) + Progress Bar Bersegmen
            Padding(
              padding: const EdgeInsets.fromLTRB(
                SpasiFunda.l,
                SpasiFunda.m,
                SpasiFunda.l,
                SpasiFunda.s,
              ),
              child: Row(
                children: [
                  Semantics(
                    button: true,
                    label: 'Tutup pelajaran',
                    child: InkWell(
                      key: const Key('tombol_tutup_pelajaran'),
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(SudutFunda.pil),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: WarnaFunda.permukaan,
                          shape: BoxShape.circle,
                          border: Border.all(color: WarnaFunda.garis),
                        ),
                        child: const Icon(
                          LucideIcons.x,
                          size: 20,
                          color: WarnaFunda.teks,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: SpasiFunda.m),
                  Expanded(
                    child: Row(
                      key: const Key('progress_bersegmen_pelajaran'),
                      children: List.generate(totalLangkah, (idx) {
                        final aktif = idx <= _indeksLangkah;
                        return Expanded(
                          child: Container(
                            height: 6,
                            margin: EdgeInsets.only(
                              right: idx == totalLangkah - 1 ? 0 : 4,
                            ),
                            decoration: BoxDecoration(
                              color: aktif
                                  ? temaVisual.aksen
                                  : WarnaFunda.segmenNonAktif,
                              borderRadius: BorderRadius.circular(
                                SudutFunda.pil,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),

            // PageView untuk Kartu-Kartu Pelajaran
            Expanded(
              child: PageView(
                controller: _pageController,
                physics:
                    const NeverScrollableScrollPhysics(), // Wajib tombol lanjut
                children: _bangunDaftarKartu(pel, fotoData),
              ),
            ),

            // Tombol Pil Gelap Aksi Bawah Kontras Tinggi
            Padding(
              padding: const EdgeInsets.fromLTRB(
                SpasiFunda.xl,
                SpasiFunda.s,
                SpasiFunda.xl,
                SpasiFunda.l,
              ),
              child: TombolFunda.pilGelap(
                key: const Key('tombol_lanjut'),
                teks: _indeksLangkah == totalLangkah - 1
                    ? 'Selesai Belajar'
                    : 'Lanjut',
                padaTekan: _cekApakahBisaLanjut(pel, fotoData)
                    ? _lanjutkanKeLangkahBerikutnya
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _cekApakahBisaLanjut(PelajaranKonten pel, FotoDataPengguna fotoData) {
    final indeksMulaiCek = _indeksMulaiCekPaham(pel);
    final indeksMisi = _indeksMisi(pel);

    // Pada tiap halaman Cek Paham (1 soal per langkah), wajib memilih jawaban soal aktif
    if (_indeksLangkah >= indeksMulaiCek && _indeksLangkah < indeksMisi) {
      final indeksSoal = _indeksLangkah - indeksMulaiCek;
      return _jawabanCekPaham.containsKey(indeksSoal);
    }

    // Pada langkah Misi, misi harus sudah terverifikasi selesai atau dilewati
    if (_indeksLangkah == indeksMisi) {
      if (_misiDilewati) return true;
      if (pel.misi.tipe == 'keputusan' ||
          pel.misi.tipe == 'daftar_periksa' ||
          pel.misi.tipe == 'refleksi' ||
          pel.misi.tipe == 'sandbox') {
        return _misiTerverifikasi;
      }
      final evalMisi = RegistriMisi.evaluasi(
        misi: pel.misi,
        fotoData: fotoData,
      );
      return evalMisi.selesai || _misiTerverifikasi;
    }

    return true;
  }

  List<Widget> _bangunDaftarKartu(
    PelajaranKonten pel,
    FotoDataPengguna fotoData,
  ) {
    final kartuWidgets = <Widget>[];

    // 1. Pemantik
    kartuWidgets.add(
      _pembungkusKartu(
        judul: pel.judul,
        headerVisual: KanvasIlustrasiPelajaran(modulId: pel.modulId),
        pakaiKartuMembungkus: false,
        isi: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TeksAnimasiKata(
              teks: pel.pemantik,
              dukungIstilah: false,
              rataTeks: TextAlign.start,
              gaya: TipografiFunda.isi.copyWith(
                fontSize: 16,
                height: 1.6,
                color: WarnaFunda.teks,
              ),
            ),
            const SizedBox(height: SpasiFunda.l),
            const TeksFunda.isiKecil(
              'Mari kita bedah pelan-pelan melalui kartu konsep berikut ini.',
              warna: WarnaFunda.teksRedup,
              rataTeks: TextAlign.start,
            ),
          ],
        ),
      ),
    );

    // 2. Kartu Konsep (1 sampai 3 kartu)
    for (var i = 0; i < pel.kartu.length; i++) {
      final k = pel.kartu[i];
      kartuWidgets.add(
        _pembungkusKartu(
          judul: k.judul,
          headerVisual: KanvasIlustrasiPelajaran(modulId: pel.modulId),
          pakaiKartuMembungkus: false,
          isi: TeksAnimasiKata(
            teks: k.isi,
            dukungIstilah: true,
            rataTeks: TextAlign.start,
            gaya: TipografiFunda.isi.copyWith(
              fontSize: 16,
              height: 1.6,
              color: WarnaFunda.teks,
            ),
          ),
        ),
      );
    }

    // 3. Contoh Angka Konkret
    final contoh = pel.contohAngka;
    if (contoh != null && _punyaContohAngka(pel)) {
      kartuWidgets.add(
        _pembungkusKartu(
          judul: contoh.judul.isNotEmpty ? contoh.judul : 'Gambaran Angka',
          isi: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(SpasiFunda.l),
                decoration: BoxDecoration(
                  color: WarnaFunda.latar,
                  borderRadius: BorderRadius.circular(SudutFunda.kartu),
                  border: Border.all(color: WarnaFunda.garis),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Table(
                      columnWidths: const {
                        0: FlexColumnWidth(3),
                        1: FlexColumnWidth(2),
                      },
                      children: contoh.baris.map((b) {
                        final isTebal = b.ringkasan;
                        final formatJumlah = formatRupiahRapat(b.jumlah);

                        return TableRow(
                          decoration: isTebal
                              ? const BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: WarnaFunda.garis,
                                      width: 1.5,
                                    ),
                                  ),
                                )
                              : null,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                top: SpasiFunda.xs,
                                bottom: SpasiFunda.xs,
                                right: SpasiFunda.s,
                              ),
                              child: Text(
                                b.label,
                                style: TipografiFunda.isiKecil.copyWith(
                                  fontWeight: isTebal
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                  color: isTebal
                                      ? WarnaFunda.teks
                                      : WarnaFunda.teksRedup,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: SpasiFunda.xs,
                              ),
                              child: Text(
                                formatJumlah,
                                textAlign: TextAlign.right,
                                style: TipografiFunda.isiKecil.copyWith(
                                  fontWeight: isTebal
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  color: WarnaFunda.teks,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                    if (contoh.kesimpulan.isNotEmpty) ...[
                      const SizedBox(height: SpasiFunda.m),
                      const Divider(color: WarnaFunda.garis),
                      const SizedBox(height: SpasiFunda.s),
                      TeksAnimasiKata(
                        teks: contoh.kesimpulan,
                        dukungIstilah: false,
                        rataTeks: TextAlign.start,
                        gaya: TipografiFunda.isiKecil.copyWith(
                          height: 1.6,
                          color: WarnaFunda.teksRedup,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 4. Cek Paham (1 soal per halaman PageView)
    for (var idx = 0; idx < pel.cekPaham.length; idx++) {
      final soal = pel.cekPaham[idx];
      final jawabanDipilih = _jawabanCekPaham[idx];
      final sudahDijawab = jawabanDipilih != null;

      kartuWidgets.add(
        _pembungkusKartu(
          judul: 'Uji Pemahaman Singkat',
          isi: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TeksFunda.catatan(
                'Pertanyaan ${idx + 1} dari ${pel.cekPaham.length}',
                warna: WarnaFunda.utama,
              ),
              const SizedBox(height: SpasiFunda.s),
              TeksFunda.label(soal.tanya),
              const SizedBox(height: SpasiFunda.m),
              ...soal.pilihan.asMap().entries.map((pEntry) {
                final pIdx = pEntry.key;
                final teksPilihan = pEntry.value;
                final isSelected = jawabanDipilih == pIdx;

                Color latarPilihan = WarnaFunda.permukaan;
                Color borderPilihan = WarnaFunda.garis;

                if (sudahDijawab) {
                  if (pIdx == soal.benar) {
                    latarPilihan = WarnaFunda.tintHijau;
                    borderPilihan = WarnaFunda.pemasukan;
                  } else if (isSelected) {
                    latarPilihan = WarnaFunda.tintMawar;
                    borderPilihan = WarnaFunda.pengeluaran;
                  }
                }

                return InkWell(
                  onTap: sudahDijawab
                      ? null
                      : () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _jawabanCekPaham[idx] = pIdx;
                          });
                        },
                  borderRadius: BorderRadius.circular(SudutFunda.kartu),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 48),
                    margin: const EdgeInsets.only(bottom: SpasiFunda.s),
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpasiFunda.m,
                      vertical: SpasiFunda.s,
                    ),
                    decoration: BoxDecoration(
                      color: latarPilihan,
                      borderRadius: BorderRadius.circular(SudutFunda.kartu),
                      border: Border.all(
                        color: borderPilihan,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? LucideIcons.checkCircle2
                              : LucideIcons.circle,
                          size: 18,
                          color: isSelected
                              ? WarnaFunda.utama
                              : WarnaFunda.teksRedup,
                        ),
                        const SizedBox(width: SpasiFunda.s),
                        Expanded(child: TeksFunda.isiKecil(teksPilihan)),
                      ],
                    ),
                  ),
                );
              }),
              if (sudahDijawab) ...[
                const SizedBox(height: SpasiFunda.m),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(SpasiFunda.m),
                  decoration: BoxDecoration(
                    color: jawabanDipilih == soal.benar
                        ? WarnaFunda.tintHijau
                        : WarnaFunda.tintAmber,
                    borderRadius: BorderRadius.circular(SudutFunda.kartu),
                    border: Border.all(
                      color: jawabanDipilih == soal.benar
                          ? WarnaFunda.batasHijau
                          : WarnaFunda.batasAmber,
                    ),
                  ),
                  child: TeksFunda.isiKecil(
                    soal.penjelasan,
                    warna: WarnaFunda.teks,
                    rataTeks: TextAlign.start,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    // 5. Kartu Misi Praktik
    kartuWidgets.add(_bangunKartuMisiPraktik(pel.misi, fotoData));

    // 6. Umpan Balik
    kartuWidgets.add(_bangunKartuUmpanBalik(pel.misi));

    // 7. Tindak Lanjut (bila ada)
    if (pel.tindakLanjut != null && pel.tindakLanjut!.isNotEmpty) {
      kartuWidgets.add(
        _pembungkusKartu(
          judul: 'Langkah Kecil Berikutnya',
          headerVisual: KanvasIlustrasiPelajaran(modulId: pel.modulId),
          pakaiKartuMembungkus: false,
          isi: TeksAnimasiKata(
            teks: pel.tindakLanjut!,
            dukungIstilah: false,
            rataTeks: TextAlign.start,
            gaya: TipografiFunda.isi.copyWith(
              fontSize: 16,
              height: 1.6,
              color: WarnaFunda.teks,
            ),
          ),
        ),
      );
    }

    return kartuWidgets;
  }

  Widget _bangunKartuMisiPraktik(MisiKonten misi, FotoDataPengguna fotoData) {
    if (misi.tipe == 'keputusan') {
      return _bangunKartuMisiKeputusan(misi);
    }
    if (misi.tipe == 'daftar_periksa') {
      return _bangunKartuMisiDaftarPeriksa(misi);
    }
    if (misi.tipe == 'refleksi') {
      return _bangunKartuMisiRefleksi(misi);
    }
    if (misi.tipe == 'sandbox') {
      return _bangunKartuMisiSandbox(misi);
    }

    final evalMisi = RegistriMisi.evaluasi(misi: misi, fotoData: fotoData);
    final sudahSelesai = evalMisi.selesai || _misiTerverifikasi;

    return _pembungkusKartu(
      judul: misi.judul,
      isi: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TeksFunda.isi(misi.deskripsi),
          const SizedBox(height: SpasiFunda.m),
          Row(
            children: [
              const Icon(
                LucideIcons.timer,
                size: 16,
                color: WarnaFunda.teksRedup,
              ),
              const SizedBox(width: SpasiFunda.xs),
              Expanded(
                child: TeksFunda.catatan(
                  'Perkiraan waktu: ${misi.perkiraanMenit} menit',
                  warna: WarnaFunda.teksRedup,
                ),
              ),
            ],
          ),
          const SizedBox(height: SpasiFunda.l),

          // Status Verifikasi Misi
          Container(
            padding: const EdgeInsets.all(SpasiFunda.m),
            decoration: BoxDecoration(
              color: sudahSelesai
                  ? WarnaFunda.tintHijau
                  : (_misiDilewati
                        ? WarnaFunda.tintNetral
                        : WarnaFunda.tintAmber),
              borderRadius: BorderRadius.circular(SudutFunda.kartu),
            ),
            child: Row(
              children: [
                Icon(
                  sudahSelesai
                      ? LucideIcons.checkCircle
                      : (_misiDilewati
                            ? LucideIcons.forward
                            : LucideIcons.alertCircle),
                  color: sudahSelesai
                      ? WarnaFunda.pemasukan
                      : (_misiDilewati
                            ? WarnaFunda.teksRedup
                            : WarnaFunda.peringatan),
                ),
                const SizedBox(width: SpasiFunda.s),
                Expanded(
                  child: TeksFunda.label(
                    _misiDilewati
                        ? 'Misi ini kamu lewati.'
                        : evalMisi.statusTeks,
                    warna: sudahSelesai
                        ? WarnaFunda.pemasukan
                        : WarnaFunda.teks,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: SpasiFunda.l),

          // Tombol-tombol aksi Misi
          if (!sudahSelesai && !_misiDilewati) ...[
            TombolFunda(
              key: const Key('tombol_kerjakan_misi'),
              teks: 'Kerjakan Sekarang',
              lebarPenuh: true,
              padaTekan: () {
                final rute = ambilRutePengisianObjek(misi.objek) ?? '/catatan';
                if (rute == '/catatan' || rute == '/transaksi/tambah') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LayarFormTransaksi(),
                    ),
                  );
                } else {
                  context.push(rute);
                }
              },
            ),
            const SizedBox(height: SpasiFunda.s),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                key: const Key('tombol_periksa_misi'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  side: const BorderSide(color: WarnaFunda.garis),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SudutFunda.pil),
                  ),
                ),
                onPressed: () async {
                  ref.invalidate(penyediaFotoData);
                  if (evalMisi.selesai) {
                    setState(() {
                      _misiTerverifikasi = true;
                    });
                    await ref
                        .read(penyediaHasilMisiRepositori)
                        .simpanHasilMisi(
                          misiId: widget.pelajaranId,
                          pelajaranId: widget.pelajaranId,
                          tipe: misi.tipe,
                          status: 'selesai',
                          muatanJson: null,
                        );
                  }
                },
                child: const TeksFunda.catatan('Periksa Misi'),
              ),
            ),
            const SizedBox(height: SpasiFunda.xs),
            Center(
              child: TextButton(
                key: const Key('tombol_lewati_misi'),
                style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                onPressed: () async {
                  setState(() {
                    _misiDilewati = true;
                  });
                  await ref
                      .read(penyediaHasilMisiRepositori)
                      .simpanHasilMisi(
                        misiId: widget.pelajaranId,
                        pelajaranId: widget.pelajaranId,
                        tipe: misi.tipe,
                        status: 'dilewati',
                      );
                },
                child: const TeksFunda.catatan(
                  'Belum relevan buat aku',
                  warna: WarnaFunda.teksRedup,
                ),
              ),
            ),
          ] else if (sudahSelesai) ...[
            Container(
              padding: const EdgeInsets.all(SpasiFunda.m),
              decoration: BoxDecoration(
                color: WarnaFunda.tintHijau,
                borderRadius: BorderRadius.circular(SudutFunda.kartu),
              ),
              child: const Row(
                children: [
                  Icon(LucideIcons.check, color: WarnaFunda.pemasukan),
                  SizedBox(width: SpasiFunda.s),
                  Expanded(
                    child: TeksFunda.label(
                      'Luar biasa! Misi berhasil diselesaikan.',
                      warna: WarnaFunda.pemasukan,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _bangunKartuMisiKeputusan(MisiKonten misi) {
    final skenario = misi.skenario;
    final pemantik = skenario?.pemantik ?? '';
    final opsiList = skenario?.opsi ?? [];

    return _pembungkusKartu(
      judul: misi.judul,
      isi: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TeksFunda.isi(
            misi.instruksi.isNotEmpty ? misi.instruksi : misi.deskripsi,
          ),
          const SizedBox(height: SpasiFunda.m),
          Row(
            children: [
              const Icon(
                LucideIcons.timer,
                size: 16,
                color: WarnaFunda.teksRedup,
              ),
              const SizedBox(width: SpasiFunda.xs),
              Expanded(
                child: TeksFunda.catatan(
                  'Perkiraan waktu: ${misi.perkiraanMenit} menit',
                  warna: WarnaFunda.teksRedup,
                ),
              ),
            ],
          ),
          const SizedBox(height: SpasiFunda.l),

          // Skenario Pemantik
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(SpasiFunda.m),
            decoration: BoxDecoration(
              color: WarnaFunda.utamaTipis,
              borderRadius: BorderRadius.circular(SudutFunda.kartu),
              border: Border.all(color: WarnaFunda.garis),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      LucideIcons.helpCircle,
                      size: 18,
                      color: WarnaFunda.utama,
                    ),
                    SizedBox(width: SpasiFunda.xs),
                    TeksFunda.label('Skenario', warna: WarnaFunda.utama),
                  ],
                ),
                const SizedBox(height: SpasiFunda.s),
                TeksFunda.isi(pemantik),
              ],
            ),
          ),
          const SizedBox(height: SpasiFunda.l),

          // Tampilan Opsi atau Umpan Balik
          if (_misiDilewati) ...[
            Container(
              padding: const EdgeInsets.all(SpasiFunda.m),
              decoration: BoxDecoration(
                color: WarnaFunda.tintNetral,
                borderRadius: BorderRadius.circular(SudutFunda.kartu),
              ),
              child: const Row(
                children: [
                  Icon(LucideIcons.forward, color: WarnaFunda.teksRedup),
                  SizedBox(width: SpasiFunda.s),
                  Expanded(
                    child: TeksFunda.label(
                      'Misi ini kamu lewati.',
                      warna: WarnaFunda.teks,
                    ),
                  ),
                ],
              ),
            ),
          ] else if (_misiTerverifikasi) ...[
            // Misi Selesai (Opsi aman terpilih)
            Container(
              padding: const EdgeInsets.all(SpasiFunda.m),
              decoration: BoxDecoration(
                color: WarnaFunda.tintHijau,
                borderRadius: BorderRadius.circular(SudutFunda.kartu),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        LucideIcons.checkCircle,
                        color: WarnaFunda.pemasukan,
                      ),
                      SizedBox(width: SpasiFunda.s),
                      Expanded(
                        child: TeksFunda.label(
                          'Pilihan Aman Terverifikasi!',
                          warna: WarnaFunda.pemasukan,
                        ),
                      ),
                    ],
                  ),
                  if (_opsiKeputusanTerpilih != null) ...[
                    const SizedBox(height: SpasiFunda.s),
                    Builder(
                      builder: (context) {
                        final opt = opsiList.firstWhere(
                          (o) => o.id == _opsiKeputusanTerpilih,
                          orElse: () => const OpsiKeputusanMisi(
                            id: '',
                            teks: '',
                            aman: true,
                            umpanBalik: '',
                          ),
                        );
                        return TeksFunda.isi(opt.umpanBalik);
                      },
                    ),
                  ],
                ],
              ),
            ),
          ] else if (_tampilkanUmpanBalikKeputusan &&
              _opsiKeputusanTerpilih != null) ...[
            // Opsi tidak aman dipilih -> Tampilkan umpan balik & tombol Coba pilihan lain
            Builder(
              builder: (context) {
                final opt = opsiList.firstWhere(
                  (o) => o.id == _opsiKeputusanTerpilih,
                  orElse: () => const OpsiKeputusanMisi(
                    id: '',
                    teks: '',
                    aman: false,
                    umpanBalik: '',
                  ),
                );
                return Container(
                  padding: const EdgeInsets.all(SpasiFunda.m),
                  decoration: BoxDecoration(
                    color: WarnaFunda.tintAmber,
                    borderRadius: BorderRadius.circular(SudutFunda.kartu),
                    border: Border.all(color: WarnaFunda.garis),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            LucideIcons.alertCircle,
                            color: WarnaFunda.peringatan,
                          ),
                          SizedBox(width: SpasiFunda.s),
                          Expanded(
                            child: TeksFunda.label(
                              'Umpan Balik Pilihan',
                              warna: WarnaFunda.peringatan,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: SpasiFunda.s),
                      TeksFunda.isi(opt.umpanBalik),
                      const SizedBox(height: SpasiFunda.m),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          key: const Key('tombol_coba_pilihan_lain'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(48, 48),
                            side: const BorderSide(color: WarnaFunda.garis),
                            backgroundColor: WarnaFunda.permukaan,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                SudutFunda.pil,
                              ),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _tampilkanUmpanBalikKeputusan = false;
                              _opsiKeputusanTerpilih = null;
                            });
                          },
                          child: const TeksFunda.label(
                            'Coba pilihan lain',
                            warna: WarnaFunda.utama,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: SpasiFunda.s),
            Center(
              child: TextButton(
                key: const Key('tombol_lewati_misi'),
                style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                onPressed: () async {
                  setState(() {
                    _misiDilewati = true;
                  });
                  await ref
                      .read(penyediaHasilMisiRepositori)
                      .simpanHasilMisi(
                        misiId: widget.pelajaranId,
                        pelajaranId: widget.pelajaranId,
                        tipe: misi.tipe,
                        status: 'dilewati',
                      );
                },
                child: const TeksFunda.catatan(
                  'Belum relevan buat aku',
                  warna: WarnaFunda.teksRedup,
                ),
              ),
            ),
          ] else ...[
            // Daftar tombol opsi (>= 48 dp)
            for (final opsi in opsiList) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: SpasiFunda.s),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    key: Key('opsi_keputusan_${opsi.id}'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(48, 48),
                      padding: const EdgeInsets.symmetric(
                        horizontal: SpasiFunda.m,
                        vertical: SpasiFunda.m,
                      ),
                      side: const BorderSide(color: WarnaFunda.garis),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(SudutFunda.kartu),
                      ),
                      alignment: Alignment.centerLeft,
                    ),
                    onPressed: () async {
                      _riwayatOpsiDipilih.add(opsi.id);
                      _opsiKeputusanTerpilih = opsi.id;
                      _tampilkanUmpanBalikKeputusan = true;
                      if (opsi.aman) {
                        _misiTerverifikasi = true;
                        await ref
                            .read(penyediaHasilMisiRepositori)
                            .simpanHasilMisi(
                              misiId: widget.pelajaranId,
                              pelajaranId: widget.pelajaranId,
                              tipe: misi.tipe,
                              status: 'selesai',
                              muatanJson: jsonEncode({
                                'opsiDipilih': _riwayatOpsiDipilih,
                              }),
                            );
                      }
                      setState(() {});
                    },
                    child: TeksFunda.isi(opsi.teks),
                  ),
                ),
              ),
            ],
            const SizedBox(height: SpasiFunda.xs),
            Center(
              child: TextButton(
                key: const Key('tombol_lewati_misi'),
                style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                onPressed: () async {
                  setState(() {
                    _misiDilewati = true;
                  });
                  await ref
                      .read(penyediaHasilMisiRepositori)
                      .simpanHasilMisi(
                        misiId: widget.pelajaranId,
                        pelajaranId: widget.pelajaranId,
                        tipe: misi.tipe,
                        status: 'dilewati',
                      );
                },
                child: const TeksFunda.catatan(
                  'Belum relevan buat aku',
                  warna: WarnaFunda.teksRedup,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _bangunKartuMisiDaftarPeriksa(MisiKonten misi) {
    final langkahList = misi.langkah ?? [];
    final minDicentang = misi.minimalDicentang ?? 1;
    final jumlahDicentang = _langkahDicentang.length;
    final memenuhiSyarat = jumlahDicentang >= minDicentang;

    return _pembungkusKartu(
      judul: misi.judul,
      isi: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TeksFunda.isi(
            misi.instruksi.isNotEmpty ? misi.instruksi : misi.deskripsi,
          ),
          const SizedBox(height: SpasiFunda.m),
          Row(
            children: [
              const Icon(
                LucideIcons.timer,
                size: 16,
                color: WarnaFunda.teksRedup,
              ),
              const SizedBox(width: SpasiFunda.xs),
              Expanded(
                child: TeksFunda.catatan(
                  'Perkiraan waktu: ${misi.perkiraanMenit} menit',
                  warna: WarnaFunda.teksRedup,
                ),
              ),
            ],
          ),
          const SizedBox(height: SpasiFunda.l),

          // 1. Komponen Disclaimer di atas
          DisclaimerLangkahDuniaNyata(
            key: const Key('disclaimer_langkah_dunia_nyata'),
            sudahMengerti: _disclaimerSudahMengerti,
            padaMengerti: () {
              setState(() {
                _disclaimerSudahMengerti = true;
              });
            },
          ),

          // 2. Daftar Kotak Centang (Semantics, >= 48 dp)
          for (final langkah in langkahList) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: SpasiFunda.xs),
              child: Semantics(
                label: langkah.teks,
                checked: _langkahDicentang.contains(langkah.id),
                child: InkWell(
                  key: Key('centang_langkah_${langkah.id}'),
                  borderRadius: BorderRadius.circular(SudutFunda.kartu),
                  onTap: _misiTerverifikasi
                      ? null
                      : () {
                          setState(() {
                            if (_langkahDicentang.contains(langkah.id)) {
                              _langkahDicentang.remove(langkah.id);
                            } else {
                              _langkahDicentang.add(langkah.id);
                            }
                          });
                        },
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 48),
                    padding: const EdgeInsets.symmetric(
                      vertical: SpasiFunda.s,
                      horizontal: SpasiFunda.xs,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          _langkahDicentang.contains(langkah.id)
                              ? LucideIcons.checkSquare
                              : LucideIcons.square,
                          color: _langkahDicentang.contains(langkah.id)
                              ? WarnaFunda.utama
                              : WarnaFunda.teksRedup,
                          size: 22,
                        ),
                        const SizedBox(width: SpasiFunda.s),
                        Expanded(child: TeksFunda.isi(langkah.teks)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: SpasiFunda.m),

          // Penghitung "n dari minimal m"
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: SpasiFunda.m,
              vertical: SpasiFunda.s,
            ),
            decoration: BoxDecoration(
              color: memenuhiSyarat
                  ? WarnaFunda.tintHijau
                  : WarnaFunda.permukaan,
              borderRadius: BorderRadius.circular(SudutFunda.kartu),
              border: Border.all(color: WarnaFunda.garis),
            ),
            child: Row(
              children: [
                Icon(
                  memenuhiSyarat ? LucideIcons.check : LucideIcons.listTodo,
                  size: 18,
                  color: memenuhiSyarat
                      ? WarnaFunda.pemasukan
                      : WarnaFunda.teksRedup,
                ),
                const SizedBox(width: SpasiFunda.s),
                Expanded(
                  child: TeksFunda.label(
                    '$jumlahDicentang dari minimal $minDicentang langkah dicentang',
                    warna: memenuhiSyarat
                        ? WarnaFunda.pemasukan
                        : WarnaFunda.teks,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: SpasiFunda.l),

          // Tombol Selesai atau Status
          if (_misiDilewati) ...[
            Container(
              padding: const EdgeInsets.all(SpasiFunda.m),
              decoration: BoxDecoration(
                color: WarnaFunda.tintNetral,
                borderRadius: BorderRadius.circular(SudutFunda.kartu),
              ),
              child: const Row(
                children: [
                  Icon(LucideIcons.forward, color: WarnaFunda.teksRedup),
                  SizedBox(width: SpasiFunda.s),
                  Expanded(
                    child: TeksFunda.label(
                      'Misi ini kamu lewati.',
                      warna: WarnaFunda.teks,
                    ),
                  ),
                ],
              ),
            ),
          ] else if (_misiTerverifikasi) ...[
            Container(
              padding: const EdgeInsets.all(SpasiFunda.m),
              decoration: BoxDecoration(
                color: WarnaFunda.tintHijau,
                borderRadius: BorderRadius.circular(SudutFunda.kartu),
              ),
              child: const Row(
                children: [
                  Icon(LucideIcons.check, color: WarnaFunda.pemasukan),
                  SizedBox(width: SpasiFunda.s),
                  Expanded(
                    child: TeksFunda.label(
                      'Luar biasa! Misi berhasil diselesaikan.',
                      warna: WarnaFunda.pemasukan,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            TombolFunda(
              key: const Key('tombol_selesai_daftar_periksa'),
              teks: 'Selesai',
              lebarPenuh: true,
              padaTekan: memenuhiSyarat
                  ? () async {
                      setState(() {
                        _misiTerverifikasi = true;
                      });
                      await ref
                          .read(penyediaHasilMisiRepositori)
                          .simpanHasilMisi(
                            misiId: widget.pelajaranId,
                            pelajaranId: widget.pelajaranId,
                            tipe: misi.tipe,
                            status: 'selesai',
                            muatanJson: jsonEncode({
                              'dicentang': _langkahDicentang.toList(),
                            }),
                          );
                    }
                  : null,
            ),
            const SizedBox(height: SpasiFunda.xs),
            Center(
              child: TextButton(
                key: const Key('tombol_lewati_misi'),
                style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                onPressed: () async {
                  setState(() {
                    _misiDilewati = true;
                  });
                  await ref
                      .read(penyediaHasilMisiRepositori)
                      .simpanHasilMisi(
                        misiId: widget.pelajaranId,
                        pelajaranId: widget.pelajaranId,
                        tipe: misi.tipe,
                        status: 'dilewati',
                      );
                },
                child: const TeksFunda.catatan(
                  'Belum relevan buat aku',
                  warna: WarnaFunda.teksRedup,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _bangunKartuMisiRefleksi(MisiKonten misi) {
    final minimalKarakter = misi.minimalKarakter;
    final panjangKarakter = _teksRefleksi.trim().length;
    final cukupKarakter = panjangKarakter >= minimalKarakter;

    return _pembungkusKartu(
      judul: misi.judul,
      isi: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TeksFunda.isi(misi.instruksi),
          const SizedBox(height: SpasiFunda.m),
          Row(
            children: [
              const Icon(
                LucideIcons.timer,
                size: 16,
                color: WarnaFunda.teksRedup,
              ),
              const SizedBox(width: SpasiFunda.xs),
              Expanded(
                child: TeksFunda.catatan(
                  'Perkiraan waktu: ${misi.perkiraanMenit} menit',
                  warna: WarnaFunda.teksRedup,
                ),
              ),
            ],
          ),
          const SizedBox(height: SpasiFunda.l),

          // Keterangan privat
          Container(
            padding: const EdgeInsets.all(SpasiFunda.m),
            decoration: BoxDecoration(
              color: WarnaFunda.latar,
              borderRadius: BorderRadius.circular(SudutFunda.kartu),
              border: Border.all(color: WarnaFunda.garis),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(LucideIcons.lock, size: 18, color: WarnaFunda.utama),
                SizedBox(width: SpasiFunda.s),
                Expanded(
                  child: TeksFunda.catatan(
                    'Catatan ini privat dan hanya tersimpan di HP-mu.',
                    warna: WarnaFunda.teks,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: SpasiFunda.l),

          // Pertanyaan refleksi
          if (misi.pertanyaan != null) ...[
            TeksFunda.judulBagian(misi.pertanyaan!),
            const SizedBox(height: SpasiFunda.m),
          ],

          // Kolom teks multi-baris
          Semantics(
            label: 'Kolom input refleksi',
            child: TextFormField(
              key: const Key('input_refleksi'),
              controller: _pengontrolRefleksi,
              minLines: 3,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: misi.petunjukInput ?? 'Tulis refleksimu di sini...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SudutFunda.kecil),
                  borderSide: const BorderSide(color: WarnaFunda.garis),
                ),
                contentPadding: const EdgeInsets.all(SpasiFunda.m),
              ),
            ),
          ),
          const SizedBox(height: SpasiFunda.s),

          // Penghitung karakter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TeksFunda.catatan(
                'Minimal $minimalKarakter karakter',
                warna: WarnaFunda.teksRedup,
              ),
              TeksFunda.catatan(
                '$panjangKarakter / $minimalKarakter',
                warna: cukupKarakter ? WarnaFunda.sukses : WarnaFunda.teksRedup,
              ),
            ],
          ),
          const SizedBox(height: SpasiFunda.l),

          // Tombol simpan refleksi
          TombolFunda(
            key: const Key('tombol_simpan_refleksi'),
            teks: _misiTerverifikasi ? 'Perbarui Refleksi' : 'Simpan Refleksi',
            ikon: const Icon(LucideIcons.check, size: 18),
            lebarPenuh: true,
            padaTekan: cukupKarakter
                ? () async {
                    setState(() {
                      _misiTerverifikasi = true;
                    });
                    await ref
                        .read(penyediaHasilMisiRepositori)
                        .simpanHasilMisi(
                          misiId: widget.pelajaranId,
                          pelajaranId: widget.pelajaranId,
                          tipe: misi.tipe,
                          status: 'selesai',
                          muatanJson: jsonEncode({
                            'jawaban': _teksRefleksi.trim(),
                          }),
                        );
                  }
                : null,
          ),

          if (_misiTerverifikasi) ...[
            const SizedBox(height: SpasiFunda.m),
            Container(
              padding: const EdgeInsets.all(SpasiFunda.m),
              decoration: BoxDecoration(
                color: WarnaFunda.tintHijau,
                borderRadius: BorderRadius.circular(SudutFunda.kartu),
              ),
              child: const Row(
                children: [
                  Icon(
                    LucideIcons.checkCircle2,
                    size: 20,
                    color: WarnaFunda.sukses,
                  ),
                  SizedBox(width: SpasiFunda.s),
                  Expanded(
                    child: TeksFunda.catatan(
                      'Refleksi tersimpan dengan aman di perangkatmu.',
                      warna: WarnaFunda.sukses,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: SpasiFunda.xs),
          Center(
            child: TextButton(
              key: const Key('tombol_lewati_misi'),
              style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
              onPressed: () async {
                setState(() {
                  _misiDilewati = true;
                });
                await ref
                    .read(penyediaHasilMisiRepositori)
                    .simpanHasilMisi(
                      misiId: widget.pelajaranId,
                      pelajaranId: widget.pelajaranId,
                      tipe: misi.tipe,
                      status: 'dilewati',
                    );
              },
              child: const TeksFunda.catatan(
                'Belum relevan buat aku',
                warna: WarnaFunda.teksRedup,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bangunKartuMisiSandbox(MisiKonten misi) {
    final sudahSelesai = _misiTerverifikasi;

    return _pembungkusKartu(
      judul: misi.judul,
      isi: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TeksFunda.isi(
            misi.instruksi.isNotEmpty ? misi.instruksi : misi.deskripsi,
          ),
          const SizedBox(height: SpasiFunda.m),
          Row(
            children: [
              const Icon(
                LucideIcons.timer,
                size: 16,
                color: WarnaFunda.teksRedup,
              ),
              const SizedBox(width: SpasiFunda.xs),
              Expanded(
                child: TeksFunda.catatan(
                  'Perkiraan waktu: ${misi.perkiraanMenit} menit',
                  warna: WarnaFunda.teksRedup,
                ),
              ),
            ],
          ),
          const SizedBox(height: SpasiFunda.l),

          // 1. Komponen Disclaimer di atas
          DisclaimerLangkahDuniaNyata(
            key: const Key('disclaimer_langkah_dunia_nyata'),
            sudahMengerti: _disclaimerSudahMengerti,
            padaMengerti: () {
              setState(() {
                _disclaimerSudahMengerti = true;
              });
            },
          ),
          const SizedBox(height: SpasiFunda.m),

          // 2. Status Verifikasi Misi
          Container(
            padding: const EdgeInsets.all(SpasiFunda.m),
            decoration: BoxDecoration(
              color: sudahSelesai
                  ? WarnaFunda.tintHijau
                  : (_misiDilewati
                        ? WarnaFunda.tintNetral
                        : WarnaFunda.tintAmber),
              borderRadius: BorderRadius.circular(SudutFunda.kartu),
            ),
            child: Row(
              children: [
                Icon(
                  sudahSelesai
                      ? LucideIcons.checkCircle
                      : (_misiDilewati
                            ? LucideIcons.forward
                            : LucideIcons.flaskConical),
                  color: sudahSelesai
                      ? WarnaFunda.pemasukan
                      : (_misiDilewati
                            ? WarnaFunda.teksRedup
                            : WarnaFunda.peringatan),
                ),
                const SizedBox(width: SpasiFunda.s),
                Expanded(
                  child: TeksFunda.label(
                    _misiDilewati
                        ? 'Misi ini kamu lewati.'
                        : (sudahSelesai
                              ? (_ringkasanSandbox.isNotEmpty
                                    ? 'Simulasi selesai! $_ringkasanSandbox'
                                    : 'Syarat misi terpenuhi. Simulasi sandbox sudah kamu jalankan.')
                              : 'Buka Mode Sandbox, atur alokasi, lalu jalankan minimal 1 tahun simulasi.'),
                    warna: sudahSelesai
                        ? WarnaFunda.pemasukan
                        : WarnaFunda.teks,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: SpasiFunda.l),

          // 3. Tombol Aksi Buka Sandbox & Periksa Misi
          if (!sudahSelesai && !_misiDilewati) ...[
            SizedBox(
              height: 48,
              width: double.infinity,
              child: OutlinedButton.icon(
                key: const Key('tombol_buka_sandbox'),
                icon: const Icon(LucideIcons.externalLink, size: 18),
                label: const Text('Buka Mode Sandbox'),
                onPressed: () => context.push('/sandbox'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  foregroundColor: WarnaFunda.utama,
                ),
              ),
            ),
            const SizedBox(height: SpasiFunda.m),
            SizedBox(
              height: 48,
              width: double.infinity,
              child: ElevatedButton.icon(
                key: const Key('tombol_periksa_misi_sandbox'),
                icon: const Icon(LucideIcons.check, size: 18),
                label: const Text('Periksa Misi'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: WarnaFunda.utama,
                  foregroundColor: WarnaFunda.putih,
                ),
                onPressed: () async {
                  final repo = ref.read(penyediaSandboxRepositori);
                  final sesi = await repo.ambilSesiTerakhir();
                  if (sesi != null && sesi.bulanBerjalan >= 12) {
                    final ringkasan =
                        'PU ${sesi.alokasiPasarUangPersen}%, OB ${sesi.alokasiObligasiPersen}%, SH ${sesi.alokasiSahamPersen}%. Nilai: ${formatRupiahRapat(sesi.nilaiSaatIniRupiah)}';
                    final muatan = jsonEncode({
                      'skenario': sesi.skenarioAktif,
                      'bulanBerjalan': sesi.bulanBerjalan,
                      'nilaiSaatIni': sesi.nilaiSaatIniRupiah,
                      'ringkasanSandbox': ringkasan,
                    });
                    setState(() {
                      _misiTerverifikasi = true;
                      _ringkasanSandbox = ringkasan;
                    });
                    await ref
                        .read(penyediaHasilMisiRepositori)
                        .simpanHasilMisi(
                          misiId: widget.pelajaranId,
                          pelajaranId: widget.pelajaranId,
                          tipe: 'sandbox',
                          status: 'selesai',
                          muatanJson: muatan,
                        );
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Jalankan minimal 1 tahun simulasi di Mode Sandbox terlebih dahulu.',
                          ),
                          backgroundColor: WarnaFunda.peringatan,
                        ),
                      );
                    }
                  }
                },
              ),
            ),
            const SizedBox(height: SpasiFunda.xs),
            Center(
              child: TextButton(
                key: const Key('tombol_lewati_misi'),
                style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                onPressed: () async {
                  setState(() {
                    _misiDilewati = true;
                  });
                  await ref
                      .read(penyediaHasilMisiRepositori)
                      .simpanHasilMisi(
                        misiId: widget.pelajaranId,
                        pelajaranId: widget.pelajaranId,
                        tipe: misi.tipe,
                        status: 'dilewati',
                      );
                },
                child: const TeksFunda.catatan(
                  'Belum relevan buat aku',
                  warna: WarnaFunda.teksRedup,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _bangunKartuUmpanBalik(MisiKonten misi) {
    final kunci = misi.umpanBalik ?? 'arus_kas_bulan_ini';
    final umpanBalikAsync = ref.watch(penyediaTeksUmpanBalikMisi(kunci));
    final teksUmpanBalik = umpanBalikAsync.value ?? 'Memuat analisis datamu...';

    return _pembungkusKartu(
      judul: 'Hasil dari Datamu',
      isi: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(SpasiFunda.l),
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
                      decoration: const BoxDecoration(
                        color: WarnaFunda.utamaTipis,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.barChart2,
                        color: WarnaFunda.utama,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: SpasiFunda.s),
                    const Expanded(
                      child: TeksFunda.label('Analisis Data Pengguna'),
                    ),
                  ],
                ),
                const SizedBox(height: SpasiFunda.m),
                TeksFunda.isi(teksUmpanBalik),
              ],
            ),
          ),
          const SizedBox(height: SpasiFunda.m),
          const TeksFunda.catatan(
            'Ini adalah gambaran nyata dari keuanganmu saat ini tanpa kata-kata menghakimi.',
            warna: WarnaFunda.teksRedup,
          ),
        ],
      ),
    );
  }

  Widget _pembungkusKartu({
    required String judul,
    required Widget isi,
    Widget? headerVisual,
    bool pakaiKartuMembungkus = true,
  }) {
    final konten = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (headerVisual != null) ...[
          headerVisual,
          const SizedBox(height: SpasiFunda.xl),
        ],
        TeksFunda.judulLayar(judul),
        const SizedBox(height: SpasiFunda.m),
        isi,
        const SizedBox(height: SpasiFunda.m),
      ],
    );

    if (!pakaiKartuMembungkus) {
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          SpasiFunda.xl,
          SpasiFunda.s,
          SpasiFunda.xl,
          SpasiFunda.m,
        ),
        child: konten,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: SpasiFunda.marginLayar),
      child: Container(
        margin: const EdgeInsets.only(top: SpasiFunda.s, bottom: SpasiFunda.s),
        padding: const EdgeInsets.all(SpasiFunda.l),
        decoration: BoxDecoration(
          color: WarnaFunda.permukaan,
          borderRadius: BorderRadius.circular(SudutFunda.petak),
          border: Border.all(color: WarnaFunda.garis),
        ),
        child: konten,
      ),
    );
  }
}
