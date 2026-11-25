@Timeout(Duration(seconds: 30))
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/aplikasi/rute.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/penyedia_data.dart';
import 'package:funda/fitur/belajar/kontroler/penyedia_belajar.dart';
import 'package:funda/fitur/belajar/model/pembaca_konten.dart';
import 'package:funda/fitur/belajar/tampilan/layar_belajar.dart';
import 'package:funda/fitur/belajar/tampilan/layar_pemutar_pelajaran.dart';
import 'package:funda/fitur/beranda/tampilan/layar_beranda.dart';
import 'package:funda/fitur/catatan/tampilan/layar_catatan.dart';
import 'package:funda/fitur/lainnya/tampilan/layar_lainnya.dart';
import 'package:funda/fitur/transaksi/tampilan/layar_form_transaksi.dart';
import 'package:funda/komponen/efek_perayaan.dart';
import 'package:funda/komponen/indikator_memuat.dart';
import 'package:funda/perhitungan/perhitungan_belajar.dart';
import 'package:funda/tema/tema.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' as drift;
import '../pembantu/pompa_uji.dart';

void main() {
  late BasisDataFunda db;

  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  setUp(() async {
    db = BasisDataFunda(NativeDatabase.memory());
    // Anggap tutorial Beranda sudah selesai saat menguji regresi navigasi tab
    await db.simpanPengaturan('tutorial_beranda_selesai', 'true');
  });

  tearDown(() async {
    await db.close();
  });

  Widget bangunAplikasiUji({Widget? home, List<dynamic> overrides = const []}) {
    return ProviderScope(
      overrides: [
        penyediaBasisData.overrideWithValue(db),
        penyediaTanpaAnimasi.overrideWithValue(true),
        penyediaFotoData.overrideWith(
          (ref) => Future.value(FotoDataPengguna.kosong()),
        ),
        penyediaKamus.overrideWith(
          (ref) => Future.value(<String, IstilahKamus>{}),
        ),
        penyediaDaftarDompetAktif.overrideWith(
          (ref) => Stream.value([
            EntitasDompet(
              id: 'dompet-utama',
              nama: 'Dompet Utama',
              jenis: 'tunai',
              ikon: 'wallet',
              warna: 'tintNetral',
              saldoAwalRupiah: 1000000,
              urutan: 0,
              diarsipkan: false,
              dibuatPada: DateTime.now(),
            ),
          ]),
        ),
        penyediaDaftarDompet.overrideWith(
          (ref) => Stream.value([
            EntitasDompet(
              id: 'dompet-utama',
              nama: 'Dompet Utama',
              jenis: 'tunai',
              ikon: 'wallet',
              warna: 'tintNetral',
              saldoAwalRupiah: 1000000,
              urutan: 0,
              diarsipkan: false,
              dibuatPada: DateTime.now(),
            ),
          ]),
        ),
        penyediaDaftarKategori.overrideWith(
          (ref) => Stream.value([
            const EntitasKategori(
              id: 'kat-1',
              nama: 'Makanan',
              arus: 'keluar',
              sifat: 'kebutuhan',
              ikon: 'utensils',
              bawaan: true,
              diarsipkan: false,
            ),
          ]),
        ),
        ...overrides,
      ],
      child: home != null
          ? MaterialApp(theme: TemaFunda.temaTerang, home: home)
          : MaterialApp.router(
              theme: TemaFunda.temaTerang,
              routerConfig: ruteFunda,
            ),
    );
  }

  group('Uji Regresi Navigasi & Layar Catatan Tahap 13A', () {
    testWidgets(
      '1. Dari Layar Pemutar Pelajaran -> klik "Kerjakan Sekarang" -> membuka form catat transaksi utuh (tidak kosong)',
      (tester) async {
        final pel = PelajaranKonten(
          id: 'anggaran_arus_kas_1_1',
          modulId: 'anggaran_arus_kas',
          judul: 'Uji Misi Transaksi',
          durasiMenit: 3,
          status: 'draf',
          gerbang: const [],
          pemantik: 'Pengantar materi arus kas.',
          kartu: const [
            KartuPelajaranKonten(
              judul: 'Konsep Dasar',
              isi: 'Penjelasan konsep.',
            ),
          ],
          cekPaham: const [],
          misi: const MisiKonten(
            tipe: 'ada_data',
            objek: 'pengeluaran',
            min: 1,
            judul: 'Catat satu pengeluaranmu',
            deskripsi: 'Buka Catatan, lalu catat satu pengeluaran terakhirmu.',
            perkiraanMenit: 2,
          ),
        );

        await tester.pumpWidget(
          bangunAplikasiUji(
            home: LayarPemutarPelajaran(
              modulId: 'anggaran_arus_kas',
              pelajaranId: pel.id,
              pelajaranOverride: pel,
            ),
          ),
        );
        await tester.pump();

        // Langkah 0 (Pemantik) -> Tekan Lanjut -> Langkah 1 (Kartu)
        await tester.tap(find.byKey(const Key('tombol_lanjut')));
        await tester.pump();

        // Langkah 1 (Kartu) -> Tekan Lanjut -> Langkah 2 (Misi Praktik, karena cekPaham kosong)
        await tester.tap(find.byKey(const Key('tombol_lanjut')));
        await tester.pump();

        expect(find.byKey(const Key('tombol_kerjakan_misi')), findsOneWidget);

        // Ketuk "Kerjakan Sekarang"
        await tester.tap(find.byKey(const Key('tombol_kerjakan_misi')));
        await pompaHinggaAda(tester, find.byType(LayarFormTransaksi));

        // Form catat transaksi tampil utuh dan TIDAK kosong
        expect(find.byType(LayarFormTransaksi), findsOneWidget);
        expect(find.text('Catat Transaksi'), findsOneWidget);
        expect(find.text('Simpan Transaksi'), findsOneWidget);

        // Lepas pohon widget sebelum teardown
        await bongkarWidget(tester);
      },
    );

    testWidgets(
      '2. Dari Beranda -> klik tab Catatan -> benar-benar menampilkan LayarCatatan',
      (tester) async {
        await tester.pumpWidget(
          bangunAplikasiUji(
            overrides: [
              penyediaTransaksiBerhalaman(
                const ParameterKueriTransaksi(),
              ).overrideWith((ref) => Stream.value([])),
            ],
          ),
        );
        ruteFunda.go('/');
        await tester.pump();

        // Awal di Beranda
        expect(find.byType(LayarBeranda), findsOneWidget);

        // Klik tab Catatan (indeks 1)
        await tester.tap(find.text('Catatan'));
        await pompaHinggaAda(tester, find.byType(LayarCatatan));

        // Harus menampilkan LayarCatatan
        expect(find.byType(LayarCatatan), findsOneWidget);

        // Lepas pohon widget sebelum teardown
        await bongkarWidget(tester);
      },
    );

    testWidgets(
      '2b. Alur menyelesaikan kuis modul -> kembali ke Beranda -> klik tab Catatan -> benar-benar menampilkan LayarCatatan (tidak lempar ke Beranda)',
      (tester) async {
        // Simpan hasil kuis modul 1 ke db
        await db
            .into(db.tabelHasilKuis)
            .insert(
              TabelHasilKuisCompanion(
                modulId: const drift.Value('anggaran_arus_kas'),
                skorPersen: const drift.Value(100),
                benar: const drift.Value(5),
                total: const drift.Value(5),
                lulus: const drift.Value(true),
                waktu: drift.Value(DateTime.now().toUtc()),
              ),
            );

        await tester.pumpWidget(
          bangunAplikasiUji(
            overrides: [
              penyediaTransaksiBerhalaman(
                const ParameterKueriTransaksi(),
              ).overrideWith((ref) => Stream.value([])),
            ],
          ),
        );
        ruteFunda.go('/');
        await tester.pump();

        // Tampil di Beranda
        expect(find.byType(LayarBeranda), findsOneWidget);

        // Klik tab Catatan
        await tester.tap(find.text('Catatan'));
        await pompaHinggaAda(tester, find.byType(LayarCatatan));

        // Harus menampilkan LayarCatatan
        expect(find.byType(LayarCatatan), findsOneWidget);

        // Lepas pohon widget sebelum teardown
        await bongkarWidget(tester);
      },
    );

    testWidgets(
      '3. Dari tab Belajar -> klik tab Catatan -> tampil LayarCatatan (tidak lempar ke Beranda)',
      (tester) async {
        await tester.pumpWidget(
          bangunAplikasiUji(
            overrides: [
              penyediaPetaBelajar.overrideWith((ref) => Future.value([])),
              penyediaTransaksiBerhalaman(
                const ParameterKueriTransaksi(),
              ).overrideWith((ref) => Stream.value([])),
            ],
          ),
        );
        await tester.pump();

        // Pindah ke tab Belajar
        await tester.tap(find.text('Belajar'));
        await pompaHinggaAda(tester, find.byType(LayarBelajar));
        expect(find.byType(LayarBelajar), findsOneWidget);

        // Pindah dari Belajar ke Catatan
        await tester.tap(find.text('Catatan'));
        await pompaHinggaAda(tester, find.byType(LayarCatatan));

        // Harus menampilkan LayarCatatan, BUKAN LayarBeranda
        expect(find.byType(LayarCatatan), findsOneWidget);

        // Lepas pohon widget sebelum teardown
        await bongkarWidget(tester);
      },
    );

    testWidgets(
      '4. Dari tab Lainnya -> klik tab Catatan -> tampil LayarCatatan (tidak lempar ke Beranda)',
      (tester) async {
        await tester.pumpWidget(
          bangunAplikasiUji(
            overrides: [
              penyediaTransaksiBerhalaman(
                const ParameterKueriTransaksi(),
              ).overrideWith((ref) => Stream.value([])),
            ],
          ),
        );
        await tester.pump();

        // Pindah ke tab Lainnya
        await tester.tap(find.text('Lainnya'));
        await pompaHinggaAda(tester, find.byType(LayarLainnya));
        expect(find.byType(LayarLainnya), findsOneWidget);

        // Pindah dari Lainnya ke Catatan
        await tester.tap(find.text('Catatan'));
        await pompaHinggaAda(tester, find.byType(LayarCatatan));

        // Harus menampilkan LayarCatatan
        expect(find.byType(LayarCatatan), findsOneWidget);

        // Lepas pohon widget sebelum teardown
        await bongkarWidget(tester);
      },
    );

    testWidgets(
      '5. Verifikasi Efek Perayaan tidak bocor OverlayEntry saat dispose sebelum animasi selesai',
      (tester) async {
        late BuildContext savedContext;
        await tester.pumpWidget(
          MaterialApp(
            theme: TemaFunda.temaTerang,
            home: Builder(
              builder: (ctx) {
                savedContext = ctx;
                return const Scaffold(body: Text('Layar Uji'));
              },
            ),
          ),
        );
        await tester.pump();

        // Panggil efek perayaan
        tampilkanEfekPerayaan(savedContext);
        await tester.pump();

        // Unmount widget sebelum durasi 1800ms selesai
        await bongkarWidget(tester);

        // Tidak boleh ada error atau assertion failure pada timer
      },
    );
  });
}
