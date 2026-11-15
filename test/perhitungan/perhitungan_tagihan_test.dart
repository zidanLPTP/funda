import 'package:flutter_test/flutter_test.dart';
import 'package:funda/perhitungan/perhitungan_tagihan.dart';

void main() {
  group('Logika Murni Perhitungan Tagihan (Tahap 3C - TDD)', () {
    group('1. hitungJatuhTempoDalamRentang', () {
      test(
        'Bulanan: tanggal 31 ke bulan yang memiliki 30, 28, dan 29 hari jatuh pada hari terakhir',
        () {
          // Tagihan tanggal 31 mulai Januari 2024 (tahun kabisat)
          final aturan = AturanJatuhTempo(
            frekuensi: FrekuensiKalkulasi.bulanan,
            jatuhTempoPertama: DateTime(2024, 1, 31),
          );

          // Rentang Jan 2024 s.d. Mei 2024
          final hasil = hitungJatuhTempoDalamRentang(
            aturan: aturan,
            mulai: DateTime(2024, 1, 1),
            selesai: DateTime(2024, 5, 31),
          );

          expect(hasil.length, equals(5));
          expect(hasil[0], equals(DateTime(2024, 1, 31)));
          expect(
            hasil[1],
            equals(DateTime(2024, 2, 29)),
            reason: 'Februari 2024 kabisat -> 29',
          );
          expect(hasil[2], equals(DateTime(2024, 3, 31)));
          expect(
            hasil[3],
            equals(DateTime(2024, 4, 30)),
            reason: 'April 30 hari -> 30',
          );
          expect(hasil[4], equals(DateTime(2024, 5, 31)));
        },
      );

      test(
        'Bulanan: Februari tahun biasa (non-kabisat) 2025 jatuh pada 28 Februari',
        () {
          final aturan = AturanJatuhTempo(
            frekuensi: FrekuensiKalkulasi.bulanan,
            jatuhTempoPertama: DateTime(2025, 1, 31),
          );

          final hasil = hitungJatuhTempoDalamRentang(
            aturan: aturan,
            mulai: DateTime(2025, 2, 1),
            selesai: DateTime(2025, 2, 28),
          );

          expect(hasil.length, equals(1));
          expect(hasil[0], equals(DateTime(2025, 2, 28)));
        },
      );

      test('Tahunan: 29 Februari pada tahun biasa jatuh pada 28 Februari', () {
        final aturan = AturanJatuhTempo(
          frekuensi: FrekuensiKalkulasi.tahunan,
          jatuhTempoPertama: DateTime(2024, 2, 29),
        );

        final hasil = hitungJatuhTempoDalamRentang(
          aturan: aturan,
          mulai: DateTime(2024, 1, 1),
          selesai: DateTime(2028, 12, 31),
        );

        expect(hasil.length, equals(5));
        expect(hasil[0], equals(DateTime(2024, 2, 29)), reason: '2024 kabisat');
        expect(hasil[1], equals(DateTime(2025, 2, 28)), reason: '2025 biasa');
        expect(hasil[2], equals(DateTime(2026, 2, 28)), reason: '2026 biasa');
        expect(hasil[3], equals(DateTime(2027, 2, 28)), reason: '2027 biasa');
        expect(hasil[4], equals(DateTime(2028, 2, 29)), reason: '2028 kabisat');
      });

      test('Mingguan: lintas bulan dan pergantian tahun terhitung tepat', () {
        // Jatuh tempo setiap Senin (mulai 22 Des 2025)
        final aturan = AturanJatuhTempo(
          frekuensi: FrekuensiKalkulasi.mingguan,
          jatuhTempoPertama: DateTime(2025, 12, 22),
        );

        final hasil = hitungJatuhTempoDalamRentang(
          aturan: aturan,
          mulai: DateTime(2025, 12, 20),
          selesai: DateTime(2026, 1, 15),
        );

        expect(
          hasil,
          equals([
            DateTime(2025, 12, 22), // Senin
            DateTime(2025, 12, 29), // Senin
            DateTime(2026, 1, 5), // Senin tahun baru
            DateTime(2026, 1, 12), // Senin
          ]),
        );
      });

      test(
        'Berakhir pada (inklusif): kemunculan tepat pada tanggal akhir disertakan, setelahnya tidak',
        () {
          final aturan = AturanJatuhTempo(
            frekuensi: FrekuensiKalkulasi.bulanan,
            jatuhTempoPertama: DateTime(2026, 1, 10),
            berakhirPada: DateTime(2026, 3, 10),
          );

          final hasil = hitungJatuhTempoDalamRentang(
            aturan: aturan,
            mulai: DateTime(2026, 1, 1),
            selesai: DateTime(2026, 5, 1),
          );

          expect(
            hasil,
            equals([
              DateTime(2026, 1, 10),
              DateTime(2026, 2, 10),
              DateTime(2026, 3, 10),
            ]),
          );
        },
      );
    });

    group('2. tentukanStatusJatuhTempo', () {
      final hariIni = DateTime(2026, 3, 15);

      test('Status hari ini, besok (+1), dan lewat (-2)', () {
        final s1 = tentukanStatusJatuhTempo(
          tanggalJatuhTempo: DateTime(2026, 3, 15),
          hariIni: hariIni,
        );
        expect(s1.status, equals(StatusKemunculan.hariIni));
        expect(s1.selisihHari, equals(0));

        final s2 = tentukanStatusJatuhTempo(
          tanggalJatuhTempo: DateTime(2026, 3, 16),
          hariIni: hariIni,
        );
        expect(s2.status, equals(StatusKemunculan.akanDatang));
        expect(s2.selisihHari, equals(1));

        final s3 = tentukanStatusJatuhTempo(
          tanggalJatuhTempo: DateTime(2026, 3, 13),
          hariIni: hariIni,
        );
        expect(s3.status, equals(StatusKemunculan.lewat));
        expect(s3.selisihHari, equals(-2));
      });

      test('Status dibayar dan dilewati jika ada catatan status', () {
        final sBayar = tentukanStatusJatuhTempo(
          tanggalJatuhTempo: DateTime(2026, 3, 10),
          hariIni: hariIni,
          statusTersimpan: 'dibayar',
        );
        expect(sBayar.status, equals(StatusKemunculan.dibayar));

        final sLewat = tentukanStatusJatuhTempo(
          tanggalJatuhTempo: DateTime(2026, 3, 10),
          hariIni: hariIni,
          statusTersimpan: 'dilewati',
        );
        expect(sLewat.status, equals(StatusKemunculan.dilewati));
      });

      test('Kemunculan lewat > 60 hari diabaikan (lewatKedaluwarsa)', () {
        final sLama = tentukanStatusJatuhTempo(
          tanggalJatuhTempo: DateTime(2026, 1, 10), // lewat 64 hari
          hariIni: hariIni,
        );
        expect(sLama.status, equals(StatusKemunculan.lewatKedaluwarsa));
        expect(sLama.selisihHari, equals(-64));
      });
    });

    group('3. hitungRingkasanBulanTagihan', () {
      test(
        'Menghitung total perkiraan, sudah dibayar, sisa perkiraan, dan item tanpa nominal',
        () {
          final daftarItem = [
            const ItemKalkulasiJadwal(
              idTagihan: 't1',
              nama: 'Listrik PLN',
              tanggal: null,
              jumlahPerkiraanRupiah: 500000,
              status: StatusKemunculan.dibayar,
              jumlahAktualBayarRupiah: 520000,
            ),
            const ItemKalkulasiJadwal(
              idTagihan: 't2',
              nama: 'WiFi Kantor',
              tanggal: null,
              jumlahPerkiraanRupiah: 350000,
              status: StatusKemunculan.akanDatang,
            ),
            const ItemKalkulasiJadwal(
              idTagihan: 't3',
              nama: 'Air PDAM (Berubah)',
              tanggal: null,
              jumlahPerkiraanRupiah: null, // Tanpa perkiraan nominal
              status: StatusKemunculan.hariIni,
            ),
            const ItemKalkulasiJadwal(
              idTagihan: 't4',
              nama: 'Langganan Gym',
              tanggal: null,
              jumlahPerkiraanRupiah: 200000,
              status: StatusKemunculan.dilewati,
            ),
          ];

          final ringkasan = hitungRingkasanBulanTagihan(daftarItem);

          // Total perkiraan: 500rb + 350rb + 200rb = 1.050.000
          expect(ringkasan.totalPerkiraanRupiah, equals(1050000));
          // Sudah dibayar aktual: 520.000
          expect(ringkasan.sudahDibayarRupiah, equals(520000));
          // Sisa perkiraan (belum dibayar/dilewati yang punya perkiraan): t2 = 350.000
          expect(ringkasan.sisaPerkiraanRupiah, equals(350000));
          // Belum ditandai: t2 (akanDatang) dan t3 (hariIni) = 2 item
          expect(ringkasan.jumlahBelumDitandai, equals(2));
          // Jumlah tanpa nominal: t3 = 1 item
          expect(ringkasan.jumlahTanpaNominal, equals(1));
        },
      );
    });

    group('4. rencanakanPengingat', () {
      final sekarang = DateTime(2026, 3, 15, 8, 0); // 15 Maret 2026 jam 08:00
      final pengaturanAktif = PengaturanPengingatTagihan(
        aktif: true,
        jam: 9,
        menit: 0,
        tampilkanNominal: false,
      );

      test(
        'Rencana pengingat menghasilkan ID stabil, judul ramah, dan waktu tayang tepat',
        () {
          final jadwal = [
            ItemKalkulasiJadwal(
              idTagihan: 'tag_listrik',
              nama: 'Listrik Pascabayar',
              tanggal: DateTime(2026, 3, 16), // Jatuh tempo besok
              jumlahPerkiraanRupiah: 400000,
              status: StatusKemunculan.akanDatang,
              hariSebelumPengingat: const [0, 1], // Hari-H dan H-1
            ),
          ];

          final rencana = rencanakanPengingat(
            daftarJadwal: jadwal,
            pengaturan: pengaturanAktif,
            sekarang: sekarang,
          );

          expect(rencana.length, equals(2));

          // H-1: 15 Maret 2026 jam 09:00
          expect(rencana[0].waktuTayang, equals(DateTime(2026, 3, 15, 9, 0)));
          expect(rencana[0].judul, contains('Listrik Pascabayar'));
          expect(rencana[0].judul, contains('jatuh tempo besok'));
          expect(
            rencana[0].isi,
            equals('Buka Funda untuk menandai kalau sudah dibayar.'),
          );

          // Hari-H: 16 Maret 2026 jam 09:00
          expect(rencana[1].waktuTayang, equals(DateTime(2026, 3, 16, 9, 0)));
          expect(rencana[1].judul, contains('jatuh tempo hari ini'));
        },
      );

      test('Pengingat yang waktunya sudah lewat tidak dijadwalkan', () {
        final sekarangSiang = DateTime(
          2026,
          3,
          15,
          14,
          0,
        ); // Jam 14:00 (sudah lewat jam 09:00)
        final jadwal = [
          ItemKalkulasiJadwal(
            idTagihan: 'tag_listrik',
            nama: 'Listrik',
            tanggal: DateTime(2026, 3, 15), // Hari ini
            status: StatusKemunculan.hariIni,
            hariSebelumPengingat: const [0],
          ),
        ];

        final rencana = rencanakanPengingat(
          daftarJadwal: jadwal,
          pengaturan: pengaturanAktif,
          sekarang: sekarangSiang,
        );

        expect(
          rencana,
          isEmpty,
          reason: 'Jam 09:00 hari ini sudah lewat saat sekarang jam 14:00',
        );
      });

      test(
        'Item yang sudah dibayar atau dilewati tidak dijadwalkan pengingatnya',
        () {
          final jadwal = [
            ItemKalkulasiJadwal(
              idTagihan: 'tag_lunas',
              nama: 'WiFi Kantor',
              tanggal: DateTime(2026, 3, 20),
              status: StatusKemunculan.dibayar,
              hariSebelumPengingat: const [1, 3],
            ),
          ];

          final rencana = rencanakanPengingat(
            daftarJadwal: jadwal,
            pengaturan: pengaturanAktif,
            sekarang: sekarang,
          );

          expect(rencana, isEmpty);
        },
      );

      test(
        'Batas maksimal jendela bergulir 45 hari dan batas 50 pengingat',
        () {
          // Buat 60 item tagihan dalam 60 hari ke depan
          final jadwalBanyak = List.generate(60, (i) {
            return ItemKalkulasiJadwal(
              idTagihan: 'tag_$i',
              nama: 'Tagihan $i',
              tanggal: sekarang.add(Duration(days: i + 1)),
              status: StatusKemunculan.akanDatang,
              hariSebelumPengingat: const [0],
            );
          });

          final rencana = rencanakanPengingat(
            daftarJadwal: jadwalBanyak,
            pengaturan: pengaturanAktif,
            sekarang: sekarang,
            batasMaksimal: 50,
          );

          // Hanya mengambil dalam 45 hari dan dibatasi maksimal 50
          expect(
            rencana.length,
            equals(44),
          ); // hari 1 s.d. 44 (hari ke-45 jatuh tempo jam 9)
          for (final r in rencana) {
            expect(
              r.waktuTayang.isBefore(
                sekarang.add(const Duration(days: 45, hours: 2)),
              ),
              isTrue,
            );
          }
        },
      );

      test('Nominal ditampilkan hanya jika pengaturan mengizinkan', () {
        final pengaturanDenganNominal = PengaturanPengingatTagihan(
          aktif: true,
          jam: 9,
          menit: 0,
          tampilkanNominal: true,
        );

        final jadwal = [
          ItemKalkulasiJadwal(
            idTagihan: 'tag_inet',
            nama: 'Internet',
            tanggal: DateTime(2026, 3, 17),
            jumlahPerkiraanRupiah: 375000,
            status: StatusKemunculan.akanDatang,
            hariSebelumPengingat: const [1],
          ),
        ];

        final rencana = rencanakanPengingat(
          daftarJadwal: jadwal,
          pengaturan: pengaturanDenganNominal,
          sekarang: sekarang,
        );

        expect(rencana.first.isi, contains('Rp 375.000'));
      });
    });

    group('5. Serialisasi dan deserialisasi pengingat_hari_sebelum', () {
      test('Serialisasi daftar angka {0,1,3,7} ke JSON dan kembali', () {
        const daftarAsli = [0, 1, 3, 7];
        final jsonStr = serialisasiHariPengingat(daftarAsli);
        expect(jsonStr, equals('[0,1,3,7]'));

        final hasilUrai = uraiHariPengingat(jsonStr);
        expect(hasilUrai, equals(daftarAsli));
      });

      test('Format kosong atau null menghasilkan daftar kosong aman', () {
        expect(uraiHariPengingat(''), isEmpty);
        expect(uraiHariPengingat(null), isEmpty);
        expect(uraiHariPengingat('[]'), isEmpty);
      });
    });
  });
}
