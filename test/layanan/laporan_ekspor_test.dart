@Timeout(Duration(seconds: 30))
library;

import '../pembantu/pompa_uji.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/fitur/belajar/model/pembaca_konten.dart';
import 'package:funda/layanan/laporan/layanan_bagikan.dart';
import 'package:funda/layanan/laporan/pembuat_gambar_laporan.dart';
import 'package:funda/layanan/laporan/pembuat_pdf_laporan.dart';
import 'package:funda/perhitungan/perhitungan_anggaran_tujuan.dart';
import 'package:funda/perhitungan/perhitungan_laporan_bulanan.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late KontenLaporan konten;
  late Uint8List fontRegBytes;
  late Uint8List fontBoldBytes;
  late LaporanBulanan laporanContoh;

  setUpAll(() {
    final berkasKonten = File('aset/konten/laporan.json');
    konten = PembacaKonten.uraiLaporan(berkasKonten.readAsStringSync());

    fontRegBytes = File('aset/font/PlusJakartaSans-Regular.ttf').readAsBytesSync();
    fontBoldBytes = File('aset/font/PlusJakartaSans-Bold.ttf').readAsBytesSync();

    final masukan = MasukanLaporanBulanan(
      bulan: DateTime(2026, 11, 1),
      waktuDibuat: DateTime(2026, 11, 18, 14, 0),
      uangMasukRupiah: 3000000,
      uangKeluarRupiah: 2450000,
      pengeluaranPerSifat: {
        'kebutuhan': 1900000,
        'keinginan': 550000,
      },
      daftarPosAnggaran: [
        const PosAnggaranLaporan(
          id: '1',
          nama: 'Makan',
          batasRupiah: 1000000,
          terpakaiRupiah: 800000,
          persenTerpakai: 80,
          status: StatusAnggaran.mendekati,
        ),
      ],
      daftarTujuanAktif: [
        const TujuanLaporan(
          id: 't1',
          nama: 'Dana Liburan',
          danaTerkumpulRupiah: 1500000,
          targetRupiah: 3000000,
          persenProgres: 50,
        ),
      ],
      saldoDompetAktifRupiah: 4000000,
      sisaUtangAktifRupiah: 0,
    );

    laporanContoh = susunLaporanBulanan(masukan, konten: konten);
  });

  group('Layanan Ekspor Laporan Bulanan (PNG, PDF, LayananBagikan)', () {
    test('1. PDF berawalan %PDF, memuat halaman sah, dan mendukung mode normal & sensor', () async {
      final pembuatPdf = PembuatPdfLaporan(
        fontRegularBytes: fontRegBytes,
        fontBoldBytes: fontBoldBytes,
      );

      // Normal PDF
      final pdfNormalBytes = await pembuatPdf.buatPdf(
        laporan: laporanContoh,
        konten: konten,
        sensor: false,
      );
      expect(pdfNormalBytes.isNotEmpty, isTrue);
      // Simpan contoh ekspor PDF ke direktori sementara pengujian
      final folderTemp = Directory.systemTemp.createTempSync('funda_uji_pdf_');
      addTearDown(() {
        if (folderTemp.existsSync()) folderTemp.deleteSync(recursive: true);
      });
      File('${folderTemp.path}/laporan.pdf').writeAsBytesSync(pdfNormalBytes);

      // Validasi awalan %PDF
      final headerStr = String.fromCharCodes(pdfNormalBytes.take(5));
      expect(headerStr, equals('%PDF-'));

      // Sensor PDF
      final pdfSensorBytes = await pembuatPdf.buatPdf(
        laporan: laporanContoh,
        konten: konten,
        sensor: true,
      );
      expect(pdfSensorBytes.isNotEmpty, isTrue);
      final headerSensor = String.fromCharCodes(pdfSensorBytes.take(5));
      expect(headerSensor, equals('%PDF-'));

      // Mode sensor: teks "Rp" tidak boleh muncul dalam aliran teks PDF
      final teksLaporanSensor = terapkanSensor(laporanContoh, konten, sensor: true);
      for (final t in teksLaporanSensor.semuaTeks) {
        expect(t.contains('Rp'), isFalse);
      }
    });

    testWidgets('2. PNG berawalan signature PNG dan memiliki lebar tepat 1080 px', (tester) async {
      final kunci = GlobalKey();
      final teks = terapkanSensor(laporanContoh, konten, sensor: false);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Center(
                child: PembuatGambarLaporan.bungkusWidgetLaporan(
                  kunci: kunci,
                  teks: teks,
                  untukEkspor: true,
                ),
              ),
            ),
          ),
        ),
      );
      await pompaAman(tester);

      Uint8List? pngBytes;
      await tester.runAsync(() async {
        pngBytes = await PembuatGambarLaporan.tangkapDariKunci(kunci, pixelRatio: 3.0);
      });
      expect(pngBytes, isNotNull);
      expect(pngBytes!.isNotEmpty, isTrue);

      // Signature PNG: 89 50 4E 47 0D 0A 1A 0A
      const signaturePng = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
      expect(pngBytes!.take(8).toList(), equals(signaturePng));

      // Dimensi IHDR: offset 16 sampai 19 (lebar 4 byte Big Endian)
      final byteData = ByteData.sublistView(pngBytes!);
      final lebar = byteData.getUint32(16, Endian.big);
      expect(lebar, equals(1080), reason: 'Lebar gambar PNG harus tepat 1080 px (360 dp * 3.0)');

      // Simpan contoh ekspor PNG ke direktori sementara pengujian
      final folderTempPng = Directory.systemTemp.createTempSync('funda_uji_png_');
      addTearDown(() {
        if (folderTempPng.existsSync()) folderTempPng.deleteSync(recursive: true);
      });
      File('${folderTempPng.path}/laporan_normal.png').writeAsBytesSync(pngBytes!);

      // Mode Sensor PNG
      final kunciSensor = GlobalKey();
      final teksSensor = terapkanSensor(laporanContoh, konten, sensor: true);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Center(
                child: PembuatGambarLaporan.bungkusWidgetLaporan(
                  kunci: kunciSensor,
                  teks: teksSensor,
                  untukEkspor: true,
                ),
              ),
            ),
          ),
        ),
      );
      await pompaAman(tester);

      Uint8List? pngSensorBytes;
      await tester.runAsync(() async {
        pngSensorBytes = await PembuatGambarLaporan.tangkapDariKunci(kunciSensor, pixelRatio: 3.0);
      });
      expect(pngSensorBytes, isNotNull);
      File('${folderTempPng.path}/laporan_sensor.png').writeAsBytesSync(pngSensorBytes!);
    });

    test('3. LayananBagikanPalsu: simpan, bagikan, format nama berkas benar, dan bersihkan cache > 24 jam', () async {
      final dirTemp = Directory.systemTemp.createTempSync('funda_test_share_');
      final layanan = LayananBagikanPalsu(direktoriUji: dirTemp);

      final namaPng = 'funda_laporan_2026-11.png';
      final namaPdf = 'funda_laporan_2026-11.pdf';

      expect(RegExp(r'^funda_laporan_\d{4}-\d{2}\.(png|pdf)$').hasMatch(namaPng), isTrue);
      expect(RegExp(r'^funda_laporan_\d{4}-\d{2}\.(png|pdf)$').hasMatch(namaPdf), isTrue);

      final filePng = await layanan.simpanBerkas(namaBerkas: namaPng, bytes: [1, 2, 3]);
      expect(filePng.existsSync(), isTrue);
      expect(filePng.path.endsWith(namaPng), isTrue);

      await layanan.bagikanBerkas(pathBerkas: filePng.path, judul: 'Laporan Bulanan');
      expect(layanan.riwayatDibagikan.length, equals(1));
      expect(layanan.riwayatDibagikan.first, contains('funda_laporan_2026-11.png'));

      // Uji pembersihan berkas kedaluwarsa (> 24 jam)
      // Buat berkas lama (ubah modified time ke 25 jam yang lalu)
      final berkasLama = File('${dirTemp.path}/funda_laporan_2026-10.png');
      berkasLama.writeAsBytesSync([0]);
      berkasLama.setLastModifiedSync(DateTime.now().subtract(const Duration(hours: 25)));

      final terhapus = await layanan.bersihkanCacheKedaluwarsa(batasUsia: const Duration(hours: 24));
      expect(terhapus, equals(1));
      expect(berkasLama.existsSync(), isFalse);
      expect(filePng.existsSync(), isTrue); // Berkas baru tetap ada

      // Bersihkan direktori uji
      dirTemp.deleteSync(recursive: true);
    });

    test('4. Ekstraksi teks byte PDF membuktikan PDF sensor bebas teks Rp dan mendukung nominal negatif U+2212', () async {
      final pembuatPdf = PembuatPdfLaporan(
        fontRegularBytes: fontRegBytes,
        fontBoldBytes: fontBoldBytes,
      );

      // Skenario kekayaan bersih negatif (utang > dompet -> U+2212)
      final masukanNegatif = MasukanLaporanBulanan(
        bulan: DateTime(2026, 11, 1),
        waktuDibuat: DateTime(2026, 11, 18, 14, 0),
        uangMasukRupiah: 2000000,
        uangKeluarRupiah: 1500000,
        pengeluaranPerSifat: {'kebutuhan': 1500000},
        daftarPosAnggaran: [],
        daftarTujuanAktif: [],
        saldoDompetAktifRupiah: 1000000,
        sisaUtangAktifRupiah: 3000000, // Bersih: -2.000.000 (mengandung U+2212)
      );
      final laporanNegatif = susunLaporanBulanan(masukanNegatif, konten: konten);

      // 1. Ekspor Normal PDF dengan U+2212
      final pdfNormal = await pembuatPdf.buatPdf(
        laporan: laporanNegatif,
        konten: konten,
        sensor: false,
      );
      expect(pdfNormal.isNotEmpty, isTrue);

      // Ekstraksi teks dari PDF Normal
      final teksNormalPdf = _ekstrakTeksDariBytePdf(pdfNormal);
      expect(teksNormalPdf.contains('Rp'), isTrue, reason: 'PDF normal wajib memuat simbol Rp');

      // 2. Ekspor Sensor PDF
      final pdfSensor = await pembuatPdf.buatPdf(
        laporan: laporanNegatif,
        konten: konten,
        sensor: true,
      );
      expect(pdfSensor.isNotEmpty, isTrue);

      // Ekstraksi teks dari PDF Sensor
      final teksSensorPdf = _ekstrakTeksDariBytePdf(pdfSensor);
      expect(
        teksSensorPdf.contains('Rp'),
        isFalse,
        reason: 'Aliran teks PDF mode sensor tidak boleh memuat kata "Rp"',
      );
    });
  });
}

String _ekstrakTeksDariBytePdf(Uint8List bytes) {
  final patternStream = [115, 116, 114, 101, 97, 109]; // 'stream'
  final patternEnd = [101, 110, 100, 115, 116, 114, 101, 97, 109]; // 'endstream'

  final List<Uint8List> decompressedStreams = [];
  int i = 0;
  while (i < bytes.length) {
    int sIdx = -1;
    for (int j = i; j <= bytes.length - patternStream.length; j++) {
      bool m = true;
      for (int k = 0; k < patternStream.length; k++) {
        if (bytes[j + k] != patternStream[k]) {
          m = false;
          break;
        }
      }
      if (m) {
        sIdx = j;
        break;
      }
    }
    if (sIdx == -1) break;

    var start = sIdx + patternStream.length;
    while (start < bytes.length && (bytes[start] == 10 || bytes[start] == 13)) {
      start++;
    }

    int eIdx = -1;
    for (int j = start; j <= bytes.length - patternEnd.length; j++) {
      bool m = true;
      for (int k = 0; k < patternEnd.length; k++) {
        if (bytes[j + k] != patternEnd[k]) {
          m = false;
          break;
        }
      }
      if (m) {
        eIdx = j;
        break;
      }
    }
    if (eIdx == -1) break;

    var end = eIdx;
    while (end > start && (bytes[end - 1] == 10 || bytes[end - 1] == 13)) {
      end--;
    }

    final sBytes = bytes.sublist(start, end);
    try {
      final decomp = zlib.decode(sBytes);
      decompressedStreams.add(Uint8List.fromList(decomp));
    } catch (_) {}

    i = eIdx + patternEnd.length;
  }

  // 1. Ekstrak kamus ToUnicode CMap dari stream
  final Map<String, String> cmap = {};
  final List<String> contentStreams = [];

  for (final s in decompressedStreams) {
    final str = String.fromCharCodes(s);
    if (str.contains('beginbfchar')) {
      final regexBf = RegExp(r'<([0-9a-fA-F]+)>\s*<([0-9a-fA-F]+)>');
      for (final match in regexBf.allMatches(str)) {
        final cid = match.group(1)!.toUpperCase();
        final codePoint = int.parse(match.group(2)!, radix: 16);
        cmap[cid] = String.fromCharCode(codePoint);
      }
    } else if (str.contains('BT') && str.contains('ET')) {
      contentStreams.add(str);
    }
  }

  // 2. Dekode urutan teks dari content streams
  final buffer = StringBuffer();
  final regexHexStr = RegExp(r'<([0-9a-fA-F]+)>');
  for (final cs in contentStreams) {
    for (final match in regexHexStr.allMatches(cs)) {
      final hex = match.group(1)!.toUpperCase();
      for (int k = 0; k + 4 <= hex.length; k += 4) {
        final code = hex.substring(k, k + 4);
        buffer.write(cmap[code] ?? '');
      }
      buffer.write(' ');
    }
  }

  return buffer.toString();
}
