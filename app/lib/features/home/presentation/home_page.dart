import 'package:flutter/material.dart';

import '../../../shared/widgets/section_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          SectionCard(title: 'Today Card', child: Text('今日の記録・AI導線を配置予定。')),
        ],
      ),
    );
  }
}
