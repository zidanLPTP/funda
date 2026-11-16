import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../data/penyedia_data.dart';
import '../../../komponen/komponen_funda.dart';
import '../../../perhitungan/perhitungan_belajar.dart';
import '../../../tema/token.dart';
import '../../../util/format_rupiah.dart';
import '../kontroler/penyedia_belajar.dart';
import '../model/pembaca_konten.dart';
import '../model/registri_misi.dart';
import 'komponen_teks_istilah.dart';

/// Layar pemutar pelajaran kartu geser berurutan (Micro-learning Funda).
class LayarPemutarPelajaran extends ConsumerStatefulWidget {
  final String modulId;
  final String pelajaranId;

  const LayarPemutarPelajaran({
    super.key,
    required this.modulId,
    required this.pelajaranId,
  });

  @override
  ConsumerState<LayarPemutarPelajaran> createState() => _LayarPemutarPelajaranState();
}

class _LayarPemutarPelajaranState extends ConsumerState<LayarPemutarPelajaran> {
  PelajaranKonten? _pelajaran;
  bool _memuat = true;
  String? _galat;

  int _indeksLangkah = 0;
  final PageController _pageController = PageController();

  // State kuis Cek Paham per soal: indeksSoal -> jawabanDipilih
  final Map<int, int> _jawabanCekPaham = {};

  // State misi
  bool _misiDilewati = false;
  bool _misiTerverifikasi = false;

  @override
  void initState() {
    super.initState();
    _muatKontenPelajaran();
  }

  Future<void> _muatKontenPelajaran() async {
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

      // Ambil progres langkah terakhir yang tersimpan
      final progresRepo = ref.read(penyediaProgresRepositori);
      final progresLama = await progresRepo.ambilProgresPelajaran(widget.pelajaranId);

      var langkahAwal = 0;
      if (progresLama != null && progresLama.status != 'selesai') {
        langkahAwal = progresLama.indeksLangkah;
      }

      if (mounted) {
        setState(() {
          _pelajaran = pel;
          _indeksLangkah = langkahAwal;
          _memuat = false;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_pageController.hasClients && langkahAwal > 0) {
            _pageController.jumpToPage(langkahAwal);
          }
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
    _pageController.dispose();
    super.dispose();
  }

  // Menghitung total kartu/langkah dalam pelajaran ini:
  // 1 (Pemantik) + N (Kartu Konsep) + 1 (Contoh Angka) + 1 (Cek Paham) + 1 (Misi) + 1 (Umpan Balik) + (Tindak Lanjut jika ada ? 1 : 0)
  int _hitungTotalLangkah() {
    if (_pelajaran == null) return 1;
    var total = 1; // Pemantik
    total += _pelajaran!.kartu.length; // Kartu konsep
    total += 1; // Contoh Angka
    total += 1; // Cek Paham
    total += 1; // Misi
    total += 1; // Umpan Balik
    if (_pelajaran!.tindakLanjut != null && _pelajaran!.tindakLanjut!.isNotEmpty) {
      total += 1; // Tindak Lanjut
    }
    return total;
  }

  Future<void> _lanjutkanKeLangkahBerikutnya() async {
    final total = _hitungTotalLangkah();
    final langkahBerikutnya = _indeksLangkah + 1;

    if (langkahBerikutnya < total) {
      final kurangiGerakan = MediaQuery.of(context).disableAnimations;
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
      await ref.read(penyediaProgresRepositori).simpanProgresLangkah(
            pelajaranId: widget.pelajaranId,
            modulId: widget.modulId,
            indeksLangkah: langkahBerikutnya,
          );
      ref.invalidate(penyediaFotoData);
    } else {
      // Pelajaran Selesai!
      await ref.read(penyediaProgresRepositori).tandaiPelajaranSelesai(
            pelajaranId: widget.pelajaranId,
            modulId: widget.modulId,
          );
      ref.invalidate(penyediaFotoData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: WarnaFunda.pemasukan,
            content: TeksFunda.label('Pelajaran selesai! Kamu selangkah lebih dekat menguasai uangmu.', warna: Colors.white),
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_memuat) {
      return const Scaffold(
        backgroundColor: WarnaFunda.latar,
        body: Center(child: CircularProgressIndicator(color: WarnaFunda.utama)),
      );
    }

    if (_galat != null || _pelajaran == null) {
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
    final fotoData = ref.watch(penyediaFotoData).value ?? FotoDataPengguna.kosong();

    return Scaffold(
      backgroundColor: WarnaFunda.latar,
      body: SafeArea(
        child: Column(
          children: [
            // Header: Tombol Kembali + Penanda Kemajuan + Lencana Draf
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
                    tooltip: 'Kembali',
                  ),
                  const SizedBox(width: SpasiFunda.xs),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(SudutFunda.pil),
                      child: LinearProgressIndicator(
                        value: (totalLangkah > 0) ? (_indeksLangkah + 1) / totalLangkah : 0.0,
                        backgroundColor: WarnaFunda.garis,
                        valueColor: const AlwaysStoppedAnimation<Color>(WarnaFunda.utama),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: SpasiFunda.m),
                  TeksFunda.catatan(
                    '${_indeksLangkah + 1}/$totalLangkah',
                    warna: WarnaFunda.teksRedup,
                  ),
                  if (kDebugMode && pel.status == 'draf') ...[
                    const SizedBox(width: SpasiFunda.s),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: WarnaFunda.tintAmber,
                        borderRadius: BorderRadius.circular(SudutFunda.pil),
                      ),
                      child: const TeksFunda.catatan('Draf', warna: WarnaFunda.peringatan),
                    ),
                  ],
                ],
              ),
            ),

            // PageView untuk Kartu-Kartu Pelajaran
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Wajib tombol lanjut
                children: _bangunDaftarKartu(pel, fotoData),
              ),
            ),

            // Tombol Aksi Lanjut di Bagian Bawah
            Padding(
              padding: const EdgeInsets.all(SpasiFunda.m),
              child: SizedBox(
                width: double.infinity,
                child: TombolFunda(
                  teks: _indeksLangkah == totalLangkah - 1 ? 'Selesai Belajar' : 'Lanjut',
                  lebarPenuh: true,
                  padaTekan: _cekApakahBisaLanjut(pel, fotoData) ? _lanjutkanKeLangkahBerikutnya : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _cekApakahBisaLanjut(PelajaranKonten pel, FotoDataPengguna fotoData) {
    // Pada langkah Cek Paham, pengguna harus menjawab semua soal
    final indeksCekPaham = 1 + pel.kartu.length + 1;
    if (_indeksLangkah == indeksCekPaham) {
      return _jawabanCekPaham.length >= pel.cekPaham.length;
    }

    // Pada langkah Misi, misi harus sudah terverifikasi selesai atau dilewati
    final indeksMisi = indeksCekPaham + 1;
    if (_indeksLangkah == indeksMisi) {
      if (_misiDilewati) return true;
      final evalMisi = RegistriMisi.evaluasi(misi: pel.misi, fotoData: fotoData);
      return evalMisi.selesai || _misiTerverifikasi;
    }

    return true;
  }

  List<Widget> _bangunDaftarKartu(PelajaranKonten pel, FotoDataPengguna fotoData) {
    final kartuWidgets = <Widget>[];

    // 1. Pemantik
    kartuWidgets.add(
      _pembungkusKartu(
        tag: 'Pemantik',
        judul: pel.judul,
        isi: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(SpasiFunda.l),
              decoration: BoxDecoration(
                color: WarnaFunda.utamaTipis,
                borderRadius: BorderRadius.circular(SudutFunda.kartu),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(LucideIcons.sparkles, color: WarnaFunda.utama, size: 24),
                  const SizedBox(width: SpasiFunda.m),
                  Expanded(
                    child: TeksFunda.isi(pel.pemantik),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SpasiFunda.l),
            const TeksFunda.isiKecil(
              'Mari kita bedah pelan-pelan melalui kartu konsep berikut ini.',
              warna: WarnaFunda.teksRedup,
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
          tag: 'Konsep Inti (${i + 1}/${pel.kartu.length})',
          judul: k.judul,
          isi: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TeksDenganIstilah(teks: k.isi),
            ],
          ),
        ),
      );
    }

    // 3. Contoh Angka Konkret
    kartuWidgets.add(
      _pembungkusKartu(
        tag: 'Contoh Nyata',
        judul: 'Gambaran Angka',
        isi: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(SpasiFunda.l),
              decoration: BoxDecoration(
                color: WarnaFunda.tintNetral,
                borderRadius: BorderRadius.circular(SudutFunda.kartu),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TeksFunda.catatan('Contoh nominal ilustrasi:', warna: WarnaFunda.teksRedup),
                  const SizedBox(height: SpasiFunda.s),
                  TeksFunda.judulBagian(formatRupiah(pel.contohAngka)),
                  const SizedBox(height: SpasiFunda.s),
                  const TeksFunda.isiKecil(
                    'Melihat angka nyata membuat gambaran keuangan jauh lebih jelas daripada sekadar teori angka abstrak.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    // 4. Cek Paham (Soal Singkat)
    kartuWidgets.add(
      _pembungkusKartu(
        tag: 'Cek Paham',
        judul: 'Uji Pemahaman Singkat',
        isi: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...pel.cekPaham.asMap().entries.map((entry) {
              final idx = entry.key;
              final soal = entry.value;
              final jawabanDipilih = _jawabanCekPaham[idx];
              final sudahDijawab = jawabanDipilih != null;

              return Container(
                margin: const EdgeInsets.only(bottom: SpasiFunda.l),
                padding: const EdgeInsets.all(SpasiFunda.m),
                decoration: BoxDecoration(
                  color: WarnaFunda.permukaan,
                  borderRadius: BorderRadius.circular(SudutFunda.kartu),
                  border: Border.all(color: WarnaFunda.garis),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TeksFunda.label('${idx + 1}. ${soal.tanya}'),
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

                      return GestureDetector(
                        onTap: sudahDijawab
                            ? null
                            : () {
                                setState(() {
                                  _jawabanCekPaham[idx] = pIdx;
                                });
                              },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: SpasiFunda.s),
                          padding: const EdgeInsets.symmetric(horizontal: SpasiFunda.m, vertical: SpasiFunda.s),
                          decoration: BoxDecoration(
                            color: latarPilihan,
                            borderRadius: BorderRadius.circular(SudutFunda.kecil),
                            border: Border.all(color: borderPilihan),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected ? LucideIcons.checkCircle2 : LucideIcons.circle,
                                size: 18,
                                color: isSelected ? WarnaFunda.utama : WarnaFunda.teksRedup,
                              ),
                              const SizedBox(width: SpasiFunda.s),
                              Expanded(child: TeksFunda.isiKecil(teksPilihan)),
                            ],
                          ),
                        ),
                      );
                    }),
                    if (sudahDijawab) ...[
                      const SizedBox(height: SpasiFunda.s),
                      Container(
                        padding: const EdgeInsets.all(SpasiFunda.s),
                        decoration: BoxDecoration(
                          color: jawabanDipilih == soal.benar ? WarnaFunda.tintHijau : WarnaFunda.tintAmber,
                          borderRadius: BorderRadius.circular(SudutFunda.kecil),
                        ),
                        child: TeksFunda.catatan(soal.penjelasan),
                      ),
                    ],
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );

    // 5. Kartu Misi Praktik
    kartuWidgets.add(_bangunKartuMisiPraktik(pel.misi, fotoData));

    // 6. Umpan Balik
    kartuWidgets.add(_bangunKartuUmpanBalik(pel.misi));

    // 7. Tindak Lanjut (bila ada)
    if (pel.tindakLanjut != null && pel.tindakLanjut!.isNotEmpty) {
      kartuWidgets.add(
        _pembungkusKartu(
          tag: 'Tindak Lanjut',
          judul: 'Langkah Kecil Berikutnya',
          isi: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(SpasiFunda.l),
                decoration: BoxDecoration(
                  color: WarnaFunda.utamaTipis,
                  borderRadius: BorderRadius.circular(SudutFunda.kartu),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(LucideIcons.lightbulb, color: WarnaFunda.utama, size: 24),
                    const SizedBox(width: SpasiFunda.m),
                    Expanded(child: TeksFunda.isi(pel.tindakLanjut!)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return kartuWidgets;
  }

  Widget _bangunKartuMisiPraktik(MisiKonten misi, FotoDataPengguna fotoData) {
    final evalMisi = RegistriMisi.evaluasi(misi: misi, fotoData: fotoData);
    final sudahSelesai = evalMisi.selesai || _misiTerverifikasi;

    return _pembungkusKartu(
      tag: 'Misi Praktik Nyata',
      judul: misi.judul,
      isi: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TeksFunda.isi(misi.deskripsi),
          const SizedBox(height: SpasiFunda.m),
          Row(
            children: [
              const Icon(LucideIcons.timer, size: 16, color: WarnaFunda.teksRedup),
              const SizedBox(width: SpasiFunda.xs),
              Expanded(
                child: TeksFunda.catatan('Perkiraan waktu: ${misi.perkiraanMenit} menit', warna: WarnaFunda.teksRedup),
              ),
            ],
          ),
          const SizedBox(height: SpasiFunda.l),

          // Status Verifikasi Misi
          Container(
            padding: const EdgeInsets.all(SpasiFunda.m),
            decoration: BoxDecoration(
              color: sudahSelesai ? WarnaFunda.tintHijau : (_misiDilewati ? WarnaFunda.tintNetral : WarnaFunda.tintAmber),
              borderRadius: BorderRadius.circular(SudutFunda.kartu),
            ),
            child: Row(
              children: [
                Icon(
                  sudahSelesai ? LucideIcons.checkCircle : (_misiDilewati ? LucideIcons.forward : LucideIcons.alertCircle),
                  color: sudahSelesai ? WarnaFunda.pemasukan : (_misiDilewati ? WarnaFunda.teksRedup : WarnaFunda.peringatan),
                ),
                const SizedBox(width: SpasiFunda.s),
                Expanded(
                  child: TeksFunda.label(
                    _misiDilewati ? 'Misi ini kamu lewati.' : evalMisi.statusTeks,
                    warna: sudahSelesai ? WarnaFunda.pemasukan : WarnaFunda.teks,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: SpasiFunda.l),

          // Tombol-tombol aksi Misi
          if (!sudahSelesai && !_misiDilewati) ...[
            TombolFunda(
              teks: 'Kerjakan Sekarang',
              lebarPenuh: true,
              padaTekan: () {
                final rute = ambilRutePengisianObjek(misi.objek) ?? '/catatan';
                context.push(rute);
              },
            ),
            const SizedBox(height: SpasiFunda.s),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  side: const BorderSide(color: WarnaFunda.garis),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SudutFunda.pil)),
                ),
                onPressed: () {
                  ref.invalidate(penyediaFotoData);
                  setState(() {
                    if (evalMisi.selesai) {
                      _misiTerverifikasi = true;
                    }
                  });
                },
                child: const TeksFunda.catatan('Periksa Misi'),
              ),
            ),
            const SizedBox(height: SpasiFunda.xs),
            Center(
              child: TextButton(
                style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                onPressed: () async {
                  setState(() {
                    _misiDilewati = true;
                  });
                  await ref.read(penyediaHasilMisiRepositori).simpanHasilMisi(
                        misiId: widget.pelajaranId,
                        pelajaranId: widget.pelajaranId,
                        tipe: misi.tipe,
                        status: 'dilewati',
                      );
                },
                child: const TeksFunda.catatan('Belum relevan buat aku', warna: WarnaFunda.teksRedup),
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
                    child: TeksFunda.label('Luar biasa! Misi berhasil diselesaikan.', warna: WarnaFunda.pemasukan),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _bangunKartuUmpanBalik(MisiKonten misi) {
    final arusKas = ref.watch(penyediaArusKasBulanIni);
    final pengeluaranPerSifat = ref.watch(penyediaKomposisiSifatBulanIni).value ??
        const {
          'kebutuhan': 0,
          'keinginan': 0,
          'tabungan': 0,
          'utang': 0,
          'belum_dilabeli': 0,
        };

    final persenSifat = hitungKomposisiSifat(pengeluaranPerSifat);

    String teksUmpanBalik;
    if (misi.umpanBalik == 'komposisi_sifat_bulan_ini') {
      teksUmpanBalik = RegistriUmpanBalik.formatKomposisiSifat(persenSifat);
    } else {
      teksUmpanBalik = RegistriUmpanBalik.formatArusKasBulanIni(arusKas);
    }

    return _pembungkusKartu(
      tag: 'Umpan Balik Nyata',
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
                      child: const Icon(LucideIcons.barChart2, color: WarnaFunda.utama, size: 20),
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
    required String tag,
    required String judul,
    required Widget isi,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: SpasiFunda.marginLayar),
      child: Container(
        margin: const EdgeInsets.only(top: SpasiFunda.s),
        padding: const EdgeInsets.all(SpasiFunda.l),
        decoration: BoxDecoration(
          color: WarnaFunda.permukaan,
          borderRadius: BorderRadius.circular(SudutFunda.petak),
          border: Border.all(color: WarnaFunda.garis),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: SpasiFunda.s, vertical: SpasiFunda.xs),
              decoration: BoxDecoration(
                color: WarnaFunda.utamaTipis,
                borderRadius: BorderRadius.circular(SudutFunda.pil),
              ),
              child: TeksFunda.catatan(tag, warna: WarnaFunda.utama),
            ),
            const SizedBox(height: SpasiFunda.m),
            TeksFunda.judulLayar(judul),
            const SizedBox(height: SpasiFunda.m),
            isi,
            const SizedBox(height: SpasiFunda.m),
          ],
        ),
      ),
    );
  }
}
