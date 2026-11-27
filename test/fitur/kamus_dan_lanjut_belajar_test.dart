@Timeout(Duration(seconds: 30))
library;

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/penyedia_data.dart';
import 'package:funda/fitur/belajar/kontroler/penyedia_belajar.dart';
import 'package:funda/fitur/belajar/model/pembaca_konten.dart';
import 'package:funda/fitur/belajar/tampilan/layar_belajar.dart';
import 'package:funda/fitur/kamus/tampilan/layar_kamus.dart';
import 'package:funda/komponen/komponen_funda.dart';
import 'package:funda/perhitungan/perhitungan_belajar.dart';
import 'package:funda/tema/tema.dart';
import 'package:go_router/go_router.dart';

import '../pembantu/pompa_uji.dart';

PelajaranKonten _buatPelajaran({
  required String id,
  required String modulId,
  required String judul,
  String pemantik = 'Pemantik singkat.',
  String isiKartu = 'Isi materi.',
}) {
  return PelajaranKonten(
    id: id,
    modulId: modulId,
    judul: judul,
    durasiMenit: 4,
    status: 'ditinjau',
    gerbang: const [],
    pemantik: pemantik,
    kartu: [KartuPelajaranKonten(judul: 'Konsep', isi: isiKartu)],
    cekPaham: const [],
    misi: const MisiKonten(
      tipe: 'ada_data',
      judul: 'Misi',
      deskripsi: 'Catat transaksi',
      perkiraanMenit: 2,
    ),
  );
}

ModulKonten _buatModul({
  required String id,
  required String judul,
  required int urutan,
  String tingkat = 'pemula',
}) {
  return ModulKonten(
    id: id,
    judul: judul,
    tingkat: tingkat,
    urutan: urutan,
    deskripsiSingkat: 'Deskripsi $judul',
    tersedia: true,
    gerbang: const [],
    daftarPelajaran: const [],
    kuis: const KuisKonten(jumlahSoal: 1, bankSoal: []),
  );
}

void main() {
  final kamusContoh = <String, IstilahKamus>{
    'arus kas': const IstilahKamus(
      istilah: 'arus kas',
      arti: 'Selisih uang masuk dan keluar.',
      contohRupiah: 'Masuk Rp3.000.000, keluar Rp2.400.000.',
    ),
    'keinginan': const IstilahKamus(
      istilah: 'keinginan',
      arti: 'Pengeluaran yang bisa ditunda atau dikurangi.',
      contohRupiah: 'Uang jajan kopi dan tiket konser.',
    ),
    'dividen': const IstilahKamus(
      istilah: 'dividen',
      arti: 'Pembagian laba perusahaan kepada pemegang saham.',
      contohRupiah: 'Dividen Rp150.000 per tahun.',
    ),
    'dompet': const IstilahKamus(
      istilah: 'dompet',
      arti: 'Tempat menyimpan dan mencatat sumber uangmu.',
      contohRupiah: 'Dompet Tunai atau Rekening Bank.',
    ),
    'surplus': const IstilahKamus(
      istilah: 'surplus',
      arti: 'Pemasukan lebih besar daripada pengeluaran.',
      contohRupiah: 'Surplus Rp500.000 bulan ini.',
    ),
    'defisit': const IstilahKamus(
      istilah: 'defisit',
      arti: 'Pengeluaran lebih besar daripada pemasukan.',
      contohRupiah: 'Defisit Rp200.000 bulan ini.',
    ),
    'cicilan': const IstilahKamus(
      istilah: 'cicilan',
      arti: 'Pembayaran utang secara berkala.',
      contohRupiah: 'Cicilan motor Rp750.000 per bulan.',
    ),
    'sifat pengeluaran': const IstilahKamus(
      istilah: 'sifat pengeluaran',
      arti: 'Pengelompokan kebutuhan, keinginan, tabungan, atau utang.',
      contohRupiah: 'Makan harian masuk kebutuhan.',
    ),
  };

  group('Logika Kamus Terbuka Bertahap', () {
    test(
      'hanya membuka istilah dari pelajaran yang sedang/selesai plus 5 istilah dasar saat Modul 1 terbuka',
      () {
        final modul1 = _buatModul(
          id: 'anggaran_arus_kas',
          judul: 'Anggaran & Arus Kas',
          urutan: 1,
        );
        final modul11 = _buatModul(
          id: 'investasi_dasar',
          judul: 'Investasi Dasar',
          urutan: 11,
          tingkat: 'menengah',
        );

        final pel1 = _buatPelajaran(
          id: 'anggaran_arus_kas_1_1',
          modulId: 'anggaran_arus_kas',
          judul: 'Ke Mana Uangku',
          isiKartu: 'Pahami {{arus kas}} terlebih dahulu.',
        );
        final pel2 = _buatPelajaran(
          id: 'anggaran_arus_kas_1_2',
          modulId: 'anggaran_arus_kas',
          judul: 'Kebutuhan vs Keinginan',
          isiKartu: 'Bedakan kebutuhan dan {{keinginan}}.',
        );
        final pel11 = _buatPelajaran(
          id: 'investasi_dasar_11_1',
          modulId: 'investasi_dasar',
          judul: 'Saham & Dividen',
          isiKartu: 'Kenali {{dividen}} sebelum berinvestasi.',
        );

        final peta = [
          ItemPetaModul(
            modul: modul1,
            statusModul: const HasilStatusBelajar(
              status: StatusBelajar.sedang,
              apaYangKurang: [],
            ),
            daftarPelajaran: [
              (
                pel1,
                const HasilStatusBelajar(
                  status: StatusBelajar.selesai,
                  apaYangKurang: [],
                ),
              ),
              (
                pel2,
                const HasilStatusBelajar(
                  status: StatusBelajar.terkunci,
                  apaYangKurang: ['Catat minimal 1 transaksi'],
                  ruteAksi: '/transaksi/baru',
                ),
              ),
            ],
          ),
          ItemPetaModul(
            modul: modul11,
            statusModul: const HasilStatusBelajar(
              status: StatusBelajar.terkunci,
              apaYangKurang: ['Selesaikan modul pemula'],
            ),
            daftarPelajaran: [
              (
                pel11,
                const HasilStatusBelajar(
                  status: StatusBelajar.terkunci,
                  apaYangKurang: ['Selesaikan modul pemula'],
                ),
              ),
            ],
          ),
        ];

        final ringkasan = hitungKamusTerbuka(kamus: kamusContoh, peta: peta);
        final daftarKunci = ringkasan.daftarTerbuka
            .map((e) => e.istilah.istilah)
            .toSet();

        expect(ringkasan.totalIstilah, equals(kamusContoh.length));
        expect(daftarKunci, contains('arus kas'));
        expect(
          daftarKunci,
          containsAll([
            'dompet',
            'surplus',
            'defisit',
            'cicilan',
            'sifat pengeluaran',
          ]),
        );
        // Istilah dari pelajaran terkunci dan modul lanjutan tidak boleh muncul
        expect(daftarKunci, isNot(contains('keinginan')));
        expect(daftarKunci, isNot(contains('dividen')));
      },
    );

    test(
      'filterKamusTerbuka mencari berdasarkan nama istilah, arti, maupun contohRupiah',
      () {
        final entri = kamusContoh.values
            .map((i) => EntriKamusTerbuka(istilah: i, sumberModul: 'Modul 1'))
            .toList();

        final cariJajan = filterKamusTerbuka(entri, 'jajan');
        expect(cariJajan.map((e) => e.istilah.istilah), contains('keinginan'));

        final cariArti = filterKamusTerbuka(entri, 'berkala');
        expect(cariArti.map((e) => e.istilah.istilah), contains('cicilan'));
      },
    );
  });

  group('Widget LayarKamus & Kartu Lanjut Belajar', () {
    testWidgets(
      'LayarKamus menampilkan istilah terbuka dan menyaring pencarian',
      (tester) async {
        final ringkasan = RingkasanKamusTerbuka(
          daftarTerbuka: [
            EntriKamusTerbuka(
              istilah: kamusContoh['arus kas']!,
              sumberModul: 'Modul 1 · Anggaran & Arus Kas',
            ),
            EntriKamusTerbuka(
              istilah: kamusContoh['keinginan']!,
              sumberModul: 'Modul 1 · Anggaran & Arus Kas',
            ),
          ],
          totalIstilah: 93,
        );

        final db = BasisDataFunda(NativeDatabase.memory());
        addTearDown(db.close);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              penyediaBasisData.overrideWithValue(db),
              penyediaTanpaAnimasi.overrideWithValue(true),
              penyediaKamusTerbuka.overrideWith((ref) async => ringkasan),
            ],
            child: MaterialApp(
              theme: TemaFunda.temaTerang,
              home: const LayarKamus(),
            ),
          ),
        );
        await pompaHinggaAda(tester, find.byKey(const Key('kolom_cari_kamus')));

        expect(
          find.text('2 dari 93 istilah terbuka sesuai progres belajarmu'),
          findsOneWidget,
        );
        expect(find.text('Arus kas'), findsOneWidget);
        expect(find.text('Keinginan'), findsOneWidget);

        // Cari lewat contoh ("jajan") -> hanya Keinginan yang tersisa
        await tester.enterText(
          find.byKey(const Key('kolom_cari_kamus')),
          'jajan',
        );
        await tester.pump();

        expect(find.text('Keinginan'), findsOneWidget);
        expect(find.text('Arus kas'), findsNothing);

        await bongkarWidget(tester);
      },
    );

    testWidgets(
      'LayarBelajar tidak mengembalikan ke pelajaran selesai saat pelajaran berikutnya terkunci gerbang data',
      (tester) async {
        final modul1 = _buatModul(
          id: 'anggaran_arus_kas',
          judul: 'Anggaran & Arus Kas',
          urutan: 1,
        );
        final pel1 = _buatPelajaran(
          id: 'anggaran_arus_kas_1_1',
          modulId: 'anggaran_arus_kas',
          judul: 'Ke Mana Uangku',
        );
        final pel2 = _buatPelajaran(
          id: 'anggaran_arus_kas_1_2',
          modulId: 'anggaran_arus_kas',
          judul: 'Peta Arus Kas',
        );

        final peta = [
          ItemPetaModul(
            modul: modul1,
            statusModul: const HasilStatusBelajar(
              status: StatusBelajar.sedang,
              apaYangKurang: [],
            ),
            daftarPelajaran: [
              (
                pel1,
                const HasilStatusBelajar(
                  status: StatusBelajar.selesai,
                  apaYangKurang: [],
                ),
              ),
              (
                pel2,
                const HasilStatusBelajar(
                  status: StatusBelajar.terkunci,
                  apaYangKurang: ['Catat minimal 1 transaksi pengeluaran'],
                  ruteAksi: '/transaksi/baru',
                ),
              ),
            ],
          ),
        ];

        final rekomendasi = [
          InfoRekomendasiModul(
            modul: modul1,
            judulAlasan: 'Langkah Awal',
            deskripsiAlasan: 'Mulai pahami arus kasmu.',
            statusModul: const HasilStatusBelajar(
              status: StatusBelajar.sedang,
              apaYangKurang: [],
            ),
          ),
        ];

        String? ruteDikunjungi;
        final router = GoRouter(
          initialLocation: '/belajar',
          routes: [
            GoRoute(path: '/belajar', builder: (_, _) => const LayarBelajar()),
            GoRoute(
              path: '/transaksi/baru',
              builder: (_, _) {
                ruteDikunjungi = '/transaksi/baru';
                return const Scaffold(body: Text('Halaman Tambah Transaksi'));
              },
            ),
          ],
        );

        final db = BasisDataFunda(NativeDatabase.memory());
        addTearDown(db.close);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              penyediaBasisData.overrideWithValue(db),
              penyediaTanpaAnimasi.overrideWithValue(true),
              penyediaStreamProfilKeuangan.overrideWith(
                (ref) => Stream.value(
                  EntitasProfilKeuangan(
                    id: 1,
                    punyaPenghasilan: 'ya',
                    punyaUtang: 'tidak',
                    danaDarurat: 'belum',
                    menabung: 'jarang',
                    investasi: 'belum',
                    mencatatKeuangan: 'belum',
                    tujuanUtama: 'atur_arus_kas',
                    diisiPada: DateTime(2026, 1, 1),
                    diperbaruiPada: DateTime(2026, 1, 1),
                  ),
                ),
              ),
              penyediaPetaBelajar.overrideWith((ref) async => peta),
              penyediaDaftarRekomendasiModul.overrideWith(
                (ref) async => rekomendasi,
              ),
            ],
            child: MaterialApp.router(
              theme: TemaFunda.temaTerang,
              routerConfig: router,
            ),
          ),
        );
        await pompaHinggaAda(
          tester,
          find.byKey(const Key('kartu_sorotan_rekomendasi')),
        );

        expect(find.text('Isi Data & Lanjut'), findsOneWidget);
        expect(find.text('Lanjut Belajar'), findsNothing);
        expect(
          find.textContaining('Catat minimal 1 transaksi pengeluaran'),
          findsOneWidget,
        );

        await tester.tap(find.text('Isi Data & Lanjut'));
        await pompaHinggaAda(tester, find.text('Halaman Tambah Transaksi'));

        expect(ruteDikunjungi, equals('/transaksi/baru'));

        await bongkarWidget(tester);
      },
    );
  });
}
