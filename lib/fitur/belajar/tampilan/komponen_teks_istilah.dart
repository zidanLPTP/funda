import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../komponen/komponen_funda.dart';
import '../../../tema/token.dart';
import '../kontroler/penyedia_belajar.dart';

/// Widget teks kaya yang otomatis mendeteksi istilah {{nama_istilah}}
/// dan menjadikannya teks bergaris bawah putus-putus yang membuka dialog penjelasan kamus.
class TeksDenganIstilah extends ConsumerWidget {
  final String teks;
  final TextStyle? gaya;

  const TeksDenganIstilah({
    super.key,
    required this.teks,
    this.gaya,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kamusAsync = ref.watch(penyediaKamus);
    final mapKamus = kamusAsync.value ?? {};

    final spans = <InlineSpan>[];
    final regex = RegExp(r'\{\{([^}]+)\}\}');
    var posisiTerakhir = 0;

    for (final match in regex.allMatches(teks)) {
      if (match.start > posisiTerakhir) {
        final teksBiasa = teks.substring(posisiTerakhir, match.start);
        spans.addAll(_uraiFormatTebal(teksBiasa, gaya));
      }

      final istilahKunci = match.group(1)!;
      final istilahObj = mapKamus[istilahKunci.toLowerCase().trim()];

      spans.add(
        TextSpan(
          text: istilahKunci,
          style: (gaya ?? const TextStyle()).copyWith(
            fontWeight: FontWeight.w600,
            color: WarnaFunda.utama,
            decoration: TextDecoration.underline,
            decorationStyle: TextDecorationStyle.dashed,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              if (istilahObj != null) {
                _tampilkanDialogKamus(context, istilahObj.istilah, istilahObj.arti, istilahObj.contohRupiah);
              } else {
                _tampilkanDialogKamus(context, istilahKunci, 'Istilah keuangan.', '');
              }
            },
        ),
      );

      posisiTerakhir = match.end;
    }

    if (posisiTerakhir < teks.length) {
      final sisa = teks.substring(posisiTerakhir);
      spans.addAll(_uraiFormatTebal(sisa, gaya));
    }

    return Text.rich(
      TextSpan(children: spans),
      style: gaya ?? const TextStyle(fontSize: 16, height: 1.5, color: WarnaFunda.teks),
    );
  }

  List<InlineSpan> _uraiFormatTebal(String teks, TextStyle? dasar) {
    final spans = <InlineSpan>[];
    final regTebal = RegExp(r'\*\*([^*]+)\*\*');
    var idx = 0;

    for (final m in regTebal.allMatches(teks)) {
      if (m.start > idx) {
        spans.add(TextSpan(text: teks.substring(idx, m.start), style: dasar));
      }
      spans.add(
        TextSpan(
          text: m.group(1),
          style: (dasar ?? const TextStyle()).copyWith(fontWeight: FontWeight.bold),
        ),
      );
      idx = m.end;
    }
    if (idx < teks.length) {
      spans.add(TextSpan(text: teks.substring(idx), style: dasar));
    }
    return spans;
  }

  void _tampilkanDialogKamus(
    BuildContext context,
    String istilah,
    String arti,
    String contohRupiah,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: WarnaFunda.permukaan,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SudutFunda.kartu),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(SpasiFunda.s),
                decoration: BoxDecoration(
                  color: WarnaFunda.utamaTipis,
                  borderRadius: BorderRadius.circular(SudutFunda.kecil),
                ),
                child: const Icon(Icons.menu_book, color: WarnaFunda.utama, size: 20),
              ),
              const SizedBox(width: SpasiFunda.s),
              Expanded(
                child: TeksFunda.judulBagian(istilah),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TeksFunda.isi(arti),
              if (contohRupiah.isNotEmpty) ...[
                const SizedBox(height: SpasiFunda.m),
                Container(
                  padding: const EdgeInsets.all(SpasiFunda.m),
                  decoration: BoxDecoration(
                    color: WarnaFunda.tintNetral,
                    borderRadius: BorderRadius.circular(SudutFunda.kecil),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const TeksFunda.catatan('Contoh konkret:', warna: WarnaFunda.teksRedup),
                      const SizedBox(height: SpasiFunda.xs),
                      TeksFunda.isiKecil(contohRupiah),
                    ],
                  ),
                ),
              ],
            ],
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
}
