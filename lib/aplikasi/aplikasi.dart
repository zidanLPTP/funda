import 'package:flutter/material.dart';
import '../tema/tema.dart';
import 'rute.dart';

/// Akar widget aplikasi Funda.
class AplikasiFunda extends StatelessWidget {
  const AplikasiFunda({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Funda',
      debugShowCheckedModeBanner: false,
      theme: TemaFunda.temaTerang,
      routerConfig: ruteFunda,
    );
  }
}
