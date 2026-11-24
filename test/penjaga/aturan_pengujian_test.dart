import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Penjaga Aturan Pengujian Anti-Menggantung (Tahap 7-R)', () {
    test(
      '1. pumpAndSettle hanya boleh dipanggil di test/pembantu/pompa_uji.dart',
      () {
        final direktoriTest = Directory('test');
        final direktoriIntegration = Directory('integration_test');
        final berkasMelanggar = <String>[];

        void periksaDirektori(Directory dir) {
          if (!dir.existsSync()) return;
          for (final entitas in dir.listSync(recursive: true)) {
            if (entitas is! File || !entitas.path.endsWith('.dart')) continue;
            final pathNormal = entitas.path.replaceAll('\\', '/');
            if (pathNormal.endsWith('test/pembantu/pompa_uji.dart') ||
                pathNormal.endsWith(
                  'test/penjaga/aturan_pengujian_test.dart',
                )) {
              continue;
            }

            final baris = entitas.readAsLinesSync();
            for (var i = 0; i < baris.length; i++) {
              final b = baris[i];
              // Abaikan komentar
              if (b.trim().startsWith('//') || b.trim().startsWith('*')) {
                continue;
              }
              if (b.contains('pumpAndSettle(')) {
                berkasMelanggar.add('$pathNormal:${i + 1} -> ${b.trim()}');
              }
            }
          }
        }

        periksaDirektori(direktoriTest);
        periksaDirektori(direktoriIntegration);

        expect(
          berkasMelanggar,
          isEmpty,
          reason:
              'pumpAndSettle DILARANG di luar test/pembantu/pompa_uji.dart:\n'
              '${berkasMelanggar.join('\n')}',
        );
      },
    );

    test('2. Future.delayed DILARANG pada berkas uji widget', () {
      final direktoriTest = Directory('test');
      final berkasMelanggar = <String>[];

      for (final entitas in direktoriTest.listSync(recursive: true)) {
        if (entitas is! File || !entitas.path.endsWith('.dart')) continue;
        final teks = entitas.readAsStringSync();
        // Berkas uji widget ditandai dengan pemanggilan testWidgets
        if (!teks.contains('testWidgets(')) continue;

        final pathNormal = entitas.path.replaceAll('\\', '/');
        if (pathNormal.endsWith('test/penjaga/aturan_pengujian_test.dart')) {
          continue;
        }
        final baris = entitas.readAsLinesSync();
        for (var i = 0; i < baris.length; i++) {
          final b = baris[i];
          if (b.trim().startsWith('//') || b.trim().startsWith('*')) continue;
          if (b.contains('Future.delayed(')) {
            berkasMelanggar.add('$pathNormal:${i + 1} -> ${b.trim()}');
          }
        }
      }

      expect(
        berkasMelanggar,
        isEmpty,
        reason:
            'Future.delayed DILARANG pada berkas uji widget:\n'
            '${berkasMelanggar.join('\n')}',
      );
    });

    test(
      '3. CircularProgressIndicator dan LinearProgressIndicator di lib/ hanya boleh ada di IndikatorMemuat',
      () {
        final direktoriLib = Directory('lib');
        final berkasMelanggar = <String>[];

        for (final entitas in direktoriLib.listSync(recursive: true)) {
          if (entitas is! File || !entitas.path.endsWith('.dart')) continue;
          final pathNormal = entitas.path.replaceAll('\\', '/');
          if (pathNormal.endsWith('lib/komponen/indikator_memuat.dart')) {
            continue;
          }

          final baris = entitas.readAsLinesSync();
          for (var i = 0; i < baris.length; i++) {
            final b = baris[i];
            if (b.trim().startsWith('//') || b.trim().startsWith('*')) continue;
            if (b.contains('CircularProgressIndicator') ||
                b.contains('LinearProgressIndicator')) {
              berkasMelanggar.add('$pathNormal:${i + 1} -> ${b.trim()}');
            }
          }
        }

        expect(
          berkasMelanggar,
          isEmpty,
          reason:
              'ProgressIndicator di lib/ wajib dialihkan ke IndikatorMemuat:\n'
              '${berkasMelanggar.join('\n')}',
        );
      },
    );

    test('4. Setiap berkas uji widget wajib menyertakan anotasi @Timeout', () {
      final direktoriTest = Directory('test');
      final berkasTanpaTimeout = <String>[];

      for (final entitas in direktoriTest.listSync(recursive: true)) {
        if (entitas is! File || !entitas.path.endsWith('.dart')) continue;
        final teks = entitas.readAsStringSync();
        if (!teks.contains('testWidgets(')) continue;

        final pathNormal = entitas.path.replaceAll('\\', '/');
        if (!teks.contains('@Timeout(')) {
          berkasTanpaTimeout.add(pathNormal);
        }
      }

      expect(
        berkasTanpaTimeout,
        isEmpty,
        reason:
            'Berkas uji widget berikut belum menyertakan @Timeout(Duration(seconds: 30)):\n'
            '${berkasTanpaTimeout.join('\n')}',
      );
    });

    test('5. pompaAman DILARANG di seluruh berkas uji (Tahap 8C)', () {
      final berkasMelanggar = <String>[];

      void periksa(Directory dir) {
        if (!dir.existsSync()) return;
        for (final entitas in dir.listSync(recursive: true)) {
          if (entitas is! File || !entitas.path.endsWith('.dart')) continue;
          final pathNormal = entitas.path.replaceAll('\\', '/');
          if (pathNormal.endsWith('test/penjaga/aturan_pengujian_test.dart')) {
            continue;
          }

          final baris = entitas.readAsLinesSync();
          for (var i = 0; i < baris.length; i++) {
            final b = baris[i];
            if (b.trim().startsWith('//') || b.trim().startsWith('*')) continue;
            if (b.contains('pompaAman(')) {
              berkasMelanggar.add('$pathNormal:${i + 1} -> ${b.trim()}');
            }
          }
        }
      }

      periksa(Directory('test'));
      periksa(Directory('integration_test'));

      expect(
        berkasMelanggar,
        isEmpty,
        reason:
            'pompaAman DILARANG di seluruh berkas uji. Gunakan pompaHingga/pompaHinggaAda:\n'
            '${berkasMelanggar.join('\n')}',
      );
    });

    test(
      '6. pump(const Duration...) DILARANG di luar test/pembantu/pompa_uji.dart (Tahap 8C)',
      () {
        final berkasMelanggar = <String>[];

        void periksa(Directory dir) {
          if (!dir.existsSync()) return;
          for (final entitas in dir.listSync(recursive: true)) {
            if (entitas is! File || !entitas.path.endsWith('.dart')) continue;
            final pathNormal = entitas.path.replaceAll('\\', '/');
            if (pathNormal.endsWith('test/pembantu/pompa_uji.dart') ||
                pathNormal.endsWith(
                  'test/penjaga/aturan_pengujian_test.dart',
                )) {
              continue;
            }

            final baris = entitas.readAsLinesSync();
            for (var i = 0; i < baris.length; i++) {
              final b = baris[i];
              if (b.trim().startsWith('//') || b.trim().startsWith('*')) {
                continue;
              }
              if (b.contains('pump(const Duration') ||
                  b.contains('pump(Duration(')) {
                // Abaikan pump(Duration.zero) yang murni memompa satu frame
                if (b.contains('Duration.zero')) continue;
                berkasMelanggar.add('$pathNormal:${i + 1} -> ${b.trim()}');
              }
            }
          }
        }

        periksa(Directory('test'));
        periksa(Directory('integration_test'));

        expect(
          berkasMelanggar,
          isEmpty,
          reason:
              'pump(const Duration...) sebagai penunggu data DILARANG di luar test/pembantu/pompa_uji.dart:\n'
              '${berkasMelanggar.join('\n')}',
        );
      },
    );

    test(
      '7. warnIfMissed: false DILARANG di seluruh berkas uji (Tahap 8C)',
      () {
        final berkasMelanggar = <String>[];

        void periksa(Directory dir) {
          if (!dir.existsSync()) return;
          for (final entitas in dir.listSync(recursive: true)) {
            if (entitas is! File || !entitas.path.endsWith('.dart')) continue;
            final pathNormal = entitas.path.replaceAll('\\', '/');
            if (pathNormal.endsWith(
              'test/penjaga/aturan_pengujian_test.dart',
            )) {
              continue;
            }

            final baris = entitas.readAsLinesSync();
            for (var i = 0; i < baris.length; i++) {
              final b = baris[i];
              if (b.trim().startsWith('//') || b.trim().startsWith('*')) {
                continue;
              }
              if (b.contains('warnIfMissed: false') ||
                  b.contains('warnIfMissed:false')) {
                berkasMelanggar.add('$pathNormal:${i + 1} -> ${b.trim()}');
              }
            }
          }
        }

        periksa(Directory('test'));
        periksa(Directory('integration_test'));

        expect(
          berkasMelanggar,
          isEmpty,
          reason:
              'warnIfMissed: false DILARANG di seluruh berkas uji:\n'
              '${berkasMelanggar.join('\n')}',
        );
      },
    );
  });
}
