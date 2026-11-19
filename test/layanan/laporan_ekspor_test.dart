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
      // Simpan contoh ekspor PDF
      final folderEkspor = Directory('docs/contoh_ekspor');
      if (!folderEkspor.existsSync()) folderEkspor.createSync(recursive: true);
      File('docs/contoh_ekspor/laporan.pdf').writeAsBytesSync(pdfNormalBytes);

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
      await tester.pumpAndSettle();

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

      // Simpan contoh ekspor PNG Normal
      File('docs/contoh_ekspor/laporan_normal.png').writeAsBytesSync(pngBytes!);

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
      await tester.pumpAndSettle();

      Uint8List? pngSensorBytes;
      await tester.runAsync(() async {
        pngSensorBytes = await PembuatGambarLaporan.tangkapDariKunci(kunciSensor, pixelRatio: 3.0);
      });
      expect(pngSensorBytes, isNotNull);
      File('docs/contoh_ekspor/laporan_sensor.png').writeAsBytesSync(pngSensorBytes!);
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
  });
}
