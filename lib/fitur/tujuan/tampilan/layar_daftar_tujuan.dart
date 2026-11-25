import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../data/basis_data.dart';
import '../../../data/model/jenis_tujuan.dart';
import '../../../komponen/komponen_funda.dart';
import '../../../komponen/pembantu_ikon.dart';
import '../../../komponen/pembantu_tint.dart';
import '../../../perhitungan/perhitungan_anggaran_tujuan.dart';
import '../../../tema/token.dart';
import '../../../util/format_rupiah.dart';
import '../kontroler/penyedia_tujuan.dart';
import 'layar_detail_tujuan.dart';
import 'layar_form_tujuan.dart';

/// Layar daftar seluruh tujuan finansial pengguna.
class LayarDaftarTujuan extends ConsumerWidget {
  const LayarDaftarTujuan({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daftarTujuanAsync = ref.watch(penyediaDaftarTujuanAktif);

    return Scaffold(
      backgroundColor: WarnaFunda.latar,
      appBar: AppBar(
        title: const TeksFunda.judulBagian('Tujuan Keuangan'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus),
            tooltip: 'Tambah Tujuan',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LayarFormTujuan()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: WarnaFunda.utama,
        foregroundColor: WarnaFunda.teksPutih,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LayarFormTujuan()),
          );
        },
        icon: const Icon(LucideIcons.plus, size: 20),
        label: const Text('Tambah Tujuan'),
      ),
      body: SafeArea(
        child: daftarTujuanAsync.when(
          loading: () => const Center(child: IndikatorMemuat()),
          error: (e, _) => Center(child: Text('Terjadi kesalahan: $e')),
          data: (daftar) {
            if (daftar.isEmpty) {
              return KeadaanKosong(
                ikon: LucideIcons.target,
                judul: 'Belum Ada Tujuan',
                pesan:
                    'Tetapkan impian keuanganmu, seperti Dana Darurat, Liburan, atau Tabungan Masa Depan.',
                teksTombol: 'Buat Tujuan Pertamamu',
                padaAksi: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LayarFormTujuan()),
                  );
                },
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(SpasiFunda.m),
              itemCount: daftar.length,
              separatorBuilder: (_, _) => const SizedBox(height: SpasiFunda.m),
              itemBuilder: (context, index) {
                final tujuan = daftar[index];
                return _KartuBentoTujuan(
                  tujuan: tujuan,
                  padaKetuk: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LayarDetailTujuan(tujuanId: tujuan.id),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _KartuBentoTujuan extends ConsumerWidget {
  const _KartuBentoTujuan({required this.tujuan, required this.padaKetuk});

  final EntitasTujuan tujuan;
  final VoidCallback padaKetuk;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final danaTerkumpulAsync = ref.watch(penyediaDanaTujuan(tujuan.id));
    final danaTerkumpul = danaTerkumpulAsync.value ?? 0;
    final progres = hitungProgresTujuan(
      danaRupiah: danaTerkumpul,
      targetRupiah: tujuan.targetRupiah,
    );
    final jenis = JenisTujuan.dariKode(tujuan.jenis);
    final sisa = tujuan.targetRupiah - danaTerkumpul;

    final warnaAksen = ambilWarnaAksenTint(tujuan.warna);

    return PetakBento.ukuran2x1(
      warnaKustom: ambilWarnaTint(tujuan.warna),
      warnaBatasKustom: ambilWarnaBatasTint(tujuan.warna),
      padaKetuk: padaKetuk,
      anak: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(SpasiFunda.s),
                decoration: BoxDecoration(
                  color: WarnaFunda.permukaan,
                  borderRadius: BorderRadius.circular(SudutFunda.kecil),
                ),
                child: Icon(
                  ambilIkonLucide(tujuan.ikon),
                  size: 20,
                  color: warnaAksen,
                ),
              ),
              const SizedBox(width: SpasiFunda.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TeksFunda.label(tujuan.nama),
                    TeksFunda.catatan(jenis.label),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: SpasiFunda.s,
                  vertical: SpasiFunda.xs,
                ),
                decoration: BoxDecoration(
                  color: WarnaFunda.permukaan,
                  borderRadius: BorderRadius.circular(SudutFunda.pil),
                ),
                child: TeksFunda.catatan(
                  '$progres%',
                  warna: progres >= 100 ? WarnaFunda.sukses : WarnaFunda.utama,
                ),
              ),
            ],
          ),
          const SizedBox(height: SpasiFunda.m),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TeksFunda.catatan('Terkumpul'),
                  TeksFunda.label(
                    formatRupiah(danaTerkumpul),
                    angkaTabular: true,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const TeksFunda.catatan('Target'),
                  TeksFunda.label(
                    formatRupiah(tujuan.targetRupiah),
                    angkaTabular: true,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: SpasiFunda.s),
          ClipRRect(
            borderRadius: BorderRadius.circular(SudutFunda.pil),
            child: IndikatorMemuat.garis(
              nilai: (progres / 100).clamp(0.0, 1.0),
              tinggi: 6,
              warnaLatar: WarnaFunda.garis,
              warna: progres >= 100 ? WarnaFunda.sukses : WarnaFunda.utama,
            ),
          ),
          const SizedBox(height: SpasiFunda.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (tujuan.tenggat != null)
                TeksFunda.catatan(
                  'Tenggat: ${DateFormat('d MMM yyyy', 'id_ID').format(tujuan.tenggat!)}',
                )
              else
                const TeksFunda.catatan('Tanpa tenggat'),
              TeksFunda.catatan(
                sisa > 0 ? 'Sisa ${formatRupiah(sisa)}' : 'Tercapai',
                warna: sisa <= 0 ? WarnaFunda.sukses : WarnaFunda.teksRedup,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
