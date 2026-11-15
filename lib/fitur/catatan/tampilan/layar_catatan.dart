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

/// Layar Tab Catatan Keuangan dengan riwayat per hari, pencarian, dan filter lembar bawah.
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

  @override
  void initState() {
    super.initState();
    _pengontrolGulir.addListener(_padaGulir);
  }

  void _padaGulir() {
    if (_pengontrolGulir.position.pixels >=
        _pengontrolGulir.position.maxScrollExtent - 200) {
      if (_limit < 100000) {
        setState(() {
          _limit += 50;
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

  void _bukaLembarFilter(
    List<EntitasDompet> daftarDompet,
    List<EntitasKategori> daftarKategori,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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

  @override
  Widget build(BuildContext context) {
    final daftarDompetAktif = ref.watch(penyediaDaftarDompetAktif).value ?? [];
    final daftarSemuaDompet = ref.watch(penyediaDaftarDompet).value ?? [];
    final daftarKategori = ref.watch(penyediaDaftarKategori).value ?? [];
    final repoTransaksi = ref.watch(penyediaTransaksiRepositori);

    DateTime? mulai;
    DateTime? selesai;
    final sekarang = DateTime.now();
    switch (_filter.rentang) {
      case RentangWaktuFilter.hariIni:
        mulai = DateTime(sekarang.year, sekarang.month, sekarang.day);
        selesai = DateTime(
          sekarang.year,
          sekarang.month,
          sekarang.day,
          23,
          59,
          59,
        );
        break;
      case RentangWaktuFilter.tujuhHari:
        mulai = sekarang.subtract(const Duration(days: 7));
        selesai = sekarang;
        break;
      case RentangWaktuFilter.bulanIni:
        mulai = DateTime(sekarang.year, sekarang.month, 1);
        selesai = DateTime(sekarang.year, sekarang.month + 1, 0, 23, 59, 59);
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
      return PembungkusLayar(
        appBar: AppBar(title: const TeksFunda.judulBagian('Catatan Keuangan')),
        anak: KeadaanKosong(
          ikon: LucideIcons.wallet,
          judul: 'Belum Ada Dompet',
          pesan:
              'Buat dompet pertamamu terlebih dahulu agar bisa mulai mencatat transaksi.',
          teksTombol: 'Buat Dompet Pertamamu',
          padaAksi: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LayarFormDompet()),
            );
          },
        ),
      );
    }

    return PembungkusLayar(
      appBar: AppBar(
        title: const TeksFunda.judulBagian('Catatan Keuangan'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus),
            tooltip: 'Catat Transaksi',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LayarFormTransaksi()),
              );
            },
          ),
        ],
      ),
      anak: Column(
        children: [
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
                    onPressed: () =>
                        _bukaLembarFilter(daftarSemuaDompet, daftarKategori),
                    icon: const Icon(LucideIcons.slidersHorizontal, size: 20),
                    style: IconButton.styleFrom(
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
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: WarnaFunda.utama,
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

          // Daftar Riwayat Transaksi Dikelompokkan Per Hari
          Expanded(
            child: daftarTransaksiAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Terjadi kesalahan: $e')),
              data: (transaksiTersaring) {
                if (transaksiTersaring.isEmpty) {
                  return KeadaanKosong(
                    ikon: LucideIcons.receipt,
                    judul:
                        _kataKunci.isNotEmpty || _filter.jumlahFilterAktif > 0
                        ? 'Tidak Ada Catatan yang Cocok'
                        : 'Belum Ada Transaksi',
                    pesan:
                        _kataKunci.isNotEmpty || _filter.jumlahFilterAktif > 0
                        ? 'Coba sesuaikan kata kunci pencarian atau hapus beberapa filter yang aktif.'
                        : 'Setiap langkah keuangan dimulai dari satu catatan kecil. Yuk mulai catat transaksi pertamamu!',
                    teksTombol: _filter.jumlahFilterAktif > 0
                        ? 'Hapus Semua Filter'
                        : 'Catat Transaksi Sekarang',
                    padaAksi: () {
                      if (_filter.jumlahFilterAktif > 0) {
                        setState(() {
                          _filter = const KondisiFilterTransaksi();
                          _pengontrolCari.clear();
                          _kataKunci = '';
                        });
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LayarFormTransaksi(),
                          ),
                        );
                      }
                    },
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
                  itemCount: daftarHari.length,
                  itemBuilder: (context, indeks) {
                    final hari = daftarHari[indeks];
                    final daftarTransaksiHari = petaHari[hari]!;

                    // Hitung subjumlah harian lokal sebagai nilai mula-mula
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

                    final awalHari = DateTime(hari.year, hari.month, hari.day);
                    final akhirHari = DateTime(
                      hari.year,
                      hari.month,
                      hari.day,
                      23,
                      59,
                      59,
                    );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Tanggal & Subjumlah Harian (Agregasi SQL)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: SpasiFunda.s,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TeksFunda.label(
                                DateFormat(
                                  'EEEE, d MMMM yyyy',
                                  'id_ID',
                                ).format(hari),
                                warna: WarnaFunda.teksRedup,
                              ),
                              FutureBuilder<int>(
                                future: repoTransaksi.hitungSubjumlahHarianSQL(
                                  awalHari: awalHari,
                                  akhirHari: akhirHari,
                                ),
                                builder: (context, snapshot) {
                                  final selisihHari =
                                      snapshot.data ?? selisihHariLokal;
                                  return TeksFunda.catatan(
                                    '${selisihHari >= 0 ? '+' : ''}${formatRupiah(selisihHari)}',
                                    warna: selisihHari >= 0
                                        ? WarnaFunda.pemasukan
                                        : WarnaFunda.pengeluaran,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        // Item Transaksi di Hari Tersebut
                        ...daftarTransaksiHari.map((transaksi) {
                          return _ItemBarisTransaksi(
                            transaksi: transaksi,
                            daftarDompet: daftarSemuaDompet,
                            daftarKategori: daftarKategori,
                            padaKetuk: () => _tampilkanAksiTransaksi(
                              context,
                              ref,
                              transaksi,
                            ),
                          );
                        }),
                        const SizedBox(height: SpasiFunda.m),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _tampilkanAksiTransaksi(
    BuildContext context,
    WidgetRef ref,
    EntitasTransaksi transaksi,
  ) {
    showModalBottomSheet(
      context: context,
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
                    MaterialPageRoute(
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

    // Judul & Ikon
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
      warnaIkon = WarnaFunda.teksRedup;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: SpasiFunda.s),
      decoration: BoxDecoration(
        color: WarnaFunda.permukaan,
        borderRadius: BorderRadius.circular(SudutFunda.kartu),
        border: Border.all(color: WarnaFunda.garis),
      ),
      child: ListTile(
        onTap: padaKetuk,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: SpasiFunda.m,
          vertical: SpasiFunda.xs,
        ),
        leading: Container(
          padding: const EdgeInsets.all(SpasiFunda.s),
          decoration: BoxDecoration(
            color: warnaIkon.withAlpha(20),
            borderRadius: BorderRadius.circular(SudutFunda.kecil),
          ),
          child: Icon(ikonBaris, size: 20, color: warnaIkon),
        ),
        title: Text(judulBaris, style: TipografiFunda.label),
        subtitle: Row(
          children: [
            if (!isTransfer) ...[
              Text(dompetAsal.nama, style: TipografiFunda.catatan),
              const SizedBox(width: SpasiFunda.s),
            ],
            if (transaksi.catatan != null && transaksi.catatan!.isNotEmpty) ...[
              Expanded(
                child: Text(
                  '• ${transaksi.catatan}',
                  style: TipografiFunda.catatan,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
      child: Padding(
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

            TombolFunda.primer(
              teks: 'Terapkan Filter',
              lebarPenuh: true,
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
