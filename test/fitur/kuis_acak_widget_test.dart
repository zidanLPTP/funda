@Timeout(Duration(seconds: 30))
library;

import '../pembantu/pompa_uji.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/penyedia_data.dart';
import 'package:funda/fitur/belajar/kontroler/penyedia_belajar.dart';
import 'package:funda/fitur/belajar/tampilan/layar_kuis_modul.dart';
import 'package:funda/komponen/komponen_funda.dart';
import 'package:funda/perhitungan/perhitungan_belajar.dart';
import 'package:funda/tema/tema.dart';

void main() {
  late BasisDataFunda db;

  setUp(() {
    db = BasisDataFunda(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  final modulUji = ModulKonten(
    id: 'modul_uji_pengacakan',
    judul: 'Uji Pengacakan',
    tingkat: 'pemula',
    urutan: 1,
    deskripsiSingkat: 'Deskripsi',
    tersedia: true,
    gerbang: const [],
    daftarPelajaran: const [],
    kuis: const KuisKonten(
      jumlahSoal: 3,
      bankSoal: [
        SoalKuis(
          id: 'soal_1',
          pelajaranId: 'pel_1',
          tanya: 'Pertanyaan Soal Pertama',
          pilihan: ['Jawaban Benar 1', 'Pilihan Salah 1A', 'Pilihan Salah 1B'],
          benar: 0,
          penjelasan: 'Penjelasan 1',
        ),
        SoalKuis(
          id: 'soal_2',
          pelajaranId: 'pel_1',
          tanya: 'Pertanyaan Soal Kedua',
          pilihan: ['Pilihan Salah 2A', 'Jawaban Benar 2', 'Pilihan Salah 2B'],
          benar: 1,
          penjelasan: 'Penjelasan 2',
        ),
        SoalKuis(
          id: 'soal_3',
          pelajaranId: 'pel_1',
          tanya: 'Pertanyaan Soal Ketiga',
          pilihan: ['Pilihan Salah 3A', 'Pilihan Salah 3B', 'Jawaban Benar 3'],
          benar: 2,
          penjelasan: 'Penjelasan 3',
        ),
        SoalKuis(
          id: 'soal_4',
          pelajaranId: 'pel_1',
          tanya: 'Pertanyaan Soal Keempat',
          pilihan: ['Pilihan Salah 4A', 'Jawaban Benar 4', 'Pilihan Salah 4B'],
          benar: 1,
          penjelasan: 'Penjelasan 4',
        ),
        SoalKuis(
          id: 'soal_5',
          pelajaranId: 'pel_1',
          tanya: 'Pertanyaan Soal Kelima',
          pilihan: ['Jawaban Benar 5', 'Pilihan Salah 5A', 'Pilihan Salah 5B'],
          benar: 0,
          penjelasan: 'Penjelasan 5',
        ),
      ],
    ),
  );

  testWidgets(
      'Kuis diacak secara default dengan benih berbeda: urutan beda namun jawaban benar tetap terverifikasi',
      (tester) async {
    // 1. Instance pertama dengan benih 42
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          penyediaBasisData.overrideWithValue(db),
          penyediaDaftarSemuaModul.overrideWith(
            (ref) => Future.value([modulUji]),
          ),
        ],
        child: MaterialApp(
          theme: TemaFunda.temaTerang,
          home: const LayarKuisModul(
            modulId: 'modul_uji_pengacakan',
            benih: 42,
          ),
        ),
      ),
    );
    await pompaAman(tester);

    // Catat urutan soal pada benih 1
    final daftarSoalBenih1 = <String>[];

    // Jawab semua soal dengan memilih teks jawaban yang benar untuk setiap soal
    for (var i = 0; i < 3; i++) {
      final teksSoal =
          tester.widget<TeksFunda>(find.byKey(const Key('teks_soal_kuis'))).teks;
      daftarSoalBenih1.add(teksSoal);

      // Cari pilihan yang benar di layar sesuai nomor soal
      Finder? finderJawabanBenar;
      for (var k = 1; k <= 5; k++) {
        final f = find.text('Jawaban Benar $k');
        if (f.evaluate().isNotEmpty) {
          finderJawabanBenar = f;
          break;
        }
      }

      expect(finderJawabanBenar, isNotNull);
      await tester.tap(finderJawabanBenar!);
      await pompaAman(tester);

      if (i < 2) {
        await tester.tap(find.text('Soal Berikutnya'));
        await pompaAman(tester);
      } else {
        await tester.tap(find.text('Lihat Hasil Kuis'));
        await pompaAman(tester);
      }
    }

    // Pastikan hasil kelulusan 100% lulus
    expect(find.text('100%'), findsOneWidget);
    expect(find.text('Selamat, Kamu Lulus!'), findsOneWidget);

    // Bersihkan widget sebelum test kedua
    await tester.pumpWidget(const SizedBox());
    await pompaAman(tester);

    // 2. Instance kedua dengan benih 2
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          penyediaBasisData.overrideWithValue(db),
          penyediaDaftarSemuaModul.overrideWith(
            (ref) => Future.value([modulUji]),
          ),
        ],
        child: MaterialApp(
          theme: TemaFunda.temaTerang,
          home: const LayarKuisModul(
            modulId: 'modul_uji_pengacakan',
            benih: 2,
          ),
        ),
      ),
    );
    await pompaAman(tester);

    final daftarSoalBenih2 = <String>[];

    // Jawab semua soal dengan jawaban benar
    for (var i = 0; i < 3; i++) {
      final teksSoal =
          tester.widget<TeksFunda>(find.byKey(const Key('teks_soal_kuis'))).teks;
      daftarSoalBenih2.add(teksSoal);

      Finder? finderJawabanBenar;
      for (var k = 1; k <= 5; k++) {
        final f = find.text('Jawaban Benar $k');
        if (f.evaluate().isNotEmpty) {
          finderJawabanBenar = f;
          break;
        }
      }

      expect(finderJawabanBenar, isNotNull);
      await tester.tap(finderJawabanBenar!);
      await pompaAman(tester);

      if (i < 2) {
        await tester.tap(find.text('Soal Berikutnya'));
        await pompaAman(tester);
      } else {
        await tester.tap(find.text('Lihat Hasil Kuis'));
        await pompaAman(tester);
      }
    }

    // Pastikan urutan soal berbeda antara benih 1 dan benih 2
    expect(
      daftarSoalBenih1,
      isNot(equals(daftarSoalBenih2)),
      reason: 'Urutan soal terpilih/diacak harus berbeda antar benih',
    );

    // Tetap lulus 100% meskipun urutan berbeda
    expect(find.text('100%'), findsOneWidget);
    expect(find.text('Selamat, Kamu Lulus!'), findsOneWidget);

    // Tetap lulus 100% meskipun urutan berbeda
    expect(find.text('100%'), findsOneWidget);
    expect(find.text('Selamat, Kamu Lulus!'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await pompaAman(tester);
  });
}
