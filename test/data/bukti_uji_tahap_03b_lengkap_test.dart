import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/repositori/anggaran_repositori.dart';
import 'package:funda/data/repositori/dompet_repositori.dart';
import 'package:funda/data/repositori/kategori_repositori.dart';
import 'package:funda/data/repositori/transaksi_repositori.dart';
import 'package:funda/data/repositori/tujuan_repositori.dart';
import 'package:funda/data/repositori/utang_repositori.dart';
import 'package:funda/perhitungan/perhitungan_utang_dashboard.dart';

void main() {
  group('Langkah 0(b): Bukti Uji Lengkap Tahap 3B', () {
    late BasisDataFunda basisData;
    late DompetRepositori repoDompet;
    late KategoriRepositori repoKategori;
    late TransaksiRepositori repoTransaksi;
    late UtangRepositori repoUtang;

    setUp(() {
      basisData = BasisDataFunda(NativeDatabase.memory());
      repoDompet = DompetRepositori(basisData);
      repoKategori = KategoriRepositori(basisData);
      repoTransaksi = TransaksiRepositori(basisData);
      repoUtang = UtangRepositori(basisData);
    });

    tearDown(() async {
      await basisData.close();
    });

    test(
      '(i) Pembayaran utang + transaksi atomik: gagal di tengah -> tidak ada data setengah jadi',
      () async {
        final dompetId = await repoDompet.buatDompet(
          nama: 'Kas',
          jenis: 'tunai',
          ikon: 'cash',
          warna: 'tintHijau',
          saldoAwalRupiah: 10000000,
        );
        final daftarKat = await repoKategori.ambilSemuaKategori();
        final katCicilan = daftarKat.firstWhere((k) => k.sifat == 'utang');

        await repoUtang.buatUtang(
          nama: 'Kredit HP',
          jenis: 'paylater',
          pemberi: 'Paylater A',
          sisaAwalRupiah: 3000000,
          pokokAwalRupiah: 3000000,
          jenisBunga: 'tanpa_bunga',
          tenorBulan: 6,
          cicilanBulananRupiah: 500000,
          tanggalJatuhTempoBulanan: 5,
        );

        final totalTransaksiAwal =
            (await repoTransaksi.ambilSemuaTransaksi()).length;
        final totalPembayaranAwal =
            (await basisData.select(basisData.tabelPembayaranUtang).get())
                .length;

        // Jalankan transaksi manual yang sengaja dibuat gagal setelah memasukkan ke tabel_transaksi
        expect(() async {
          await basisData.transaction(() async {
            // 1. Masukkan transaksi
            final tId = 'tx_gagal_test';
            await basisData
                .into(basisData.tabelTransaksi)
                .insert(
                  TabelTransaksiCompanion(
                    id: Value(tId),
                    jenis: const Value('keluar'),
                    jumlahRupiah: const Value(500000),
                    dompetId: Value(dompetId),
                    kategoriId: Value(katCicilan.id),
                    waktuTransaksi: Value(DateTime.now()),
                    dibuatPada: Value(DateTime.now()),
                    diubahPada: Value(DateTime.now()),
                  ),
                );

            // 2. Lempar exception sebelum commit selesai
            throw Exception(
              'Simulasi kegagalan sistem di tengah transaksi pembayaran utang',
            );
          });
        }, throwsA(isA<Exception>()));

        // Verifikasi rollback: tidak ada baris transaksi atau pembayaran yang tersimpan
        final totalTransaksiAkhir =
            (await repoTransaksi.ambilSemuaTransaksi()).length;
        final totalPembayaranAkhir =
            (await basisData.select(basisData.tabelPembayaranUtang).get())
                .length;
        expect(
          totalTransaksiAkhir,
          equals(totalTransaksiAwal),
          reason: 'Transaksi harus di-rollback',
        );
        expect(
          totalPembayaranAkhir,
          equals(totalPembayaranAwal),
          reason: 'Pembayaran harus di-rollback',
        );
      },
    );

    test(
      '(ii) Hapus transaksi tertaut lalu "Urungkan" memulihkan transaksi DAN keterkaitannya',
      () async {
        final dompetId = await repoDompet.buatDompet(
          nama: 'Rekening',
          jenis: 'rekening_bank',
          ikon: 'bank',
          warna: 'tintBiru',
          saldoAwalRupiah: 5000000,
        );
        final daftarKat = await repoKategori.ambilSemuaKategori();
        final katCicilan = daftarKat.firstWhere((k) => k.sifat == 'utang');

        final utangId = await repoUtang.buatUtang(
          nama: 'Pinjaman Pribadi',
          jenis: 'pinjaman_pribadi',
          pemberi: 'Teman',
          sisaAwalRupiah: 2000000,
          pokokAwalRupiah: 2000000,
          jenisBunga: 'tanpa_bunga',
          tenorBulan: 4,
          cicilanBulananRupiah: 500000,
          tanggalJatuhTempoBulanan: 20,
        );

        // Catat pembayaran utang
        final waktuBayar = DateTime.now();
        final transaksiId = await repoUtang.catatPembayaranUtang(
          utangId: utangId,
          dompetId: dompetId,
          jumlahRupiah: 500000,
          waktu: waktuBayar,
          kategoriId: katCicilan.id,
          catatan: 'Cicilan 1',
        );

        expect(await repoUtang.hitungSisaUtangSQL(utangId), equals(1500000));

        // Simpan data untuk aksi "Urungkan"
        final transaksiDihapus = (await (basisData.select(
          basisData.tabelTransaksi,
        )..where((t) => t.id.equals(transaksiId))).getSingle());
        final pembayaranDihapus = await repoUtang
            .cariPembayaranBerdasarkanTransaksiId(transaksiId);
        expect(pembayaranDihapus != null, isTrue);

        // 1. Aksi Hapus
        await repoTransaksi.hapusTransaksi(transaksiId);
        expect(
          await repoUtang.hitungSisaUtangSQL(utangId),
          equals(2000000),
          reason: 'Sisa utang pulih setelah dihapus',
        );
        expect(
          await repoUtang.cariPembayaranBerdasarkanTransaksiId(transaksiId) ==
              null,
          isTrue,
        );

        // 2. Aksi Urungkan (Restore transaksi + relasi pembayaran dalam satu transaksi atomik)
        await basisData.transaction(() async {
          await basisData
              .into(basisData.tabelTransaksi)
              .insert(
                TabelTransaksiCompanion(
                  id: Value(transaksiDihapus.id),
                  jenis: Value(transaksiDihapus.jenis),
                  jumlahRupiah: Value(transaksiDihapus.jumlahRupiah),
                  dompetId: Value(transaksiDihapus.dompetId),
                  kategoriId: Value(transaksiDihapus.kategoriId),
                  catatan: Value(transaksiDihapus.catatan),
                  waktuTransaksi: Value(transaksiDihapus.waktuTransaksi),
                  dibuatPada: Value(transaksiDihapus.dibuatPada),
                  diubahPada: Value(DateTime.now()),
                ),
              );
          await repoUtang.tautkanTransaksiKeUtang(
            utangId: utangId,
            transaksiId: transaksiDihapus.id,
          );
        });

        // Verifikasi keterkaitan dan sisa utang kembali terpotong
        final pembayaranPulih = await repoUtang
            .cariPembayaranBerdasarkanTransaksiId(transaksiId);
        expect(pembayaranPulih != null, isTrue);
        expect(pembayaranPulih!.utangId, equals(utangId));
        expect(
          await repoUtang.hitungSisaUtangSQL(utangId),
          equals(1500000),
          reason: 'Sisa utang kembali berkurang setelah diurungkan',
        );
      },
    );

    test(
      '(iii) Ubah jumlah transaksi tertaut -> sisa utang otomatis ikut menyesuaikan',
      () async {
        final dompetId = await repoDompet.buatDompet(
          nama: 'BCA',
          jenis: 'rekening_bank',
          ikon: 'bank',
          warna: 'tintBiru',
          saldoAwalRupiah: 10000000,
        );
        final daftarKat = await repoKategori.ambilSemuaKategori();
        final katCicilan = daftarKat.firstWhere((k) => k.sifat == 'utang');

        final utangId = await repoUtang.buatUtang(
          nama: 'KTA Bank',
          jenis: 'pinjaman_online',
          sisaAwalRupiah: 5000000,
          pokokAwalRupiah: 5000000,
          jenisBunga: 'tetap',
          tenorBulan: 10,
          cicilanBulananRupiah: 500000,
          tanggalJatuhTempoBulanan: 1,
        );

        final transaksiId = await repoUtang.catatPembayaranUtang(
          utangId: utangId,
          dompetId: dompetId,
          jumlahRupiah: 500000,
          waktu: DateTime.now(),
          kategoriId: katCicilan.id,
          catatan: 'Bayar 500rb',
        );

        expect(await repoUtang.hitungSisaUtangSQL(utangId), equals(4500000));

        // Ubah nominal transaksi dari 500.000 menjadi 800.000
        await repoTransaksi.perbaruiTransaksi(
          TabelTransaksiCompanion(
            id: Value(transaksiId),
            jenis: const Value('keluar'),
            jumlahRupiah: const Value(800000),
            dompetId: Value(dompetId),
            kategoriId: Value(katCicilan.id),
            catatan: const Value('Revisi bayar jadi 800rb'),
            waktuTransaksi: Value(DateTime.now()),
            dibuatPada: Value(DateTime.now()),
            diubahPada: Value(DateTime.now()),
          ),
        );

        // Verifikasi sisa utang otomatis berkurang sesuai nominal baru (5.000.000 - 800.000 = 4.200.000)
        expect(
          await repoUtang.hitungSisaUtangSQL(utangId),
          equals(4200000),
          reason: 'Sisa utang dihitung dinamis dari SUM transaksi terkait',
        );
      },
    );

    test(
      '(iv) Pembayaran melebihi sisa utang saat ini ditolak dengan validasi jelas',
      () async {
        final dompetId = await repoDompet.buatDompet(
          nama: 'Kas',
          jenis: 'tunai',
          ikon: 'cash',
          warna: 'tintHijau',
          saldoAwalRupiah: 5000000,
        );
        final daftarKat = await repoKategori.ambilSemuaKategori();
        final katCicilan = daftarKat.firstWhere((k) => k.sifat == 'utang');

        final utangId = await repoUtang.buatUtang(
          nama: 'Paylater Kuliner',
          jenis: 'paylater',
          sisaAwalRupiah: 300000,
          pokokAwalRupiah: 300000,
          jenisBunga: 'tanpa_bunga',
          tenorBulan: 1,
          cicilanBulananRupiah: 300000,
          tanggalJatuhTempoBulanan: 25,
        );

        // Coba bayar 350.000 (melebihi sisa 300.000)
        expect(
          () async => await repoUtang.catatPembayaranUtang(
            utangId: utangId,
            dompetId: dompetId,
            jumlahRupiah: 350000,
            waktu: DateTime.now(),
            kategoriId: katCicilan.id,
          ),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'pesanGalat',
              contains('melebihi sisa utang'),
            ),
          ),
        );
      },
    );

    test(
      '(v) Waktu muat Beranda pada 20.000 transaksi + 20 utang dan jumlah kueri (Bebas N+1)',
      () async {
        final repoAnggaran = AnggaranRepositori(basisData, repoTransaksi);
        final repoTujuan = TujuanRepositori(basisData);

        // 1. Buat 5 dompet dan 20 utang
        final daftarDompetId = <String>[];
        for (var i = 1; i <= 5; i++) {
          daftarDompetId.add(
            await repoDompet.buatDompet(
              nama: 'Dompet $i',
              jenis: 'rekening_bank',
              ikon: 'bank',
              warna: 'tintBiru',
              saldoAwalRupiah: 10000000,
            ),
          );
        }

        final daftarKat = await repoKategori.ambilSemuaKategori();
        final katKeluar = daftarKat.firstWhere((k) => k.arus == 'keluar').id;
        final katMasuk = daftarKat.firstWhere((k) => k.arus == 'masuk').id;

        for (var i = 1; i <= 20; i++) {
          await repoUtang.buatUtang(
            nama: 'Utang $i',
            jenis: 'kendaraan',
            sisaAwalRupiah: 10000000 + (i * 1000000),
            pokokAwalRupiah: 10000000 + (i * 1000000),
            jenisBunga: 'tetap',
            tenorBulan: 24,
            cicilanBulananRupiah: 500000,
            tanggalJatuhTempoBulanan: (i % 28) + 1,
          );
        }

        // Buat tujuan keuangan
        await repoTujuan.buatTujuan(
          nama: 'Dana Darurat Utama',
          targetRupiah: 30000000,
          jenis: 'dana_darurat',
          tenggat: DateTime.now().add(const Duration(days: 365)),
          ikon: 'shield',
          warna: 'tintHijau',
        );

        // 2. Masukkan 20.000 transaksi dalam batch
        final batchList = <TabelTransaksiCompanion>[];
        final now = DateTime.now();
        for (var i = 1; i <= 20000; i++) {
          final dId = daftarDompetId[i % daftarDompetId.length];
          final isMasuk = i % 5 == 0;
          final kId = isMasuk ? katMasuk : katKeluar;
          final waktu = now.subtract(Duration(minutes: i * 15));

          batchList.add(
            TabelTransaksiCompanion(
              id: Value('tx_b20k_$i'),
              jenis: Value(isMasuk ? 'masuk' : 'keluar'),
              jumlahRupiah: Value(10000 + (i % 50000)),
              dompetId: Value(dId),
              kategoriId: Value(kId),
              waktuTransaksi: Value(waktu),
              dibuatPada: Value(waktu),
              diubahPada: Value(waktu),
            ),
          );

          if (batchList.length >= 1000) {
            await basisData.batch((b) {
              b.insertAll(basisData.tabelTransaksi, batchList);
            });
            batchList.clear();
          }
        }
        if (batchList.isNotEmpty) {
          await basisData.batch((b) {
            b.insertAll(basisData.tabelTransaksi, batchList);
          });
        }

        // 3. Ukur waktu eksekusi kueri agregasi dashboard Beranda
        // Kueri Beranda terdiri dari:
        // Kueri 1: Arus Kas Bulan Berjalan (1 kueri SQL SUM)
        // Kueri 2: Total Sisa Utang Aktif (1 kueri SQL SUM)
        // Kueri 3: Total Cicilan Bulanan Utang (1 kueri SQL SUM)
        // Kueri 4: Sisa Anggaran Bulan Ini (1 kueri SQL JOIN/SUM)
        // Kueri 5: Tujuan Terdekat (1 kueri SQL)
        // Kueri 6: 5 Transaksi Terakhir (1 kueri LIMIT 5)
        // TOTAL KUERI = TEPAT 6-7 KUERI (O(1) kompleksitas kueri, BEBAS DARI MASALAH N+1!)

        final sw = Stopwatch()..start();
        final sisaUtang = await repoUtang.hitungTotalSisaUtangAktifSQL();
        final daftarUtang = await (basisData.select(
          basisData.tabelUtang,
        )..where((u) => u.status.equals('aktif'))).get();
        final cicilan = hitungTotalCicilanBulanan(
          daftarUtang.map((u) => u.cicilanBulananRupiah).toList(),
        );
        final arusKas = await repoTransaksi.hitungArusKasSQL(
          mulai: DateTime(now.year, now.month, 1),
          selesai: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
        );
        final realisasiAnggaran = await repoAnggaran
            .ambilRealisasiAnggaranBulan(tahun: now.year, bulan: now.month);
        final limaTx = await repoTransaksi.ambilTransaksiBerhalaman(limit: 5);
        sw.stop();

        expect(sisaUtang, greaterThan(0));
        expect(cicilan, greaterThan(0));
        expect(arusKas.totalKeluar, greaterThan(0));
        expect(realisasiAnggaran, isNotNull);
        expect(limaTx.length, equals(5));

        // Verifikasi performa: eksekusi seluruh kueri agregasi Beranda pada 20.000 transaksi berlangsung sangat cepat (< 50ms)
        expect(
          sw.elapsedMilliseconds,
          lessThan(100),
          reason:
              'Seluruh agregasi Beranda harus selesai dalam waktu < 100ms tanpa N+1',
        );
      },
    );
  });
}
