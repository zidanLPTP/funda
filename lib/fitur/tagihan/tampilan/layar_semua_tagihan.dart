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

/// Layar daftar master seluruh tagihan & langganan (Aktif & Arsip).
class LayarSemuaTagihan extends ConsumerStatefulWidget {
  const LayarSemuaTagihan({super.key});

  @override
  ConsumerState<LayarSemuaTagihan> createState() => _LayarSemuaTagihanState();
}

class _LayarSemuaTagihanState extends ConsumerState<LayarSemuaTagihan> {
  bool _tampilkanArsip = false;

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

  @override
  Widget build(BuildContext context) {
    final semuaTagihanAsync = ref.watch(penyediaDaftarTagihan);
    final daftarKategori = ref.watch(penyediaDaftarKategori).value ?? [];

    return Scaffold(
      backgroundColor: WarnaFunda.latar,
      appBar: AppBar(
        title: const TeksFunda.judulBagian('Master Tagihan'),
        backgroundColor: WarnaFunda.latar,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _tampilkanArsip
                  ? LucideIcons.archiveRestore
                  : LucideIcons.archive,
              color: WarnaFunda.teks,
            ),
            tooltip: _tampilkanArsip ? 'Sembunyikan Arsip' : 'Lihat Arsip',
            onPressed: () => setState(() => _tampilkanArsip = !_tampilkanArsip),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: WarnaFunda.utama,
        foregroundColor: WarnaFunda.permukaan,
        onPressed: () => context.push('/tagihan/tambah'),
        icon: const Icon(LucideIcons.plus),
        label: const Text('Tambah Tagihan'),
      ),
      body: SafeArea(
        child: semuaTagihanAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Terjadi kesalahan: $err')),
          data: (daftar) {
            final disaring = daftar.where((t) {
              if (_tampilkanArsip) return true;
              return !t.diarsipkan;
            }).toList();

            if (disaring.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(SpasiFunda.l),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        LucideIcons.receipt,
                        size: 56,
                        color: WarnaFunda.teksRedup,
                      ),
                      const SizedBox(height: SpasiFunda.m),
                      TeksFunda.judulBagian(
                        _tampilkanArsip
                            ? 'Belum ada tagihan diarsipkan.'
                            : 'Belum ada tagihan terdaftar.',
                      ),
                      const SizedBox(height: SpasiFunda.s),
                      const Center(
                        child: TeksFunda.catatan(
                          'Catat tagihan dan langganan rutinmu agar selalu diingatkan tepat waktu.',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(SpasiFunda.m),
              itemCount: disaring.length,
              separatorBuilder: (context, _) =>
                  const SizedBox(height: SpasiFunda.jarakPetak),
              itemBuilder: (context, index) {
                final tagihan = disaring[index];
                final kategori = daftarKategori
                    .where((k) => k.id == tagihan.kategoriId)
                    .firstOrNull;
                final frekuensi = FrekuensiTagihan.dariKode(tagihan.frekuensi);
                final jenis = JenisTagihan.dariKode(tagihan.jenis);

                return PetakBento(
                  anak: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: tagihan.aktif
                                  ? WarnaFunda.tintHijau
                                  : WarnaFunda.latar,
                              borderRadius: BorderRadius.circular(
                                SudutFunda.kartu,
                              ),
                            ),
                            child: Icon(
                              kategori != null
                                  ? ambilIkonLucide(kategori.ikon)
                                  : (jenis == JenisTagihan.langganan
                                        ? LucideIcons.repeat
                                        : LucideIcons.receipt),
                              color: tagihan.aktif
                                  ? WarnaFunda.utama
                                  : WarnaFunda.teksRedup,
                              size: 22,
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
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: WarnaFunda.tintAmber,
                                          borderRadius: BorderRadius.circular(
                                            4,
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
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: WarnaFunda.latar,
                                          borderRadius: BorderRadius.circular(
                                            4,
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
                                TeksFunda.catatan(
                                  '${jenis.judul} • ${frekuensi.judul}',
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(
                              LucideIcons.ellipsisVertical,
                              size: 20,
                            ),
                            onSelected: (aksi) async {
                              final repo = ref.read(penyediaTagihanRepositori);
                              if (aksi == 'ubah') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        LayarFormTagihan(tagihan: tagihan),
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
                                    Text('Ubah Tagihan'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'jeda',
                                child: Row(
                                  children: [
                                    Icon(
                                      tagihan.aktif
                                          ? LucideIcons.pause
                                          : LucideIcons.play,
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      tagihan.aktif
                                          ? 'Jeda Pengingat'
                                          : 'Aktifkan Kembali',
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
                                    SizedBox(width: 8),
                                    Text(
                                      tagihan.diarsipkan
                                          ? 'Pulihkan dari Arsip'
                                          : 'Arsipkan',
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
                                    Text(
                                      'Hapus Permanen',
                                      style: TextStyle(
                                        color: WarnaFunda.pengeluaran,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: SpasiFunda.l),
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
                                    ? formatRupiah(
                                        tagihan.jumlahPerkiraanRupiah!,
                                      )
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
              },
            );
          },
        ),
      ),
    );
  }
}
