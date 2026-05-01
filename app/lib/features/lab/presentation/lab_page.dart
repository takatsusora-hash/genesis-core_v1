import 'package:flutter/material.dart';

import '../../../shared/widgets/section_card.dart';

class LabPage extends StatelessWidget {
  const LabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lab')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          SectionCard(title: 'Validation News', child: Text('検証ニュースと統計を表示予定。')),
        ],
      ),
    );
  }
}
