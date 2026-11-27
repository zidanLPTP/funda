import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/basis_data.dart';
import '../../../data/penyedia_data.dart';
import '../../../data/repositori/foto_data_repositori.dart';
import '../../../data/repositori/hasil_misi_repositori.dart';
import '../../../data/repositori/kuis_repositori.dart';
import '../../../data/repositori/progres_repositori.dart';
import '../../../data/repositori/pernyataan_repositori.dart';
import '../../../perhitungan/perhitungan_belajar.dart';
import '../../../perhitungan/perhitungan_tes_awal_personalisasi.dart';
import '../../../perhitungan/perhitungan_umpan_balik_belajar.dart';
import '../../../perhitungan/perhitungan_utang_dashboard.dart';
import '../../utang/kontroler/penyedia_utang.dart';
import '../model/pembaca_konten.dart';
import '../model/registri_misi.dart';

// Repositori Providers
final penyediaProgresRepositori = Provider<ProgresRepositori>((ref) {
  final db = ref.watch(penyediaBasisData);
  return ProgresRepositori(db);
});

final penyediaKuisRepositori = Provider<KuisRepositori>((ref) {
  final db = ref.watch(penyediaBasisData);
  return KuisRepositori(db);
});

final penyediaPernyataanRepositori = Provider<PernyataanRepositori>((ref) {
  final db = ref.watch(penyediaBasisData);
  return PernyataanRepositori(db);
});

final penyediaHasilMisiRepositori = Provider<HasilMisiRepositori>((ref) {
  final db = ref.watch(penyediaBasisData);
  return HasilMisiRepositori(db);
});

final penyediaFotoDataRepositori = Provider<FotoDataRepositori>((ref) {
  final db = ref.watch(penyediaBasisData);
  return FotoDataRepositori(db);
});

Map<String, IstilahKamus>? _cacheKamus;

/// Provider kamus istilah keuangan Funda (cache in-memory).
final penyediaKamus = FutureProvider<Map<String, IstilahKamus>>((ref) async {
  if (_cacheKamus != null && _cacheKamus!.isNotEmpty) {
    return _cacheKamus!;
  }
  final kamus = await PembacaKonten.muatKamusDariAset(rootBundle);
  _cacheKamus = kamus;
  return kamus;
});

/// Daftar ID dan tingkat modul 0 s.d. 18 sesuai kurikulum Funda.
const daftarMetadataModul = [
  ('pemula', 'mulai_tes_awal'),
  ('pemula', 'anggaran_arus_kas'),
  ('pemula', 'tabungan'),
  ('pemula', 'dana_darurat'),
  ('pemula', 'utang_cicilan'),
  ('pemula', 'waspada_penipuan'),
  ('pemula', 'psikologi_uang'),
  ('menengah', 'paylater_kredit'),
  ('menengah', 'penghasilan_tambahan'),
  ('menengah', 'pajak_dasar'),
  ('menengah', 'proteksi_dasar'),
  ('menengah', 'investasi_dasar'),
  ('menengah', 'tujuan_besar'),
  ('lanjutan', 'investasi_lanjutan'),
  ('lanjutan', 'kpr_kredit_besar'),
  ('lanjutan', 'pajak_lanjutan'),
  ('lanjutan', 'pensiun_kebebasan_finansial'),
  ('lanjutan', 'keuangan_usaha_kecil'),
  ('lanjutan', 'proteksi_keluarga_warisan'),
];

/// Cache in-memory untuk modul kurikulum agar tidak membaca 19 file JSON berulang kali.
List<ModulKonten>? _cacheSemuaModul;

/// Provider seluruh 19 modul konten dari aset (dengan cache in-memory O(1)).
final penyediaDaftarSemuaModul = FutureProvider<List<ModulKonten>>((ref) async {
  if (_cacheSemuaModul != null && _cacheSemuaModul!.isNotEmpty) {
    return _cacheSemuaModul!;
  }
  final hasil = <ModulKonten>[];
  for (final (tingkat, modulId) in daftarMetadataModul) {
    try {
      final modul = await PembacaKonten.muatModulDariAset(
        rootBundle,
        tingkat: tingkat,
        modulId: modulId,
      );
      hasil.add(modul);
    } catch (_) {}
  }
  hasil.sort((a, b) => a.urutan.compareTo(b.urutan));
  _cacheSemuaModul = hasil;
  return hasil;
});

final penyediaStreamPernyataan = StreamProvider<Map<String, String>>((ref) {
  return ref.watch(penyediaPernyataanRepositori).pantauSemuaPernyataan();
});

final penyediaStreamProgresPelajaran = StreamProvider((ref) {
  return ref.watch(penyediaProgresRepositori).pantauSemuaProgres();
});

final penyediaStreamHasilKuis = StreamProvider((ref) {
  return ref.watch(penyediaKuisRepositori).pantauSemuaHasilKuis();
});

/// Provider stream profil keuangan pengguna aktif.
final penyediaStreamProfilKeuangan = StreamProvider<EntitasProfilKeuangan?>((
  ref,
) {
  return ref.watch(penyediaProfilRepositori).pantauProfil();
});

/// Provider stream hasil tes awal terakhir.
final penyediaStreamHasilTesAwal = StreamProvider<EntitasHasilTesAwal?>((ref) {
  return ref.watch(penyediaTesAwalRepositori).pantauHasilTerakhir();
});

/// Provider konten tes awal dari aset JSON.
final penyediaKontenTesAwal = FutureProvider<KontenTesAwal>((ref) async {
  return PembacaKonten.muatTesAwalDariAset(rootBundle);
});

/// Provider konten rekomendasi dari aset JSON.
final penyediaKontenRekomendasi = FutureProvider<KontenRekomendasi>((
  ref,
) async {
  return PembacaKonten.muatRekomendasiDariAset(rootBundle);
});

/// Stream sinyal ringan perubahan transaksi untuk reaktivitas tanpa menarik seluruh baris ke memori Dart.
final penyediaSinyalTransaksiBerubah = StreamProvider<int>((ref) {
  return ref.watch(penyediaTransaksiRepositori).pantauJumlahTransaksi();
});

/// Provider snapshot foto data pengguna yang reaktif terhadap perubahan data via agregasi SQL.
final penyediaFotoData = FutureProvider<FotoDataPengguna>((ref) async {
  // Hubungkan dengan reaktivitas stream data ringan (bebas N+1)
  ref.watch(penyediaSinyalTransaksiBerubah);
  ref.watch(penyediaDaftarDompetAktif);
  ref.watch(penyediaStreamPernyataan);
  ref.watch(penyediaStreamProgresPelajaran);
  ref.watch(penyediaStreamHasilKuis);
  ref.watch(penyediaStreamProfilKeuangan);
  ref.watch(penyediaDaftarUtangAktif);

  final repo = ref.watch(penyediaFotoDataRepositori);
  return repo.ambilFotoData();
});

/// Model agregat satu modul dalam peta belajar.
class ItemPetaModul {
  final ModulKonten modul;
  final HasilStatusBelajar statusModul;
  final List<(PelajaranKonten, HasilStatusBelajar)> daftarPelajaran;

  const ItemPetaModul({
    required this.modul,
    required this.statusModul,
    required this.daftarPelajaran,
  });
}

/// Provider peta belajar lengkap yang menggabungkan konten, foto data, dan status belajar.
final penyediaPetaBelajar = FutureProvider<List<ItemPetaModul>>((ref) async {
  final daftarModul = await ref.watch(penyediaDaftarSemuaModul.future);
  final fotoData = await ref.watch(penyediaFotoData.future);
  final kamus = (await ref.watch(penyediaKamus.future)).keys.toSet();

  final hasilPeta = <ItemPetaModul>[];

  for (final modul in daftarModul) {
    final statusModul = tentukanStatusModul(modul: modul, fotoData: fotoData);

    final listPelajaranItem = <(PelajaranKonten, HasilStatusBelajar)>[];
    if (modul.tersedia && modul.daftarPelajaran.isNotEmpty) {
      // Muat berkas pelajaran modul
      final objekPelajaran = <PelajaranKonten>[];
      for (final pelId in modul.daftarPelajaran) {
        try {
          final pel = await PembacaKonten.muatPelajaranDariAset(
            rootBundle,
            tingkat: modul.tingkat,
            modulId: modul.id,
            pelajaranId: pelId,
            daftarIstilahKamus: kamus,
          );
          objekPelajaran.add(pel);
        } catch (_) {}
      }

      for (var i = 0; i < objekPelajaran.length; i++) {
        final pel = objekPelajaran[i];
        final statusPel = tentukanStatusPelajaran(
          pelajaran: pel,
          posisiIndeks: i,
          daftarPelajaranModul: objekPelajaran,
          gerbangModul: modul.gerbang,
          fotoData: fotoData,
        );
        listPelajaranItem.add((pel, statusPel));
      }
    }

    hasilPeta.add(
      ItemPetaModul(
        modul: modul,
        statusModul: statusModul,
        daftarPelajaran: listPelajaranItem,
      ),
    );
  }

  return hasilPeta;
});

/// Model data rekomendasi petak "Lanjut Belajar" di Beranda.
class InfoLanjutBelajar {
  final String labelAksi; // 'Lanjutkan', 'Mulai', 'Satu langkah lagi', 'Hebat!'
  final String judul;
  final String keterangan;
  final String rute;
  final bool bisaDibuka;

  const InfoLanjutBelajar({
    required this.labelAksi,
    required this.judul,
    required this.keterangan,
    required this.rute,
    required this.bisaDibuka,
  });
}

/// Item rekomendasi lengkap dengan teks alasan dari rekomendasi.json
class InfoRekomendasiModul {
  final ModulKonten modul;
  final String judulAlasan;
  final String deskripsiAlasan;
  final HasilStatusBelajar statusModul;

  const InfoRekomendasiModul({
    required this.modul,
    required this.judulAlasan,
    required this.deskripsiAlasan,
    required this.statusModul,
  });
}

/// Provider daftar modul rekomendasi personalisasi.
final penyediaDaftarRekomendasiModul =
    FutureProvider<List<InfoRekomendasiModul>>((ref) async {
      final entitasProfil = ref.watch(penyediaStreamProfilKeuangan).value;
      final entitasTesAwal = ref.watch(penyediaStreamHasilTesAwal).value;
      final kontenRekomendasi = await ref.watch(
        penyediaKontenRekomendasi.future,
      );
      final peta = await ref.watch(penyediaPetaBelajar.future);
      final fotoData = await ref.watch(penyediaFotoData.future);

      final profil = entitasProfil != null
          ? bangunProfil(
              jawabanProfil: {
                'punya_penghasilan': entitasProfil.punyaPenghasilan,
                'punya_utang': entitasProfil.punyaUtang,
                'dana_darurat': entitasProfil.danaDarurat,
                'menabung': entitasProfil.menabung,
                'investasi': entitasProfil.investasi,
                'mencatat_keuangan': entitasProfil.mencatatKeuangan,
              },
              tujuanUtama: entitasProfil.tujuanUtama,
            )
          : null;

      HasilSkorTesAwal? hasilTes;
      if (entitasTesAwal != null) {
        try {
          final decoded =
              jsonDecode(entitasTesAwal.skorPerModulJson)
                  as Map<String, dynamic>;
          final skorPerModul = decoded.map(
            (k, v) => MapEntry(k, (v as num).toInt()),
          );
          hasilTes = HasilSkorTesAwal(
            skorPerModul: skorPerModul,
            skorTotalPersen: entitasTesAwal.skorTotalPersen,
            totalBenar: 0,
            totalSoal: 12,
          );
        } catch (_) {}
      }

      final daftarModul = peta.map((p) => p.modul).toList();
      final statusModul = {for (final p in peta) p.modul.id: p.statusModul};

      final daftarRekomendasi = rekomendasiModul(
        profil: profil,
        hasilTes: hasilTes,
        fotoData: fotoData,
        daftarModul: daftarModul,
        statusModul: statusModul,
      );

      final hasil = <InfoRekomendasiModul>[];
      for (final rek in daftarRekomendasi) {
        final itemPeta = peta.firstWhere(
          (p) => p.modul.id == rek.modulId,
          orElse: () => ItemPetaModul(
            modul: ModulKonten(
              id: rek.modulId,
              judul: rek.modulId,
              tingkat: 'pemula',
              urutan: 0,
              deskripsiSingkat: '',
              tersedia: rek.tersedia,
              gerbang: [],
              daftarPelajaran: [],
              kuis: const KuisKonten(jumlahSoal: 0, bankSoal: []),
            ),
            statusModul: HasilStatusBelajar(
              status: rek.terbuka
                  ? StatusBelajar.terbuka
                  : StatusBelajar.terkunci,
              apaYangKurang: rek.apaYangKurang,
            ),
            daftarPelajaran: [],
          ),
        );

        final alasanKey = rek.kodeAlasanUtama;
        final alasanInfo = kontenRekomendasi.alasan[alasanKey];
        hasil.add(
          InfoRekomendasiModul(
            modul: itemPeta.modul,
            judulAlasan: alasanInfo?.judul ?? 'Rekomendasi Untukmu',
            deskripsiAlasan:
                alasanInfo?.deskripsi ??
                'Bagus untuk mendukung langkah keuanganmu.',
            statusModul: itemPeta.statusModul,
          ),
        );
      }

      return hasil;
    });

/// Provider dinamis petak "Lanjut Belajar" untuk Layar Beranda.
final penyediaLanjutBelajarBeranda = FutureProvider<InfoLanjutBelajar>((
  ref,
) async {
  final peta = await ref.watch(penyediaPetaBelajar.future);
  final rekomendasi = await ref.watch(penyediaDaftarRekomendasiModul.future);

  // 1. Cari pelajaran dengan status 'sedang' (prioritas tertinggi)
  for (final itemModul in peta) {
    for (final (pel, statusPel) in itemModul.daftarPelajaran) {
      if (statusPel.status == StatusBelajar.sedang) {
        return InfoLanjutBelajar(
          labelAksi: 'Lanjutkan',
          judul: pel.judul,
          keterangan: 'Lanjutkan kartu belajarmu dari langkah terakhir.',
          rute: '/belajar/pelajaran/${pel.modulId}/${pel.id}',
          bisaDibuka: true,
        );
      }
    }
  }

  // 2. Cari dari rekomendasi modul urutan pertama yang terbuka dan belum selesai
  for (final rek in rekomendasi) {
    ItemPetaModul? itemModul;
    for (final p in peta) {
      if (p.modul.id == rek.modul.id) {
        itemModul = p;
        break;
      }
    }
    if (itemModul != null &&
        itemModul.modul.tersedia &&
        itemModul.statusModul.status != StatusBelajar.terkunci) {
      for (final (pel, statusPel) in itemModul.daftarPelajaran) {
        if (statusPel.status == StatusBelajar.terbuka) {
          return InfoLanjutBelajar(
            labelAksi: 'Mulai',
            judul: pel.judul,
            keterangan: rek.deskripsiAlasan,
            rute: '/belajar/pelajaran/${pel.modulId}/${pel.id}',
            bisaDibuka: true,
          );
        }
      }
    }
  }

  // 3. Fallback: Cari pelajaran pertama dengan status 'terbuka' di peta belajar
  for (final itemModul in peta) {
    if (!itemModul.modul.tersedia) continue;
    for (final (pel, statusPel) in itemModul.daftarPelajaran) {
      if (statusPel.status == StatusBelajar.terbuka) {
        return InfoLanjutBelajar(
          labelAksi: 'Mulai',
          judul: pel.judul,
          keterangan: 'Pelajaran siap dipelajari sekarang.',
          rute: '/belajar/pelajaran/${pel.modulId}/${pel.id}',
          bisaDibuka: true,
        );
      }
    }
  }

  // 4. Bila ada pelajaran terkunci di modul pertama
  for (final itemModul in peta) {
    if (!itemModul.modul.tersedia) continue;
    for (final (pel, statusPel) in itemModul.daftarPelajaran) {
      if (statusPel.status == StatusBelajar.terkunci) {
        final pesan =
            statusPel.apaYangKurang.firstOrNull ?? 'Penuhi syarat data dulu';
        return InfoLanjutBelajar(
          labelAksi: 'Satu langkah lagi',
          judul: pel.judul,
          keterangan: pesan,
          rute: statusPel.ruteAksi ?? '/belajar',
          bisaDibuka: true,
        );
      }
    }
  }

  // 5. Semua pelajaran dan modul tersedia selesai
  return const InfoLanjutBelajar(
    labelAksi: 'Hebat!',
    judul: 'Semua Materi Selesai',
    keterangan: 'Kamu telah menuntaskan seluruh pelajaran yang tersedia.',
    rute: '/belajar',
    bisaDibuka: true,
  );
});

/// Provider penghasil teks umpan balik dari data riil pengguna secara reaktif.
final penyediaTeksUmpanBalikMisi = FutureProvider.autoDispose
    .family<String, String>((ref, kunci) async {
      final db = ref.watch(penyediaBasisData);
      final waktuSekarang = DateTime.now();

      switch (kunci) {
        case 'catatan_pengeluaran_terbaru':
          final daftarPengeluaran =
              await (db.select(db.tabelTransaksi)
                    ..where((t) => t.jenis.equals('keluar'))
                    ..orderBy([
                      (t) => OrderingTerm.desc(t.waktuTransaksi),
                      (t) => OrderingTerm.desc(t.id),
                    ]))
                  .get();

          final total = daftarPengeluaran.length;
          if (total == 0) {
            return formatCatatanPengeluaranTerbaru(
              jumlahTotal: 0,
              kategori: 'Belum ada',
              nominal: 0,
            );
          }
          final terbaru = daftarPengeluaran.first;
          var namaKategori = 'Pengeluaran';
          if (terbaru.kategoriId != null) {
            final kat =
                await (db.select(db.tabelKategori)
                      ..where((k) => k.id.equals(terbaru.kategoriId!)))
                    .getSingleOrNull();
            if (kat != null) {
              namaKategori = kat.nama;
            }
          }
          return formatCatatanPengeluaranTerbaru(
            jumlahTotal: total,
            kategori: namaKategori,
            nominal: terbaru.jumlahRupiah,
          );

        case 'perbandingan_pola_anggaran':
          final arusKas = ref.watch(penyediaArusKasBulanIni);
          final pemasukan = arusKas.totalMasuk;

          final daftarAnggaran =
              await (db.select(db.tabelAnggaran)..where(
                    (a) =>
                        a.tahun.equals(waktuSekarang.year) &
                        a.bulan.equals(waktuSekarang.month),
                  ))
                  .get();

          var keb = 0;
          var kei = 0;
          var tabUtg = 0;
          var belum = 0;

          for (final a in daftarAnggaran) {
            final kat = await (db.select(
              db.tabelKategori,
            )..where((k) => k.id.equals(a.kategoriId))).getSingleOrNull();
            final sifat = kat?.sifat ?? 'belum_dilabeli';
            switch (sifat) {
              case 'kebutuhan':
                keb += a.batasRupiah;
                break;
              case 'keinginan':
                kei += a.batasRupiah;
                break;
              case 'tabungan':
              case 'utang':
                tabUtg += a.batasRupiah;
                break;
              default:
                belum += a.batasRupiah;
                break;
            }
          }

          return formatPerbandinganPolaAnggaran(
            pemasukan: pemasukan,
            kebutuhan: keb,
            keinginan: kei,
            tabunganDanUtang: tabUtg,
            belumDilabeli: belum,
          );

        case 'realisasi_anggaran_bulan_ini':
          final repoAnggaran = ref.watch(penyediaAnggaranRepositori);
          final daftarRealisasi = await repoAnggaran
              .ambilRealisasiAnggaranBulan(
                tahun: waktuSekarang.year,
                bulan: waktuSekarang.month,
              );

          final daftarPos = daftarRealisasi.map((r) {
            return PosAnggaranEvaluasi(
              nama: r.namaKategori,
              batas: r.batasRupiah,
              terpakai: r.terpakaiRupiah,
            );
          }).toList();

          return formatRealisasiAnggaranBulanIni(daftarPos);

        case 'komposisi_sifat_bulan_ini':
          final pengeluaranPerSifat = (await ref.watch(
            penyediaKomposisiSifatBulanIni.future,
          ));
          final persenSifat = hitungKomposisiSifat(pengeluaranPerSifat);
          return RegistriUmpanBalik.formatKomposisiSifat(persenSifat);

        case 'ringkasan_tujuan_tabungan':
          final semuaTujuan =
              await (db.select(db.tabelTujuan)..where(
                    (t) =>
                        t.status.equals('aktif') & t.jenis.equals('tabungan'),
                  ))
                  .get();

          if (semuaTujuan.isEmpty) {
            return formatRingkasanTujuanTabungan(
              tujuan: null,
              waktuSekarang: waktuSekarang,
            );
          }

          final daftarTujuan = <DataTujuanTabunganUmpanBalik>[];
          for (final t in semuaTujuan) {
            final kantongList =
                await (db.select(db.tabelKantong)..where(
                      (k) =>
                          k.tujuanId.equals(t.id) & k.diarsipkan.equals(false),
                    ))
                    .get();

            var saldo = 0;
            for (final k in kantongList) {
              final alokasi = await (db.select(
                db.tabelAlokasiKantong,
              )..where((a) => a.kantongId.equals(k.id))).get();
              for (final a in alokasi) {
                if (a.jenis == 'isi') {
                  saldo += a.jumlahRupiah;
                } else if (a.jenis == 'ambil') {
                  saldo -= a.jumlahRupiah;
                }
              }
            }

            daftarTujuan.add(
              DataTujuanTabunganUmpanBalik(
                nama: t.nama,
                danaTerkumpul: saldo,
                targetRupiah: t.targetRupiah,
                tenggat: t.tenggat,
                dibuatPada: t.dibuatPada,
              ),
            );
          }

          final tujuanTerpilih = pilihTujuanTabunganUmpanBalik(daftarTujuan);
          return formatRingkasanTujuanTabungan(
            tujuan: tujuanTerpilih,
            waktuSekarang: waktuSekarang,
          );

        case 'estimasi_tabungan':
          final semuaTujuanEst =
              await (db.select(db.tabelTujuan)..where(
                    (t) =>
                        t.status.equals('aktif') & t.jenis.equals('tabungan'),
                  ))
                  .get();

          if (semuaTujuanEst.isEmpty) {
            return formatEstimasiTabungan(tujuan: null, setoranRataRata: 0);
          }

          final mapIdToData = <String, DataTujuanTabunganUmpanBalik>{};
          for (final t in semuaTujuanEst) {
            final kantongList =
                await (db.select(db.tabelKantong)..where(
                      (k) =>
                          k.tujuanId.equals(t.id) & k.diarsipkan.equals(false),
                    ))
                    .get();

            var saldo = 0;
            for (final k in kantongList) {
              final alokasi = await (db.select(
                db.tabelAlokasiKantong,
              )..where((a) => a.kantongId.equals(k.id))).get();
              for (final a in alokasi) {
                if (a.jenis == 'isi') {
                  saldo += a.jumlahRupiah;
                } else if (a.jenis == 'ambil') {
                  saldo -= a.jumlahRupiah;
                }
              }
            }

            mapIdToData[t.id] = DataTujuanTabunganUmpanBalik(
              nama: t.nama,
              danaTerkumpul: saldo,
              targetRupiah: t.targetRupiah,
              tenggat: t.tenggat,
              dibuatPada: t.dibuatPada,
            );
          }

          final terpilih = pilihTujuanTabunganUmpanBalik(
            mapIdToData.values.toList(),
          );
          if (terpilih == null) {
            return 'Belum ada tujuan tabungan.';
          }

          final idTerpilih = mapIdToData.entries
              .firstWhere((e) => e.value.nama == terpilih.nama)
              .key;
          final kantongTerpilih = await (db.select(
            db.tabelKantong,
          )..where((k) => k.tujuanId.equals(idTerpilih))).get();

          final alokasiList = <EntitasAlokasiSimpel>[];
          for (final k in kantongTerpilih) {
            final alokasi = await (db.select(
              db.tabelAlokasiKantong,
            )..where((a) => a.kantongId.equals(k.id))).get();
            for (final a in alokasi) {
              alokasiList.add(
                EntitasAlokasiSimpel(
                  jenis: a.jenis,
                  jumlahRupiah: a.jumlahRupiah,
                  waktu: a.waktu,
                ),
              );
            }
          }

          final setoranRata = hitungRataRataSetoranTabungan(
            daftarAlokasi: alokasiList,
            waktuSekarang: waktuSekarang,
          );

          return formatEstimasiTabungan(
            tujuan: terpilih,
            setoranRataRata: setoranRata,
          );

        case 'pengeluaran_wajib_bulanan':
          final semuaTransaksiKeluar = await (db.select(
            db.tabelTransaksi,
          )..where((t) => t.jenis.equals('keluar'))).get();

          final daftarWajib = <ItemPengeluaranWajib>[];
          for (final t in semuaTransaksiKeluar) {
            if (t.kategoriId != null) {
              final kat = await (db.select(
                db.tabelKategori,
              )..where((k) => k.id.equals(t.kategoriId!))).getSingleOrNull();
              if (kat != null &&
                  (kat.sifat == 'kebutuhan' || kat.sifat == 'utang')) {
                daftarWajib.add(
                  ItemPengeluaranWajib(
                    jumlahRupiah: t.jumlahRupiah,
                    sifat: kat.sifat,
                    waktu: t.waktuTransaksi,
                  ),
                );
              }
            }
          }

          final hasilWajib = hitungPengeluaranWajibBulanan(
            daftarPengeluaran: daftarWajib,
            waktuSekarang: waktuSekarang,
          );

          return formatTeksPengeluaranWajibBulanan(hasilWajib);

        case 'target_dana_darurat':
          final semuaTransaksiKeluarTarget = await (db.select(
            db.tabelTransaksi,
          )..where((t) => t.jenis.equals('keluar'))).get();

          final daftarWajibTarget = <ItemPengeluaranWajib>[];
          for (final t in semuaTransaksiKeluarTarget) {
            if (t.kategoriId != null) {
              final kat = await (db.select(
                db.tabelKategori,
              )..where((k) => k.id.equals(t.kategoriId!))).getSingleOrNull();
              if (kat != null &&
                  (kat.sifat == 'kebutuhan' || kat.sifat == 'utang')) {
                daftarWajibTarget.add(
                  ItemPengeluaranWajib(
                    jumlahRupiah: t.jumlahRupiah,
                    sifat: kat.sifat,
                    waktu: t.waktuTransaksi,
                  ),
                );
              }
            }
          }

          final hasilWajibTarget = hitungPengeluaranWajibBulanan(
            daftarPengeluaran: daftarWajibTarget,
            waktuSekarang: waktuSekarang,
          );

          return formatTargetDanaDarurat(pengeluaranWajib: hasilWajibTarget);

        case 'progres_dana_darurat':
          final tujuanDaruratRow =
              await (db.select(db.tabelTujuan)
                    ..where(
                      (t) =>
                          t.status.equals('aktif') &
                          t.jenis.equals('dana_darurat'),
                    )
                    ..limit(1))
                  .getSingleOrNull();

          DataTujuanDanaDaruratUmpanBalik? tujuanDarurat;
          if (tujuanDaruratRow != null) {
            final kantongList =
                await (db.select(db.tabelKantong)..where(
                      (k) =>
                          k.tujuanId.equals(tujuanDaruratRow.id) &
                          k.diarsipkan.equals(false),
                    ))
                    .get();

            var saldo = 0;
            for (final k in kantongList) {
              final alokasi = await (db.select(
                db.tabelAlokasiKantong,
              )..where((a) => a.kantongId.equals(k.id))).get();
              for (final a in alokasi) {
                if (a.jenis == 'isi') {
                  saldo += a.jumlahRupiah;
                } else if (a.jenis == 'ambil') {
                  saldo -= a.jumlahRupiah;
                }
              }
            }

            tujuanDarurat = DataTujuanDanaDaruratUmpanBalik(
              danaTerkumpul: saldo,
              targetRupiah: tujuanDaruratRow.targetRupiah,
            );
          }

          final semuaTransaksiKeluarProgres = await (db.select(
            db.tabelTransaksi,
          )..where((t) => t.jenis.equals('keluar'))).get();

          final daftarWajibProgres = <ItemPengeluaranWajib>[];
          for (final t in semuaTransaksiKeluarProgres) {
            if (t.kategoriId != null) {
              final kat = await (db.select(
                db.tabelKategori,
              )..where((k) => k.id.equals(t.kategoriId!))).getSingleOrNull();
              if (kat != null &&
                  (kat.sifat == 'kebutuhan' || kat.sifat == 'utang')) {
                daftarWajibProgres.add(
                  ItemPengeluaranWajib(
                    jumlahRupiah: t.jumlahRupiah,
                    sifat: kat.sifat,
                    waktu: t.waktuTransaksi,
                  ),
                );
              }
            }
          }

          final hasilWajibProgres = hitungPengeluaranWajibBulanan(
            daftarPengeluaran: daftarWajibProgres,
            waktuSekarang: waktuSekarang,
          );

          final w = hasilWajibProgres.total > 0
              ? hasilWajibProgres.total
              : null;
          return formatProgresDanaDarurat(
            tujuan: tujuanDarurat,
            pengeluaranWajibPerBulan: w,
          );

        case 'ringkasan_utang':
          final repoUtang = ref.watch(penyediaUtangRepositori);
          final daftarUtang = await repoUtang.ambilDaftarUtangUmpanBalik();
          final pernyataan =
              await (db.select(db.tabelPernyataan)..where(
                    (p) =>
                        p.kunci.equals('tidak_punya_utang') &
                        p.nilai.equals('true'),
                  ))
                  .getSingleOrNull();
          final semuaTx = await db.select(db.tabelTransaksi).get();
          final pemasukan = hitungPemasukanBulananRataRata(
            daftarTransaksi: semuaTx,
            waktuSekarang: waktuSekarang,
          );
          return formatRingkasanUtang(
            daftarUtang: daftarUtang,
            pemasukan: pemasukan,
            tidakPunyaUtang: pernyataan != null,
          );

        case 'biaya_pinjaman_tercatat':
          final repoUtang = ref.watch(penyediaUtangRepositori);
          final daftarUtang = await repoUtang.ambilDaftarUtangUmpanBalik();
          final pernyataan =
              await (db.select(db.tabelPernyataan)..where(
                    (p) =>
                        p.kunci.equals('tidak_punya_utang') &
                        p.nilai.equals('true'),
                  ))
                  .getSingleOrNull();
          return formatBiayaPinjamanTercatat(
            daftarUtang: daftarUtang,
            tidakPunyaUtang: pernyataan != null,
          );

        case 'rasio_cicilan_bulan_ini':
          final repoUtang = ref.watch(penyediaUtangRepositori);
          final daftarUtang = await repoUtang.ambilDaftarUtangUmpanBalik();
          final totalCicilan = daftarUtang.fold<int>(
            0,
            (prev, u) => prev + u.cicilanBulananRupiah,
          );
          final semuaTx = await db.select(db.tabelTransaksi).get();
          final pemasukan = hitungPemasukanBulananRataRata(
            daftarTransaksi: semuaTx,
            waktuSekarang: waktuSekarang,
          );
          return formatRasioCicilanBulanIni(
            totalCicilanBulanan: totalCicilan,
            pemasukan: pemasukan,
          );

        case 'urutan_pelunasan':
          final repoUtang = ref.watch(penyediaUtangRepositori);
          final daftarUtang = await repoUtang.ambilDaftarUtangUmpanBalik();
          final pernyataan =
              await (db.select(db.tabelPernyataan)..where(
                    (p) =>
                        p.kunci.equals('tidak_punya_utang') &
                        p.nilai.equals('true'),
                  ))
                  .getSingleOrNull();
          return formatUrutanPelunasan(
            daftarUtang: daftarUtang,
            tidakPunyaUtang: pernyataan != null,
          );

        case 'ringkasan_langganan_dan_keinginan':
          final semuaTagihan = await db.select(db.tabelTagihan).get();
          final daftarTagihan = semuaTagihan
              .map(
                (t) => ItemLanggananUmpanBalik(
                  nama: t.nama,
                  jenis: t.jenis,
                  frekuensi: t.frekuensi,
                  jumlahPerkiraanRupiah: t.jumlahPerkiraanRupiah,
                  aktif: t.aktif,
                  diarsipkan: t.diarsipkan,
                ),
              )
              .toList();

          final semuaKategori = await db.select(db.tabelKategori).get();
          final petaSifatKategori = {
            for (final k in semuaKategori) k.id: k.sifat,
          };

          final sekarangLokal = waktuSekarang.toLocal();
          final awalBulan = DateTime(
            sekarangLokal.year,
            sekarangLokal.month,
            1,
          );
          final akhirBulan = DateTime(
            sekarangLokal.year,
            sekarangLokal.month + 1,
            1,
          );

          final txBulanIni =
              await (db.select(db.tabelTransaksi)..where(
                    (t) =>
                        (t.jenis.equals('keluar') |
                            t.jenis.equals('pengeluaran')) &
                        t.waktuTransaksi.isBiggerOrEqualValue(awalBulan) &
                        t.waktuTransaksi.isSmallerThanValue(akhirBulan),
                  ))
                  .get();

          var totalKeinginan = 0;
          for (final tx in txBulanIni) {
            if (tx.kategoriId != null &&
                petaSifatKategori[tx.kategoriId] == 'keinginan') {
              totalKeinginan += tx.jumlahRupiah;
            }
          }

          return formatRingkasanLanggananDanKeinginan(
            daftarTagihan: daftarTagihan,
            totalKeinginanBulanIniRupiah: totalKeinginan,
          );

        case 'ringkasan_proteksi_dasar':
          final tujuanDaruratRow =
              await (db.select(db.tabelTujuan)
                    ..where(
                      (t) =>
                          t.jenis.equals('dana_darurat') &
                          (t.status.equals('aktif') |
                              t.status.equals('tercapai')),
                    )
                    ..limit(1))
                  .getSingleOrNull();

          var danaDaruratTerkumpul = 0;
          if (tujuanDaruratRow != null) {
            final kantongList =
                await (db.select(db.tabelKantong)..where(
                      (k) =>
                          k.tujuanId.equals(tujuanDaruratRow.id) &
                          k.diarsipkan.equals(false),
                    ))
                    .get();

            for (final k in kantongList) {
              final alokasi = await (db.select(
                db.tabelAlokasiKantong,
              )..where((a) => a.kantongId.equals(k.id))).get();
              for (final a in alokasi) {
                if (a.jenis == 'isi') {
                  danaDaruratTerkumpul += a.jumlahRupiah;
                } else if (a.jenis == 'ambil') {
                  danaDaruratTerkumpul -= a.jumlahRupiah;
                }
              }
            }
            if (danaDaruratTerkumpul < 0) {
              danaDaruratTerkumpul = 0;
            }
          }

          final semuaTransaksiKeluar =
              await (db.select(db.tabelTransaksi)..where(
                    (t) =>
                        t.jenis.equals('keluar') |
                        t.jenis.equals('pengeluaran'),
                  ))
                  .get();

          final semuaKategori = await db.select(db.tabelKategori).get();
          final petaSifatKategori = {
            for (final k in semuaKategori) k.id: k.sifat,
          };

          final daftarWajib = <ItemPengeluaranWajib>[];
          for (final t in semuaTransaksiKeluar) {
            if (t.kategoriId != null) {
              final sifat = petaSifatKategori[t.kategoriId];
              if (sifat == 'kebutuhan' || sifat == 'utang') {
                daftarWajib.add(
                  ItemPengeluaranWajib(
                    jumlahRupiah: t.jumlahRupiah,
                    sifat: sifat!,
                    waktu: t.waktuTransaksi,
                  ),
                );
              }
            }
          }

          final hasilWajib = hitungPengeluaranWajibBulanan(
            daftarPengeluaran: daftarWajib,
            waktuSekarang: waktuSekarang,
          );

          final String dasarStr;
          if (hasilWajib.dasar == DasarPengeluaranWajib.tigaBulanTerakhir) {
            dasarStr = 'rata-rata 3 bulan terakhir';
          } else {
            dasarStr = 'bulan ini';
          }

          return formatRingkasanProteksiDasar(
            pengeluaranWajibBulananRupiah: hasilWajib.total,
            dasarPengeluaranWajib: dasarStr,
            danaDaruratTerkumpul: danaDaruratTerkumpul,
          );

        case 'ringkasan_pemasukan_tambahan':
          final db = ref.read(penyediaBasisData);
          final waktuSekarang = DateTime.now();
          final awalBulan = DateTime(
            waktuSekarang.year,
            waktuSekarang.month,
            1,
          );
          final akhirBulan = DateTime(
            waktuSekarang.year,
            waktuSekarang.month + 1,
            1,
          );

          final txMasukBulanIni =
              await (db.select(db.tabelTransaksi)..where(
                    (t) =>
                        t.jenis.equals('masuk') &
                        t.waktuTransaksi.isBiggerOrEqualValue(awalBulan) &
                        t.waktuTransaksi.isSmallerThanValue(akhirBulan),
                  ))
                  .get();

          final semuaKategori = await db.select(db.tabelKategori).get();
          final petaNamaKategori = {
            for (final k in semuaKategori) k.id: k.nama,
          };

          final petaPemasukan = <String, int>{};
          for (final tx in txMasukBulanIni) {
            final namaKat =
                (tx.kategoriId != null
                    ? petaNamaKategori[tx.kategoriId]
                    : null) ??
                'Lainnya';
            petaPemasukan[namaKat] =
                (petaPemasukan[namaKat] ?? 0) + tx.jumlahRupiah;
          }

          final pernyataan =
              await (db.select(db.tabelPernyataan)
                    ..where((p) => p.kunci.equals('baru_satu_sumber')))
                  .getSingleOrNull();
          final baruSatuSumber =
              pernyataan != null && pernyataan.nilai == 'true';

          return formatRingkasanPemasukanTambahan(
            petaPemasukanPerKategori: petaPemasukan,
            baruSatuSumber: baruSatuSumber,
          );

        case 'ringkasan_penghasilan_tahunan':
          final db = ref.read(penyediaBasisData);
          final waktuSekarang = DateTime.now();
          final awalTahun = DateTime(waktuSekarang.year, 1, 1);
          final akhirTahun = DateTime(waktuSekarang.year + 1, 1, 1);

          final txMasukTahunIni =
              await (db.select(db.tabelTransaksi)..where(
                    (t) =>
                        t.jenis.equals('masuk') &
                        t.waktuTransaksi.isBiggerOrEqualValue(awalTahun) &
                        t.waktuTransaksi.isSmallerThanValue(akhirTahun),
                  ))
                  .get();

          var totalTahunIni = 0;
          final bulanSet = <int>{};
          for (final tx in txMasukTahunIni) {
            totalTahunIni += tx.jumlahRupiah;
            bulanSet.add(tx.waktuTransaksi.month);
          }

          return formatRingkasanPenghasilanTahunan(
            totalPemasukanTahunIni: totalTahunIni,
            jumlahBulanTercatat: bulanSet.length,
          );

        case 'ringkasan_tujuan_besar':
          final db = ref.read(penyediaBasisData);
          final semuaTujuan =
              await (db.select(db.tabelTujuan)..where(
                    (t) =>
                        t.status.equals('aktif') &
                        t.jenis.isNotIn(['dana_darurat']),
                  ))
                  .get();

          final waktuSekarang = DateTime.now();
          final daftarTujuan = <DataTujuanBesarUmpanBalik>[];
          for (final t in semuaTujuan) {
            final kantongList =
                await (db.select(db.tabelKantong)..where(
                      (k) =>
                          k.tujuanId.equals(t.id) & k.diarsipkan.equals(false),
                    ))
                    .get();

            var saldo = 0;
            for (final k in kantongList) {
              final alokasi = await (db.select(
                db.tabelAlokasiKantong,
              )..where((a) => a.kantongId.equals(k.id))).get();
              for (final a in alokasi) {
                if (a.jenis == 'isi') {
                  saldo += a.jumlahRupiah;
                } else if (a.jenis == 'ambil') {
                  saldo -= a.jumlahRupiah;
                }
              }
            }

            int? bulanTersisa;
            if (t.tenggat != null) {
              bulanTersisa = hitungBulanTersisa(t.tenggat!, waktuSekarang);
            }

            daftarTujuan.add(
              DataTujuanBesarUmpanBalik(
                nama: t.nama,
                targetRupiah: t.targetRupiah,
                danaTerkumpulRupiah: saldo,
                bulanTersisa: bulanTersisa,
                jenis: t.jenis,
                dibuatPada: t.dibuatPada,
                tenggat: t.tenggat,
              ),
            );
          }

          final terpilih = pilihTujuanBesarUmpanBalik(daftarTujuan);
          return formatRingkasanTujuanBesar(tujuan: terpilih);

        case 'uji_kemampuan_kpr':
          final repoTx = ref.read(penyediaTransaksiRepositori);
          final waktuSekarang = DateTime.now();
          final pemasukan = await repoTx.hitungPemasukanRataRataSQL(
            waktuSekarang: waktuSekarang,
          );

          final repoUtang = ref.read(penyediaUtangRepositori);
          final daftarUtang = await repoUtang.ambilDaftarUtangUmpanBalik();
          final totalCicilan = daftarUtang.fold<int>(
            0,
            (prev, u) => prev + u.cicilanBulananRupiah,
          );

          final totalSaldo = ref.watch(penyediaTotalSaldoAktif);

          return formatUjiKemampuanKpr(
            pemasukanRataRata: pemasukan,
            totalCicilanAktifRupiah: totalCicilan,
            totalSaldoDompetAktifRupiah: totalSaldo,
          );

        case 'proyeksi_kebebasan_finansial':
          final semuaTransaksiKeluar =
              await (db.select(db.tabelTransaksi)..where(
                    (t) =>
                        t.jenis.equals('keluar') |
                        t.jenis.equals('pengeluaran'),
                  ))
                  .get();

          final semuaKategori = await db.select(db.tabelKategori).get();
          final petaSifatKategori = {
            for (final k in semuaKategori) k.id: k.sifat,
          };

          final daftarWajib = <ItemPengeluaranWajib>[];
          for (final t in semuaTransaksiKeluar) {
            if (t.kategoriId != null) {
              final sifat = petaSifatKategori[t.kategoriId];
              if (sifat == 'kebutuhan' || sifat == 'utang') {
                daftarWajib.add(
                  ItemPengeluaranWajib(
                    jumlahRupiah: t.jumlahRupiah,
                    sifat: sifat!,
                    waktu: t.waktuTransaksi,
                  ),
                );
              }
            }
          }

          final hasilWajib = hitungPengeluaranWajibBulanan(
            daftarPengeluaran: daftarWajib,
            waktuSekarang: waktuSekarang,
          );

          final String dasarStr;
          if (hasilWajib.dasar == DasarPengeluaranWajib.tigaBulanTerakhir) {
            dasarStr = 'rata-rata 3 bulan terakhir';
          } else {
            dasarStr = 'bulan ini';
          }

          final totalSaldo = ref.watch(penyediaTotalSaldoAktif);
          final repoUtang = ref.read(penyediaUtangRepositori);
          final totalUtang = await repoUtang.hitungTotalSisaUtangAktifSQL();
          final kekayaanBersih = hitungKekayaanBersih(
            totalSaldoDompetAktifRupiah: totalSaldo,
            totalSisaUtangRupiah: totalUtang,
          );

          return formatProyeksiKebebasanFinansial(
            pengeluaranWajibBulananRupiah: hasilWajib.total,
            dasarPengeluaranWajib: dasarStr,
            kekayaanBersihRupiah: kekayaanBersih,
          );

        case 'ringkasan_usaha_kecil':
          final daftarDompetAktif = await (db.select(
            db.tabelDompet,
          )..where((d) => d.diarsipkan.equals(false))).get();
          final jumlahDompetAktif = daftarDompetAktif.length;

          final arusKas = ref.watch(penyediaArusKasBulanIni);
          final totalPemasukanBulanIniRupiah = arusKas.totalMasuk;
          final totalPengeluaranBulanIniRupiah = arusKas.totalKeluar;

          final pernyataan =
              await (db.select(db.tabelPernyataan)
                    ..where((p) => p.kunci.equals('belum_punya_usaha')))
                  .getSingleOrNull();
          final belumPunyaUsaha =
              pernyataan != null && pernyataan.nilai == 'true';

          return RegistriUmpanBalik.formatRingkasanUsahaKecilMisi(
            jumlahDompetAktif: jumlahDompetAktif,
            totalPemasukanBulanIniRupiah: totalPemasukanBulanIniRupiah,
            totalPengeluaranBulanIniRupiah: totalPengeluaranBulanIniRupiah,
            belumPunyaUsaha: belumPunyaUsaha,
          );

        case 'arus_kas_bulan_ini':
        default:
          final arusKas = ref.watch(penyediaArusKasBulanIni);
          return RegistriUmpanBalik.formatArusKasBulanIni(arusKas);
      }
    });

/// Entri istilah kamus yang sudah terbuka beserta informasi modul sumbernya.
class EntriKamusTerbuka {
  final IstilahKamus istilah;
  final String? sumberModul;

  const EntriKamusTerbuka({required this.istilah, this.sumberModul});
}

/// Ringkasan daftar istilah kamus yang sudah terbuka sesuai progres belajar.
class RingkasanKamusTerbuka {
  final List<EntriKamusTerbuka> daftarTerbuka;
  final int totalIstilah;

  const RingkasanKamusTerbuka({
    required this.daftarTerbuka,
    required this.totalIstilah,
  });
}

const Set<String> _istilahDasarModulSatu = {
  'sifat pengeluaran',
  'dompet',
  'surplus',
  'defisit',
  'cicilan',
};

final RegExp _polaKurungIstilahKamus = RegExp(r'\{\{([^}]+)\}\}');

Set<String> _ekstrakIstilahPelajaran(PelajaranKonten pel) {
  final hasil = <String>{};
  void kumpulkan(String? teks) {
    if (teks == null || teks.isEmpty) return;
    for (final m in _polaKurungIstilahKamus.allMatches(teks)) {
      final kunci = m.group(1)?.trim().toLowerCase();
      if (kunci != null && kunci.isNotEmpty) {
        hasil.add(kunci);
      }
    }
  }

  kumpulkan(pel.pemantik);
  for (final k in pel.kartu) {
    kumpulkan(k.judul);
    kumpulkan(k.isi);
  }
  if (pel.contohAngka != null) {
    kumpulkan(pel.contohAngka!.judul);
    kumpulkan(pel.contohAngka!.kesimpulan);
    for (final b in pel.contohAngka!.baris) {
      kumpulkan(b.label);
    }
  }
  for (final c in pel.cekPaham) {
    kumpulkan(c.tanya);
    kumpulkan(c.penjelasan);
    for (final p in c.pilihan) {
      kumpulkan(p);
    }
  }
  kumpulkan(pel.misi.judul);
  kumpulkan(pel.misi.deskripsi);
  kumpulkan(pel.misi.instruksi);
  kumpulkan(pel.misi.pertanyaan);
  if (pel.misi.skenario != null) {
    kumpulkan(pel.misi.skenario!.pemantik);
    for (final o in pel.misi.skenario!.opsi) {
      kumpulkan(o.teks);
      kumpulkan(o.umpanBalik);
    }
  }
  if (pel.misi.langkah != null) {
    for (final l in pel.misi.langkah!) {
      kumpulkan(l.teks);
    }
  }
  kumpulkan(pel.tindakLanjut);
  return hasil;
}

/// Menghitung daftar istilah kamus yang sudah terbuka berdasarkan progres belajar.
RingkasanKamusTerbuka hitungKamusTerbuka({
  required Map<String, IstilahKamus> kamus,
  required List<ItemPetaModul> peta,
}) {
  final sumberPerKunci = <String, String>{};
  var modulSatuTerbuka = false;

  for (var i = 0; i < peta.length; i++) {
    final itemModul = peta[i];
    final modul = itemModul.modul;
    if (modul.id == 'anggaran_arus_kas' &&
        itemModul.statusModul.status != StatusBelajar.terkunci) {
      modulSatuTerbuka = true;
    }

    final labelModul = modul.urutan > 0
        ? 'Modul ${modul.urutan} · ${modul.judul}'
        : modul.judul;

    for (final (pel, statusPel) in itemModul.daftarPelajaran) {
      final sudahDibuka =
          statusPel.status == StatusBelajar.sedang ||
          statusPel.status == StatusBelajar.selesai;
      if (!sudahDibuka) continue;

      for (final kunci in _ekstrakIstilahPelajaran(pel)) {
        if (kamus.containsKey(kunci)) {
          sumberPerKunci.putIfAbsent(kunci, () => labelModul);
        }
      }
    }
  }

  if (modulSatuTerbuka) {
    final itemModul1 = peta
        .where((m) => m.modul.id == 'anggaran_arus_kas')
        .firstOrNull;
    final labelModul1 = itemModul1 != null
        ? 'Modul ${itemModul1.modul.urutan} · ${itemModul1.modul.judul}'
        : 'Modul 1 · Anggaran & Arus Kas';
    for (final kunci in _istilahDasarModulSatu) {
      if (kamus.containsKey(kunci)) {
        sumberPerKunci.putIfAbsent(kunci, () => labelModul1);
      }
    }
  }

  final daftarTerbuka =
      sumberPerKunci.entries
          .map(
            (e) =>
                EntriKamusTerbuka(istilah: kamus[e.key]!, sumberModul: e.value),
          )
          .toList()
        ..sort(
          (a, b) => a.istilah.istilah.toLowerCase().compareTo(
            b.istilah.istilah.toLowerCase(),
          ),
        );

  return RingkasanKamusTerbuka(
    daftarTerbuka: daftarTerbuka,
    totalIstilah: kamus.length,
  );
}

/// Menyaring daftar istilah kamus terbuka berdasarkan nama istilah, arti, maupun contoh.
List<EntriKamusTerbuka> filterKamusTerbuka(
  List<EntriKamusTerbuka> daftar,
  String kueri,
) {
  final q = kueri.trim().toLowerCase();
  if (q.isEmpty) return daftar;

  final cocok = daftar.where((entri) {
    final i = entri.istilah;
    return i.istilah.toLowerCase().contains(q) ||
        i.arti.toLowerCase().contains(q) ||
        i.contohRupiah.toLowerCase().contains(q);
  }).toList();

  // Prioritaskan kecocokan langsung pada nama istilah di urutan atas.
  cocok.sort((a, b) {
    final aNama = a.istilah.istilah.toLowerCase().contains(q) ? 0 : 1;
    final bNama = b.istilah.istilah.toLowerCase().contains(q) ? 0 : 1;
    if (aNama != bNama) return aNama.compareTo(bNama);
    return a.istilah.istilah.toLowerCase().compareTo(
      b.istilah.istilah.toLowerCase(),
    );
  });
  return cocok;
}

/// Provider reaktif kamus istilah keuangan yang sudah terbuka sesuai progres belajar.
final penyediaKamusTerbuka = FutureProvider<RingkasanKamusTerbuka>((ref) async {
  final kamus = await ref.watch(penyediaKamus.future);
  final peta = await ref.watch(penyediaPetaBelajar.future);
  return hitungKamusTerbuka(kamus: kamus, peta: peta);
});
