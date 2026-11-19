import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Batas waktu maksimal default untuk pumpAndSettle (5 detik).
const Duration batasMaksimalPompa = Duration(seconds: 5);

/// Interval langkah waktu default (100 ms).
const Duration langkahPompa = Duration(milliseconds: 100);

/// Helper resmi dan SATU-SATUNYA tempat pemanggilan pumpAndSettle pada pengujian Funda.
/// Memastikan pengujian tidak pernah menggantung hingga 10 menit jika ada animasi berkelanjutan.
Future<int> pompaAman(
  WidgetTester tester, {
  Duration durasi = langkahPompa,
  EnginePhase fase = EnginePhase.sendSemanticsUpdate,
  Duration batasMaksimal = batasMaksimalPompa,
}) async {
  await tester.pump();
  await tester.pump(durasi);
  try {
    return await tester.pumpAndSettle(durasi, fase, batasMaksimal);
  } catch (_) {
    return 1;
  }
}

/// Memompa secara berkala hingga [kondisi] bernilai true atau batas waktu terlampaui.
Future<void> pompaHingga(
  WidgetTester tester,
  bool Function() kondisi, {
  Duration batas = batasMaksimalPompa,
  Duration langkah = const Duration(milliseconds: 50),
  String? pesan,
}) async {
  final batasWaktu = DateTime.now().add(batas);
  while (!kondisi()) {
    if (DateTime.now().isAfter(batasWaktu)) {
      throw TestFailure(pesan ?? 'Batas waktu pompaHingga (${batas.inSeconds} detik) terlampaui.');
    }
    await tester.pump(langkah);
    if (!kondisi()) {
      await tester.runAsync(() async {
        await tester.idle();
      });
    }
  }
}

/// Memompa secara berkala hingga [pencari] menemukan minimal satu elemen di pohon widget.
Future<void> pompaHinggaAda(
  WidgetTester tester,
  Finder pencari, {
  Duration batas = batasMaksimalPompa,
  Duration langkah = const Duration(milliseconds: 50),
}) async {
  await pompaHingga(
    tester,
    () => pencari.evaluate().isNotEmpty,
    batas: batas,
    langkah: langkah,
    pesan: 'Pencari "$pencari" tidak ditemukan dalam batas waktu ${batas.inSeconds} detik.',
  );
}

/// Helper pelepasan pohon widget sebelum penutupan basis data atau selesai uji.
Future<void> bongkarWidget(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(Duration.zero);
}
