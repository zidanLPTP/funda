import 'package:flutter_test/flutter_test.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/model/jenis_transaksi.dart';
import 'package:funda/perhitungan/perhitungan_keuangan.dart';

void main() {
  group('hitungSaldoDompet', () {
    const dompetIdA = 'dompet_a';
    const dompetIdB = 'dompet_b';

    test('saldo awal tanpa transaksi bernilai saldo awal', () {
      final saldo = hitungSaldoDompet(
        dompetId: dompetIdA,
        saldoAwalRupiah: 100000,
        daftarTransaksi: [],
      );
      expect(saldo, equals(100000));
    });

    test(
      'transaksi masuk menambah saldo, transaksi keluar mengurangi saldo',
      () {
        final daftarTransaksi = [
          EntitasTransaksi(
            id: 't1',
            jenis: JenisTransaksi.masuk.kode,
            jumlahRupiah: 500000,
            dompetId: dompetIdA,
            waktuTransaksi: DateTime.now(),
            dibuatPada: DateTime.now(),
            diubahPada: DateTime.now(),
            biayaAdminRupiah: 0,
          ),
          EntitasTransaksi(
            id: 't2',
            jenis: JenisTransaksi.keluar.kode,
            jumlahRupiah: 200000,
            dompetId: dompetIdA,
            waktuTransaksi: DateTime.now(),
            dibuatPada: DateTime.now(),
            diubahPada: DateTime.now(),
            biayaAdminRupiah: 0,
          ),
        ];

        final saldo = hitungSaldoDompet(
          dompetId: dompetIdA,
          saldoAwalRupiah: 100000,
          daftarTransaksi: daftarTransaksi,
        );

        // 100.000 + 500.000 - 200.000 = 400.000
        expect(saldo, equals(400000));
      },
    );

    test('penyesuaian masuk dan keluar mempengaruhi saldo dengan benar', () {
      final daftarTransaksi = [
        EntitasTransaksi(
          id: 't1',
          jenis: JenisTransaksi.penyesuaianMasuk.kode,
          jumlahRupiah: 75000,
          dompetId: dompetIdA,
          waktuTransaksi: DateTime.now(),
          dibuatPada: DateTime.now(),
          diubahPada: DateTime.now(),
          biayaAdminRupiah: 0,
        ),
        EntitasTransaksi(
          id: 't2',
          jenis: JenisTransaksi.penyesuaianKeluar.kode,
          jumlahRupiah: 25000,
          dompetId: dompetIdA,
          waktuTransaksi: DateTime.now(),
          dibuatPada: DateTime.now(),
          diubahPada: DateTime.now(),
          biayaAdminRupiah: 0,
        ),
      ];

      final saldo = hitungSaldoDompet(
        dompetId: dompetIdA,
        saldoAwalRupiah: 50000,
        daftarTransaksi: daftarTransaksi,
      );

      // 50.000 + 75.000 - 25.000 = 100.000
      expect(saldo, equals(100000));
    });

    test(
      'transfer mengurangi dompet asal (jumlah + biaya admin) dan menambah dompet tujuan',
      () {
        final transfer = EntitasTransaksi(
          id: 'tf1',
          jenis: JenisTransaksi.transfer.kode,
          jumlahRupiah: 300000,
          dompetId: dompetIdA,
          dompetTujuanId: dompetIdB,
          biayaAdminRupiah: 2500,
          waktuTransaksi: DateTime.now(),
          dibuatPada: DateTime.now(),
          diubahPada: DateTime.now(),
        );

        // Saldo Dompet A (Asal)
        final saldoA = hitungSaldoDompet(
          dompetId: dompetIdA,
          saldoAwalRupiah: 500000,
          daftarTransaksi: [transfer],
        );
        // 500.000 - 300.000 - 2.500 = 197.500
        expect(saldoA, equals(197500));

        // Saldo Dompet B (Tujuan)
        final saldoB = hitungSaldoDompet(
          dompetId: dompetIdB,
          saldoAwalRupiah: 50000,
          daftarTransaksi: [transfer],
        );
        // 50.000 + 300.000 = 350.000 (tidak kena biaya admin)
        expect(saldoB, equals(350000));
      },
    );

    test('saldo boleh bernilai negatif', () {
      final transaksiKeluar = EntitasTransaksi(
        id: 't1',
        jenis: JenisTransaksi.keluar.kode,
        jumlahRupiah: 250000,
        dompetId: dompetIdA,
        waktuTransaksi: DateTime.now(),
        dibuatPada: DateTime.now(),
        diubahPada: DateTime.now(),
        biayaAdminRupiah: 0,
      );

      final saldo = hitungSaldoDompet(
        dompetId: dompetIdA,
        saldoAwalRupiah: 50000,
        daftarTransaksi: [transaksiKeluar],
      );
      expect(saldo, equals(-200000));
    });

    test('menghitung nominal uang bernilai besar (puluhan miliar)', () {
      final transaksiBesar = EntitasTransaksi(
        id: 't1',
        jenis: JenisTransaksi.masuk.kode,
        jumlahRupiah: 50000000000, // 50 Miliar
        dompetId: dompetIdA,
        waktuTransaksi: DateTime.now(),
        dibuatPada: DateTime.now(),
        diubahPada: DateTime.now(),
        biayaAdminRupiah: 0,
      );

      final saldo = hitungSaldoDompet(
        dompetId: dompetIdA,
        saldoAwalRupiah: 10000000000, // 10 Miliar
        daftarTransaksi: [transaksiBesar],
      );
      expect(saldo, equals(60000000000));
    });
  });

  group('hitungPenyesuaianSaldo', () {
    test('selisih 0 menghasilkan tidak ada transaksi penyesuaian', () {
      final hasil = hitungPenyesuaianSaldo(
        saldoSekarang: 150000,
        saldoSebenarnya: 150000,
      );
      expect(hasil.perluPenyesuaian, isFalse);
      expect(hasil.jenis, isNull);
      expect(hasil.jumlahRupiah, equals(0));
    });

    test('saldoSebenarnya > saldoSekarang menghasilkan penyesuaianMasuk', () {
      final hasil = hitungPenyesuaianSaldo(
        saldoSekarang: 100000,
        saldoSebenarnya: 175000,
      );
      expect(hasil.perluPenyesuaian, isTrue);
      expect(hasil.jenis, equals(JenisTransaksi.penyesuaianMasuk));
      expect(hasil.jumlahRupiah, equals(75000));
    });

    test('saldoSebenarnya < saldoSekarang menghasilkan penyesuaianKeluar', () {
      final hasil = hitungPenyesuaianSaldo(
        saldoSekarang: 200000,
        saldoSebenarnya: 120000,
      );
      expect(hasil.perluPenyesuaian, isTrue);
      expect(hasil.jenis, equals(JenisTransaksi.penyesuaianKeluar));
      expect(hasil.jumlahRupiah, equals(80000));
    });
  });

  group('hitungArusKas', () {
    test('hanya menghitung masuk, keluar, dan biaya admin transfer', () {
      final t1 = EntitasTransaksi(
        id: 't1',
        jenis: JenisTransaksi.masuk.kode,
        jumlahRupiah: 1000000,
        dompetId: 'd1',
        waktuTransaksi: DateTime(2026, 11, 15, 10, 0),
        dibuatPada: DateTime.now(),
        diubahPada: DateTime.now(),
        biayaAdminRupiah: 0,
      );
      final t2 = EntitasTransaksi(
        id: 't2',
        jenis: JenisTransaksi.keluar.kode,
        jumlahRupiah: 400000,
        dompetId: 'd1',
        waktuTransaksi: DateTime(2026, 11, 15, 12, 0),
        dibuatPada: DateTime.now(),
        diubahPada: DateTime.now(),
        biayaAdminRupiah: 0,
      );
      final t3Transfer = EntitasTransaksi(
        id: 't3',
        jenis: JenisTransaksi.transfer.kode,
        jumlahRupiah: 500000,
        dompetId: 'd1',
        dompetTujuanId: 'd2',
        biayaAdminRupiah: 5000, // Biaya admin dihitung sebagai pengeluaran
        waktuTransaksi: DateTime(2026, 11, 15, 14, 0),
        dibuatPada: DateTime.now(),
        diubahPada: DateTime.now(),
      );
      final t4Penyesuaian = EntitasTransaksi(
        id: 't4',
        jenis: JenisTransaksi.penyesuaianMasuk.kode,
        jumlahRupiah: 50000,
        dompetId: 'd1',
        waktuTransaksi: DateTime(2026, 11, 15, 15, 0),
        dibuatPada: DateTime.now(),
        diubahPada: DateTime.now(),
        biayaAdminRupiah: 0,
      );

      final arusKas = hitungArusKas(
        daftarTransaksi: [t1, t2, t3Transfer, t4Penyesuaian],
        mulai: DateTime(2026, 11, 1),
        selesai: DateTime(2026, 11, 30),
      );

      expect(arusKas.totalMasuk, equals(1000000));
      // Keluar 400.000 + Biaya admin transfer 5.000 = 405.000
      expect(arusKas.totalKeluar, equals(405000));
      expect(arusKas.selisih, equals(595000));
    });
  });

  group('hitungTotalSaldo', () {
    test(
      'hanya menghitung saldo dompet aktif, mengabaikan dompet diarsipkan',
      () {
        final dompetA = EntitasDompet(
          id: 'd1',
          nama: 'BCA',
          jenis: 'rekening_bank',
          ikon: 'building2',
          warna: 'tintBiru',
          saldoAwalRupiah: 500000,
          urutan: 0,
          diarsipkan: false,
          dibuatPada: DateTime.now(),
        );
        final dompetB = EntitasDompet(
          id: 'd2',
          nama: 'Kas',
          jenis: 'tunai',
          ikon: 'wallet',
          warna: 'tintHijau',
          saldoAwalRupiah: 200000,
          urutan: 1,
          diarsipkan: false,
          dibuatPada: DateTime.now(),
        );
        final dompetArsip = EntitasDompet(
          id: 'd3',
          nama: 'Dompet Lama',
          jenis: 'e_wallet',
          ikon: 'archive',
          warna: 'tintNetral',
          saldoAwalRupiah: 1000000,
          urutan: 2,
          diarsipkan: true, // Diarsipkan
          dibuatPada: DateTime.now(),
        );

        final total = hitungTotalSaldo(
          daftarDompet: [dompetA, dompetB, dompetArsip],
          ambilSaldoDompet: (id) {
            if (id == 'd1') return 500000;
            if (id == 'd2') return 200000;
            if (id == 'd3') return 1000000;
            return 0;
          },
        );

        // Hanya d1 (500.000) + d2 (200.000) = 700.000
        expect(total, equals(700000));
      },
    );
  });

  group('validasiTransaksi', () {
    test('menolak nominal kurang dari atau sama dengan nol', () {
      final hasilNol = validasiTransaksi(
        jenis: JenisTransaksi.masuk,
        jumlahRupiah: 0,
        dompetId: 'd1',
        kategoriId: 'k1',
      );
      expect(hasilNol.isValid, isFalse);
      expect(hasilNol.pesanGalat, contains('lebih besar dari Rp 0'));

      final hasilMinus = validasiTransaksi(
        jenis: JenisTransaksi.keluar,
        jumlahRupiah: -5000,
        dompetId: 'd1',
        kategoriId: 'k1',
      );
      expect(hasilMinus.isValid, isFalse);
    });

    test('menolak nominal melebihi batas 999.999.999.999', () {
      final hasil = validasiTransaksi(
        jenis: JenisTransaksi.masuk,
        jumlahRupiah: 1000000000000,
        dompetId: 'd1',
        kategoriId: 'k1',
      );
      expect(hasil.isValid, isFalse);
      expect(hasil.pesanGalat, contains('Maksimal nominal'));
    });

    test('menolak transfer ke dompet yang sama', () {
      final hasil = validasiTransaksi(
        jenis: JenisTransaksi.transfer,
        jumlahRupiah: 50000,
        dompetId: 'd1',
        dompetTujuanId: 'd1',
      );
      expect(hasil.isValid, isFalse);
      expect(hasil.pesanGalat, contains('berbeda'));
    });

    test('menolak transaksi masuk/keluar tanpa kategori', () {
      final hasil = validasiTransaksi(
        jenis: JenisTransaksi.masuk,
        jumlahRupiah: 50000,
        dompetId: 'd1',
        kategoriId: null,
      );
      expect(hasil.isValid, isFalse);
      expect(hasil.pesanGalat, contains('Kategori'));
    });

    test('menerima transaksi yang memenuhi syarat validasi', () {
      final hasil = validasiTransaksi(
        jenis: JenisTransaksi.keluar,
        jumlahRupiah: 25000,
        dompetId: 'd1',
        kategoriId: 'k1',
      );
      expect(hasil.isValid, isTrue);
      expect(hasil.pesanGalat, isNull);
    });
  });

  group('Zona Waktu & Pengelompokan Tanggal Lokal', () {
    test(
      'transaksi jam 23:30 WIB disimpan UTC tetap dikelompokkan ke tanggal lokal WIB yang tepat',
      () {
        // 2026-11-15 23:30 WIB (UTC+7) setara dengan 2026-11-15 16:30 UTC
        final waktuUtc = DateTime.utc(2026, 11, 15, 16, 30);
        final tanggalLokal = ambilTanggalLokalPerangkat(waktuUtc);

        // Tanggal lokal harus sesuai waktu perangkat lokal
        expect(tanggalLokal.year, equals(waktuUtc.toLocal().year));
        expect(tanggalLokal.month, equals(waktuUtc.toLocal().month));
        expect(tanggalLokal.day, equals(waktuUtc.toLocal().day));
      },
    );
  });
}
