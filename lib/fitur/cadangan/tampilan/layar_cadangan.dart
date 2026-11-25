import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
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

/// Layar Cadangan & Pemulihan bergaya editorial bersih:
/// header tombol kembali >= 48dp, hero kanvas status, kartu aksi putih 1px,
/// dan peringatan privasi yang jelas.
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
      if (kDebugMode) {
        debugPrint('GALAT DI _BUATCADANGAN: $e\n$s');
      }
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
      await _tampilkanDialogPratinjauPemulihan(
        validasi.dokumen,
        validasi.pratinjau,
      );
    } catch (e, s) {
      if (kDebugMode) {
        debugPrint('GALAT DI _BUATCADANGAN: $e\n$s');
      }
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
        title: const TeksFunda.judulBagian('Pratinjau Data Cadangan'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TeksFunda.catatan(
                'Dibuat pada: ${formatBulanTahunIndonesia(pratinjau.dibuatPada)} (${pratinjau.dibuatPada.day} ${_namaBulan(pratinjau.dibuatPada.month)} ${pratinjau.dibuatPada.year})',
              ),
              TeksFunda.catatan(
                'Versi Aplikasi: ${pratinjau.versiAplikasi} (Skema ${pratinjau.versiSkema})',
              ),
              const Divider(height: SpasiFunda.l, color: WarnaFunda.garis),
              const TeksFunda.label('Rincian Data Tersimpan:'),
              const SizedBox(height: SpasiFunda.xs),
              TeksFunda.catatan('• Dompet: ${pratinjau.jumlahDompet}'),
              TeksFunda.catatan('• Transaksi: ${pratinjau.jumlahTransaksi}'),
              TeksFunda.catatan('• Pos Anggaran: ${pratinjau.jumlahAnggaran}'),
              TeksFunda.catatan('• Tujuan Keuangan: ${pratinjau.jumlahTujuan}'),
              TeksFunda.catatan('• Utang & Cicilan: ${pratinjau.jumlahUtang}'),
              TeksFunda.catatan('• Jadwal Tagihan: ${pratinjau.jumlahTagihan}'),
              const SizedBox(height: SpasiFunda.m),
              Container(
                padding: const EdgeInsets.all(SpasiFunda.s),
                decoration: BoxDecoration(
                  color: WarnaFunda.tintMawar,
                  borderRadius: BorderRadius.circular(SudutFunda.kecil),
                  border: Border.all(color: WarnaFunda.batasMawar),
                ),
                child: const TeksFunda.catatan(
                  'Peringatan: Memulihkan cadangan akan MENGGANTI semua data yang ada sekarang.',
                  warna: WarnaFunda.bahaya,
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
            child: const Text(
              'Lanjut Pulihkan',
              style: TextStyle(color: WarnaFunda.putih),
            ),
          ),
        ],
      ),
    );

    if (konfirmasiPertama != true || !mounted) return;

    // Langkah konfirmasi kedua (eksplisit)
    final konfirmasiKedua = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const TeksFunda.judulBagian('Konfirmasi Penggantian Data'),
        content: const TeksFunda.isiKecil(
          'Yakin ingin menimpa seluruh data saat ini? Data lama akan disimpan otomatis di cadangan keselamatan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: WarnaFunda.bahaya),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Ya, Pulihkan Sekarang',
              style: TextStyle(color: WarnaFunda.putih),
            ),
          ),
        ],
      ),
    );

    if (konfirmasiKedua != true || !mounted) return;

    setState(() => _sedangMemproses = true);
    try {
      final repo = ref.read(penyediaCadanganRepositori);
      await repo.pulihkanCadangan(doc, simpanKeselamatanOtomatis: true);

      ref.invalidate(penyediaStatusCadangan);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil dipulihkan dari cadangan.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e, s) {
      if (kDebugMode) {
        debugPrint('GALAT DI _BUATCADANGAN: $e\n$s');
      }
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
        title: const TeksFunda.judulBagian('Kembalikan Data Sebelumnya?'),
        content: const TeksFunda.isiKecil(
          'Aplikasi akan memulihkan data yang tersimpan sesaat sebelum pemulihan terakhir kali dijalankan.',
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
          content: Text(
            'Data sebelum pemulihan terakhir berhasil dikembalikan.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e, s) {
      if (kDebugMode) {
        debugPrint('GALAT DI _BUATCADANGAN: $e\n$s');
      }
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
    const bulan = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return bulan[b];
  }

  @override
  Widget build(BuildContext context) {
    final asyncStatus = ref.watch(penyediaStatusCadangan);

    return Scaffold(
      backgroundColor: WarnaFunda.latar,
      body: SafeArea(
        child: asyncStatus.when(
          loading: () => const Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  SpasiFunda.marginLayar,
                  SpasiFunda.marginLayar,
                  SpasiFunda.marginLayar,
                  0,
                ),
                child: HeaderSubLayarEditorial(judul: 'Cadangan & Pemulihan'),
              ),
              Expanded(child: Center(child: IndikatorMemuat())),
            ],
          ),
          error: (err, _) => Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(
                  SpasiFunda.marginLayar,
                  SpasiFunda.marginLayar,
                  SpasiFunda.marginLayar,
                  0,
                ),
                child: HeaderSubLayarEditorial(judul: 'Cadangan & Pemulihan'),
              ),
              Expanded(child: Center(child: Text('Gagal memuat status: $err'))),
            ],
          ),
          data: (status) {
            final sudahDicadangkan = status.terakhirDicadangkan != null;
            final teksStatus = sudahDicadangkan
                ? 'Terakhir dicadangkan: ${status.terakhirDicadangkan!.day} ${_namaBulan(status.terakhirDicadangkan!.month)} ${status.terakhirDicadangkan!.year}'
                : 'Belum pernah dicadangkan';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(SpasiFunda.marginLayar),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const HeaderSubLayarEditorial(judul: 'Cadangan & Pemulihan'),
                  const SizedBox(height: SpasiFunda.m),

                  // 1. Hero Kanvas Status Cadangan Data
                  Container(
                    key: const Key('hero_kanvas_cadangan'),
                    padding: const EdgeInsets.all(SpasiFunda.l),
                    decoration: BoxDecoration(
                      color: sudahDicadangkan
                          ? WarnaFunda.kanvasMint
                          : WarnaFunda.kanvasKuning,
                      borderRadius: BorderRadius.circular(SudutFunda.petak),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          sudahDicadangkan
                              ? LucideIcons.circleCheck
                              : LucideIcons.clock,
                          color: sudahDicadangkan
                              ? WarnaFunda.pemasukan
                              : WarnaFunda.peringatan,
                          size: 28,
                        ),
                        const SizedBox(width: SpasiFunda.m),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const TeksFunda.catatan(
                                'Status Cadangan Data',
                                warna: WarnaFunda.teksRedup,
                              ),
                              const SizedBox(height: SpasiFunda.xs),
                              TeksFunda.judulBagian(teksStatus),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: SpasiFunda.m),

                  // 2. Kartu Aksi Utama Putih Border 1px
                  Container(
                    padding: const EdgeInsets.all(SpasiFunda.l),
                    decoration: BoxDecoration(
                      color: WarnaFunda.permukaan,
                      borderRadius: BorderRadius.circular(SudutFunda.petak),
                      border: Border.all(color: WarnaFunda.garis, width: 1.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TombolFunda.pilGelap(
                          teks: 'Buat Cadangan dan Bagikan',
                          ikon: const Icon(LucideIcons.upload, size: 18),
                          memuat: _sedangMemproses,
                          padaTekan: _sedangMemproses ? null : _buatCadangan,
                          lebarPenuh: true,
                        ),
                        const SizedBox(height: SpasiFunda.s),
                        TombolFunda.sekunder(
                          teks: 'Pulihkan dari Berkas',
                          ikon: const Icon(LucideIcons.download, size: 18),
                          memuat: _sedangMemproses,
                          padaTekan: _sedangMemproses
                              ? null
                              : _pilihDanPulihkanBerkas,
                          lebarPenuh: true,
                        ),

                        // 3. Tombol Cadangan Keselamatan (bila tersedia)
                        if (status.adaCadanganKeselamatan) ...[
                          const SizedBox(height: SpasiFunda.s),
                          TombolFunda.teks(
                            teks: 'Kembalikan Data Sebelum Pemulihan Terakhir',
                            ikon: const Icon(LucideIcons.undo2, size: 18),
                            memuat: _sedangMemproses,
                            padaTekan: _sedangMemproses
                                ? null
                                : _kembalikanSebelumPemulihan,
                            lebarPenuh: true,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: SpasiFunda.m),

                  // 4. Peringatan Privasi
                  Container(
                    padding: const EdgeInsets.all(SpasiFunda.l),
                    decoration: BoxDecoration(
                      color: WarnaFunda.permukaan,
                      borderRadius: BorderRadius.circular(SudutFunda.petak),
                      border: Border.all(
                        color: WarnaFunda.batasAmber,
                        width: 1.0,
                      ),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          LucideIcons.shieldAlert,
                          size: 20,
                          color: WarnaFunda.peringatan,
                        ),
                        SizedBox(width: SpasiFunda.m),
                        Expanded(
                          child: TeksFunda.catatan(
                            'Berkas cadangan berisi seluruh data keuanganmu dan tidak dienkripsi. Simpan hanya di tempat yang aman.',
                            warna: WarnaFunda.teksRedup,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: SpasiFunda.xl),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
