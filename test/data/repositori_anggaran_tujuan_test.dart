import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/model/jenis_alokasi.dart';
import 'package:funda/data/model/jenis_dompet.dart';
import 'package:funda/data/model/jenis_tujuan.dart';
import 'package:funda/data/model/status_tujuan.dart';
import 'package:funda/data/repositori/anggaran_repositori.dart';
import 'package:funda/data/repositori/dompet_repositori.dart';
import 'package:funda/data/repositori/kantong_repositori.dart';
import 'package:funda/data/repositori/transaksi_repositori.dart';
import 'package:funda/data/repositori/tujuan_repositori.dart';

void main() {
  late BasisDataFunda db;
  late DompetRepositori repoDompet;
  late TransaksiRepositori repoTransaksi;
  late AnggaranRepositori repoAnggaran;
  late TujuanRepositori repoTujuan;
  late KantongRepositori repoKantong;

  setUp(() {
    db = BasisDataFunda(NativeDatabase.memory());
    repoDompet = DompetRepositori(db);
    repoTransaksi = TransaksiRepositori(db);
    repoAnggaran = AnggaranRepositori(db, repoTransaksi);
    repoTujuan = TujuanRepositori(db);
    repoKantong = KantongRepositori(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('TujuanRepositori Integritas', () {
    test('hanya satu tujuan dana_darurat aktif yang diperbolehkan', () async {
      final sekarang = DateTime.now();

      // Tambah tujuan dana darurat pertama (aktif)
      await repoTujuan.tambahTujuan(
        TabelTujuanCompanion(
          id: const Value('tujuan_dd_1'),
          nama: const Value('Dana Darurat 6 Bulan'),
          jenis: Value(JenisTujuan.danaDarurat.kode),
          targetRupiah: const Value(30000000),
          ikon: const Value('shieldCheck'),
          warna: const Value('tintBiru'),
          status: Value(StatusTujuan.aktif.kode),
          dibuatPada: Value(sekarang),
        ),
      );

      // Coba tambah tujuan dana darurat kedua (aktif) -> harus ditolak
      expect(
        () => repoTujuan.tambahTujuan(
          TabelTujuanCompanion(
            id: const Value('tujuan_dd_2'),
            nama: const Value('Dana Darurat Cadangan'),
            jenis: Value(JenisTujuan.danaDarurat.kode),
            targetRupiah: const Value(10000000),
            ikon: const Value('shieldCheck'),
            warna: const Value('tintBiru'),
            status: Value(StatusTujuan.aktif.kode),
            dibuatPada: Value(sekarang),
          ),
        ),
        throwsA(isA<StateError>()),
      );

      // Bila tujuan pertama diarsipkan, tujuan dana darurat baru boleh ditambahkan
      await repoTujuan.ubahStatusTujuan('tujuan_dd_1', StatusTujuan.diarsipkan);

      await expectLater(
        repoTujuan.tambahTujuan(
          TabelTujuanCompanion(
            id: const Value('tujuan_dd_2'),
            nama: const Value('Dana Darurat Baru'),
            jenis: Value(JenisTujuan.danaDarurat.kode),
            targetRupiah: const Value(15000000),
            ikon: const Value('shieldCheck'),
            warna: const Value('tintBiru'),
            status: Value(StatusTujuan.aktif.kode),
            dibuatPada: Value(sekarang),
          ),
        ),
        completes,
      );
    });
  });

  group('KantongRepositori Integritas', () {
    test(
      'menolak penambahan kantong dengan dompet_id dan tujuan_id yang sama',
      () async {
        final sekarang = DateTime.now();

        // Buat dompet & tujuan
        await repoDompet.tambahDompet(
          TabelDompetCompanion(
            id: const Value('dompet_k'),
            nama: const Value('Dompet Tabungan'),
            jenis: Value(JenisDompet.rekeningBank.name),
            ikon: const Value('wallet'),
            warna: const Value('tintHijau'),
            saldoAwalRupiah: const Value(5000000),
          ),
        );

        await repoTujuan.tambahTujuan(
          TabelTujuanCompanion(
            id: const Value('tujuan_laptop'),
            nama: const Value('Beli Laptop'),
            jenis: Value(JenisTujuan.tujuanBesar.kode),
            targetRupiah: const Value(15000000),
            ikon: const Value('laptop'),
            warna: const Value('tintUngu'),
            status: Value(StatusTujuan.aktif.kode),
            dibuatPada: Value(sekarang),
          ),
        );

        // Tambah kantong pertama
        await repoKantong.tambahKantong(
          TabelKantongCompanion(
            id: const Value('kantong_1'),
            dompetId: const Value('dompet_k'),
            tujuanId: const Value('tujuan_laptop'),
            nama: const Value('Alokasi Laptop BCA'),
            ikon: const Value('laptop'),
            warna: const Value('tintUngu'),
            dibuatPada: Value(sekarang),
          ),
        );

        // Coba tambah kantong kedua untuk tujuan yang sama di dompet yang sama -> tolak
        expect(
          () => repoKantong.tambahKantong(
            TabelKantongCompanion(
              id: const Value('kantong_2'),
              dompetId: const Value('dompet_k'),
              tujuanId: const Value('tujuan_laptop'),
              nama: const Value('Alokasi Laptop Duplikat'),
              ikon: const Value('laptop'),
              warna: const Value('tintUngu'),
              dibuatPada: Value(sekarang),
            ),
          ),
          throwsA(isA<StateError>()),
        );
      },
    );

    test('alokasi kantong: tolak pengambilan melebihi saldo kantong', () async {
      final sekarang = DateTime.now();

      await repoDompet.tambahDompet(
        TabelDompetCompanion(
          id: const Value('dompet_alokasi'),
          nama: const Value('Dompet Alokasi'),
          jenis: Value(JenisDompet.tunai.name),
          ikon: const Value('wallet'),
          warna: const Value('tintHijau'),
          saldoAwalRupiah: const Value(1000000),
        ),
      );

      await repoKantong.tambahKantong(
        TabelKantongCompanion(
          id: const Value('kantong_liburan'),
          dompetId: const Value('dompet_alokasi'),
          nama: const Value('Liburan Akhir Tahun'),
          ikon: const Value('plane'),
          warna: const Value('tintKuning'),
          dibuatPada: Value(sekarang),
        ),
      );

      // Isi kantong 300.000
      await repoKantong.tambahAlokasiKantong(
        TabelAlokasiKantongCompanion(
          id: const Value('alokasi_isi_1'),
          kantongId: const Value('kantong_liburan'),
          jenis: Value(JenisAlokasi.isi.kode),
          jumlahRupiah: const Value(300000),
          waktu: Value(sekarang),
          dibuatPada: Value(sekarang),
        ),
      );

      final saldoSetelahIsi = await repoKantong.hitungSaldoKantongSQL(
        'kantong_liburan',
      );
      expect(saldoSetelahIsi, equals(300000));

      // Coba ambil 400.000 (melebihi 300.000) -> harus ditolak
      expect(
        () => repoKantong.tambahAlokasiKantong(
          TabelAlokasiKantongCompanion(
            id: const Value('alokasi_ambil_gagal'),
            kantongId: const Value('kantong_liburan'),
            jenis: Value(JenisAlokasi.ambil.kode),
            jumlahRupiah: const Value(400000),
            waktu: Value(sekarang),
            dibuatPada: Value(sekarang),
          ),
        ),
        throwsA(isA<ArgumentError>()),
      );

      // Ambil 200.000 -> berhasil, saldo jadi 100.000
      await repoKantong.tambahAlokasiKantong(
        TabelAlokasiKantongCompanion(
          id: const Value('alokasi_ambil_sukses'),
          kantongId: const Value('kantong_liburan'),
          jenis: Value(JenisAlokasi.ambil.kode),
          jumlahRupiah: const Value(200000),
          waktu: Value(sekarang),
          dibuatPada: Value(sekarang),
        ),
      );

      final saldoAkhir = await repoKantong.hitungSaldoKantongSQL(
        'kantong_liburan',
      );
      expect(saldoAkhir, equals(100000));
    });

    test('kantong hanya dapat diarsipkan jika saldonya Rp 0', () async {
      final sekarang = DateTime.now();

      await repoDompet.tambahDompet(
        TabelDompetCompanion(
          id: const Value('dompet_arsip_k'),
          nama: const Value('Dompet'),
          jenis: Value(JenisDompet.tunai.name),
          ikon: const Value('wallet'),
          warna: const Value('tintHijau'),
          saldoAwalRupiah: const Value(1000000),
        ),
      );

      await repoKantong.tambahKantong(
        TabelKantongCompanion(
          id: const Value('kantong_berisi'),
          dompetId: const Value('dompet_arsip_k'),
          nama: const Value('Kantong Uji'),
          ikon: const Value('tag'),
          warna: const Value('tintBiru'),
          dibuatPada: Value(sekarang),
        ),
      );

      // Isi kantong 50.000
      await repoKantong.tambahAlokasiKantong(
        TabelAlokasiKantongCompanion(
          id: const Value('alokasi_isi_arsip'),
          kantongId: const Value('kantong_berisi'),
          jenis: Value(JenisAlokasi.isi.kode),
          jumlahRupiah: const Value(50000),
          waktu: Value(sekarang),
          dibuatPada: Value(sekarang),
        ),
      );

      // Coba arsipkan saat saldo masih 50.000 -> harus ditolak
      expect(
        () => repoKantong.arsipkanKantong('kantong_berisi'),
        throwsA(isA<StateError>()),
      );

      // Ambil sisa 50.000 sehingga saldo kantong jadi 0
      await repoKantong.tambahAlokasiKantong(
        TabelAlokasiKantongCompanion(
          id: const Value('alokasi_ambil_habis'),
          kantongId: const Value('kantong_berisi'),
          jenis: Value(JenisAlokasi.ambil.kode),
          jumlahRupiah: const Value(50000),
          waktu: Value(sekarang),
          dibuatPada: Value(sekarang),
        ),
      );

      // Sekarang arsipkan -> harus sukses
      final sukses = await repoKantong.arsipkanKantong('kantong_berisi');
      expect(sukses, isTrue);

      final kantongData = await repoKantong.ambilKantongBerdasarkanId(
        'kantong_berisi',
      );
      expect(kantongData!.diarsipkan, isTrue);
    });
  });

  group('AnggaranRepositori & Salin Anggaran', () {
    test(
      'anggaran unik per kategori per bulan dan salin dari bulan lalu bekerja',
      () async {
        final kategoriList = await db.select(db.tabelKategori).get();
        final katMakan = kategoriList.firstWhere(
          (k) => k.nama == 'Makan Harian',
        );
        final katTrans = kategoriList.firstWhere(
          (k) => k.nama == 'Transportasi',
        );

        final sekarang = DateTime.now();

        // Simpan anggaran Januari 2026
        await repoAnggaran.simpanAtauPerbaruiAnggaran(
          TabelAnggaranCompanion(
            id: const Value('ang_jan_makan'),
            tahun: const Value(2026),
            bulan: const Value(1),
            kategoriId: Value(katMakan.id),
            batasRupiah: const Value(1500000),
            dibuatPada: Value(sekarang),
            diubahPada: Value(sekarang),
          ),
        );

        await repoAnggaran.simpanAtauPerbaruiAnggaran(
          TabelAnggaranCompanion(
            id: const Value('ang_jan_trans'),
            tahun: const Value(2026),
            bulan: const Value(1),
            kategoriId: Value(katTrans.id),
            batasRupiah: const Value(500000),
            dibuatPada: Value(sekarang),
            diubahPada: Value(sekarang),
          ),
        );

        // Verifikasi anggaran Januari ada 2
        final daftarJan = await repoAnggaran.ambilAnggaranBulan(2026, 1);
        expect(daftarJan.length, equals(2));

        // Salin dari Januari 2026 ke Februari 2026
        final disalin = await repoAnggaran.salinAnggaranDariBulanLalu(
          tahunTujuan: 2026,
          bulanTujuan: 2,
        );
        expect(disalin, equals(2));

        // Verifikasi Februari memuat anggaran yang sama
        final daftarFeb = await repoAnggaran.ambilAnggaranBulan(2026, 2);
        expect(daftarFeb.length, equals(2));
        expect(
          daftarFeb.any(
            (a) => a.kategoriId == katMakan.id && a.batasRupiah == 1500000,
          ),
          isTrue,
        );
        expect(
          daftarFeb.any(
            (a) => a.kategoriId == katTrans.id && a.batasRupiah == 500000,
          ),
          isTrue,
        );

        // Uji kasus khusus 0(e): Bulan tujuan sudah punya sebagian anggaran
        // Misal di Maret 2026, pengguna sudah atur anggaran Makan Harian Rp 2.000.000
        await repoAnggaran.simpanAtauPerbaruiAnggaran(
          TabelAnggaranCompanion(
            id: Value('ang_2026_3_${katMakan.id}'),
            tahun: const Value(2026),
            bulan: const Value(3),
            kategoriId: Value(katMakan.id),
            batasRupiah: const Value(2000000),
            dibuatPada: Value(sekarang),
            diubahPada: Value(sekarang),
          ),
        );

        // Salin dari Februari 2026 ke Maret 2026
        final disalinKeMaret = await repoAnggaran.salinAnggaranDariBulanLalu(
          tahunTujuan: 2026,
          bulanTujuan: 3,
        );

        // Hanya 1 kategori yang disalin (Transportasi), Makan Harian tidak ditimpa
        expect(disalinKeMaret, equals(1));

        final daftarMaret = await repoAnggaran.ambilAnggaranBulan(2026, 3);
        expect(daftarMaret.length, equals(2));
        final makanMaret = daftarMaret.firstWhere(
          (a) => a.kategoriId == katMakan.id,
        );
        expect(
          makanMaret.batasRupiah,
          equals(2000000),
        ); // Tetap Rp 2.000.000, tidak tertimpa
        final transMaret = daftarMaret.firstWhere(
          (a) => a.kategoriId == katTrans.id,
        );
        expect(
          transMaret.batasRupiah,
          equals(500000),
        ); // Disalin dari bulan lalu

        // Jika disalin lagi saat semua kategori sudah ada, hasilnya 0 disalin
        final disalinLagi = await repoAnggaran.salinAnggaranDariBulanLalu(
          tahunTujuan: 2026,
          bulanTujuan: 3,
        );
        expect(disalinLagi, equals(0));
      },
    );
  });
}
