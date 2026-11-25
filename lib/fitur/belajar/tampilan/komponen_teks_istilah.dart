import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../komponen/komponen_funda.dart';
import '../../../tema/token.dart';
import '../kontroler/penyedia_belajar.dart';
import '../model/pembaca_konten.dart';

/// Bagian teks hasil penguraian sintaks `{{istilah}}` dan `**tebal**`.
class SegmenTeksIstilah {
  final String teks;
  final bool tebal;
  final String? kunciIstilah;

  const SegmenTeksIstilah({
    required this.teks,
    this.tebal = false,
    this.kunciIstilah,
  });
}

/// Mengurai string materi yang mengandung penanda `{{istilah}}` dan `**tebal**`.
List<SegmenTeksIstilah> uraiSegmenTeksIstilah(String sumber) {
  final hasil = <SegmenTeksIstilah>[];
  final regexIstilah = RegExp(r'\{\{([^}]+)\}\}');
  var posisiTerakhir = 0;

  void tambahTeksBiasa(String bagian) {
    final regTebal = RegExp(r'\*\*([^*]+)\*\*');
    var idx = 0;
    for (final m in regTebal.allMatches(bagian)) {
      if (m.start > idx) {
        hasil.add(SegmenTeksIstilah(teks: bagian.substring(idx, m.start)));
      }
      hasil.add(SegmenTeksIstilah(teks: m.group(1)!, tebal: true));
      idx = m.end;
    }
    if (idx < bagian.length) {
      hasil.add(SegmenTeksIstilah(teks: bagian.substring(idx)));
    }
  }

  for (final match in regexIstilah.allMatches(sumber)) {
    if (match.start > posisiTerakhir) {
      tambahTeksBiasa(sumber.substring(posisiTerakhir, match.start));
    }
    final kunci = match.group(1)!;
    hasil.add(SegmenTeksIstilah(teks: kunci, kunciIstilah: kunci));
    posisiTerakhir = match.end;
  }

  if (posisiTerakhir < sumber.length) {
    tambahTeksBiasa(sumber.substring(posisiTerakhir));
  }

  return hasil;
}

/// Mengembalikan teks polos tanpa markah `{{...}}` atau `**...**` untuk pembaca layar.
String bersihkanMarkahIstilah(String sumber) {
  return uraiSegmenTeksIstilah(sumber).map((s) => s.teks).join();
}

/// Membuka dialog penjelasan kamus untuk istilah tertentu.
void tampilkanDialogKamusIstilah(
  BuildContext context,
  String kunciIstilah,
  Map<String, IstilahKamus> mapKamus,
) {
  final istilahObj = mapKamus[kunciIstilah.toLowerCase().trim()];
  final judul = istilahObj?.istilah ?? kunciIstilah;
  final arti = istilahObj?.arti ?? 'Istilah keuangan.';
  final contohRupiah = istilahObj?.contohRupiah ?? '';

  showDialog<void>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: WarnaFunda.permukaan,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SudutFunda.petak),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(SpasiFunda.s),
              decoration: BoxDecoration(
                color: WarnaFunda.utamaTipis,
                borderRadius: BorderRadius.circular(SudutFunda.kecil),
              ),
              child: const Icon(
                Icons.menu_book,
                color: WarnaFunda.utama,
                size: 20,
              ),
            ),
            const SizedBox(width: SpasiFunda.s),
            Expanded(child: TeksFunda.judulBagian(judul)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TeksFunda.isi(arti, rataTeks: TextAlign.start),
              if (contohRupiah.isNotEmpty) ...[
                const SizedBox(height: SpasiFunda.m),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(SpasiFunda.m),
                  decoration: BoxDecoration(
                    color: WarnaFunda.tintNetral,
                    borderRadius: BorderRadius.circular(SudutFunda.kartu),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const TeksFunda.catatan(
                        'Contoh konkret:',
                        warna: WarnaFunda.teksRedup,
                      ),
                      const SizedBox(height: SpasiFunda.xs),
                      TeksFunda.isiKecil(
                        contohRupiah,
                        rataTeks: TextAlign.start,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const TeksFunda.label('Mengerti', warna: WarnaFunda.utama),
          ),
        ],
      );
    },
  );
}

/// Widget teks kaya yang otomatis mendeteksi istilah `{{nama_istilah}}`
/// dan menjadikannya teks bergaris bawah putus-putus yang membuka dialog penjelasan kamus.
class TeksDenganIstilah extends ConsumerWidget {
  final String teks;
  final TextStyle? gaya;
  final TextAlign rataTeks;

  const TeksDenganIstilah({
    super.key,
    required this.teks,
    this.gaya,
    this.rataTeks = TextAlign.start,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kamusAsync = ref.watch(penyediaKamus);
    final mapKamus = kamusAsync.value ?? const <String, IstilahKamus>{};
    final gayaDasar =
        gaya ??
        TipografiFunda.isi.copyWith(
          fontSize: 16,
          height: 1.6,
          color: WarnaFunda.teks,
        );

    final segmen = uraiSegmenTeksIstilah(teks);
    final spans = segmen.map((bagian) {
      if (bagian.kunciIstilah != null) {
        final kunci = bagian.kunciIstilah!;
        return TextSpan(
          text: bagian.teks,
          style: gayaDasar.copyWith(
            fontWeight: FontWeight.w600,
            color: WarnaFunda.utama,
            decoration: TextDecoration.underline,
            decorationStyle: TextDecorationStyle.dashed,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () =>
                tampilkanDialogKamusIstilah(context, kunci, mapKamus),
        );
      }
      if (bagian.tebal) {
        return TextSpan(
          text: bagian.teks,
          style: gayaDasar.copyWith(fontWeight: FontWeight.w700),
        );
      }
      return TextSpan(text: bagian.teks, style: gayaDasar);
    }).toList();

    return Text.rich(
      TextSpan(children: spans),
      textAlign: rataTeks,
      style: gayaDasar,
    );
  }
}
