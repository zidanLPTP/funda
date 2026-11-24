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
  group('Pengujian Widget Belajar Tahap 9B (Modul 7 & Modul 10)', () {
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

    testWidgets(
      '1. Kartu Misi Keputusan (7.1): Opsi tidak aman ditolak -> opsi aman diterima dan tombol lanjut aktif',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final pel = muatPelajaranLocal(
          'paylater_kredit',
          'paylater_kredit_7_1',
        );

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
                  modulId: 'paylater_kredit',
                  pelajaranId: 'paylater_kredit_7_1',
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
          expect(btnLanjut, findsOneWidget);
          await tester.tap(btnLanjut);
          await tester.pump();
        }

        // Jawab 3 soal Cek Paham 7.1
        final opsi1 = find.textContaining(
          'Utang yang mengikat pemasukan bulan depan',
        );
        await tester.ensureVisible(opsi1);
        await tester.pump();
        await tester.tap(opsi1);
        await tester.pump();

        final opsi2 = find.textContaining(
          'Biaya layanan, bunga, denda keterlambatan',
        );
        await tester.ensureVisible(opsi2);
        await tester.pump();
        await tester.tap(opsi2);
        await tester.pump();

        final opsi3 = find.textContaining(
          'total cicilan bulanannya bisa memakan banyak pemasukan',
        );
        await tester.ensureVisible(opsi3);
        await tester.pump();
        await tester.tap(opsi3);
        await tester.pump();

        // Tap Lanjut ke Misi Keputusan
        final btnLanjutKeMisi = find.byKey(const Key('tombol_lanjut'));
        await tester.tap(btnLanjutKeMisi);
        await tester.pump();

        // Pastikan berada di layar Misi Keputusan
        await pompaHinggaAda(
          tester,
          find.text('Cek sebelum menekan bayar nanti'),
        );
        expect(find.text('Cek sebelum menekan bayar nanti'), findsOneWidget);
        expect(find.textContaining('Sepatu seharga Rp600.000'), findsOneWidget);

        // Pilih opsi tidak aman A
        final opsiA = find.byKey(const Key('opsi_keputusan_a'));
        await tester.ensureVisible(opsiA);
        await tester.pump();
        await tester.tap(opsiA);
        await tester.pump();

        // Umpan balik penolakan muncul dan tombol coba pilihan lain ada
        expect(
          find.textContaining(
            'Cicilan itu tetap mengurangi pemasukanmu tiga bulan ke depan',
          ),
          findsOneWidget,
        );
        final tombolCobaLain = find.byKey(
          const Key('tombol_coba_pilihan_lain'),
        );
        expect(tombolCobaLain, findsOneWidget);

        // Tombol lanjut navigasi bawah belum aktif
        final btnLanjutBawah = find.byKey(const Key('tombol_lanjut'));
        expect(tester.widget<TombolFunda>(btnLanjutBawah).padaTekan, isNull);

        // Tap coba pilihan lain agar opsi muncul kembali
        await tester.tap(tombolCobaLain);
        await tester.pump();

        // Pilih opsi aman B
        final opsiB = find.byKey(const Key('opsi_keputusan_b'));
        await tester.ensureVisible(opsiB);
        await tester.pump();
        await tester.tap(opsiB);
        await tester.pump();

        // Umpan balik sukses muncul dan tombol lanjut aktif
        expect(
          find.textContaining(
            'Tepat. Menabung dulu menghindarkanmu dari biaya tambahan',
          ),
          findsOneWidget,
        );
        expect(tester.widget<TombolFunda>(btnLanjutBawah).padaTekan, isNotNull);

        // Tap Lanjut untuk menyelesaikan misi
        await tester.tap(btnLanjutBawah);
        await tester.pump();

        // Verifikasi rekaman ke database
        final hasilMisi =
            await (db.select(db.tabelHasilMisi)
                  ..where((m) => m.misiId.equals('paylater_kredit_7_1')))
                .getSingleOrNull();
        expect(hasilMisi, isNotNull);
        expect(hasilMisi!.status, equals('selesai'));
        expect(hasilMisi.tipe, equals('keputusan'));

        await bongkarWidget(tester);
      },
    );

    testWidgets(
      '2. Kartu Misi Daftar Periksa + Disclaimer (7.3 & 10.2): Menampilkan banner disclaimer dan validasi centang',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final pel = muatPelajaranLocal(
          'paylater_kredit',
          'paylater_kredit_7_3',
        );

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
                  modulId: 'paylater_kredit',
                  pelajaranId: 'paylater_kredit_7_3',
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

        // Jawab 3 soal Cek Paham 7.3
        final opsi1 = find.textContaining(
          'Menghindari bunga berjalan dan menjaga riwayat kredit tetap bersih',
        );
        await tester.ensureVisible(opsi1);
        await tester.pump();
        await tester.tap(opsi1);
        await tester.pump();

        final opsi2 = find.textContaining(
          'Memastikan catatan akurat dan mendeteksi penyalahgunaan data lebih awal',
        );
        await tester.ensureVisible(opsi2);
        await tester.pump();
        await tester.tap(opsi2);
        await tester.pump();

        final opsi3 = find.textContaining(
          'Memakai hanya sesuai kemampuan bayar di anggaranmu',
        );
        await tester.ensureVisible(opsi3);
        await tester.pump();
        await tester.tap(opsi3);
        await tester.pump();

        // Tap Lanjut ke Misi Daftar Periksa
        final btnLanjutKeMisi = find.byKey(const Key('tombol_lanjut'));
        await tester.tap(btnLanjutKeMisi);
        await tester.pump();

        // Pastikan berada di layar Misi Daftar Periksa
        await pompaHinggaAda(tester, find.text('Daftar jaga reputasi kredit'));
        expect(find.text('Daftar jaga reputasi kredit'), findsOneWidget);

        // Verifikasi banner disclaimer langkah dunia nyata
        expect(find.text('Langkah Dunia Nyata'), findsOneWidget);

        // Tombol Selesai awal nonaktif karena minimal 3
        final tombolSelesai = find.byKey(
          const Key('tombol_selesai_daftar_periksa'),
        );
        expect(tombolSelesai, findsOneWidget);
        expect(tester.widget<TombolFunda>(tombolSelesai).padaTekan, isNull);

        // Centang langkah 1 & 2
        await tester.tap(find.byKey(const Key('centang_langkah_l1')));
        await tester.pump();
        await tester.tap(find.byKey(const Key('centang_langkah_l2')));
        await tester.pump();
        expect(tester.widget<TombolFunda>(tombolSelesai).padaTekan, isNull);

        // Centang langkah 3 -> mencapai minimal 3
        await tester.tap(find.byKey(const Key('centang_langkah_l3')));
        await tester.pump();
        expect(tester.widget<TombolFunda>(tombolSelesai).padaTekan, isNotNull);

        // Tap Selesai
        await tester.ensureVisible(tombolSelesai);
        await tester.pump();
        await tester.tap(tombolSelesai);
        await tester.pump();

        expect(
          find.text('Luar biasa! Misi berhasil diselesaikan.'),
          findsOneWidget,
        );

        // Tombol Lanjut sekarang menjadi aktif
        final btnLanjut = find.byKey(const Key('tombol_lanjut'));
        expect(tester.widget<TombolFunda>(btnLanjut).padaTekan, isNotNull);

        await bongkarWidget(tester);
      },
    );

    testWidgets(
      '3. Umpan Balik ringkasan_proteksi_dasar (10.3): Menampilkan beban wajib dan dana darurat',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        // Siapkan dompet, kategori kebutuhan, transaksi keluar, dan tujuan dana_darurat
        final sekarang = DateTime.now();
        await db
            .into(db.tabelDompet)
            .insert(
              TabelDompetCompanion.insert(
                id: 'dompet_utama',
                nama: 'Dompet Utama',
                jenis: 'tunai',
                ikon: 'wallet',
                warna: 'tintHijau',
              ),
            );

        await db
            .into(db.tabelKategori)
            .insert(
              TabelKategoriCompanion.insert(
                id: 'kat_kebutuhan',
                nama: 'Belanja Pokok',
                arus: 'keluar',
                sifat: 'kebutuhan',
                ikon: 'groceries',
              ),
            );

        await db
            .into(db.tabelTransaksi)
            .insert(
              TabelTransaksiCompanion.insert(
                id: 'tx_keb_1',
                dompetId: 'dompet_utama',
                kategoriId: const Value('kat_kebutuhan'),
                jumlahRupiah: 1500000,
                jenis: 'keluar',
                waktuTransaksi: sekarang,
              ),
            );

        await db
            .into(db.tabelTujuan)
            .insert(
              TabelTujuanCompanion.insert(
                id: 'tujuan_dd',
                nama: 'Dana Darurat Siaga',
                targetRupiah: 6000000,
                jenis: 'dana_darurat',
                status: 'aktif',
                ikon: 'tameng',
                warna: 'merah',
                dibuatPada: sekarang,
              ),
            );

        await db
            .into(db.tabelKantong)
            .insert(
              TabelKantongCompanion.insert(
                id: 'kantong_dd',
                dompetId: 'dompet_utama',
                tujuanId: const Value('tujuan_dd'),
                nama: 'Kantong DD',
                ikon: 'tameng',
                warna: 'merah',
                dibuatPada: sekarang,
              ),
            );

        await db
            .into(db.tabelAlokasiKantong)
            .insert(
              TabelAlokasiKantongCompanion.insert(
                id: 'alokasi_1',
                kantongId: 'kantong_dd',
                jumlahRupiah: 2500000,
                jenis: 'isi',
                waktu: sekarang,
                dibuatPada: sekarang,
              ),
            );

        final pel = muatPelajaranLocal('proteksi_dasar', 'proteksi_dasar_10_3');

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
                  modulId: 'proteksi_dasar',
                  pelajaranId: 'proteksi_dasar_10_3',
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

        // Jawab 3 soal Cek Paham 10.3
        final opsi1 = find.textContaining(
          'Berisiko berhenti membayar di tengah jalan sehingga perlindungan tidak aktif',
        );
        await tester.ensureVisible(opsi1);
        await tester.pump();
        await tester.tap(opsi1);
        await tester.pump();

        final opsi2 = find.textContaining(
          'Saat ada perubahan fase hidup, seperti mulai bekerja atau punya tanggungan',
        );
        await tester.ensureVisible(opsi2);
        await tester.pump();
        await tester.tap(opsi2);
        await tester.pump();

        final opsi3 = find.textContaining(
          'Lebih jelas melihat berapa biaya perlindungan dan berapa yang ditabung',
        );
        await tester.ensureVisible(opsi3);
        await tester.pump();
        await tester.tap(opsi3);
        await tester.pump();

        // Tap Lanjut ke Misi Lihat Hitungan
        final btnLanjutKeMisi = find.byKey(const Key('tombol_lanjut'));
        await tester.tap(btnLanjutKeMisi);
        await tester.pump();

        // Pastikan berada di layar Misi Lihat Hitungan
        await pompaHinggaAda(
          tester,
          find.text('Lihat gambaran beban wajib dan dana daruratmu'),
        );
        expect(
          find.text('Lihat gambaran beban wajib dan dana daruratmu'),
          findsOneWidget,
        );

        // Tap Lanjut ke Kartu Umpan Balik Nyata
        final btnLanjutKeUmpanBalik = find.byKey(const Key('tombol_lanjut'));
        await tester.tap(btnLanjutKeUmpanBalik);
        await tester.pump();

        // Umpan balik nyata muncul
        await pompaHinggaAda(tester, find.text('Umpan Balik Nyata'));
        expect(find.text('Umpan Balik Nyata'), findsOneWidget);
        expect(
          find.textContaining(
            'Pengeluaran wajibmu sekitar Rp1.500.000 per bulan (bulan ini).',
          ),
          findsOneWidget,
        );
        expect(
          find.textContaining(
            'Dana darurat yang terkumpul saat ini: Rp2.500.000.',
          ),
          findsOneWidget,
        );
        expect(
          find.textContaining('Ini gambaran umum, bukan rekomendasi produk.'),
          findsOneWidget,
        );

        await bongkarWidget(tester);
      },
    );

    testWidgets('4. Kuis Modul 7 & Modul 10: Tampilan kuis berjalan lancar', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final modul7 = muatModulLocal('paylater_kredit');
      final modul10 = muatModulLocal('proteksi_dasar');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            penyediaBasisData.overrideWithValue(db),
            penyediaDaftarSemuaModul.overrideWith(
              (ref) => Future.value([modul7, modul10]),
            ),
          ],
          child: MaterialApp(
            theme: TemaFunda.temaTerang,
            home: const LayarKuisModul(modulId: 'paylater_kredit'),
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
            penyediaDaftarSemuaModul.overrideWith(
              (ref) => Future.value([modul7, modul10]),
            ),
          ],
          child: MaterialApp(
            theme: TemaFunda.temaTerang,
            home: const LayarKuisModul(modulId: 'proteksi_dasar'),
          ),
        ),
      );
      await tester.pump();

      expect(find.textContaining('Kuis'), findsWidgets);
      await bongkarWidget(tester);
    });

    testWidgets(
      '5. Aksesibilitas Skala Teks 2.0 pada 360x640: Bebas RenderFlex Overflow',
      (tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final pel7 = muatPelajaranLocal(
          'paylater_kredit',
          'paylater_kredit_7_1',
        );

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
                textScaler: TextScaler.linear(2.0),
                disableAnimations: true,
              ),
              child: MaterialApp(
                theme: TemaFunda.temaTerang,
                home: LayarPemutarPelajaran(
                  modulId: 'paylater_kredit',
                  pelajaranId: 'paylater_kredit_7_1',
                  pelajaranOverride: pel7,
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
        await bongkarWidget(tester);
      },
    );
  });
}
