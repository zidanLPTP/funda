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
      appBar: AppBar(
        title: const TeksFunda.judulBagian('Kategori Keuangan'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus),
            tooltip: 'Tambah Kategori Kustom',
            onPressed: () => _tampilkanDialogTambahKategori(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: WarnaFunda.utama,
          unselectedLabelColor: WarnaFunda.teksRedup,
          indicatorColor: WarnaFunda.utama,
          tabs: const [
            Tab(text: 'Pengeluaran'),
            Tab(text: 'Pemasukan'),
          ],
        ),
      ),
      body: SafeArea(
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
    );
  }

  void _tampilkanDialogTambahKategori(BuildContext context) {
    final pengontrolNama = TextEditingController();
    var arus = 'keluar';
    var sifat = SifatKategori.keinginan;
    var ikon = 'tag';

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
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Pengeluaran'),
                        selected: arus == 'keluar',
                        selectedColor: WarnaFunda.utamaTipis,
                        onSelected: (val) {
                          if (val) setDialogState(() => arus = 'keluar');
                        },
                      ),
                      const SizedBox(width: SpasiFunda.s),
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
                              child: Text(s.label),
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
              TombolFunda.primer(
                teks: 'Simpan',
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
                      ikon: drift.Value(ikon),
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
      padding: const EdgeInsets.all(SpasiFunda.marginLayar),
      children: [
        // Penanda Ajakan Lembut Belum Dilabeli
        if ((perSifat[SifatKategori.belumDilabeli]?.isNotEmpty ?? false))
          Container(
            padding: const EdgeInsets.all(SpasiFunda.m),
            margin: const EdgeInsets.only(bottom: SpasiFunda.l),
            decoration: BoxDecoration(
              color: WarnaFunda.tintAmber,
              borderRadius: BorderRadius.circular(SudutFunda.kartu),
              border: Border.all(color: WarnaFunda.peringatan.withAlpha(50)),
            ),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.tags,
                  color: WarnaFunda.peringatan,
                  size: 20,
                ),
                const SizedBox(width: SpasiFunda.m),
                const Expanded(
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

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(ikonSifat, size: 18, color: warnaSifat),
                  const SizedBox(width: SpasiFunda.s),
                  TeksFunda.label(sifat.label, warna: warnaSifat),
                  const SizedBox(width: SpasiFunda.s),
                  TeksFunda.catatan('(${kategoriList.length})'),
                ],
              ),
              const SizedBox(height: SpasiFunda.s),
              ...kategoriList.map(
                (kategori) =>
                    _BarisKategori(kategori: kategori, warnaSifat: warnaSifat),
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
      padding: const EdgeInsets.all(SpasiFunda.marginLayar),
      children: [
        const Row(
          children: [
            Icon(
              LucideIcons.arrowDownLeft,
              size: 18,
              color: WarnaFunda.pemasukan,
            ),
            SizedBox(width: SpasiFunda.s),
            TeksFunda.label('Semua Pemasukan', warna: WarnaFunda.pemasukan),
          ],
        ),
        const SizedBox(height: SpasiFunda.s),
        ...daftarKategori.map(
          (kategori) => _BarisKategori(
            kategori: kategori,
            warnaSifat: WarnaFunda.pemasukan,
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
    return Container(
      margin: const EdgeInsets.only(bottom: SpasiFunda.s),
      decoration: BoxDecoration(
        color: WarnaFunda.permukaan,
        borderRadius: BorderRadius.circular(SudutFunda.kartu),
        border: Border.all(color: WarnaFunda.garis),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(SpasiFunda.s),
          decoration: BoxDecoration(
            color: warnaSifat.withAlpha(20),
            borderRadius: BorderRadius.circular(SudutFunda.kecil),
          ),
          child: Icon(
            ambilIkonLucide(kategori.ikon),
            size: 20,
            color: warnaSifat,
          ),
        ),
        title: Row(
          children: [
            Text(kategori.nama, style: TipografiFunda.label),
            if (kategori.diarsipkan) ...[
              const SizedBox(width: SpasiFunda.s),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: SpasiFunda.xs,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: WarnaFunda.peringatan.withAlpha(25),
                  borderRadius: BorderRadius.circular(SudutFunda.pil),
                ),
                child: const Text('Arsip', style: TipografiFunda.catatan),
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(LucideIcons.ellipsisVertical, size: 18),
          onSelected: (aksi) => _tanganiAksi(context, ref, aksi),
          itemBuilder: (context) => [
            if (kategori.arus == 'keluar')
              const PopupMenuItem(
                value: 'ubah_sifat',
                child: Text('Ubah Sifat'),
              ),
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
            content: Column(
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
                      leading: Icon(
                        terpilih ? LucideIcons.circleDot : LucideIcons.circle,
                        color: terpilih
                            ? WarnaFunda.utama
                            : WarnaFunda.teksRedup,
                        size: 20,
                      ),
                      onTap: () {
                        setDialogState(() => sifatTerpilih = s);
                      },
                    );
                  }).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal'),
              ),
              TombolFunda.primer(
                teks: 'Simpan',
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
