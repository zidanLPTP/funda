import 'package:flutter/material.dart';
import '../tema/token.dart';

/// Pembungkus layar standar aplikasi Funda.
/// Memastikan SafeArea, latar belakang sesuai tema, dan margin standar 16dp.
class PembungkusLayar extends StatelessWidget {
  const PembungkusLayar({
    super.key,
    required this.anak,
    this.appBar,
    this.bilahBawah,
    this.bisaGulir = false,
    this.padding,
    this.warnaLatar = WarnaFunda.latar,
  });

  final Widget anak;
  final PreferredSizeWidget? appBar;
  final Widget? bilahBawah;
  final bool bisaGulir;
  final EdgeInsetsGeometry? padding;
  final Color warnaLatar;

  @override
  Widget build(BuildContext context) {
    final paddingStandar =
        padding ?? const EdgeInsets.all(SpasiFunda.marginLayar);

    Widget konten = anak;
    if (bisaGulir) {
      konten = SingleChildScrollView(
        padding: paddingStandar,
        physics: const AlwaysScrollableScrollPhysics(),
        child: anak,
      );
    } else {
      konten = Padding(padding: paddingStandar, child: anak);
    }

    return Scaffold(
      backgroundColor: warnaLatar,
      appBar: appBar,
      body: SafeArea(child: konten),
      bottomNavigationBar: bilahBawah,
    );
  }
}
