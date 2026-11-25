@Timeout(Duration(seconds: 30))
library;

import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/aplikasi/aplikasi.dart';
import 'package:funda/aplikasi/konfigurasi_debug.dart';
import 'package:funda/aplikasi/rute.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/penyedia_data.dart';
import 'package:funda/fitur/anggaran/kontroler/penyedia_anggaran.dart';
import 'package:funda/fitur/belajar/kontroler/penyedia_belajar.dart';
import 'package:funda/fitur/belajar/tampilan/layar_pemutar_pelajaran.dart';
import 'package:funda/fitur/beranda/tampilan/layar_beranda.dart';
import 'package:funda/fitur/lainnya/tampilan/layar_lainnya.dart';
import 'package:funda/fitur/pengaturan/tampilan/layar_pengaturan.dart';
import 'package:funda/fitur/tujuan/kontroler/penyedia_tujuan.dart';
import 'package:funda/komponen/komponen_funda.dart';
import 'package:funda/perhitungan/perhitungan_belajar.dart';
import 'package:funda/perhitungan/perhitungan_keuangan.dart';
import 'package:funda/tema/tema.dart';
import 'package:go_router/go_router.dart';

import '../pembantu/pompa_uji.dart';

void main() {
  group('Penonaktifan Fitur Debug UI secara Default', () {
    test('aktifkanFiturDebugUi bernilai false secara default', () {
      expect(kDebugMode, isTrue);
      expect(aktifkanFiturDebugUi, isFalse);
    });

    test('rute /galeri tidak terdaftar saat aktifkanFiturDebugUi false', () {
      final ruteCocok = ruteFunda.configuration.routes.any(
        (rute) => rute is GoRoute && rute.path == '/galeri',
      );
      expect(ruteCocok, isFalse);
    });

    testWidgets(
      'banner galeri debug tidak tampil pada LayarBeranda secara default',
      (tester) async {
        final db = BasisDataFunda(NativeDatabase.memory());
        await db.simpanPengaturan('tutorial_beranda_selesai', 'true');
        addTearDown(() async => db.close());

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              penyediaBasisData.overrideWithValue(db),
              penyediaTanpaAnimasi.overrideWithValue(true),
              penyediaTotalSaldoAktif.overrideWithValue(0),
              penyediaArusKasBulanIni.overrideWithValue(
                const HasilArusKas(totalMasuk: 0, totalKeluar: 0, selisih: 0),
              ),
              penyediaDaftarDompetAktif.overrideWith(
                (ref) => Stream.value(const []),
              ),
              penyediaSisaAnggaranBulanIni.overrideWith(
                (ref) => Future.value(0),
              ),
              penyediaTujuanTerdekat.overrideWithValue(null),
            ],
            child: const AplikasiFunda(),
          ),
        );
        await tester.pump();

        expect(find.byType(LayarBeranda), findsOneWidget);
        expect(
          find.textContaining('Mode Pengembang: Buka Galeri Komponen & Token'),
          findsNothing,
        );

        await bongkarWidget(tester);
      },
    );

    testWidgets(
      'kartu galeri tidak tampil pada LayarLainnya dan tombol uji tidak tampil di Pengaturan',
      (tester) async {
        final db = BasisDataFunda(NativeDatabase.memory());
        await db.simpanPengaturan('tutorial_beranda_selesai', 'true');
        addTearDown(() async => db.close());

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              penyediaBasisData.overrideWithValue(db),
              penyediaTanpaAnimasi.overrideWithValue(true),
              penyediaTotalSaldoAktif.overrideWithValue(0),
              penyediaArusKasBulanIni.overrideWithValue(
                const HasilArusKas(totalMasuk: 0, totalKeluar: 0, selisih: 0),
              ),
              penyediaDaftarDompetAktif.overrideWith(
                (ref) => Stream.value(const []),
              ),
              penyediaSisaAnggaranBulanIni.overrideWith(
                (ref) => Future.value(0),
              ),
              penyediaTujuanTerdekat.overrideWithValue(null),
            ],
            child: const AplikasiFunda(),
          ),
        );
        await tester.pump();

        // Pindah ke tab Lainnya
        await tester.tap(find.text('Lainnya'));
        await pompaHinggaAda(tester, find.byType(LayarLainnya));

        expect(find.byType(LayarLainnya), findsOneWidget);
        expect(find.text('Galeri Komponen UI'), findsNothing);

        await bongkarWidget(tester);

        // Periksa LayarPengaturan tidak menampilkan tombol Jadwalkan Pengingat Uji
        await tester.pumpWidget(
          ProviderScope(
            key: UniqueKey(),
            overrides: [
              penyediaBasisData.overrideWithValue(db),
              penyediaTanpaAnimasi.overrideWithValue(true),
            ],
            child: MaterialApp(
              theme: TemaFunda.temaTerang,
              home: const LayarPengaturan(),
            ),
          ),
        );
        await tester.pump();
        expect(
          find.text('Jadwalkan Pengingat Uji (2 Menit Lagi)'),
          findsNothing,
        );

        await bongkarWidget(tester);
      },
    );

    testWidgets('lencana Draf tidak muncul di LayarPemutarPelajaran', (
      tester,
    ) async {
      final BasisDataFunda db = BasisDataFunda(NativeDatabase.memory());
      addTearDown(() async => db.close());

      const pelDraf = PelajaranKonten(
        id: 'pel_draf_cek',
        modulId: 'anggaran_arus_kas',
        judul: 'Pelajaran Tanpa Label Draf',
        durasiMenit: 3,
        status: 'draf',
        gerbang: [],
        pemantik: 'Teks pemantik sederhana.',
        kartu: [KartuPelajaranKonten(judul: 'Konsep', isi: 'Isi materi.')],
        contohAngka: ContohAngkaKonten.kosong,
        cekPaham: [],
        misi: MisiKonten(
          tipe: 'ada_data',
          objek: 'transaksi',
          min: 1,
          judul: 'Misi',
          deskripsi: 'Deskripsi',
          perkiraanMenit: 2,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            penyediaBasisData.overrideWithValue(db),
            penyediaTanpaAnimasi.overrideWithValue(true),
            penyediaFotoData.overrideWith(
              (ref) => Future.value(FotoDataPengguna.kosong()),
            ),
            penyediaKamus.overrideWith((ref) => Future.value(const {})),
          ],
          child: MaterialApp(
            theme: TemaFunda.temaTerang,
            home: const LayarPemutarPelajaran(
              modulId: 'anggaran_arus_kas',
              pelajaranId: 'pel_draf_cek',
              pelajaranOverride: pelDraf,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Pelajaran Tanpa Label Draf'), findsOneWidget);
      expect(find.text('Draf'), findsNothing);

      await bongkarWidget(tester);
    });
  });
}
