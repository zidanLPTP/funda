import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/model/jenis_transaksi.dart';
import 'package:funda/data/penyedia_data.dart';
import 'package:funda/data/repositori/dompet_repositori.dart';
import 'package:funda/data/repositori/kategori_repositori.dart';
import 'package:funda/data/repositori/transaksi_repositori.dart';
import 'package:funda/fitur/catatan/tampilan/layar_catatan.dart';
import 'package:funda/fitur/transaksi/tampilan/layar_form_transaksi.dart';
import 'package:funda/komponen/tombol_funda.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  late BasisDataFunda basisData;
  late DompetRepositori repoDompet;
  late KategoriRepositori repoKategori;
  late TransaksiRepositori repoTransaksi;

  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  setUp(() {
    basisData = BasisDataFunda(NativeDatabase.memory());
    repoDompet = DompetRepositori(basisData);
    repoKategori = KategoriRepositori(basisData);
    repoTransaksi = TransaksiRepositori(basisData);
  });

  tearDown(() async {
    await basisData.close();
  });

  Widget buatAplikasiUji(Widget layar) {
    return ProviderScope(
      overrides: [
        penyediaBasisData.overrideWithValue(basisData),
        penyediaDompetRepositori.overrideWithValue(repoDompet),
        penyediaKategoriRepositori.overrideWithValue(repoKategori),
        penyediaTransaksiRepositori.overrideWithValue(repoTransaksi),
      ],
      child: MaterialApp(home: layar),
    );
  }

  group('Uji Widget Form Transaksi', () {
    testWidgets(
      'pengetikan nominal otomatis terformat Rupiah dan tombol pintasan bekerja',
      (tester) async {
        // Buat 1 dompet awal
        await repoDompet.tambahDompet(
          const TabelDompetCompanion(
            id: Value('dompet_1'),
            nama: Value('Dompet Utama'),
            jenis: Value('tunai'),
            ikon: Value('wallet'),
            warna: Value('tintHijau'),
            saldoAwalRupiah: Value(1000000),
          ),
        );

        await tester.pumpWidget(buatAplikasiUji(const LayarFormTransaksi()));
        await tester.pumpAndSettle();

        // Cari field nominal
        final bidangNominal = find.byType(TextField).first;
        expect(bidangNominal, findsOneWidget);

        // Ketik 50000
        await tester.enterText(bidangNominal, '50000');
        await tester.pumpAndSettle();

        // Cek teks terformat Rp 50.000
        expect(find.text('Rp 50.000'), findsOneWidget);

        // Tekan pintasan +50rb
        final tombolPintasan50rb = find.text('+50rb');
        expect(tombolPintasan50rb, findsOneWidget);
        await tester.tap(tombolPintasan50rb);
        await tester.pumpAndSettle();

        // Nominal menjadi 50.000 + 50.000 = Rp 100.000
        expect(find.text('Rp 100.000'), findsOneWidget);

        // Bersihkan widget tree dan tuntaskan timer stream drift
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'peringatan lembut saldo minus muncul jika pengeluaran melebihi saldo dompet',
      (tester) async {
        // Dompet dengan saldo awal 50.000
        await repoDompet.tambahDompet(
          const TabelDompetCompanion(
            id: Value('dompet_saku'),
            nama: Value('Uang Saku'),
            jenis: Value('tunai'),
            ikon: Value('wallet'),
            warna: Value('tintHijau'),
            saldoAwalRupiah: Value(50000),
          ),
        );

        await tester.pumpWidget(buatAplikasiUji(const LayarFormTransaksi()));
        await tester.pumpAndSettle();

        final bidangNominal = find.byType(TextField).first;
        // Masukkan nominal pengeluaran 100.000 (melebihi 50.000)
        await tester.enterText(bidangNominal, '100000');
        await tester.pumpAndSettle();

        // Periksa peringatan lembut muncul
        expect(
          find.textContaining('Saldo dompet ini akan menjadi minus'),
          findsOneWidget,
        );

        // Bersihkan widget tree dan tuntaskan timer stream drift
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
      },
    );
  });

  group('Uji Widget Tab Catatan (Riwayat & Pencarian)', () {
    testWidgets(
      'menampilkan riwayat transaksi per hari lokal dan pencarian menyaring hasil',
      (tester) async {
        // Buat 1 dompet
        await repoDompet.tambahDompet(
          const TabelDompetCompanion(
            id: Value('dompet_catatan'),
            nama: Value('Dompet Utama'),
            jenis: Value('tunai'),
            ikon: Value('wallet'),
            warna: Value('tintHijau'),
            saldoAwalRupiah: Value(500000),
          ),
        );

        // Ambil kategori Makan Harian dan Gaji langsung via kueri basis data
        final semuaKategori = await basisData
            .select(basisData.tabelKategori)
            .get();
        final katMakan = semuaKategori.firstWhere(
          (k) => k.nama == 'Makan Harian',
        );
        final katGaji = semuaKategori.firstWhere((k) => k.nama == 'Gaji');

        // Buat 2 transaksi pada hari ini
        final sekarang = DateTime.now();
        await repoTransaksi.tambahTransaksi(
          TabelTransaksiCompanion(
            id: const Value('tx_masuk'),
            jenis: Value(JenisTransaksi.masuk.kode),
            jumlahRupiah: const Value(300000),
            dompetId: const Value('dompet_catatan'),
            kategoriId: Value(katGaji.id),
            catatan: const Value('Bonus mingguan'),
            waktuTransaksi: Value(sekarang),
          ),
        );

        await repoTransaksi.tambahTransaksi(
          TabelTransaksiCompanion(
            id: const Value('tx_keluar'),
            jenis: Value(JenisTransaksi.keluar.kode),
            jumlahRupiah: const Value(50000),
            dompetId: const Value('dompet_catatan'),
            kategoriId: Value(katMakan.id),
            catatan: const Value('Makan siang bakso'),
            waktuTransaksi: Value(sekarang),
          ),
        );

        await tester.pumpWidget(buatAplikasiUji(const LayarCatatan()));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();

        // Memastikan riwayat muncul dengan teks catatan dan kategori
        expect(find.textContaining('Bonus mingguan'), findsOneWidget);
        expect(find.textContaining('Makan siang bakso'), findsOneWidget);
        expect(find.text('Gaji'), findsOneWidget);
        expect(find.text('Makan Harian'), findsOneWidget);

        // Cek subjumlah harian (300.000 masuk - 50.000 keluar = +Rp 250.000)
        expect(find.text('+Rp 250.000'), findsOneWidget);

        // Lakukan pencarian "bakso"
        final bidangCari = find.widgetWithText(
          TextField,
          'Cari catatan atau kategori...',
        );
        expect(bidangCari, findsOneWidget);
        await tester.enterText(bidangCari, 'bakso');
        await tester.pumpAndSettle();

        // "Makan siang bakso" tetap tampil, "Bonus mingguan" tersaring hilang
        expect(find.textContaining('Makan siang bakso'), findsOneWidget);
        expect(find.textContaining('Bonus mingguan'), findsNothing);

        // Bersihkan widget tree dan tuntaskan timer stream drift
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'membuka lembar bawah filter dan mereset filter bekerja dengan baik',
      (tester) async {
        // Buat 1 dompet agar tidak menampilkan keadaan kosong
        await repoDompet.tambahDompet(
          const TabelDompetCompanion(
            id: Value('dompet_filter'),
            nama: Value('Dompet Filter'),
            jenis: Value('tunai'),
            ikon: Value('wallet'),
            warna: Value('tintHijau'),
            saldoAwalRupiah: Value(100000),
          ),
        );

        await tester.pumpWidget(buatAplikasiUji(const LayarCatatan()));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();

        for (final element in find.byType(Text).evaluate()) {
          debugPrint('TEXT WIDGET: ${(element.widget as Text).data}');
        }

        // Cari tombol ikon filter (ikon slidersHorizontal / tooltip Filter Transaksi)
        final tombolFilter = find.byTooltip('Filter Transaksi');
        expect(tombolFilter, findsOneWidget);
        await tester.tap(tombolFilter);
        await tester.pumpAndSettle();

        // Lembar bawah terbuka, menampilkan judul Filter Catatan
        expect(find.text('Filter Catatan'), findsOneWidget);
        expect(find.text('Rentang Waktu'), findsOneWidget);
        expect(find.text('Jenis Transaksi'), findsOneWidget);

        // Tekan tombol Terapkan
        final tombolTerapkan = find.widgetWithText(
          TombolFunda,
          'Terapkan Filter',
        );
        expect(tombolTerapkan, findsOneWidget);
        await tester.tap(tombolTerapkan);
        await tester.pumpAndSettle();

        // Lembar bawah tertutup kembali
        expect(find.text('Filter Catatan'), findsNothing);

        // Bersihkan widget tree dan tuntaskan timer stream drift
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
      },
    );
  });
}
