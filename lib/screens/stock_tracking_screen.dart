import 'package:flutter/material.dart';

import '../utils/navigation_helpers.dart';

class StockTrackingScreen extends StatelessWidget {
  const StockTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: buildAppMenuDrawer(),
      appBar: AppBar(
        leading: buildMenuLeading(),
        title: const Text('Borsa Takip'),
        actions: [buildHomeAction(context)],
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'Borsa takip ekrani hazirlaniyor.\nYakin zamanda canli BIST hisseleri ve ozet performanslar eklenecek.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

