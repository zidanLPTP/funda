import 'package:flutter_test/flutter_test.dart';
import 'package:funda/perhitungan/perhitungan_umpan_balik_belajar.dart';
import 'package:funda/perhitungan/perhitungan_utang_dashboard.dart';

void main() {
  group('Pengujian Fungsi Murni Umpan Balik Tahap 8B (Modul 4)', () {
    group('1. formatBungaPersen (integer murni tanpa double)', () {
      test('kelipatan 100 menghasilkan angka bulat tanpa koma', () {
        expect(formatBungaPersen(1800), equals('18'));
        expect(formatBungaPersen(3600), equals('36'));
        expect(formatBungaPersen(0), equals('0'));
        expect(formatBungaPersen(500), equals('5'));
      });

      test('sisa kelipatan 10 menghasilkan 1 angka di belakang koma tanpa nol gantung', () {
        expect(formatBungaPersen(1850), equals('18,5'));
        expect(formatBungaPersen(50), equals('0,5'));
        expect(formatBungaPersen(250), equals('2,5'));
      });

      test('sisa bukan kelipatan 10 menghasilkan 2 angka di belakang koma lengkap', () {
        expect(formatBungaPersen(1205), equals('12,05'));
        expect(formatBungaPersen(5), equals('0,05'));
        expect(formatBungaPersen(1875), equals('18,75'));
      });
    });

    group('2. formatRingkasanUtang (vektor V1 sampai V7)', () {
      test('V1: 3 utang aktif, pemasukan rata-rata 3 bulan Rp3.000.000', () {
        final utangList = [
          const ItemUtangUmpanBalik(
            nama: 'Kredit HP',
            sisaRupiah: 2000000,
            cicilanBulananRupiah: 450000,
          ),
          const ItemUtangUmpanBalik(
            nama: 'Paylater',
            sisaRupiah: 1500000,
            cicilanBulananRupiah: 250000,
          ),
          const ItemUtangUmpanBalik(
            nama: 'Pinjaman Teman',
            sisaRupiah: 1500000,
            cicilanBulananRupiah: 200000,
          ),
        ];
        const pemasukan = HasilPemasukanRataRata(
          nilaiRupiah: 3000000,
          dasar: DasarPemasukanRataRata.rataRata3Bulan,
        );

        final hasil = formatRingkasanUtang(
          daftarUtang: utangList,
          pemasukan: pemasukan,
          tidakPunyaUtang: false,
        );

        expect(
          hasil,
          equals(
            'Kamu punya 3 utang aktif dengan sisa total Rp5.000.000. '
            'Cicilan per bulan: Rp900.000. '
            'Itu sekitar 30 persen dari pemasukanmu (rata-rata 3 bulan terakhir). '
            'Ini gambaran, bukan penilaian.',
          ),
        );
      });

      test('V2: 3 utang aktif, pemasukan bulan ini Rp2.500.000', () {
        final utangList = [
          const ItemUtangUmpanBalik(
            nama: 'Kredit HP',
            sisaRupiah: 2000000,
            cicilanBulananRupiah: 450000,
          ),
          const ItemUtangUmpanBalik(
            nama: 'Paylater',
            sisaRupiah: 1500000,
            cicilanBulananRupiah: 250000,
          ),
          const ItemUtangUmpanBalik(
            nama: 'Pinjaman Teman',
            sisaRupiah: 1500000,
            cicilanBulananRupiah: 200000,
          ),
        ];
        const pemasukan = HasilPemasukanRataRata(
          nilaiRupiah: 2500000,
          dasar: DasarPemasukanRataRata.bulanBerjalan,
        );

        final hasil = formatRingkasanUtang(
          daftarUtang: utangList,
          pemasukan: pemasukan,
          tidakPunyaUtang: false,
        );

        expect(
          hasil,
          equals(
            'Kamu punya 3 utang aktif dengan sisa total Rp5.000.000. '
            'Cicilan per bulan: Rp900.000. '
            'Itu sekitar 36 persen dari pemasukanmu (bulan ini). '
            'Ini gambaran, bukan penilaian.',
          ),
        );
      });

      test('V3: 3 utang aktif, pemasukan belumAda', () {
        final utangList = [
          const ItemUtangUmpanBalik(
            nama: 'Kredit HP',
            sisaRupiah: 2000000,
            cicilanBulananRupiah: 450000,
          ),
          const ItemUtangUmpanBalik(
            nama: 'Paylater',
            sisaRupiah: 1500000,
            cicilanBulananRupiah: 250000,
          ),
          const ItemUtangUmpanBalik(
            nama: 'Pinjaman Teman',
            sisaRupiah: 1500000,
            cicilanBulananRupiah: 200000,
          ),
        ];
        const pemasukan = HasilPemasukanRataRata(
          nilaiRupiah: 0,
          dasar: DasarPemasukanRataRata.belumAda,
        );

        final hasil = formatRingkasanUtang(
          daftarUtang: utangList,
          pemasukan: pemasukan,
          tidakPunyaUtang: false,
        );

        expect(
          hasil,
          equals(
            'Kamu punya 3 utang aktif dengan sisa total Rp5.000.000. '
            'Cicilan per bulan: Rp900.000. '
            'Catat pemasukanmu supaya perbandingannya bisa dihitung. '
            'Ini gambaran, bukan penilaian.',
          ),
        );
      });

      test('V4: satu utang sisa Rp800.000 cicilan 0', () {
        final utangList = [
          const ItemUtangUmpanBalik(
            nama: 'Pinjaman Teman',
            sisaRupiah: 800000,
            cicilanBulananRupiah: 0,
          ),
        ];
        const pemasukan = HasilPemasukanRataRata(
          nilaiRupiah: 3000000,
          dasar: DasarPemasukanRataRata.rataRata3Bulan,
        );

        final hasil = formatRingkasanUtang(
          daftarUtang: utangList,
          pemasukan: pemasukan,
          tidakPunyaUtang: false,
        );

        expect(
          hasil,
          equals(
            'Kamu punya 1 utang aktif dengan sisa total Rp800.000. '
            'Cicilan per bulan: Rp0. '
            'Ini gambaran, bukan penilaian.',
          ),
        );
      });

      test('V5: n = 0 dan pernyataan tidak_punya_utang', () {
        final hasil = formatRingkasanUtang(
          daftarUtang: [],
          pemasukan: null,
          tidakPunyaUtang: true,
        );

        expect(
          hasil,
          equals(
            'Kamu menyatakan tidak punya utang. '
            'Pelajaran ini tetap berguna untuk jaga-jaga. '
            'Kalau suatu saat berutang, catat di menu Utang.',
          ),
        );
      });

      test('V6: n = 0 tanpa pernyataan', () {
        final hasil = formatRingkasanUtang(
          daftarUtang: [],
          pemasukan: null,
          tidakPunyaUtang: false,
        );

        expect(hasil, equals('Belum ada utang yang tercatat.'));
      });

      test('V7: utang lunas dan diarsipkan tidak dihitung', () {
        final utangList = [
          const ItemUtangUmpanBalik(
            nama: 'Utang Lunas',
            sisaRupiah: 0,
            cicilanBulananRupiah: 300000,
            status: 'lunas',
          ),
          const ItemUtangUmpanBalik(
            nama: 'Utang Arsip',
            sisaRupiah: 500000,
            cicilanBulananRupiah: 100000,
            status: 'diarsipkan',
          ),
        ];

        final hasil = formatRingkasanUtang(
          daftarUtang: utangList,
          pemasukan: null,
          tidakPunyaUtang: false,
        );

        expect(hasil, equals('Belum ada utang yang tercatat.'));
      });
    });

    group('3. formatBiayaPinjamanTercatat (vektor V1 sampai V6)', () {
      test('V1: Kredit HP pokok 6jt, cicilan 550rb, tenor 12', () {
        final utangList = [
          const ItemUtangUmpanBalik(
            nama: 'Kredit HP',
            sisaRupiah: 4000000,
            pokokAwalRupiah: 6000000,
            cicilanBulananRupiah: 550000,
            tenorBulan: 12,
          ),
        ];

        final hasil = formatBiayaPinjamanTercatat(
          daftarUtang: utangList,
          tidakPunyaUtang: false,
        );

        expect(
          hasil,
          equals(
            'Kredit HP: pokok Rp6.000.000, cicilan Rp550.000 x 12 bulan = total Rp6.600.000. Biaya pinjaman: Rp600.000. '
            'Hitungan ini memakai cicilan x tenor yang kamu catat dan belum memasukkan denda.',
          ),
        );
      });

      test('V2: 4 utang layak -> 3 pertama diurut biaya menurun lalu nama + "Dan 1 utang lain."', () {
        final utangList = [
          const ItemUtangUmpanBalik(
            nama: 'Paylater',
            sisaRupiah: 800000,
            pokokAwalRupiah: 900000,
            cicilanBulananRupiah: 330000,
            tenorBulan: 3,
          ), // total 990k, biaya 90k
          const ItemUtangUmpanBalik(
            nama: 'Kredit HP',
            sisaRupiah: 4000000,
            pokokAwalRupiah: 6000000,
            cicilanBulananRupiah: 550000,
            tenorBulan: 12,
          ), // total 6.6jt, biaya 600k
          const ItemUtangUmpanBalik(
            nama: 'Koperasi',
            sisaRupiah: 4000000,
            pokokAwalRupiah: 5000000,
            cicilanBulananRupiah: 450000,
            tenorBulan: 12,
          ), // total 5.4jt, biaya 400k
          const ItemUtangUmpanBalik(
            nama: 'Pinjaman Teman',
            sisaRupiah: 1000000,
            pokokAwalRupiah: 1200000,
            cicilanBulananRupiah: 100000,
            tenorBulan: 12,
          ), // total 1.2jt, biaya 0
        ];

        final hasil = formatBiayaPinjamanTercatat(
          daftarUtang: utangList,
          tidakPunyaUtang: false,
        );

        expect(
          hasil,
          equals(
            'Kredit HP: pokok Rp6.000.000, cicilan Rp550.000 x 12 bulan = total Rp6.600.000. Biaya pinjaman: Rp600.000. '
            'Koperasi: pokok Rp5.000.000, cicilan Rp450.000 x 12 bulan = total Rp5.400.000. Biaya pinjaman: Rp400.000. '
            'Paylater: pokok Rp900.000, cicilan Rp330.000 x 3 bulan = total Rp990.000. Biaya pinjaman: Rp90.000. '
            'Dan 1 utang lain. '
            'Hitungan ini memakai cicilan x tenor yang kamu catat dan belum memasukkan denda.',
          ),
        );
      });

      test('V3: utang aktif ada tetapi tanpa tenor -> pesan lengkapi data', () {
        final utangList = [
          const ItemUtangUmpanBalik(
            nama: 'Utang Teman',
            sisaRupiah: 1000000,
            pokokAwalRupiah: 1000000,
            cicilanBulananRupiah: 100000,
            tenorBulan: null,
          ),
        ];

        final hasil = formatBiayaPinjamanTercatat(
          daftarUtang: utangList,
          tidakPunyaUtang: false,
        );

        expect(
          hasil,
          equals(
            'Belum ada utang dengan pokok awal, tenor, dan cicilan yang lengkap. '
            'Lengkapi datanya di menu Utang agar biaya pinjaman bisa dihitung.',
          ),
        );
      });

      test('V4: n = 0 dan pernyataan tidak_punya_utang', () {
        final hasil = formatBiayaPinjamanTercatat(
          daftarUtang: [],
          tidakPunyaUtang: true,
        );

        expect(
          hasil,
          equals(
            'Kamu menyatakan tidak punya utang, jadi belum ada biaya pinjaman yang dihitung. '
            'Contoh di pelajaran ini bisa kamu pakai kalau nanti menerima tawaran pinjaman.',
          ),
        );
      });

      test('V5: n = 0 tanpa pernyataan', () {
        final hasil = formatBiayaPinjamanTercatat(
          daftarUtang: [],
          tidakPunyaUtang: false,
        );

        expect(hasil, equals('Belum ada utang yang tercatat.'));
      });

      test('V6: cicilan x tenor < pokok menghasilkan Biaya pinjaman: Rp0', () {
        final utangList = [
          const ItemUtangUmpanBalik(
            nama: 'Subsidi Bunga',
            sisaRupiah: 500000,
            pokokAwalRupiah: 1000000,
            cicilanBulananRupiah: 80000,
            tenorBulan: 10,
          ), // total 800k < 1jt -> biaya 0
        ];

        final hasil = formatBiayaPinjamanTercatat(
          daftarUtang: utangList,
          tidakPunyaUtang: false,
        );

        expect(
          hasil,
          equals(
            'Subsidi Bunga: pokok Rp1.000.000, cicilan Rp80.000 x 10 bulan = total Rp800.000. Biaya pinjaman: Rp0. '
            'Hitungan ini memakai cicilan x tenor yang kamu catat dan belum memasukkan denda.',
          ),
        );
      });
    });

    group('4. formatRasioCicilanBulanIni (vektor V1 sampai V6)', () {
      test('V1: cicilan Rp900.000, pemasukan Rp3.000.000 (3 bulan) -> 30% dan 40%', () {
        const pemasukan = HasilPemasukanRataRata(
          nilaiRupiah: 3000000,
          dasar: DasarPemasukanRataRata.rataRata3Bulan,
        );

        final hasil = formatRasioCicilanBulanIni(
          totalCicilanBulanan: 900000,
          pemasukan: pemasukan,
        );

        expect(
          hasil,
          equals(
            'Total cicilanmu Rp900.000 per bulan, dibandingkan pemasukan Rp3.000.000 per bulan (rata-rata 3 bulan terakhir). '
            'Rasio cicilanmu 30 persen. '
            'Kalau pemasukanmu turun 25 persen, rasionya menjadi 40 persen. '
            'Ini angka untuk kamu pahami, bukan nilai.',
          ),
        );
      });

      test('V2: cicilan Rp900.000, pemasukan Rp2.500.000 (bulan ini) -> 36% dan 48%', () {
        const pemasukan = HasilPemasukanRataRata(
          nilaiRupiah: 2500000,
          dasar: DasarPemasukanRataRata.bulanBerjalan,
        );

        final hasil = formatRasioCicilanBulanIni(
          totalCicilanBulanan: 900000,
          pemasukan: pemasukan,
        );

        expect(
          hasil,
          equals(
            'Total cicilanmu Rp900.000 per bulan, dibandingkan pemasukan Rp2.500.000 per bulan (bulan ini). '
            'Rasio cicilanmu 36 persen. '
            'Kalau pemasukanmu turun 25 persen, rasionya menjadi 48 persen. '
            'Ini angka untuk kamu pahami, bukan nilai.',
          ),
        );
      });

      test('V3: cicilan Rp1.000.000, pemasukan Rp3.000.000 -> 33% dan 44%', () {
        const pemasukan = HasilPemasukanRataRata(
          nilaiRupiah: 3000000,
          dasar: DasarPemasukanRataRata.rataRata3Bulan,
        );

        final hasil = formatRasioCicilanBulanIni(
          totalCicilanBulanan: 1000000,
          pemasukan: pemasukan,
        );

        expect(
          hasil,
          equals(
            'Total cicilanmu Rp1.000.000 per bulan, dibandingkan pemasukan Rp3.000.000 per bulan (rata-rata 3 bulan terakhir). '
            'Rasio cicilanmu 33 persen. '
            'Kalau pemasukanmu turun 25 persen, rasionya menjadi 44 persen. '
            'Ini angka untuk kamu pahami, bukan nilai.',
          ),
        );
      });

      test('V4: cicilan 0 -> rasio 0 persen', () {
        const pemasukan = HasilPemasukanRataRata(
          nilaiRupiah: 3000000,
          dasar: DasarPemasukanRataRata.rataRata3Bulan,
        );

        final hasil = formatRasioCicilanBulanIni(
          totalCicilanBulanan: 0,
          pemasukan: pemasukan,
        );

        expect(hasil, equals('Cicilan bulananmu belum tercatat (Rp0), jadi rasio cicilanmu 0 persen.'));
      });

      test('V5: pemasukan belumAda -> pesan belum bisa dihitung', () {
        const pemasukan = HasilPemasukanRataRata(
          nilaiRupiah: 0,
          dasar: DasarPemasukanRataRata.belumAda,
        );

        final hasil = formatRasioCicilanBulanIni(
          totalCicilanBulanan: 500000,
          pemasukan: pemasukan,
        );

        expect(
          hasil,
          equals('Belum ada pemasukan yang tercatat, jadi rasio cicilan belum bisa dihitung. Catat pemasukanmu dulu.'),
        );
      });

      test('V6: pemasukan kecil (Rp1) tanpa pembagian nol atau galat', () {
        const pemasukan = HasilPemasukanRataRata(
          nilaiRupiah: 1,
          dasar: DasarPemasukanRataRata.bulanBerjalan,
        );

        expect(
          () => formatRasioCicilanBulanIni(
            totalCicilanBulanan: 500000,
            pemasukan: pemasukan,
          ),
          returnsNormally,
        );
      });
    });

    group('5. formatUrutanPelunasan (vektor V1 sampai V8)', () {
      test('V1: 3 utang (Paylater 800k bp 3600, Pinjaman Teman 1.5jt tanpa_bunga, Kredit HP 4jt flat bp 1800)', () {
        final utangList = [
          const ItemUtangUmpanBalik(
            nama: 'Paylater',
            sisaRupiah: 800000,
            jenisBunga: 'efektif',
            bungaBasisPoinPerTahun: 3600,
          ),
          const ItemUtangUmpanBalik(
            nama: 'Pinjaman Teman',
            sisaRupiah: 1500000,
            jenisBunga: 'tanpa_bunga',
            bungaBasisPoinPerTahun: 0,
          ),
          const ItemUtangUmpanBalik(
            nama: 'Kredit HP',
            sisaRupiah: 4000000,
            jenisBunga: 'flat',
            bungaBasisPoinPerTahun: 1800,
          ),
        ];

        final hasil = formatUrutanPelunasan(
          daftarUtang: utangList,
          tidakPunyaUtang: false,
        );

        expect(
          hasil,
          equals(
            'Urutan bola salju (sisa terkecil dulu): Paylater (Rp800.000), lalu Pinjaman Teman (Rp1.500.000), lalu Kredit HP (Rp4.000.000). '
            'Urutan longsor (bunga tertinggi dulu): Paylater (36 persen per tahun), lalu Kredit HP (18 persen per tahun), lalu Pinjaman Teman (tanpa bunga). '
            'Urutan longsor memakai persen bunga yang kamu catat. Kalau jenis bunganya berbeda, anggap sebagai perkiraan. '
            'Pilih salah satu dan konsisten. Ini bahan belajar, bukan keharusan.',
          ),
        );
      });

      test('V2: 4 utang dengan bunga belum dicatat (Kartu Lama 300k efektif bp 0)', () {
        final utangList = [
          const ItemUtangUmpanBalik(
            nama: 'Paylater',
            sisaRupiah: 800000,
            jenisBunga: 'efektif',
            bungaBasisPoinPerTahun: 3600,
          ),
          const ItemUtangUmpanBalik(
            nama: 'Pinjaman Teman',
            sisaRupiah: 1500000,
            jenisBunga: 'tanpa_bunga',
            bungaBasisPoinPerTahun: 0,
          ),
          const ItemUtangUmpanBalik(
            nama: 'Kredit HP',
            sisaRupiah: 4000000,
            jenisBunga: 'flat',
            bungaBasisPoinPerTahun: 1800,
          ),
          const ItemUtangUmpanBalik(
            nama: 'Kartu Lama',
            sisaRupiah: 300000,
            jenisBunga: 'efektif',
            bungaBasisPoinPerTahun: 0,
          ),
        ];

        final hasil = formatUrutanPelunasan(
          daftarUtang: utangList,
          tidakPunyaUtang: false,
        );

        expect(
          hasil,
          equals(
            'Urutan bola salju (sisa terkecil dulu): Kartu Lama (Rp300.000), lalu Paylater (Rp800.000), lalu Pinjaman Teman (Rp1.500.000), lalu Kredit HP (Rp4.000.000). '
            'Urutan longsor (bunga tertinggi dulu): Paylater (36 persen per tahun), lalu Kredit HP (18 persen per tahun), lalu Kartu Lama (bunga belum dicatat), lalu Pinjaman Teman (tanpa bunga). '
            'Urutan longsor memakai persen bunga yang kamu catat. Kalau jenis bunganya berbeda, anggap sebagai perkiraan. '
            'Pilih salah satu dan konsisten. Ini bahan belajar, bukan keharusan.',
          ),
        );
      });

      test('V3: hanya satu utang aktif', () {
        final utangList = [
          const ItemUtangUmpanBalik(
            nama: 'Paylater',
            sisaRupiah: 800000,
          ),
        ];

        final hasil = formatUrutanPelunasan(
          daftarUtang: utangList,
          tidakPunyaUtang: false,
        );

        expect(hasil, equals('Kamu hanya punya satu utang aktif: Paylater (sisa Rp800.000). Fokuskan uang ekstra ke utang ini.'));
      });

      test('V4: dua utang aktif', () {
        final utangList = [
          const ItemUtangUmpanBalik(
            nama: 'Utang B',
            sisaRupiah: 2000000,
            jenisBunga: 'flat',
            bungaBasisPoinPerTahun: 1000,
          ),
          const ItemUtangUmpanBalik(
            nama: 'Utang A',
            sisaRupiah: 1000000,
            jenisBunga: 'flat',
            bungaBasisPoinPerTahun: 2000,
          ),
        ];

        final hasil = formatUrutanPelunasan(
          daftarUtang: utangList,
          tidakPunyaUtang: false,
        );

        expect(
          hasil,
          equals(
            'Urutan bola salju (sisa terkecil dulu): Utang A (Rp1.000.000), lalu Utang B (Rp2.000.000). '
            'Urutan longsor (bunga tertinggi dulu): Utang A (20 persen per tahun), lalu Utang B (10 persen per tahun). '
            'Urutan longsor memakai persen bunga yang kamu catat. Kalau jenis bunganya berbeda, anggap sebagai perkiraan. '
            'Pilih salah satu dan konsisten. Ini bahan belajar, bukan keharusan.',
          ),
        );
      });

      test('V5: bunga desimal bp 1850 -> 18,5% dan bp 1205 -> 12,05%', () {
        final utangList = [
          const ItemUtangUmpanBalik(
            nama: 'Utang 1',
            sisaRupiah: 2000000,
            jenisBunga: 'efektif',
            bungaBasisPoinPerTahun: 1850,
          ),
          const ItemUtangUmpanBalik(
            nama: 'Utang 2',
            sisaRupiah: 1000000,
            jenisBunga: 'efektif',
            bungaBasisPoinPerTahun: 1205,
          ),
        ];

        final hasil = formatUrutanPelunasan(
          daftarUtang: utangList,
          tidakPunyaUtang: false,
        );

        expect(
          hasil,
          contains('Urutan longsor (bunga tertinggi dulu): Utang 1 (18,5 persen per tahun), lalu Utang 2 (12,05 persen per tahun).'),
        );
      });

      test('V6: sisa sama diurut berdasarkan nama menaik', () {
        final utangList = [
          const ItemUtangUmpanBalik(
            nama: 'Utang Z',
            sisaRupiah: 1000000,
            jenisBunga: 'tanpa_bunga',
            bungaBasisPoinPerTahun: 0,
          ),
          const ItemUtangUmpanBalik(
            nama: 'Utang A',
            sisaRupiah: 1000000,
            jenisBunga: 'tanpa_bunga',
            bungaBasisPoinPerTahun: 0,
          ),
        ];

        final hasil = formatUrutanPelunasan(
          daftarUtang: utangList,
          tidakPunyaUtang: false,
        );

        expect(
          hasil,
          contains('Urutan bola salju (sisa terkecil dulu): Utang A (Rp1.000.000), lalu Utang Z (Rp1.000.000).'),
        );
      });

      test('V7: n = 0 dan pernyataan tidak_punya_utang', () {
        final hasil = formatUrutanPelunasan(
          daftarUtang: [],
          tidakPunyaUtang: true,
        );

        expect(
          hasil,
          equals('Kamu menyatakan tidak punya utang, jadi belum ada yang perlu diurutkan. Pelajaran ini siap dipakai kalau nanti kamu berutang.'),
        );
      });

      test('V8: n = 0 tanpa pernyataan', () {
        final hasil = formatUrutanPelunasan(
          daftarUtang: [],
          tidakPunyaUtang: false,
        );

        expect(hasil, equals('Belum ada utang aktif untuk diurutkan.'));
      });
    });
  });
}
