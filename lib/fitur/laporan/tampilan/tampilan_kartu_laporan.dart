import 'package:flutter/material.dart';
import '../../../perhitungan/perhitungan_laporan_bulanan.dart';
import '../../../tema/token.dart';

/// Widget presentasional yang merender seluruh kartu bento laporan bulanan.
/// Dapat digunakan langsung di layar pratinjau maupun dibungkus RepaintBoundary untuk ekspor PNG.
class TampilanKartuLaporan extends StatelessWidget {
  final TampilanTeksLaporan teks;
  final bool untukEkspor;

  const TampilanKartuLaporan({
    super.key,
    required this.teks,
    this.untukEkspor = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      color: WarnaFunda.latar,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Laporan
          _buildHeader(),
          const SizedBox(height: 12),

          // Temuan & Saran (Bento Atas)
          _buildKartuTemuanSaran(),
          const SizedBox(height: 10),

          // Hero Arus Kas
          _buildHeroArusKas(),
          const SizedBox(height: 10),

          // Komposisi Pengeluaran
          _buildKomposisi(),
          const SizedBox(height: 10),

          // Realisasi Anggaran
          _buildRealisasiAnggaran(),
          const SizedBox(height: 10),

          // Tujuan & Dana Darurat
          _buildTujuan(),
          const SizedBox(height: 10),

          // Kekayaan Bersih
          _buildKekayaanBersih(),
          const SizedBox(height: 14),

          // Catatan Kaki
          Text(
            untukEkspor ? teks.catatanKakiEkspor : teks.catatanKakiAplikasi,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: WarnaFunda.teksRedup,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final teksBesar = MediaQuery.textScalerOf(context).scale(14) > 18;
            if (teksBesar) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    teks.judulPeriode,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: WarnaFunda.teks,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: WarnaFunda.permukaan,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: WarnaFunda.garis),
                    ),
                    child: Text(
                      teks.labelPerTanggal,
                      style: const TextStyle(
                        fontSize: 10,
                        color: WarnaFunda.teksRedup,
                      ),
                    ),
                  ),
                ],
              );
            }
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    teks.judulPeriode,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: WarnaFunda.teks,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: WarnaFunda.permukaan,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: WarnaFunda.garis),
                  ),
                  child: Text(
                    teks.labelPerTanggal,
                    style: const TextStyle(
                      fontSize: 10,
                      color: WarnaFunda.teksRedup,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 2),
        const Text(
          'Laporan Edukasi Keuangan Pribadi',
          style: TextStyle(fontSize: 11, color: WarnaFunda.teksRedup),
        ),
      ],
    );
  }

  Widget _buildKartuTemuanSaran() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: WarnaFunda.tintLaporan, // Tint biru lembut
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: WarnaFunda.garisLaporan),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Temuan Bulan Ini',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: WarnaFunda.teksLaporan,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            teks.teksTemuan,
            style: const TextStyle(
              fontSize: 11,
              color: WarnaFunda.teks,
              height: 1.3,
            ),
          ),
          const Divider(height: 14, color: WarnaFunda.garisLaporan),
          const Text(
            'Saran untuk Bulan Depan',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: WarnaFunda.utama,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            teks.teksSaran,
            style: const TextStyle(
              fontSize: 11,
              color: WarnaFunda.teks,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroArusKas() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: WarnaFunda.permukaan,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: WarnaFunda.garis),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Arus Kas Bulan Ini',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: WarnaFunda.utama,
            ),
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final teksBesar = MediaQuery.textScalerOf(context).scale(14) > 18;
              if (teksBesar) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _kolomArusKas(
                      teks.labelUangMasuk,
                      teks.nilaiUangMasuk,
                      WarnaFunda.sukses,
                    ),
                    const SizedBox(height: 8),
                    _kolomArusKas(
                      teks.labelUangKeluar,
                      teks.nilaiUangKeluar,
                      WarnaFunda.pengeluaran,
                    ),
                    const SizedBox(height: 8),
                    _kolomArusKas(
                      teks.labelSelisih,
                      teks.nilaiSelisih,
                      WarnaFunda.teks,
                    ),
                  ],
                );
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _kolomArusKas(
                      teks.labelUangMasuk,
                      teks.nilaiUangMasuk,
                      WarnaFunda.sukses,
                    ),
                  ),
                  Expanded(
                    child: _kolomArusKas(
                      teks.labelUangKeluar,
                      teks.nilaiUangKeluar,
                      WarnaFunda.pengeluaran,
                    ),
                  ),
                  Expanded(
                    child: _kolomArusKas(
                      teks.labelSelisih,
                      teks.nilaiSelisih,
                      WarnaFunda.teks,
                    ),
                  ),
                ],
              );
            },
          ),
          if (teks.teksArusKasSensor != null) ...[
            const SizedBox(height: 6),
            Text(
              teks.teksArusKasSensor!,
              style: const TextStyle(
                fontSize: 10.5,
                color: WarnaFunda.teksRedup,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _kolomArusKas(String label, String nilai, Color warnaNilai) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: WarnaFunda.teksRedup),
        ),
        const SizedBox(height: 2),
        Text(
          nilai,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: warnaNilai,
          ),
        ),
      ],
    );
  }

  Widget _buildKomposisi() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: WarnaFunda.permukaan,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: WarnaFunda.garis),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Komposisi Pengeluaran',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: WarnaFunda.utama,
            ),
          ),
          const SizedBox(height: 6),
          ...teks.komposisiPerSifat.values.map(
            (baris) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.5),
              child: Text(
                baris,
                style: const TextStyle(fontSize: 11, color: WarnaFunda.teks),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealisasiAnggaran() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: WarnaFunda.permukaan,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: WarnaFunda.garis),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Realisasi Anggaran',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: WarnaFunda.utama,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            teks.ringkasanAnggaran,
            style: const TextStyle(fontSize: 11, color: WarnaFunda.teksRedup),
          ),
          if (teks.daftarPosAnggaran.isNotEmpty) ...[
            const SizedBox(height: 6),
            ...teks.daftarPosAnggaran.map(
              (pos) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.5),
                child: Text(
                  pos.teks,
                  style: const TextStyle(fontSize: 11, color: WarnaFunda.teks),
                ),
              ),
            ),
            if (teks.barisPosLain != null) ...[
              const SizedBox(height: 3),
              Text(
                teks.barisPosLain!,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: WarnaFunda.teksRedup,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildTujuan() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: WarnaFunda.permukaan,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: WarnaFunda.garis),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tujuan dan Dana Darurat',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: WarnaFunda.utama,
            ),
          ),
          const SizedBox(height: 4),
          if (teks.teksBelumAdaTujuan != null)
            Text(
              teks.teksBelumAdaTujuan!,
              style: const TextStyle(fontSize: 11, color: WarnaFunda.teksRedup),
            )
          else
            ...teks.daftarTujuan.map(
              (tuj) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.5),
                child: Text(
                  tuj.teks,
                  style: const TextStyle(fontSize: 11, color: WarnaFunda.teks),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildKekayaanBersih() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: WarnaFunda.permukaan,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: WarnaFunda.garis),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kekayaan Bersih',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: WarnaFunda.utama,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            teks.teksSaldoDompet,
            style: const TextStyle(fontSize: 10.5, color: WarnaFunda.teks),
          ),
          const SizedBox(height: 3),
          Text(
            teks.teksSisaUtang,
            style: const TextStyle(fontSize: 10.5, color: WarnaFunda.teks),
          ),
          const SizedBox(height: 4),
          Text(
            teks.teksKekayaanBersih,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: WarnaFunda.utama,
            ),
          ),
        ],
      ),
    );
  }
}
