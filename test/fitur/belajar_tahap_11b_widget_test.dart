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
    'Pengujian Widget Belajar Tahap 11B (Modul 15 Pajak Lanjutan & Modul 16 Pensiun)',
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
        final data = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
        return PelajaranKonten.fromJson(data);
      }

      ModulKonten muatModulLocal(String modulId) {
        final f = File('aset/konten/lanjutan/$modulId/modul.json');
        final data = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
        return ModulKonten.fromJson(data);
      }

      testWidgets(
        '1. Status Modul 15 & 16 pada Peta Belajar: Terkunci vs Terbuka',
        (tester) async {
          tester.view.physicalSize = const Size(1080, 2400);
          tester.view.devicePixelRatio = 2.0;
          addTearDown(() => tester.view.resetPhysicalSize());

          final modul15 = muatModulLocal('pajak_lanjutan');
          final modul16 = muatModulLocal('pensiun_kebebasan_finansial');

          // Kasus A: Terkunci
          final fotoDataTerkunci = FotoDataPengguna.kosong();
          expect(
            tentukanStatusModul(
              modul: modul15,
              fotoData: fotoDataTerkunci,
            ).status,
            equals(StatusBelajar.terkunci),
          );
          expect(
            tentukanStatusModul(
              modul: modul16,
              fotoData: fotoDataTerkunci,
            ).status,
            equals(StatusBelajar.terkunci),
          );

          // Kasus B: Terbuka Modul 15 (modul_selesai pajak_dasar dan bulanTransaksiBerbeda >= 6)
          final fotoDataTerbuka15 = FotoDataPengguna.kosong().copyWith(
            bulanTransaksiBerbeda: 6,
            hasilKuisTerbaik: {
              'pajak_dasar': const HasilKuisSnapshot(
                skorPersen: 100,
                lulus: true,
              ),
            },
          );
          expect(
            tentukanStatusModul(
              modul: modul15,
              fotoData: fotoDataTerbuka15,
            ).status,
            equals(StatusBelajar.terbuka),
          );

          // Kasus C: Terbuka Modul 16 (modul_selesai investasi_lanjutan dan bulanTransaksiBerbeda >= 3)
          final fotoDataTerbuka16 = FotoDataPengguna.kosong().copyWith(
            bulanTransaksiBerbeda: 3,
            hasilKuisTerbaik: {
              'investasi_lanjutan': const HasilKuisSnapshot(
                skorPersen: 100,
                lulus: true,
              ),
            },
          );
          expect(
            tentukanStatusModul(
              modul: modul16,
              fotoData: fotoDataTerbuka16,
            ).status,
            equals(StatusBelajar.terbuka),
          );

          final pel15_1 = muatPelajaranLocal(
            'pajak_lanjutan',
            'pajak_lanjutan_15_1',
          );
          final statusPel15_1 = tentukanStatusPelajaran(
            pelajaran: pel15_1,
            posisiIndeks: 0,
            daftarPelajaranModul: [pel15_1],
            gerbangModul: modul15.gerbang,
            fotoData: fotoDataTerbuka15,
          );

          final itemModul15 = ItemPetaModul(
            modul: modul15,
            statusModul: const HasilStatusBelajar(
              status: StatusBelajar.terbuka,
              apaYangKurang: [],
            ),
            daftarPelajaran: [(pel15_1, statusPel15_1)],
          );

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                penyediaBasisData.overrideWithValue(db),
                penyediaFotoData.overrideWith(
                  (ref) => Future.value(fotoDataTerbuka15),
                ),
                penyediaKamus.overrideWith(
                  (ref) => Future.value(<String, IstilahKamus>{}),
                ),
                penyediaPetaBelajar.overrideWith(
                  (ref) => Future.value([itemModul15]),
                ),
              ],
              child: MaterialApp(
                theme: TemaFunda.temaTerang,
                home: const Scaffold(body: LayarBelajar()),
              ),
            ),
          );
          await tester.pump();
          await pompaHinggaAda(tester, find.text('Pajak Lanjutan'));
          expect(find.text('Pajak Lanjutan'), findsOneWidget);
          await bongkarWidget(tester);
        },
      );

      testWidgets(
        '2. Misi Pelajaran 15.1 (Keputusan: Menata dokumen penghasilan beragam)',
        (tester) async {
          tester.view.physicalSize = const Size(1080, 2400);
          tester.view.devicePixelRatio = 2.0;
          addTearDown(() => tester.view.resetPhysicalSize());

          final pel = muatPelajaranLocal(
            'pajak_lanjutan',
            'pajak_lanjutan_15_1',
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
                  modulId: 'pajak_lanjutan',
                  pelajaranId: 'pajak_lanjutan_15_1',
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

          // Jawab 3 soal Cek Paham 15.1 (1 soal per halaman)
          final opsi1 = find.textContaining(
            'Sebagai bukti resmi bahwa sebagian pajak sudah dipotong',
          );
          await tester.ensureVisible(opsi1);
          await tester.tap(opsi1);
          await tester.pump();
          await tester.tap(find.byKey(const Key('tombol_lanjut')));
          await tester.pump();

          final opsi2 = find.textContaining(
            'Pajak final perhitungannya selesai saat dipotong',
          );
          await tester.ensureVisible(opsi2);
          await tester.tap(opsi2);
          await tester.pump();
          await tester.tap(find.byKey(const Key('tombol_lanjut')));
          await tester.pump();

          final opsi3 = find.textContaining(
            'Dipisah per kategori pemasukan sejak awal',
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
            find.text('Menata dokumen penghasilan beragam'),
          );
          expect(
            find.text('Menata dokumen penghasilan beragam'),
            findsOneWidget,
          );

          final opsiAman = find.textContaining(
            'Kumpulkan bukti potong kantor, rekap kategori freelance di Funda',
          );
          await tester.ensureVisible(opsiAman);
          await tester.tap(opsiAman);
          await tester.pump();

          expect(
            find.textContaining(
              'Data yang lengkap membuat proses pelaporan lewat saluran resmi jauh lebih cepat dan akurat',
            ),
            findsOneWidget,
          );

          final hasilMisi =
              await (db.select(db.tabelHasilMisi)
                    ..where((m) => m.misiId.equals('pajak_lanjutan_15_1')))
                  .getSingleOrNull();
          expect(hasilMisi, isNotNull);
          expect(hasilMisi!.status, equals('selesai'));
          expect(hasilMisi.tipe, equals('keputusan'));

          await bongkarWidget(tester);
        },
      );

      testWidgets(
        '3. Misi Pelajaran 15.2 (Refleksi: Merapikan kebiasaan arsip tahunanmu)',
        (tester) async {
          tester.view.physicalSize = const Size(1080, 2400);
          tester.view.devicePixelRatio = 2.0;
          addTearDown(() => tester.view.resetPhysicalSize());

          final pel = muatPelajaranLocal(
            'pajak_lanjutan',
            'pajak_lanjutan_15_2',
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
                  modulId: 'pajak_lanjutan',
                  pelajaranId: 'pajak_lanjutan_15_2',
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

          // Jawab 3 soal Cek Paham 15.2 (1 soal per halaman)
          final opsi1 = find.textContaining(
            'Mengelola kewajiban pajak secara tertib mengikuti aturan resmi',
          );
          await tester.ensureVisible(opsi1);
          await tester.tap(opsi1);
          await tester.pump();
          await tester.tap(find.byKey(const Key('tombol_lanjut')));
          await tester.pump();

          final opsi2 = find.textContaining(
            'Saat sumber penghasilan makin beragam atau aturan terasa membingungkan',
          );
          await tester.ensureVisible(opsi2);
          await tester.tap(opsi2);
          await tester.pump();
          await tester.tap(find.byKey(const Key('tombol_lanjut')));
          await tester.pump();

          final opsi3 = find.textContaining(
            'Karena status tanggungan memengaruhi perhitungan batas tidak kena pajak',
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
            find.text('Merapikan kebiasaan arsip tahunanmu'),
          );
          expect(
            find.text('Merapikan kebiasaan arsip tahunanmu'),
            findsOneWidget,
          );

          final input = find.byType(TextField);
          await tester.ensureVisible(input);
          await tester.enterText(
            input,
            'Aku akan membuat folder Google Drive khusus bukti potong.',
          );
          await tester.pump();

          final btnSimpan = find.text('Simpan Refleksi');
          await tester.ensureVisible(btnSimpan);
          await tester.tap(btnSimpan);
          await tester.pump();

          final hasilMisi =
              await (db.select(db.tabelHasilMisi)
                    ..where((m) => m.misiId.equals('pajak_lanjutan_15_2')))
                  .getSingleOrNull();
          expect(hasilMisi, isNotNull);
          expect(hasilMisi!.status, equals('selesai'));
          expect(hasilMisi.tipe, equals('refleksi'));

          await bongkarWidget(tester);
        },
      );

      testWidgets(
        '4. Misi Pelajaran 15.3 (Daftar Periksa: Daftar siap lapor pajak lanjutan + Disclaimer)',
        (tester) async {
          tester.view.physicalSize = const Size(1080, 2400);
          tester.view.devicePixelRatio = 2.0;
          addTearDown(() => tester.view.resetPhysicalSize());

          final pel = muatPelajaranLocal(
            'pajak_lanjutan',
            'pajak_lanjutan_15_3',
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
                  modulId: 'pajak_lanjutan',
                  pelajaranId: 'pajak_lanjutan_15_3',
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

          // Jawab 3 soal Cek Paham 15.3 (1 soal per halaman)
          final opsi1 = find.textContaining('Menu Kekayaan Bersih');
          await tester.ensureVisible(opsi1);
          await tester.tap(opsi1);
          await tester.pump();
          await tester.tap(find.byKey(const Key('tombol_lanjut')));
          await tester.pump();

          final opsi2 = find.textContaining(
            'Bukti penerimaan pelaporan tahunan',
          );
          await tester.ensureVisible(opsi2);
          await tester.tap(opsi2);
          await tester.pump();
          await tester.tap(find.byKey(const Key('tombol_lanjut')));
          await tester.pump();

          final opsi3 = find.textContaining(
            'Memberi waktu memeriksa kesalahan tanpa panik',
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
            find.text('Daftar siap lapor pajak lanjutan'),
          );
          expect(find.text('Daftar siap lapor pajak lanjutan'), findsOneWidget);

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
              await (db.select(db.tabelHasilMisi)
                    ..where((m) => m.misiId.equals('pajak_lanjutan_15_3')))
                  .getSingleOrNull();
          expect(hasilMisi, isNotNull);
          expect(hasilMisi!.status, equals('selesai'));
          expect(hasilMisi.tipe, equals('daftar_periksa'));

          await bongkarWidget(tester);
        },
      );

      testWidgets(
        '5. Misi Pelajaran 16.1 (Keputusan: Mulai menyiapkan masa depan sejak muda)',
        (tester) async {
          tester.view.physicalSize = const Size(1080, 2400);
          tester.view.devicePixelRatio = 2.0;
          addTearDown(() => tester.view.resetPhysicalSize());

          final pel = muatPelajaranLocal(
            'pensiun_kebebasan_finansial',
            'pensiun_kebebasan_finansial_16_1',
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
                  modulId: 'pensiun_kebebasan_finansial',
                  pelajaranId: 'pensiun_kebebasan_finansial_16_1',
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

          // Jawab 3 soal Cek Paham 16.1 (1 soal per halaman)
          final opsi1 = find.textContaining(
            'Karena waktu yang panjang membuat setoran bulanan lebih kecil',
          );
          await tester.ensureVisible(opsi1);
          await tester.tap(opsi1);
          await tester.pump();
          await tester.tap(find.byKey(const Key('tombol_lanjut')));
          await tester.pump();

          final opsi2 = find.textContaining(
            'Biaya hidup rutin sudah bisa ditopang oleh hasil simpanan',
          );
          await tester.ensureVisible(opsi2);
          await tester.tap(opsi2);
          await tester.pump();
          await tester.tap(find.byKey(const Key('tombol_lanjut')));
          await tester.pump();

          final opsi3 = find.textContaining(
            'Pertumbuhan yang dihitung bukan hanya dari pokok awal',
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
            find.text('Mulai menyiapkan masa depan sejak muda'),
          );
          expect(
            find.text('Mulai menyiapkan masa depan sejak muda'),
            findsOneWidget,
          );

          final opsiAman = find.textContaining(
            'Mulai sisihkan porsi kecil yang nyaman secara rutin',
          );
          await tester.ensureVisible(opsiAman);
          await tester.tap(opsiAman);
          await tester.pump();

          expect(
            find.textContaining(
              'Memulai dari nominal kecil di usia muda jauh lebih ringan daripada menunda puluhan tahun',
            ),
            findsOneWidget,
          );

          final hasilMisi =
              await (db.select(db.tabelHasilMisi)..where(
                    (m) => m.misiId.equals('pensiun_kebebasan_finansial_16_1'),
                  ))
                  .getSingleOrNull();
          expect(hasilMisi, isNotNull);
          expect(hasilMisi!.status, equals('selesai'));
          expect(hasilMisi.tipe, equals('keputusan'));

          await bongkarWidget(tester);
        },
      );

      testWidgets(
        '6. Umpan Balik Pelajaran 16.2 (proyeksi_kebebasan_finansial: Lihat patokan awal dana pensiunmu)',
        (tester) async {
          tester.view.physicalSize = const Size(1080, 2400);
          tester.view.devicePixelRatio = 2.0;
          addTearDown(() => tester.view.resetPhysicalSize());

          final pel = muatPelajaranLocal(
            'pensiun_kebebasan_finansial',
            'pensiun_kebebasan_finansial_16_2',
          );

          final now = DateTime.now();
          await db
              .into(db.tabelDompet)
              .insert(
                TabelDompetCompanion.insert(
                  id: 'dompet_utama',
                  nama: 'Dompet Utama',
                  jenis: 'tunai',
                  ikon: 'wallet',
                  warna: 'biru',
                  saldoAwalRupiah: const Value(300000000),
                  dibuatPada: Value(now),
                ),
              );
          await db
              .into(db.tabelKategori)
              .insert(
                TabelKategoriCompanion.insert(
                  id: 'kat_makan',
                  nama: 'Makan',
                  arus: 'keluar',
                  sifat: 'kebutuhan',
                  ikon: 'food',
                ),
              );
          await db
              .into(db.tabelTransaksi)
              .insert(
                TabelTransaksiCompanion.insert(
                  id: 'trx_wajib_1',
                  jenis: 'keluar',
                  jumlahRupiah: 4000000,
                  dompetId: 'dompet_utama',
                  kategoriId: const Value('kat_makan'),
                  waktuTransaksi: now,
                  catatan: const Value('Makan Pokok'),
                ),
              );

          final fotoData = FotoDataPengguna.kosong();

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                penyediaBasisData.overrideWithValue(db),
                penyediaFotoData.overrideWith((ref) => Future.value(fotoData)),
                penyediaKamus.overrideWith(
                  (ref) => Future.value(<String, IstilahKamus>{}),
                ),
                penyediaTotalSaldoAktif.overrideWith((ref) => 300000000),
              ],
              child: MaterialApp(
                theme: TemaFunda.temaTerang,
                home: LayarPemutarPelajaran(
                  modulId: 'pensiun_kebebasan_finansial',
                  pelajaranId: 'pensiun_kebebasan_finansial_16_2',
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

          // Jawab 3 soal Cek Paham 16.2 (1 soal per halaman)
          final opsi1 = find.textContaining(
            'Dari pengeluaran hidup bulanan dan tahunannya sendiri',
          );
          await tester.ensureVisible(opsi1);
          await tester.tap(opsi1);
          await tester.pump();
          await tester.tap(find.byKey(const Key('tombol_lanjut')));
          await tester.pump();

          final opsi2 = find.textContaining('Rp600.000.000');
          await tester.ensureVisible(opsi2);
          await tester.tap(opsi2);
          await tester.pump();
          await tester.tap(find.byKey(const Key('tombol_lanjut')));
          await tester.pump();

          final opsi3 = find.textContaining(
            'Sebagai kompas awal yang disesuaikan dengan inflasi dan kondisimu',
          );
          await tester.ensureVisible(opsi3);
          await tester.tap(opsi3);
          await tester.pump();

          // Tap Lanjut ke Misi Lihat Hitungan
          final btnLanjutKeMisi = find.byKey(const Key('tombol_lanjut'));
          await tester.tap(btnLanjutKeMisi);
          await tester.pump();

          await pompaHinggaAda(
            tester,
            find.text('Lihat patokan awal dana pensiunmu'),
          );
          expect(
            find.text('Lihat patokan awal dana pensiunmu'),
            findsOneWidget,
          );

          // Tap Lanjut ke Kartu Umpan Balik Nyata
          final btnLanjutKeUmpanBalik = find.byKey(const Key('tombol_lanjut'));
          await tester.tap(btnLanjutKeUmpanBalik);
          await tester.pump();

          // Umpan balik nyata muncul
          await pompaHinggaAda(tester, find.text('Hasil dari Datamu'));
          expect(find.text('Hasil dari Datamu'), findsOneWidget);

          // Verifikasi teks proyeksi_kebebasan_finansial
          expect(
            find.textContaining(
              'Dengan pengeluaran wajib sekitar Rp4.000.000 per bulan',
            ),
            findsOneWidget,
          );
          expect(
            find.textContaining(
              'patokan awal 25 kali pengeluaran tahunan berada di sekitar Rp1.200.000.000',
            ),
            findsOneWidget,
          );
          expect(
            find.textContaining('Kekayaan bersihmu saat ini Rp300.000.000'),
            findsOneWidget,
          );
          expect(
            find.textContaining(
              'Ini simulasi aturan praktis, bukan jaminan hasil',
            ),
            findsOneWidget,
          );

          await bongkarWidget(tester);
        },
      );

      testWidgets(
        '7. Misi Pelajaran 16.3 (Daftar Periksa: Peta jalan masa pensiun tenang + Disclaimer)',
        (tester) async {
          tester.view.physicalSize = const Size(1080, 2400);
          tester.view.devicePixelRatio = 2.0;
          addTearDown(() => tester.view.resetPhysicalSize());

          final pel = muatPelajaranLocal(
            'pensiun_kebebasan_finansial',
            'pensiun_kebebasan_finansial_16_3',
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
                  modulId: 'pensiun_kebebasan_finansial',
                  pelajaranId: 'pensiun_kebebasan_finansial_16_3',
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

          // Jawab 3 soal Cek Paham 16.3 (1 soal per halaman)
          final opsi1 = find.textContaining(
            'Karena daya belinya akan tergerus inflasi dari tahun ke tahun',
          );
          await tester.ensureVisible(opsi1);
          await tester.tap(opsi1);
          await tester.pump();
          await tester.tap(find.byKey(const Key('tombol_lanjut')));
          await tester.pump();

          final opsi2 = find.textContaining(
            'Menambah porsi setoran setiap kali penghasilan naik',
          );
          await tester.ensureVisible(opsi2);
          await tester.tap(opsi2);
          await tester.pump();
          await tester.tap(find.byKey(const Key('tombol_lanjut')));
          await tester.pump();

          final opsi3 = find.textContaining(
            'Bebas dari beban cicilan besar dan memiliki perlindungan kesehatan aktif',
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
            find.text('Peta jalan masa pensiun tenang'),
          );
          expect(find.text('Peta jalan masa pensiun tenang'), findsOneWidget);

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
                    (m) => m.misiId.equals('pensiun_kebebasan_finansial_16_3'),
                  ))
                  .getSingleOrNull();
          expect(hasilMisi, isNotNull);
          expect(hasilMisi!.status, equals('selesai'));
          expect(hasilMisi.tipe, equals('daftar_periksa'));

          await bongkarWidget(tester);
        },
      );

      testWidgets('8. Kuis Modul 15 & 16: Tampilan kuis berjalan lancar', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final modul15 = muatModulLocal('pajak_lanjutan');
        final modul16 = muatModulLocal('pensiun_kebebasan_finansial');

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              penyediaBasisData.overrideWithValue(db),
              penyediaDaftarSemuaModul.overrideWith(
                (ref) => Future.value([modul15, modul16]),
              ),
            ],
            child: MaterialApp(
              theme: TemaFunda.temaTerang,
              home: const LayarKuisModul(modulId: 'pajak_lanjutan'),
            ),
          ),
        );
        await tester.pump();

        expect(find.textContaining('Kuis'), findsWidgets);
        await bongkarWidget(tester);
      });

      testWidgets(
        '9. Aksesibilitas Skala Teks 2.0 pada 360x640: Bebas RenderFlex Overflow',
        (tester) async {
          tester.view.physicalSize = const Size(360, 640);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() => tester.view.resetPhysicalSize());

          final pel16 = muatPelajaranLocal(
            'pensiun_kebebasan_finansial',
            'pensiun_kebebasan_finansial_16_1',
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
                    modulId: 'pensiun_kebebasan_finansial',
                    pelajaranId: 'pensiun_kebebasan_finansial_16_1',
                    pelajaranOverride: pel16,
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
