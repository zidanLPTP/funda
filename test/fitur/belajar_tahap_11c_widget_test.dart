@Timeout(Duration(seconds: 30))
library;

import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/penyedia_data.dart';
import 'package:funda/fitur/belajar/kontroler/penyedia_belajar.dart';
import 'package:funda/fitur/belajar/model/pembaca_konten.dart';
import 'package:funda/fitur/belajar/tampilan/layar_belajar.dart';
import 'package:funda/fitur/belajar/tampilan/layar_kuis_modul.dart';
import 'package:funda/fitur/belajar/tampilan/layar_pemutar_pelajaran.dart';
import 'package:funda/perhitungan/perhitungan_belajar.dart';
import 'package:funda/tema/tema_funda.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../pembantu/pompa_uji.dart';

void main() {
  group(
    'Pengujian Widget Belajar Tahap 11C (Modul 17 Keuangan Usaha Kecil & Modul 18 Proteksi Keluarga & Warisan Dasar)',
    () {
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
        final f = File('aset/konten/lanjutan/$modulId/$pelajaranId.json');
        final jsonMap =
            jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
        return PelajaranKonten.fromJson(jsonMap);
      }

      ModulKonten muatModulLocal(String modulId) {
        final f = File('aset/konten/lanjutan/$modulId/modul.json');
        final data = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
        return ModulKonten.fromJson(data);
      }

      testWidgets(
        '1. Tombol "Aku tidak punya ini" pada Modul 17, simpan & cabut pernyataan belum_punya_usaha',
        (tester) async {
          tester.view.physicalSize = const Size(1080, 2400);
          tester.view.devicePixelRatio = 2.0;
          addTearDown(() => tester.view.resetPhysicalSize());

          final modul17 = muatModulLocal('keuangan_usaha_kecil');
          final pel171 = muatPelajaranLocal(
            'keuangan_usaha_kecil',
            'keuangan_usaha_kecil_17_1',
          );

          final fotoDataTerkunci = FotoDataPengguna.kosong().copyWith(
            jumlahSumberPemasukan: 1,
            pernyataan: {},
          );

          final statusModul = tentukanStatusModul(
            modul: modul17,
            fotoData: fotoDataTerkunci,
          );
          final statusPel = tentukanStatusPelajaran(
            pelajaran: pel171,
            posisiIndeks: 0,
            daftarPelajaranModul: [pel171],
            gerbangModul: modul17.gerbang,
            fotoData: fotoDataTerkunci,
          );

          final itemModul17 = ItemPetaModul(
            modul: modul17,
            statusModul: statusModul,
            daftarPelajaran: [(pel171, statusPel)],
          );

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                penyediaBasisData.overrideWithValue(db),
                penyediaFotoData.overrideWith(
                  (ref) => Future.value(fotoDataTerkunci),
                ),
                penyediaKamus.overrideWith(
                  (ref) => Future.value(<String, IstilahKamus>{}),
                ),
                penyediaPetaBelajar.overrideWith(
                  (ref) => Future.value([itemModul17]),
                ),
              ],
              child: MaterialApp(
                theme: TemaFunda.temaTerang,
                home: const Scaffold(body: LayarBelajar()),
              ),
            ),
          );
          await tester.pump();

          await pompaHinggaAda(tester, find.text('Keuangan Usaha Kecil'));
          expect(find.text('Keuangan Usaha Kecil'), findsOneWidget);

          // Cari tombol "Aku tidak punya ini"
          final tombolPernyataan = find.text('Aku tidak punya ini');
          expect(tombolPernyataan, findsOneWidget);

          // Tap tombol pernyataan
          await tester.tap(tombolPernyataan);
          await tester.pump();

          // Verifikasi pernyataan tersimpan di database
          final p =
              await (db.select(db.tabelPernyataan)
                    ..where((tbl) => tbl.kunci.equals('belum_punya_usaha')))
                  .getSingleOrNull();
          expect(p, isNotNull);
          expect(p!.nilai, equals('true'));

          // Banner pernyataan harus muncul
          await pompaHinggaAda(
            tester,
            find.text('Kamu menyatakan belum punya usaha saat ini.'),
          );
          expect(
            find.text('Kamu menyatakan belum punya usaha saat ini.'),
            findsOneWidget,
          );
          expect(find.text('Cabut pernyataan'), findsOneWidget);

          // Tap "Cabut pernyataan"
          await tester.tap(find.text('Cabut pernyataan'));
          await tester.pump();

          // Verifikasi pernyataan terhapus
          final pSetelahCabut =
              await (db.select(db.tabelPernyataan)
                    ..where((tbl) => tbl.kunci.equals('belum_punya_usaha')))
                  .getSingleOrNull();
          expect(pSetelahCabut, isNull);

          await bongkarWidget(tester);
        },
      );

      testWidgets(
        '2. Status Modul 18 pada Peta Belajar: Terkunci vs Terbuka (proteksi_dasar)',
        (tester) async {
          tester.view.physicalSize = const Size(1080, 2400);
          tester.view.devicePixelRatio = 2.0;
          addTearDown(() => tester.view.resetPhysicalSize());

          final modul18 = muatModulLocal('proteksi_keluarga_warisan');
          final pel181 = muatPelajaranLocal(
            'proteksi_keluarga_warisan',
            'proteksi_keluarga_warisan_18_1',
          );

          // Kasus A: Tanpa lulus proteksi_dasar -> Modul 18 Terkunci
          final fotoDataTerkunci = FotoDataPengguna.kosong().copyWith(
            hasilKuisTerbaik: {},
          );
          final statusModulTerkunci = tentukanStatusModul(
            modul: modul18,
            fotoData: fotoDataTerkunci,
          );
          final statusPelTerkunci = tentukanStatusPelajaran(
            pelajaran: pel181,
            posisiIndeks: 0,
            daftarPelajaranModul: [pel181],
            gerbangModul: modul18.gerbang,
            fotoData: fotoDataTerkunci,
          );
          final itemModul18Terkunci = ItemPetaModul(
            modul: modul18,
            statusModul: statusModulTerkunci,
            daftarPelajaran: [(pel181, statusPelTerkunci)],
          );

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                penyediaBasisData.overrideWithValue(db),
                penyediaFotoData.overrideWith(
                  (ref) => Future.value(fotoDataTerkunci),
                ),
                penyediaKamus.overrideWith(
                  (ref) => Future.value(<String, IstilahKamus>{}),
                ),
                penyediaPetaBelajar.overrideWith(
                  (ref) => Future.value([itemModul18Terkunci]),
                ),
              ],
              child: MaterialApp(
                theme: TemaFunda.temaTerang,
                home: const Scaffold(body: LayarBelajar()),
              ),
            ),
          );
          await tester.pump();

          await pompaHinggaAda(
            tester,
            find.text('Proteksi Keluarga & Warisan Dasar'),
          );
          expect(
            find.text('Proteksi Keluarga & Warisan Dasar'),
            findsOneWidget,
          );

          // Verifikasi pesan gerbang muncul
          expect(
            find.textContaining('Selesaikan Modul 10 (Proteksi Dasar) dulu'),
            findsOneWidget,
          );

          await bongkarWidget(tester);

          // Kasus B: Sudah lulus proteksi_dasar -> Modul 18 Terbuka
          final fotoDataTerbuka = FotoDataPengguna.kosong().copyWith(
            hasilKuisTerbaik: {
              'proteksi_dasar': const HasilKuisSnapshot(
                lulus: true,
                skorPersen: 100,
              ),
            },
          );
          final statusModulTerbuka = tentukanStatusModul(
            modul: modul18,
            fotoData: fotoDataTerbuka,
          );
          final statusPelTerbuka = tentukanStatusPelajaran(
            pelajaran: pel181,
            posisiIndeks: 0,
            daftarPelajaranModul: [pel181],
            gerbangModul: modul18.gerbang,
            fotoData: fotoDataTerbuka,
          );
          final itemModul18Terbuka = ItemPetaModul(
            modul: modul18,
            statusModul: statusModulTerbuka,
            daftarPelajaran: [(pel181, statusPelTerbuka)],
          );

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                penyediaBasisData.overrideWithValue(db),
                penyediaFotoData.overrideWith(
                  (ref) => Future.value(fotoDataTerbuka),
                ),
                penyediaKamus.overrideWith(
                  (ref) => Future.value(<String, IstilahKamus>{}),
                ),
                penyediaPetaBelajar.overrideWith(
                  (ref) => Future.value([itemModul18Terbuka]),
                ),
              ],
              child: MaterialApp(
                theme: TemaFunda.temaTerang,
                home: const Scaffold(body: LayarBelajar()),
              ),
            ),
          );
          await tester.pump();

          await pompaHinggaAda(
            tester,
            find.text('Proteksi Keluarga & Warisan Dasar'),
          );
          expect(
            find.text('Proteksi Keluarga & Warisan Dasar'),
            findsOneWidget,
          );
          expect(
            find.textContaining('Selesaikan Modul 10 (Proteksi Dasar) dulu'),
            findsNothing,
          );

          await bongkarWidget(tester);
        },
      );

      testWidgets(
        '3. Misi Pelajaran 17.1 (Keputusan: Menjaga batas kas usaha)',
        (tester) async {
          tester.view.physicalSize = const Size(1080, 2400);
          tester.view.devicePixelRatio = 2.0;
          addTearDown(() => tester.view.resetPhysicalSize());

          final pel = muatPelajaranLocal(
            'keuangan_usaha_kecil',
            'keuangan_usaha_kecil_17_1',
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
              child: MaterialApp(
                theme: TemaFunda.temaTerang,
                home: LayarPemutarPelajaran(
                  modulId: 'keuangan_usaha_kecil',
                  pelajaranId: 'keuangan_usaha_kecil_17_1',
                  pelajaranOverride: pel,
                ),
              ),
            ),
          );
          await tester.pump();

          while (find.text('Uji Pemahaman Singkat').evaluate().isEmpty) {
            final btnLanjut = find.byKey(const Key('tombol_lanjut'));
            expect(btnLanjut, findsOneWidget);
            await tester.tap(btnLanjut);
            await tester.pump();
          }

          // Jawab 3 soal Cek Paham 17.1
          final opsi1 = find.textContaining(
            'Sulit mengetahui untung rugi sebenarnya',
          );
          await tester.ensureVisible(opsi1);
          await tester.tap(opsi1);
          await tester.pump();

          final opsi2 = find.textContaining(
            'Menetapkan jatah gaji pemilik secara teratur',
          );
          await tester.ensureVisible(opsi2);
          await tester.tap(opsi2);
          await tester.pump();

          final opsi3 = find.text('Rp2.200.000');
          await tester.ensureVisible(opsi3);
          await tester.tap(opsi3);
          await tester.pump();

          // Tap Lanjut ke Misi
          final btnLanjutKeMisi = find.byKey(const Key('tombol_lanjut'));
          await tester.tap(btnLanjutKeMisi);
          await tester.pump();

          await pompaHinggaAda(tester, find.text('Menjaga batas kas usaha'));
          expect(find.text('Menjaga batas kas usaha'), findsOneWidget);

          // Coba opsi tidak aman (opsi a)
          final opsiSalah = find.textContaining('Pakai uang kas usaha dulu');
          await tester.ensureVisible(opsiSalah);
          await tester.tap(opsiSalah);
          await tester.pump();
          expect(
            find.textContaining(
              'Mengambil uang modal kerja untuk keinginan pribadi',
            ),
            findsOneWidget,
          );

          // Ketuk coba pilihan lain
          final btnCobaLain = find.byKey(const Key('tombol_coba_pilihan_lain'));
          await tester.ensureVisible(btnCobaLain);
          await tester.tap(btnCobaLain);
          await tester.pump();

          // Pilih opsi aman (opsi b)
          final opsiAman = find.textContaining(
            'Biarkan Rp1.500.000 tetap di dompet usaha',
          );
          await tester.ensureVisible(opsiAman);
          await tester.tap(opsiAman);
          await tester.pump();
          expect(
            find.textContaining(
              'Menjaga batas kas usaha memastikan operasional',
            ),
            findsOneWidget,
          );

          final hasilMisi =
              await (db.select(db.tabelHasilMisi)..where(
                    (tbl) => tbl.misiId.equals('keuangan_usaha_kecil_17_1'),
                  ))
                  .getSingleOrNull();
          expect(hasilMisi, isNotNull);
          expect(hasilMisi!.status, equals('selesai'));

          await bongkarWidget(tester);
        },
      );

      testWidgets(
        '4. Umpan Balik Pelajaran 17.2 (ringkasan_usaha_kecil: Tinjau kesiapan dompet dan arus kasmu)',
        (tester) async {
          tester.view.physicalSize = const Size(1080, 2400);
          tester.view.devicePixelRatio = 2.0;
          addTearDown(() => tester.view.resetPhysicalSize());

          final pel = muatPelajaranLocal(
            'keuangan_usaha_kecil',
            'keuangan_usaha_kecil_17_2',
          );

          // Masukkan 3 dompet aktif dan transaksi
          final now = DateTime.now();
          for (var i = 1; i <= 3; i++) {
            await db
                .into(db.tabelDompet)
                .insert(
                  TabelDompetCompanion.insert(
                    id: 'dompet_$i',
                    nama: 'Dompet $i',
                    jenis: 'tunai',
                    ikon: 'wallet',
                    warna: 'biru',
                    saldoAwalRupiah: const Value(2000000),
                    dibuatPada: Value(now),
                  ),
                );
          }

          await db
              .into(db.tabelKategori)
              .insert(
                TabelKategoriCompanion.insert(
                  id: 'kat_jual',
                  nama: 'Jualan',
                  arus: 'masuk',
                  sifat: 'fleksibel',
                  ikon: 'shopping-bag',
                ),
              );
          await db
              .into(db.tabelKategori)
              .insert(
                TabelKategoriCompanion.insert(
                  id: 'kat_bahan',
                  nama: 'Bahan Baku',
                  arus: 'keluar',
                  sifat: 'kebutuhan',
                  ikon: 'package',
                ),
              );

          await db
              .into(db.tabelTransaksi)
              .insert(
                TabelTransaksiCompanion.insert(
                  id: 'tx_masuk',
                  dompetId: 'dompet_1',
                  kategoriId: const Value('kat_jual'),
                  jenis: 'masuk',
                  jumlahRupiah: 8000000,
                  waktuTransaksi: now,
                  dibuatPada: Value(now),
                ),
              );
          await db
              .into(db.tabelTransaksi)
              .insert(
                TabelTransaksiCompanion.insert(
                  id: 'tx_keluar',
                  dompetId: 'dompet_1',
                  kategoriId: const Value('kat_bahan'),
                  jenis: 'keluar',
                  jumlahRupiah: 5000000,
                  waktuTransaksi: now,
                  dibuatPada: Value(now),
                ),
              );

          await tester.pumpWidget(
            ProviderScope(
              overrides: [penyediaBasisData.overrideWithValue(db)],
              child: MaterialApp(
                theme: TemaFunda.temaTerang,
                home: LayarPemutarPelajaran(
                  modulId: 'keuangan_usaha_kecil',
                  pelajaranId: 'keuangan_usaha_kecil_17_2',
                  pelajaranOverride: pel,
                ),
              ),
            ),
          );
          await tester.pump();

          while (find.text('Uji Pemahaman Singkat').evaluate().isEmpty) {
            final btnLanjut = find.byKey(const Key('tombol_lanjut'));
            expect(btnLanjut, findsOneWidget);
            await tester.tap(btnLanjut);
            await tester.pump();
          }

          // Jawab 3 soal Cek Paham 17.2
          final opsi1 = find.textContaining(
            'Omzet adalah total penjualan kotor',
          );
          await tester.ensureVisible(opsi1);
          await tester.tap(opsi1);
          await tester.pump();

          final opsi2 = find.textContaining(
            'Karena uang dari pelanggan belum cair',
          );
          await tester.ensureVisible(opsi2);
          await tester.tap(opsi2);
          await tester.pump();

          final opsi3 = find.textContaining(
            'Agar perhitungan laba bersih dan penentuan harga jual akurat',
          );
          await tester.ensureVisible(opsi3);
          await tester.tap(opsi3);
          await tester.pump();

          // Tap Lanjut ke Misi
          final btnLanjutKeMisi = find.byKey(const Key('tombol_lanjut'));
          await tester.tap(btnLanjutKeMisi);
          await tester.pump();

          await pompaHinggaAda(
            tester,
            find.text('Tinjau kesiapan dompet dan arus kasmu'),
          );
          expect(
            find.text('Tinjau kesiapan dompet dan arus kasmu'),
            findsOneWidget,
          );

          final btnLanjutKeUmpanBalik = find.byKey(const Key('tombol_lanjut'));
          await tester.tap(btnLanjutKeUmpanBalik);
          await tester.pump();

          // Verifikasi umpan balik ringkasan usaha kecil muncul
          await pompaHinggaAda(
            tester,
            find.textContaining('Kamu sudah punya 3 dompet aktif'),
          );
          expect(
            find.textContaining('Kamu sudah punya 3 dompet aktif'),
            findsOneWidget,
          );

          // Tap Lanjut ke kartu selesai
          final btnLanjutSelesai = find.byKey(const Key('tombol_lanjut'));
          await tester.tap(btnLanjutSelesai);
          await tester.pump();

          final hasilMisi =
              await (db.select(db.tabelHasilMisi)..where(
                    (tbl) => tbl.misiId.equals('keuangan_usaha_kecil_17_2'),
                  ))
                  .getSingleOrNull();
          expect(hasilMisi, isNotNull);
          expect(hasilMisi!.status, equals('selesai'));

          await bongkarWidget(tester);
        },
      );

      testWidgets(
        '5. Misi Pelajaran 17.3 (Refleksi: Aturan emas kas usahamu)',
        (tester) async {
          tester.view.physicalSize = const Size(1080, 2400);
          tester.view.devicePixelRatio = 2.0;
          addTearDown(() => tester.view.resetPhysicalSize());

          final pel = muatPelajaranLocal(
            'keuangan_usaha_kecil',
            'keuangan_usaha_kecil_17_3',
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
              child: MaterialApp(
                theme: TemaFunda.temaTerang,
                home: LayarPemutarPelajaran(
                  modulId: 'keuangan_usaha_kecil',
                  pelajaranId: 'keuangan_usaha_kecil_17_3',
                  pelajaranOverride: pel,
                ),
              ),
            ),
          );
          await tester.pump();

          while (find.text('Uji Pemahaman Singkat').evaluate().isEmpty) {
            final btnLanjut = find.byKey(const Key('tombol_lanjut'));
            expect(btnLanjut, findsOneWidget);
            await tester.tap(btnLanjut);
            await tester.pump();
          }

          // Jawab 3 soal Cek Paham 17.3
          final opsi1 = find.textContaining(
            'Membiayai perputaran operasional harian',
          );
          await tester.ensureVisible(opsi1);
          await tester.tap(opsi1);
          await tester.pump();

          final opsi2 = find.textContaining('Menghadapi masa penjualan sepi');
          await tester.ensureVisible(opsi2);
          await tester.tap(opsi2);
          await tester.pump();

          final opsi3 = find.textContaining(
            'Menyisihkan sebagian laba bersih secara rutin',
          );
          await tester.ensureVisible(opsi3);
          await tester.tap(opsi3);
          await tester.pump();

          // Tap Lanjut ke Misi
          final btnLanjutKeMisi = find.byKey(const Key('tombol_lanjut'));
          await tester.tap(btnLanjutKeMisi);
          await tester.pump();

          await pompaHinggaAda(tester, find.text('Aturan emas kas usahamu'));
          expect(find.text('Aturan emas kas usahamu'), findsOneWidget);

          final field = find.byType(TextField);
          expect(field, findsOneWidget);

          // Input < 10 karakter
          await tester.enterText(field, '12345');
          await tester.pump();

          // Input >= 10 karakter
          await tester.enterText(
            field,
            'Aku akan pakai rekening terpisah untuk kas usaha.',
          );
          await tester.pump();

          final btnSimpan = find.byKey(const Key('tombol_simpan_refleksi'));
          await tester.ensureVisible(btnSimpan);
          await tester.tap(btnSimpan);
          await tester.pump();

          final hasilMisi =
              await (db.select(db.tabelHasilMisi)..where(
                    (tbl) => tbl.misiId.equals('keuangan_usaha_kecil_17_3'),
                  ))
                  .getSingleOrNull();
          expect(hasilMisi, isNotNull);
          expect(hasilMisi!.status, equals('selesai'));

          await bongkarWidget(tester);
        },
      );

      testWidgets(
        '6. Misi Pelajaran 18.1 (Keputusan: Menjaga keterbukaan di saat penting)',
        (tester) async {
          tester.view.physicalSize = const Size(1080, 2400);
          tester.view.devicePixelRatio = 2.0;
          addTearDown(() => tester.view.resetPhysicalSize());

          final pel = muatPelajaranLocal(
            'proteksi_keluarga_warisan',
            'proteksi_keluarga_warisan_18_1',
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
              child: MaterialApp(
                theme: TemaFunda.temaTerang,
                home: LayarPemutarPelajaran(
                  modulId: 'proteksi_keluarga_warisan',
                  pelajaranId: 'proteksi_keluarga_warisan_18_1',
                  pelajaranOverride: pel,
                ),
              ),
            ),
          );
          await tester.pump();

          while (find.text('Uji Pemahaman Singkat').evaluate().isEmpty) {
            final btnLanjut = find.byKey(const Key('tombol_lanjut'));
            expect(btnLanjut, findsOneWidget);
            await tester.tap(btnLanjut);
            await tester.pump();
          }

          // Jawab 3 soal Cek Paham 18.1
          final opsi1 = find.textContaining(
            'Agar keluarga tidak kebingungan mengakses hak',
          );
          await tester.ensureVisible(opsi1);
          await tester.tap(opsi1);
          await tester.pump();

          final opsi2 = find.textContaining(
            'Saat jumlah tanggungan keluarga bertambah',
          );
          await tester.ensureVisible(opsi2);
          await tester.tap(opsi2);
          await tester.pump();

          final opsi3 = find.textContaining(
            'Secara terbuka, tenang, dan berkala',
          );
          await tester.ensureVisible(opsi3);
          await tester.tap(opsi3);
          await tester.pump();

          // Tap Lanjut ke Misi
          final btnLanjutKeMisi = find.byKey(const Key('tombol_lanjut'));
          await tester.tap(btnLanjutKeMisi);
          await tester.pump();

          await pompaHinggaAda(
            tester,
            find.text('Menjaga keterbukaan di saat penting'),
          );
          expect(
            find.text('Menjaga keterbukaan di saat penting'),
            findsOneWidget,
          );

          // Pilih opsi aman (opsi a)
          final opsiAman = find.textContaining(
            'Buat ringkasan daftar rekening',
          );
          await tester.ensureVisible(opsiAman);
          await tester.tap(opsiAman);
          await tester.pump();
          expect(find.textContaining('Tepat'), findsOneWidget);

          final hasilMisi =
              await (db.select(db.tabelHasilMisi)..where(
                    (tbl) =>
                        tbl.misiId.equals('proteksi_keluarga_warisan_18_1'),
                  ))
                  .getSingleOrNull();
          expect(hasilMisi, isNotNull);
          expect(hasilMisi!.status, equals('selesai'));

          await bongkarWidget(tester);
        },
      );

      testWidgets(
        '7. Misi Pelajaran 18.2 (Daftar Periksa: Merapikan Dokumen Penting Keluarga + Disclaimer)',
        (tester) async {
          tester.view.physicalSize = const Size(1080, 2400);
          tester.view.devicePixelRatio = 2.0;
          addTearDown(() => tester.view.resetPhysicalSize());

          final pel = muatPelajaranLocal(
            'proteksi_keluarga_warisan',
            'proteksi_keluarga_warisan_18_2',
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
              child: MaterialApp(
                theme: TemaFunda.temaTerang,
                home: LayarPemutarPelajaran(
                  modulId: 'proteksi_keluarga_warisan',
                  pelajaranId: 'proteksi_keluarga_warisan_18_2',
                  pelajaranOverride: pel,
                ),
              ),
            ),
          );
          await tester.pump();

          while (find.text('Uji Pemahaman Singkat').evaluate().isEmpty) {
            final btnLanjut = find.byKey(const Key('tombol_lanjut'));
            expect(btnLanjut, findsOneWidget);
            await tester.tap(btnLanjut);
            await tester.pump();
          }

          // Jawab 3 soal Cek Paham 18.2
          final opsi1 = find.textContaining('Dalam satu map tahan air');
          await tester.ensureVisible(opsi1);
          await tester.tap(opsi1);
          await tester.pump();

          final opsi2 = find.textContaining(
            'Tidak boleh, demi menjaga keamanan',
          );
          await tester.ensureVisible(opsi2);
          await tester.tap(opsi2);
          await tester.pump();

          final opsi3 = find.textContaining(
            'Pasangan atau satu anggota keluarga yang benar-benar kamu percaya',
          );
          await tester.ensureVisible(opsi3);
          await tester.tap(opsi3);
          await tester.pump();

          // Tap Lanjut ke Misi
          final btnLanjutKeMisi = find.byKey(const Key('tombol_lanjut'));
          await tester.tap(btnLanjutKeMisi);
          await tester.pump();

          await pompaHinggaAda(
            tester,
            find.text('Daftar rapi dokumen pentingmu'),
          );
          expect(find.text('Daftar rapi dokumen pentingmu'), findsOneWidget);

          // Centang 3 langkah via Key
          final k1 = find.byKey(const Key('centang_langkah_l1'));
          await tester.ensureVisible(k1);
          await tester.tap(k1);
          await tester.pump();

          final k2 = find.byKey(const Key('centang_langkah_l2'));
          await tester.ensureVisible(k2);
          await tester.tap(k2);
          await tester.pump();

          final k3 = find.byKey(const Key('centang_langkah_l3'));
          await tester.ensureVisible(k3);
          await tester.tap(k3);
          await tester.pump();

          final btnSelesai = find.byKey(
            const Key('tombol_selesai_daftar_periksa'),
          );
          await tester.ensureVisible(btnSelesai);
          await tester.tap(btnSelesai);
          await tester.pump();

          final hasilMisi =
              await (db.select(db.tabelHasilMisi)..where(
                    (tbl) =>
                        tbl.misiId.equals('proteksi_keluarga_warisan_18_2'),
                  ))
                  .getSingleOrNull();
          expect(hasilMisi, isNotNull);
          expect(hasilMisi!.status, equals('selesai'));

          await bongkarWidget(tester);
        },
      );

      testWidgets(
        '8. Misi Pelajaran 18.3 (Daftar Periksa: Mengenal Gambaran Warisan Dasar + Disclaimer)',
        (tester) async {
          tester.view.physicalSize = const Size(1080, 2400);
          tester.view.devicePixelRatio = 2.0;
          addTearDown(() => tester.view.resetPhysicalSize());

          final pel = muatPelajaranLocal(
            'proteksi_keluarga_warisan',
            'proteksi_keluarga_warisan_18_3',
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
              child: MaterialApp(
                theme: TemaFunda.temaTerang,
                home: LayarPemutarPelajaran(
                  modulId: 'proteksi_keluarga_warisan',
                  pelajaranId: 'proteksi_keluarga_warisan_18_3',
                  pelajaranOverride: pel,
                ),
              ),
            ),
          );
          await tester.pump();

          while (find.text('Uji Pemahaman Singkat').evaluate().isEmpty) {
            final btnLanjut = find.byKey(const Key('tombol_lanjut'));
            expect(btnLanjut, findsOneWidget);
            await tester.tap(btnLanjut);
            await tester.pump();
          }

          // Jawab 3 soal Cek Paham 18.3
          final opsi1 = find.textContaining(
            'Mencegah kebingungan dan sengketa keluarga',
          );
          await tester.ensureVisible(opsi1);
          await tester.tap(opsi1);
          await tester.pump();

          final opsi2 = find.textContaining(
            'Pihak yang berhak menerima warisan',
          );
          await tester.ensureVisible(opsi2);
          await tester.tap(opsi2);
          await tester.pump();

          final opsi3 = find.textContaining(
            'Kepada notaris atau ahli hukum yang berwenang',
          );
          await tester.ensureVisible(opsi3);
          await tester.tap(opsi3);
          await tester.pump();

          // Tap Lanjut ke Misi
          final btnLanjutKeMisi = find.byKey(const Key('tombol_lanjut'));
          await tester.tap(btnLanjutKeMisi);
          await tester.pump();

          await pompaHinggaAda(
            tester,
            find.text('Langkah awal kesiapan keluarga'),
          );
          expect(find.text('Langkah awal kesiapan keluarga'), findsOneWidget);

          // Centang 3 langkah via Key
          final k1 = find.byKey(const Key('centang_langkah_l1'));
          await tester.ensureVisible(k1);
          await tester.tap(k1);
          await tester.pump();

          final k2 = find.byKey(const Key('centang_langkah_l2'));
          await tester.ensureVisible(k2);
          await tester.tap(k2);
          await tester.pump();

          final k3 = find.byKey(const Key('centang_langkah_l3'));
          await tester.ensureVisible(k3);
          await tester.tap(k3);
          await tester.pump();

          final btnSelesai = find.byKey(
            const Key('tombol_selesai_daftar_periksa'),
          );
          await tester.ensureVisible(btnSelesai);
          await tester.tap(btnSelesai);
          await tester.pump();

          final hasilMisi =
              await (db.select(db.tabelHasilMisi)..where(
                    (tbl) =>
                        tbl.misiId.equals('proteksi_keluarga_warisan_18_3'),
                  ))
                  .getSingleOrNull();
          expect(hasilMisi, isNotNull);
          expect(hasilMisi!.status, equals('selesai'));

          await bongkarWidget(tester);
        },
      );

      testWidgets('9. Kuis Modul 17 & 18: Tampilan kuis berjalan lancar', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        // Kuis Modul 17
        await tester.pumpWidget(
          ProviderScope(
            overrides: [penyediaBasisData.overrideWithValue(db)],
            child: MaterialApp(
              theme: TemaFunda.temaTerang,
              home: const LayarKuisModul(modulId: 'keuangan_usaha_kecil'),
            ),
          ),
        );
        await tester.pump();

        expect(find.textContaining('Kuis'), findsWidgets);
        await bongkarWidget(tester);

        // Kuis Modul 18
        await tester.pumpWidget(
          ProviderScope(
            overrides: [penyediaBasisData.overrideWithValue(db)],
            child: MaterialApp(
              theme: TemaFunda.temaTerang,
              home: const LayarKuisModul(modulId: 'proteksi_keluarga_warisan'),
            ),
          ),
        );
        await tester.pump();

        expect(find.textContaining('Kuis'), findsWidgets);
        await bongkarWidget(tester);
      });

      testWidgets(
        '10. Aksesibilitas Skala Teks 2.0 pada 360x640: Bebas RenderFlex Overflow',
        (tester) async {
          tester.view.physicalSize = const Size(360, 640);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() => tester.view.resetPhysicalSize());

          final pel = muatPelajaranLocal(
            'keuangan_usaha_kecil',
            'keuangan_usaha_kecil_17_1',
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
              child: MaterialApp(
                theme: TemaFunda.temaTerang,
                home: MediaQuery(
                  data: const MediaQueryData(
                    textScaler: TextScaler.linear(2.0),
                    size: Size(360, 640),
                  ),
                  child: LayarPemutarPelajaran(
                    modulId: 'keuangan_usaha_kecil',
                    pelajaranId: 'keuangan_usaha_kecil_17_1',
                    pelajaranOverride: pel,
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
    },
  );
}
