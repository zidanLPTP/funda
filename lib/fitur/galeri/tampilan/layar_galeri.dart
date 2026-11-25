import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../komponen/komponen_funda.dart';
import '../../../tema/token.dart';
import '../../../util/format_rupiah.dart';

/// Layar Galeri Komponen khusus mode pengembangan.
/// Berfungsi sebagai bukti visual kesesuaian implementasi dengan styleguide.md.
class LayarGaleri extends StatefulWidget {
  const LayarGaleri({super.key});

  @override
  State<LayarGaleri> createState() => _LayarGaleriState();
}

class _LayarGaleriState extends State<LayarGaleri> {
  bool _tombolSedangMemuat = false;
  final _pengontrolTeks = TextEditingController(text: 'Rp 1.250.000');
  String _pesanUjiRupiah = 'Hasil konversi int: 1250000';

  @override
  void dispose() {
    _pengontrolTeks.dispose();
    super.dispose();
  }

  void _ujiKonversiRupiah(String teks) {
    try {
      final angka = ambilAngkaRupiah(teks);
      setState(() {
        _pesanUjiRupiah =
            'Berhasil diurai menjadi int: $angka\nFormat ulang: ${formatRupiah(angka)}';
      });
    } catch (e) {
      setState(() {
        _pesanUjiRupiah = 'Galat: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PembungkusLayar(
      appBar: AppBar(title: const TeksFunda.judulBagian('Galeri Komponen UI')),
      bisaGulir: true,
      anak: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Catatan pembuka
          Container(
            padding: const EdgeInsets.all(SpasiFunda.m),
            decoration: BoxDecoration(
              color: WarnaFunda.tintHijau,
              borderRadius: BorderRadius.circular(SudutFunda.kartu),
              border: Border.all(color: WarnaFunda.garis),
            ),
            child: const TeksFunda.isiKecil(
              'Layar ini hanya untuk pengembangan, membuktikan kesesuaian token, warna, tipografi, dan komponen dasar dengan styleguide.md.',
              warna: WarnaFunda.utamaGelap,
            ),
          ),
          const SizedBox(height: SpasiFunda.xxl),

          // 1. Tipografi
          _BagianGaleri(
            judul: '1. Tipografi (Plus Jakarta Sans)',
            anak: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TeksFunda.angkaBesar('Rp 1.250.000'),
                const TeksFunda.catatan('Varian: angkaBesar (32dp, Bold)'),
                const Divider(height: SpasiFunda.l),
                const TeksFunda.judulLayar('Judul Layar Utama'),
                const TeksFunda.catatan('Varian: judulLayar (24dp, Bold)'),
                const Divider(height: SpasiFunda.l),
                const TeksFunda.judulBagian('Judul Bagian Kartu'),
                const TeksFunda.catatan('Varian: judulBagian (18dp, SemiBold)'),
                const Divider(height: SpasiFunda.l),
                const TeksFunda.isi(
                  'Teks isi bacaan reguler 16dp yang nyaman untuk materi pelajaran.',
                ),
                const TeksFunda.catatan('Varian: isi (16dp, Regular)'),
                const Divider(height: SpasiFunda.l),
                const TeksFunda.isiKecil(
                  'Teks isi kecil atau keterangan sekunder 14dp.',
                ),
                const TeksFunda.catatan('Varian: isiKecil (14dp, Regular)'),
                const Divider(height: SpasiFunda.l),
                const TeksFunda.label('Label Elemen / Tombol'),
                const TeksFunda.catatan('Varian: label (15dp, SemiBold)'),
                const Divider(height: SpasiFunda.l),
                const TeksFunda.catatan(
                  'Catatan kaki 12dp untuk informasi pelengkap.',
                ),
                const TeksFunda.catatan('Varian: catatan (12dp, Regular)'),
              ],
            ),
          ),
          const SizedBox(height: SpasiFunda.xxl),

          // 2. Token Warna
          _BagianGaleri(
            judul: '2. Token Warna & Sifat Pengeluaran',
            anak: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TeksFunda.isiKecil('Palet Dasar:'),
                const SizedBox(height: SpasiFunda.s),
                Wrap(
                  spacing: SpasiFunda.s,
                  runSpacing: SpasiFunda.s,
                  children: [
                    _KotakWarna(warna: WarnaFunda.utama, nama: 'utama'),
                    _KotakWarna(
                      warna: WarnaFunda.utamaGelap,
                      nama: 'utamaGelap',
                    ),
                    _KotakWarna(
                      warna: WarnaFunda.utamaTipis,
                      nama: 'utamaTipis',
                      teksHitam: true,
                    ),
                    _KotakWarna(
                      warna: WarnaFunda.latar,
                      nama: 'latar',
                      teksHitam: true,
                    ),
                    _KotakWarna(warna: WarnaFunda.teks, nama: 'teks'),
                    _KotakWarna(warna: WarnaFunda.teksRedup, nama: 'teksRedup'),
                    _KotakWarna(warna: WarnaFunda.aksen, nama: 'aksen'),
                  ],
                ),
                const SizedBox(height: SpasiFunda.l),
                const TeksFunda.isiKecil(
                  'Warna Sifat Pengeluaran (Wajib didampingi ikon):',
                ),
                const SizedBox(height: SpasiFunda.s),
                Wrap(
                  spacing: SpasiFunda.s,
                  runSpacing: SpasiFunda.s,
                  children: [
                    _LencanaSifat(
                      ikon: LucideIcons.shield,
                      nama: 'Kebutuhan',
                      warna: WarnaFunda.sifatKebutuhan,
                    ),
                    _LencanaSifat(
                      ikon: LucideIcons.gift,
                      nama: 'Keinginan',
                      warna: WarnaFunda.sifatKeinginan,
                    ),
                    _LencanaSifat(
                      ikon: LucideIcons.piggyBank,
                      nama: 'Tabungan',
                      warna: WarnaFunda.sifatTabungan,
                    ),
                    _LencanaSifat(
                      ikon: LucideIcons.calendarClock,
                      nama: 'Utang/Cicilan',
                      warna: WarnaFunda.sifatUtang,
                    ),
                  ],
                ),
                const SizedBox(height: SpasiFunda.l),
                const TeksFunda.isiKecil('Tint Petak Bento:'),
                const SizedBox(height: SpasiFunda.s),
                Wrap(
                  spacing: SpasiFunda.s,
                  runSpacing: SpasiFunda.s,
                  children: [
                    _KotakWarna(
                      warna: WarnaFunda.tintHijau,
                      nama: 'tintHijau',
                      teksHitam: true,
                    ),
                    _KotakWarna(
                      warna: WarnaFunda.tintBiru,
                      nama: 'tintBiru',
                      teksHitam: true,
                    ),
                    _KotakWarna(
                      warna: WarnaFunda.tintUngu,
                      nama: 'tintUngu',
                      teksHitam: true,
                    ),
                    _KotakWarna(
                      warna: WarnaFunda.tintAmber,
                      nama: 'tintAmber',
                      teksHitam: true,
                    ),
                    _KotakWarna(
                      warna: WarnaFunda.tintNetral,
                      nama: 'tintNetral',
                      teksHitam: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: SpasiFunda.xxl),

          // 3. TombolFunda
          _BagianGaleri(
            judul: '3. TombolFunda',
            anak: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: SpasiFunda.m,
                  runSpacing: SpasiFunda.m,
                  children: [
                    TombolFunda.primer(teks: 'Tombol Primer', padaTekan: () {}),
                    TombolFunda.sekunder(
                      teks: 'Tombol Sekunder',
                      padaTekan: () {},
                    ),
                    TombolFunda.teks(teks: 'Tombol Teks', padaTekan: () {}),
                  ],
                ),
                const SizedBox(height: SpasiFunda.l),
                const TeksFunda.isiKecil(
                  'Status Tombol (dengan Ikon, Memuat, Nonaktif):',
                ),
                const SizedBox(height: SpasiFunda.m),
                Wrap(
                  spacing: SpasiFunda.m,
                  runSpacing: SpasiFunda.m,
                  children: [
                    TombolFunda.primer(
                      teks: 'Dengan Ikon',
                      ikon: const Icon(
                        LucideIcons.plus,
                        size: 18,
                        color: WarnaFunda.putih,
                      ),
                      padaTekan: () {},
                    ),
                    TombolFunda.primer(
                      teks: 'Simulasikan Memuat',
                      memuat: _tombolSedangMemuat,
                      padaTekan: () {
                        setState(
                          () => _tombolSedangMemuat = !_tombolSedangMemuat,
                        );
                        Future.delayed(const Duration(seconds: 2), () {
                          if (mounted) {
                            setState(() => _tombolSedangMemuat = false);
                          }
                        });
                      },
                    ),
                    const TombolFunda.primer(
                      teks: 'Tombol Nonaktif',
                      padaTekan: null,
                    ),
                  ],
                ),
                const SizedBox(height: SpasiFunda.l),
                TombolFunda.primer(
                  teks: 'Tombol Lebar Penuh (Aksi Utama)',
                  lebarPenuh: true,
                  padaTekan: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: SpasiFunda.xxl),

          // 4. Petak Bento
          _BagianGaleri(
            judul: '4. PetakBento (Soft Bento Grid)',
            anak: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PetakBento.ukuran2x1(
                  tint: TintPetakBento.hijau,
                  padaKetuk: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Petak Bento 2x1 diketuk (efek animasi tekan halus aktif)',
                        ),
                      ),
                    );
                  },
                  anak: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TeksFunda.isiKecil('Petak Bento 2x1 (Bisa Diketuk)'),
                      SizedBox(height: SpasiFunda.s),
                      TeksFunda.angkaBesar('Rp 2.500.000'),
                      SizedBox(height: SpasiFunda.xs),
                      TeksFunda.catatan(
                        'Radius 24dp, latar tint hijau pastel, batas halus',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: SpasiFunda.jarakPetak),
                Row(
                  children: [
                    Expanded(
                      child: PetakBento.ukuran1x1(
                        tint: TintPetakBento.biru,
                        padaKetuk: () {},
                        anak: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TeksFunda.isiKecil('Petak 1x1 Biru'),
                            SizedBox(height: SpasiFunda.m),
                            TeksFunda.judulBagian('Anggaran'),
                            SizedBox(height: SpasiFunda.xs),
                            TeksFunda.catatan('Kebutuhan'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: SpasiFunda.jarakPetak),
                    Expanded(
                      child: PetakBento.ukuran1x1(
                        tint: TintPetakBento.ungu,
                        padaKetuk: () {},
                        anak: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TeksFunda.isiKecil('Petak 1x1 Ungu'),
                            SizedBox(height: SpasiFunda.m),
                            TeksFunda.judulBagian('Refleksi'),
                            SizedBox(height: SpasiFunda.xs),
                            TeksFunda.catatan('Keinginan'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: SpasiFunda.xxl),

          // 5. Keadaan Kosong (Empty State)
          _BagianGaleri(
            judul: '5. KeadaanKosong (Empty State)',
            anak: Container(
              padding: const EdgeInsets.symmetric(vertical: SpasiFunda.xl),
              decoration: BoxDecoration(
                color: WarnaFunda.permukaan,
                borderRadius: BorderRadius.circular(SudutFunda.petak),
                border: Border.all(color: WarnaFunda.garis),
              ),
              child: KeadaanKosong(
                ikon: LucideIcons.walletCards,
                judul: 'Belum Ada Dompet',
                pesan: 'Catat rekening bank atau dompet tunaimu untuk memulai.',
                teksTombol: 'Tambah Dompet Pertama',
                padaAksi: () {},
              ),
            ),
          ),
          const SizedBox(height: SpasiFunda.xxl),

          // 6. Pengujian Interaktif Format Rupiah
          _BagianGaleri(
            judul: '6. Pengujian Format Rupiah (Fungsi Murni int)',
            anak: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _pengontrolTeks,
                  decoration: const InputDecoration(
                    labelText: 'Ketik Teks Rupiah untuk Diurai',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: _ujiKonversiRupiah,
                ),
                const SizedBox(height: SpasiFunda.m),
                Text(
                  _pesanUjiRupiah,
                  style: TipografiFunda.catatan.copyWith(
                    color: _pesanUjiRupiah.startsWith('Galat')
                        ? WarnaFunda.bahaya
                        : WarnaFunda.pemasukan,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: SpasiFunda.xxxl),
        ],
      ),
    );
  }
}

class _BagianGaleri extends StatelessWidget {
  const _BagianGaleri({required this.judul, required this.anak});

  final String judul;
  final Widget anak;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TeksFunda.judulBagian(judul),
        const SizedBox(height: SpasiFunda.m),
        anak,
      ],
    );
  }
}

class _KotakWarna extends StatelessWidget {
  const _KotakWarna({
    required this.warna,
    required this.nama,
    this.teksHitam = false,
  });

  final Color warna;
  final String nama;
  final bool teksHitam;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(SpasiFunda.s),
      decoration: BoxDecoration(
        color: warna,
        borderRadius: BorderRadius.circular(SudutFunda.kecil),
        border: Border.all(color: WarnaFunda.garis),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            nama,
            style: TipografiFunda.catatan.copyWith(
              color: teksHitam ? WarnaFunda.teks : WarnaFunda.teksPutih,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: SpasiFunda.xs),
          Text(
            '#${warna.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
            style: TipografiFunda.catatan.copyWith(
              color: teksHitam
                  ? WarnaFunda.teksRedup
                  : WarnaFunda.teksPutihRedup,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _LencanaSifat extends StatelessWidget {
  const _LencanaSifat({
    required this.ikon,
    required this.nama,
    required this.warna,
  });

  final IconData ikon;
  final String nama;
  final Color warna;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpasiFunda.m,
        vertical: SpasiFunda.s,
      ),
      decoration: BoxDecoration(
        color: warna.withAlpha(25),
        borderRadius: BorderRadius.circular(SudutFunda.pil),
        border: Border.all(color: warna),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ikon, size: 16, color: warna),
          const SizedBox(width: SpasiFunda.s),
          Text(
            nama,
            style: TipografiFunda.label.copyWith(color: warna, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
