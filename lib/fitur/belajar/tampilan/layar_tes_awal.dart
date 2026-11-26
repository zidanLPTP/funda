import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/penyedia_data.dart';
import '../../../komponen/komponen_funda.dart';
import '../../../perhitungan/perhitungan_tes_awal_personalisasi.dart';
import '../../../tema/token.dart';
import '../../../util/haptic.dart';
import '../kontroler/penyedia_belajar.dart';
import '../model/pembaca_konten.dart';

/// Layar alur tes awal dan pembentukan profil keuangan (Modul 0).
class LayarTesAwal extends ConsumerStatefulWidget {
  const LayarTesAwal({super.key});

  @override
  ConsumerState<LayarTesAwal> createState() => _LayarTesAwalState();
}

enum TahapTesAwal {
  pembuka,
  profil,
  transisiProfil,
  soal,
  animasiSelesai,
  hasil,
}

class _LayarTesAwalState extends ConsumerState<LayarTesAwal> {
  TahapTesAwal _tahap = TahapTesAwal.pembuka;
  KontenTesAwal? _konten;
  bool _memuat = true;
  String? _galat;

  // State Form Profil
  final TextEditingController _kontrolerTujuan = TextEditingController();
  final Map<String, String> _jawabanProfil = {};
  int _indeksPertanyaanProfil = 0;

  // State Soal Tes Awal
  final Map<String, int> _jawabanSoal = {};
  int _indeksSoal = 0;

  // State Hasil
  HasilSkorTesAwal? _hasilSkor;
  bool _sedangMenyimpan = false;

  @override
  void initState() {
    super.initState();
    _muatKonten();
  }

  @override
  void dispose() {
    _kontrolerTujuan.dispose();
    super.dispose();
  }

  Future<void> _muatKonten() async {
    try {
      final k = await ref.read(penyediaKontenTesAwal.future);
      if (mounted) {
        setState(() {
          _konten = k;
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

  Future<void> _lewatiTesAwal() async {
    // Simpan pernyataan profil_dilewati: 'true' agar gerbang Modul 1 terbuka
    await ref
        .read(penyediaPernyataanRepositori)
        .simpanPernyataan('profil_dilewati', 'true');
    ref.invalidate(penyediaFotoData);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tes awal dilewati. Kamu bisa mengisinya kapan saja di Tab Belajar.',
          ),
        ),
      );
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        try {
          context.go('/belajar');
        } catch (_) {}
      }
    }
  }

  Future<void> _selesaikanTesAwal() async {
    if (_konten == null) return;
    setState(() => _sedangMenyimpan = true);

    final hasil = hitungSkorTesAwal(
      jawabanPengguna: _jawabanSoal,
      daftarSoal: _konten!.soalTesAwal,
    );

    final profil = bangunProfil(
      jawabanProfil: _jawabanProfil,
      tujuanUtama: _kontrolerTujuan.text,
    );

    // Simpan ke database
    await ref
        .read(penyediaProfilRepositori)
        .simpanProfil(
          punyaPenghasilan: profil.punyaPenghasilan,
          punyaUtang: profil.punyaUtang,
          danaDarurat: profil.danaDarurat,
          menabung: profil.menabung,
          investasi: profil.investasi,
          mencatatKeuangan: profil.mencatatKeuangan,
          tujuanUtama: profil.tujuanUtama,
        );

    await ref
        .read(penyediaTesAwalRepositori)
        .simpanHasilTesAwal(
          jawaban: _jawabanSoal,
          skorPerModul: hasil.skorPerModul,
          skorTotalPersen: hasil.skorTotalPersen,
        );

    // Invalidate state terkait
    ref.invalidate(penyediaFotoData);
    ref.invalidate(penyediaPetaBelajar);
    ref.invalidate(penyediaDaftarRekomendasiModul);
    ref.invalidate(penyediaLanjutBelajarBeranda);

    if (mounted) {
      UtilHaptic.suksesBesar();
      setState(() {
        _hasilSkor = hasil;
        _sedangMenyimpan = false;
        _tahap = TahapTesAwal.animasiSelesai;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_memuat) {
      return const Scaffold(body: Center(child: IndikatorMemuat()));
    }

    if (_galat != null || _konten == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tes Awal')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(SpasiFunda.marginLayar),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const IkonUiFunda(
                  pathAset: AsetIkonUiFunda.triangleAlert,
                  ukuran: 48,
                  warna: WarnaFunda.peringatan,
                ),
                const SizedBox(height: SpasiFunda.m),
                TeksFunda.judulBagian('Gagal Memuat Tes Awal'),
                const SizedBox(height: SpasiFunda.s),
                TeksFunda.isi(_galat ?? 'Terjadi kesalahan sistem.'),
                const SizedBox(height: SpasiFunda.l),
                TombolFunda(
                  teks: 'Coba Lagi',
                  padaTekan: () {
                    setState(() {
                      _memuat = true;
                      _galat = null;
                    });
                    _muatKonten();
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    switch (_tahap) {
      case TahapTesAwal.pembuka:
        return _bangunTampilanPembuka();
      case TahapTesAwal.profil:
        return _bangunTampilanProfil();
      case TahapTesAwal.transisiProfil:
        return _bangunTampilanTransisiProfil();
      case TahapTesAwal.soal:
        return _bangunTampilanSoal();
      case TahapTesAwal.animasiSelesai:
        return _bangunTampilanAnimasiSelesai();
      case TahapTesAwal.hasil:
        return _bangunTampilanHasil();
    }
  }

  Widget _bangunTampilanPembuka() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mulai & Tes Awal'),
        actions: [
          TextButton(onPressed: _lewatiTesAwal, child: const Text('Lewati')),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(SpasiFunda.marginLayar),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(SpasiFunda.m),
                        decoration: BoxDecoration(
                          color: WarnaFunda.utamaTipis,
                          borderRadius: BorderRadius.circular(SudutFunda.kartu),
                        ),
                        child: const Row(
                          children: [
                            IkonSvgFunda(
                              pathAset: AsetIkonFunda.tesAwal,
                              ukuran: 28,
                            ),
                            SizedBox(width: SpasiFunda.m),
                            Expanded(
                              child: Text(
                                'Kenali situasi finansialmu tanpa rasa cemas.',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: WarnaFunda.utama,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: SpasiFunda.l),
                      TeksFunda.judulBagian(_konten!.judul),
                      const SizedBox(height: SpasiFunda.s),
                      TeksFunda.isi(_konten!.deskripsi),
                      const SizedBox(height: SpasiFunda.l),
                      TeksFunda.label('Yang akan kita lakukan:'),
                      const SizedBox(height: SpasiFunda.s),
                      _itemLangkah(
                        '1',
                        '6 pertanyaan kondisi finansialmu saat ini',
                      ),
                      _itemLangkah(
                        '2',
                        '12 pertanyaan kuis ringkas pemahaman dasar',
                      ),
                      _itemLangkah(
                        '3',
                        'Rekomendasi topik belajar yang paling relevan',
                      ),
                      const SizedBox(height: SpasiFunda.l),
                      TeksFunda.label(_konten!.tujuanUtama.tanya),
                      const SizedBox(height: SpasiFunda.xs),
                      TeksFunda.catatan(_konten!.tujuanUtama.petunjuk),
                      const SizedBox(height: SpasiFunda.s),
                      TextField(
                        controller: _kontrolerTujuan,
                        maxLength: _konten!.tujuanUtama.maksimalKarakter,
                        decoration: InputDecoration(
                          hintText: 'Tuliskan sasaran utamamu (opsional)...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              SudutFunda.kartu,
                            ),
                          ),
                          filled: true,
                          fillColor: WarnaFunda.permukaan,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: SpasiFunda.m),
              TombolFunda(
                teks: 'Mulai Sekarang',
                lebarPenuh: true,
                padaTekan: () {
                  setState(() {
                    _indeksPertanyaanProfil = 0;
                    _tahap = TahapTesAwal.profil;
                  });
                },
              ),
              const SizedBox(height: SpasiFunda.s),
              Center(
                child: TextButton(
                  onPressed: _lewatiTesAwal,
                  child: const Text('Belum siap? Lewati tes dulu'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _itemLangkah(String nomor, String teks) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SpasiFunda.s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: WarnaFunda.garis,
            child: Text(
              nomor,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: WarnaFunda.teks,
              ),
            ),
          ),
          const SizedBox(width: SpasiFunda.s),
          Expanded(child: TeksFunda.isi(teks)),
        ],
      ),
    );
  }

  Widget _bangunTampilanProfil() {
    final daftarPertanyaan = _konten!.pertanyaanProfil;
    final pertanyaan = daftarPertanyaan[_indeksPertanyaanProfil];
    final nilaiTerpilih = _jawabanProfil[pertanyaan.kunci];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profil (${_indeksPertanyaanProfil + 1}/${daftarPertanyaan.length})',
        ),
        leading: IconButton(
          icon: const IkonUiFunda(
            pathAset: AsetIkonUiFunda.arrowLeft,
            ukuran: 24,
          ),
          onPressed: () {
            if (_indeksPertanyaanProfil > 0) {
              setState(() => _indeksPertanyaanProfil--);
            } else {
              setState(() => _tahap = TahapTesAwal.pembuka);
            }
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(SpasiFunda.marginLayar),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IndikatorMemuat.garis(
                nilai: (_indeksPertanyaanProfil + 1) / daftarPertanyaan.length,
                warnaLatar: WarnaFunda.garis,
                warna: WarnaFunda.utama,
              ),
              const SizedBox(height: SpasiFunda.l),
              TeksFunda.judulBagian(pertanyaan.tanya),
              const SizedBox(height: SpasiFunda.l),
              Expanded(
                child: ListView.separated(
                  itemCount: pertanyaan.pilihan.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: SpasiFunda.s),
                  itemBuilder: (context, idx) {
                    final pil = pertanyaan.pilihan[idx];
                    final terpilih = nilaiTerpilih == pil.nilai;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _jawabanProfil[pertanyaan.kunci] = pil.nilai;
                        });
                      },
                      borderRadius: BorderRadius.circular(SudutFunda.kartu),
                      child: Container(
                        padding: const EdgeInsets.all(SpasiFunda.m),
                        decoration: BoxDecoration(
                          color: terpilih
                              ? WarnaFunda.utamaTipis
                              : WarnaFunda.permukaan,
                          border: Border.all(
                            color: terpilih
                                ? WarnaFunda.utama
                                : WarnaFunda.garis,
                            width: terpilih ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(SudutFunda.kartu),
                        ),
                        child: Row(
                          children: [
                            IkonUiFunda(
                              pathAset: terpilih
                                  ? AsetIkonUiFunda.circleCheck
                                  : AsetIkonUiFunda.circle,
                              warna: terpilih
                                  ? WarnaFunda.utama
                                  : WarnaFunda.teksRedup,
                              ukuran: 24,
                            ),
                            const SizedBox(width: SpasiFunda.m),
                            Expanded(child: TeksFunda.isi(pil.teks)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              TombolFunda(
                teks: _indeksPertanyaanProfil == daftarPertanyaan.length - 1
                    ? 'Lanjut ke Tes Pemahaman'
                    : 'Pertanyaan Berikutnya',
                lebarPenuh: true,
                padaTekan: nilaiTerpilih == null
                    ? null
                    : () {
                        if (_indeksPertanyaanProfil <
                            daftarPertanyaan.length - 1) {
                          setState(() => _indeksPertanyaanProfil++);
                        } else {
                          UtilHaptic.sukses();
                          setState(() {
                            _tahap = TahapTesAwal.transisiProfil;
                          });
                        }
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bangunTampilanTransisiProfil() {
    final tanpaAnimasi =
        MediaQuery.disableAnimationsOf(context) ||
        ref.watch(penyediaTanpaAnimasi);
    final durasi = tanpaAnimasi
        ? Duration.zero
        : const Duration(milliseconds: 350);

    return Scaffold(
      backgroundColor: WarnaFunda.latar,
      appBar: AppBar(
        title: const Text('Profil Keuangan'),
        leading: IconButton(
          icon: const IkonUiFunda(
            pathAset: AsetIkonUiFunda.arrowLeft,
            ukuran: 24,
          ),
          onPressed: () {
            setState(() {
              _indeksPertanyaanProfil = _konten!.pertanyaanProfil.length - 1;
              _tahap = TahapTesAwal.profil;
            });
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(SpasiFunda.marginLayar),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: tanpaAnimasi ? 1.0 : 0.9, end: 1.0),
                      duration: durasi,
                      curve: Curves.easeOutBack,
                      builder: (context, nilai, child) {
                        return Opacity(
                          opacity: nilai.clamp(0.0, 1.0),
                          child: Transform.scale(scale: nilai, child: child),
                        );
                      },
                      child: PetakBento.ukuran2x1(
                        tint: TintPetakBento.putih,
                        anak: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: WarnaFunda.tintHijau,
                                borderRadius: BorderRadius.circular(
                                  SudutFunda.petak,
                                ),
                                border: Border.all(
                                  color: WarnaFunda.batasHijau,
                                ),
                              ),
                              child: const IkonSvgFunda(
                                pathAset: AsetIkonFunda.pengaturanProfil,
                                ukuran: 38,
                              ),
                            ),
                            const SizedBox(height: SpasiFunda.l),
                            const TeksFunda.judulLayar(
                              'Profil Keuanganmu Tersimpan!',
                              rataTeks: TextAlign.center,
                            ),
                            const SizedBox(height: SpasiFunda.m),
                            const TeksFunda.isi(
                              'Sekarang lanjut ke 12 pertanyaan singkat untuk memetakan pemahamanmu. Jawab santai saja nggak perlu takut salah, ada opsi "Belum tahu" bila masih ragu.',
                              warna: WarnaFunda.teksRedup,
                              rataTeks: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: SpasiFunda.m),
              TombolFunda.primer(
                key: const Key('tombol_mulai_soal_tes_awal'),
                lebarPenuh: true,
                teks: 'Mulai 12 Pertanyaan',
                padaTekan: () {
                  UtilHaptic.pilih();
                  setState(() {
                    _indeksSoal = 0;
                    _tahap = TahapTesAwal.soal;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bangunTampilanAnimasiSelesai() {
    final tanpaAnimasi =
        MediaQuery.disableAnimationsOf(context) ||
        ref.watch(penyediaTanpaAnimasi);
    final durasi = tanpaAnimasi
        ? Duration.zero
        : const Duration(milliseconds: 420);

    return Scaffold(
      backgroundColor: WarnaFunda.latar,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(SpasiFunda.marginLayar),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: tanpaAnimasi ? 1.0 : 0.84, end: 1.0),
                      duration: durasi,
                      curve: Curves.easeOutBack,
                      builder: (context, nilai, child) {
                        return Opacity(
                          opacity: nilai.clamp(0.0, 1.0),
                          child: Transform.scale(scale: nilai, child: child),
                        );
                      },
                      child: PetakBento.ukuran2x1(
                        tint: TintPetakBento.hijau,
                        anak: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: const BoxDecoration(
                                color: WarnaFunda.permukaan,
                                shape: BoxShape.circle,
                              ),
                              child: const IkonUiFunda(
                                pathAset: AsetIkonUiFunda.circleCheck,
                                ukuran: 44,
                                warna: WarnaFunda.pemasukan,
                              ),
                            ),
                            const SizedBox(height: SpasiFunda.l),
                            const TeksFunda.judulLayar(
                              'Tes Awal Selesai!',
                              rataTeks: TextAlign.center,
                            ),
                            const SizedBox(height: SpasiFunda.m),
                            const TeksFunda.isi(
                              'Terima kasih sudah meluangkan waktu. Rekomendasi belajar yang sesuai dengan kondisimu sudah siap dilihat.',
                              warna: WarnaFunda.teksRedup,
                              rataTeks: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: SpasiFunda.m),
              TombolFunda.primer(
                key: const Key('tombol_lihat_rekomendasi_tes_awal'),
                lebarPenuh: true,
                teks: 'Lihat Rekomendasi',
                padaTekan: () {
                  UtilHaptic.pilih();
                  setState(() {
                    _tahap = TahapTesAwal.hasil;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bangunTampilanSoal() {
    final daftarSoal = _konten!.soalTesAwal;
    final soal = daftarSoal[_indeksSoal];
    final jawabanDipilih = _jawabanSoal[soal.id];

    return Scaffold(
      appBar: AppBar(
        title: Text('Tes Awal (${_indeksSoal + 1}/${daftarSoal.length})'),
        leading: IconButton(
          icon: const IkonUiFunda(
            pathAset: AsetIkonUiFunda.arrowLeft,
            ukuran: 24,
          ),
          onPressed: () {
            if (_indeksSoal > 0) {
              setState(() => _indeksSoal--);
            } else {
              setState(() {
                _indeksPertanyaanProfil = _konten!.pertanyaanProfil.length - 1;
                _tahap = TahapTesAwal.profil;
              });
            }
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(SpasiFunda.marginLayar),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IndikatorMemuat.garis(
                nilai: (_indeksSoal + 1) / daftarSoal.length,
                warnaLatar: WarnaFunda.garis,
                warna: WarnaFunda.utama,
              ),
              const SizedBox(height: SpasiFunda.l),
              TeksFunda.judulBagian(soal.tanya),
              const SizedBox(height: SpasiFunda.l),
              Expanded(
                child: ListView.separated(
                  itemCount: soal.pilihan.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: SpasiFunda.s),
                  itemBuilder: (context, idx) {
                    final teksPilihan = soal.pilihan[idx];
                    final terpilih = jawabanDipilih == idx;
                    final apakahBelumTahu = idx == 3;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          _jawabanSoal[soal.id] = idx;
                        });
                      },
                      borderRadius: BorderRadius.circular(SudutFunda.kartu),
                      child: Container(
                        padding: const EdgeInsets.all(SpasiFunda.m),
                        decoration: BoxDecoration(
                          color: terpilih
                              ? (apakahBelumTahu
                                    ? WarnaFunda.tintNetral
                                    : WarnaFunda.utamaTipis)
                              : WarnaFunda.permukaan,
                          border: Border.all(
                            color: terpilih
                                ? (apakahBelumTahu
                                      ? WarnaFunda.teksRedup
                                      : WarnaFunda.utama)
                                : WarnaFunda.garis,
                            width: terpilih ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(SudutFunda.kartu),
                        ),
                        child: Row(
                          children: [
                            IkonUiFunda(
                              pathAset: terpilih
                                  ? AsetIkonUiFunda.circleCheck
                                  : AsetIkonUiFunda.circle,
                              warna: terpilih
                                  ? (apakahBelumTahu
                                        ? WarnaFunda.teksRedup
                                        : WarnaFunda.utama)
                                  : WarnaFunda.teksRedup,
                              ukuran: 24,
                            ),
                            const SizedBox(width: SpasiFunda.m),
                            Expanded(
                              child: Text(
                                teksPilihan,
                                style: TextStyle(
                                  color: apakahBelumTahu
                                      ? WarnaFunda.teksRedup
                                      : WarnaFunda.teks,
                                  fontStyle: apakahBelumTahu
                                      ? FontStyle.italic
                                      : FontStyle.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              TombolFunda(
                teks: _indeksSoal == daftarSoal.length - 1
                    ? (_sedangMenyimpan ? 'Menyimpan...' : 'Lihat Hasil')
                    : 'Soal Berikutnya',
                lebarPenuh: true,
                padaTekan: jawabanDipilih == null || _sedangMenyimpan
                    ? null
                    : () {
                        if (_indeksSoal < daftarSoal.length - 1) {
                          setState(() => _indeksSoal++);
                        } else {
                          _selesaikanTesAwal();
                        }
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bangunTampilanHasil() {
    final hasil = _hasilSkor;
    if (hasil == null) return const SizedBox();

    final asyncRekomendasi = ref.watch(penyediaDaftarRekomendasiModul);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Tes Awal'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(SpasiFunda.marginLayar),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(SpasiFunda.l),
                        decoration: BoxDecoration(
                          color: WarnaFunda.utamaTipis,
                          borderRadius: BorderRadius.circular(SudutFunda.kartu),
                        ),
                        child: Column(
                          children: [
                            const IkonUiFunda(
                              pathAset: AsetIkonUiFunda.circleCheck,
                              warna: WarnaFunda.utama,
                              ukuran: 40,
                            ),
                            const SizedBox(height: SpasiFunda.s),
                            TeksFunda.judulBagian('Profil Berhasil Dibentuk'),
                            const SizedBox(height: SpasiFunda.xs),
                            TeksFunda.catatan(
                              'Skor pemahaman awalmu: ${hasil.skorTotalPersen}% (${hasil.totalBenar}/${hasil.totalSoal} benar).',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: SpasiFunda.l),
                      TeksFunda.label('Rekomendasi Belajar Untukmu'),
                      const SizedBox(height: SpasiFunda.s),
                      asyncRekomendasi.when(
                        data: (daftar) {
                          if (daftar.isEmpty) {
                            return const Text('Belum ada rekomendasi.');
                          }
                          return Column(
                            children: daftar.map((rek) {
                              return Card(
                                margin: const EdgeInsets.only(
                                  bottom: SpasiFunda.m,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    SudutFunda.kartu,
                                  ),
                                  side: const BorderSide(
                                    color: WarnaFunda.garis,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(SpasiFunda.m),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: WarnaFunda.tintHijau,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    SudutFunda.kecil,
                                                  ),
                                            ),
                                            child: const IkonSvgFunda(
                                              pathAset: AsetIkonFunda.tesAwal,
                                              ukuran: 20,
                                            ),
                                          ),
                                          const SizedBox(width: SpasiFunda.s),
                                          Expanded(
                                            child: TeksFunda.label(
                                              rek.judulAlasan,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: SpasiFunda.xs),
                                      TeksFunda.judulBagian(rek.modul.judul),
                                      const SizedBox(height: SpasiFunda.xs),
                                      TeksFunda.isiKecil(rek.deskripsiAlasan),
                                      const SizedBox(height: SpasiFunda.m),
                                      TombolFunda(
                                        teks: 'Mulai Modul Ini',
                                        lebarPenuh: true,
                                        padaTekan: () {
                                          try {
                                            context.go('/belajar');
                                          } catch (_) {}
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                        loading: () => const Center(child: IndikatorMemuat()),
                        error: (err, stack) =>
                            const Text('Gagal memuat rekomendasi.'),
                      ),
                      const SizedBox(height: SpasiFunda.l),
                      TeksFunda.label('Skor Awal per Topik Pemula:'),
                      const SizedBox(height: SpasiFunda.s),
                      ...hasil.skorPerModul.entries.map((e) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: SpasiFunda.xs,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(e.key.replaceAll('_', ' ')),
                              Text(
                                '${e.value}%',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: SpasiFunda.m),
              TombolFunda(
                teks: 'Buka Peta Belajar',
                lebarPenuh: true,
                padaTekan: () {
                  try {
                    context.go('/belajar');
                  } catch (_) {}
                },
              ),
              const SizedBox(height: SpasiFunda.s),
              Center(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _indeksPertanyaanProfil = 0;
                      _indeksSoal = 0;
                      _jawabanProfil.clear();
                      _jawabanSoal.clear();
                      _tahap = TahapTesAwal.pembuka;
                    });
                  },
                  child: const Text('Ulangi Tes Awal'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
