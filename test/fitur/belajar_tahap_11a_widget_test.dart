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
import 'package:funda/tema/tema.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../pembantu/pompa_uji.dart';

void main() {
  group('Pengujian Widget Belajar Tahap 11A (Modul 13 Investasi Lanjutan & Modul 14 KPR)', () {
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

    testWidgets('1. Status Modul 13 & 14 pada Peta Belajar: Terkunci vs Terbuka', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final modul13 = muatModulLocal('investasi_lanjutan');
      final modul14 = muatModulLocal('kpr_kredit_besar');

      // Kasus A: Terkunci
      final fotoDataTerkunci = FotoDataPengguna.kosong();
      expect(tentukanStatusModul(modul: modul13, fotoData: fotoDataTerkunci).status, equals(StatusBelajar.terkunci));
      expect(tentukanStatusModul(modul: modul14, fotoData: fotoDataTerkunci).status, equals(StatusBelajar.terkunci));

      // Kasus B: Terbuka Modul 13 (modul_selesai investasi_dasar dan bulanTransaksiBerbeda >= 3)
      final fotoDataTerbuka13 = FotoDataPengguna.kosong().copyWith(
        bulanTransaksiBerbeda: 3,
        hasilKuisTerbaik: {
          'investasi_dasar': const HasilKuisSnapshot(skorPersen: 100, lulus: true),
        },
      );
      expect(tentukanStatusModul(modul: modul13, fotoData: fotoDataTerbuka13).status, equals(StatusBelajar.terbuka));

      // Kasus C: Terbuka Modul 14 (modul_selesai utang_cicilan DAN tujuan_besar dan bulanTransaksiBerbeda >= 3)
      final fotoDataTerbuka14 = FotoDataPengguna.kosong().copyWith(
        bulanTransaksiBerbeda: 3,
        hasilKuisTerbaik: {
          'utang_cicilan': const HasilKuisSnapshot(skorPersen: 100, lulus: true),
          'tujuan_besar': const HasilKuisSnapshot(skorPersen: 100, lulus: true),
        },
      );
      expect(tentukanStatusModul(modul: modul14, fotoData: fotoDataTerbuka14).status, equals(StatusBelajar.terbuka));

      final pel13_1 = muatPelajaranLocal('investasi_lanjutan', 'investasi_lanjutan_13_1');
      final statusPel13_1 = tentukanStatusPelajaran(
        pelajaran: pel13_1,
        posisiIndeks: 0,
        daftarPelajaranModul: [pel13_1],
        gerbangModul: modul13.gerbang,
        fotoData: fotoDataTerbuka13,
      );

      final itemModul13 = ItemPetaModul(
        modul: modul13,
        statusModul: const HasilStatusBelajar(status: StatusBelajar.terbuka, apaYangKurang: []),
        daftarPelajaran: [(pel13_1, statusPel13_1)],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            penyediaBasisData.overrideWithValue(db),
            penyediaFotoData.overrideWith((ref) => Future.value(fotoDataTerbuka13)),
            penyediaKamus.overrideWith((ref) => Future.value(<String, IstilahKamus>{})),
            penyediaPetaBelajar.overrideWith((ref) => Future.value([itemModul13])),
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
      await pompaHinggaAda(tester, find.text('Investasi Lanjutan'));
      expect(find.text('Investasi Lanjutan'), findsOneWidget);
      await bongkarWidget(tester);
    });

    testWidgets('2. Misi Pelajaran 13.1 (Sandbox: Uji komposisi alokasi di Sandbox)', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      // Tambahkan sesi sandbox simulasi minimal 12 bulan
      final now = DateTime.now();
      await db.into(db.tabelSesiSandbox).insert(
        TabelSesiSandboxCompanion.insert(
          alokasiPasarUangPersen: 50,
          alokasiObligasiPersen: 30,
          alokasiSahamPersen: 20,
          bulanBerjalan: const Value(12),
          nilaiSaatIniRupiah: 11000000,
          skenarioAktif: 'moderat',
          riwayatJson: '[]',
          diperbaruiPada: now,
        ),
      );

      final pel = muatPelajaranLocal('investasi_lanjutan', 'investasi_lanjutan_13_1');

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
              modulId: 'investasi_lanjutan',
              pelajaranId: 'investasi_lanjutan_13_1',
              pelajaranOverride: pel,
            ),
          ),
        ),
      );
      await tester.pump();

      // Maju melewati kartu hingga Cek Paham
      while (find.text('Uji Pemahaman Singkat').evaluate().isEmpty) {
        final btnLanjut = find.byKey(const Key('tombol_lanjut'));
        expect(btnLanjut, findsOneWidget);
        await tester.tap(btnLanjut);
        await tester.pump();
      }

      // Jawab 3 soal Cek Paham 13.1
      final opsi1 = find.textContaining('Mengembalikan pembagian instrumen ke target awal');
      await tester.ensureVisible(opsi1);
      await tester.tap(opsi1);
      await tester.pump();

      final opsi2 = find.textContaining('Profil risiko dan jangka waktu tujuannya');
      await tester.ensureVisible(opsi2);
      await tester.tap(opsi2);
      await tester.pump();

      final opsi3 = find.textContaining('Secara berkala, misalnya setahun sekali');
      await tester.ensureVisible(opsi3);
      await tester.tap(opsi3);
      await tester.pump();

      // Tap Lanjut ke Misi Sandbox
      final btnLanjutKeMisi = find.byKey(const Key('tombol_lanjut'));
      await tester.tap(btnLanjutKeMisi);
      await tester.pump();

      await pompaHinggaAda(tester, find.text('Uji komposisi alokasi di Sandbox'));
      expect(find.text('Uji komposisi alokasi di Sandbox'), findsOneWidget);

      // Tekan tombol periksa misi sandbox
      final btnPeriksa = find.byKey(const Key('tombol_periksa_misi_sandbox'));
      expect(btnPeriksa, findsOneWidget);
      await tester.ensureVisible(btnPeriksa);
      await tester.tap(btnPeriksa);
      await tester.pump();

      final hasilMisi = await (db.select(db.tabelHasilMisi)
            ..where((m) => m.misiId.equals('investasi_lanjutan_13_1')))
          .getSingleOrNull();
      expect(hasilMisi, isNotNull);
      expect(hasilMisi!.status, equals('selesai'));
      expect(hasilMisi.tipe, equals('sandbox'));

      await bongkarWidget(tester);
    });

    testWidgets('3. Misi Pelajaran 13.2 (Keputusan: Menilai tawaran instrumen berbiaya tinggi)', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final pel = muatPelajaranLocal('investasi_lanjutan', 'investasi_lanjutan_13_2');

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
              modulId: 'investasi_lanjutan',
              pelajaranId: 'investasi_lanjutan_13_2',
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

      // Jawab 3 soal Cek Paham 13.2
      final opsi1 = find.textContaining('potongan berulang tiap tahun ikut mengurangi');
      await tester.ensureVisible(opsi1);
      await tester.tap(opsi1);
      await tester.pump();

      final opsi2 = find.textContaining('Memahami perlakuannya lewat sumber resmi');
      await tester.ensureVisible(opsi2);
      await tester.tap(opsi2);
      await tester.pump();

      final opsi3 = find.textContaining('Hasil bersih setelah memperhitungkan biaya dan pajak');
      await tester.ensureVisible(opsi3);
      await tester.tap(opsi3);
      await tester.pump();

      // Tap Lanjut ke Misi Keputusan
      final btnLanjutKeMisi = find.byKey(const Key('tombol_lanjut'));
      await tester.tap(btnLanjutKeMisi);
      await tester.pump();

      await pompaHinggaAda(tester, find.text('Menilai tawaran instrumen berbiaya tinggi'));
      expect(find.text('Menilai tawaran instrumen berbiaya tinggi'), findsOneWidget);

      // Pilih opsi A
      final opsiAman = find.textContaining('Pilih mempelajari Instrumen A');
      await tester.ensureVisible(opsiAman);
      await tester.tap(opsiAman);
      await tester.pump();

      expect(find.textContaining('Keterbukaan biaya dan risiko adalah ciri layanan yang sehat'), findsOneWidget);

      final hasilMisi = await (db.select(db.tabelHasilMisi)
            ..where((m) => m.misiId.equals('investasi_lanjutan_13_2')))
          .getSingleOrNull();
      expect(hasilMisi, isNotNull);
      expect(hasilMisi!.status, equals('selesai'));
      expect(hasilMisi.tipe, equals('keputusan'));

      await bongkarWidget(tester);
    });

    testWidgets('4. Misi Pelajaran 13.3 (Daftar Periksa: Aturan tenang menghadapi gejolak pasar)', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final pel = muatPelajaranLocal('investasi_lanjutan', 'investasi_lanjutan_13_3');

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
              modulId: 'investasi_lanjutan',
              pelajaranId: 'investasi_lanjutan_13_3',
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

      // Jawab 3 soal Cek Paham 13.3
      final opsi1 = find.textContaining('Mengunci kerugian yang tadinya hanya penurunan sementara');
      await tester.ensureVisible(opsi1);
      await tester.tap(opsi1);
      await tester.pump();

      final opsi2 = find.textContaining('Melatih disiplin dan mengurangi stres');
      await tester.ensureVisible(opsi2);
      await tester.tap(opsi2);
      await tester.pump();

      final opsi3 = find.textContaining('Apakah tujuan jangka panjangku berubah');
      await tester.ensureVisible(opsi3);
      await tester.tap(opsi3);
      await tester.pump();

      // Tap Lanjut ke Misi Daftar Periksa
      final btnLanjutKeMisi = find.byKey(const Key('tombol_lanjut'));
      await tester.tap(btnLanjutKeMisi);
      await tester.pump();

      await pompaHinggaAda(tester, find.text('Aturan tenang menghadapi gejolak pasar'));
      expect(find.text('Aturan tenang menghadapi gejolak pasar'), findsOneWidget);

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

      final tombolSelesai = find.byKey(const Key('tombol_selesai_daftar_periksa'));
      expect(tombolSelesai, findsOneWidget);
      await tester.ensureVisible(tombolSelesai);
      await tester.tap(tombolSelesai);
      await tester.pump();

      final hasilMisi = await (db.select(db.tabelHasilMisi)
            ..where((m) => m.misiId.equals('investasi_lanjutan_13_3')))
          .getSingleOrNull();
      expect(hasilMisi, isNotNull);
      expect(hasilMisi!.status, equals('selesai'));
      expect(hasilMisi.tipe, equals('daftar_periksa'));

      await bongkarWidget(tester);
    });

    testWidgets('5. Misi Pelajaran 14.1 (Keputusan: Menyiapkan dana akad rumah)', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final pel = muatPelajaranLocal('kpr_kredit_besar', 'kpr_kredit_besar_14_1');

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
              modulId: 'kpr_kredit_besar',
              pelajaranId: 'kpr_kredit_besar_14_1',
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

      // Jawab 3 soal Cek Paham 14.1
      final opsi1 = find.textContaining('Karena masih ada biaya akad, notaris');
      await tester.ensureVisible(opsi1);
      await tester.tap(opsi1);
      await tester.pump();

      final opsi2 = find.textContaining('Pokok pinjaman lebih kecil sehingga cicilan');
      await tester.ensureVisible(opsi2);
      await tester.tap(opsi2);
      await tester.pump();

      final opsi3 = find.textContaining('Sebaiknya jangan, karena setelah pindah');
      await tester.ensureVisible(opsi3);
      await tester.tap(opsi3);
      await tester.pump();

      // Tap Lanjut ke Misi
      final btnLanjutKeMisi = find.byKey(const Key('tombol_lanjut'));
      await tester.tap(btnLanjutKeMisi);
      await tester.pump();

      await pompaHinggaAda(tester, find.text('Menyiapkan dana akad rumah'));
      expect(find.text('Menyiapkan dana akad rumah'), findsOneWidget);

      final opsiAman = find.textContaining('Tunda dulu beberapa bulan sampai dana akad terkumpul');
      await tester.ensureVisible(opsiAman);
      await tester.tap(opsiAman);
      await tester.pump();

      expect(find.textContaining('Membeli rumah dengan dana darurat tetap utuh'), findsOneWidget);

      final hasilMisi = await (db.select(db.tabelHasilMisi)
            ..where((m) => m.misiId.equals('kpr_kredit_besar_14_1')))
          .getSingleOrNull();
      expect(hasilMisi, isNotNull);
      expect(hasilMisi!.status, equals('selesai'));
      expect(hasilMisi.tipe, equals('keputusan'));

      await bongkarWidget(tester);
    });

    testWidgets('6. Misi Pelajaran 14.2 (Keputusan: Menguji kesiapan saat cicilan naik)', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final pel = muatPelajaranLocal('kpr_kredit_besar', 'kpr_kredit_besar_14_2');

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
              modulId: 'kpr_kredit_besar',
              pelajaranId: 'kpr_kredit_besar_14_2',
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

      // Jawab 3 soal Cek Paham 14.2
      final opsi1 = find.textContaining('Cicilan bulanan bisa naik saat beralih ke bunga mengambang');
      await tester.ensureVisible(opsi1);
      await tester.tap(opsi1);
      await tester.pump();

      final opsi2 = find.textContaining('Memberi fleksibilitas dan waktu mengumpulkan uang muka');
      await tester.ensureVisible(opsi2);
      await tester.tap(opsi2);
      await tester.pump();

      final opsi3 = find.textContaining('Biaya perawatan, pajak tahunan properti');
      await tester.ensureVisible(opsi3);
      await tester.tap(opsi3);
      await tester.pump();

      // Tap Lanjut ke Misi
      final btnLanjutKeMisi = find.byKey(const Key('tombol_lanjut'));
      await tester.tap(btnLanjutKeMisi);
      await tester.pump();

      await pompaHinggaAda(tester, find.text('Menguji kesiapan saat cicilan naik'));
      expect(find.text('Menguji kesiapan saat cicilan naik'), findsOneWidget);

      final opsiAman = find.textContaining('Hitung ulang dengan harga rumah lebih terjangkau');
      await tester.ensureVisible(opsiAman);
      await tester.tap(opsiAman);
      await tester.pump();

      expect(find.textContaining('Mengukur kemampuan bayar dari skenario cicilan normal'), findsOneWidget);

      final hasilMisi = await (db.select(db.tabelHasilMisi)
            ..where((m) => m.misiId.equals('kpr_kredit_besar_14_2')))
          .getSingleOrNull();
      expect(hasilMisi, isNotNull);
      expect(hasilMisi!.status, equals('selesai'));
      expect(hasilMisi.tipe, equals('keputusan'));

      await bongkarWidget(tester);
    });

    testWidgets('7. Umpan Balik Pelajaran 14.3 (uji_kemampuan_kpr: Uji ruang cicilanmu)', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final pel = muatPelajaranLocal('kpr_kredit_besar', 'kpr_kredit_besar_14_3');

      final now = DateTime.now();
      await db.into(db.tabelDompet).insert(
        TabelDompetCompanion.insert(
          id: 'dompet_utama',
          nama: 'Dompet Utama',
          jenis: 'tunai',
          ikon: 'wallet',
          warna: 'biru',
          saldoAwalRupiah: const Value(5000000),
          dibuatPada: Value(now),
        ),
      );
      await db.into(db.tabelTransaksi).insert(
        TabelTransaksiCompanion.insert(
          id: 'trx_masuk_1',
          jenis: 'masuk',
          jumlahRupiah: 10000000,
          dompetId: 'dompet_utama',
          waktuTransaksi: now,
          catatan: const Value('Gaji'),
        ),
      );
      await db.into(db.tabelUtang).insert(
        TabelUtangCompanion.insert(
          id: 'utang_motor',
          nama: 'Cicilan Motor',
          jenis: 'cicilan',
          sisaAwalRupiah: 12000000,
          jenisBunga: 'flat',
          cicilanBulananRupiah: const Value(1000000),
          dibuatPada: now,
        ),
      );

      final fotoData = FotoDataPengguna.kosong();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            penyediaBasisData.overrideWithValue(db),
            penyediaFotoData.overrideWith((ref) => Future.value(fotoData)),
            penyediaKamus.overrideWith((ref) => Future.value(<String, IstilahKamus>{})),
          ],
          child: MaterialApp(
            theme: TemaFunda.temaTerang,
            home: LayarPemutarPelajaran(
              modulId: 'kpr_kredit_besar',
              pelajaranId: 'kpr_kredit_besar_14_3',
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

      // Jawab 3 soal Cek Paham 14.3
      final opsi1 = find.textContaining('mencerminkan kebutuhan hidup dan cicilan aktualmu');
      await tester.ensureVisible(opsi1);
      await tester.tap(opsi1);
      await tester.pump();

      final opsi2 = find.textContaining('Menyisihkan selisih calon cicilan ke tabungan khusus');
      await tester.ensureVisible(opsi2);
      await tester.tap(opsi2);
      await tester.pump();

      final opsi3 = find.textContaining('Rp2.000.000');
      await tester.ensureVisible(opsi3);
      await tester.tap(opsi3);
      await tester.pump();

      // Tap Lanjut ke Misi Lihat Hitungan
      final btnLanjutKeMisi = find.byKey(const Key('tombol_lanjut'));
      await tester.tap(btnLanjutKeMisi);
      await tester.pump();

      await pompaHinggaAda(tester, find.text('Uji ruang cicilanmu dari data nyata'));
      expect(find.text('Uji ruang cicilanmu dari data nyata'), findsOneWidget);

      // Tap Lanjut ke Kartu Umpan Balik Nyata
      final btnLanjutKeUmpanBalik = find.byKey(const Key('tombol_lanjut'));
      await tester.tap(btnLanjutKeUmpanBalik);
      await tester.pump();

      // Umpan balik nyata muncul
      await pompaHinggaAda(tester, find.text('Umpan Balik Nyata'));
      expect(find.text('Umpan Balik Nyata'), findsOneWidget);

      // Verifikasi teks uji_kemampuan_kpr
      expect(find.textContaining('Dengan pemasukan sekitar Rp10.000.000 per bulan'), findsOneWidget);
      expect(find.textContaining('cicilan aktif saat ini Rp1.000.000'), findsOneWidget);
      expect(find.textContaining('estimasi sisa ruang cicilan (memakai patokan umum 30 persen) adalah sekitar Rp2.000.000 per bulan'), findsOneWidget);
      expect(find.textContaining('Ini simulasi edukatif, bukan persetujuan kredit'), findsOneWidget);

      await bongkarWidget(tester);
    });

    testWidgets('8. Kuis Modul 13 & 14: Tampilan kuis berjalan lancar', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final modul13 = muatModulLocal('investasi_lanjutan');
      final modul14 = muatModulLocal('kpr_kredit_besar');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            penyediaBasisData.overrideWithValue(db),
            penyediaDaftarSemuaModul.overrideWith((ref) => Future.value([modul13, modul14])),
          ],
          child: MaterialApp(
            theme: TemaFunda.temaTerang,
            home: const LayarKuisModul(
              modulId: 'investasi_lanjutan',
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.textContaining('Kuis'), findsWidgets);
      await bongkarWidget(tester);
    });

    testWidgets('9. Aksesibilitas Skala Teks 2.0 pada 360x640: Bebas RenderFlex Overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final pel13 = muatPelajaranLocal('investasi_lanjutan', 'investasi_lanjutan_13_1');

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
                modulId: 'investasi_lanjutan',
                pelajaranId: 'investasi_lanjutan_13_1',
                pelajaranOverride: pel13,
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
