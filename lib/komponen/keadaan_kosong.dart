import 'package:flutter/material.dart';
import '../tema/token.dart';
import 'teks_funda.dart';
import 'tombol_funda.dart';

/// Komponen Keadaan Kosong (Empty State) Funda.
/// Terdiri dari kotak ikon membulat berwarna tint, satu kalimat pesan yang ramah,
/// dan satu tombol aksi utama.
class KeadaanKosong extends StatelessWidget {
  const KeadaanKosong({
    super.key,
    required this.ikon,
    required this.pesan,
    this.judul,
    this.teksTombol,
    this.padaAksi,
    this.warnaTint = WarnaFunda.tintHijau,
    this.warnaIkon = WarnaFunda.utama,
  });

  final IconData ikon;
  final String pesan;
  final String? judul;
  final String? teksTombol;
  final VoidCallback? padaAksi;
  final Color warnaTint;
  final Color warnaIkon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SpasiFunda.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Wadah Ikon Ber-tint
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: warnaTint,
                borderRadius: BorderRadius.circular(SudutFunda.petak),
                border: Border.all(color: WarnaFunda.garis),
              ),
              child: Icon(ikon, size: 32, color: warnaIkon),
            ),
            const SizedBox(height: SpasiFunda.l),

            // Judul jika ada
            if (judul != null) ...[
              TeksFunda.judulBagian(judul!, rataTeks: TextAlign.center),
              const SizedBox(height: SpasiFunda.s),
            ],

            // Satu kalimat pesan yang memberdayakan & tidak menghakimi
            TeksFunda.isi(
              pesan,
              warna: WarnaFunda.teksRedup,
              rataTeks: TextAlign.center,
            ),

            // Satu tombol aksi jika disediakan
            if (teksTombol != null && padaAksi != null) ...[
              const SizedBox(height: SpasiFunda.xl),
              TombolFunda.primer(teks: teksTombol!, padaTekan: padaAksi),
            ],
          ],
        ),
      ),
    );
  }
}
