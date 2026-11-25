import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../data/basis_data.dart';
import '../../../data/model/jenis_dompet.dart';
import '../../../data/penyedia_data.dart';
import '../../../komponen/komponen_funda.dart';
import '../../../komponen/pembantu_ikon.dart';
import '../../../komponen/pembantu_tint.dart';
import '../../../tema/token.dart';
import '../../../util/format_rupiah.dart';
import 'layar_detail_dompet.dart';
import 'layar_form_dompet.dart';

/// Layar Daftar Dompet untuk mengelola semua akun keuangan.
class LayarDaftarDompet extends ConsumerWidget {
  const LayarDaftarDompet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daftarDompetAsync = ref.watch(penyediaDaftarDompet);
    final petaSaldo = ref.watch(penyediaPetaSaldoDompet);
    final totalSaldo = ref.watch(penyediaTotalSaldoAktif);

    return PembungkusLayar(
      appBar: AppBar(
        title: const TeksFunda.judulBagian('Daftar Dompet'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus),
            tooltip: 'Tambah Dompet',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LayarFormDompet()),
              );
            },
          ),
        ],
      ),
      bisaGulir: true,
      anak: daftarDompetAsync.when(
        loading: () => const Center(child: IndikatorMemuat()),
        error: (e, _) => Center(child: Text('Terjadi kesalahan: $e')),
        data: (daftar) {
          if (daftar.isEmpty) {
            return KeadaanKosong(
              ikon: LucideIcons.wallet,
              judul: 'Belum Ada Dompet',
              pesan:
                  'Kamu belum memiliki akun dompet. Buat dompet pertamamu untuk mulai mencatat keuangan.',
              teksTombol: 'Buat Dompet Pertama',
              padaAksi: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LayarFormDompet()),
                );
              },
            );
          }

          final dompetAktif = daftar.where((d) => !d.diarsipkan).toList();
          final dompetArsip = daftar.where((d) => d.diarsipkan).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ringkasan Total Saldo
              PetakBento.ukuran2x1(
                tint: TintPetakBento.hijau,
                anak: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TeksFunda.isiKecil(
                      'Total Saldo Seluruh Dompet Aktif',
                    ),
                    const SizedBox(height: SpasiFunda.s),
                    TeksFunda.angkaBesar(
                      formatRupiah(totalSaldo),
                      warna: totalSaldo < 0
                          ? WarnaFunda.pengeluaran
                          : WarnaFunda.teks,
                    ),
                    const SizedBox(height: SpasiFunda.xs),
                    TeksFunda.catatan(
                      '${dompetAktif.length} dompet aktif terdaftar',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: SpasiFunda.xl),

              // Daftar Dompet Aktif
              const TeksFunda.judulBagian('Dompet Aktif'),
              const SizedBox(height: SpasiFunda.m),
              ...dompetAktif.map(
                (dompet) => Padding(
                  padding: const EdgeInsets.only(bottom: SpasiFunda.m),
                  child: _ItemDompetBento(
                    dompet: dompet,
                    saldo: petaSaldo[dompet.id] ?? dompet.saldoAwalRupiah,
                    padaKetuk: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              LayarDetailDompet(dompetId: dompet.id),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Daftar Dompet Diarsipkan jika ada
              if (dompetArsip.isNotEmpty) ...[
                const SizedBox(height: SpasiFunda.l),
                const TeksFunda.judulBagian('Diarsipkan'),
                const SizedBox(height: SpasiFunda.m),
                ...dompetArsip.map(
                  (dompet) => Padding(
                    padding: const EdgeInsets.only(bottom: SpasiFunda.m),
                    child: _ItemDompetBento(
                      dompet: dompet,
                      saldo: petaSaldo[dompet.id] ?? dompet.saldoAwalRupiah,
                      padaKetuk: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                LayarDetailDompet(dompetId: dompet.id),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
              const SizedBox(height: SpasiFunda.xl),
            ],
          );
        },
      ),
    );
  }
}

class _ItemDompetBento extends StatelessWidget {
  const _ItemDompetBento({
    required this.dompet,
    required this.saldo,
    required this.padaKetuk,
  });

  final EntitasDompet dompet;
  final int saldo;
  final VoidCallback padaKetuk;

  @override
  Widget build(BuildContext context) {
    final jenis = JenisDompet.dariKode(dompet.jenis);

    return PetakBento.ukuran2x1(
      warnaKustom: ambilWarnaTint(dompet.warna),
      warnaBatasKustom: ambilWarnaBatasTint(dompet.warna),
      padaKetuk: padaKetuk,
      labelAkses: 'Dompet ${dompet.nama}, saldo ${formatRupiah(saldo)}',
      anak: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(SpasiFunda.m),
            decoration: BoxDecoration(
              color: WarnaFunda.permukaan,
              borderRadius: BorderRadius.circular(SudutFunda.kartu),
            ),
            child: Icon(
              ambilIkonLucide(dompet.ikon),
              size: 24,
              color: ambilWarnaAksenTint(dompet.warna),
            ),
          ),
          const SizedBox(width: SpasiFunda.l),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TeksFunda.label(dompet.nama),
                const SizedBox(height: SpasiFunda.xs),
                TeksFunda.catatan(jenis.label),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TeksFunda.label(
                formatRupiah(saldo),
                warna: saldo < 0 ? WarnaFunda.pengeluaran : WarnaFunda.teks,
                angkaTabular: true,
              ),
              if (dompet.diarsipkan) ...[
                const SizedBox(height: SpasiFunda.xs),
                const TeksFunda.catatan(
                  'Diarsipkan',
                  warna: WarnaFunda.peringatan,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
