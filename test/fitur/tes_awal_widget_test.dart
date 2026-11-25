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
import 'package:funda/fitur/belajar/model/pembaca_konten.dart';
import 'package:funda/fitur/belajar/tampilan/layar_tes_awal.dart';
import 'package:funda/tema/tema.dart';

void main() {
  late BasisDataFunda db;

  setUp(() {
    db = BasisDataFunda(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  final kontenTesUji = KontenTesAwal(
    versi: 1,
    judul: 'Tes Awal & Profil Keuangan',
    deskripsi: 'Bantu Funda memahami situasi dan pemahamanmu.',
    tujuanUtama: const TujuanUtamaKonten(
      tanya: 'Apa sasaran keuanganmu?',
      petunjuk: 'Tuliskan sasaranmu...',
      maksimalKarakter: 100,
    ),
    pertanyaanProfil: const [
      PertanyaanProfilKonten(
        kunci: 'punya_penghasilan',
        tanya: 'Bagaimana kondisi penghasilanmu?',
        pilihan: [
          PilihanProfilKonten(
            nilai: 'rutin',
            teks: 'Punya penghasilan rutin bulanan',
          ),
          PilihanProfilKonten(
            nilai: 'tidak_rutin',
            teks: 'Penghasilan tidak menentu',
          ),
          PilihanProfilKonten(nilai: 'belum', teks: 'Belum berpenghasilan'),
        ],
      ),
      PertanyaanProfilKonten(
        kunci: 'punya_utang',
        tanya: 'Apakah punya utang?',
        pilihan: [
          PilihanProfilKonten(nilai: 'ya', teks: 'Ya, ada utang'),
          PilihanProfilKonten(nilai: 'tidak', teks: 'Tidak punya utang'),
          PilihanProfilKonten(nilai: 'tidak_yakin', teks: 'Tidak yakin'),
        ],
      ),
      PertanyaanProfilKonten(
        kunci: 'dana_darurat',
        tanya: 'Punya dana darurat?',
        pilihan: [
          PilihanProfilKonten(nilai: 'belum', teks: 'Belum punya'),
          PilihanProfilKonten(nilai: 'sedikit', teks: 'Ada sedikit'),
          PilihanProfilKonten(nilai: 'sudah', teks: 'Sudah cukup'),
        ],
      ),
      PertanyaanProfilKonten(
        kunci: 'menabung',
        tanya: 'Sering menabung?',
        pilihan: [
          PilihanProfilKonten(nilai: 'belum', teks: 'Belum'),
          PilihanProfilKonten(nilai: 'kadang', teks: 'Kadang'),
          PilihanProfilKonten(nilai: 'rutin', teks: 'Rutin'),
        ],
      ),
      PertanyaanProfilKonten(
        kunci: 'investasi',
        tanya: 'Pengalaman investasi?',
        pilihan: [
          PilihanProfilKonten(nilai: 'belum', teks: 'Belum pernah'),
          PilihanProfilKonten(nilai: 'pernah', teks: 'Pernah'),
          PilihanProfilKonten(nilai: 'aktif', teks: 'Aktif'),
        ],
      ),
      PertanyaanProfilKonten(
        kunci: 'mencatat_keuangan',
        tanya: 'Terbiasa mencatat?',
        pilihan: [
          PilihanProfilKonten(nilai: 'belum', teks: 'Belum'),
          PilihanProfilKonten(nilai: 'kadang', teks: 'Kadang'),
          PilihanProfilKonten(nilai: 'rutin', teks: 'Rutin'),
        ],
      ),
    ],
    soalTesAwal: const [
      SoalTesAwalKonten(
        id: 's1',
        modulId: 'anggaran_arus_kas',
        tanya: 'Soal 1 Arus Kas',
        pilihan: ['A', 'B', 'C', 'Belum tahu, nggak apa-apa'],
        benar: 1,
        penjelasan: 'P1',
      ),
      SoalTesAwalKonten(
        id: 's2',
        modulId: 'anggaran_arus_kas',
        tanya: 'Soal 2 Arus Kas',
        pilihan: ['A', 'B', 'C', 'Belum tahu, nggak apa-apa'],
        benar: 0,
        penjelasan: 'P2',
      ),
      SoalTesAwalKonten(
        id: 's3',
        modulId: 'tabungan',
        tanya: 'Soal 1 Tabungan',
        pilihan: ['A', 'B', 'C', 'Belum tahu, nggak apa-apa'],
        benar: 0,
        penjelasan: 'P3',
      ),
      SoalTesAwalKonten(
        id: 's4',
        modulId: 'tabungan',
        tanya: 'Soal 2 Tabungan',
        pilihan: ['A', 'B', 'C', 'Belum tahu, nggak apa-apa'],
        benar: 1,
        penjelasan: 'P4',
      ),
      SoalTesAwalKonten(
        id: 's5',
        modulId: 'dana_darurat',
        tanya: 'Soal 1 Dana Darurat',
        pilihan: ['A', 'B', 'C', 'Belum tahu, nggak apa-apa'],
        benar: 0,
        penjelasan: 'P5',
      ),
      SoalTesAwalKonten(
        id: 's6',
        modulId: 'dana_darurat',
        tanya: 'Soal 2 Dana Darurat',
        pilihan: ['A', 'B', 'C', 'Belum tahu, nggak apa-apa'],
        benar: 1,
        penjelasan: 'P6',
      ),
      SoalTesAwalKonten(
        id: 's7',
        modulId: 'utang_cicilan',
        tanya: 'Soal 1 Utang',
        pilihan: ['A', 'B', 'C', 'Belum tahu, nggak apa-apa'],
        benar: 0,
        penjelasan: 'P7',
      ),
      SoalTesAwalKonten(
        id: 's8',
        modulId: 'utang_cicilan',
        tanya: 'Soal 2 Utang',
        pilihan: ['A', 'B', 'C', 'Belum tahu, nggak apa-apa'],
        benar: 1,
        penjelasan: 'P8',
      ),
      SoalTesAwalKonten(
        id: 's9',
        modulId: 'waspada_penipuan',
        tanya: 'Soal 1 Penipuan',
        pilihan: ['A', 'B', 'C', 'Belum tahu, nggak apa-apa'],
        benar: 0,
        penjelasan: 'P9',
      ),
      SoalTesAwalKonten(
        id: 's10',
        modulId: 'waspada_penipuan',
        tanya: 'Soal 2 Penipuan',
        pilihan: ['A', 'B', 'C', 'Belum tahu, nggak apa-apa'],
        benar: 1,
        penjelasan: 'P10',
      ),
      SoalTesAwalKonten(
        id: 's11',
        modulId: 'psikologi_uang',
        tanya: 'Soal 1 Psikologi',
        pilihan: ['A', 'B', 'C', 'Belum tahu, nggak apa-apa'],
        benar: 0,
        penjelasan: 'P11',
      ),
      SoalTesAwalKonten(
        id: 's12',
        modulId: 'psikologi_uang',
        tanya: 'Soal 2 Psikologi',
        pilihan: ['A', 'B', 'C', 'Belum tahu, nggak apa-apa'],
        benar: 1,
        penjelasan: 'P12',
      ),
    ],
  );

  testWidgets(
    'Pengguna dapat melewati tes awal dan profil_dilewati tersimpan',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            penyediaBasisData.overrideWithValue(db),
            penyediaKontenTesAwal.overrideWith(
              (ref) => Future.value(kontenTesUji),
            ),
          ],
          child: MaterialApp(
            theme: TemaFunda.temaTerang,
            home: const LayarTesAwal(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Mulai & Tes Awal'), findsOneWidget);
      expect(find.text('Lewati'), findsOneWidget);

      await tester.tap(find.text('Lewati'));
      await tester.pump();

      // Verifikasi pernyataan profil_dilewati tersimpan di DB
      final pernyataan = await (db.select(
        db.tabelPernyataan,
      )..where((t) => t.kunci.equals('profil_dilewati'))).getSingleOrNull();
      expect(pernyataan, isNotNull);
      expect(pernyataan!.nilai, equals('true'));

      await bongkarWidget(tester);
    },
  );

  testWidgets(
    'Pengguna mengisi tes awal lengkap dan melihat rekomendasi personalisasi',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            penyediaBasisData.overrideWithValue(db),
            penyediaKontenTesAwal.overrideWith(
              (ref) => Future.value(kontenTesUji),
            ),
          ],
          child: MaterialApp(
            theme: TemaFunda.temaTerang,
            home: const LayarTesAwal(),
          ),
        ),
      );
      await tester.pump();

      // Isi tujuan utama di tahap pembuka
      await tester.enterText(
        find.byType(TextField),
        'Bebas utang dan punya tabungan',
      );
      await tester.pump();

      // Ketuk Mulai Sekarang -> masuk ke Tahap Profil
      await tester.tap(find.text('Mulai Sekarang'));
      await tester.pump();

      // Jawab 6 pertanyaan profil
      for (var i = 0; i < 6; i++) {
        expect(find.textContaining('Profil (${i + 1}/6)'), findsOneWidget);

        // Pilih opsi pertama
        final pilihanPertama = find.byType(InkWell).first;
        await tester.tap(pilihanPertama);
        await tester.pump();

        if (i < 5) {
          await tester.tap(find.text('Pertanyaan Berikutnya'));
          await tester.pump();
        } else {
          await tester.tap(find.text('Lanjut ke Tes Pemahaman'));
          await tester.pump();
        }
      }

      // Layar transisi profil -> tes pemahaman
      expect(find.text('Profil Keuanganmu Tersimpan!'), findsOneWidget);
      await tester.tap(find.byKey(const Key('tombol_mulai_soal_tes_awal')));
      await tester.pump();

      // Jawab 12 pertanyaan soal tes awal
      for (var i = 0; i < 12; i++) {
        expect(find.textContaining('Tes Awal (${i + 1}/12)'), findsOneWidget);

        // Pilih opsi kedua ('B') untuk semua soal
        final opsiJawaban = find.text('B');
        await tester.tap(opsiJawaban);
        await tester.pump();

        if (i < 11) {
          await tester.tap(find.text('Soal Berikutnya'));
          await tester.pump();
        } else {
          await tester.tap(find.text('Lihat Hasil'));
          await tester.pump();
        }
      }

      // Layar animasi selesai tes awal
      expect(find.text('Tes Awal Selesai!'), findsOneWidget);
      await tester.tap(
        find.byKey(const Key('tombol_lihat_rekomendasi_tes_awal')),
      );
      await tester.pump();

      // Tahap Hasil
      expect(find.text('Hasil Tes Awal'), findsOneWidget);
      expect(find.text('Profil Berhasil Dibentuk'), findsOneWidget);
      expect(find.textContaining('Skor pemahaman awalmu:'), findsOneWidget);

      // Verifikasi data tersimpan di basis data SQLite
      final profilTersimpan = await db
          .select(db.tabelProfilKeuangan)
          .getSingleOrNull();
      expect(profilTersimpan, isNotNull);
      expect(
        profilTersimpan!.tujuanUtama,
        equals('Bebas utang dan punya tabungan'),
      );

      final hasilTersimpan = await db
          .select(db.tabelHasilTesAwal)
          .getSingleOrNull();
      expect(hasilTersimpan, isNotNull);
      expect(hasilTersimpan!.skorTotalPersen, inInclusiveRange(0, 100));

      await bongkarWidget(tester);
    },
  );
}
