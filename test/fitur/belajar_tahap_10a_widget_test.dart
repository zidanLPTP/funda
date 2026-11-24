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
import 'package:funda/fitur/belajar/tampilan/layar_belajar.dart';
import 'package:funda/fitur/belajar/tampilan/layar_kuis_modul.dart';
import 'package:funda/fitur/belajar/tampilan/layar_pemutar_pelajaran.dart';
import 'package:funda/perhitungan/perhitungan_belajar.dart';
import 'package:funda/tema/tema.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../pembantu/pompa_uji.dart';

void main() {
  group('Pengujian Widget Belajar Tahap 10A (Modul 8 & Modul 9)', () {
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
      final f = File('aset/konten/menengah/$modulId/$pelajaranId.json');
      final data = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
      return PelajaranKonten.fromJson(data);
    }

    ModulKonten muatModulLocal(String modulId) {
      final f = File('aset/konten/menengah/$modulId/modul.json');
      final data = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
      return ModulKonten.fromJson(data);
    }

    testWidgets('1. Tombol pernyataan baru_satu_sumber pada Modul 8 terkunci: tampil, simpan, dan cabut pernyataan', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final modul8 = muatModulLocal('penghasilan_tambahan');
      final pel81 = muatPelajaranLocal('penghasilan_tambahan', 'penghasilan_tambahan_8_1');

      final fotoDataTerkunci = FotoDataPengguna.kosong().copyWith(
        jumlahSumberPemasukan: 1,
        pernyataan: {},
      );

      final statusModul = tentukanStatusModul(modul: modul8, fotoData: fotoDataTerkunci);
      final statusPel = tentukanStatusPelajaran(
        pelajaran: pel81,
        posisiIndeks: 0,
        daftarPelajaranModul: [pel81],
        gerbangModul: modul8.gerbang,
        fotoData: fotoDataTerkunci,
      );

      final itemModul8 = ItemPetaModul(
        modul: modul8,
        statusModul: statusModul,
        daftarPelajaran: [(pel81, statusPel)],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            penyediaBasisData.overrideWithValue(db),
            penyediaFotoData.overrideWith((ref) => Future.value(fotoDataTerkunci)),
            penyediaKamus.overrideWith((ref) => Future.value(<String, IstilahKamus>{})),
            penyediaPetaBelajar.overrideWith((ref) => Future.value([itemModul8])),
          ],
          child: MaterialApp(
            theme: TemaFunda.temaTerang,
            home: const Scaffold(
              body: LayarBelajar(),
            ),
          ),
        ),
      );
      await tester.pump();
      await pompaHinggaAda(tester, find.text('Penghasilan Tambahan & Freelance'));

      // Modul 8 harus terlihat
      expect(find.text('Penghasilan Tambahan & Freelance'), findsOneWidget);

      // Cari tombol "Aku tidak punya ini"
      final tombolPernyataan = find.text('Aku tidak punya ini');
      expect(tombolPernyataan, findsOneWidget);

      // Tap tombol pernyataan
      await tester.tap(tombolPernyataan);
      await tester.pump();

      // Verifikasi pernyataan tersimpan di database
      final p = await (db.select(db.tabelPernyataan)..where((tbl) => tbl.kunci.equals('baru_satu_sumber'))).getSingleOrNull();
      expect(p, isNotNull);
      expect(p!.nilai, equals('true'));

      // Banner pernyataan harus muncul
      await pompaHinggaAda(tester, find.text('Kamu menyatakan baru punya satu sumber penghasilan.'));
      expect(find.text('Kamu menyatakan baru punya satu sumber penghasilan.'), findsOneWidget);
      expect(find.text('Cabut pernyataan'), findsOneWidget);

      // Tap "Cabut pernyataan"
      await tester.tap(find.text('Cabut pernyataan'));
      await tester.pump();

      // Verifikasi pernyataan terhapus
      final pSetelahCabut = await (db.select(db.tabelPernyataan)..where((tbl) => tbl.kunci.equals('baru_satu_sumber'))).getSingleOrNull();
      expect(pSetelahCabut, isNull);

      await bongkarWidget(tester);
    });

    testWidgets('2. Umpan Balik Pelajaran 8.2 (ringkasan_pemasukan_tambahan)', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final pel = muatPelajaranLocal('penghasilan_tambahan', 'penghasilan_tambahan_8_2');

      // Masukkan transaksi pemasukan dummy
      final now = DateTime.now();
      await db.into(db.tabelDompet).insert(
        TabelDompetCompanion.insert(
          id: 'dmp_1',
          nama: 'Kas',
          jenis: 'tunai',
          ikon: 'wallet',
          warna: 'tintHijau',
        ),
      );
      await db.into(db.tabelKategori).insert(
        TabelKategoriCompanion.insert(
          id: 'kat_gaji',
          nama: 'Gaji',
          arus: 'masuk',
          sifat: 'kebutuhan',
          ikon: 'briefcase',
        ),
      );
      await db.into(db.tabelKategori).insert(
        TabelKategoriCompanion.insert(
          id: 'kat_freelance',
          nama: 'Freelance',
          arus: 'masuk',
          sifat: 'kebutuhan',
          ikon: 'laptop',
        ),
      );
      await db.into(db.tabelTransaksi).insert(
        TabelTransaksiCompanion.insert(
          id: 'tx_1',
          dompetId: 'dmp_1',
          jumlahRupiah: 3000000,
          jenis: 'masuk',
          kategoriId: const Value('kat_gaji'),
          waktuTransaksi: now,
        ),
      );
      await db.into(db.tabelTransaksi).insert(
        TabelTransaksiCompanion.insert(
          id: 'tx_2',
          dompetId: 'dmp_1',
          jumlahRupiah: 1200000,
          jenis: 'masuk',
          kategoriId: const Value('kat_freelance'),
          waktuTransaksi: now,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            penyediaBasisData.overrideWithValue(db),
            penyediaFotoData.overrideWith((ref) => Future.value(FotoDataPengguna.kosong())),
            penyediaKamus.overrideWith((ref) => Future.value(<String, IstilahKamus>{})),
          ],
          child: MaterialApp(
            theme: TemaFunda.temaTerang,
            home: LayarPemutarPelajaran(
              modulId: 'penghasilan_tambahan',
              pelajaranId: 'penghasilan_tambahan_8_2',
              pelajaranOverride: pel,
            ),
          ),
        ),
      );
      await tester.pump();

      // Maju ke Cek Paham
      while (find.text('Uji Pemahaman Singkat').evaluate().isEmpty) {
        final btnLanjut = find.byKey(const Key('tombol_lanjut'));
        expect(btnLanjut, findsOneWidget);
        await tester.tap(btnLanjut);
        await tester.pump();
      }

      // Jawab 3 soal Cek Paham 8.2
      final opsi1 = find.textContaining('Mudah melihat mana penghasilan rutin');
      await tester.ensureVisible(opsi1);
      await tester.pump();
      await tester.tap(opsi1);
      await tester.pump();

      final opsi2 = find.textContaining('Menampung pemasukan lalu mengeluarkan jatah tetap');
      await tester.ensureVisible(opsi2);
      await tester.pump();
      await tester.tap(opsi2);
      await tester.pump();

      final opsi3 = find.textContaining('Bantalan masa sepi, dana darurat');
      await tester.ensureVisible(opsi3);
      await tester.pump();
      await tester.tap(opsi3);
      await tester.pump();

      // Tap Lanjut ke Misi
      final btnLanjutKeMisi = find.byKey(const Key('tombol_lanjut'));
      await tester.tap(btnLanjutKeMisi);
      await tester.pump();

      // Pastikan berada di layar Misi Lihat Hitungan
      await pompaHinggaAda(tester, find.text('Lihat ringkasan sumber pemasukanmu'));
      expect(find.text('Lihat ringkasan sumber pemasukanmu'), findsOneWidget);

      // Tap Lanjut ke Kartu Umpan Balik Nyata
      final btnLanjutKeUmpanBalik = find.byKey(const Key('tombol_lanjut'));
      await tester.tap(btnLanjutKeUmpanBalik);
      await tester.pump();

      // Umpan balik nyata muncul
      await pompaHinggaAda(tester, find.text('Umpan Balik Nyata'));
      expect(find.text('Umpan Balik Nyata'), findsOneWidget);
      expect(find.textContaining('Bulan ini pemasukanmu datang dari 2 sumber dengan total Rp4.200.000.'), findsOneWidget);
      expect(find.textContaining('Terbesar: Gaji (Rp3.000.000), diikuti Freelance (Rp1.200.000).'), findsOneWidget);

      await bongkarWidget(tester);
    });

    testWidgets('3. Umpan Balik Pelajaran 9.2 (ringkasan_penghasilan_tahunan)', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final pel = muatPelajaranLocal('pajak_dasar', 'pajak_dasar_9_2');

      // Masukkan transaksi pemasukan dummy di tahun berjalan
      final now = DateTime.now();
      await db.into(db.tabelDompet).insert(
        TabelDompetCompanion.insert(
          id: 'dmp_1',
          nama: 'Kas',
          jenis: 'tunai',
          ikon: 'wallet',
          warna: 'tintHijau',
        ),
      );
      await db.into(db.tabelTransaksi).insert(
        TabelTransaksiCompanion.insert(
          id: 'tx_tahun_1',
          dompetId: 'dmp_1',
          jumlahRupiah: 10000000,
          jenis: 'masuk',
          waktuTransaksi: now,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            penyediaBasisData.overrideWithValue(db),
            penyediaFotoData.overrideWith((ref) => Future.value(FotoDataPengguna.kosong())),
            penyediaKamus.overrideWith((ref) => Future.value(<String, IstilahKamus>{})),
          ],
          child: MaterialApp(
            theme: TemaFunda.temaTerang,
            home: LayarPemutarPelajaran(
              modulId: 'pajak_dasar',
              pelajaranId: 'pajak_dasar_9_2',
              pelajaranOverride: pel,
            ),
          ),
        ),
      );
      await tester.pump();

      // Maju ke Cek Paham
      while (find.text('Uji Pemahaman Singkat').evaluate().isEmpty) {
        final btnLanjut = find.byKey(const Key('tombol_lanjut'));
        expect(btnLanjut, findsOneWidget);
        await tester.tap(btnLanjut);
        await tester.pump();
      }

      // Jawab 3 soal Cek Paham 9.2
      final opsi1 = find.textContaining('Batas penghasilan tahunan yang tidak dikenai pajak');
      await tester.ensureVisible(opsi1);
      await tester.pump();
      await tester.tap(opsi1);
      await tester.pump();

      final opsi2 = find.textContaining('Karyawan umumnya mendapat bukti potong dari kantor');
      await tester.ensureVisible(opsi2);
      await tester.pump();
      await tester.tap(opsi2);
      await tester.pump();

      final opsi3 = find.textContaining('Memudahkan rekap total penghasilan saat waktunya melapor');
      await tester.ensureVisible(opsi3);
      await tester.pump();
      await tester.tap(opsi3);
      await tester.pump();

      // Tap Lanjut ke Misi
      final btnLanjutKeMisi = find.byKey(const Key('tombol_lanjut'));
      await tester.tap(btnLanjutKeMisi);
      await tester.pump();

      // Pastikan berada di layar Misi Lihat Hitungan
      await pompaHinggaAda(tester, find.text('Lihat rekap pemasukanmu tahun ini'));
      expect(find.text('Lihat rekap pemasukanmu tahun ini'), findsOneWidget);

      // Tap Lanjut ke Kartu Umpan Balik Nyata
      final btnLanjutKeUmpanBalik = find.byKey(const Key('tombol_lanjut'));
      await tester.tap(btnLanjutKeUmpanBalik);
      await tester.pump();

      // Umpan balik nyata muncul
      await pompaHinggaAda(tester, find.text('Umpan Balik Nyata'));
      expect(find.text('Umpan Balik Nyata'), findsOneWidget);
      expect(find.textContaining('Total pemasukanmu yang tercatat tahun ini: Rp10.000.000 (dari 1 bulan yang tercatat).'), findsOneWidget);
      expect(find.textContaining('Ini edukasi umum, bukan nasihat pajak.'), findsOneWidget);

      await bongkarWidget(tester);
    });

    testWidgets('4. Misi Daftar Periksa + Disclaimer 9.3: Centang 3 langkah dan selesaikan', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final pel = muatPelajaranLocal('pajak_dasar', 'pajak_dasar_9_3');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            penyediaBasisData.overrideWithValue(db),
            penyediaFotoData.overrideWith((ref) => Future.value(FotoDataPengguna.kosong())),
            penyediaKamus.overrideWith((ref) => Future.value(<String, IstilahKamus>{})),
          ],
          child: MaterialApp(
            theme: TemaFunda.temaTerang,
            home: LayarPemutarPelajaran(
              modulId: 'pajak_dasar',
              pelajaranId: 'pajak_dasar_9_3',
              pelajaranOverride: pel,
            ),
          ),
        ),
      );
      await tester.pump();

      // Maju ke Cek Paham
      while (find.text('Uji Pemahaman Singkat').evaluate().isEmpty) {
        final btnLanjut = find.byKey(const Key('tombol_lanjut'));
        expect(btnLanjut, findsOneWidget);
        await tester.tap(btnLanjut);
        await tester.pump();
      }

      // Jawab 3 soal Cek Paham 9.3
      final opsi1 = find.textContaining('Laporan penghasilan, pajak yang sudah dipotong');
      await tester.ensureVisible(opsi1);
      await tester.pump();
      await tester.tap(opsi1);
      await tester.pump();

      final opsi2 = find.textContaining('Memenuhi kewajiban administrasi dan menghindari denda');
      await tester.ensureVisible(opsi2);
      await tester.pump();
      await tester.tap(opsi2);
      await tester.pump();

      final opsi3 = find.textContaining('Membantu merapikan catatan pemasukan, saldo, dan utang');
      await tester.ensureVisible(opsi3);
      await tester.pump();
      await tester.tap(opsi3);
      await tester.pump();

      // Tap Lanjut ke Misi
      final btnLanjutKeMisi = find.byKey(const Key('tombol_lanjut'));
      await tester.tap(btnLanjutKeMisi);
      await tester.pump();

      // Pastikan berada di layar Misi Daftar Periksa
      await pompaHinggaAda(tester, find.text('Daftar siap lapor tahunan'));
      expect(find.text('Daftar siap lapor tahunan'), findsOneWidget);
      expect(find.byKey(const Key('disclaimer_langkah_dunia_nyata')), findsOneWidget);

      // Tekan Mengerti pada disclaimer
      await tester.tap(find.text('Mengerti'));
      await tester.pump();

      // Centang 3 langkah (l1, l2, l3)
      await tester.tap(find.byKey(const Key('centang_langkah_l1')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('centang_langkah_l2')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('centang_langkah_l3')));
      await tester.pump();

      // Tombol Selesai Daftar Periksa
      final tombolSelesai = find.byKey(const Key('tombol_selesai_daftar_periksa'));
      await tester.ensureVisible(tombolSelesai);
      await tester.tap(tombolSelesai);
      await tester.pump();

      expect(find.text('Luar biasa! Misi berhasil diselesaikan.'), findsOneWidget);

      // Tombol Lanjut navigasi bawah aktif
      final tombolLanjut = find.byKey(const Key('tombol_lanjut'));
      expect(tester.widget<TombolFunda>(tombolLanjut).padaTekan, isNotNull);

      // Verifikasi rekaman ke tabel_hasil_misi
      final hasilMisi = await (db.select(db.tabelHasilMisi)..where((m) => m.misiId.equals('pajak_dasar_9_3'))).getSingleOrNull();
      expect(hasilMisi, isNotNull);
      expect(hasilMisi!.status, equals('selesai'));
      expect(hasilMisi.tipe, equals('daftar_periksa'));

      final muatan = jsonDecode(hasilMisi.muatanJson!) as Map<String, dynamic>;
      final dicentang = (muatan['dicentang'] as List).cast<String>();
      expect(dicentang, containsAll(['l1', 'l2', 'l3']));

      await bongkarWidget(tester);
    });

    testWidgets('5. Kuis Modul 8 & Modul 9: Tampilan kuis berjalan lancar', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final modul8 = muatModulLocal('penghasilan_tambahan');
      final modul9 = muatModulLocal('pajak_dasar');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            penyediaBasisData.overrideWithValue(db),
            penyediaDaftarSemuaModul.overrideWith((ref) => Future.value([modul8, modul9])),
          ],
          child: MaterialApp(
            theme: TemaFunda.temaTerang,
            home: const LayarKuisModul(
              modulId: 'penghasilan_tambahan',
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.textContaining('Kuis'), findsWidgets);
      await bongkarWidget(tester);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            penyediaBasisData.overrideWithValue(db),
            penyediaDaftarSemuaModul.overrideWith((ref) => Future.value([modul8, modul9])),
          ],
          child: MaterialApp(
            theme: TemaFunda.temaTerang,
            home: const LayarKuisModul(
              modulId: 'pajak_dasar',
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.textContaining('Kuis'), findsWidgets);
      await bongkarWidget(tester);
    });

    testWidgets('6. Aksesibilitas Skala Teks 2.0 pada 360x640: Bebas RenderFlex Overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final pel8 = muatPelajaranLocal('penghasilan_tambahan', 'penghasilan_tambahan_8_1');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            penyediaBasisData.overrideWithValue(db),
            penyediaFotoData.overrideWith((ref) => Future.value(FotoDataPengguna.kosong())),
            penyediaKamus.overrideWith((ref) => Future.value(<String, IstilahKamus>{})),
          ],
          child: MediaQuery(
            data: const MediaQueryData(
              textScaler: TextScaler.linear(2.0),
              disableAnimations: true,
            ),
            child: MaterialApp(
              theme: TemaFunda.temaTerang,
              home: LayarPemutarPelajaran(
                modulId: 'penghasilan_tambahan',
                pelajaranId: 'penghasilan_tambahan_8_1',
                pelajaranOverride: pel8,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      await bongkarWidget(tester);
    });
  });
}
