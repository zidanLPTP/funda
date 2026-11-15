import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../data/basis_data.dart';
import '../../../data/model/frekuensi_tagihan.dart';
import '../../../data/model/jenis_tagihan.dart';
import '../../../data/penyedia_data.dart';
import '../../../komponen/komponen_funda.dart';
import '../../../komponen/pembantu_ikon.dart';
import '../../../perhitungan/perhitungan_tagihan.dart';
import '../../../tema/token.dart';
import '../../../util/format_rupiah.dart';
import '../../pengaturan/kontroler/penyedia_pengaturan.dart';
import '../kontroler/penyedia_tagihan.dart';

/// Layar formulir untuk membuat atau mengubah data tagihan/langganan berulang.
class LayarFormTagihan extends ConsumerStatefulWidget {
  const LayarFormTagihan({super.key, this.tagihan});

  final EntitasTagihan? tagihan;

  @override
  ConsumerState<LayarFormTagihan> createState() => _LayarFormTagihanState();
}

class _LayarFormTagihanState extends ConsumerState<LayarFormTagihan> {
  final _kunciForm = GlobalKey<FormState>();
  late final TextEditingController _pengontrolNama;
  late final TextEditingController _pengontrolNominalPerkiraan;

  late JenisTagihan _jenis;
  late FrekuensiTagihan _frekuensi;
  late DateTime _tanggalJatuhTempoPertama;
  DateTime? _berakhirPada;
  bool _punyaBatasAkhir = false;

  String? _kategoriIdTerpilih;
  String? _dompetBawaanIdTerpilih;
  late Set<int> _hariPengingatTerpilih;
  bool _memuat = false;

  bool get _sedangUbah => widget.tagihan != null;

  @override
  void initState() {
    super.initState();
    final t = widget.tagihan;
    _pengontrolNama = TextEditingController(text: t?.nama ?? '');
    _pengontrolNominalPerkiraan = TextEditingController(
      text: (t?.jumlahPerkiraanRupiah != null && t!.jumlahPerkiraanRupiah! > 0)
          ? formatRupiah(t.jumlahPerkiraanRupiah!)
          : '',
    );

    _jenis = t != null ? JenisTagihan.dariKode(t.jenis) : JenisTagihan.tagihan;
    _frekuensi = t != null
        ? FrekuensiTagihan.dariKode(t.frekuensi)
        : FrekuensiTagihan.bulanan;
    _tanggalJatuhTempoPertama =
        t?.jatuhTempoPertama.toLocal() ?? DateTime.now();
    _berakhirPada = t?.berakhirPada?.toLocal();
    _punyaBatasAkhir = _berakhirPada != null;

    _kategoriIdTerpilih = t?.kategoriId;
    _dompetBawaanIdTerpilih = t?.dompetId;

    if (t != null) {
      _hariPengingatTerpilih = uraiHariPengingat(
        t.pengingatHariSebelum,
      ).toSet();
    } else {
      _hariPengingatTerpilih = {0, 1, 3}; // Bawaan: Hari-H, H-1, H-3
    }
  }

  @override
  void dispose() {
    _pengontrolNama.dispose();
    _pengontrolNominalPerkiraan.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggalJatuhTempo() async {
    final tanggal = await showDatePicker(
      context: context,
      initialDate: _tanggalJatuhTempoPertama,
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
    );
    if (tanggal != null && mounted) {
      setState(() => _tanggalJatuhTempoPertama = tanggal);
    }
  }

  Future<void> _pilihTanggalBerakhir() async {
    final tanggal = await showDatePicker(
      context: context,
      initialDate:
          _berakhirPada ??
          _tanggalJatuhTempoPertama.add(const Duration(days: 365)),
      firstDate: _tanggalJatuhTempoPertama,
      lastDate: DateTime(2045),
    );
    if (tanggal != null && mounted) {
      setState(() => _berakhirPada = tanggal);
    }
  }

  Future<void> _simpan() async {
    if (!_kunciForm.currentState!.validate()) return;
    if (_kategoriIdTerpilih == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih kategori pengeluaran terlebih dahulu.'),
        ),
      );
      return;
    }

    final nama = _pengontrolNama.text.trim();
    int? nominalPerkiraan;
    final teksNominal = _pengontrolNominalPerkiraan.text.trim();
    if (teksNominal.isNotEmpty) {
      try {
        final angka = ambilAngkaRupiah(teksNominal);
        if (angka > 0) nominalPerkiraan = angka;
      } catch (_) {}
    }

    final daftarHari = _hariPengingatTerpilih.toList()..sort();

    setState(() => _memuat = true);

    try {
      final repo = ref.read(penyediaTagihanRepositori);
      if (_sedangUbah) {
        await repo.perbaruiTagihan(
          TabelTagihanCompanion(
            id: drift.Value(widget.tagihan!.id),
            nama: drift.Value(nama),
            jenis: drift.Value(_jenis.kode),
            jumlahPerkiraanRupiah: drift.Value(nominalPerkiraan),
            kategoriId: drift.Value(_kategoriIdTerpilih!),
            dompetId: drift.Value(_dompetBawaanIdTerpilih),
            frekuensi: drift.Value(_frekuensi.kode),
            jatuhTempoPertama: drift.Value(_tanggalJatuhTempoPertama),
            berakhirPada: drift.Value(_punyaBatasAkhir ? _berakhirPada : null),
            pengingatHariSebelum: drift.Value(
              serialisasiHariPengingat(daftarHari),
            ),
            aktif: drift.Value(widget.tagihan!.aktif),
            diarsipkan: drift.Value(widget.tagihan!.diarsipkan),
            dibuatPada: drift.Value(widget.tagihan!.dibuatPada),
          ),
        );
      } else {
        await repo.buatTagihan(
          nama: nama,
          jenis: _jenis.kode,
          jumlahPerkiraanRupiah: nominalPerkiraan,
          kategoriId: _kategoriIdTerpilih!,
          dompetId: _dompetBawaanIdTerpilih,
          frekuensi: _frekuensi.kode,
          jatuhTempoPertama: _tanggalJatuhTempoPertama,
          berakhirPada: _punyaBatasAkhir ? _berakhirPada : null,
          pengingatHariSebelum: daftarHari,
        );
      }

      await sinkronkanPengingatLokal(ref);

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _sedangUbah
                  ? 'Tagihan "$nama" berhasil diperbarui.'
                  : 'Tagihan "$nama" berhasil ditambahkan.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan tagihan: $e')));
      }
    } finally {
      if (mounted) setState(() => _memuat = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final daftarKategori = ref.watch(penyediaDaftarKategori).value ?? [];
    final kategoriKeluar = daftarKategori
        .where((k) => k.arus == 'keluar' && !k.diarsipkan)
        .toList();
    final daftarDompet = ref.watch(penyediaDaftarDompetAktif).value ?? [];
    final pengingatGlobalAktif = ref.watch(penyediaPengingatAktif);

    return Scaffold(
      backgroundColor: WarnaFunda.latar,
      appBar: AppBar(
        title: TeksFunda.judulBagian(
          _sedangUbah ? 'Ubah Tagihan' : 'Tambah Tagihan',
        ),
        backgroundColor: WarnaFunda.latar,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _kunciForm,
          child: ListView(
            padding: const EdgeInsets.all(SpasiFunda.m),
            children: [
              if (!pengingatGlobalAktif)
                Container(
                  margin: const EdgeInsets.only(bottom: SpasiFunda.m),
                  padding: const EdgeInsets.all(SpasiFunda.m),
                  decoration: BoxDecoration(
                    color: WarnaFunda.tintAmber,
                    borderRadius: BorderRadius.circular(SudutFunda.kartu),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        LucideIcons.bellOff,
                        color: WarnaFunda.teks,
                        size: 24,
                      ),
                      const SizedBox(width: SpasiFunda.m),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const TeksFunda.label(
                              'Pengingat Sistem Belum Dinyalakan',
                            ),
                            const SizedBox(height: SpasiFunda.xs),
                            const TeksFunda.catatan(
                              'Nyalakan di Pengaturan agar notifikasi jadwal jatuh tempo bisa muncul di perangkatmu.',
                            ),
                            const SizedBox(height: SpasiFunda.s),
                            GestureDetector(
                              onTap: () => context.push('/pengaturan'),
                              child: const TeksFunda.label(
                                'Buka Pengaturan →',
                                warna: WarnaFunda.utama,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // 1. Jenis Tagihan
              PetakBento(
                anak: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TeksFunda.label('Jenis Tagihan'),
                    const SizedBox(height: SpasiFunda.s),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Tagihan')),
                            selected: _jenis == JenisTagihan.tagihan,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _jenis = JenisTagihan.tagihan);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: SpasiFunda.s),
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Langganan')),
                            selected: _jenis == JenisTagihan.langganan,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _jenis = JenisTagihan.langganan);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: SpasiFunda.m),

              // 2. Nama & Perkiraan Nominal
              PetakBento(
                anak: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _pengontrolNama,
                      decoration: const InputDecoration(
                        labelText: 'Nama Tagihan / Layanan *',
                        hintText: 'Misal: Listrik PLN, Spotify, Internet',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama tagihan wajib diisi.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: SpasiFunda.m),
                    TextFormField(
                      controller: _pengontrolNominalPerkiraan,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Perkiraan Nominal (Opsional)',
                        hintText: 'Rp 0 (kosongkan jika fluktuatif)',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (teks) {
                        if (teks.isEmpty) return;
                        try {
                          final nominal = ambilAngkaRupiah(teks);
                          final baru = formatRupiah(nominal);
                          _pengontrolNominalPerkiraan.value = TextEditingValue(
                            text: baru,
                            selection: TextSelection.collapsed(
                              offset: baru.length,
                            ),
                          );
                        } catch (_) {}
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: SpasiFunda.m),

              // 3. Frekuensi & Jadwal Jatuh Tempo
              PetakBento(
                anak: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TeksFunda.label('Frekuensi Pengulangan'),
                    const SizedBox(height: SpasiFunda.s),
                    Wrap(
                      spacing: SpasiFunda.s,
                      children: FrekuensiTagihan.values.map((f) {
                        return ChoiceChip(
                          label: Text(f.judul),
                          selected: _frekuensi == f,
                          onSelected: (selected) {
                            if (selected) setState(() => _frekuensi = f);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: SpasiFunda.m),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        LucideIcons.calendar,
                        color: WarnaFunda.utama,
                      ),
                      title: const TeksFunda.isi('Jatuh Tempo Pertama'),
                      subtitle: TeksFunda.catatan(
                        DateFormat(
                          'EEEE, d MMMM yyyy',
                          'id_ID',
                        ).format(_tanggalJatuhTempoPertama),
                      ),
                      trailing: const Icon(LucideIcons.chevronRight, size: 20),
                      onTap: _pilihTanggalJatuhTempo,
                    ),
                    const Divider(),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const TeksFunda.isi('Memiliki Batas Akhir'),
                      subtitle: const TeksFunda.catatan(
                        'Aktifkan jika langganan berakhir pada tanggal tertentu',
                      ),
                      value: _punyaBatasAkhir,
                      onChanged: (aktif) {
                        setState(() {
                          _punyaBatasAkhir = aktif;
                          if (aktif && _berakhirPada == null) {
                            _berakhirPada = _tanggalJatuhTempoPertama.add(
                              const Duration(days: 365),
                            );
                          }
                        });
                      },
                    ),
                    if (_punyaBatasAkhir) ...[
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          LucideIcons.calendarOff,
                          color: WarnaFunda.pengeluaran,
                        ),
                        title: const TeksFunda.isi('Berakhir Pada'),
                        subtitle: TeksFunda.catatan(
                          _berakhirPada != null
                              ? DateFormat(
                                  'EEEE, d MMMM yyyy',
                                  'id_ID',
                                ).format(_berakhirPada!)
                              : 'Pilih tanggal',
                        ),
                        trailing: const Icon(
                          LucideIcons.chevronRight,
                          size: 20,
                        ),
                        onTap: _pilihTanggalBerakhir,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: SpasiFunda.m),

              // 4. Kategori & Dompet Bawaan
              PetakBento(
                anak: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TeksFunda.label('Kategori & Pembayaran'),
                    const SizedBox(height: SpasiFunda.s),
                    DropdownButtonFormField<String>(
                      initialValue: _kategoriIdTerpilih,
                      decoration: const InputDecoration(
                        labelText: 'Kategori Pengeluaran *',
                        border: OutlineInputBorder(),
                      ),
                      items: kategoriKeluar.map((k) {
                        return DropdownMenuItem(
                          value: k.id,
                          child: Row(
                            children: [
                              Icon(ambilIkonLucide(k.ikon), size: 18),
                              const SizedBox(width: SpasiFunda.s),
                              Text(k.nama),
                            ],
                          ),
                        );
                      }).toList(),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Kategori pengeluaran wajib dipilih.';
                        }
                        return null;
                      },
                      onChanged: (id) =>
                          setState(() => _kategoriIdTerpilih = id),
                    ),
                    const SizedBox(height: SpasiFunda.m),
                    DropdownButtonFormField<String>(
                      initialValue: _dompetBawaanIdTerpilih,
                      decoration: const InputDecoration(
                        labelText: 'Dompet Pembayaran Bawaan (Opsional)',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Pilih Saat Membayar'),
                        ),
                        ...daftarDompet.map((d) {
                          return DropdownMenuItem(
                            value: d.id,
                            child: Row(
                              children: [
                                Icon(ambilIkonLucide(d.ikon), size: 18),
                                const SizedBox(width: SpasiFunda.s),
                                Text(d.nama),
                              ],
                            ),
                          );
                        }),
                      ],
                      onChanged: (id) =>
                          setState(() => _dompetBawaanIdTerpilih = id),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: SpasiFunda.m),

              // 5. Pilihan Pengingat
              PetakBento(
                anak: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TeksFunda.label('Waktu Pengingat'),
                    const SizedBox(height: SpasiFunda.xs),
                    const TeksFunda.catatan(
                      'Pemberitahuan ramah sebelum jatuh tempo tiba',
                    ),
                    const SizedBox(height: SpasiFunda.s),
                    Wrap(
                      spacing: SpasiFunda.s,
                      children: [
                        FilterChip(
                          label: const Text('Hari-H (0 hari)'),
                          selected: _hariPengingatTerpilih.contains(0),
                          onSelected: (aktif) {
                            setState(() {
                              if (aktif) {
                                _hariPengingatTerpilih.add(0);
                              } else {
                                _hariPengingatTerpilih.remove(0);
                              }
                            });
                          },
                        ),
                        FilterChip(
                          label: const Text('1 hari sebelumnya'),
                          selected: _hariPengingatTerpilih.contains(1),
                          onSelected: (aktif) {
                            setState(() {
                              if (aktif) {
                                _hariPengingatTerpilih.add(1);
                              } else {
                                _hariPengingatTerpilih.remove(1);
                              }
                            });
                          },
                        ),
                        FilterChip(
                          label: const Text('3 hari sebelumnya'),
                          selected: _hariPengingatTerpilih.contains(3),
                          onSelected: (aktif) {
                            setState(() {
                              if (aktif) {
                                _hariPengingatTerpilih.add(3);
                              } else {
                                _hariPengingatTerpilih.remove(3);
                              }
                            });
                          },
                        ),
                        FilterChip(
                          label: const Text('7 hari sebelumnya'),
                          selected: _hariPengingatTerpilih.contains(7),
                          onSelected: (aktif) {
                            setState(() {
                              if (aktif) {
                                _hariPengingatTerpilih.add(7);
                              } else {
                                _hariPengingatTerpilih.remove(7);
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: SpasiFunda.l),

              // Tombol Simpan
              TombolFunda.primer(
                teks: _sedangUbah ? 'Simpan Perubahan' : 'Tambah Tagihan',
                memuat: _memuat,
                lebarPenuh: true,
                padaTekan: _simpan,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
