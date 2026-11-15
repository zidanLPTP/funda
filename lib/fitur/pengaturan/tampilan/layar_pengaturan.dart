import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../komponen/komponen_funda.dart';
import '../../../layanan/pengingat/penyedia_layanan_pengingat.dart';
import '../../../tema/token.dart';
import '../kontroler/penyedia_pengaturan.dart';

/// Layar Pengaturan Aplikasi (Pengingat Lokal, Jam Notifikasi, Privasi Nominal).
class LayarPengaturan extends ConsumerStatefulWidget {
  const LayarPengaturan({super.key});

  @override
  ConsumerState<LayarPengaturan> createState() => _LayarPengaturanState();
}

class _LayarPengaturanState extends ConsumerState<LayarPengaturan> {
  Future<void> _ubahStatusPengingat(bool aktif) async {
    final layananPengingat = ref.read(penyediaLayananPengingat);
    final notifier = ref.read(penyediaPengingatAktif.notifier);

    if (aktif) {
      final diizinkan = await layananPengingat.mintaIzin();
      if (!diizinkan) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Izin notifikasi belum diberikan. Kamu dapat mengaktifkannya melalui Pengaturan Perangkat.',
              ),
            ),
          );
        }
        return;
      }
    }

    await notifier.setelAktif(aktif);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            aktif
                ? 'Pengingat tagihan lokal aktif.'
                : 'Semua jadwal pengingat dibatalkan.',
          ),
        ),
      );
    }
  }

  Future<void> _pilihJamPengingat(String jamTeks) async {
    final bagian = jamTeks.split(':');
    final jamAwal = int.tryParse(bagian.first) ?? 9;
    final menitAwal = int.tryParse(bagian.last) ?? 0;

    final waktuBaru = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: jamAwal, minute: menitAwal),
    );

    if (waktuBaru != null && mounted) {
      await ref
          .read(penyediaJamPengingat.notifier)
          .setelJam(waktuBaru.hour, waktuBaru.minute);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Jam pengingat disetel ke ${waktuBaru.format(context)}.',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pengingatAktif = ref.watch(penyediaPengingatAktif);
    final jamPengingat = ref.watch(penyediaJamPengingat);
    final tampilkanNominal = ref.watch(penyediaTampilkanNominalNotifikasi);

    return Scaffold(
      backgroundColor: WarnaFunda.latar,
      appBar: AppBar(
        title: const TeksFunda.judulBagian('Pengaturan'),
        backgroundColor: WarnaFunda.latar,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(SpasiFunda.m),
          children: [
            // Grup 1: Pengingat Tagihan & Notifikasi Lokal
            PetakBento(
              anak: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(SpasiFunda.xs),
                        decoration: BoxDecoration(
                          color: WarnaFunda.permukaan,
                          borderRadius: BorderRadius.circular(SudutFunda.kecil),
                        ),
                        child: const Icon(
                          LucideIcons.bell,
                          color: WarnaFunda.utama,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: SpasiFunda.s),
                      const Expanded(
                        child: TeksFunda.label('Pengingat Jadwal Tagihan'),
                      ),
                    ],
                  ),
                  const SizedBox(height: SpasiFunda.s),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const TeksFunda.isi('Nyalakan Pengingat Lokal'),
                    subtitle: const TeksFunda.catatan(
                      'Kirimkan pemberitahuan ramah sebelum jatuh tempo tagihan tiba',
                    ),
                    value: pengingatAktif,
                    onChanged: (aktif) => _ubahStatusPengingat(aktif),
                  ),
                  if (pengingatAktif) ...[
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const TeksFunda.isi('Waktu Notifikasi Harian'),
                      subtitle: TeksFunda.catatan('Setiap pukul $jamPengingat'),
                      trailing: const Icon(LucideIcons.chevronRight, size: 20),
                      onTap: () => _pilihJamPengingat(jamPengingat),
                    ),
                    const Divider(),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const TeksFunda.isi(
                        'Tampilkan Nominal di Notifikasi',
                      ),
                      subtitle: const TeksFunda.catatan(
                        'Jika dimatikan, nominal rupiah disensor agar privasimu tetap aman di layar kunci',
                      ),
                      value: tampilkanNominal,
                      onChanged: (nilai) async {
                        await ref
                            .read(penyediaTampilkanNominalNotifikasi.notifier)
                            .setelTampilkanNominal(nilai);
                      },
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: SpasiFunda.m),

            // Grup 2: Transparansi Baterai & Privasi
            PetakBento(
              anak: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(SpasiFunda.xs),
                        decoration: BoxDecoration(
                          color: WarnaFunda.permukaan,
                          borderRadius: BorderRadius.circular(SudutFunda.kecil),
                        ),
                        child: const Icon(
                          LucideIcons.shieldCheck,
                          color: WarnaFunda.utama,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: SpasiFunda.s),
                      const Expanded(
                        child: TeksFunda.label('Privasi & Baterai Ramah'),
                      ),
                    ],
                  ),
                  const SizedBox(height: SpasiFunda.s),
                  const TeksFunda.catatan(
                    '1. 100% Berjalan Lokal di Perangkat\nSemua data tagihan dan jadwal pengingat tersimpan di SQLite lokal tanpa ada server pengirim.',
                  ),
                  const SizedBox(height: SpasiFunda.xs),
                  const TeksFunda.catatan(
                    '2. Hemat Energi (Inexact Alarm)\nNotifikasi menggunakan penjadwalan ramah baterai yang diselaraskan dengan siklus istirahat sistem operasi Android.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
