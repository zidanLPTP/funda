import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../data/basis_data.dart';
import '../../../data/penyedia_basis_data.dart';
import '../../../komponen/komponen_funda.dart';
import '../../../komponen/pembantu_ikon.dart';
import '../../../perhitungan/perhitungan_anggaran_tujuan.dart';
import '../../../tema/token.dart';
import '../../../util/format_rupiah.dart';
import '../../kategori/kontroler/penyedia_kategori.dart';
import '../kontroler/penyedia_anggaran.dart';

/// Layar perencanaan dan pemantauan anggaran per kategori per bulan kalender.
class LayarAnggaran extends ConsumerWidget {
  const LayarAnggaran({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final periode = ref.watch(penyediaPeriodeAnggaran);
    final realisasiAsync = ref.watch(penyediaRealisasiAnggaranBulan);
    final ringkasan = ref.watch(penyediaRingkasanAnggaranBulan);
    final daftarKategori = ref.watch(penyediaDaftarKategori).value ?? [];
    final repoAnggaran = ref.watch(penyediaAnggaranRepositori);

    final namaBulan = DateFormat(
      'MMMM yyyy',
      'id_ID',
    ).format(DateTime(periode.tahun, periode.bulan));

    return Scaffold(
      backgroundColor: WarnaFunda.latar,
      appBar: AppBar(
        title: const TeksFunda.judulBagian('Anggaran Bulanan'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.copyPlus),
            tooltip: 'Salin dari Bulan Lalu',
            onPressed: () async {
              final jumlahSalin = await repoAnggaran.salinAnggaranDariBulanLalu(
                tahunTujuan: periode.tahun,
                bulanTujuan: periode.bulan,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      jumlahSalin > 0
                          ? 'Berhasil menyalin $jumlahSalin pos anggaran dari bulan lalu (pos yang sudah ada tidak ditimpa).'
                          : 'Semua pos anggaran sudah terisi atau tidak ada anggaran bulan lalu yang dapat disalin.',
                    ),
                  ),
                );
                ref.invalidate(penyediaRealisasiAnggaranBulan);
              }
            },
          ),
          IconButton(
            icon: const Icon(LucideIcons.plus),
            tooltip: 'Atur Anggaran',
            onPressed: () => _bukaDialogAturAnggaran(
              context,
              ref,
              daftarKategori,
              periode.tahun,
              periode.bulan,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: WarnaFunda.utama,
        foregroundColor: WarnaFunda.teksPutih,
        onPressed: () => _bukaDialogAturAnggaran(
          context,
          ref,
          daftarKategori,
          periode.tahun,
          periode.bulan,
        ),
        icon: const Icon(LucideIcons.plus, size: 20),
        label: const Text('Atur Anggaran'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(SpasiFunda.m),
          children: [
            // Navigasi Pengalih Bulan
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SpasiFunda.m,
                vertical: SpasiFunda.s,
              ),
              decoration: BoxDecoration(
                color: WarnaFunda.permukaan,
                borderRadius: BorderRadius.circular(SudutFunda.kartu),
                border: Border.all(color: WarnaFunda.garis),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(LucideIcons.chevronLeft),
                    tooltip: 'Bulan Sebelumnya',
                    onPressed: () => ref
                        .read(penyediaPeriodeAnggaran.notifier)
                        .bulanSebelumnya(),
                  ),
                  TeksFunda.judulBagian(namaBulan),
                  IconButton(
                    icon: const Icon(LucideIcons.chevronRight),
                    tooltip: 'Bulan Berikutnya',
                    onPressed: () => ref
                        .read(penyediaPeriodeAnggaran.notifier)
                        .bulanBerikutnya(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SpasiFunda.m),

            // Petak Bento Hero: Ringkasan Total Anggaran
            PetakBento.ukuran2x1(
              warnaKustom: WarnaFunda.tintBiru,
              anak: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const TeksFunda.label('Total Anggaran'),
                      TeksFunda.catatan(
                        '${ringkasan.persentaseTerpakai}% terpakai',
                        warna: ringkasan.persentaseTerpakai > 100
                            ? WarnaFunda.pengeluaran
                            : WarnaFunda.teksRedup,
                      ),
                    ],
                  ),
                  const SizedBox(height: SpasiFunda.s),
                  TeksFunda.angkaBesar(
                    formatRupiah(ringkasan.totalBatasRupiah),
                  ),
                  const SizedBox(height: SpasiFunda.m),
                  // Progress Bar Total
                  ClipRRect(
                    borderRadius: BorderRadius.circular(SudutFunda.pil),
                    child: IndikatorMemuat.garis(
                      nilai: (ringkasan.persentaseTerpakai / 100).clamp(0.0, 1.0),
                      tinggi: 8,
                      warnaLatar: WarnaFunda.garis,
                      warna: ringkasan.persentaseTerpakai > 100
                          ? WarnaFunda.pengeluaran
                          : ringkasan.persentaseTerpakai >= 80
                          ? WarnaFunda.peringatan
                          : WarnaFunda.utama,
                    ),
                  ),
                  const SizedBox(height: SpasiFunda.m),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const TeksFunda.catatan('Terpakai'),
                          TeksFunda.label(
                            formatRupiah(ringkasan.totalTerpakaiRupiah),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const TeksFunda.catatan('Sisa Anggaran'),
                          TeksFunda.label(
                            formatRupiah(ringkasan.totalSisaRupiah),
                            warna: ringkasan.totalSisaRupiah < 0
                                ? WarnaFunda.pengeluaran
                                : WarnaFunda.sukses,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: SpasiFunda.m),

            // Baris Ringkasan Per Sifat (Bento Grid)
            if (ringkasan.totalBatasRupiah > 0) ...[
              const TeksFunda.judulBagian('Ringkasan Alokasi Sifat'),
              const SizedBox(height: SpasiFunda.s),
              Row(
                children: [
                  Expanded(
                    child: _KartuMiniSifat(
                      label: 'Kebutuhan',
                      batas: ringkasan.totalKebutuhanBatasRupiah,
                      terpakai: ringkasan.totalKebutuhanTerpakaiRupiah,
                      warnaDasar: WarnaFunda.sifatKebutuhan,
                    ),
                  ),
                  const SizedBox(width: SpasiFunda.s),
                  Expanded(
                    child: _KartuMiniSifat(
                      label: 'Keinginan',
                      batas: ringkasan.totalKeinginanBatasRupiah,
                      terpakai: ringkasan.totalKeinginanTerpakaiRupiah,
                      warnaDasar: WarnaFunda.sifatKeinginan,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SpasiFunda.s),
              Row(
                children: [
                  Expanded(
                    child: _KartuMiniSifat(
                      label: 'Tabungan',
                      batas: ringkasan.totalTabunganBatasRupiah,
                      terpakai: ringkasan.totalTabunganTerpakaiRupiah,
                      warnaDasar: WarnaFunda.sifatTabungan,
                    ),
                  ),
                  const SizedBox(width: SpasiFunda.s),
                  Expanded(
                    child: _KartuMiniSifat(
                      label: 'Utang',
                      batas: ringkasan.totalUtangBatasRupiah,
                      terpakai: ringkasan.totalUtangTerpakaiRupiah,
                      warnaDasar: WarnaFunda.sifatUtang,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SpasiFunda.l),
            ],

            // Daftar Rincian Kategori yang Dianggarkan
            const TeksFunda.judulBagian('Kategori yang Dianggarkan'),
            const SizedBox(height: SpasiFunda.s),
            realisasiAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(SpasiFunda.xl),
                  child: IndikatorMemuat(),
                ),
              ),
              error: (e, _) => Center(child: Text('Terjadi kesalahan: $e')),
              data: (daftarItem) {
                if (daftarItem.isEmpty) {
                  return KeadaanKosong(
                    ikon: LucideIcons.pieChart,
                    judul: 'Belum Ada Anggaran',
                    pesan:
                        'Rencanakan pengeluaran bulan $namaBulan agar keuanganmu tetap tenang dan terkendali.',
                    teksTombol: 'Atur Anggaran Sekarang',
                    padaAksi: () => _bukaDialogAturAnggaran(
                      context,
                      ref,
                      daftarKategori,
                      periode.tahun,
                      periode.bulan,
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: daftarItem.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: SpasiFunda.s),
                  itemBuilder: (context, index) {
                    final item = daftarItem[index];
                    return _KartuItemAnggaran(
                      item: item,
                      padaKetuk: () => _bukaDialogAturAnggaran(
                        context,
                        ref,
                        daftarKategori,
                        periode.tahun,
                        periode.bulan,
                        anggaranLama: item,
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: SpasiFunda.xxl),
          ],
        ),
      ),
    );
  }

  void _bukaDialogAturAnggaran(
    BuildContext context,
    WidgetRef ref,
    List<EntitasKategori> daftarKategori,
    int tahun,
    int bulan, {
    ItemRealisasiAnggaran? anggaranLama,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: WarnaFunda.permukaan,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SudutFunda.lembar),
        ),
      ),
      builder: (ctx) => _LembarAturAnggaran(
        tahun: tahun,
        bulan: bulan,
        daftarKategori: daftarKategori,
        anggaranLama: anggaranLama,
        padaSelesai: () {
          ref.invalidate(penyediaRealisasiAnggaranBulan);
        },
      ),
    );
  }
}

class _KartuMiniSifat extends StatelessWidget {
  const _KartuMiniSifat({
    required this.label,
    required this.batas,
    required this.terpakai,
    required this.warnaDasar,
  });

  final String label;
  final int batas;
  final int terpakai;
  final Color warnaDasar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SpasiFunda.m),
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
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: warnaDasar,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: SpasiFunda.xs),
              TeksFunda.label(label),
            ],
          ),
          const SizedBox(height: SpasiFunda.xs),
          TeksFunda.catatan('Batas: ${formatRupiah(batas)}'),
          TeksFunda.catatan('Pakai: ${formatRupiah(terpakai)}'),
        ],
      ),
    );
  }
}

class _KartuItemAnggaran extends StatelessWidget {
  const _KartuItemAnggaran({required this.item, required this.padaKetuk});

  final ItemRealisasiAnggaran item;
  final VoidCallback padaKetuk;

  @override
  Widget build(BuildContext context) {
    Color warnaStatus;
    IconData ikonStatus;
    String labelStatus;

    switch (item.status) {
      case StatusAnggaran.aman:
        warnaStatus = WarnaFunda.sukses;
        ikonStatus = LucideIcons.circleCheck;
        labelStatus = 'Aman';
        break;
      case StatusAnggaran.mendekati:
        warnaStatus = WarnaFunda.peringatan;
        ikonStatus = LucideIcons.alertTriangle;
        labelStatus = 'Mendekati batas';
        break;
      case StatusAnggaran.melewati:
        warnaStatus = WarnaFunda.pengeluaran;
        ikonStatus = LucideIcons.alertCircle;
        labelStatus = 'Melebihi batas';
        break;
    }

    return InkWell(
      onTap: padaKetuk,
      borderRadius: BorderRadius.circular(SudutFunda.kartu),
      child: Container(
        padding: const EdgeInsets.all(SpasiFunda.m),
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
                  decoration: BoxDecoration(
                    color: WarnaFunda.latar,
                    borderRadius: BorderRadius.circular(SudutFunda.kecil),
                  ),
                  child: Icon(
                    ambilIkonLucide(item.kategoriIkon),
                    size: 20,
                    color: WarnaFunda.utama,
                  ),
                ),
                const SizedBox(width: SpasiFunda.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TeksFunda.label(item.kategoriNama),
                      Row(
                        children: [
                          Icon(ikonStatus, size: 12, color: warnaStatus),
                          const SizedBox(width: 4),
                          TeksFunda.catatan(labelStatus, warna: warnaStatus),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TeksFunda.label(
                      formatRupiah(item.terpakaiRupiah),
                      angkaTabular: true,
                    ),
                    TeksFunda.catatan('dari ${formatRupiah(item.batasRupiah)}'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: SpasiFunda.m),
            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(SudutFunda.pil),
              child: IndikatorMemuat.garis(
                nilai: (item.persentase / 100).clamp(0.0, 1.0),
                tinggi: 6,
                warnaLatar: WarnaFunda.garis,
                warna: warnaStatus,
              ),
            ),
            const SizedBox(height: SpasiFunda.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TeksFunda.catatan('${item.persentase}%'),
                TeksFunda.catatan(
                  item.sisaRupiah >= 0
                      ? 'Sisa ${formatRupiah(item.sisaRupiah)}'
                      : 'Lewat ${formatRupiah(item.sisaRupiah.abs())}',
                  warna: item.sisaRupiah < 0
                      ? WarnaFunda.pengeluaran
                      : WarnaFunda.teksRedup,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LembarAturAnggaran extends ConsumerStatefulWidget {
  const _LembarAturAnggaran({
    required this.tahun,
    required this.bulan,
    required this.daftarKategori,
    this.anggaranLama,
    required this.padaSelesai,
  });

  final int tahun;
  final int bulan;
  final List<EntitasKategori> daftarKategori;
  final ItemRealisasiAnggaran? anggaranLama;
  final VoidCallback padaSelesai;

  @override
  ConsumerState<_LembarAturAnggaran> createState() =>
      _LembarAturAnggaranState();
}

class _LembarAturAnggaranState extends ConsumerState<_LembarAturAnggaran> {
  late String? _kategoriTerpilihId;
  final _pengontrolNominal = TextEditingController();
  int _batasRupiah = 0;

  @override
  void initState() {
    super.initState();
    if (widget.anggaranLama != null) {
      _kategoriTerpilihId = widget.anggaranLama!.kategoriId;
      _batasRupiah = widget.anggaranLama!.batasRupiah;
      _pengontrolNominal.text = formatRupiah(_batasRupiah);
    } else {
      // Ambil kategori keluar pertama yang belum diarsipkan
      final kategoriKeluar = widget.daftarKategori
          .where((k) => k.arus == 'keluar' && !k.diarsipkan)
          .toList();
      _kategoriTerpilihId = kategoriKeluar.isNotEmpty
          ? kategoriKeluar.first.id
          : null;
    }
  }

  @override
  void dispose() {
    _pengontrolNominal.dispose();
    super.dispose();
  }

  void _padaUbahNominal(String teks) {
    final digit = teks.replaceAll(RegExp(r'[^0-9]'), '');
    final nilai = int.tryParse(digit) ?? 0;
    setState(() {
      _batasRupiah = nilai;
    });
  }

  @override
  Widget build(BuildContext context) {
    final repoAnggaran = ref.watch(penyediaAnggaranRepositori);
    final kategoriKeluar = widget.daftarKategori
        .where((k) => k.arus == 'keluar' && !k.diarsipkan)
        .toList();

    return Padding(
      padding: EdgeInsets.only(
        left: SpasiFunda.m,
        right: SpasiFunda.m,
        top: SpasiFunda.m,
        bottom: MediaQuery.of(context).viewInsets.bottom + SpasiFunda.m,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TeksFunda.judulBagian(
                widget.anggaranLama != null
                    ? 'Ubah Batas Anggaran'
                    : 'Atur Anggaran Kategori',
              ),
              IconButton(
                icon: const Icon(LucideIcons.x),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: SpasiFunda.m),
          // Pemilih Kategori (hanya jika buat baru)
          if (widget.anggaranLama == null) ...[
            const TeksFunda.label('Pilih Kategori'),
            const SizedBox(height: SpasiFunda.xs),
            DropdownButtonFormField<String>(
              initialValue: _kategoriTerpilihId,
              decoration: InputDecoration(
                filled: true,
                fillColor: WarnaFunda.latar,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SudutFunda.kecil),
                  borderSide: const BorderSide(color: WarnaFunda.garis),
                ),
              ),
              items: kategoriKeluar.map((k) {
                return DropdownMenuItem(
                  value: k.id,
                  child: Row(
                    children: [
                      Icon(ambilIkonLucide(k.ikon), size: 18),
                      const SizedBox(width: SpasiFunda.s),
                      Text(k.nama),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (id) => setState(() => _kategoriTerpilihId = id),
            ),
            const SizedBox(height: SpasiFunda.m),
          ],

          // Input Batas Nominal
          const TeksFunda.label('Batas Nominal Bulanan'),
          const SizedBox(height: SpasiFunda.xs),
          TextField(
            controller: _pengontrolNominal,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Rp 0',
              prefixIcon: const Icon(LucideIcons.walletCards),
              filled: true,
              fillColor: WarnaFunda.latar,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SudutFunda.kecil),
                borderSide: const BorderSide(color: WarnaFunda.garis),
              ),
            ),
            onChanged: _padaUbahNominal,
          ),
          const SizedBox(height: SpasiFunda.l),

          // Tombol Simpan & Hapus
          Row(
            children: [
              if (widget.anggaranLama != null) ...[
                Expanded(
                  child: TombolFunda.sekunder(
                    teks: 'Hapus Anggaran',
                    padaTekan: () async {
                      await repoAnggaran.hapusAnggaran(
                        widget.anggaranLama!.anggaranId,
                      );
                      widget.padaSelesai();
                      if (context.mounted) Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(width: SpasiFunda.m),
              ],
              Expanded(
                child: TombolFunda.primer(
                  teks: 'Simpan Anggaran',
                  padaTekan: _batasRupiah > 0 && _kategoriTerpilihId != null
                      ? () async {
                          await repoAnggaran.simpanAnggaran(
                            tahun: widget.tahun,
                            bulan: widget.bulan,
                            kategoriId: _kategoriTerpilihId!,
                            batasRupiah: _batasRupiah,
                          );
                          widget.padaSelesai();
                          if (context.mounted) Navigator.pop(context);
                        }
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: SpasiFunda.m),
        ],
      ),
    );
  }
}
