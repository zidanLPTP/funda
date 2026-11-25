import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../data/basis_data.dart';
import '../../../data/model/jenis_transaksi.dart';
import '../../../data/model/sifat_kategori.dart';
import '../../../data/penyedia_data.dart';
import '../../../komponen/komponen_funda.dart';
import '../../../komponen/pembantu_ikon.dart';
import '../../../perhitungan/perhitungan_keuangan.dart';
import '../../../tema/token.dart';
import '../../../util/format_rupiah.dart';
import '../../dompet/tampilan/layar_form_dompet.dart';
import '../../transaksi/tampilan/layar_form_transaksi.dart';

/// Opsi pilihan rentang waktu untuk filter transaksi.
enum RentangWaktuFilter {
  semua('Semua Waktu'),
  hariIni('Hari Ini'),
  tujuhHari('7 Hari Terakhir'),
  bulanIni('Bulan Ini');

  const RentangWaktuFilter(this.label);
  final String label;
}

/// Keadaan konfigurasi filter pencarian transaksi.
class KondisiFilterTransaksi {
  const KondisiFilterTransaksi({
    this.jenis,
    this.dompetId,
    this.kategoriId,
    this.sifat,
    this.rentang = RentangWaktuFilter.semua,
  });

  final JenisTransaksi? jenis;
  final String? dompetId;
  final String? kategoriId;
  final SifatKategori? sifat;
  final RentangWaktuFilter rentang;

  int get jumlahFilterAktif {
    var count = 0;
    if (jenis != null) count++;
    if (dompetId != null) count++;
    if (kategoriId != null) count++;
    if (sifat != null) count++;
    if (rentang != RentangWaktuFilter.semua) count++;
    return count;
  }

  KondisiFilterTransaksi copyWith({
    JenisTransaksi? Function()? jenis,
    String? Function()? dompetId,
    String? Function()? kategoriId,
    SifatKategori? Function()? sifat,
    RentangWaktuFilter? rentang,
  }) {
    return KondisiFilterTransaksi(
      jenis: jenis != null ? jenis() : this.jenis,
      dompetId: dompetId != null ? dompetId() : this.dompetId,
      kategoriId: kategoriId != null ? kategoriId() : this.kategoriId,
      sifat: sifat != null ? sifat() : this.sifat,
      rentang: rentang ?? this.rentang,
    );
  }
}

/// Layar Tab Catatan Keuangan bergaya editorial bersih:
/// header ringkas + tombol pil gelap `+ Catat`, bilah cari & filter,
/// dan transaksi dikelompokkan per hari dalam satu kartu putih border 1px.
class LayarCatatan extends ConsumerStatefulWidget {
  const LayarCatatan({super.key});

  @override
  ConsumerState<LayarCatatan> createState() => _LayarCatatanState();
}

class _LayarCatatanState extends ConsumerState<LayarCatatan> {
  final _pengontrolCari = TextEditingController();
  final _pengontrolGulir = ScrollController();
  KondisiFilterTransaksi _filter = const KondisiFilterTransaksi();
  String _kataKunci = '';
  int _limit = 50;
  bool _sedangMemuatHalamanBerikutnya = false;

  @override
  void initState() {
    super.initState();
    _pengontrolGulir.addListener(_padaGulir);
  }

  void _padaGulir() {
    if (!_pengontrolGulir.hasClients) return;
    final posisi = _pengontrolGulir.position;
    // Cegah infinite loop jika list kosong atau pendek (maxScrollExtent <= 200)
    if (posisi.maxScrollExtent > 200 &&
        posisi.pixels >= posisi.maxScrollExtent - 200) {
      if (!_sedangMemuatHalamanBerikutnya && _limit < 10000) {
        _sedangMemuatHalamanBerikutnya = true;
        setState(() {
          _limit += 50;
        });
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _sedangMemuatHalamanBerikutnya = false;
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _pengontrolCari.dispose();
    _pengontrolGulir.dispose();
    super.dispose();
  }

  void _bukaFormCatat() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const LayarFormTransaksi()),
    );
  }

  void _bukaLembarFilter(
    List<EntitasDompet> daftarDompet,
    List<EntitasKategori> daftarKategori,
  ) {
    final tanpaAnimasi =
        MediaQuery.disableAnimationsOf(context) ||
        ref.read(penyediaTanpaAnimasi);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      sheetAnimationStyle: tanpaAnimasi ? AnimationStyle.noAnimation : null,
      backgroundColor: WarnaFunda.permukaan,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SudutFunda.lembar),
        ),
      ),
      builder: (ctx) => _LembarFilter(
        filterAwal: _filter,
        daftarDompet: daftarDompet,
        daftarKategori: daftarKategori,
        padaTerapkan: (filterBaru) {
          setState(() => _filter = filterBaru);
        },
      ),
    );
  }

  Widget _bangunHeaderEditorial(
    BuildContext context, {
    required bool tampilkanTombolCatat,
  }) {
    final bisaKembali = Navigator.canPop(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: SpasiFunda.m),
      child: Row(
        children: [
          if (bisaKembali) ...[
            Semantics(
              button: true,
              label: 'Kembali',
              child: InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(SudutFunda.pil),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: WarnaFunda.permukaan,
                    shape: BoxShape.circle,
                    border: Border.all(color: WarnaFunda.garis),
                  ),
                  child: const Icon(
                    LucideIcons.arrowLeft,
                    size: 18,
                    color: WarnaFunda.teks,
                  ),
                ),
              ),
            ),
            const SizedBox(width: SpasiFunda.m),
          ],
          const Expanded(child: TeksFunda.judulLayar('Catatan Keuangan')),
          if (tampilkanTombolCatat) ...[
            const SizedBox(width: SpasiFunda.s),
            Semantics(
              button: true,
              label: 'Catat Transaksi',
              child: InkWell(
                key: const Key('tombol_catat_header_catatan'),
                onTap: _bukaFormCatat,
                borderRadius: BorderRadius.circular(SudutFunda.pil),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 44),
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpasiFunda.m,
                    vertical: SpasiFunda.s,
                  ),
                  decoration: BoxDecoration(
                    color: WarnaFunda.tombolGelap,
                    borderRadius: BorderRadius.circular(SudutFunda.pil),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.plus,
                        size: 16,
                        color: WarnaFunda.teksPutih,
                      ),
                      SizedBox(width: SpasiFunda.xs),
                      Text(
                        'Catat',
                        style: TextStyle(
                          fontFamily: TipografiFunda.namaKeluargaFont,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: WarnaFunda.teksPutih,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dompetAktifAsync = ref.watch(penyediaDaftarDompetAktif);
    final semuaDompetAsync = ref.watch(penyediaDaftarDompet);

    // Tampilkan pemuat saat data dompet pertama kali diambil
    if (dompetAktifAsync.isLoading && !dompetAktifAsync.hasValue) {
      return Scaffold(
        backgroundColor: WarnaFunda.latar,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(SpasiFunda.marginLayar),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _bangunHeaderEditorial(context, tampilkanTombolCatat: false),
                const Expanded(child: Center(child: IndikatorMemuat())),
              ],
            ),
          ),
        ),
      );
    }

    final daftarDompetAktif = dompetAktifAsync.value ?? [];
    final daftarSemuaDompet = semuaDompetAsync.value ?? [];
    final daftarKategori = ref.watch(penyediaDaftarKategori).value ?? [];

    DateTime? mulai;
    DateTime? selesai;
    final sekarang = DateTime.now();
    final hariIni = DateTime(sekarang.year, sekarang.month, sekarang.day);
    switch (_filter.rentang) {
      case RentangWaktuFilter.hariIni:
        mulai = hariIni;
        selesai = DateTime(
          hariIni.year,
          hariIni.month,
          hariIni.day,
          23,
          59,
          59,
        );
        break;
      case RentangWaktuFilter.tujuhHari:
        mulai = hariIni.subtract(const Duration(days: 7));
        selesai = DateTime(
          hariIni.year,
          hariIni.month,
          hariIni.day,
          23,
          59,
          59,
        );
        break;
      case RentangWaktuFilter.bulanIni:
        mulai = DateTime(hariIni.year, hariIni.month, 1);
        selesai = DateTime(hariIni.year, hariIni.month + 1, 0, 23, 59, 59);
        break;
      case RentangWaktuFilter.semua:
        break;
    }

    final paramKueri = ParameterKueriTransaksi(
      limit: _limit,
      offset: 0,
      kataKunci: _kataKunci.isEmpty ? null : _kataKunci,
      dompetId: _filter.dompetId,
      kategoriId: _filter.kategoriId,
      sifat: _filter.sifat?.kode,
      jenis: _filter.jenis?.kode,
      mulai: mulai,
      selesai: selesai,
    );

    final daftarTransaksiAsync = ref.watch(
      penyediaTransaksiBerhalaman(paramKueri),
    );

    // Jika belum ada dompet sama sekali di aplikasi
    if (daftarDompetAktif.isEmpty && daftarSemuaDompet.isEmpty) {
      return Scaffold(
        backgroundColor: WarnaFunda.latar,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(SpasiFunda.marginLayar),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _bangunHeaderEditorial(context, tampilkanTombolCatat: false),
                const SizedBox(height: SpasiFunda.m),
                _KartuKosongCatatanEditorial(
                  judul: 'Belum Ada Dompet',
                  pesan:
                      'Buat dompet pertamamu terlebih dahulu agar bisa mulai mencatat transaksi.',
                  teksTombol: 'Buat Dompet Pertamamu',
                  pathSvg: AsetIlustrasiFunda.belumAdaDompet,
                  warnaKanvas: WarnaFunda.kanvasMint,
                  padaTekan: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const LayarFormDompet(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: WarnaFunda.latar,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            SpasiFunda.marginLayar,
            SpasiFunda.marginLayar,
            SpasiFunda.marginLayar,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _bangunHeaderEditorial(context, tampilkanTombolCatat: true),

              // Bilah Pencarian & Tombol Filter
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _pengontrolCari,
                      decoration: InputDecoration(
                        hintText: 'Cari catatan atau kategori...',
                        prefixIcon: const Icon(LucideIcons.search, size: 20),
                        suffixIcon: _kataKunci.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _pengontrolCari.clear();
                                  setState(() => _kataKunci = '');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: WarnaFunda.permukaan,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: SpasiFunda.m,
                          vertical: SpasiFunda.s,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(SudutFunda.pil),
                          borderSide: const BorderSide(color: WarnaFunda.garis),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(SudutFunda.pil),
                          borderSide: const BorderSide(color: WarnaFunda.garis),
                        ),
                      ),
                      onChanged: (teks) {
                        setState(() => _kataKunci = teks.trim().toLowerCase());
                      },
                    ),
                  ),
                  const SizedBox(width: SpasiFunda.s),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton.filledTonal(
                        tooltip: 'Filter Transaksi',
                        onPressed: () => _bukaLembarFilter(
                          daftarSemuaDompet,
                          daftarKategori,
                        ),
                        icon: const Icon(
                          LucideIcons.slidersHorizontal,
                          size: 20,
                        ),
                        style: IconButton.styleFrom(
                          minimumSize: const Size(48, 48),
                          backgroundColor: _filter.jumlahFilterAktif > 0
                              ? WarnaFunda.utamaTipis
                              : WarnaFunda.permukaan,
                          foregroundColor: _filter.jumlahFilterAktif > 0
                              ? WarnaFunda.utamaGelap
                              : WarnaFunda.teks,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(SudutFunda.pil),
                            side: const BorderSide(color: WarnaFunda.garis),
                          ),
                        ),
                      ),
                      if (_filter.jumlahFilterAktif > 0)
                        Positioned(
                          top: -2,
                          right: -2,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: WarnaFunda.tombolGelap,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${_filter.jumlahFilterAktif}',
                              style: TipografiFunda.catatan.copyWith(
                                color: WarnaFunda.teksPutih,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: SpasiFunda.m),

              // Daftar Riwayat Transaksi Dikelompokkan 1 Kartu Putih per Hari
              Expanded(
                child: daftarTransaksiAsync.when(
                  loading: () => const Center(child: IndikatorMemuat()),
                  error: (e, _) => Center(child: Text('Terjadi kesalahan: $e')),
                  data: (transaksiTersaring) {
                    if (transaksiTersaring.isEmpty) {
                      final adaSaringan =
                          _kataKunci.isNotEmpty ||
                          _filter.jumlahFilterAktif > 0;
                      return SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: SpasiFunda.xl),
                        child: _KartuKosongCatatanEditorial(
                          judul: adaSaringan
                              ? 'Tidak Ada Catatan yang Cocok'
                              : 'Belum Ada Transaksi',
                          pesan: adaSaringan
                              ? 'Coba sesuaikan kata kunci pencarian atau hapus beberapa filter yang aktif.'
                              : 'Setiap langkah keuangan dimulai dari satu catatan kecil. Yuk mulai catat transaksi pertamamu!',
                          teksTombol: _filter.jumlahFilterAktif > 0
                              ? 'Hapus Semua Filter'
                              : 'Catat Transaksi Sekarang',
                          pathSvg: AsetIlustrasiFunda.catatanKosong,
                          warnaKanvas: adaSaringan
                              ? WarnaFunda.kanvasBiru
                              : WarnaFunda.kanvasMint,
                          padaTekan: () {
                            if (_filter.jumlahFilterAktif > 0) {
                              setState(() {
                                _filter = const KondisiFilterTransaksi();
                                _pengontrolCari.clear();
                                _kataKunci = '';
                              });
                            } else {
                              _bukaFormCatat();
                            }
                          },
                        ),
                      );
                    }

                    // Kelompokkan per tanggal lokal perangkat
                    final petaHari = <DateTime, List<EntitasTransaksi>>{};
                    for (final t in transaksiTersaring) {
                      final hari = ambilTanggalLokalPerangkat(t.waktuTransaksi);
                      petaHari.putIfAbsent(hari, () => []).add(t);
                    }

                    final daftarHari = petaHari.keys.toList()
                      ..sort((a, b) => b.compareTo(a));

                    return ListView.builder(
                      controller: _pengontrolGulir,
                      padding: const EdgeInsets.only(bottom: SpasiFunda.xl),
                      itemCount: daftarHari.length,
                      itemBuilder: (context, indeks) {
                        final hari = daftarHari[indeks];
                        final daftarTransaksiHari = petaHari[hari]!;

                        var masukHari = 0;
                        var keluarHari = 0;
                        for (final t in daftarTransaksiHari) {
                          if (t.jenis == 'masuk') {
                            masukHari += t.jumlahRupiah;
                          } else if (t.jenis == 'keluar') {
                            keluarHari += t.jumlahRupiah;
                          } else if (t.jenis == 'transfer') {
                            keluarHari += t.biayaAdminRupiah;
                          }
                        }
                        final selisihHariLokal = masukHari - keluarHari;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Tanggal & Pil Subjumlah Harian
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: SpasiFunda.s,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: TeksFunda.label(
                                      DateFormat(
                                        'EEEE, d MMMM yyyy',
                                        'id_ID',
                                      ).format(hari),
                                      warna: WarnaFunda.teksRedup,
                                    ),
                                  ),
                                  const SizedBox(width: SpasiFunda.s),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: SpasiFunda.s,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: selisihHariLokal >= 0
                                          ? WarnaFunda.tintHijau
                                          : WarnaFunda.tintMawar,
                                      borderRadius: BorderRadius.circular(
                                        SudutFunda.pil,
                                      ),
                                    ),
                                    child: TeksFunda.catatan(
                                      '${selisihHariLokal >= 0 ? '+' : ''}${formatRupiah(selisihHariLokal)}',
                                      warna: selisihHariLokal >= 0
                                          ? WarnaFunda.pemasukan
                                          : WarnaFunda.pengeluaran,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Satu Kartu Putih Border 1px Berpemisah Tipis per Hari
                            Container(
                              key: Key('kartu_harian_catatan_$indeks'),
                              margin: const EdgeInsets.only(
                                bottom: SpasiFunda.m,
                              ),
                              decoration: BoxDecoration(
                                color: WarnaFunda.permukaan,
                                borderRadius: BorderRadius.circular(
                                  SudutFunda.petak,
                                ),
                                border: Border.all(
                                  color: WarnaFunda.garis,
                                  width: 1.0,
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                children: daftarTransaksiHari
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                      final idxTx = entry.key;
                                      final transaksi = entry.value;
                                      return Column(
                                        children: [
                                          _ItemBarisTransaksi(
                                            transaksi: transaksi,
                                            daftarDompet: daftarSemuaDompet,
                                            daftarKategori: daftarKategori,
                                            padaKetuk: () =>
                                                _tampilkanAksiTransaksi(
                                                  context,
                                                  ref,
                                                  transaksi,
                                                ),
                                          ),
                                          if (idxTx <
                                              daftarTransaksiHari.length - 1)
                                            const Divider(
                                              height: 1,
                                              indent: SpasiFunda.l,
                                              endIndent: SpasiFunda.l,
                                              color: WarnaFunda.garis,
                                            ),
                                        ],
                                      );
                                    })
                                    .toList(),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _tampilkanAksiTransaksi(
    BuildContext context,
    WidgetRef ref,
    EntitasTransaksi transaksi,
  ) {
    final tanpaAnimasi =
        MediaQuery.disableAnimationsOf(context) ||
        ref.read(penyediaTanpaAnimasi);
    showModalBottomSheet<void>(
      context: context,
      sheetAnimationStyle: tanpaAnimasi ? AnimationStyle.noAnimation : null,
      backgroundColor: WarnaFunda.permukaan,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SudutFunda.lembar),
        ),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(SpasiFunda.l),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: WarnaFunda.garis,
                  borderRadius: BorderRadius.circular(SudutFunda.pil),
                ),
              ),
              const SizedBox(height: SpasiFunda.l),
              TeksFunda.judulBagian(formatRupiah(transaksi.jumlahRupiah)),
              const SizedBox(height: SpasiFunda.xs),
              TeksFunda.catatan(
                DateFormat(
                  'EEEE, d MMMM yyyy HH:mm',
                  'id_ID',
                ).format(transaksi.waktuTransaksi.toLocal()),
              ),
              const SizedBox(height: SpasiFunda.xl),
              ListTile(
                leading: const Icon(
                  LucideIcons.pencil,
                  color: WarnaFunda.utama,
                ),
                title: const Text(
                  'Ubah Catatan Ini',
                  style: TipografiFunda.label,
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => LayarFormTransaksi(transaksi: transaksi),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  LucideIcons.trash2,
                  color: WarnaFunda.bahaya,
                ),
                title: const Text(
                  'Hapus Catatan Ini',
                  style: TextStyle(color: WarnaFunda.bahaya),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  final setuju = await showDialog<bool>(
                    context: context,
                    builder: (dCtx) => AlertDialog(
                      title: const TeksFunda.judulBagian('Hapus Catatan?'),
                      content: const TeksFunda.isi(
                        'Catatan transaksi ini akan dihapus dari riwayat.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dCtx, false),
                          child: const Text('Batal'),
                        ),
                        TombolFunda.primer(
                          teks: 'Hapus',
                          padaTekan: () => Navigator.pop(dCtx, true),
                        ),
                      ],
                    ),
                  );

                  if (setuju == true && context.mounted) {
                    final repo = ref.read(penyediaTransaksiRepositori);
                    await repo.hapusTransaksi(transaksi.id);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Catatan transaksi telah dihapus.',
                          ),
                          action: SnackBarAction(
                            label: 'Urungkan',
                            textColor: WarnaFunda.aksen,
                            onPressed: () async {
                              await repo.tambahTransaksi(
                                TabelTransaksiCompanion(
                                  id: drift.Value(transaksi.id),
                                  jenis: drift.Value(transaksi.jenis),
                                  jumlahRupiah: drift.Value(
                                    transaksi.jumlahRupiah,
                                  ),
                                  dompetId: drift.Value(transaksi.dompetId),
                                  dompetTujuanId: drift.Value(
                                    transaksi.dompetTujuanId,
                                  ),
                                  kategoriId: drift.Value(transaksi.kategoriId),
                                  biayaAdminRupiah: drift.Value(
                                    transaksi.biayaAdminRupiah,
                                  ),
                                  catatan: drift.Value(transaksi.catatan),
                                  waktuTransaksi: drift.Value(
                                    transaksi.waktuTransaksi,
                                  ),
                                  dibuatPada: drift.Value(transaksi.dibuatPada),
                                  diubahPada: drift.Value(
                                    DateTime.now().toUtc(),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KartuKosongCatatanEditorial extends StatelessWidget {
  final String judul;
  final String pesan;
  final String teksTombol;
  final String pathSvg;
  final Color warnaKanvas;
  final VoidCallback padaTekan;

  const _KartuKosongCatatanEditorial({
    required this.judul,
    required this.pesan,
    required this.teksTombol,
    required this.pathSvg,
    required this.warnaKanvas,
    required this.padaTekan,
  });

  @override
  Widget build(BuildContext context) {
    final teksBesar = MediaQuery.textScalerOf(context).scale(1) >= 1.5;
    return Container(
      decoration: BoxDecoration(
        color: WarnaFunda.permukaan,
        borderRadius: BorderRadius.circular(SudutFunda.petak),
        border: Border.all(color: WarnaFunda.garis),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: warnaKanvas,
            padding: const EdgeInsets.symmetric(
              vertical: SpasiFunda.xl,
              horizontal: SpasiFunda.l,
            ),
            child: Center(
              child: IlustrasiSvgFunda(
                pathAset: pathSvg,
                tinggi: teksBesar ? 80 : 108,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(SpasiFunda.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TeksFunda.judulBagian(judul),
                const SizedBox(height: SpasiFunda.s),
                TeksFunda.isiKecil(pesan, warna: WarnaFunda.teksRedup),
                const SizedBox(height: SpasiFunda.l),
                TombolFunda.pilGelap(teks: teksTombol, padaTekan: padaTekan),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemBarisTransaksi extends StatelessWidget {
  const _ItemBarisTransaksi({
    required this.transaksi,
    required this.daftarDompet,
    required this.daftarKategori,
    required this.padaKetuk,
  });

  final EntitasTransaksi transaksi;
  final List<EntitasDompet> daftarDompet;
  final List<EntitasKategori> daftarKategori;
  final VoidCallback padaKetuk;

  @override
  Widget build(BuildContext context) {
    final jenis = JenisTransaksi.dariKode(transaksi.jenis);
    final dompetAsal = daftarDompet.firstWhere(
      (d) => d.id == transaksi.dompetId,
      orElse: () => EntitasDompet(
        id: '',
        nama: 'Dompet Tidak Dikenal',
        jenis: '',
        ikon: 'wallet',
        warna: 'tintNetral',
        saldoAwalRupiah: 0,
        urutan: 0,
        diarsipkan: false,
        dibuatPada: DateTime.now(),
      ),
    );

    final dompetTujuan = transaksi.dompetTujuanId != null
        ? daftarDompet.firstWhere(
            (d) => d.id == transaksi.dompetTujuanId,
            orElse: () => EntitasDompet(
              id: '',
              nama: 'Dompet Tujuan',
              jenis: '',
              ikon: 'wallet',
              warna: 'tintNetral',
              saldoAwalRupiah: 0,
              urutan: 0,
              diarsipkan: false,
              dibuatPada: DateTime.now(),
            ),
          )
        : null;

    final kategori = transaksi.kategoriId != null
        ? daftarKategori.firstWhere(
            (k) => k.id == transaksi.kategoriId,
            orElse: () => EntitasKategori(
              id: '',
              nama: 'Kategori Lain',
              arus: '',
              sifat: 'belum_dilabeli',
              ikon: 'tag',
              bawaan: false,
              diarsipkan: false,
            ),
          )
        : null;

    final isMasuk =
        jenis == JenisTransaksi.masuk ||
        jenis == JenisTransaksi.penyesuaianMasuk;
    final isTransfer = jenis == JenisTransaksi.transfer;

    final tanda = isMasuk ? '+' : (isTransfer ? '' : '-');
    final warnaNominal = isMasuk
        ? WarnaFunda.pemasukan
        : (isTransfer ? WarnaFunda.utama : WarnaFunda.pengeluaran);

    String judulBaris;
    IconData ikonBaris;
    Color warnaIkon;

    if (isTransfer) {
      judulBaris = '${dompetAsal.nama} → ${dompetTujuan?.nama ?? ''}';
      ikonBaris = LucideIcons.arrowLeftRight;
      warnaIkon = WarnaFunda.utama;
    } else if (kategori != null) {
      judulBaris = kategori.nama;
      ikonBaris = ambilIkonLucide(kategori.ikon);
      warnaIkon = isMasuk ? WarnaFunda.pemasukan : WarnaFunda.pengeluaran;
    } else {
      judulBaris = jenis.label;
      ikonBaris = LucideIcons.slidersHorizontal;
      warnaIkon = WarnaFunda.utama;
    }

    return Material(
      color: WarnaFunda.transparan,
      child: InkWell(
        onTap: padaKetuk,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SpasiFunda.l,
            vertical: SpasiFunda.m,
          ),
          child: Row(
            children: [
              if (isTransfer)
                const IkonSvgFunda(
                  pathAset: AsetIkonFunda.transaksiTransfer,
                  ukuran: 22,
                )
              else
                Icon(ikonBaris, size: 20, color: warnaIkon),
              const SizedBox(width: SpasiFunda.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(judulBaris, style: TipografiFunda.label),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (!isTransfer) ...[
                          Flexible(
                            child: Text(
                              dompetAsal.nama,
                              style: TipografiFunda.catatan,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (transaksi.catatan != null &&
                              transaksi.catatan!.isNotEmpty)
                            const SizedBox(width: SpasiFunda.s),
                        ],
                        if (transaksi.catatan != null &&
                            transaksi.catatan!.isNotEmpty)
                          Expanded(
                            child: Text(
                              '• ${transaksi.catatan}',
                              style: TipografiFunda.catatan,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: SpasiFunda.s),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$tanda${formatRupiah(transaksi.jumlahRupiah)}',
                    style: TipografiFunda.label.copyWith(
                      color: warnaNominal,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  if (transaksi.biayaAdminRupiah > 0)
                    Text(
                      'admin ${formatRupiah(transaksi.biayaAdminRupiah)}',
                      style: TipografiFunda.catatan.copyWith(
                        fontSize: 10,
                        color: WarnaFunda.teksRedup,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LembarFilter extends StatefulWidget {
  const _LembarFilter({
    required this.filterAwal,
    required this.daftarDompet,
    required this.daftarKategori,
    required this.padaTerapkan,
  });

  final KondisiFilterTransaksi filterAwal;
  final List<EntitasDompet> daftarDompet;
  final List<EntitasKategori> daftarKategori;
  final ValueChanged<KondisiFilterTransaksi> padaTerapkan;

  @override
  State<_LembarFilter> createState() => _LembarFilterState();
}

class _LembarFilterState extends State<_LembarFilter> {
  late KondisiFilterTransaksi _filterSaatIni;

  @override
  void initState() {
    super.initState();
    _filterSaatIni = widget.filterAwal;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(SpasiFunda.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const TeksFunda.judulBagian('Filter Catatan'),
                if (_filterSaatIni.jumlahFilterAktif > 0)
                  TextButton(
                    onPressed: () {
                      setState(
                        () => _filterSaatIni = const KondisiFilterTransaksi(),
                      );
                    },
                    child: const Text('Hapus Semua Filter'),
                  ),
              ],
            ),
            const SizedBox(height: SpasiFunda.m),

            // Filter Rentang Waktu
            const TeksFunda.label('Rentang Waktu'),
            const SizedBox(height: SpasiFunda.s),
            Wrap(
              spacing: SpasiFunda.s,
              children: RentangWaktuFilter.values.map((r) {
                final terpilih = _filterSaatIni.rentang == r;
                return ChoiceChip(
                  label: Text(r.label),
                  selected: terpilih,
                  selectedColor: WarnaFunda.utamaTipis,
                  onSelected: (val) {
                    if (val) {
                      setState(
                        () => _filterSaatIni = _filterSaatIni.copyWith(
                          rentang: r,
                        ),
                      );
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: SpasiFunda.l),

            // Filter Jenis Transaksi
            const TeksFunda.label('Jenis Transaksi'),
            const SizedBox(height: SpasiFunda.s),
            Wrap(
              spacing: SpasiFunda.s,
              children: [
                ChoiceChip(
                  label: const Text('Semua'),
                  selected: _filterSaatIni.jenis == null,
                  onSelected: (val) {
                    if (val) {
                      setState(
                        () => _filterSaatIni = _filterSaatIni.copyWith(
                          jenis: () => null,
                        ),
                      );
                    }
                  },
                ),
                ChoiceChip(
                  avatar: const IkonSvgFunda(
                    pathAset: AsetIkonFunda.transaksiPengeluaran,
                    ukuran: 16,
                  ),
                  label: const Text('Pengeluaran'),
                  selected: _filterSaatIni.jenis == JenisTransaksi.keluar,
                  onSelected: (val) {
                    setState(
                      () => _filterSaatIni = _filterSaatIni.copyWith(
                        jenis: () => val ? JenisTransaksi.keluar : null,
                      ),
                    );
                  },
                ),
                ChoiceChip(
                  avatar: const IkonSvgFunda(
                    pathAset: AsetIkonFunda.transaksiPemasukan,
                    ukuran: 16,
                  ),
                  label: const Text('Pemasukan'),
                  selected: _filterSaatIni.jenis == JenisTransaksi.masuk,
                  onSelected: (val) {
                    setState(
                      () => _filterSaatIni = _filterSaatIni.copyWith(
                        jenis: () => val ? JenisTransaksi.masuk : null,
                      ),
                    );
                  },
                ),
                ChoiceChip(
                  avatar: const IkonSvgFunda(
                    pathAset: AsetIkonFunda.transaksiTransfer,
                    ukuran: 16,
                  ),
                  label: const Text('Transfer'),
                  selected: _filterSaatIni.jenis == JenisTransaksi.transfer,
                  onSelected: (val) {
                    setState(
                      () => _filterSaatIni = _filterSaatIni.copyWith(
                        jenis: () => val ? JenisTransaksi.transfer : null,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: SpasiFunda.l),

            // Filter Dompet
            const TeksFunda.label('Dompet'),
            const SizedBox(height: SpasiFunda.s),
            DropdownButtonFormField<String?>(
              initialValue: _filterSaatIni.dompetId,
              decoration: InputDecoration(
                filled: true,
                fillColor: WarnaFunda.latar,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SudutFunda.kartu),
                  borderSide: const BorderSide(color: WarnaFunda.garis),
                ),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Semua Dompet'),
                ),
                ...widget.daftarDompet.map((d) {
                  return DropdownMenuItem(value: d.id, child: Text(d.nama));
                }),
              ],
              onChanged: (val) {
                setState(
                  () => _filterSaatIni = _filterSaatIni.copyWith(
                    dompetId: () => val,
                  ),
                );
              },
            ),
            const SizedBox(height: SpasiFunda.xl),

            TombolFunda.pilGelap(
              teks: 'Terapkan Filter',
              padaTekan: () {
                widget.padaTerapkan(_filterSaatIni);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
