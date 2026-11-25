import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../komponen/komponen_funda.dart';
import '../../../perhitungan/perhitungan_umpan_balik_belajar.dart';
import '../../../tema/token.dart';
import '../kontroler/penyedia_sandbox.dart';

/// Layar Mode Sandbox edukasi investasi dengan portofolio uang fiktif
/// bergaya editorial bersih.
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
    final isTeksBesar = MediaQuery.textScalerOf(context).scale(1) > 1.3;

    return Scaffold(
      backgroundColor: WarnaFunda.latar,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                SpasiFunda.marginLayar,
                SpasiFunda.marginLayar,
                SpasiFunda.marginLayar,
                SpasiFunda.s,
              ),
              child: HeaderSubLayarEditorial(
                judul: 'Mode Sandbox',
                aksiKanan: [
                  TombolPilHeaderEditorial(
                    key: const Key('tombol_reset_sandbox'),
                    teks: 'Reset',
                    ikon: LucideIcons.rotateCcw,
                    warnaTeks: WarnaFunda.teksRedup,
                    padaTekan: () => _konfirmasiReset(context, notifier),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  SpasiFunda.marginLayar,
                  SpasiFunda.s,
                  SpasiFunda.marginLayar,
                  SpasiFunda.marginLayar,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Banner Penanda Mode Sandbox Uang Fiktif (menonjol di atas)
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
                          border: Border.all(
                            color: WarnaFunda.batasAmber,
                            width: 1.5,
                          ),
                        ),
                        child: const Row(
                          children: [
                            IkonSvgFunda(
                              pathAset: AsetIkonFunda.modeSandbox,
                              ukuran: 24,
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

                    // 3. Hero Kanvas Ungu: Ringkasan Portofolio & Nilai Saat Ini
                    Container(
                      key: const Key('hero_kanvas_sandbox'),
                      padding: const EdgeInsets.all(SpasiFunda.l),
                      decoration: BoxDecoration(
                        color: WarnaFunda.kanvasUngu,
                        borderRadius: BorderRadius.circular(SudutFunda.petak),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: SpasiFunda.s,
                            runSpacing: SpasiFunda.xs,
                            children: [
                              const TeksFunda.catatan(
                                'Nilai Portofolio Fiktif',
                                warna: WarnaFunda.teksRedup,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: SpasiFunda.s,
                                  vertical: SpasiFunda.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: WarnaFunda.permukaan,
                                  borderRadius: BorderRadius.circular(
                                    SudutFunda.pil,
                                  ),
                                ),
                                child: Text(
                                  keadaan.tahunBerjalan == 0
                                      ? 'Tahun 0 (Awal)'
                                      : 'Tahun ${keadaan.tahunBerjalan}',
                                  style: const TextStyle(
                                    fontFamily: TipografiFunda.namaKeluargaFont,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: WarnaFunda.sifatKeinginan,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: SpasiFunda.s),
                          TeksFunda.angkaBesar(
                            formatRupiahRapat(keadaan.nilaiSaatIni),
                            angkaTabular: true,
                          ),
                          const SizedBox(height: SpasiFunda.xs),
                          Wrap(
                            spacing: SpasiFunda.s,
                            runSpacing: SpasiFunda.xs,
                            children: [
                              TeksFunda.catatan(
                                'Modal Awal: ${formatRupiahRapat(keadaan.saldoAwal)}',
                                angkaTabular: true,
                                warna: WarnaFunda.teksRedup,
                              ),
                              Text(
                                keadaan.selisihDariAwal >= 0
                                    ? '+${formatRupiahRapat(keadaan.selisihDariAwal)}'
                                    : formatRupiahRapat(
                                        keadaan.selisihDariAwal,
                                      ),
                                style: TextStyle(
                                  fontFamily: TipografiFunda.namaKeluargaFont,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                  color: keadaan.selisihDariAwal > 0
                                      ? WarnaFunda.pemasukan
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

                    // 4. Pembagian Alokasi Portofolio dalam 1 Kartu Putih Border 1px
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
                                ? WarnaFunda.pemasukan
                                : WarnaFunda.bahaya,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: SpasiFunda.s),

                    Container(
                      key: const Key('kartu_alokasi_sandbox'),
                      decoration: BoxDecoration(
                        color: WarnaFunda.permukaan,
                        borderRadius: BorderRadius.circular(SudutFunda.petak),
                        border: Border.all(color: WarnaFunda.garis, width: 1.0),
                      ),
                      child: Column(
                        children: [
                          _PengaturAlokasi(
                            label: 'Pasar Uang',
                            persen: keadaan.persenPasarUang,
                            nominal: keadaan.nilaiPasarUang,
                            warna: WarnaFunda.sifatKebutuhan,
                            onChanged: (val) =>
                                notifier.ubahAlokasi(persenPasarUang: val),
                          ),
                          const Divider(
                            height: 1,
                            indent: SpasiFunda.l,
                            endIndent: SpasiFunda.l,
                            color: WarnaFunda.garis,
                          ),
                          _PengaturAlokasi(
                            label: 'Obligasi',
                            persen: keadaan.persenObligasi,
                            nominal: keadaan.nilaiObligasi,
                            warna: WarnaFunda.aksen,
                            onChanged: (val) =>
                                notifier.ubahAlokasi(persenObligasi: val),
                          ),
                          const Divider(
                            height: 1,
                            indent: SpasiFunda.l,
                            endIndent: SpasiFunda.l,
                            color: WarnaFunda.garis,
                          ),
                          _PengaturAlokasi(
                            label: 'Saham',
                            persen: keadaan.persenSaham,
                            nominal: keadaan.nilaiSaham,
                            warna: WarnaFunda.sifatKeinginan,
                            onChanged: (val) =>
                                notifier.ubahAlokasi(persenSaham: val),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: SpasiFunda.l),

                    // 5. Pemilih Skenario Pasar (menumpuk vertikal jika textScale > 1.3)
                    const TeksFunda.judulBagian('Skenario Pasar'),
                    const SizedBox(height: SpasiFunda.s),
                    if (isTeksBesar)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _KartuPilihSkenario(
                            kunci: const Key('skenario_normal'),
                            label: 'Normal',
                            keterangan: 'Stabil bertumbuh',
                            terpilih: keadaan.skenario == 'normal',
                            padaKetuk: () => notifier.ubahSkenario('normal'),
                          ),
                          const SizedBox(height: SpasiFunda.s),
                          _KartuPilihSkenario(
                            kunci: const Key('skenario_turun'),
                            label: 'Pasar Turun',
                            keterangan: 'Saham -20%',
                            terpilih: keadaan.skenario == 'turun',
                            padaKetuk: () => notifier.ubahSkenario('turun'),
                          ),
                          const SizedBox(height: SpasiFunda.s),
                          _KartuPilihSkenario(
                            kunci: const Key('skenario_naik'),
                            label: 'Pasar Naik',
                            keterangan: 'Saham +18%',
                            terpilih: keadaan.skenario == 'naik',
                            padaKetuk: () => notifier.ubahSkenario('naik'),
                          ),
                        ],
                      )
                    else
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

                    // 6. Tombol Aksi Majukan 1 Tahun bergaya pilGelap
                    // Tetap memakai ElevatedButton agar kompatibel dengan uji widget tombol_majukan_sandbox.
                    Semantics(
                      button: true,
                      enabled: keadaan.alokasiSah,
                      label: 'Majukan simulasi satu tahun',
                      child: ElevatedButton(
                        key: const Key('tombol_majukan_sandbox'),
                        onPressed: keadaan.alokasiSah
                            ? () => notifier.majukanSatuTahun()
                            : null,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 52),
                          padding: const EdgeInsets.symmetric(
                            horizontal: SpasiFunda.xl,
                            vertical: SpasiFunda.m,
                          ),
                          elevation: 0,
                          backgroundColor: WarnaFunda.tombolGelap,
                          foregroundColor: WarnaFunda.teksPutih,
                          disabledBackgroundColor: WarnaFunda.garis,
                          disabledForegroundColor: WarnaFunda.teksRedup,
                          shape: const StadiumBorder(),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.fastForward, size: 20),
                            SizedBox(width: SpasiFunda.s),
                            Flexible(
                              child: Text(
                                'Majukan 1 Tahun',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: TipografiFunda.namaKeluargaFont,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (!keadaan.alokasiSah) ...[
                      const SizedBox(height: SpasiFunda.xs),
                      const TeksFunda.catatan(
                        'Sesuaikan slider agar total alokasi pas 100% untuk menjalankan simulasi.',
                        rataTeks: TextAlign.center,
                        warna: WarnaFunda.bahaya,
                      ),
                    ],
                    const SizedBox(height: SpasiFunda.xl),

                    // 7. Riwayat Simulasi Menyatu dalam 1 Kartu Putih Border 1px
                    if (keadaan.riwayat.isNotEmpty) ...[
                      const TeksFunda.judulBagian('Riwayat Simulasi'),
                      const SizedBox(height: SpasiFunda.s),
                      Container(
                        key: const Key('kartu_riwayat_sandbox'),
                        decoration: BoxDecoration(
                          color: WarnaFunda.permukaan,
                          borderRadius: BorderRadius.circular(SudutFunda.petak),
                          border: Border.all(
                            color: WarnaFunda.garis,
                            width: 1.0,
                          ),
                        ),
                        child: Column(
                          children: [
                            for (
                              var i = 0;
                              i < keadaan.riwayat.length;
                              i++
                            ) ...[
                              () {
                                final r = keadaan
                                    .riwayat[keadaan.riwayat.length - 1 - i];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: SpasiFunda.l,
                                    vertical: SpasiFunda.m,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            TeksFunda.label(
                                              'Tahun ${r.tahun} (${r.skenario})',
                                            ),
                                            const SizedBox(height: 2),
                                            TeksFunda.catatan(
                                              formatRupiahRapat(r.nilaiTotal),
                                              angkaTabular: true,
                                              warna: WarnaFunda.teks,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: SpasiFunda.s),
                                      Text(
                                        r.selisihTahun >= 0
                                            ? '+${formatRupiahRapat(r.selisihTahun)}'
                                            : formatRupiahRapat(r.selisihTahun),
                                        style: TextStyle(
                                          fontFamily:
                                              TipografiFunda.namaKeluargaFont,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          fontFeatures: const [
                                            FontFeature.tabularFigures(),
                                          ],
                                          color: r.selisihTahun >= 0
                                              ? WarnaFunda.pemasukan
                                              : WarnaFunda.bahaya,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }(),
                              if (i < keadaan.riwayat.length - 1)
                                const Divider(
                                  height: 1,
                                  indent: SpasiFunda.l,
                                  endIndent: SpasiFunda.l,
                                  color: WarnaFunda.garis,
                                ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: SpasiFunda.xl),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _konfirmasiReset(BuildContext context, NotifierSandbox notifier) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const TeksFunda.judulBagian('Atur Ulang Sandbox?'),
        content: const TeksFunda.isiKecil(
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SpasiFunda.l,
        SpasiFunda.m,
        SpasiFunda.l,
        SpasiFunda.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  const SizedBox(width: SpasiFunda.s),
                  Flexible(child: TeksFunda.label(label)),
                ],
              ),
              TeksFunda.catatan(
                '$persen% (${formatRupiahRapat(nominal)})',
                angkaTabular: true,
                warna: WarnaFunda.teksRedup,
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
            color: terpilih ? WarnaFunda.kanvasBiru : WarnaFunda.permukaan,
            borderRadius: BorderRadius.circular(SudutFunda.kartu),
            border: Border.all(
              color: terpilih ? WarnaFunda.utama : WarnaFunda.garis,
              width: terpilih ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
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
                  fontSize: 11,
                  color: terpilih
                      ? WarnaFunda.utamaGelap
                      : WarnaFunda.teksRedup,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
