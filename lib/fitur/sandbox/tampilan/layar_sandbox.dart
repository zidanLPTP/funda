import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../komponen/komponen_funda.dart';
import '../../../perhitungan/perhitungan_umpan_balik_belajar.dart';
import '../../../tema/token.dart';
import '../kontroler/penyedia_sandbox.dart';

/// Layar Mode Sandbox edukasi investasi dengan portofolio uang fiktif.
///
/// Seluruh data dan simulasi di layar ini TERISOLASI TOTAL dari data asli pengguna.
class LayarSandbox extends ConsumerStatefulWidget {
  const LayarSandbox({super.key});

  @override
  ConsumerState<LayarSandbox> createState() => _LayarSandboxState();
}

class _LayarSandboxState extends ConsumerState<LayarSandbox> {
  bool _disclaimerDilipat = false;

  @override
  Widget build(BuildContext context) {
    final keadaan = ref.watch(penyediaSandbox);
    final notifier = ref.read(penyediaSandbox.notifier);

    return PembungkusLayar(
      appBar: AppBar(
        title: const TeksFunda.judulBagian('Mode Sandbox'),
        actions: [
          Semantics(
            button: true,
            label: 'Atur ulang simulasi',
            child: TextButton.icon(
              key: const Key('tombol_reset_sandbox'),
              onPressed: () => _konfirmasiReset(context, notifier),
              icon: const Icon(LucideIcons.rotateCcw, size: 18),
              label: const Text('Reset'),
              style: TextButton.styleFrom(
                minimumSize: const Size(48, 48),
                foregroundColor: WarnaFunda.teksRedup,
              ),
            ),
          ),
        ],
      ),
      bisaGulir: true,
      anak: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Banner Penanda Mode Sandbox Uang Fiktif (tintAmber)
          Semantics(
            container: true,
            label: 'Peringatan mode sandbox uang fiktif',
            child: Container(
              key: const Key('banner_mode_sandbox'),
              padding: const EdgeInsets.symmetric(
                horizontal: SpasiFunda.m,
                vertical: SpasiFunda.s,
              ),
              decoration: BoxDecoration(
                color: WarnaFunda.tintAmber,
                borderRadius: BorderRadius.circular(SudutFunda.kartu),
                border: Border.all(color: WarnaFunda.aksen, width: 1.5),
              ),
              child: const Row(
                children: [
                  Icon(
                    LucideIcons.flaskConical,
                    color: WarnaFunda.peringatan,
                    size: 22,
                  ),
                  SizedBox(width: SpasiFunda.s),
                  Expanded(
                    child: Text(
                      'Mode Sandbox — Uang Fiktif (Simulasi, bukan prediksi)',
                      style: TextStyle(
                        fontFamily: TipografiFunda.namaKeluargaFont,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: WarnaFunda.peringatan,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: SpasiFunda.m),

          // 2. Komponen Disclaimer Langkah Dunia Nyata
          if (!_disclaimerDilipat) ...[
            DisclaimerLangkahDuniaNyata(
              padaMengerti: () {
                setState(() {
                  _disclaimerDilipat = true;
                });
              },
            ),
            const SizedBox(height: SpasiFunda.m),
          ],

          // 3. Ringkasan Portofolio & Nilai Saat Ini (Bento)
          PetakBento.ukuran2x1(
            tint: TintPetakBento.netral,
            anak: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: SpasiFunda.s,
                  runSpacing: SpasiFunda.xs,
                  children: [
                    const TeksFunda.catatan('Nilai Portofolio Fiktif'),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SpasiFunda.s,
                        vertical: SpasiFunda.xs,
                      ),
                      decoration: BoxDecoration(
                        color: WarnaFunda.permukaan,
                        borderRadius: BorderRadius.circular(SudutFunda.kecil),
                      ),
                      child: Text(
                        keadaan.tahunBerjalan == 0
                            ? 'Tahun 0 (Awal)'
                            : 'Tahun ${keadaan.tahunBerjalan}',
                        style: const TextStyle(
                          fontFamily: TipografiFunda.namaKeluargaFont,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: WarnaFunda.utama,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SpasiFunda.xs),
                Text(
                  formatRupiahRapat(keadaan.nilaiSaatIni),
                  style: const TextStyle(
                    fontFamily: TipografiFunda.namaKeluargaFont,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: WarnaFunda.teks,
                  ),
                ),
                const SizedBox(height: SpasiFunda.xs),
                Wrap(
                  spacing: SpasiFunda.s,
                  runSpacing: SpasiFunda.xs,
                  children: [
                    Text(
                      'Modal Awal: ${formatRupiahRapat(keadaan.saldoAwal)}',
                      style: const TextStyle(
                        fontFamily: TipografiFunda.namaKeluargaFont,
                        fontSize: 12,
                        color: WarnaFunda.teksRedup,
                      ),
                    ),
                    Text(
                      keadaan.selisihDariAwal >= 0
                          ? '+${formatRupiahRapat(keadaan.selisihDariAwal)}'
                          : formatRupiahRapat(keadaan.selisihDariAwal),
                      style: TextStyle(
                        fontFamily: TipografiFunda.namaKeluargaFont,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: keadaan.selisihDariAwal > 0
                            ? WarnaFunda.sukses
                            : (keadaan.selisihDariAwal < 0
                                  ? WarnaFunda.bahaya
                                  : WarnaFunda.teksRedup),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: SpasiFunda.l),

          // 4. Pembagian Alokasi Portofolio
          const TeksFunda.judulBagian('Alokasi Portofolio'),
          const SizedBox(height: SpasiFunda.xs),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: SpasiFunda.s,
            runSpacing: SpasiFunda.xs,
            children: [
              const TeksFunda.catatan('Total harus tepat 100%'),
              Text(
                'Total: ${keadaan.totalAlokasi}%',
                style: TextStyle(
                  fontFamily: TipografiFunda.namaKeluargaFont,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: keadaan.alokasiSah
                      ? WarnaFunda.sukses
                      : WarnaFunda.bahaya,
                ),
              ),
            ],
          ),
          const SizedBox(height: SpasiFunda.s),

          _PengaturAlokasi(
            label: 'Pasar Uang',
            persen: keadaan.persenPasarUang,
            nominal: keadaan.nilaiPasarUang,
            warna: WarnaFunda.sifatKebutuhan,
            onChanged: (val) => notifier.ubahAlokasi(persenPasarUang: val),
          ),
          const SizedBox(height: SpasiFunda.xs),
          _PengaturAlokasi(
            label: 'Obligasi',
            persen: keadaan.persenObligasi,
            nominal: keadaan.nilaiObligasi,
            warna: WarnaFunda.aksen,
            onChanged: (val) => notifier.ubahAlokasi(persenObligasi: val),
          ),
          const SizedBox(height: SpasiFunda.xs),
          _PengaturAlokasi(
            label: 'Saham',
            persen: keadaan.persenSaham,
            nominal: keadaan.nilaiSaham,
            warna: WarnaFunda.sifatKeinginan,
            onChanged: (val) => notifier.ubahAlokasi(persenSaham: val),
          ),
          const SizedBox(height: SpasiFunda.l),

          // 5. Pemilih Skenario Pasar
          const TeksFunda.judulBagian('Skenario Pasar'),
          const SizedBox(height: SpasiFunda.s),
          Row(
            children: [
              Expanded(
                child: _KartuPilihSkenario(
                  kunci: const Key('skenario_normal'),
                  label: 'Normal',
                  keterangan: 'Stabil bertumbuh',
                  terpilih: keadaan.skenario == 'normal',
                  padaKetuk: () => notifier.ubahSkenario('normal'),
                ),
              ),
              const SizedBox(width: SpasiFunda.s),
              Expanded(
                child: _KartuPilihSkenario(
                  kunci: const Key('skenario_turun'),
                  label: 'Pasar Turun',
                  keterangan: 'Saham -20%',
                  terpilih: keadaan.skenario == 'turun',
                  padaKetuk: () => notifier.ubahSkenario('turun'),
                ),
              ),
              const SizedBox(width: SpasiFunda.s),
              Expanded(
                child: _KartuPilihSkenario(
                  kunci: const Key('skenario_naik'),
                  label: 'Pasar Naik',
                  keterangan: 'Saham +18%',
                  terpilih: keadaan.skenario == 'naik',
                  padaKetuk: () => notifier.ubahSkenario('naik'),
                ),
              ),
            ],
          ),
          const SizedBox(height: SpasiFunda.l),

          // 6. Tombol Aksi Majukan 1 Tahun
          Semantics(
            button: true,
            enabled: keadaan.alokasiSah,
            label: 'Majukan simulasi satu tahun',
            child: SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                key: const Key('tombol_majukan_sandbox'),
                onPressed: keadaan.alokasiSah
                    ? () => notifier.majukanSatuTahun()
                    : null,
                icon: const Icon(LucideIcons.fastForward, size: 20),
                label: const Text(
                  'Majukan 1 Tahun',
                  style: TextStyle(
                    fontFamily: TipografiFunda.namaKeluargaFont,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: WarnaFunda.utama,
                  foregroundColor: WarnaFunda.teksPutih,
                  disabledBackgroundColor: WarnaFunda.garis,
                  disabledForegroundColor: WarnaFunda.teksRedup,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SudutFunda.kecil),
                  ),
                ),
              ),
            ),
          ),
          if (!keadaan.alokasiSah) ...[
            const SizedBox(height: SpasiFunda.xs),
            const Text(
              'Sesuaikan slider agar total alokasi pas 100% untuk menjalankan simulasi.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: TipografiFunda.namaKeluargaFont,
                fontSize: 12,
                color: WarnaFunda.bahaya,
              ),
            ),
          ],
          const SizedBox(height: SpasiFunda.xl),

          // 7. Riwayat Simulasi
          if (keadaan.riwayat.isNotEmpty) ...[
            const TeksFunda.judulBagian('Riwayat Simulasi'),
            const SizedBox(height: SpasiFunda.s),
            ...keadaan.riwayat.reversed.map((r) {
              return Container(
                margin: const EdgeInsets.only(bottom: SpasiFunda.s),
                padding: const EdgeInsets.all(SpasiFunda.m),
                decoration: BoxDecoration(
                  color: WarnaFunda.permukaan,
                  borderRadius: BorderRadius.circular(SudutFunda.kartu),
                  border: Border.all(color: WarnaFunda.garis),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tahun ${r.tahun} (${r.skenario})',
                          style: const TextStyle(
                            fontFamily: TipografiFunda.namaKeluargaFont,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: WarnaFunda.teks,
                          ),
                        ),
                        const SizedBox(height: SpasiFunda.xs),
                        Text(
                          formatRupiahRapat(r.nilaiTotal),
                          style: const TextStyle(
                            fontFamily: TipografiFunda.namaKeluargaFont,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: WarnaFunda.teks,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      r.selisihTahun >= 0
                          ? '+${formatRupiahRapat(r.selisihTahun)}'
                          : formatRupiahRapat(r.selisihTahun),
                      style: TextStyle(
                        fontFamily: TipografiFunda.namaKeluargaFont,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: r.selisihTahun >= 0
                            ? WarnaFunda.sukses
                            : WarnaFunda.bahaya,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  void _konfirmasiReset(BuildContext context, NotifierSandbox notifier) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Atur Ulang Sandbox?'),
        content: const Text(
          'Seluruh riwayat simulasi uang fiktif ini akan dihapus dan kembali ke saldo awal Rp10.000.000.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            key: const Key('konfirmasi_reset_sandbox'),
            onPressed: () {
              notifier.aturUlang();
              Navigator.pop(ctx);
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

class _PengaturAlokasi extends StatelessWidget {
  final String label;
  final int persen;
  final int nominal;
  final Color warna;
  final ValueChanged<int> onChanged;

  const _PengaturAlokasi({
    required this.label,
    required this.persen,
    required this.nominal,
    required this.warna,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpasiFunda.m,
        vertical: SpasiFunda.xs,
      ),
      decoration: BoxDecoration(
        color: WarnaFunda.permukaan,
        borderRadius: BorderRadius.circular(SudutFunda.kartu),
        border: Border.all(color: WarnaFunda.garis),
      ),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: SpasiFunda.s,
            runSpacing: SpasiFunda.xs,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: warna,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: SpasiFunda.xs),
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: TipografiFunda.namaKeluargaFont,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: WarnaFunda.teks,
                    ),
                  ),
                ],
              ),
              Text(
                '$persen% (${formatRupiahRapat(nominal)})',
                style: const TextStyle(
                  fontFamily: TipografiFunda.namaKeluargaFont,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: WarnaFunda.teksRedup,
                ),
              ),
            ],
          ),
          Slider(
            value: persen.clamp(0, 100).toDouble(),
            min: 0,
            max: 100,
            divisions: 20,
            activeColor: warna,
            inactiveColor: warna.withAlpha(50),
            onChanged: (val) => onChanged(val.round()),
          ),
        ],
      ),
    );
  }
}

class _KartuPilihSkenario extends StatelessWidget {
  final Key? kunci;
  final String label;
  final String keterangan;
  final bool terpilih;
  final VoidCallback padaKetuk;

  const _KartuPilihSkenario({
    this.kunci,
    required this.label,
    required this.keterangan,
    required this.terpilih,
    required this.padaKetuk,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: terpilih,
      child: InkWell(
        key: kunci,
        onTap: padaKetuk,
        borderRadius: BorderRadius.circular(SudutFunda.kartu),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(
            horizontal: SpasiFunda.s,
            vertical: SpasiFunda.m,
          ),
          decoration: BoxDecoration(
            color: terpilih ? WarnaFunda.tintBiru : WarnaFunda.permukaan,
            borderRadius: BorderRadius.circular(SudutFunda.kartu),
            border: Border.all(
              color: terpilih ? WarnaFunda.utama : WarnaFunda.garis,
              width: terpilih ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: TipografiFunda.namaKeluargaFont,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: terpilih ? WarnaFunda.utama : WarnaFunda.teks,
                ),
              ),
              const SizedBox(height: SpasiFunda.xs),
              Text(
                keterangan,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: TipografiFunda.namaKeluargaFont,
                  fontSize: 10,
                  color: terpilih ? WarnaFunda.utama : WarnaFunda.teksRedup,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
