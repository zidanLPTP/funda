import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/model/arah_penyesuaian_utang.dart';
import 'package:funda/data/model/jenis_dompet.dart';
import 'package:funda/data/model/jenis_utang.dart';
import 'package:funda/data/repositori/dompet_repositori.dart';
import 'package:funda/data/repositori/kategori_repositori.dart';
import 'package:funda/data/repositori/transaksi_repositori.dart';
import 'package:funda/data/repositori/utang_repositori.dart';
import 'package:funda/perhitungan/perhitungan_utang_dashboard.dart';

void main() {
  late BasisDataFunda basisData;
  late DompetRepositori repoDompet;
  late KategoriRepositori repoKategori;
  late TransaksiRepositori repoTransaksi;
  late UtangRepositori repoUtang;

  setUp(() async {
    basisData = BasisDataFunda(NativeDatabase.memory());
    repoDompet = DompetRepositori(basisData);
    repoKategori = KategoriRepositori(basisData);
    repoTransaksi = TransaksiRepositori(basisData);
    repoUtang = UtangRepositori(basisData);
  });

  tearDown(() async {
    await basisData.close();
  });

  group('UtangRepositori Operasi & Integritas', () {
    test(
      'tambah utang, catat pembayaran atomik, dan periksa sisa utang berkurang',
      () async {
        // 1. Buat dompet dengan saldo 10jt
        final dompetId = await repoDompet.buatDompet(
          nama: 'BCA Utama',
          jenis: JenisDompet.rekeningBank.kode,
          ikon: 'landmark',
          warna: 'biru',
          saldoAwalRupiah: 10000000,
        );

        // Kategori cicilan
        final daftarKategori = await repoKategori.ambilSemuaKategori();
        final katCicilan = daftarKategori.firstWhere(
          (k) => k.nama == 'Cicilan',
        );
        expect(katCicilan, isNotNull);

        // 2. Buat utang cicilan sisa 5.000.000
        final utangId = await repoUtang.buatUtang(
          nama: 'Cicilan Laptop',
          jenis: JenisUtang.cicilan.kode,
          sisaAwalRupiah: 5000000,
          cicilanBulananRupiah: 1000000,
          jenisBunga: 'flat',
          bungaBasisPoinPerTahun: 500, // 5%
        );

        expect(await repoUtang.hitungSisaUtangSQL(utangId), equals(5000000));

        // 3. Catat pembayaran 1.000.000
        final trxId = await repoUtang.catatPembayaranUtang(
          utangId: utangId,
          dompetId: dompetId,
          jumlahRupiah: 1000000,
          waktu: DateTime.now(),
          kategoriId: katCicilan.id,
          catatan: 'Cicilan bulan 1',
        );

        // Sisa utang harus berkurang menjadi 4.000.000
        expect(await repoUtang.hitungSisaUtangSQL(utangId), equals(4000000));

        // Saldo dompet harus berkurang menjadi 9.000.000
        final saldoDompet = await repoTransaksi.hitungSaldoDompetSQL(
          dompetId: dompetId,
          saldoAwalRupiah: 10000000,
        );
        expect(saldoDompet, equals(9000000));

        // Verifikasi keterkaitan pembayaran
        final pmb = await repoUtang.cariPembayaranBerdasarkanTransaksiId(trxId);
        expect(pmb, isNotNull);
        expect(pmb!.utangId, equals(utangId));
      },
    );

    test('menolak pembayaran yang melebihi sisa utang saat ini', () async {
      final dompetId = await repoDompet.buatDompet(
        nama: 'BCA Utama',
        jenis: JenisDompet.rekeningBank.kode,
        ikon: 'landmark',
        warna: 'biru',
        saldoAwalRupiah: 10000000,
      );
      final daftarKategori = await repoKategori.ambilSemuaKategori();
      final katCicilan = daftarKategori.firstWhere((k) => k.nama == 'Cicilan');

      final utangId = await repoUtang.buatUtang(
        nama: 'Cicilan HP',
        jenis: JenisUtang.cicilan.kode,
        sisaAwalRupiah: 1500000,
        jenisBunga: 'tanpa_bunga',
      );

      // Coba bayar 2.000.000 padahal sisa 1.500.000 -> harus melempar ArgumentError
      expect(
        () async => await repoUtang.catatPembayaranUtang(
          utangId: utangId,
          dompetId: dompetId,
          jumlahRupiah: 2000000,
          waktu: DateTime.now(),
          kategoriId: katCicilan.id,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test(
      'hapus transaksi pembayaran memulihkan sisa utang karena cascade',
      () async {
        final dompetId = await repoDompet.buatDompet(
          nama: 'BCA Utama',
          jenis: JenisDompet.rekeningBank.kode,
          ikon: 'landmark',
          warna: 'biru',
          saldoAwalRupiah: 10000000,
        );
        final daftarKategori = await repoKategori.ambilSemuaKategori();
        final katCicilan = daftarKategori.firstWhere(
          (k) => k.nama == 'Cicilan',
        );

        final utangId = await repoUtang.buatUtang(
          nama: 'Cicilan Motor',
          jenis: JenisUtang.cicilan.kode,
          sisaAwalRupiah: 6000000,
          jenisBunga: 'flat',
        );

        final trxId = await repoUtang.catatPembayaranUtang(
          utangId: utangId,
          dompetId: dompetId,
          jumlahRupiah: 2000000,
          waktu: DateTime.now(),
          kategoriId: katCicilan.id,
        );

        expect(await repoUtang.hitungSisaUtangSQL(utangId), equals(4000000));

        // Hapus transaksi
        await repoTransaksi.hapusTransaksi(trxId);

        // Keterkaitan pembayaran harus terhapus dan sisa utang kembali menjadi 6.000.000
        final pmb = await repoUtang.cariPembayaranBerdasarkanTransaksiId(trxId);
        expect(pmb, isNull);
        expect(await repoUtang.hitungSisaUtangSQL(utangId), equals(6000000));
      },
    );

    test(
      'pelunasan otomatis saat sisa mencapai 0 dan pengaktifan kembali jika penyesuaian bertambah',
      () async {
        final dompetId = await repoDompet.buatDompet(
          nama: 'BCA Utama',
          jenis: JenisDompet.rekeningBank.kode,
          ikon: 'landmark',
          warna: 'biru',
          saldoAwalRupiah: 5000000,
        );
        final daftarKategori = await repoKategori.ambilSemuaKategori();
        final katCicilan = daftarKategori.firstWhere(
          (k) => k.nama == 'Cicilan',
        );

        final utangId = await repoUtang.buatUtang(
          nama: 'Paylater Baju',
          jenis: JenisUtang.paylater.kode,
          sisaAwalRupiah: 500000,
          jenisBunga: 'tanpa_bunga',
        );

        // Bayar lunas 500.000
        await repoUtang.catatPembayaranUtang(
          utangId: utangId,
          dompetId: dompetId,
          jumlahRupiah: 500000,
          waktu: DateTime.now(),
          kategoriId: katCicilan.id,
        );

        final utangSetelahBayar = await repoUtang.ambilUtangBerdasarkanId(
          utangId,
        );
        expect(utangSetelahBayar!.status, equals('lunas'));
        expect(await repoUtang.hitungSisaUtangSQL(utangId), equals(0));

        // Tambahkan denda 50.000 melalui penyesuaian
        await repoUtang.sesuaikanSisaUtang(
          utangId: utangId,
          arah: ArahPenyesuaianUtang.tambah,
          jumlahRupiah: 50000,
          catatan: 'Denda keterlambatan sistem',
          tanggal: DateTime.now(),
        );

        final utangSetelahDenda = await repoUtang.ambilUtangBerdasarkanId(
          utangId,
        );
        expect(utangSetelahDenda!.status, equals('aktif'));
        expect(await repoUtang.hitungSisaUtangSQL(utangId), equals(50000));
      },
    );

    test('uji kesetaraan SQL vs fungsi murni pada data utang', () async {
      final dompetId = await repoDompet.buatDompet(
        nama: 'BCA',
        jenis: JenisDompet.rekeningBank.kode,
        ikon: 'landmark',
        warna: 'biru',
        saldoAwalRupiah: 20000000,
      );
      final daftarKategori = await repoKategori.ambilSemuaKategori();
      final katCicilan = daftarKategori.firstWhere((k) => k.nama == 'Cicilan');

      final utangId = await repoUtang.buatUtang(
        nama: 'Utang Uji Kesetaraan',
        jenis: JenisUtang.pinjamanPribadi.kode,
        sisaAwalRupiah: 10000000,
        jenisBunga: 'tanpa_bunga',
      );

      // Buat beberapa pembayaran
      await repoUtang.catatPembayaranUtang(
        utangId: utangId,
        dompetId: dompetId,
        jumlahRupiah: 1500000,
        waktu: DateTime.now(),
        kategoriId: katCicilan.id,
      );
      await repoUtang.catatPembayaranUtang(
        utangId: utangId,
        dompetId: dompetId,
        jumlahRupiah: 2500000,
        waktu: DateTime.now(),
        kategoriId: katCicilan.id,
      );

      // Buat penyesuaian
      await repoUtang.sesuaikanSisaUtang(
        utangId: utangId,
        arah: ArahPenyesuaianUtang.tambah,
        jumlahRupiah: 300000,
        tanggal: DateTime.now(),
      );
      await repoUtang.sesuaikanSisaUtang(
        utangId: utangId,
        arah: ArahPenyesuaianUtang.kurang,
        jumlahRupiah: 100000,
        tanggal: DateTime.now(),
      );

      // Hitung via SQL
      final sisaSQL = await repoUtang.hitungSisaUtangSQL(utangId);

      // Hitung via fungsi murni
      final sisaMurni = hitungSisaUtang(
        sisaAwalRupiah: 10000000,
        daftarJumlahPembayaranRupiah: [1500000, 2500000],
        daftarPenyesuaian: [
          const ItemPenyesuaianUtang(
            arah: ArahPenyesuaianUtang.tambah,
            jumlahRupiah: 300000,
          ),
          const ItemPenyesuaianUtang(
            arah: ArahPenyesuaianUtang.kurang,
            jumlahRupiah: 100000,
          ),
        ],
      );

      expect(sisaSQL, equals(sisaMurni));
      expect(sisaSQL, equals(6200000));
    });
  });
}
