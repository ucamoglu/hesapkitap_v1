import 'package:flutter/material.dart';

import '../utils/navigation_helpers.dart';

class CryptoTrackingScreen extends StatelessWidget {
  const CryptoTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: buildAppMenuDrawer(),
      appBar: AppBar(
        leading: buildMenuLeading(),
        title: const Text('Kripto Para Takip'),
        actions: [buildHomeAction(context)],
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'Kripto para takip ekrani hazirlaniyor.\nYakin zamanda canli kripto pariteleri ve ozet performanslar eklenecek.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
