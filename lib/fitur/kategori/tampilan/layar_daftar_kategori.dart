import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../data/basis_data.dart';
import '../../../data/model/sifat_kategori.dart';
import '../../../data/penyedia_data.dart';
import '../../../komponen/komponen_funda.dart';
import '../../../komponen/pembantu_ikon.dart';
import '../../../tema/token.dart';

/// Layar Daftar Kategori: menampilkan kategori per sifat, ubah sifat, arsip, dan tambah kustom.
class LayarDaftarKategori extends ConsumerStatefulWidget {
  const LayarDaftarKategori({super.key});

  @override
  ConsumerState<LayarDaftarKategori> createState() =>
      _LayarDaftarKategoriState();
}

class _LayarDaftarKategoriState extends ConsumerState<LayarDaftarKategori>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final daftarKategoriAsync = ref.watch(penyediaDaftarKategori);

    return Scaffold(
      backgroundColor: WarnaFunda.latar,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                SpasiFunda.marginLayar,
                SpasiFunda.s,
                SpasiFunda.marginLayar,
                SpasiFunda.s,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  HeaderSubLayarEditorial(
                    judul: 'Kategori Keuangan',
                    aksiKanan: [
                      TombolPilHeaderEditorial(
                        key: const Key('tombol_tambah_kategori'),
                        teks: 'Tambah',
                        ikon: LucideIcons.plus,
                        warnaTeks: WarnaFunda.teksPutih,
                        warnaLatar: WarnaFunda.tombolGelap,
                        warnaBatas: WarnaFunda.tombolGelap,
                        padaTekan: () =>
                            _tampilkanDialogTambahKategori(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: SpasiFunda.m),
                  Container(
                    padding: const EdgeInsets.all(SpasiFunda.xs),
                    decoration: BoxDecoration(
                      color: WarnaFunda.permukaan,
                      borderRadius: BorderRadius.circular(SudutFunda.pil),
                      border: Border.all(color: WarnaFunda.garis, width: 1.0),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      dividerColor: WarnaFunda.transparan,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        color: WarnaFunda.tombolGelap,
                        borderRadius: BorderRadius.circular(SudutFunda.pil),
                      ),
                      labelColor: WarnaFunda.teksPutih,
                      unselectedLabelColor: WarnaFunda.teksRedup,
                      labelStyle: const TextStyle(
                        fontFamily: TipografiFunda.namaKeluargaFont,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      tabs: const [
                        Tab(text: 'Pengeluaran'),
                        Tab(text: 'Pemasukan'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: daftarKategoriAsync.when(
                loading: () => const Center(child: IndikatorMemuat()),
                error: (e, _) => Center(child: Text('Terjadi kesalahan: $e')),
                data: (semuaKategori) {
                  final daftarKeluar = semuaKategori
                      .where((k) => k.arus == 'keluar')
                      .toList();
                  final daftarMasuk = semuaKategori
                      .where((k) => k.arus == 'masuk')
                      .toList();

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _DaftarKategoriKeluar(daftarKategori: daftarKeluar),
                      _DaftarKategoriMasuk(daftarKategori: daftarMasuk),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _tampilkanDialogTambahKategori(BuildContext context) {
    final pengontrolNama = TextEditingController();
    var arus = 'keluar';
    var sifat = SifatKategori.keinginan;
    const ikon = 'tag';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const TeksFunda.judulBagian('Tambah Kategori'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TeksFunda.label('Nama Kategori'),
                  const SizedBox(height: SpasiFunda.s),
                  TextField(
                    controller: pengontrolNama,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Contoh: Kopi Spesialti, Laundry',
                      filled: true,
                      fillColor: WarnaFunda.latar,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(SudutFunda.kartu),
                        borderSide: const BorderSide(color: WarnaFunda.garis),
                      ),
                    ),
                  ),
                  const SizedBox(height: SpasiFunda.m),
                  const TeksFunda.label('Arah Arus'),
                  const SizedBox(height: SpasiFunda.s),
                  Wrap(
                    spacing: SpasiFunda.s,
                    runSpacing: SpasiFunda.s,
                    children: [
                      ChoiceChip(
                        label: const Text('Pengeluaran'),
                        selected: arus == 'keluar',
                        selectedColor: WarnaFunda.utamaTipis,
                        onSelected: (val) {
                          if (val) setDialogState(() => arus = 'keluar');
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Pemasukan'),
                        selected: arus == 'masuk',
                        selectedColor: WarnaFunda.utamaTipis,
                        onSelected: (val) {
                          if (val) {
                            setDialogState(() {
                              arus = 'masuk';
                              sifat = SifatKategori.tidakBerlaku;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  if (arus == 'keluar') ...[
                    const SizedBox(height: SpasiFunda.m),
                    const TeksFunda.label('Sifat Pengeluaran'),
                    const SizedBox(height: SpasiFunda.s),
                    DropdownButtonFormField<SifatKategori>(
                      isExpanded: true,
                      initialValue: sifat,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: WarnaFunda.latar,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(SudutFunda.kartu),
                          borderSide: const BorderSide(color: WarnaFunda.garis),
                        ),
                      ),
                      items:
                          [
                            SifatKategori.kebutuhan,
                            SifatKategori.keinginan,
                            SifatKategori.tabungan,
                            SifatKategori.utang,
                            SifatKategori.belumDilabeli,
                          ].map((s) {
                            return DropdownMenuItem(
                              value: s,
                              child: Text(
                                s.label,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => sifat = val);
                      },
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal'),
              ),
              TombolFunda.pilGelap(
                teks: 'Simpan',
                lebarPenuh: false,
                padaTekan: () async {
                  final nama = pengontrolNama.text.trim();
                  if (nama.isEmpty) return;

                  final repo = ref.read(penyediaKategoriRepositori);
                  final idBaru =
                      'kat_kustom_${DateTime.now().millisecondsSinceEpoch}';

                  await repo.tambahKategoriKustom(
                    TabelKategoriCompanion(
                      id: drift.Value(idBaru),
                      nama: drift.Value(nama),
                      arus: drift.Value(arus),
                      sifat: drift.Value(sifat.kode),
                      ikon: const drift.Value(ikon),
                      bawaan: const drift.Value(false),
                      diarsipkan: const drift.Value(false),
                    ),
                  );

                  if (ctx.mounted) Navigator.pop(ctx);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DaftarKategoriKeluar extends ConsumerWidget {
  const _DaftarKategoriKeluar({required this.daftarKategori});

  final List<EntitasKategori> daftarKategori;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perSifat = <SifatKategori, List<EntitasKategori>>{};
    for (final s in [
      SifatKategori.kebutuhan,
      SifatKategori.keinginan,
      SifatKategori.tabungan,
      SifatKategori.utang,
      SifatKategori.belumDilabeli,
    ]) {
      perSifat[s] = daftarKategori.where((k) => k.sifat == s.kode).toList();
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        SpasiFunda.marginLayar,
        SpasiFunda.xs,
        SpasiFunda.marginLayar,
        SpasiFunda.xl,
      ),
      children: [
        if ((perSifat[SifatKategori.belumDilabeli]?.isNotEmpty ?? false))
          Container(
            padding: const EdgeInsets.all(SpasiFunda.m),
            margin: const EdgeInsets.only(bottom: SpasiFunda.l),
            decoration: BoxDecoration(
              color: WarnaFunda.kanvasKuning,
              borderRadius: BorderRadius.circular(SudutFunda.kartu),
              border: Border.all(color: WarnaFunda.batasAmber, width: 1.0),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IkonSvgFunda(pathAset: AsetIkonFunda.menuKategori, ukuran: 22),
                SizedBox(width: SpasiFunda.m),
                Expanded(
                  child: TeksFunda.catatan(
                    'Beberapa pengeluaran sengaja "Belum Dilabeli" agar kamu bisa melabelinya sesuai kebiasaan belanjamu nanti di pelajaran!',
                    warna: WarnaFunda.teks,
                  ),
                ),
              ],
            ),
          ),

        ...perSifat.entries.map((entri) {
          final sifat = entri.key;
          final kategoriList = entri.value;
          if (kategoriList.isEmpty) return const SizedBox.shrink();

          final warnaSifat = switch (sifat) {
            SifatKategori.kebutuhan => WarnaFunda.sifatKebutuhan,
            SifatKategori.keinginan => WarnaFunda.sifatKeinginan,
            SifatKategori.tabungan => WarnaFunda.sifatTabungan,
            SifatKategori.utang => WarnaFunda.sifatUtang,
            _ => WarnaFunda.teksRedup,
          };

          final ikonSifat = switch (sifat) {
            SifatKategori.kebutuhan => LucideIcons.shield,
            SifatKategori.keinginan => LucideIcons.gift,
            SifatKategori.tabungan => LucideIcons.piggyBank,
            SifatKategori.utang => LucideIcons.calendarClock,
            _ => LucideIcons.helpCircle,
          };
          final svgSifat = pathSvgUntukSifatKategori(sifat.kode);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (svgSifat != null)
                    IkonSvgFunda(pathAset: svgSifat, ukuran: 20)
                  else
                    ikonUiDariLucide(ikonSifat, ukuran: 18, warna: warnaSifat),
                  const SizedBox(width: SpasiFunda.s),
                  Expanded(
                    child: TeksFunda.label(
                      '${sifat.label} (${kategoriList.length})',
                      warna: warnaSifat,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SpasiFunda.s),
              Container(
                decoration: BoxDecoration(
                  color: WarnaFunda.permukaan,
                  borderRadius: BorderRadius.circular(SudutFunda.kartu),
                  border: Border.all(color: WarnaFunda.garis, width: 1.0),
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < kategoriList.length; i++) ...[
                      if (i > 0)
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: WarnaFunda.garis,
                        ),
                      _BarisKategori(
                        kategori: kategoriList[i],
                        warnaSifat: warnaSifat,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: SpasiFunda.l),
            ],
          );
        }),
      ],
    );
  }
}

class _DaftarKategoriMasuk extends ConsumerWidget {
  const _DaftarKategoriMasuk({required this.daftarKategori});

  final List<EntitasKategori> daftarKategori;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        SpasiFunda.marginLayar,
        SpasiFunda.xs,
        SpasiFunda.marginLayar,
        SpasiFunda.xl,
      ),
      children: [
        Row(
          children: [
            const IkonUiFunda(
              pathAset: AsetIkonUiFunda.arrowDownLeft,
              ukuran: 18,
              warna: WarnaFunda.pemasukan,
            ),
            const SizedBox(width: SpasiFunda.s),
            Expanded(
              child: TeksFunda.label(
                'Semua Pemasukan (${daftarKategori.length})',
                warna: WarnaFunda.pemasukan,
              ),
            ),
          ],
        ),
        const SizedBox(height: SpasiFunda.s),
        Container(
          decoration: BoxDecoration(
            color: WarnaFunda.permukaan,
            borderRadius: BorderRadius.circular(SudutFunda.kartu),
            border: Border.all(color: WarnaFunda.garis, width: 1.0),
          ),
          child: Column(
            children: [
              for (var i = 0; i < daftarKategori.length; i++) ...[
                if (i > 0)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: WarnaFunda.garis,
                  ),
                _BarisKategori(
                  kategori: daftarKategori[i],
                  warnaSifat: WarnaFunda.pemasukan,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _BarisKategori extends ConsumerWidget {
  const _BarisKategori({required this.kategori, required this.warnaSifat});

  final EntitasKategori kategori;
  final Color warnaSifat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: SpasiFunda.m,
        vertical: SpasiFunda.xs,
      ),
      leading: IkonKategoriFunda(
        kunciIkon: kategori.ikon,
        ukuran: 22,
        warnaFallback: warnaSifat,
      ),
      title: Wrap(
        spacing: SpasiFunda.s,
        runSpacing: SpasiFunda.xs,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(kategori.nama, style: TipografiFunda.label),
          if (kategori.diarsipkan)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SpasiFunda.s,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: WarnaFunda.tintAmber,
                borderRadius: BorderRadius.circular(SudutFunda.pil),
              ),
              child: const TeksFunda.catatan('Arsip', warna: WarnaFunda.teks),
            ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        icon: const IkonUiFunda(
          pathAset: AsetIkonUiFunda.ellipsisVertical,
          ukuran: 18,
        ),
        onSelected: (aksi) => _tanganiAksi(context, ref, aksi),
        itemBuilder: (context) => [
          if (kategori.arus == 'keluar')
            const PopupMenuItem(value: 'ubah_sifat', child: Text('Ubah Sifat')),
          PopupMenuItem(
            value: 'arsip',
            child: Text(kategori.diarsipkan ? 'Pulihkan' : 'Arsipkan'),
          ),
          if (!kategori.bawaan)
            const PopupMenuItem(
              value: 'hapus',
              child: Text(
                'Hapus Kustom',
                style: TextStyle(color: WarnaFunda.bahaya),
              ),
            ),
        ],
      ),
    );
  }

  void _tanganiAksi(BuildContext context, WidgetRef ref, String aksi) async {
    final repo = ref.read(penyediaKategoriRepositori);

    if (aksi == 'arsip') {
      await repo.arsipkanKategori(kategori.id, !kategori.diarsipkan);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              kategori.diarsipkan
                  ? 'Kategori dipulihkan.'
                  : 'Kategori diarsipkan.',
            ),
          ),
        );
      }
    } else if (aksi == 'ubah_sifat') {
      _tampilkanDialogUbahSifat(context, ref);
    } else if (aksi == 'hapus') {
      try {
        await repo.hapusKategoriKustom(kategori.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kategori kustom dihapus.')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.toString())));
        }
      }
    }
  }

  void _tampilkanDialogUbahSifat(BuildContext context, WidgetRef ref) {
    var sifatTerpilih = SifatKategori.dariKode(kategori.sifat);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: TeksFunda.judulBagian('Ubah Sifat ${kategori.nama}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children:
                    [
                      SifatKategori.kebutuhan,
                      SifatKategori.keinginan,
                      SifatKategori.tabungan,
                      SifatKategori.utang,
                      SifatKategori.belumDilabeli,
                    ].map((s) {
                      final terpilih = sifatTerpilih == s;
                      return ListTile(
                        title: Text(s.label),
                        leading: IkonUiFunda(
                          pathAset: terpilih
                              ? AsetIkonUiFunda.circleDot
                              : AsetIkonUiFunda.circle,
                          warna: terpilih
                              ? WarnaFunda.utama
                              : WarnaFunda.teksRedup,
                          ukuran: 20,
                        ),
                        onTap: () {
                          setDialogState(() => sifatTerpilih = s);
                        },
                      );
                    }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal'),
              ),
              TombolFunda.pilGelap(
                teks: 'Simpan',
                lebarPenuh: false,
                padaTekan: () async {
                  final repo = ref.read(penyediaKategoriRepositori);
                  await repo.perbaruiKategori(
                    TabelKategoriCompanion(
                      id: drift.Value(kategori.id),
                      nama: drift.Value(kategori.nama),
                      arus: drift.Value(kategori.arus),
                      sifat: drift.Value(sifatTerpilih.kode),
                      ikon: drift.Value(kategori.ikon),
                      bawaan: drift.Value(kategori.bawaan),
                      diarsipkan: drift.Value(kategori.diarsipkan),
                    ),
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
