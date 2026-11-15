import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/repositori/dompet_repositori.dart';
import 'package:funda/data/repositori/kategori_repositori.dart';
import 'package:funda/data/repositori/tagihan_repositori.dart';
import 'package:funda/data/repositori/transaksi_repositori.dart';
import 'package:funda/layanan/pengingat/layanan_pengingat_palsu.dart';
import 'package:funda/perhitungan/perhitungan_tagihan.dart';

void main() {
  group(
    'TagihanRepositori: Operasi, Integritas Database, dan Sinkronisasi Pengingat',
    () {
      late BasisDataFunda basisData;
      late DompetRepositori repoDompet;
      late KategoriRepositori repoKategori;
      late TransaksiRepositori repoTransaksi;
      late TagihanRepositori repoTagihan;
      late LayananPengingatPalsu layananPengingat;

      setUp(() {
        basisData = BasisDataFunda(NativeDatabase.memory());
        repoDompet = DompetRepositori(basisData);
        repoKategori = KategoriRepositori(basisData);
        repoTransaksi = TransaksiRepositori(basisData);
        repoTagihan = TagihanRepositori(basisData);
        layananPengingat = LayananPengingatPalsu();
      });

      tearDown(() async {
        await basisData.close();
      });

      test(
        'Operasi dasar: buat tagihan, jeda, arsipkan, dan hapus permanen',
        () async {
          final daftarKat = await repoKategori.ambilSemuaKategori();
          final katListrik = daftarKat.firstWhere((k) => k.arus == 'keluar');

          // Buat tagihan
          final tagihanId = await repoTagihan.buatTagihan(
            nama: 'Listrik Rumah',
            jenis: 'tagihan',
            jumlahPerkiraanRupiah: 350000,
            kategoriId: katListrik.id,
            frekuensi: 'bulanan',
            jatuhTempoPertama: DateTime(2026, 3, 20),
            pengingatHariSebelum: [0, 1, 3],
          );

          final tagihan = await repoTagihan.ambilTagihanBerdasarkanId(
            tagihanId,
          );
          expect(tagihan, isNotNull);
          expect(tagihan!.nama, equals('Listrik Rumah'));
          expect(tagihan.aktif, isTrue);
          expect(tagihan.diarsipkan, isFalse);

          // Jeda tagihan (aktif -> false)
          await repoTagihan.ubahStatusAktifTagihan(tagihanId, false);
          expect(
            (await repoTagihan.ambilTagihanBerdasarkanId(tagihanId))!.aktif,
            isFalse,
          );

          // Arsipkan tagihan
          await repoTagihan.arsipkanTagihan(tagihanId);
          final tagihanArsip = await repoTagihan.ambilTagihanBerdasarkanId(
            tagihanId,
          );
          expect(tagihanArsip!.diarsipkan, isTrue);

          // Hapus permanen boleh jika belum pernah ada pembayaran
          await repoTagihan.hapusTagihanPermanen(tagihanId);
          expect(
            await repoTagihan.ambilTagihanBerdasarkanId(tagihanId),
            isNull,
          );
        },
      );

      test(
        'Atomik & Cascade: tandai tagihan dibayar membuat transaksi, hapus transaksi menghapus pembayaran',
        () async {
          final dompetId = await repoDompet.buatDompet(
            nama: 'BCA',
            jenis: 'rekening_bank',
            ikon: 'bank',
            warna: 'tintBiru',
            saldoAwalRupiah: 2000000,
          );
          final daftarKat = await repoKategori.ambilSemuaKategori();
          final katWifi = daftarKat.firstWhere((k) => k.arus == 'keluar');

          final tagihanId = await repoTagihan.buatTagihan(
            nama: 'WiFi Indihome',
            jenis: 'langganan',
            jumlahPerkiraanRupiah: 375000,
            kategoriId: katWifi.id,
            dompetId: dompetId,
            frekuensi: 'bulanan',
            jatuhTempoPertama: DateTime(2026, 3, 10),
          );

          // Tandai dibayar untuk periode 10 Maret 2026
          final tJatuhTempo = DateTime(2026, 3, 10);
          final transaksiId = await repoTagihan.tandaiTagihanDibayar(
            tagihanId: tagihanId,
            jatuhTempo: tJatuhTempo,
            dompetId: dompetId,
            kategoriId: katWifi.id,
            jumlahRupiah: 380000,
            waktuTransaksi: DateTime.now(),
            catatan: 'Pembayaran WiFi Maret',
          );

          // 1. Verifikasi transaksi tersimpan di tabel_transaksi
          final tx = await repoTransaksi.ambilTransaksiBerdasarkanId(
            transaksiId,
          );
          expect(tx, isNotNull);
          expect(tx!.jumlahRupiah, equals(380000));

          // 2. Verifikasi status jadwal menjadi dibayar
          var jadwal = await repoTagihan.ambilJadwalGabungan(
            mulai: DateTime(2026, 3, 1),
            selesai: DateTime(2026, 3, 31),
          );
          final itemWifi = jadwal.firstWhere((j) => j.idTagihan == tagihanId);
          expect(itemWifi.status, equals(StatusKemunculan.dibayar));
          expect(itemWifi.jumlahAktualRupiah, equals(380000));

          // 3. Hapus permanen harus DITOLAK karena sudah memiliki riwayat pembayaran
          expect(
            () async => await repoTagihan.hapusTagihanPermanen(tagihanId),
            throwsA(isA<StateError>()),
          );

          // 4. Hapus transaksi pengeluaran -> Foreign key CASCADE otomatis menghapus pembayaran tagihan
          await repoTransaksi.hapusTransaksi(transaksiId);

          // 5. Verifikasi status jadwal kembali menjadi belum ditandai
          jadwal = await repoTagihan.ambilJadwalGabungan(
            mulai: DateTime(2026, 3, 1),
            selesai: DateTime(2026, 3, 31),
          );
          final itemWifiPulih = jadwal.firstWhere(
            (j) => j.idTagihan == tagihanId,
          );
          expect(itemWifiPulih.status, isNot(equals(StatusKemunculan.dibayar)));
          expect(itemWifiPulih.transaksiIdTertaut, isNull);
        },
      );

      test('Tandai dilewati dan batalkan penandaan', () async {
        final daftarKat = await repoKategori.ambilSemuaKategori();
        final kat = daftarKat.firstWhere((k) => k.arus == 'keluar');

        final tagihanId = await repoTagihan.buatTagihan(
          nama: 'Langganan Koran',
          jenis: 'langganan',
          kategoriId: kat.id,
          frekuensi: 'bulanan',
          jatuhTempoPertama: DateTime(2026, 3, 5),
        );

        final tJatuh = DateTime(2026, 3, 5);
        await repoTagihan.tandaiTagihanDilewati(
          tagihanId: tagihanId,
          jatuhTempo: tJatuh,
        );

        var jadwal = await repoTagihan.ambilJadwalGabungan(
          mulai: DateTime(2026, 3, 1),
          selesai: DateTime(2026, 3, 31),
        );
        var item = jadwal.firstWhere((j) => j.idTagihan == tagihanId);
        expect(item.status, equals(StatusKemunculan.dilewati));

        // Batalkan penandaan periode
        await repoTagihan.batalkanPenandaanPeriode(
          tagihanId: tagihanId,
          jatuhTempo: tJatuh,
        );

        jadwal = await repoTagihan.ambilJadwalGabungan(
          mulai: DateTime(2026, 3, 1),
          selesai: DateTime(2026, 3, 31),
        );
        item = jadwal.firstWhere((j) => j.idTagihan == tagihanId);
        expect(item.status, isNot(equals(StatusKemunculan.dilewati)));
      });

      test(
        'Sinkronisasi pengingat: jika pengaturan mati membatalkan semua, jika aktif menjadwalkan rencana',
        () async {
          final daftarKat = await repoKategori.ambilSemuaKategori();
          final kat = daftarKat.firstWhere((k) => k.arus == 'keluar');

          // Buat tagihan yang jatuh tempo besok
          final besok = DateTime.now().add(const Duration(days: 1));
          await repoTagihan.buatTagihan(
            nama: 'Tagihan Air',
            jenis: 'tagihan',
            jumlahPerkiraanRupiah: 150000,
            kategoriId: kat.id,
            frekuensi: 'bulanan',
            jatuhTempoPertama: DateTime(besok.year, besok.month, besok.day),
            pengingatHariSebelum: [0, 1],
          );

          // 1. Kondisi default: pengingat_aktif = false -> membatalkan semua
          await repoTagihan.sinkronkanPengingat(layananPengingat);
          expect(layananPengingat.daftarTersimpan, isEmpty);

          // 2. Aktifkan pengingat di pengaturan
          await basisData.simpanPengaturan('pengingat_aktif', 'true');
          await basisData.simpanPengaturan(
            'jam_pengingat',
            '23:59',
          ); // Jam malam agar tidak lewat sekarang
          await repoTagihan.sinkronkanPengingat(layananPengingat);

          // Harus ada rencana yang terjadwal
          expect(layananPengingat.daftarTersimpan, isNotEmpty);
          expect(
            layananPengingat.daftarTersimpan.first.judul,
            contains('Tagihan Air'),
          );
        },
      );
    },
  );
}
