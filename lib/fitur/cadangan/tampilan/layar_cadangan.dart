import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../data/cadangan/format_cadangan.dart';
import '../../../komponen/komponen_funda.dart';
import '../../../perhitungan/perhitungan_laporan_bulanan.dart';
import '../../../tema/token.dart';
import '../kontroler/penyedia_cadangan.dart';

/// Typedef fungsi pemilih berkas agar dapat disuntikkan implementasi mock pada pengujian widget/E2E.
typedef PemilihBerkasJson = Future<String?> Function();

Future<String?> pemilihBerkasBawaan() async {
  final hasil = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['json'],
  );
  if (hasil.isNotEmpty && hasil.first.path != null) {
    final berkas = File(hasil.first.path!);
    return berkas.readAsString();
  }
  return null;
}

final penyediaPemilihBerkas = Provider<PemilihBerkasJson>((ref) {
  return pemilihBerkasBawaan;
});

/// Layar Cadangan & Pemulihan: Mengelola ekspor berkas JSON, pemulihan atomik, dan rollback keselamatan.
class LayarCadangan extends ConsumerStatefulWidget {
  const LayarCadangan({super.key});

  @override
  ConsumerState<LayarCadangan> createState() => _LayarCadanganState();
}

class _LayarCadanganState extends ConsumerState<LayarCadangan> {
  bool _sedangMemproses = false;

  Future<void> _buatCadangan() async {
    setState(() => _sedangMemproses = true);
    try {
      await buatDanBagikanCadangan(ref);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Berkas cadangan berhasil dibuat dan siap dibagikan.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e, s) {
      debugPrint('GALAT DI _BUATCADANGAN: $e\n$s');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuat cadangan: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _sedangMemproses = false);
    }
  }

  Future<void> _pilihDanPulihkanBerkas() async {
    final pemilih = ref.read(penyediaPemilihBerkas);
    final jsonStr = await pemilih();
    if (jsonStr == null || !mounted) return;

    final repo = ref.read(penyediaCadanganRepositori);

    try {
      final validasi = await repo.validasiDanBuatPratinjau(jsonStr);
      if (!mounted) return;
      await _tampilkanDialogPratinjauPemulihan(validasi.dokumen, validasi.pratinjau);
    } catch (e, s) {
      debugPrint('GALAT DI _BUATCADANGAN: $e\n$s');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _tampilkanDialogPratinjauPemulihan(
    DokumenCadanganFunda doc,
    PratinjauCadangan pratinjau,
  ) async {
    final konfirmasiPertama = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pratinjau Data Cadangan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Dibuat pada: ${formatBulanTahunIndonesia(pratinjau.dibuatPada)} (${pratinjau.dibuatPada.day} ${_namaBulan(pratinjau.dibuatPada.month)} ${pratinjau.dibuatPada.year})', style: const TextStyle(fontSize: 12)),
              Text('Versi Aplikasi: ${pratinjau.versiAplikasi} (Skema ${pratinjau.versiSkema})', style: const TextStyle(fontSize: 12)),
              const Divider(height: 16),
              const Text('Rincian Data Tersimpan:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('• Dompet: ${pratinjau.jumlahDompet}', style: const TextStyle(fontSize: 12)),
              Text('• Transaksi: ${pratinjau.jumlahTransaksi}', style: const TextStyle(fontSize: 12)),
              Text('• Pos Anggaran: ${pratinjau.jumlahAnggaran}', style: const TextStyle(fontSize: 12)),
              Text('• Tujuan Keuangan: ${pratinjau.jumlahTujuan}', style: const TextStyle(fontSize: 12)),
              Text('• Utang & Cicilan: ${pratinjau.jumlahUtang}', style: const TextStyle(fontSize: 12)),
              Text('• Jadwal Tagihan: ${pratinjau.jumlahTagihan}', style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: WarnaFunda.bahaya.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: WarnaFunda.bahaya.withValues(alpha: 0.3)),
                ),
                child: const Text(
                  'Peringatan: Memulihkan cadangan akan MENGGANTI semua data yang ada sekarang.',
                  style: TextStyle(fontSize: 11, color: WarnaFunda.bahaya, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: WarnaFunda.bahaya),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Lanjut Pulihkan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (konfirmasiPertama != true || !mounted) return;

    // Langkah konfirmasi kedua (eksplisit)
    final konfirmasiKedua = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Penggantian Data', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: const Text(
          'Yakin ingin menimpa seluruh data saat ini? Data lama akan disimpan otomatis di cadangan keselamatan.',
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: WarnaFunda.bahaya),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Pulihkan Sekarang', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (konfirmasiKedua != true || !mounted) return;

    setState(() => _sedangMemproses = true);
    try {
      final repo = ref.read(penyediaCadanganRepositori);
      await repo.pulihkanCadangan(doc, simpanKeselamatanOtomatis: true);

      // Invalidate semua provider yang relevan
      ref.invalidate(penyediaStatusCadangan);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil dipulihkan dari cadangan.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e, s) {
      debugPrint('GALAT DI _BUATCADANGAN: $e\n$s');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memulihkan cadangan: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _sedangMemproses = false);
    }
  }

  Future<void> _kembalikanSebelumPemulihan() async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kembalikan Data Sebelumnya?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: const Text(
          'Aplikasi akan memulihkan data yang tersimpan sesaat sebelum pemulihan terakhir kali dijalankan.',
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Kembalikan'),
          ),
        ],
      ),
    );

    if (konfirmasi != true || !mounted) return;

    setState(() => _sedangMemproses = true);
    try {
      final repo = ref.read(penyediaCadanganRepositori);
      await repo.pulihkanDariCadanganKeselamatan();
      ref.invalidate(penyediaStatusCadangan);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data sebelum pemulihan terakhir berhasil dikembalikan.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e, s) {
      debugPrint('GALAT DI _BUATCADANGAN: $e\n$s');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengembalikan data: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _sedangMemproses = false);
    }
  }

  static String _namaBulan(int b) {
    const bulan = ['', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    return bulan[b];
  }

  @override
  Widget build(BuildContext context) {
    final asyncStatus = ref.watch(penyediaStatusCadangan);

    return Scaffold(
      backgroundColor: WarnaFunda.latar,
      appBar: AppBar(
        title: const Text('Cadangan & Pemulihan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: WarnaFunda.latar,
        elevation: 0,
        foregroundColor: WarnaFunda.teks,
      ),
      body: asyncStatus.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Gagal memuat status: $err')),
        data: (status) {
          final teksStatus = status.terakhirDicadangkan != null
              ? 'Terakhir dicadangkan: ${status.terakhirDicadangkan!.day} ${_namaBulan(status.terakhirDicadangkan!.month)} ${status.terakhirDicadangkan!.year}'
              : 'Belum pernah dicadangkan';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Status Cadangan
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: WarnaFunda.permukaan,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: WarnaFunda.garis),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: status.terakhirDicadangkan != null ? WarnaFunda.sukses.withValues(alpha: 0.12) : WarnaFunda.garis,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          status.terakhirDicadangkan != null ? LucideIcons.checkCircle2 : LucideIcons.clock,
                          color: status.terakhirDicadangkan != null ? WarnaFunda.sukses : WarnaFunda.teksRedup,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Status Cadangan Data', style: TextStyle(fontSize: 12, color: WarnaFunda.teksRedup)),
                            const SizedBox(height: 3),
                            Text(
                              teksStatus,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: WarnaFunda.teks),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Tombol Aksi Utama
                TombolFunda.primer(
                  teks: 'Buat Cadangan dan Bagikan',
                  ikon: const Icon(LucideIcons.uploadCloud, size: 18),
                  memuat: _sedangMemproses,
                  padaTekan: _sedangMemproses ? null : _buatCadangan,
                  lebarPenuh: true,
                ),
                const SizedBox(height: 10),
                TombolFunda.sekunder(
                  teks: 'Pulihkan dari Berkas',
                  ikon: const Icon(LucideIcons.downloadCloud, size: 18),
                  memuat: _sedangMemproses,
                  padaTekan: _sedangMemproses ? null : _pilihDanPulihkanBerkas,
                  lebarPenuh: true,
                ),

                // 3. Tombol Cadangan Keselamatan (jika ada)
                if (status.adaCadanganKeselamatan) ...[
                  const SizedBox(height: 10),
                  TombolFunda.teks(
                    teks: 'Kembalikan Data Sebelum Pemulihan Terakhir',
                    ikon: const Icon(LucideIcons.undo2, size: 18),
                    memuat: _sedangMemproses,
                    padaTekan: _sedangMemproses ? null : _kembalikanSebelumPemulihan,
                    lebarPenuh: true,
                  ),
                ],
                const SizedBox(height: 20),

                // 4. Peringatan Privasi
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: WarnaFunda.permukaan,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: WarnaFunda.garis),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(LucideIcons.shieldAlert, size: 20, color: WarnaFunda.teksRedup),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Berkas cadangan berisi seluruh data keuanganmu dan tidak dienkripsi. Simpan hanya di tempat yang aman.',
                          style: TextStyle(fontSize: 11.5, color: WarnaFunda.teksRedup, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
