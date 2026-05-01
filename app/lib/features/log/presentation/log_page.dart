import 'package:flutter/material.dart';

import '../../../shared/widgets/section_card.dart';

class LogPage extends StatelessWidget {
  const LogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          SectionCard(title: 'Daily Log', child: Text('5指標の軽量ログ入力を配置予定。')),
        ],
      ),
    );
  }
}
