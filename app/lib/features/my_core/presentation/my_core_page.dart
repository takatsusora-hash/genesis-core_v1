import 'package:flutter/material.dart';

import '../../../shared/widgets/section_card.dart';

class MyCorePage extends StatelessWidget {
  const MyCorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Core')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          SectionCard(title: 'Genesis Type', child: Text('独自タイプと4軸スコアを表示予定。')),
        ],
      ),
    );
  }
}
