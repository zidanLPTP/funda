import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../perhitungan/perhitungan_laporan_bulanan.dart';
import '../../fitur/belajar/model/pembaca_konten.dart';

/// Pembuat dokumen PDF laporan bulanan Funda.
class PembuatPdfLaporan {
  final Uint8List fontRegularBytes;
  final Uint8List fontBoldBytes;

  const PembuatPdfLaporan({
    required this.fontRegularBytes,
    required this.fontBoldBytes,
  });

  /// Memuat font TTF dari aset bundle aplikasi.
  static Future<PembuatPdfLaporan> muatDariAset() async {
    final regData = await rootBundle.load(
      'aset/font/PlusJakartaSans-Regular.ttf',
    );
    final boldData = await rootBundle.load(
      'aset/font/PlusJakartaSans-Bold.ttf',
    );
    return PembuatPdfLaporan(
      fontRegularBytes: regData.buffer.asUint8List(),
      fontBoldBytes: boldData.buffer.asUint8List(),
    );
  }

  /// Membuat dokumen PDF dan mengembalikan byte data dokumen.
  Future<Uint8List> buatPdf({
    required LaporanBulanan laporan,
    required KontenLaporan konten,
    required bool sensor,
  }) async {
    final pdf = pw.Document();
    final fontReg = pw.Font.ttf(fontRegularBytes.buffer.asByteData());
    final fontBold = pw.Font.ttf(fontBoldBytes.buffer.asByteData());

    final teks = terapkanSensor(laporan, konten, sensor: sensor);

    // Palet warna PDF Funda
    const warnaKartu = PdfColor.fromInt(0xFFFFFFFF);
    const warnaTeksUtama = PdfColor.fromInt(0xFF191C1B);
    const warnaTeksSekunder = PdfColor.fromInt(0xFF6F7975);
    const warnaGaris = PdfColor.fromInt(0xFFE0E5E2);
    const warnaPrimer = PdfColor.fromInt(0xFF006C4C);
    const warnaAksenTemuan = PdfColor.fromInt(0xFF006684);

    pw.Widget buildKartu({
      required pw.Widget child,
      PdfColor latar = warnaKartu,
    }) {
      return pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 8),
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: latar,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          border: pw.Border.all(color: warnaGaris, width: 0.5),
        ),
        child: child,
      );
    }

    pw.Widget buildJudulBagian(String judul) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 4),
        child: pw.Text(
          judul,
          style: pw.TextStyle(font: fontBold, fontSize: 10, color: warnaPrimer),
        ),
      );
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (pw.Context context) {
          return [
            // Header Laporan
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      teks.judulPeriode,
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 18,
                        color: warnaTeksUtama,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'Laporan Edukasi Keuangan Pribadi',
                      style: pw.TextStyle(
                        font: fontReg,
                        fontSize: 9,
                        color: warnaTeksSekunder,
                      ),
                    ),
                  ],
                ),
                pw.Text(
                  teks.labelPerTanggal,
                  style: pw.TextStyle(
                    font: fontReg,
                    fontSize: 9,
                    color: warnaTeksSekunder,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 12),

            // Kartu Temuan & Saran
            buildKartu(
              latar: const PdfColor.fromInt(0xFFEBF6FA),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    konten.judulBagian['temuan'] ?? 'Temuan bulan ini',
                    style: pw.TextStyle(
                      font: fontBold,
                      fontSize: 10,
                      color: warnaAksenTemuan,
                    ),
                  ),
                  pw.SizedBox(height: 3),
                  pw.Text(
                    teks.teksTemuan,
                    style: pw.TextStyle(
                      font: fontReg,
                      fontSize: 9,
                      color: warnaTeksUtama,
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    konten.judulBagian['saran'] ?? 'Saran untuk bulan depan',
                    style: pw.TextStyle(
                      font: fontBold,
                      fontSize: 10,
                      color: warnaPrimer,
                    ),
                  ),
                  pw.SizedBox(height: 3),
                  pw.Text(
                    teks.teksSaran,
                    style: pw.TextStyle(
                      font: fontReg,
                      fontSize: 9,
                      color: warnaTeksUtama,
                    ),
                  ),
                ],
              ),
            ),

            // Kartu Arus Kas
            buildKartu(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  buildJudulBagian(
                    konten.judulBagian['arusKas'] ?? 'Arus kas bulan ini',
                  ),
                  pw.SizedBox(height: 4),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            teks.labelUangMasuk,
                            style: pw.TextStyle(
                              font: fontReg,
                              fontSize: 8,
                              color: warnaTeksSekunder,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            teks.nilaiUangMasuk,
                            style: pw.TextStyle(
                              font: fontBold,
                              fontSize: 11,
                              color: warnaPrimer,
                            ),
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            teks.labelUangKeluar,
                            style: pw.TextStyle(
                              font: fontReg,
                              fontSize: 8,
                              color: warnaTeksSekunder,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            teks.nilaiUangKeluar,
                            style: pw.TextStyle(
                              font: fontBold,
                              fontSize: 11,
                              color: const PdfColor.fromInt(0xFFBA1A1A),
                            ),
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            teks.labelSelisih,
                            style: pw.TextStyle(
                              font: fontReg,
                              fontSize: 8,
                              color: warnaTeksSekunder,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            teks.nilaiSelisih,
                            style: pw.TextStyle(
                              font: fontBold,
                              fontSize: 11,
                              color: warnaTeksUtama,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (teks.teksArusKasSensor != null) ...[
                    pw.SizedBox(height: 6),
                    pw.Text(
                      teks.teksArusKasSensor!,
                      style: pw.TextStyle(
                        font: fontReg,
                        fontSize: 8,
                        color: warnaTeksSekunder,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Kartu Komposisi Pengeluaran
            buildKartu(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  buildJudulBagian(
                    konten.judulBagian['komposisi'] ?? 'Komposisi pengeluaran',
                  ),
                  pw.SizedBox(height: 4),
                  ...teks.komposisiPerSifat.values.map(
                    (baris) => pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 2),
                      child: pw.Text(
                        baris,
                        style: pw.TextStyle(
                          font: fontReg,
                          fontSize: 8.5,
                          color: warnaTeksUtama,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Kartu Realisasi Anggaran
            buildKartu(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  buildJudulBagian(
                    konten.judulBagian['anggaran'] ?? 'Realisasi anggaran',
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    teks.ringkasanAnggaran,
                    style: pw.TextStyle(
                      font: fontReg,
                      fontSize: 8.5,
                      color: warnaTeksSekunder,
                    ),
                  ),
                  if (teks.daftarPosAnggaran.isNotEmpty) ...[
                    pw.SizedBox(height: 4),
                    ...teks.daftarPosAnggaran.map(
                      (pos) => pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
                        child: pw.Text(
                          pos.teks,
                          style: pw.TextStyle(
                            font: fontReg,
                            fontSize: 8.5,
                            color: warnaTeksUtama,
                          ),
                        ),
                      ),
                    ),
                    if (teks.barisPosLain != null) ...[
                      pw.SizedBox(height: 2),
                      pw.Text(
                        teks.barisPosLain!,
                        style: pw.TextStyle(
                          font: fontReg,
                          fontSize: 8,
                          color: warnaTeksSekunder,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),

            // Kartu Tujuan dan Dana Darurat
            buildKartu(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  buildJudulBagian(
                    konten.judulBagian['tujuan'] ?? 'Tujuan dan dana darurat',
                  ),
                  pw.SizedBox(height: 2),
                  if (teks.teksBelumAdaTujuan != null)
                    pw.Text(
                      teks.teksBelumAdaTujuan!,
                      style: pw.TextStyle(
                        font: fontReg,
                        fontSize: 8.5,
                        color: warnaTeksSekunder,
                      ),
                    )
                  else
                    ...teks.daftarTujuan.map(
                      (tuj) => pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
                        child: pw.Text(
                          tuj.teks,
                          style: pw.TextStyle(
                            font: fontReg,
                            fontSize: 8.5,
                            color: warnaTeksUtama,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Kartu Kekayaan Bersih
            buildKartu(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  buildJudulBagian(
                    konten.judulBagian['kekayaan'] ?? 'Kekayaan bersih',
                  ),
                  pw.SizedBox(height: 4),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        teks.teksSaldoDompet,
                        style: pw.TextStyle(
                          font: fontReg,
                          fontSize: 8.5,
                          color: warnaTeksUtama,
                        ),
                      ),
                      pw.Text(
                        teks.teksSisaUtang,
                        style: pw.TextStyle(
                          font: fontReg,
                          fontSize: 8.5,
                          color: warnaTeksUtama,
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 3),
                  pw.Text(
                    teks.teksKekayaanBersih,
                    style: pw.TextStyle(
                      font: fontBold,
                      fontSize: 9.5,
                      color: warnaPrimer,
                    ),
                  ),
                ],
              ),
            ),

            // Catatan Kaki
            pw.SizedBox(height: 10),
            pw.Text(
              teks.catatanKakiEkspor,
              style: pw.TextStyle(
                font: fontReg,
                fontSize: 7.5,
                color: warnaTeksSekunder,
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }
}
