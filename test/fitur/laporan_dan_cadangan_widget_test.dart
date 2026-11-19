import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/cadangan/cadangan_repositori.dart';
import 'package:funda/data/penyedia_basis_data.dart';
import 'package:funda/fitur/beranda/tampilan/layar_beranda.dart';
import 'package:funda/fitur/cadangan/kontroler/penyedia_cadangan.dart';
import 'package:funda/fitur/cadangan/tampilan/layar_cadangan.dart';
import 'package:funda/fitur/laporan/kontroler/penyedia_laporan.dart';
import 'package:funda/fitur/laporan/tampilan/layar_laporan_bulanan.dart';
import 'package:funda/fitur/laporan/tampilan/tampilan_kartu_laporan.dart';
import 'package:funda/layanan/laporan/layanan_bagikan.dart';
import 'package:funda/fitur/belajar/model/pembaca_konten.dart';
import 'dart:io';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BasisDataFunda db;
  late LayananBagikanPalsu layananPalsu;
  late KontenLaporan dummyKonten;
  late Directory tempDir;
  late CadanganRepositori cadanganRepo;

  setUp(() {
    db = BasisDataFunda(NativeDatabase.memory());
    tempDir = Directory.systemTemp.createTempSync('funda_test_widget_cadangan_');
    cadanganRepo = CadanganRepositori(db, direktoriPenyimpananUji: tempDir);
    layananPalsu = LayananBagikanPalsu(direktoriUji: tempDir);

    final jsonStr = File('aset/konten/laporan.json').readAsStringSync();
    dummyKonten = PembacaKonten.uraiLaporan(jsonStr);
  });

  tearDown(() async {
    await db.close();
    try {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    } catch (_) {}
  });

  Widget bangunAplikasiUji({
    required Widget child,
    List<dynamic> overrides = const [],
    double textScaleFactor = 1.0,
  }) {
    return ProviderScope(
      overrides: [
        penyediaBasisData.overrideWithValue(db),
        penyediaCadanganRepositori.overrideWithValue(cadanganRepo),
        penyediaLayananBagikan.overrideWithValue(layananPalsu),
        penyediaKontenLaporan.overrideWith((ref) => Future.value(dummyKonten)),
        ...overrides,
      ],
      child: MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            textScaler: TextScaler.linear(textScaleFactor),
            size: const Size(400, 900),
          ),
          child: child,
        ),
      ),
    );
  }

  Future<void> selesaikanAsync(WidgetTester tester) async {
    await tester.pump();
    await tester.runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 200));
    });
    await tester.pump();
  }

  Future<void> ketukDanSelesaikan(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pump();
    await tester.runAsync(() async {
      for (int i = 0; i < 50; i++) {
        await Future.delayed(const Duration(milliseconds: 50));
        if (layananPalsu.riwayatDisimpan.isNotEmpty) break;
      }
    });
    await tester.pump();
  }

  group('Pengujian Widget: Layar Laporan Bulanan', () {
    testWidgets('Tampil lengkap, saklar sensor privasi menyembunyikan nominal, tombol bagikan bekerja', (tester) async {
      await db.into(db.tabelDompet).insert(
            TabelDompetCompanion.insert(
              id: 'dmp_1',
              nama: 'Dompet Utama',
              jenis: 'tunai',
              ikon: 'wallet',
              warna: '#006C4C',
              saldoAwalRupiah: const Value(2000000),
            ),
          );

      await db.into(db.tabelKategori).insert(
            TabelKategoriCompanion.insert(
              id: 'kat_makan',
              nama: 'Makan',
              arus: 'keluar',
              sifat: 'kebutuhan',
              ikon: 'utensils',
            ),
          );

      final sekarang = DateTime.now();
      await db.into(db.tabelTransaksi).insert(
            TabelTransaksiCompanion.insert(
              id: 'tx_1',
              dompetId: 'dmp_1',
              kategoriId: const Value('kat_makan'),
              jumlahRupiah: 500000,
              jenis: 'keluar',
              waktuTransaksi: DateTime(sekarang.year, sekarang.month, 10),
            ),
          );

      await tester.pumpWidget(bangunAplikasiUji(child: const LayarLaporanBulanan()));
      await selesaikanAsync(tester);

      expect(find.text('Laporan Bulanan'), findsOneWidget);
      expect(find.text('Pilih Bulan'), findsOneWidget);
      expect(find.text('Sembunyikan nominal'), findsOneWidget);
      expect(find.text('Bagikan Gambar'), findsOneWidget);
      expect(find.text('Bagikan PDF'), findsOneWidget);
      expect(find.byType(TampilanKartuLaporan), findsOneWidget);

      // Aktifkan saklar sembunyikan nominal
      await ketukDanSelesaikan(tester, find.byType(Switch));

      // Verifikasi di mode sensor: tidak boleh ada teks "Rp"
      final semuaText = tester.widgetList<Text>(find.descendant(
        of: find.byType(TampilanKartuLaporan),
        matching: find.byType(Text),
      ));
      for (final widget in semuaText) {
        expect(widget.data?.contains('Rp'), isFalse, reason: 'Teks "${widget.data}" tidak boleh memuat "Rp" pada mode sensor');
      }

      // Tekan tombol bagikan gambar
      await ketukDanSelesaikan(tester, find.text('Bagikan Gambar'));
      expect(layananPalsu.riwayatDisimpan.isNotEmpty, isTrue);
      expect(layananPalsu.riwayatDibagikan.isNotEmpty, isTrue);
      expect(layananPalsu.riwayatDibagikan.first, contains('.png'));

      // Tekan tombol bagikan PDF
      await ketukDanSelesaikan(tester, find.text('Bagikan PDF'));
      expect(layananPalsu.riwayatDibagikan.any((item) => item.contains('.pdf')), isTrue);
    });

    testWidgets('Toleran terhadap skala teks 2.0 (bebas RenderFlex overflow)', (tester) async {
      await tester.pumpWidget(bangunAplikasiUji(
        child: const LayarLaporanBulanan(),
        textScaleFactor: 2.0,
      ));
      await selesaikanAsync(tester);
    });
  });

  group('Pengujian Widget: Layar Cadangan & Pemulihan', () {
    testWidgets('Tampil status, buat cadangan berhasil memanggil layanan bagikan', (tester) async {
      await tester.pumpWidget(bangunAplikasiUji(child: const LayarCadangan()));
      await selesaikanAsync(tester);

      expect(find.text('Cadangan & Pemulihan'), findsOneWidget);
      expect(find.text('Status Cadangan Data'), findsOneWidget);
      expect(find.text('Buat Cadangan dan Bagikan'), findsOneWidget);
      expect(find.text('Pulihkan dari Berkas'), findsOneWidget);

      await ketukDanSelesaikan(tester, find.text('Buat Cadangan dan Bagikan'));

      expect(layananPalsu.riwayatDisimpan.isNotEmpty, isTrue);
      expect(layananPalsu.riwayatDibagikan.first, contains('.json'));
    });

    testWidgets('Alur pemulihan berkas: pratinjau data -> dialog konfirmasi 2 langkah', (tester) async {
      final jsonValid = await cadanganRepo.eksporCadanganKeJson();

      await tester.pumpWidget(bangunAplikasiUji(
        child: const LayarCadangan(),
        overrides: [
          penyediaPemilihBerkas.overrideWithValue(() async => jsonValid),
        ],
      ));
      await selesaikanAsync(tester);

      await ketukDanSelesaikan(tester, find.text('Pulihkan dari Berkas'));

      expect(find.text('Pratinjau Data Cadangan'), findsOneWidget);
      expect(find.text('Peringatan: Memulihkan cadangan akan MENGGANTI semua data yang ada sekarang.'), findsOneWidget);

      await ketukDanSelesaikan(tester, find.text('Lanjut Pulihkan'));

      expect(find.text('Konfirmasi Penggantian Data'), findsOneWidget);
      expect(find.text('Yakin ingin menimpa seluruh data saat ini? Data lama akan disimpan otomatis di cadangan keselamatan.'), findsOneWidget);

      await tester.tap(find.text('Ya, Pulihkan Sekarang'));
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 100)));
        if (find.byType(SnackBar).evaluate().isNotEmpty) break;
      }
      await tester.pump();

      expect(find.text('Data berhasil dipulihkan dari cadangan.'), findsOneWidget);
    });

    testWidgets('Penanganan berkas rusak memunculkan pesan galat yang jelas', (tester) async {
      const jsonRusak = '{"aplikasi": "bukan_funda"}';

      await tester.pumpWidget(bangunAplikasiUji(
        child: const LayarCadangan(),
        overrides: [
          penyediaPemilihBerkas.overrideWithValue(() async => jsonRusak),
        ],
      ));
      await selesaikanAsync(tester);

      await ketukDanSelesaikan(tester, find.text('Pulihkan dari Berkas'));

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Berkas ini bukan berkas cadangan resmi'), findsOneWidget);
    });
  });

  group('Pengujian Widget: Banner Pengingat Cadangan di Beranda', () {
    testWidgets('Banner cadangan muncul saat perluPengingat == true dan tombol Nanti menundanya', (tester) async {
      // Masukkan 1 dompet aktif agar Beranda tidak masuk ke KeadaanKosong
      await db.into(db.tabelDompet).insert(
            TabelDompetCompanion.insert(
              id: 'dmp_1',
              nama: 'Dompet Utama',
              jenis: 'tunai',
              ikon: 'wallet',
              warna: '#006C4C',
              saldoAwalRupiah: const Value(2000000),
            ),
          );

      const statusPerlu = StatusFiturCadangan(
        terakhirDicadangkan: null,
        adaCadanganKeselamatan: false,
        jumlahTransaksi: 15,
        hariSejakDataPertama: 20,
        ditundaSampai: null,
        perluPengingat: true,
      );

      await tester.pumpWidget(bangunAplikasiUji(
        child: const LayarBeranda(),
        overrides: [
          penyediaStatusCadangan.overrideWith((ref) => Future.value(statusPerlu)),
        ],
      ));
      await selesaikanAsync(tester);

      expect(find.text('Yuk, amankan catatan keuanganmu'), findsOneWidget);
      expect(find.text('Cadangkan sekarang'), findsOneWidget);
      expect(find.text('Nanti'), findsOneWidget);

      await tester.tap(find.text('Nanti'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final rowTunda = await (db.select(db.tabelPengaturan)
            ..where((t) => t.kunci.equals('pengingat_cadangan_ditunda_sampai')))
          .getSingleOrNull();
      expect(rowTunda, isNotNull);

      // Unmount dan flush timer Drift sebelum test selesai
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });
  });
}
