import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/repositori/dompet_repositori.dart';
import 'package:funda/data/repositori/kategori_repositori.dart';
import 'package:funda/data/repositori/transaksi_repositori.dart';
import 'package:funda/data/repositori/utang_repositori.dart';

void main() {
  group('Pembuktian Batasan Foreign Keys & PRAGMA SQLite (Langkah 0a)', () {
    test(
      'DENGAN PRAGMA foreign_keys = ON: hapus transaksi cascade menghapus pembayaran dan memulihkan sisa utang',
      () async {
        final basisData = BasisDataFunda(NativeDatabase.memory());
        // beforeOpen di BasisDataFunda sudah mengeksekusi PRAGMA foreign_keys = ON;
        final repoDompet = DompetRepositori(basisData);
        final repoKategori = KategoriRepositori(basisData);
        final repoTransaksi = TransaksiRepositori(basisData);
        final repoUtang = UtangRepositori(basisData);

        // Siapkan dompet & kategori utang
        final dompetId = await repoDompet.buatDompet(
          nama: 'BCA Utama',
          jenis: 'rekening_bank',
          ikon: 'bank',
          warna: 'tintBiru',
          saldoAwalRupiah: 10000000,
        );
        final daftarKat = await repoKategori.ambilSemuaKategori();
        final katCicilan = daftarKat.firstWhere((k) => k.sifat == 'utang');

        // Buat utang dengan sisa 5.000.000
        final utangId = await repoUtang.buatUtang(
          nama: 'Kredit Motor',
          jenis: 'kendaraan',
          pemberi: 'Leasing',
          sisaAwalRupiah: 5000000,
          pokokAwalRupiah: 5000000,
          jenisBunga: 'tetap',
          bungaBasisPoinPerTahun: 0,
          tenorBulan: 12,
          cicilanBulananRupiah: 500000,
          tanggalJatuhTempoBulanan: 15,
        );

        // Catat pembayaran utang 1.000.000
        final transaksiId = await repoUtang.catatPembayaranUtang(
          utangId: utangId,
          dompetId: dompetId,
          jumlahRupiah: 1000000,
          waktu: DateTime.now(),
          kategoriId: katCicilan.id,
          catatan: 'Cicilan 1',
        );

        // Verifikasi sisa utang berkurang menjadi 4.000.000
        var sisa = await repoUtang.hitungSisaUtangSQL(utangId);
        expect(sisa, equals(4000000));

        // Verifikasi baris di tabel_pembayaran_utang ada
        var daftarPembayaran = await (basisData.select(
          basisData.tabelPembayaranUtang,
        )..where((t) => t.utangId.equals(utangId))).get();
        expect(daftarPembayaran.length, equals(1));
        expect(daftarPembayaran.first.transaksiId, equals(transaksiId));

        // HAPUS transaksi dari tabel_transaksi
        await repoTransaksi.hapusTransaksi(transaksiId);

        // Karena foreign key cascade aktif, baris pembayaran di tabel_pembayaran_utang otomatis terhapus
        daftarPembayaran = await (basisData.select(
          basisData.tabelPembayaranUtang,
        )..where((t) => t.utangId.equals(utangId))).get();
        expect(
          daftarPembayaran,
          isEmpty,
          reason: 'Baris pembayaran harus ikut terhapus via cascade',
        );

        // Sisa utang harus otomatis pulih kembali ke 5.000.000
        sisa = await repoUtang.hitungSisaUtangSQL(utangId);
        expect(
          sisa,
          equals(5000000),
          reason: 'Sisa utang harus pulih setelah transaksi pembayaran dihapus',
        );

        await basisData.close();
      },
    );

    test(
      'TANPA PRAGMA foreign_keys = ON (OFF): cascade gagal, orphan row tertinggal dan sisa utang TIDAK pulih',
      () async {
        final basisData = BasisDataFunda(NativeDatabase.memory());
        // Sengaja matikan foreign keys untuk membuktikan bahwa tanpa PRAGMA, cascade SQLite tidak bekerja
        await basisData.customStatement('PRAGMA foreign_keys = OFF;');

        final repoDompet = DompetRepositori(basisData);
        final repoKategori = KategoriRepositori(basisData);
        final repoTransaksi = TransaksiRepositori(basisData);
        final repoUtang = UtangRepositori(basisData);

        final dompetId = await repoDompet.buatDompet(
          nama: 'BCA Utama',
          jenis: 'rekening_bank',
          ikon: 'bank',
          warna: 'tintBiru',
          saldoAwalRupiah: 10000000,
        );
        final daftarKat = await repoKategori.ambilSemuaKategori();
        final katCicilan = daftarKat.firstWhere((k) => k.sifat == 'utang');

        final utangId = await repoUtang.buatUtang(
          nama: 'Kredit Motor',
          jenis: 'kendaraan',
          pemberi: 'Leasing',
          sisaAwalRupiah: 5000000,
          pokokAwalRupiah: 5000000,
          jenisBunga: 'tetap',
          bungaBasisPoinPerTahun: 0,
          tenorBulan: 12,
          cicilanBulananRupiah: 500000,
          tanggalJatuhTempoBulanan: 15,
        );

        final transaksiId = await repoUtang.catatPembayaranUtang(
          utangId: utangId,
          dompetId: dompetId,
          jumlahRupiah: 1000000,
          waktu: DateTime.now(),
          kategoriId: katCicilan.id,
          catatan: 'Cicilan 1',
        );

        // Hapus transaksi saat foreign_keys = OFF
        await repoTransaksi.hapusTransaksi(transaksiId);

        // Verifikasi bahwa tanpa PRAGMA, cascade TIDAK jalan: baris tabel_pembayaran_utang menjadi yatim piatu (orphan row)
        final daftarPembayaran = await (basisData.select(
          basisData.tabelPembayaranUtang,
        )..where((t) => t.utangId.equals(utangId))).get();
        expect(
          daftarPembayaran.length,
          equals(1),
          reason:
              'Tanpa PRAGMA ON, baris pembayaran tidak terhapus (orphan row tetap tertinggal)',
        );
        expect(
          daftarPembayaran.first.transaksiId,
          equals(transaksiId),
          reason: 'transaksi_id menunjuk ke ID transaksi yang sudah terhapus',
        );

        // Buktikan integritas referensial SQLite rusak dengan foreign_key_check
        final pelanggaran = await basisData
            .customSelect('PRAGMA foreign_key_check;')
            .get();
        expect(
          pelanggaran,
          isNotEmpty,
          reason:
              'SQLite mendeteksi pelanggaran integritas foreign key akibat orphan row',
        );

        await basisData.close();
      },
    );
  });
}
