import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../data/basis_data.dart';
import '../../../data/model/frekuensi_tagihan.dart';
import '../../../data/model/jenis_tagihan.dart';
import '../../../data/penyedia_data.dart';
import '../../../komponen/komponen_funda.dart';
import '../../../komponen/pembantu_ikon.dart';
import '../../../tema/token.dart';
import '../../../util/format_rupiah.dart';
import '../kontroler/penyedia_tagihan.dart';
import 'layar_form_tagihan.dart';

/// Layar daftar master seluruh tagihan & langganan (Aktif & Arsip) bergaya editorial.
class LayarSemuaTagihan extends ConsumerStatefulWidget {
  const LayarSemuaTagihan({super.key});

  @override
  ConsumerState<LayarSemuaTagihan> createState() => _LayarSemuaTagihanState();
}

class _LayarSemuaTagihanState extends ConsumerState<LayarSemuaTagihan> {
  bool _tampilkanArsip = false;

  void _bukaFormTambah() {
    final router = GoRouter.maybeOf(context);
    if (router != null) {
      context.push('/tagihan/tambah');
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LayarFormTagihan()),
      );
    }
  }

  Future<void> _konfirmasiHapus(
    BuildContext context,
    EntitasTagihan tagihan,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final setuju = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const TeksFunda.judulBagian('Hapus Tagihan?'),
        content: TeksFunda.isi(
          'Tagihan "${tagihan.nama}" akan dihapus permanen. Aksi ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: WarnaFunda.pengeluaran,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (setuju == true) {
      try {
        await ref
            .read(penyediaTagihanRepositori)
            .hapusTagihanPermanen(tagihan.id);
        await sinkronkanPengingatLokal(ref);
        messenger.showSnackBar(
          SnackBar(
            content: Text('Tagihan "${tagihan.nama}" berhasil dihapus.'),
          ),
        );
      } catch (e) {
        messenger.showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
      }
    }
  }

  Widget _bangunBarisTagihan(
    BuildContext context,
    EntitasTagihan tagihan,
    List<EntitasKategori> daftarKategori,
  ) {
    final kategori = daftarKategori
        .where((k) => k.id == tagihan.kategoriId)
        .firstOrNull;
    final frekuensi = FrekuensiTagihan.dariKode(tagihan.frekuensi);
    final jenis = JenisTagihan.dariKode(tagihan.jenis);

    return Padding(
      padding: const EdgeInsets.all(SpasiFunda.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  kategori != null
                      ? ambilIkonLucide(kategori.ikon)
                      : (jenis == JenisTagihan.langganan
                            ? LucideIcons.repeat
                            : LucideIcons.receipt),
                  color: tagihan.aktif
                      ? WarnaFunda.utama
                      : WarnaFunda.teksRedup,
                  size: 20,
                ),
              ),
              const SizedBox(width: SpasiFunda.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: SpasiFunda.xs,
                      runSpacing: SpasiFunda.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        TeksFunda.label(tagihan.nama),
                        if (!tagihan.aktif)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: SpasiFunda.s,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: WarnaFunda.tintAmber,
                              borderRadius: BorderRadius.circular(
                                SudutFunda.pil,
                              ),
                            ),
                            child: const TeksFunda.catatan(
                              'Dijeda',
                              warna: WarnaFunda.teks,
                            ),
                          ),
                        if (tagihan.diarsipkan)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: SpasiFunda.s,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: WarnaFunda.latar,
                              borderRadius: BorderRadius.circular(
                                SudutFunda.pil,
                              ),
                            ),
                            child: const TeksFunda.catatan(
                              'Arsip',
                              warna: WarnaFunda.teksRedup,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: SpasiFunda.xs),
                    TeksFunda.catatan('${jenis.judul} • ${frekuensi.judul}'),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(LucideIcons.ellipsisVertical, size: 20),
                onSelected: (aksi) async {
                  final repo = ref.read(penyediaTagihanRepositori);
                  if (aksi == 'ubah') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LayarFormTagihan(tagihan: tagihan),
                      ),
                    );
                  } else if (aksi == 'jeda') {
                    await repo.ubahStatusAktifTagihan(
                      tagihan.id,
                      !tagihan.aktif,
                    );
                    await sinkronkanPengingatLokal(ref);
                  } else if (aksi == 'arsip') {
                    if (tagihan.diarsipkan) {
                      await repo.perbaruiTagihan(
                        TabelTagihanCompanion(
                          id: drift.Value(tagihan.id),
                          diarsipkan: const drift.Value(false),
                          aktif: const drift.Value(true),
                        ),
                      );
                    } else {
                      await repo.arsipkanTagihan(tagihan.id);
                    }
                    await sinkronkanPengingatLokal(ref);
                  } else if (aksi == 'hapus') {
                    _konfirmasiHapus(context, tagihan);
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: 'ubah',
                    child: Row(
                      children: [
                        Icon(LucideIcons.pencil, size: 18),
                        SizedBox(width: 8),
                        Expanded(child: Text('Ubah Tagihan')),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'jeda',
                    child: Row(
                      children: [
                        Icon(
                          tagihan.aktif ? LucideIcons.pause : LucideIcons.play,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            tagihan.aktif
                                ? 'Jeda Pengingat'
                                : 'Aktifkan Kembali',
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'arsip',
                    child: Row(
                      children: [
                        Icon(
                          tagihan.diarsipkan
                              ? LucideIcons.archiveRestore
                              : LucideIcons.archive,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            tagihan.diarsipkan
                                ? 'Pulihkan dari Arsip'
                                : 'Arsipkan',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'hapus',
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.trash2,
                          size: 18,
                          color: WarnaFunda.pengeluaran,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Hapus Permanen',
                            style: TextStyle(color: WarnaFunda.pengeluaran),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: SpasiFunda.m),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: SpasiFunda.m,
            runSpacing: SpasiFunda.s,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TeksFunda.catatan('Perkiraan Nominal'),
                  const SizedBox(height: SpasiFunda.xs),
                  TeksFunda.label(
                    tagihan.jumlahPerkiraanRupiah != null &&
                            tagihan.jumlahPerkiraanRupiah! > 0
                        ? formatRupiah(tagihan.jumlahPerkiraanRupiah!)
                        : 'Fluktuatif (-)',
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TeksFunda.catatan('Jatuh Tempo Awal'),
                  const SizedBox(height: SpasiFunda.xs),
                  TeksFunda.catatan(
                    DateFormat(
                      'd MMM yyyy',
                      'id_ID',
                    ).format(tagihan.jatuhTempoPertama.toLocal()),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final semuaTagihanAsync = ref.watch(penyediaDaftarTagihan);
    final daftarKategori = ref.watch(penyediaDaftarKategori).value ?? [];

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
              child: HeaderSubLayarEditorial(
                judul: 'Master Tagihan',
                aksiKanan: [
                  IconButton(
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                    icon: Icon(
                      _tampilkanArsip
                          ? LucideIcons.archiveRestore
                          : LucideIcons.archive,
                      color: WarnaFunda.teks,
                      size: 20,
                    ),
                    tooltip: _tampilkanArsip
                        ? 'Sembunyikan Arsip'
                        : 'Lihat Arsip',
                    onPressed: () =>
                        setState(() => _tampilkanArsip = !_tampilkanArsip),
                  ),
                  TombolPilHeaderEditorial(
                    key: const Key('tombol_tambah_tagihan_master'),
                    teks: 'Tambah',
                    ikon: LucideIcons.plus,
                    warnaTeks: WarnaFunda.teksPutih,
                    warnaLatar: WarnaFunda.tombolGelap,
                    warnaBatas: WarnaFunda.tombolGelap,
                    padaTekan: _bukaFormTambah,
                  ),
                ],
              ),
            ),
            Expanded(
              child: semuaTagihanAsync.when(
                loading: () => const Center(child: IndikatorMemuat()),
                error: (err, _) =>
                    Center(child: Text('Terjadi kesalahan: $err')),
                data: (daftar) {
                  final disaring = daftar.where((t) {
                    if (_tampilkanArsip) return true;
                    return !t.diarsipkan;
                  }).toList();

                  if (disaring.isEmpty) {
                    return ListView(
                      padding: const EdgeInsets.all(SpasiFunda.marginLayar),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(SpasiFunda.xl),
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
                          child: Column(
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: SpasiFunda.m,
                                ),
                                decoration: BoxDecoration(
                                  color: WarnaFunda.kanvasBiru,
                                  borderRadius: BorderRadius.circular(
                                    SudutFunda.kartu,
                                  ),
                                ),
                                child: const Center(
                                  child: IlustrasiSvgFunda(
                                    pathAset: AsetIlustrasiFunda.tagihanTenang,
                                    tinggi: 92,
                                  ),
                                ),
                              ),
                              const SizedBox(height: SpasiFunda.m),
                              TeksFunda.judulBagian(
                                _tampilkanArsip
                                    ? 'Belum ada tagihan diarsipkan.'
                                    : 'Belum ada tagihan terdaftar.',
                                rataTeks: TextAlign.center,
                              ),
                              const SizedBox(height: SpasiFunda.s),
                              const TeksFunda.catatan(
                                'Catat tagihan dan langganan rutinmu agar selalu diingatkan tepat waktu.',
                                rataTeks: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(
                      SpasiFunda.marginLayar,
                      SpasiFunda.xs,
                      SpasiFunda.marginLayar,
                      SpasiFunda.xl,
                    ),
                    children: [
                      Container(
                        key: const Key('kartu_master_tagihan'),
                        decoration: BoxDecoration(
                          color: WarnaFunda.permukaan,
                          borderRadius: BorderRadius.circular(SudutFunda.kartu),
                          border: Border.all(
                            color: WarnaFunda.garis,
                            width: 1.0,
                          ),
                        ),
                        child: Column(
                          children: [
                            for (var i = 0; i < disaring.length; i++) ...[
                              if (i > 0)
                                const Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: WarnaFunda.garis,
                                ),
                              _bangunBarisTagihan(
                                context,
                                disaring[i],
                                daftarKategori,
                              ),
                            ],
                          ],
                        ),
                      ),
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
}
