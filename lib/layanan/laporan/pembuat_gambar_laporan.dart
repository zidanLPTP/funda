import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../perhitungan/perhitungan_laporan_bulanan.dart';
import '../../fitur/belajar/model/pembaca_konten.dart';
import '../../fitur/laporan/tampilan/tampilan_kartu_laporan.dart';

/// Layanan pembuat gambar PNG 1080 px dari kartu bento laporan bulanan.
class PembuatGambarLaporan {
  /// Hook override untuk pengujian headless/widget test di mana
  /// RenderRepaintBoundary.toImage() memerlukan interaksi thread rasterizer riil.
  static Future<Uint8List> Function(GlobalKey kunci, double pixelRatio)? penangkapOverride;

  /// Mengambil gambar PNG 1080 px dari RepaintBoundary yang terpasang pada GlobalKey.
  /// Rasio pixel 3.0 atas lebar 360 dp menghasilkan lebar tepat 1080 px.
  static Future<Uint8List> tangkapDariKunci(
    GlobalKey kunci, {
    double pixelRatio = 3.0,
  }) async {
    if (penangkapOverride != null) {
      return await penangkapOverride!(kunci, pixelRatio);
    }
    final boundary = kunci.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      throw StateError('RenderRepaintBoundary tidak ditemukan untuk kunci ini.');
    }
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw StateError('Gagal mengonversi gambar ke format PNG.');
    }
    return byteData.buffer.asUint8List();
  }

  /// Membungkus kartu laporan bulanan dengan constraint ukuran tetap 360 dp
  /// dan textScaler tetap (noScaling) agar tidak terpengaruh skala teks sistem.
  static Widget bungkusWidgetLaporan({
    required GlobalKey kunci,
    required TampilanTeksLaporan teks,
    bool untukEkspor = true,
  }) {
    return MediaQuery(
      data: const MediaQueryData(
        textScaler: TextScaler.noScaling,
      ),
      child: RepaintBoundary(
        key: kunci,
        child: SizedBox(
          width: 360,
          child: TampilanKartuLaporan(
            teks: teks,
            untukEkspor: untukEkspor,
          ),
        ),
      ),
    );
  }

  /// Membuat gambar PNG secara headless/programatik dari data laporan.
  static Future<Uint8List> buatGambarPng({
    required LaporanBulanan laporan,
    required KontenLaporan konten,
    required bool sensor,
  }) async {
    final teks = terapkanSensor(laporan, konten, sensor: sensor);
    final widgetLaporan = MediaQuery(
      data: const MediaQueryData(
        size: Size(360, 1400),
        textScaler: TextScaler.noScaling,
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Material(
          color: Colors.transparent,
          child: SizedBox(
            width: 360,
            child: TampilanKartuLaporan(
              teks: teks,
              untukEkspor: true,
            ),
          ),
        ),
      ),
    );

    final repaintBoundary = RenderRepaintBoundary();
    final pipelineOwner = PipelineOwner();
    final buildOwner = BuildOwner(focusManager: FocusManager());

    final renderView = RenderView(
      view: ui.PlatformDispatcher.instance.views.first,
      child: RenderPositionedBox(
        alignment: Alignment.topLeft,
        child: repaintBoundary,
      ),
      configuration: const ViewConfiguration(
        logicalConstraints: BoxConstraints(maxWidth: 360, maxHeight: 4000),
        devicePixelRatio: 1.0,
      ),
    );

    pipelineOwner.rootNode = renderView;
    renderView.prepareInitialFrame();

    final rootElement = RenderObjectToWidgetAdapter<RenderBox>(
      container: repaintBoundary,
      child: widgetLaporan,
    ).attachToRenderTree(buildOwner);

    buildOwner.buildScope(rootElement);
    buildOwner.finalizeTree();

    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();

    final image = await repaintBoundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw StateError('Gagal membuat byte PNG');
    }
    return byteData.buffer.asUint8List();
  }
}
