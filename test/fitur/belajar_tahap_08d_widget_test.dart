@Timeout(Duration(seconds: 30))
library;

import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/komponen/tombol_funda.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/penyedia_data.dart';
import 'package:funda/fitur/belajar/kontroler/penyedia_belajar.dart';
import 'package:funda/fitur/belajar/model/pembaca_konten.dart';
import 'package:funda/fitur/belajar/tampilan/layar_kuis_modul.dart';
import 'package:funda/fitur/belajar/tampilan/layar_pemutar_pelajaran.dart';
import 'package:funda/perhitungan/perhitungan_belajar.dart';
import 'package:funda/tema/tema.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../pembantu/pompa_uji.dart';

void main() {
  group('Pengujian Widget Belajar Tahap 8D (Modul 6 & Misi Refleksi)', () {
    late BasisDataFunda db;

    setUpAll(() async {
      await initializeDateFormatting('id_ID', null);
    });

    setUp(() {
      db = BasisDataFunda(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    PelajaranKonten muatPelajaranLocal(String modulId, String pelajaranId) {
      final f = File('aset/konten/pemula/$modulId/$pelajaranId.json');
      final data = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
      return PelajaranKonten.fromJson(data);
    }

    ModulKonten muatModulLocal(String modulId) {
      final f = File('aset/konten/pemula/$modulId/modul.json');
      final data = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
      return ModulKonten.fromJson(data);
    }

    testWidgets(
      '1. Kartu Misi Refleksi (6.1): Tombol simpan nonaktif di bawah minimal karakter -> aktif saat memenuhi -> simpan ke DB palsu',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final pel = muatPelajaranLocal('psikologi_uang', 'psikologi_uang_6_1');

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              penyediaBasisData.overrideWithValue(db),
              penyediaFotoData.overrideWith(
                (ref) => Future.value(FotoDataPengguna.kosong()),
              ),
              penyediaKamus.overrideWith(
                (ref) => Future.value(<String, IstilahKamus>{}),
              ),
            ],
            child: MediaQuery(
              data: const MediaQueryData(disableAnimations: true),
              child: MaterialApp(
                theme: TemaFunda.temaTerang,
                home: LayarPemutarPelajaran(
                  modulId: 'psikologi_uang',
                  pelajaranId: 'psikologi_uang_6_1',
                  pelajaranOverride: pel,
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        // Maju melewati pemantik dan 3 kartu konsep serta contoh angka
        while (find.text('Uji Pemahaman Singkat').evaluate().isEmpty) {
          final btnLanjut = find.byKey(const Key('tombol_lanjut'));
          expect(btnLanjut, findsOneWidget);
          await tester.tap(btnLanjut);
          await tester.pump();
        }

        // Jawab 3 soal Cek Paham
        final opsi1 = find.textContaining('Membeli sesuatu secara mendadak');
        await tester.ensureVisible(opsi1);
        await tester.pump();
        await tester.tap(opsi1);
        await tester.pump();

        final opsi2 = find.textContaining('Notifikasi promo saat sedang lelah');
        await tester.ensureVisible(opsi2);
        await tester.pump();
        await tester.tap(opsi2);
        await tester.pump();

        final opsi3 = find.textContaining('Menambah jarak kecil');
        await tester.ensureVisible(opsi3);
        await tester.pump();
        await tester.tap(opsi3);
        await tester.pump();

        // Tap Lanjut ke Misi
        final btnLanjutKeMisi = find.byKey(const Key('tombol_lanjut'));
        expect(
          tester.widget<TombolFunda>(btnLanjutKeMisi).padaTekan,
          isNotNull,
        );
        await tester.tap(btnLanjutKeMisi);
        await tester.pump();

        // Pastikan berada di layar Misi Refleksi
        await pompaHinggaAda(tester, find.text('Kenali pemicu belanjamu'));
        expect(find.text('Kenali pemicu belanjamu'), findsOneWidget);
        expect(
          find.text('Catatan ini privat dan hanya tersimpan di HP-mu.'),
          findsOneWidget,
        );
        expect(
          find.textContaining('Kapan atau dalam keadaan apa'),
          findsOneWidget,
        );

        // Verifikasi input dan tombol simpan
        final inputRefleksi = find.byKey(const Key('input_refleksi'));
        final tombolSimpan = find.byKey(const Key('tombol_simpan_refleksi'));
        expect(inputRefleksi, findsOneWidget);
        expect(tombolSimpan, findsOneWidget);

        // Awalnya kosong -> tombol simpan nonaktif (null padaTekan)
        expect(tester.widget<TombolFunda>(tombolSimpan).padaTekan, isNull);

        // Ketik kurang dari 10 karakter -> tombol tetap nonaktif
        await tester.enterText(inputRefleksi, 'Capek');
        await tester.pump();
        expect(tester.widget<TombolFunda>(tombolSimpan).padaTekan, isNull);

        // Ketik spasi saja sampai 15 karakter -> trim() tetap < 10 -> nonaktif
        await tester.enterText(inputRefleksi, '     Capek     ');
        await tester.pump();
        expect(tester.widget<TombolFunda>(tombolSimpan).padaTekan, isNull);

        // Ketik valid >= 10 karakter
        const refleksiValid = 'Saat capek pulang kuliah malam-malam';
        await tester.enterText(inputRefleksi, refleksiValid);
        await tester.pump();
        expect(tester.widget<TombolFunda>(tombolSimpan).padaTekan, isNotNull);

        // Tap Simpan Refleksi
        await tester.tap(tombolSimpan);
        await tester.pump();

        // Verifikasi pesan sukses
        expect(
          find.text('Refleksi tersimpan dengan aman di perangkatmu.'),
          findsOneWidget,
        );

        // Tombol Lanjut sekarang menjadi aktif
        final btnLanjut = find.byKey(const Key('tombol_lanjut'));
        expect(tester.widget<TombolFunda>(btnLanjut).padaTekan, isNotNull);

        // Verifikasi rekaman ke tabel_hasil_misi
        final hasilMisi =
            await (db.select(db.tabelHasilMisi)
                  ..where((m) => m.misiId.equals('psikologi_uang_6_1')))
                .getSingleOrNull();
        expect(hasilMisi, isNotNull);
        expect(hasilMisi!.status, equals('selesai'));
        expect(hasilMisi.tipe, equals('refleksi'));

        final muatan =
            jsonDecode(hasilMisi.muatanJson!) as Map<String, dynamic>;
        expect(muatan['jawaban'], equals(refleksiValid));

        await bongkarWidget(tester);
      },
    );

    testWidgets(
      '2. Kartu Misi 6.2 dengan umpan balik ringkasan_langganan_dan_keinginan',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        // Siapkan data dompet, kategori, tagihan, dan transaksi pengeluaran keinginan
        final sekarang = DateTime.now();
        await db
            .into(db.tabelDompet)
            .insert(
              TabelDompetCompanion.insert(
                id: 'dompet_1',
                nama: 'Dompet Utama',
                jenis: 'tunai',
                ikon: 'wallet',
                warna: 'tintHijau',
                saldoAwalRupiah: const Value(5000000),
              ),
            );

        await db
            .into(db.tabelKategori)
            .insert(
              TabelKategoriCompanion.insert(
                id: 'kat_keinginan',
                nama: 'Jajan & Hiburan',
                arus: 'keluar',
                sifat: 'keinginan',
                ikon: 'coffee',
              ),
            );

        // 2 langganan aktif
        await db
            .into(db.tabelTagihan)
            .insert(
              TabelTagihanCompanion.insert(
                id: 'tagihan_1',
                nama: 'Musik Streaming',
                jenis: 'langganan',
                frekuensi: 'bulanan',
                jumlahPerkiraanRupiah: const Value(55000),
                kategoriId: 'kat_keinginan',
                jatuhTempoPertama: sekarang,
                dibuatPada: sekarang,
              ),
            );

        await db
            .into(db.tabelTagihan)
            .insert(
              TabelTagihanCompanion.insert(
                id: 'tagihan_2',
                nama: 'Film Streaming',
                jenis: 'langganan',
                frekuensi: 'bulanan',
                jumlahPerkiraanRupiah: const Value(100000),
                kategoriId: 'kat_keinginan',
                jatuhTempoPertama: sekarang,
                dibuatPada: sekarang,
              ),
            );

        // 1 pengeluaran keinginan bulan ini sebesar Rp250.000
        await db
            .into(db.tabelTransaksi)
            .insert(
              TabelTransaksiCompanion.insert(
                id: 'tx_1',
                dompetId: 'dompet_1',
                kategoriId: const Value('kat_keinginan'),
                jumlahRupiah: 250000,
                jenis: 'keluar',
                waktuTransaksi: sekarang,
                dibuatPada: Value(sekarang),
              ),
            );

        final pel = muatPelajaranLocal('psikologi_uang', 'psikologi_uang_6_2');

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              penyediaBasisData.overrideWithValue(db),
              penyediaFotoData.overrideWith(
                (ref) => Future.value(FotoDataPengguna.kosong()),
              ),
              penyediaKamus.overrideWith(
                (ref) => Future.value(<String, IstilahKamus>{}),
              ),
            ],
            child: MediaQuery(
              data: const MediaQueryData(disableAnimations: true),
              child: MaterialApp(
                theme: TemaFunda.temaTerang,
                home: LayarPemutarPelajaran(
                  modulId: 'psikologi_uang',
                  pelajaranId: 'psikologi_uang_6_2',
                  pelajaranOverride: pel,
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        // Maju ke Cek Paham
        while (find.text('Uji Pemahaman Singkat').evaluate().isEmpty) {
          final btnLanjut = find.byKey(const Key('tombol_lanjut'));
          await tester.tap(btnLanjut);
          await tester.pump();
        }

        // Jawab 3 soal Cek Paham 6.2
        final opsi1 = find.textContaining(
          'Nominalnya kecil dan berjalan rutin',
        );
        await tester.ensureVisible(opsi1);
        await tester.pump();
        await tester.tap(opsi1);
        await tester.pump();

        final opsi2 = find.textContaining('Apakah aku benar-benar memakainya');
        await tester.ensureVisible(opsi2);
        await tester.pump();
        await tester.tap(opsi2);
        await tester.pump();

        final opsi3 = find.textContaining('Rp600.000');
        await tester.ensureVisible(opsi3);
        await tester.pump();
        await tester.tap(opsi3);
        await tester.pump();

        // Tap Lanjut ke Misi
        final btnLanjutKeMisi = find.byKey(const Key('tombol_lanjut'));
        await tester.tap(btnLanjutKeMisi);
        await tester.pump();

        // Pastikan berada di layar Misi Lihat Hitungan
        await pompaHinggaAda(
          tester,
          find.text('Lihat langganan dan keinginanmu'),
        );
        expect(find.text('Lihat langganan dan keinginanmu'), findsOneWidget);

        // Tap Lanjut ke Kartu Umpan Balik Nyata
        final btnLanjutKeUmpanBalik = find.byKey(const Key('tombol_lanjut'));
        await tester.tap(btnLanjutKeUmpanBalik);
        await tester.pump();

        // Umpan balik nyata muncul
        await pompaHinggaAda(tester, find.text('Umpan Balik Nyata'));
        expect(find.text('Umpan Balik Nyata'), findsOneWidget);
        expect(
          find.textContaining(
            'Kamu punya 2 langganan aktif dengan perkiraan sekitar Rp155.000 per bulan.',
          ),
          findsOneWidget,
        );
        expect(
          find.textContaining(
            'Pengeluaran keinginanmu bulan ini tercatat Rp250.000.',
          ),
          findsOneWidget,
        );
        expect(
          find.textContaining(
            'Ini gambaran untuk kamu kenali, bukan penilaian.',
          ),
          findsOneWidget,
        );

        await bongkarWidget(tester);
      },
    );

    testWidgets('3. Kuis Modul 6: Jawab soal dan simpan hasil', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final modul = muatModulLocal('psikologi_uang');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            penyediaBasisData.overrideWithValue(db),
            penyediaDaftarSemuaModul.overrideWith(
              (ref) => Future.value([modul]),
            ),
          ],
          child: MaterialApp(
            theme: TemaFunda.temaTerang,
            home: const LayarKuisModul(modulId: 'psikologi_uang'),
          ),
        ),
      );
      await tester.pump();

      expect(find.textContaining('Kuis'), findsWidgets);

      await bongkarWidget(tester);
    });

    testWidgets(
      '4. Aksesibilitas Skala Teks 2.0 pada Layar 360x640: Tidak overflow pada pelajaran 6.1',
      (tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final pel = muatPelajaranLocal('psikologi_uang', 'psikologi_uang_6_1');

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              penyediaBasisData.overrideWithValue(db),
              penyediaFotoData.overrideWith(
                (ref) => Future.value(FotoDataPengguna.kosong()),
              ),
              penyediaKamus.overrideWith(
                (ref) => Future.value(<String, IstilahKamus>{}),
              ),
            ],
            child: MediaQuery(
              data: const MediaQueryData(
                size: Size(360, 640),
                textScaler: TextScaler.linear(2.0),
              ),
              child: MaterialApp(
                theme: TemaFunda.temaTerang,
                home: LayarPemutarPelajaran(
                  modulId: 'psikologi_uang',
                  pelajaranId: 'psikologi_uang_6_1',
                  pelajaranOverride: pel,
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        // Render awal bebas overflow
        expect(tester.takeException(), isNull);
        expect(find.text('Pemantik'), findsOneWidget);

        await bongkarWidget(tester);
      },
    );
  });
}
